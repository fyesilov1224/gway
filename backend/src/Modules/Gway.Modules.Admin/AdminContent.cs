using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Admin;

public sealed record AdminPostMedia(string Kind, string Path, string? PosterPath);

public sealed record AdminPostSummary(
    Guid Id,
    Guid? AuthorId,
    string? AuthorUsername,
    Guid? GroupId,
    string? GroupName,
    string Caption,
    AdminPostMedia? Cover,
    int MediaCount,
    int LikeCount,
    int CommentCount,
    DateTimeOffset CreatedAt,
    DateTimeOffset? RemovedAt,
    string? RemovedReason);

public sealed record AdminComment(
    Guid Id,
    Guid AuthorId,
    string? AuthorUsername,
    Guid? ParentId,
    string Body,
    DateTimeOffset CreatedAt,
    DateTimeOffset? RemovedAt,
    string? RemovedReason);

public sealed record AdminPostDetail(AdminPostSummary Post, IReadOnlyList<AdminPostMedia> Media, IReadOnlyList<AdminComment> Comments);

/// <summary>Read side of the admin content pages (docs/ARCHITECTURE.md §3c, Admin).</summary>
internal sealed class AdminContent(NpgsqlDataSource db)
{
    public const int PageSize = 24;

    private const string SummarySelect =
        """
        select p.id, p.author_id, a.username, p.group_id, g.name, p.caption,
               m.kind, m.path, m.poster_path,
               (select count(*)::int from public.post_media x where x.post_id = p.id),
               p.like_count, p.comment_count, p.created_at, p.removed_at, p.removed_reason
        from public.posts p
        left join public.profiles a on a.id = p.author_id
        left join public.groups g on g.id = p.group_id
        left join public.post_media m on m.post_id = p.id and m.position = 0
        """;

    private const string Filter =
        """
        where (@q is null or p.caption ilike @q escape '\' or a.username ilike @q escape '\' or g.name ilike @q escape '\')
          and (@removed is null or (p.removed_at is not null) = @removed)
        """;

    public async Task<PagedResult<AdminPostSummary>> SearchAsync(string? query, bool? removed, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";
        await using var conn = await db.OpenConnectionAsync(ct);

        void Bind(NpgsqlCommand cmd)
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.Add(new NpgsqlParameter<bool?>("removed", removed));
        }

        int total;
        await using (var count = new NpgsqlCommand(
            $"""
            select count(*)::int from public.posts p
            left join public.profiles a on a.id = p.author_id
            left join public.groups g on g.id = p.group_id
            {Filter}
            """, conn))
        {
            Bind(count);
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminPostSummary>();
        await using (var cmd = new NpgsqlCommand($"{SummarySelect} {Filter} order by p.created_at desc, p.id limit {PageSize} offset @offset", conn))
        {
            Bind(cmd);
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) items.Add(Read(r));
        }
        return new PagedResult<AdminPostSummary>(items, total, page, PageSize);
    }

    public async Task<Result<AdminPostDetail>> GetAsync(Guid id, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);

        AdminPostSummary post;
        await using (var cmd = new NpgsqlCommand($"{SummarySelect} where p.id = @id", conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return Error.NotFound("admin.post_not_found", "Gönderi bulunamadı.");
            post = Read(r);
        }

        var media = new List<AdminPostMedia>();
        await using (var cmd = new NpgsqlCommand(
            "select kind, path, poster_path from public.post_media where post_id = @id order by position", conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) media.Add(new AdminPostMedia(r.GetString(0), r.GetString(1), r.IsDBNull(2) ? null : r.GetString(2)));
        }

        var comments = new List<AdminComment>();
        await using (var cmd = new NpgsqlCommand(
            """
            select c.id, c.author_id, a.username, c.parent_id, c.body, c.created_at, c.removed_at, c.removed_reason
            from public.comments c
            left join public.profiles a on a.id = c.author_id
            where c.post_id = @id
            order by coalesce(c.parent_id, c.id), c.parent_id nulls first, c.created_at
            limit 500
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                comments.Add(new AdminComment(r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2),
                    r.IsDBNull(3) ? null : r.GetGuid(3), r.GetString(4), r.GetFieldValue<DateTimeOffset>(5),
                    r.IsDBNull(6) ? null : r.GetFieldValue<DateTimeOffset>(6), r.IsDBNull(7) ? null : r.GetString(7)));
            }
        }
        return new AdminPostDetail(post, media, comments);
    }

    private static AdminPostSummary Read(NpgsqlDataReader r) => new(
        r.GetGuid(0),
        r.IsDBNull(1) ? null : r.GetGuid(1),
        r.IsDBNull(2) ? null : r.GetString(2),
        r.IsDBNull(3) ? null : r.GetGuid(3),
        r.IsDBNull(4) ? null : r.GetString(4),
        r.GetString(5),
        r.IsDBNull(6) ? null : new AdminPostMedia(r.GetString(6), r.GetString(7), r.IsDBNull(8) ? null : r.GetString(8)),
        r.GetInt32(9),
        r.GetInt32(10),
        r.GetInt32(11),
        r.GetFieldValue<DateTimeOffset>(12),
        r.IsDBNull(13) ? null : r.GetFieldValue<DateTimeOffset>(13),
        r.IsDBNull(14) ? null : r.GetString(14));
}
