using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminEvent(
    Guid Id,
    string Title,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    DateTimeOffset StartsAt,
    string Location,
    int? Capacity,
    int GoingCount,
    int WaitlistCount,
    DateTimeOffset? CanceledAt,
    string? CancelReason,
    DateTimeOffset CreatedAt,
    bool ApprovalRequired,
    int RequestedCount);

/// <summary>Read side of the admin events page (docs/ARCHITECTURE.md §3d).</summary>
internal sealed class AdminEvents(NpgsqlDataSource db)
{
    public const int PageSize = 20;

    public static readonly string[] Statuses = ["upcoming", "past", "canceled"];

    public async Task<PagedResult<AdminEvent>> SearchAsync(string? query, string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";
        var filter = status switch
        {
            "upcoming" => "and e.canceled_at is null and e.starts_at > now()",
            "past" => "and e.canceled_at is null and e.starts_at <= now()",
            "canceled" => "and e.canceled_at is not null",
            _ => "",
        };
        var where = $"where (@q is null or e.title ilike @q escape '\\' or g.name ilike @q escape '\\' or g.handle ilike @q escape '\\') {filter}";
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.events e join public.groups g on g.id = e.group_id {where}", conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminEvent>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select e.id, e.title, g.id, g.name, g.handle, e.starts_at, e.location, e.capacity, e.going_count, e.waitlist_count,
                   e.canceled_at, e.cancel_reason, e.created_at, e.approval_required,
                   (select count(*)::int from public.event_attendees a where a.event_id = e.id and a.status = 'requested')
            from public.events e join public.groups g on g.id = e.group_id
            {where}
            order by e.starts_at {(status == "upcoming" ? "asc" : "desc")}, e.id
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                items.Add(new AdminEvent(
                    r.GetGuid(0), r.GetString(1), r.GetGuid(2), r.GetString(3), r.GetString(4), r.GetFieldValue<DateTimeOffset>(5),
                    r.GetString(6), r.IsDBNull(7) ? null : r.GetInt32(7), r.GetInt32(8), r.GetInt32(9),
                    r.IsDBNull(10) ? null : r.GetFieldValue<DateTimeOffset>(10), r.IsDBNull(11) ? null : r.GetString(11),
                    r.GetFieldValue<DateTimeOffset>(12), r.GetBoolean(13), r.GetInt32(14)));
            }
        }
        return new PagedResult<AdminEvent>(items, total, page, PageSize);
    }
}
