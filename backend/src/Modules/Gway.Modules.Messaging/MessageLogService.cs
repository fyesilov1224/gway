using System.Text.Json;
using Gway.Modules.Messaging.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Supabase;
using Npgsql;

namespace Gway.Modules.Messaging;

/// <summary>
/// Message logs for the platform admin (docs/ARCHITECTURE.md §3f, Mesaj kayıtları). The database functions check the
/// admin role again; every search and every page is audited with its reason.
/// </summary>
internal sealed class MessageLogService(NpgsqlDataSource db, ISupabaseStorage storage) : IMessageLogs
{
    public const int PageSize = 20;
    public const int MessagePageSize = 50;
    public const int MinReason = 10;
    public const int MaxReason = 500;
    public const int MaxQuery = 100;
    private static readonly TimeSpan ImageUrlLifetime = TimeSpan.FromMinutes(10);
    private static readonly string[] Kinds = ["direct", "group", "table"];

    private static readonly JsonSerializerOptions Json = new() { PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower };

    private static readonly Error UserNotFound = Error.NotFound("message_log.user_not_found", "Bu kullanıcı adıyla bir hesap bulunamadı.");

    private static Error RuleError(string code) => code switch
    {
        "message_log_forbidden" => Error.Forbidden("message_log.forbidden", "Mesaj kayıtlarını yalnızca platform yöneticisi görebilir."),
        _ => Error.RuleViolation($"message_log.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private static Error? CheckReason(string? reason) =>
        (reason?.Trim().Length ?? 0) is < MinReason or > MaxReason
            ? Error.Validation("message_log.invalid_reason", $"Gerekçe {MinReason}–{MaxReason} karakter olmalı.")
            : null;

    public Task<Result<LogConversationPage>> SearchAsync(Guid actorId, MessageLogSearch search, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(search);
        if (CheckReason(search.Reason) is { } invalid) return Task.FromResult<Result<LogConversationPage>>(invalid);
        var kind = string.IsNullOrWhiteSpace(search.Kind) ? null : search.Kind.Trim();
        if (kind is not null && !Kinds.Contains(kind))
            return Task.FromResult<Result<LogConversationPage>>(Error.Validation("message_log.invalid_kind", "Sohbet türü geçersiz."));
        if (string.IsNullOrWhiteSpace(search.Username))
            return Task.FromResult<Result<LogConversationPage>>(Error.Validation("message_log.username_required", "Bir kullanıcı adı yaz."));
        var page = Math.Max(1, search.Page);
        var reason = search.Reason.Trim();

        return ActingTransaction.RunAsync<LogConversationPage>(db, actorId, async (conn, tx) =>
        {
            var user = await FindUserAsync(conn, tx, search.Username, ct);
            if (user is null) return UserNotFound;
            LogPerson? other = null;
            if (!string.IsNullOrWhiteSpace(search.WithUsername))
            {
                other = await FindUserAsync(conn, tx, search.WithUsername, ct);
                if (other is null) return UserNotFound;
            }

            var json = (string)(await ActingTransaction.ScalarAsync(conn, tx,
                "select private.admin_message_conversations(@target, @other, @kind, @lim, @skip)::text", ct,
                ("target", user.Id), ("other", other?.Id), ("kind", kind), ("lim", PageSize), ("skip", (page - 1) * PageSize)))!;
            var result = JsonSerializer.Deserialize<ConversationsJson>(json, Json)!;

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "message.log_searched", "user",
                user.Id.ToString(), new { reason, withUser = other?.Id, kind, page }), ct);
            return new LogConversationPage(user, other, result.Items, page, PageSize, result.Total);
        }, RuleError, ct);
    }

    public async Task<Result<LogConversationView>> ViewAsync(Guid actorId, Guid conversationId, MessageLogQuery query, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(query);
        if (CheckReason(query.Reason) is { } invalid) return invalid;
        var text = string.IsNullOrWhiteSpace(query.Query) ? null : query.Query.Trim();
        if (text is { Length: > MaxQuery }) return Error.Validation("message_log.query_too_long", $"Arama en fazla {MaxQuery} karakter olabilir.");
        var reason = query.Reason.Trim();

        LogJson? log = null;
        var read = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var json = await ActingTransaction.ScalarAsync(conn, tx,
                "select private.admin_message_log(@conv, @before, @q, @lim)::text", ct,
                ("conv", conversationId), ("before", query.Before), ("q", text), ("lim", MessagePageSize)) as string;
            if (json is null) return Error.NotFound("message_log.not_found", "Sohbet bulunamadı.");
            log = JsonSerializer.Deserialize<LogJson>(json, Json)!;

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "message.log_viewed", "conversation",
                conversationId.ToString(), new { reason, before = query.Before, query = text, messages = Math.Min(log.Messages.Count, MessagePageSize) },
                log.Conversation.Group?.Id), ct);
            return Result.Success();
        }, RuleError, ct);
        if (!read.IsSuccess) return read.Error;

        var page = log!.Messages.Take(MessagePageSize).Reverse().ToList();
        var paths = page.Where(m => m.ImagePath is not null).Select(m => m.ImagePath!).ToList();
        var urls = await storage.CreateSignedUrlsAsync(MessagingService.ImageBucket, paths, ImageUrlLifetime, ct);
        var messages = page.Select(m => new LogMessage(
            m.Id, m.Sender, m.Body, m.ImagePath is not null && urls.TryGetValue(m.ImagePath, out var url) ? url : null,
            m.HadImage || m.ImagePath is not null, m.Archived, m.CreatedAt, m.DeletedAt, m.RemovedReason, m.PurgeAfter)).ToList();
        return new LogConversationView(log.Conversation, messages, log.Messages.Count > MessagePageSize);
    }

    private static async Task<LogPerson?> FindUserAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string username, CancellationToken ct)
    {
        var name = username.Trim().TrimStart('@').ToLowerInvariant();
        await using var cmd = new NpgsqlCommand(
            "select id, username, display_name, avatar_path from public.profiles where lower(username) = @name", conn, tx);
        cmd.Parameters.AddWithValue("name", name);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return new LogPerson(r.GetGuid(0), r.GetString(1), r.GetString(2), r.IsDBNull(3) ? null : r.GetString(3));
    }

    private sealed record ConversationsJson(int Total, IReadOnlyList<LogConversation> Items);

    private sealed record MessageJson(
        Guid Id,
        LogPerson? Sender,
        string Body,
        string? ImagePath,
        bool HadImage,
        bool Archived,
        DateTimeOffset CreatedAt,
        DateTimeOffset? DeletedAt,
        string? RemovedReason,
        DateTimeOffset? PurgeAfter);

    private sealed record LogJson(LogConversationHeader Conversation, IReadOnlyList<MessageJson> Messages);
}
