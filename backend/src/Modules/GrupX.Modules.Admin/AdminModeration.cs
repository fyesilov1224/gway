using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminReport(
    Guid Id,
    string TargetType,
    string TargetId,
    Guid? PostId,
    Guid? GroupId,
    string? GroupName,
    string? GroupHandle,
    Guid? ReporterId,
    string? ReporterUsername,
    Guid? SubjectId,
    string? SubjectUsername,
    string Reason,
    string? Note,
    string Excerpt,
    string Status,
    int OpenCount,
    DateTimeOffset CreatedAt,
    DateTimeOffset? ReviewedAt);

public sealed record AdminAppeal(
    Guid Id,
    Guid UserId,
    string? Username,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    string SanctionType,
    DateTimeOffset? SanctionEndsAt,
    string CaseReason,
    string Body,
    string Status,
    string? DecisionNote,
    DateTimeOffset CreatedAt,
    DateTimeOffset? DecidedAt);

/// <summary>Read side of the admin reports and appeals pages (docs/ARCHITECTURE.md §3e, Admin).</summary>
internal sealed class AdminModeration(NpgsqlDataSource db)
{
    public const int PageSize = 20;

    public async Task<PagedResult<AdminReport>> ReportsAsync(string? scope, string? status, string? type, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var filter = scope switch
        {
            "platform" => " and r.group_id is null",
            "group" => " and r.group_id is not null",
            _ => "",
        };
        var where = $"where (@status is null or r.status = @status) and (@type is null or r.target_type = @type){filter}";
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.reports r {where}", conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            count.Parameters.Add(new NpgsqlParameter<string?>("type", type));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminReport>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select r.id, r.target_type, r.target_id,
                   case r.target_type when 'post' then r.target_id::uuid
                                      when 'comment' then (select c.post_id from public.comments c where c.id::text = r.target_id) end,
                   g.id, g.name, g.handle, r.reporter_id, rp.username, r.subject_id, sp.username,
                   r.reason, r.note, r.excerpt, r.status,
                   (select count(*)::int from public.reports o
                    where o.status = 'open' and o.target_type = r.target_type and o.target_id = r.target_id
                      and o.group_id is not distinct from r.group_id),
                   r.created_at, r.reviewed_at
            from public.reports r
            left join public.groups g on g.id = r.group_id
            left join public.profiles rp on rp.id = r.reporter_id
            left join public.profiles sp on sp.id = r.subject_id
            {where}
            order by r.created_at desc, r.id
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("type", type));
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                items.Add(new AdminReport(
                    r.GetGuid(0), r.GetString(1), r.GetString(2), r.IsDBNull(3) ? null : r.GetGuid(3),
                    r.IsDBNull(4) ? null : r.GetGuid(4), r.IsDBNull(5) ? null : r.GetString(5), r.IsDBNull(6) ? null : r.GetString(6),
                    r.IsDBNull(7) ? null : r.GetGuid(7), r.IsDBNull(8) ? null : r.GetString(8),
                    r.IsDBNull(9) ? null : r.GetGuid(9), r.IsDBNull(10) ? null : r.GetString(10),
                    r.GetString(11), r.IsDBNull(12) ? null : r.GetString(12), r.GetString(13), r.GetString(14), r.GetInt32(15),
                    r.GetFieldValue<DateTimeOffset>(16), r.IsDBNull(17) ? null : r.GetFieldValue<DateTimeOffset>(17)));
            }
        }
        return new PagedResult<AdminReport>(items, total, page, PageSize);
    }

    /// <summary>Appeals the platform team decides (the owner took part in the case).</summary>
    public async Task<PagedResult<AdminAppeal>> AppealsAsync(string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        const string Where = "where a.handler = 'platform' and (@status is null or a.status = @status)";
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.sanction_appeals a {Where}", conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminAppeal>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select a.id, s.user_id, p.username, g.id, g.name, g.handle, s.type, s.ends_at, c.reason, a.body, a.status, a.decision_note,
                   a.created_at, a.decided_at
            from public.sanction_appeals a
            join public.sanctions s on s.id = a.sanction_id
            join public.moderation_cases c on c.id = s.case_id
            join public.groups g on g.id = s.group_id
            left join public.profiles p on p.id = s.user_id
            {Where}
            order by a.created_at desc, a.id
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                items.Add(new AdminAppeal(
                    r.GetGuid(0), r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2), r.GetGuid(3), r.GetString(4), r.GetString(5),
                    r.GetString(6), r.IsDBNull(7) ? null : r.GetFieldValue<DateTimeOffset>(7), r.GetString(8), r.GetString(9),
                    r.GetString(10), r.IsDBNull(11) ? null : r.GetString(11), r.GetFieldValue<DateTimeOffset>(12),
                    r.IsDBNull(13) ? null : r.GetFieldValue<DateTimeOffset>(13)));
            }
        }
        return new PagedResult<AdminAppeal>(items, total, page, PageSize);
    }
}
