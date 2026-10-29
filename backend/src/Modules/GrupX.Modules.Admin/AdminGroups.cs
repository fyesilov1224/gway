using GrupX.SharedKernel;
using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminGroupSummary(
    Guid Id,
    string Handle,
    string Name,
    string CategorySlug,
    string JoinPolicy,
    string Status,
    int MemberCount,
    string? LogoPath,
    Guid OwnerId,
    string? OwnerUsername,
    string? OwnerDisplayName,
    DateTimeOffset CreatedAt);

public sealed record AdminGroupTeamMember(Guid UserId, string? Username, string? DisplayName, string? AvatarPath, IReadOnlyList<string> Roles);

public sealed record AdminGroupPlan(string Slug, string Name, int MaxMembers);

/// <summary>An invite link as staff see it (docs/ARCHITECTURE.md §3b); the code itself is not shown.</summary>
public sealed record AdminInviteLink(
    Guid Id,
    string? CreatedByUsername,
    DateTimeOffset CreatedAt,
    DateTimeOffset ExpiresAt,
    int? MaxUses,
    int UseCount,
    DateTimeOffset? RevokedAt,
    bool Valid);

public sealed record AdminGroupDetail(
    AdminGroupSummary Group,
    AdminGroupPlan Plan,
    IReadOnlyList<AdminSubscription> Subscriptions,
    string About,
    string? SuspensionReason,
    DateTimeOffset? SuspendedAt,
    int PendingRequests,
    int PendingInvitations,
    IReadOnlyList<AdminGroupTeamMember> Team,
    IReadOnlyList<AdminAuditItem> History,
    int? Province = null,
    IReadOnlyList<AdminInviteLink>? InviteLinks = null);

public sealed record AdminGroupStats(int Total, int Active, int Suspended);

/// <summary>Read side of admin group management.</summary>
internal sealed class AdminGroups(NpgsqlDataSource db)
{
    public const int PageSize = 20;
    private const int HistoryLimit = 50;

    public static readonly string[] Statuses = ["active", "suspended"];

    private const string SummarySelect =
        """
        select g.id, g.handle, g.name, g.category_slug, g.join_policy, g.status, g.member_count, g.logo_path,
               g.owner_id, p.username, p.display_name, g.created_at
        from public.groups g
        left join public.profiles p on p.id = g.owner_id
        """;

    private const string SearchFilter =
        """
        where (@q is null or g.name ilike @q escape '\' or g.handle ilike @q escape '\')
          and (@status is null or g.status = @status)
        """;

    public async Task<AdminGroupStats> StatsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select count(*)::int,
                   (count(*) filter (where status = 'active'))::int,
                   (count(*) filter (where status = 'suspended'))::int
            from public.groups
            """);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        await reader.ReadAsync(ct);
        return new AdminGroupStats(reader.GetInt32(0), reader.GetInt32(1), reader.GetInt32(2));
    }

    /// <param name="status">One of <see cref="Statuses"/>, or null for all.</param>
    public async Task<PagedResult<AdminGroupSummary>> SearchAsync(string? query, string? status, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";

        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.groups g {SearchFilter}", conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            count.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminGroupSummary>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect}
            {SearchFilter}
            order by g.created_at desc, g.id
            limit {PageSize} offset @offset
            """, conn))
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct)) items.Add(ReadSummary(reader));
        }

        return new PagedResult<AdminGroupSummary>(items, total, page, PageSize);
    }

    public async Task<Result<AdminGroupDetail>> GetAsync(Guid groupId, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);

        AdminGroupSummary summary;
        string about;
        string? reason;
        DateTimeOffset? suspendedAt;
        int requests, invitations;
        AdminGroupPlan plan;
        int? province;
        await using (var cmd = new NpgsqlCommand(
            $"""
            {SummarySelect.Replace("g.created_at", "g.created_at, g.about, g.suspension_reason, g.suspended_at, "
                + "(select count(*)::int from public.group_join_requests r where r.group_id = g.id), "
                + "(select count(*)::int from public.group_invitations i where i.group_id = g.id), "
                + "(private.group_plan_limits(g.id)).slug, (private.group_plan_limits(g.id)).name, "
                + "(private.group_plan_limits(g.id)).max_members, g.province", StringComparison.Ordinal)}
            where g.id = @id
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", groupId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            if (!await reader.ReadAsync(ct)) return Error.NotFound("admin.group_not_found", "Grup bulunamadı.");
            summary = ReadSummary(reader);
            about = reader.GetString(12);
            reason = reader.IsDBNull(13) ? null : reader.GetString(13);
            suspendedAt = reader.IsDBNull(14) ? null : reader.GetFieldValue<DateTimeOffset>(14);
            requests = reader.GetInt32(15);
            invitations = reader.GetInt32(16);
            plan = new AdminGroupPlan(reader.GetString(17), reader.GetString(18), reader.GetInt32(19));
            province = reader.IsDBNull(20) ? null : reader.GetInt16(20);
        }

        // Owner first, then members holding assigned roles, highest rank first.
        var team = new List<AdminGroupTeamMember>();
        await using (var cmd = new NpgsqlCommand(
            """
            select x.user_id, p.username, p.display_name, p.avatar_path, array_agg(x.role order by gr.rank desc)
            from (
              select owner_id as user_id, 'owner' as role from public.groups where id = @id
              union all
              select user_id, role from public.group_member_roles where group_id = @id
            ) x
            join public.group_roles gr on gr.slug = x.role
            left join public.profiles p on p.id = x.user_id
            group by x.user_id, p.username, p.display_name, p.avatar_path
            order by max(gr.rank) desc, p.display_name
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", groupId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                team.Add(new AdminGroupTeamMember(
                    reader.GetGuid(0),
                    reader.IsDBNull(1) ? null : reader.GetString(1),
                    reader.IsDBNull(2) ? null : reader.GetString(2),
                    reader.IsDBNull(3) ? null : reader.GetString(3),
                    reader.GetFieldValue<string[]>(4)));
            }
        }

        var history = new List<AdminAuditItem>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select a.occurred_at, a.action, a.actor_kind, a.actor_id, coalesce(ap.display_name, au.email),
                   case when a.target_type = 'user' then tp.display_name end,
                   coalesce(a.data->>'role', a.data->>'reason', (select pl.name from public.plans pl where pl.slug = a.data->>'plan'))
            from public.audit_log a
            left join public.profiles ap on ap.id = a.actor_id
            left join auth.users au on au.id = a.actor_id
            left join public.profiles tp on a.target_type = 'user' and tp.id::text = a.target_id
            where a.group_id = @id
            order by a.occurred_at desc
            limit {HistoryLimit}
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", groupId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                history.Add(new AdminAuditItem(
                    reader.GetFieldValue<DateTimeOffset>(0), reader.GetString(1), reader.GetString(2),
                    reader.IsDBNull(3) ? null : reader.GetGuid(3),
                    reader.IsDBNull(4) ? null : reader.GetString(4),
                    reader.IsDBNull(5) ? null : reader.GetString(5),
                    reader.IsDBNull(6) ? null : reader.GetString(6)));
            }
        }

        var links = new List<AdminInviteLink>();
        await using (var cmd = new NpgsqlCommand(
            """
            select l.id, p.username, l.created_at, l.expires_at, l.max_uses, l.use_count, l.revoked_at, private.invite_link_valid(l)
            from public.group_invite_links l
            left join public.profiles p on p.id = l.created_by
            where l.group_id = @id
            order by l.created_at desc
            limit 50
            """, conn))
        {
            cmd.Parameters.AddWithValue("id", groupId);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                links.Add(new AdminInviteLink(
                    reader.GetGuid(0), reader.IsDBNull(1) ? null : reader.GetString(1), reader.GetFieldValue<DateTimeOffset>(2),
                    reader.GetFieldValue<DateTimeOffset>(3), reader.IsDBNull(4) ? null : reader.GetInt32(4), reader.GetInt32(5),
                    reader.IsDBNull(6) ? null : reader.GetFieldValue<DateTimeOffset>(6), reader.GetBoolean(7)));
            }
        }

        var subscriptions = await AdminBilling.GroupSubscriptionsAsync(conn, groupId, ct);
        return new AdminGroupDetail(
            summary, plan, subscriptions, about, reason, suspendedAt, requests, invitations, team, history, province, links);
    }

    private static AdminGroupSummary ReadSummary(NpgsqlDataReader r) => new(
        r.GetGuid(0),
        r.GetString(1),
        r.GetString(2),
        r.GetString(3),
        r.GetString(4),
        r.GetString(5),
        r.GetInt32(6),
        r.IsDBNull(7) ? null : r.GetString(7),
        r.GetGuid(8),
        r.IsDBNull(9) ? null : r.GetString(9),
        r.IsDBNull(10) ? null : r.GetString(10),
        r.GetFieldValue<DateTimeOffset>(11));
}
