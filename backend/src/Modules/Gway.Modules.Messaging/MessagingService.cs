using System.Security.Claims;
using System.Text.Json;
using Gway.Modules.Messaging.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Gway.SharedKernel.Supabase;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Gway.Modules.Messaging;

public sealed record DirectConversation(Guid Id, string State)
{
    public const string Active = "active";
    public const string Request = "request";
}

public sealed record SendMessageRequest(string? Body, string? ImagePath);

public sealed record SentMessage(Guid Id, DateTimeOffset CreatedAt);

public sealed record ChatModeRequest(bool AdminsOnly);

public static class MessagingModule
{
    public static IServiceCollection AddMessagingModule(this IServiceCollection services)
    {
        services.AddSingleton<MessagingService>();
        services.AddSingleton<IMessagingAdministration>(sp => sp.GetRequiredService<MessagingService>());
        services.AddSingleton<IMessagingModeration>(sp => sp.GetRequiredService<MessagingService>());
        return services;
    }

    /// <summary>Message writes (docs/ARCHITECTURE.md §3f); reads go through Supabase.</summary>
    public static IEndpointRouteBuilder MapMessagingEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/messages/direct/{userId:guid}", async (Guid userId, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.OpenDirectAsync(user.GetUserId(), userId, ct)).ToHttpResult());

        app.MapPost("/conversations/{id:guid}/messages", async (
                Guid id, SendMessageRequest body, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.SendAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        app.MapPost("/conversations/{id:guid}/acceptance", async (Guid id, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.AnswerRequestAsync(user.GetUserId(), id, accept: true, ct)).ToHttpResult());

        app.MapDelete("/conversations/{id:guid}/acceptance", async (Guid id, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.AnswerRequestAsync(user.GetUserId(), id, accept: false, ct)).ToHttpResult());

        app.MapDelete("/messages/{id:guid}", async (Guid id, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.DeleteAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapPut("/groups/{id:guid}/chat", async (Guid id, ChatModeRequest body, ClaimsPrincipal user, MessagingService messaging, CancellationToken ct) =>
            (await messaging.SetChatModeAsync(user.GetUserId(), id, body.AdminsOnly, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Conversations and messages (docs/ARCHITECTURE.md §3f). Triggers and the database functions re-check every rule.</summary>
internal sealed partial class MessagingService(NpgsqlDataSource db, ISupabaseStorage storage, ILogger<MessagingService> log)
    : IMessagingAdministration, IMessagingModeration
{
    public const string ImageBucket = "message-images";
    public const int MaxBody = 2000;

    private static readonly Error NotFound = Error.NotFound("message.not_found", "Mesaj bulunamadı.");

    private static Error RuleError(string code) => code switch
    {
        "message_forbidden" => Error.Forbidden("message.forbidden", "Bu sohbete yazamazsın."),
        "message_not_found" => Error.NotFound("message.user_not_found", "Kullanıcı bulunamadı."),
        "blocked" => Error.RuleViolation("message.blocked", "Engel olduğu için mesaj gönderilemiyor."),
        "message_request_pending" => Error.RuleViolation("message.request_pending", "Yanıt vermeden önce mesaj isteğini kabul et."),
        "message_declined" => Error.RuleViolation("message.declined", "Bu kişi mesaj isteğini kabul etmedi."),
        "message_muted" => Error.RuleViolation("message.muted", "Bu grupta susturulduğun için yazamazsın."),
        "message_admins_only" => Error.RuleViolation("message.admins_only", "Bu sohbette yalnızca yöneticiler yazabilir."),
        "message_rate_limited" => Error.RuleViolation("message.rate_limited", "Çok hızlı mesaj gönderiyorsun. Biraz bekleyip tekrar dene."),
        "message_empty" => Error.Validation("message.empty", "Bir mesaj yaz ya da fotoğraf ekle."),
        "message_image_invalid" => Error.Validation("message.image_invalid", "Fotoğraf bulunamadı. Yeniden yüklemeyi dene."),
        "message_no_request" => Error.NotFound("message.no_request", "Bekleyen bir mesaj isteği yok."),
        "match_ended" => Error.RuleViolation("message.match_ended", "Eşleşme bittiği için bu sohbet kapandı."),
        "match_chat_locked" => Error.RuleViolation("message.match_chat_locked", "Eşleştiğin kişiye yazmak için Eşleşme Sohbeti paketi gerekir."),
        "teammate_chat_locked" => Error.RuleViolation("message.teammate_chat_locked",
            "Ekip arkadaşına yazmak için Ekip Arkadaşı paketi gerekir."),
        "message_not_allowed" => Error.RuleViolation("message.not_allowed",
            "Özel mesaj yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla yazışmak içindir."),
        _ => Error.RuleViolation($"message.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    public Task<Result<DirectConversation>> OpenDirectAsync(Guid actor, Guid other, CancellationToken ct)
    {
        if (actor == other) return Task.FromResult<Result<DirectConversation>>(Error.Validation("message.self", "Kendine mesaj gönderemezsin."));
        return ActingTransaction.RunAsync<DirectConversation>(db, actor, async (conn, tx) =>
        {
            var json = (string)(await ActingTransaction.ScalarAsync(conn, tx,
                "select private.open_direct_conversation(@other)::text", ct, ("other", other)))!;
            using var doc = JsonDocument.Parse(json);
            return new DirectConversation(doc.RootElement.GetProperty("id").GetGuid(), doc.RootElement.GetProperty("state").GetString()!);
        }, RuleError, ct);
    }

    public Task<Result<SentMessage>> SendAsync(Guid actor, Guid conversation, SendMessageRequest request, CancellationToken ct)
    {
        var body = request?.Body?.Trim() ?? "";
        var image = string.IsNullOrWhiteSpace(request?.ImagePath) ? null : request.ImagePath.Trim();
        if (body.Length > MaxBody)
            return Task.FromResult<Result<SentMessage>>(Error.Validation("message.too_long", $"Mesaj en fazla {MaxBody} karakter olabilir."));
        if (body.Length == 0 && image is null) return Task.FromResult<Result<SentMessage>>(RuleError("message_empty"));
        if (image is not null && (!image.StartsWith($"{conversation}/", StringComparison.Ordinal) || image.Contains("..", StringComparison.Ordinal)))
            return Task.FromResult<Result<SentMessage>>(RuleError("message_image_invalid"));

        return ActingTransaction.RunAsync<SentMessage>(db, actor, async (conn, tx) =>
        {
            if (image is not null && await ActingTransaction.ScalarAsync(conn, tx,
                    """
                    select 1 from storage.objects
                    where bucket_id = @bucket and name = @path and owner_id = @owner and coalesce(metadata->>'mimetype', '') like 'image/%'
                    """, ct, ("bucket", ImageBucket), ("path", image), ("owner", actor.ToString())) is null)
                return RuleError("message_image_invalid");

            await using var cmd = new NpgsqlCommand(
                """
                insert into public.messages (conversation_id, sender_id, body, image_path)
                values (@conversation, @sender, @body, @image)
                returning id, created_at
                """, conn, tx);
            cmd.Parameters.AddWithValue("conversation", conversation);
            cmd.Parameters.AddWithValue("sender", actor);
            cmd.Parameters.AddWithValue("body", body);
            cmd.Parameters.Add(new NpgsqlParameter<string?>("image", image));
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            return new SentMessage(r.GetGuid(0), r.GetFieldValue<DateTimeOffset>(1));
        }, RuleError, ct);
    }

    public Task<Result> AnswerRequestAsync(Guid actor, Guid conversation, bool accept, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ExecuteAsync(conn, tx, "select private.answer_message_request(@c, @accept)", ct,
                ("c", conversation), ("accept", accept));
            return Result.Success();
        }, RuleError, ct);

    /// <summary>The sender deletes their own message for everyone; its photo is deleted after the commit.</summary>
    public async Task<Result> DeleteAsync(Guid actor, Guid id, CancellationToken ct)
    {
        string? image = null;
        var deleted = await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            image = await ActingTransaction.ScalarAsync(conn, tx,
                "select coalesce(image_path, '') from public.messages where id = @id and sender_id = @me and deleted_at is null for update", ct,
                ("id", id), ("me", actor)) as string;
            if (image is null) return NotFound;
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.messages set deleted_at = now() where id = @id", ct, ("id", id));
            return Result.Success();
        }, RuleError, ct);
        if (deleted.IsSuccess && !string.IsNullOrEmpty(image)) await DeleteImageAsync(image);
        return deleted;
    }

    private async Task DeleteImageAsync(string path)
    {
        try
        {
            await storage.DeleteObjectsAsync(ImageBucket, [path], CancellationToken.None);
        }
        catch (HttpRequestException ex)
        {
            LogImageCleanupFailed(log, ex, path);
        }
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "Could not delete the message image {Path}")]
    private static partial void LogImageCleanupFailed(ILogger logger, Exception ex, string path);

    public Task<Result> SetChatModeAsync(Guid actor, Guid groupId, bool adminsOnly, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@a, @g, 'group.edit')", ct,
                    ("a", actor), ("g", groupId)) is not true)
                return Error.Forbidden("message.chat_mode_forbidden", "Sohbet ayarını yalnızca grubun yöneticileri değiştirebilir.");
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.conversations set admins_only = @mode where group_id = @g", ct,
                ("mode", adminsOnly), ("g", groupId));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actor, AuditActor.User, "group.chat_mode_changed", "group", groupId.ToString(),
                new { adminsOnly }, groupId), ct);
            return Result.Success();
        }, RuleError, ct);

    // Moderation --------------------------------------------------------------------------------

    public async Task<bool> RemoveMessageAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid messageId, string reason, CancellationToken ct) =>
        await ActingTransaction.ExecuteAsync(connection, transaction,
            "update public.messages set deleted_at = now(), removed_reason = @reason where id = @id and deleted_at is null", ct,
            ("id", messageId), ("reason", reason)) > 0;

    public Task<Result> RemoveMessageAsync(Guid actorId, Guid messageId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("message.invalid_reason", "Gerekçe 3–500 karakter olmalı."));

        return RemoveByStaffAsync(actorId, messageId, reason, ct);
    }

    private async Task<Result> RemoveByStaffAsync(Guid actorId, Guid messageId, string reason, CancellationToken ct)
    {
        string? image = null;
        var removed = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            Guid? group = null;
            var found = false;
            await using (var cmd = new NpgsqlCommand(
                """
                select c.group_id, m.image_path from public.messages m join public.conversations c on c.id = m.conversation_id
                where m.id = @id and m.deleted_at is null
                for update of m
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("id", messageId);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (await r.ReadAsync(ct))
                {
                    found = true;
                    group = r.IsDBNull(0) ? null : r.GetGuid(0);
                    image = r.IsDBNull(1) ? null : r.GetString(1);
                }
            }
            if (!found) return Error.NotFound("message.not_found", "Mesaj bulunamadı ya da zaten kaldırılmış.");
            await RemoveMessageAsync(conn, tx, messageId, reason, ct);
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "message.removed_by_admin", "message",
                messageId.ToString(), new { reason }, group), ct);
            return Result.Success();
        }, RuleError, ct);
        if (removed.IsSuccess && image is not null) await DeleteImageAsync(image);
        return removed;
    }
}
