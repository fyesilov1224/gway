using GrupX.SharedKernel;
using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminSupportStats(int OpenProblems, int OpenRequests, int OpenSuggestions, int AwaitingReply);

public sealed record AdminTicketSummary(
    Guid Id,
    string Kind,
    string Subject,
    string Status,
    Guid UserId,
    string? Username,
    string? DisplayName,
    Guid? GroupId,
    string? GroupName,
    DateTimeOffset CreatedAt,
    DateTimeOffset LastMessageAt,
    string LastMessageBy,
    int MessageCount);

public sealed record AdminTicketMessage(
    long Id,
    string AuthorKind,
    string? AuthorName,
    string Body,
    IReadOnlyList<string> Attachments,
    DateTimeOffset CreatedAt);

public sealed record AdminTicketDetail(
    AdminTicketSummary Ticket,
    string? Email,
    string? GroupHandle,
    IReadOnlyList<AdminTicketMessage> Messages);

/// <summary>Read side of the admin support pages (docs/ARCHITECTURE.md §7b).</summary>
internal sealed class AdminSupport(NpgsqlDataSource db)
{
    public const int PageSize = 20;

    private const string Active = "t.status in ('open', 'in_progress')";

    private const string SummarySelect =
        """
        select t.id, t.kind, t.subject, t.status, t.user_id, p.username, p.display_name, t.group_id, g.name,
               t.created_at, t.last_message_at, t.last_message_by,
               (select count(*)::int from public.support_messages m where m.ticket_id = t.id)
        from public.support_tickets t
        left join public.profiles p on p.id = t.user_id
        left join public.groups g on g.id = t.group_id
        """;

    private const string Filter =
        """
        where (@q is null or t.subject ilike @q escape '\' or p.username ilike @q escape '\' or g.name ilike @q escape '\')
          and (@kind is null or t.kind = @kind)
          and (@status is null or t.status = @status)
        """;

    public async Task<AdminSupportStats> StatsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            $"""
            select (count(*) filter (where t.kind = 'problem' and {Active}))::int,
                   (count(*) filter (where t.kind = 'request' and {Active}))::int,
                   (count(*) filter (where t.kind = 'suggestion' and {Active}))::int,
                   (count(*) filter (where t.last_message_by = 'user' and {Active}))::int
            from public.support_tickets t
            """);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new AdminSupportStats(r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3));
    }

    /// <summary>Tickets waiting for the team first, then the most recently active.</summary>
    public async Task<PagedResult<AdminTicketSummary>> SearchAsync(string? query, string? kind, string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";
        await using var conn = await db.OpenConnectionAsync(ct);

        void Bind(NpgsqlCommand cmd)
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("kind", kind));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
        }

        int total;
        await using (var count = new NpgsqlCommand(
            $"""
            select count(*)::int from public.support_tickets t
            left join public.profiles p on p.id = t.user_id
            left join public.groups g on g.id = t.group_id
            {Filter}
            """, conn))
        {
            Bind(count);
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminTicketSummary>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect}
            {Filter}
            order by (t.last_message_by = 'user' and {Active}) desc, t.last_message_at desc, t.id
            limit {PageSize} offset @offset
            """, conn))
        {
            Bind(cmd);
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) items.Add(ReadSummary(r));
        }
        return new PagedResult<AdminTicketSummary>(items, total, page, PageSize);
    }

    public async Task<Result<AdminTicketDetail>> GetAsync(Guid id, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);

        AdminTicketSummary ticket;
        string? email, handle;
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect.Replace("(select count(*)::int", "u.email, g.handle, (select count(*)::int", StringComparison.Ordinal)}
            left join auth.users u on u.id = t.user_id
            where t.id = @id
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return Error.NotFound("admin.ticket_not_found", "Mesaj bulunamadı.");
            email = r.IsDBNull(12) ? null : r.GetString(12);
            handle = r.IsDBNull(13) ? null : r.GetString(13);
            ticket = new AdminTicketSummary(
                r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetString(3), r.GetGuid(4),
                r.IsDBNull(5) ? null : r.GetString(5), r.IsDBNull(6) ? null : r.GetString(6),
                r.IsDBNull(7) ? null : r.GetGuid(7), r.IsDBNull(8) ? null : r.GetString(8),
                r.GetFieldValue<DateTimeOffset>(9), r.GetFieldValue<DateTimeOffset>(10), r.GetString(11), r.GetInt32(14));
        }

        var messages = new List<AdminTicketMessage>();
        await using (var cmd = new NpgsqlCommand(
            """
            select m.id, m.author_kind, coalesce(p.display_name, u.email), m.body, m.attachments, m.created_at
            from public.support_messages m
            left join public.profiles p on p.id = m.author_id
            left join auth.users u on u.id = m.author_id
            where m.ticket_id = @id
            order by m.created_at, m.id
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                messages.Add(new AdminTicketMessage(r.GetInt64(0), r.GetString(1), r.IsDBNull(2) ? null : r.GetString(2),
                    r.GetString(3), r.GetFieldValue<string[]>(4), r.GetFieldValue<DateTimeOffset>(5)));
            }
        }

        return new AdminTicketDetail(ticket, email, handle, messages);
    }

    private static AdminTicketSummary ReadSummary(NpgsqlDataReader r) => new(
        r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetString(3), r.GetGuid(4),
        r.IsDBNull(5) ? null : r.GetString(5), r.IsDBNull(6) ? null : r.GetString(6),
        r.IsDBNull(7) ? null : r.GetGuid(7), r.IsDBNull(8) ? null : r.GetString(8),
        r.GetFieldValue<DateTimeOffset>(9), r.GetFieldValue<DateTimeOffset>(10), r.GetString(11), r.GetInt32(12));
}
