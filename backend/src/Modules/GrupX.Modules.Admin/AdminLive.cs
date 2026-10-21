using GrupX.Modules.Live.Contracts;
using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminBroadcast(
    Guid Id,
    string Title,
    string Status,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    Guid? HostId,
    string? HostUsername,
    DateTimeOffset? StartedAt,
    DateTimeOffset? EndedAt,
    string? EndReason,
    int? Participants);

/// <summary>Read side of the admin live page (docs/ARCHITECTURE.md §8, Admin): live rooms first, then history.</summary>
internal sealed class AdminLive(NpgsqlDataSource db, ILiveAdministration live)
{
    public const int PageSize = 20;

    public async Task<PagedResult<AdminBroadcast>> SearchAsync(bool liveOnly, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var filter = liveOnly ? "b.status = 'live'" : "b.status = 'ended'";
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.live_broadcasts b where {filter}", conn))
        {
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var rows = new List<AdminBroadcast>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select b.id, b.title, b.status, g.id, g.name, g.handle, b.host_id, h.username, b.started_at, b.ended_at, b.end_reason
            from public.live_broadcasts b
            join public.groups g on g.id = b.group_id
            left join public.profiles h on h.id = b.host_id
            where {filter}
            order by coalesce(b.ended_at, b.started_at) desc, b.id
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
                    r.IsDBNull(8) ? null : r.GetFieldValue<DateTimeOffset>(8), r.IsDBNull(9) ? null : r.GetFieldValue<DateTimeOffset>(9),
                    r.IsDBNull(10) ? null : r.GetString(10), null));
            }
        }

        if (liveOnly && rows.Count > 0)
        {
            var counts = await live.ParticipantCountsAsync([.. rows.Select(b => b.Id)], ct);
            rows = [.. rows.Select(b => b with { Participants = counts.GetValueOrDefault(b.Id) })];
        }
        return new PagedResult<AdminBroadcast>(rows, total, page, PageSize);
    }
}
