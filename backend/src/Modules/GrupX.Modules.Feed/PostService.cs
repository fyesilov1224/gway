using System.Security.Claims;
using System.Text.RegularExpressions;
using GrupX.Modules.Feed.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using GrupX.SharedKernel.Http;
using GrupX.SharedKernel.Supabase;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace GrupX.Modules.Feed;

public sealed record PostMediaInput(string? Kind, string? Path, int Width, int Height, int? DurationMs, string? PosterPath, string? ThumbPath);

public sealed record CreatePostRequest(
    string? Caption, IReadOnlyList<PostMediaInput>? Media, Guid? GroupId, bool CommentsDisabled, bool HideLikeCount, Guid? EventId = null);

public sealed record UpdatePostRequest(string? Caption, bool? CommentsDisabled, bool? HideLikeCount);

public sealed record CreatedPost(Guid Id);

public static class FeedModule
{
    public static IServiceCollection AddFeedModule(this IServiceCollection services)
    {
        services.AddSingleton<PostService>();
        services.AddSingleton<IFeedAdministration>(sp => sp.GetRequiredService<PostService>());
        services.AddSingleton<IFeedModeration>(sp => sp.GetRequiredService<PostService>());
        return services;
    }

    /// <summary>Post writes (docs/ARCHITECTURE.md §3c). Likes, comments, saves and stories go through Supabase.</summary>
    public static IEndpointRouteBuilder MapFeedEndpoints(this IEndpointRouteBuilder app)
    {
        var posts = app.MapGroup("/posts");

        posts.MapPost("", async (CreatePostRequest body, ClaimsPrincipal user, PostService service, CancellationToken ct) =>
            (await service.CreateAsync(user.GetUserId(), body, ct)).ToHttpResult());

        posts.MapPatch("/{id:guid}", async (Guid id, UpdatePostRequest body, ClaimsPrincipal user, PostService service, CancellationToken ct) =>
            (await service.UpdateAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        posts.MapDelete("/{id:guid}", async (Guid id, ClaimsPrincipal user, PostService service, CancellationToken ct) =>
            (await service.DeleteAsync(user.GetUserId(), id, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Creating, editing and deleting posts; platform removal (docs/ARCHITECTURE.md §3c, Gönderi).</summary>
internal sealed partial class PostService(NpgsqlDataSource db, ISupabaseStorage storage, ILogger<PostService> log) : IFeedAdministration, IFeedModeration
{
    public const string Bucket = "media";
    public const int MaxCaption = 2200;
    public const int MaxMedia = 10;
    public const int MaxHashtags = 30;
    public const long MaxImageBytes = 10L * 1024 * 1024;
    public const int MaxVideoMs = 60_000;
    public const int DailyPosts = 25;

    private static readonly string[] ImageExtensions = [".jpg", ".jpeg", ".png", ".webp"];
    private static readonly string[] VideoExtensions = [".mp4", ".mov"];

    [GeneratedRegex(@"#[\p{L}\p{N}_]{1,50}")]
    private static partial Regex Hashtag();

    private static readonly Error NotFound = Error.NotFound("feed.post_not_found", "Gönderi bulunamadı.");
    private static readonly Error Forbidden = Error.Forbidden("feed.forbidden", "Bu gönderiyi yönetme yetkin yok.");

    private static Error Invalid(string message) => Error.Validation("feed.invalid_post", message);

    private static readonly Error EventForbidden = Error.Forbidden(
        "feed.event_forbidden", "Bir organizasyona anı ekleyebilmek için ona katılmış olmalısın; organizasyon başlamış olmalı.");

    private static Error RuleError(string code) => code switch
    {
        "post_rate_limited" => Error.RuleViolation("feed.post_rate_limited", "Bugün çok fazla gönderi paylaştın. Yarın tekrar dene."),
        "post_forbidden" => Forbidden,
        "event_post_forbidden" => EventForbidden,
        _ => Error.RuleViolation($"feed.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    private sealed record MediaRow(string Kind, string Path, int Width, int Height, int? DurationMs, string? PosterPath, string? ThumbPath);

    /// <summary>Checks shape, folder and extensions; storage contents are checked in the transaction.</summary>
    private static Result<List<MediaRow>> ValidateMedia(Guid actor, IReadOnlyList<PostMediaInput>? media)
    {
        if (media is null || media.Count is < 1 or > MaxMedia) return Invalid("Bir gönderide 1–10 fotoğraf ya da video olabilir.");
        var folder = $"{actor}/";
        var rows = new List<MediaRow>();
        foreach (var m in media)
        {
            var path = m.Path ?? "";
            var ext = System.IO.Path.GetExtension(path).ToLowerInvariant();
            if (!path.StartsWith(folder, StringComparison.Ordinal) || path.Contains("..", StringComparison.Ordinal))
                return Invalid("Medya dosyası bulunamadı. Yeniden yüklemeyi dene.");
            if (m.Width is < 1 or > 10000 || m.Height is < 1 or > 10000) return Invalid("Medya boyutu geçersiz.");

            bool OwnImage(string? p) =>
                p is not null && p.StartsWith(folder, StringComparison.Ordinal) && !p.Contains("..", StringComparison.Ordinal)
                && ImageExtensions.Contains(System.IO.Path.GetExtension(p).ToLowerInvariant());

            switch (m.Kind)
            {
                case "image" when ImageExtensions.Contains(ext) && m.DurationMs is null && m.PosterPath is null:
                    if (m.ThumbPath is not null && !OwnImage(m.ThumbPath)) return Invalid("Küçük kopya geçersiz.");
                    rows.Add(new MediaRow("image", path, m.Width, m.Height, null, null, m.ThumbPath));
                    break;
                case "video" when VideoExtensions.Contains(ext) && m.ThumbPath is null:
                    if (m.DurationMs is not { } ms || ms is < 1 or > MaxVideoMs) return Invalid("Videolar en fazla 60 saniye olabilir.");
                    if (m.PosterPath is not null && !OwnImage(m.PosterPath)) return Invalid("Video kapağı geçersiz.");
                    rows.Add(new MediaRow("video", path, m.Width, m.Height, ms, m.PosterPath, null));
                    break;
                default:
                    return Invalid("Yalnızca JPEG, PNG, WebP fotoğraf ve MP4, MOV video paylaşılabilir.");
            }
        }
        return rows;
    }

    private static Result<string> ValidateCaption(string? caption)
    {
        caption = caption?.Trim() ?? "";
        if (caption.Length > MaxCaption) return Invalid("Açıklama en fazla 2.200 karakter olabilir.");
        if (Hashtag().Matches(caption).Count > MaxHashtags) return Invalid("Bir gönderide en fazla 30 etiket kullanılabilir.");
        return caption;
    }

    public async Task<Result<CreatedPost>> CreateAsync(Guid actor, CreatePostRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        var caption = ValidateCaption(request.Caption);
        if (!caption.IsSuccess) return caption.Error;
        var media = ValidateMedia(actor, request.Media);
        if (!media.IsSuccess) return media.Error;

        return await ActingTransaction.RunAsync<CreatedPost>(db, actor, async (conn, tx) =>
        {
            var active = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                "select private.is_account_active(@id) and exists (select 1 from public.profiles where id = @id)", ct, ("id", actor)))!;
            if (!active) return Error.RuleViolation("feed.account_inactive", "Gönderi paylaşmak için profilini tamamlamalı ve hesabın aktif olmalı.");

            if (request.GroupId is { } groupId)
            {
                // Every member posts to the group's feed; a muted one does not (docs/ARCHITECTURE.md §3c).
                var allowed = await ActingTransaction.ScalarAsync(conn, tx,
                    "select private.can_post_in_group(@actor, @group)", ct, ("actor", actor), ("group", groupId));
                if (allowed is not true)
                    return Error.Forbidden("feed.group_forbidden", "Bu gruba paylaşım yapmak için grubun üyesi olmalısın ve susturulmuş olmamalısın.");
            }

            // A memory (docs/ARCHITECTURE.md §3d, Organizasyon sonrası): the event took place and the author went or manages it.
            if (request.EventId is { } eventId && await ActingTransaction.ScalarAsync(conn, tx,
                    """
                    select exists (
                      select 1 from public.events e
                      where e.id = @e and e.canceled_at is null and e.starts_at <= now()
                        and (exists (select 1 from public.event_attendees a where a.event_id = e.id and a.user_id = @actor and a.status = 'going')
                             or private.user_has_group_permission(@actor, e.group_id, 'events.manage')))
                    """, ct, ("e", eventId), ("actor", actor)) is not true)
                return EventForbidden;

            var today = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                "select count(*) from public.posts where author_id = @id and created_at > now() - interval '24 hours'", ct, ("id", actor)))!;
            if (today >= DailyPosts) return RuleError("post_rate_limited");

            // Every file must be the author's own upload, of the right kind and size.
            var extras = media.Value.SelectMany(m => new[] { m.PosterPath, m.ThumbPath }).OfType<string>().ToArray();
            var paths = media.Value.Select(m => m.Path).Concat(extras).ToArray();
            var stored = new Dictionary<string, (long Size, string Mime)>();
            await using (var cmd = new NpgsqlCommand(
                """
                select name, coalesce((metadata->>'size')::bigint, 0), coalesce(metadata->>'mimetype', '')
                from storage.objects where bucket_id = @bucket and name = any(@paths)
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("bucket", Bucket);
                cmd.Parameters.AddWithValue("paths", paths);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                while (await r.ReadAsync(ct)) stored[r.GetString(0)] = (r.GetInt64(1), r.GetString(2));
            }
            if (paths.Distinct(StringComparer.Ordinal).Count() != paths.Length) return Invalid("Aynı dosya iki kez kullanılamaz.");
            foreach (var extra in extras)
            {
                if (!stored.TryGetValue(extra, out var image)) return Invalid("Medya dosyası bulunamadı. Yeniden yüklemeyi dene.");
                if (!image.Mime.StartsWith("image/", StringComparison.Ordinal) || image.Size > MaxImageBytes)
                    return Invalid("Küçük kopya ya da kapak bir fotoğraf olmalı.");
            }
            foreach (var m in media.Value)
            {
                if (!stored.TryGetValue(m.Path, out var file)) return Invalid("Medya dosyası bulunamadı. Yeniden yüklemeyi dene.");
                if (!file.Mime.StartsWith(m.Kind == "image" ? "image/" : "video/", StringComparison.Ordinal))
                    return Invalid("Dosya türü medya türüyle uyuşmuyor.");
                if (m.Kind == "image" && file.Size > MaxImageBytes) return Invalid("Fotoğraflar en fazla 10 MB olabilir.");
            }

            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.posts (author_id, group_id, caption, comments_disabled, hide_like_count, event_id)
                values (@author, @group, @caption, @comments, @likes, @event) returning id
                """, ct, ("author", actor), ("group", request.GroupId), ("caption", caption.Value), ("event", request.EventId),
                ("comments", request.CommentsDisabled), ("likes", request.HideLikeCount)))!;

            foreach (var (m, i) in media.Value.Select((m, i) => (m, i)))
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    """
                    insert into public.post_media (post_id, position, kind, path, width, height, duration_ms, poster_path, thumb_path)
                    values (@post, @position, @kind, @path, @width, @height, @duration, @poster, @thumb)
                    """, ct, ("post", id), ("position", (short)i), ("kind", m.Kind), ("path", m.Path), ("width", m.Width),
                    ("height", m.Height), ("duration", m.DurationMs), ("poster", m.PosterPath), ("thumb", m.ThumbPath));
            }
            return new CreatedPost(id);
        }, RuleError, ct);
    }

    public Task<Result> UpdateAsync(Guid actor, Guid postId, UpdatePostRequest request, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(request);
        Result<string>? caption = request.Caption is null ? null : ValidateCaption(request.Caption);
        if (caption is { IsSuccess: false }) return Task.FromResult<Result>(caption.Error);

        return ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var manage = await ActingTransaction.ScalarAsync(conn, tx,
                "select private.can_manage_post(id) from public.posts where id = @id and removed_at is null for update", ct, ("id", postId));
            if (manage is null) return NotFound;
            if (manage is not true) return Forbidden;

            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.posts
                set caption = coalesce(@caption, caption),
                    comments_disabled = coalesce(@comments, comments_disabled),
                    hide_like_count = coalesce(@likes, hide_like_count)
                where id = @id
                """, ct, ("id", postId), ("caption", caption?.Value), ("comments", request.CommentsDisabled), ("likes", request.HideLikeCount));
            return Result.Success();
        }, RuleError, ct);
    }

    /// <summary>Deletes the post, then its files (a failed file delete only leaves an unreachable object).</summary>
    public async Task<Result> DeleteAsync(Guid actor, Guid postId, CancellationToken ct)
    {
        var files = new List<string>();
        var deleted = await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var manage = await ActingTransaction.ScalarAsync(conn, tx,
                "select private.can_manage_post(id) from public.posts where id = @id for update", ct, ("id", postId));
            if (manage is null) return NotFound;
            if (manage is not true) return Forbidden;

            await using (var cmd = new NpgsqlCommand("select path, poster_path, thumb_path from public.post_media where post_id = @id", conn, tx))
            {
                cmd.Parameters.AddWithValue("id", postId);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                while (await r.ReadAsync(ct))
                {
                    for (var c = 0; c < 3; c++)
                    {
                        if (!r.IsDBNull(c)) files.Add(r.GetString(c));
                    }
                }
            }
            await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.posts where id = @id", ct, ("id", postId));
            return Result.Success();
        }, RuleError, ct);

        if (deleted.IsSuccess && files.Count > 0)
        {
            try
            {
                await storage.DeleteObjectsAsync(Bucket, files, CancellationToken.None);
            }
            catch (HttpRequestException ex)
            {
                LogMediaCleanupFailed(log, ex, postId);
            }
        }
        return deleted;
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "Could not delete the media of post {PostId}")]
    private static partial void LogMediaCleanupFailed(ILogger logger, Exception ex, Guid postId);

    // Platform moderation ----------------------------------------------------------------------

    public Task<Result> RemovePostAsync(Guid actorId, Guid postId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("feed.invalid_reason", "Gerekçe 3–500 karakter olmalı."));

        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var group = await ActingTransaction.ScalarAsync(conn, tx,
                "select coalesce(group_id::text, '') from public.posts where id = @id for update", ct, ("id", postId));
            if (group is null) return NotFound;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.posts set removed_at = now(), removed_reason = @reason where id = @id and removed_at is null", ct,
                ("id", postId), ("reason", reason));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "post.removed", "post", postId.ToString(),
                new { reason }, GroupOf(group)), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> RestorePostAsync(Guid actorId, Guid postId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var group = await ActingTransaction.ScalarAsync(conn, tx,
                "select coalesce(group_id::text, '') from public.posts where id = @id for update", ct, ("id", postId));
            if (group is null) return NotFound;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.posts set removed_at = null, removed_reason = null where id = @id and removed_at is not null", ct, ("id", postId));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "post.restored", "post", postId.ToString(),
                null, GroupOf(group)), ct);
            return Result.Success();
        }, RuleError, ct);

    public Task<Result> RemoveCommentAsync(Guid actorId, Guid commentId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("feed.invalid_reason", "Gerekçe 3–500 karakter olmalı."));

        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            if (await ActingTransaction.ExecuteAsync(conn, tx,
                    "update public.comments set removed_at = now(), removed_reason = @reason where id = @id and removed_at is null", ct,
                    ("id", commentId), ("reason", reason)) == 0)
                return Error.NotFound("feed.comment_not_found", "Yorum bulunamadı ya da zaten kaldırılmış.");
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "comment.removed", "comment", commentId.ToString(),
                new { reason }), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public async Task<bool> RemoveCommentAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid commentId, string reason, CancellationToken ct) =>
        await ActingTransaction.ExecuteAsync(connection, transaction,
            "update public.comments set removed_at = now(), removed_reason = @reason where id = @id and removed_at is null", ct,
            ("id", commentId), ("reason", reason)) > 0;

    private static Guid? GroupOf(object value) => Guid.TryParse(value as string, out var id) ? id : null;
}
