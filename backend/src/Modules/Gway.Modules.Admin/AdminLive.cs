using Gway.Modules.Live.Contracts;
using Npgsql;

namespace Gway.Modules.Admin;

public sealed record AdminBroadcast(
    Guid Id,
    string Title,
    string Status,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    Guid? HostId,
    string? HostUsername,
    DateTimeOffset? ScheduledAt,
    DateTimeOffset? StartedAt,
    DateTimeOffset? EndedAt,
    string? EndReason,
    int? Participants,
    int Notified);

/// <summary>Read side of the admin live page (docs/ARCHITECTURE.md §8, Admin): live rooms, scheduled broadcasts and history.</summary>
internal sealed class AdminLive(NpgsqlDataSource db, ILiveAdministration live)
{
    public const int PageSize = 20;

    /// <summary><c>live</c> (the default), <c>scheduled</c> (soonest first) or <c>ended</c> (newest first).</summary>
    public async Task<PagedResult<AdminBroadcast>> SearchAsync(string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var (filter, order) = status switch
        {
            "scheduled" => ("b.status = 'scheduled'", "b.scheduled_at, b.id"),
            "ended" => ("b.status = 'ended'", "b.ended_at desc, b.id"),
            _ => ("b.status = 'live'", "b.started_at desc, b.id"),
        };
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.live_broadcasts b where {filter}", conn))
        {
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        // Notified: the announcement while scheduled, the start notice afterwards.
        var rows = new List<AdminBroadcast>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select b.id, b.title, b.status, g.id, g.name, g.handle, b.host_id, h.username, b.scheduled_at, b.started_at, b.ended_at, b.end_reason,
                   (select count(*)::int from public.notifications n
                    where n.live_id = b.id and n.type = case when b.status = 'scheduled' then 'live_scheduled' else 'live_started' end)
            from public.live_broadcasts b
            join public.groups g on g.id = b.group_id
            left join public.profiles h on h.id = b.host_id
            where {filter}
            order by {order}
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                rows.Add(new AdminBroadcast(
                    r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetGuid(3), r.GetString(4), r.GetString(5),
                    r.IsDBNull(6) ? null : r.GetGuid(6), r.IsDBNull(7) ? null : r.GetString(7),
                    r.IsDBNull(8) ? null : r.GetFieldValue<DateTimeOffset>(8),
                    r.IsDBNull(9) ? null : r.GetFieldValue<DateTimeOffset>(9), r.IsDBNull(10) ? null : r.GetFieldValue<DateTimeOffset>(10),
                    r.IsDBNull(11) ? null : r.GetString(11), null, r.GetInt32(12)));
            }
        }

        if (status is not ("scheduled" or "ended") && rows.Count > 0)
        {
            var counts = await live.ParticipantCountsAsync([.. rows.Select(b => b.Id)], ct);
            rows = [.. rows.Select(b => b with { Participants = counts.GetValueOrDefault(b.Id) })];
        }
        return new PagedResult<AdminBroadcast>(rows, total, page, PageSize);
    }
}
