using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Admin;

public sealed record AdminUserSummary(
    Guid Id,
    string? Email,
    string? Username,
    string? DisplayName,
    string? AvatarPath,
    string Status,
    DateTimeOffset? SuspendedUntil,
    DateTimeOffset? DeletionScheduledFor,
    string? StaffRole,
    DateTimeOffset? CreatedAt,
    DateTimeOffset? LastSignInAt);

public sealed record AdminConsent(string Kind, int Version, DateTimeOffset AcceptedAt);

/// <param name="TargetName">Display name of the affected user, for group history.</param>
/// <param name="Detail">Role or reason recorded with the action, when there is one.</param>
public sealed record AdminAuditItem(
    DateTimeOffset OccurredAt,
    string Action,
    string ActorKind,
    Guid? ActorId,
    string? ActorName = null,
    string? TargetName = null,
    string? Detail = null);

public sealed record AdminUserDetail(
    AdminUserSummary User,
    string? Bio,
    string? SuspensionReason,
    IReadOnlyList<AdminConsent> Consents,
    IReadOnlyList<AdminAuditItem> History,
    AdminContributions Contributions,
    AdminTeammates Teammates);

/// <summary>What the person did in groups (docs/ARCHITECTURE.md §3d, Katkı ve rozetler).</summary>
/// <param name="ExploredProvinces">Provinces of the events attended (docs/ARCHITECTURE.md §3d, Keşif haritam).</param>
public sealed record AdminContributions(int Attended, int Organized, int Memories, int Reviews, int NoShows, int Welcomed = 0, int ExploredProvinces = 0, int Handshakes = 0);

/// <summary>Teammate activity, for spotting request spam (docs/ARCHITECTURE.md §3c, Ekip arkadaşı); the province is never shown.</summary>
public sealed record AdminTeammates(bool Looking, int Teammates, int RequestsSentToday, int RequestsPending);

public sealed record PagedResult<T>(IReadOnlyList<T> Items, int Total, int Page, int PageSize);

public sealed record AdminUserStats(int Total, int Active, int Suspended, int PendingDeletion);

/// <summary>Read side of admin user management. Joins auth.users for e-mail, which clients cannot read.</summary>
internal sealed class AdminUsers(NpgsqlDataSource db)
{
    public const int PageSize = 20;
    private const int HistoryLimit = 200;

    public static readonly string[] Statuses = ["active", "suspended", "pending_deletion"];

    /// <summary>Status as users experience it: an expired suspension counts as active.</summary>
    private const string EffectiveStatus =
        "case when s.status = 'suspended' and s.suspended_until <= now() then 'active' else coalesce(s.status, 'active') end";

    private const string Joins =
        """
        from auth.users u
        left join public.profiles p on p.id = u.id
        left join public.account_status s on s.user_id = u.id
        left join public.platform_staff ps on ps.user_id = u.id
        """;

    private const string SummarySelect =
        $"""
        select u.id, u.email, p.username, p.display_name, p.avatar_path,
               {EffectiveStatus}, s.suspended_until, s.deletion_scheduled_for,
               ps.role, u.created_at, u.last_sign_in_at
        {Joins}
        """;

    private const string SearchFilter =
        $"""
        where (@q is null
               or u.email ilike @q escape '\'
               or p.username ilike @q escape '\'
               or p.display_name ilike @q escape '\')
          and (@status is null or {EffectiveStatus} = @status)
        """;

    public async Task<AdminUserStats> StatsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            $"""
            select count(*)::int,
                   (count(*) filter (where {EffectiveStatus} = 'active'))::int,
                   (count(*) filter (where {EffectiveStatus} = 'suspended'))::int,
                   (count(*) filter (where {EffectiveStatus} = 'pending_deletion'))::int
            {Joins}
            """);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        await reader.ReadAsync(ct);
        return new AdminUserStats(reader.GetInt32(0), reader.GetInt32(1), reader.GetInt32(2), reader.GetInt32(3));
    }

    /// <param name="status">One of <see cref="Statuses"/>, or null for all.</param>
    public async Task<PagedResult<AdminUserSummary>> SearchAsync(string? query, string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{EscapeLike(query.Trim())}%";

        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand(
            $"""
            select count(*)::int
            {Joins}
            {SearchFilter}
            """, conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            count.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminUserSummary>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect}
            {SearchFilter}
            order by u.created_at desc nulls last, u.id
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct)) items.Add(ReadSummary(reader));
        }

        return new PagedResult<AdminUserSummary>(items, total, page, PageSize);
    }

    public async Task<Result<AdminUserDetail>> GetAsync(Guid userId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);

        AdminUserSummary summary;
        string? bio, reason;
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect.Replace("u.last_sign_in_at", "u.last_sign_in_at, p.bio, s.suspension_reason", StringComparison.Ordinal)}
            where u.id = @id
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", userId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            if (!await reader.ReadAsync(ct)) return Error.NotFound("admin.user_not_found", "Kullanıcı bulunamadı.");
            summary = ReadSummary(reader);
            bio = reader.IsDBNull(11) ? null : reader.GetString(11);
            reason = reader.IsDBNull(12) ? null : reader.GetString(12);
        }

        var consents = new List<AdminConsent>();
        await using (var cmd = new NpgsqlCommand(
            "select kind, version, accepted_at from public.consents where user_id = @id order by accepted_at desc", conn))
        {
            cmd.Parameters.AddWithValue("id", userId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                consents.Add(new AdminConsent(reader.GetString(0), reader.GetInt32(1), reader.GetFieldValue<DateTimeOffset>(2)));
        }

        var history = new List<AdminAuditItem>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select a.occurred_at, a.action, a.actor_kind, a.actor_id, coalesce(ap.display_name, au.email), g.name,
                   coalesce(a.data->>'role', a.data->>'reason', a.data->>'note', a.data->>'name', a.data->>'country', a.data->>'plan')
            from public.audit_log a
            left join public.profiles ap on ap.id = a.actor_id
            left join auth.users au on au.id = a.actor_id
            left join public.groups g on g.id = a.group_id
            where a.target_type = 'user' and a.target_id = @id
            order by a.occurred_at desc
            limit {HistoryLimit}
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", userId.ToString());
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                history.Add(new AdminAuditItem(
                    reader.GetFieldValue<DateTimeOffset>(0), reader.GetString(1), reader.GetString(2),
                    reader.IsDBNull(3) ? null : reader.GetGuid(3),
                    reader.IsDBNull(4) ? null : reader.GetString(4),
                    reader.IsDBNull(5) ? null : reader.GetString(5),
                    reader.IsDBNull(6) ? null : reader.GetString(6)));
        }

        AdminContributions contributions;
        await using (var cmd = new NpgsqlCommand(
            """
            select (c->>'attended')::int, (c->>'organized')::int, (c->>'memories')::int, (c->>'reviews')::int,
                   (select count(*)::int from public.event_attendees where user_id = @id and no_show_at is not null),
                   (c->>'welcomed')::int, private.explored_province_count(@id), (c->>'handshakes')::int
            from (select private.contribution_counts(@id, null) as c) x
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", userId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            await reader.ReadAsync(ct);
            contributions = new AdminContributions(
                reader.GetInt32(0), reader.GetInt32(1), reader.GetInt32(2), reader.GetInt32(3), reader.GetInt32(4), reader.GetInt32(5),
                reader.GetInt32(6), reader.GetInt32(7));
        }

        AdminTeammates teammates;
        await using (var cmd = new NpgsqlCommand(
            """
            select coalesce((select looking from public.teammate_preferences where user_id = @id), false),
                   (select count(*)::int from public.teammates where @id in (user_a, user_b)),
                   (select count(*)::int from public.teammate_requests where requester_id = @id and created_at > now() - interval '24 hours'),
                   (select count(*)::int from public.teammate_requests where requester_id = @id)
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", userId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            await reader.ReadAsync(ct);
            teammates = new AdminTeammates(reader.GetBoolean(0), reader.GetInt32(1), reader.GetInt32(2), reader.GetInt32(3));
        }
        return new AdminUserDetail(summary, bio, reason, consents, history, contributions, teammates);
    }

    internal static string EscapeLike(string value) =>
        value.Replace(@"\", @"\\", StringComparison.Ordinal)
             .Replace("%", @"\%", StringComparison.Ordinal)
             .Replace("_", @"\_", StringComparison.Ordinal);

    private static AdminUserSummary ReadSummary(NpgsqlDataReader r) => new(
        r.GetGuid(0),
        r.IsDBNull(1) ? null : r.GetString(1),
        r.IsDBNull(2) ? null : r.GetString(2),
        r.IsDBNull(3) ? null : r.GetString(3),
        r.IsDBNull(4) ? null : r.GetString(4),
        r.GetString(5),
        r.IsDBNull(6) ? null : r.GetFieldValue<DateTimeOffset>(6),
        r.IsDBNull(7) ? null : r.GetFieldValue<DateTimeOffset>(7),
        r.IsDBNull(8) ? null : r.GetString(8),
        r.IsDBNull(9) ? null : r.GetFieldValue<DateTimeOffset>(9),
        r.IsDBNull(10) ? null : r.GetFieldValue<DateTimeOffset>(10));
}
