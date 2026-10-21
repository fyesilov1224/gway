using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminGoal(
    Guid Id,
    string Title,
    string Kind,
    string? Metric,
    int? Target,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    DateTimeOffset? CanceledAt,
    int Completions);

/// <summary>Read side of the admin goals list (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).</summary>
internal sealed class AdminGoals(NpgsqlDataSource db)
{
    public const int PageSize = 20;

    public async Task<PagedResult<AdminGoal>> SearchAsync(string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var where = status switch
        {
            "running" => "where g.canceled_at is null and g.ends_at > now()",
            "ended" => "where g.canceled_at is null and g.ends_at <= now()",
            "canceled" => "where g.canceled_at is not null",
            _ => "",
        };
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
#pragma warning disable CA2100 // the filter is one of this method's constants
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.goals g {where}", conn))
        {
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminGoal>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select g.id, g.title, g.kind, g.metric, g.target, gr.id, gr.name, gr.handle, g.starts_at, g.ends_at, g.canceled_at,
                   (select count(*)::int from public.goal_completions c where c.goal_id = g.id)
            from public.goals g join public.groups gr on gr.id = g.group_id
            {where}
            order by g.ends_at desc, g.id
            limit {PageSize} offset @offset
            """, conn))
#pragma warning restore CA2100
        {
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                items.Add(new AdminGoal(
                    r.GetGuid(0), r.GetString(1), r.GetString(2), r.IsDBNull(3) ? null : r.GetString(3), r.IsDBNull(4) ? null : r.GetInt32(4),
                    r.GetGuid(5), r.GetString(6), r.GetString(7), r.GetFieldValue<DateTimeOffset>(8), r.GetFieldValue<DateTimeOffset>(9),
                    r.IsDBNull(10) ? null : r.GetFieldValue<DateTimeOffset>(10), r.GetInt32(11)));
            }
        }
        return new PagedResult<AdminGoal>(items, total, page, PageSize);
    }
}
