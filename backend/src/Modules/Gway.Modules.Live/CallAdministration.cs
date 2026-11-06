using Gway.Modules.Live.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Live;

/// <summary>
/// The admin panel's Sesli görüşme tab (docs/ARCHITECTURE.md §8c, Admin): every request and permission with its group and
/// who decided, and the platform team's decisions beside the groups'. The trigger <c>call_permissions_guard</c> checks
/// the actor again (0088). Calls themselves are never listed: only the last 24 hours' totals.
/// </summary>
internal sealed partial class CallService : ICallAdministration
{
    public const int PageSize = 50;

    private static readonly string[] Statuses = ["requested", "active", "declined", "revoked"];

    /// <summary>The permission row with its group and decider. Whether the platform decided comes from the audit log
    /// (a staff member may also own a group); without a decider the permission closed by itself (left the group).</summary>
    private const string RowSelect =
        """
        select p.user_id, pr.username, pr.display_name, pr.avatar_path, p.status, p.note, p.requested_at, p.decided_at, p.reason,
               g.id, g.handle, g.name, g.status,
               p.decided_by, d.username, d.display_name,
               case when p.decided_at is null then null
                    when p.decided_by is null then 'system'
                    when last.actor_kind = 'staff' then 'platform'
                    when g.owner_id = p.decided_by then 'group_owner'
                    when g.id is null then 'platform'
                    else 'group_manager' end
        from public.call_permissions p
        join public.profiles pr on pr.id = p.user_id
        left join public.groups g on g.id = p.group_id
        left join public.profiles d on d.id = p.decided_by
        left join lateral (
          select a.actor_kind from public.audit_log a
          where a.target_type = 'user' and a.target_id = p.user_id::text and a.action like 'call\_permission.%'
            and a.actor_id = p.decided_by
          order by a.occurred_at desc
          limit 1
        ) last on true
        """;

    private static CallPermissionRow ReadRow(NpgsqlDataReader r) => new(
        r.GetGuid(0), r.GetString(1), r.GetString(2), r.IsDBNull(3) ? null : r.GetString(3), r.GetString(4),
        r.IsDBNull(5) ? null : r.GetString(5),
        r.IsDBNull(6) ? null : r.GetFieldValue<DateTimeOffset>(6),
        r.IsDBNull(7) ? null : r.GetFieldValue<DateTimeOffset>(7),
        r.IsDBNull(8) ? null : r.GetString(8),
        r.IsDBNull(9) ? null : new CallPermissionGroup(r.GetGuid(9), r.GetString(10), r.GetString(11), r.GetString(12)),
        r.IsDBNull(16) ? null : new CallPermissionDecider(
            r.IsDBNull(13) ? null : r.GetGuid(13), r.IsDBNull(14) ? null : r.GetString(14), r.IsDBNull(15) ? null : r.GetString(15),
            r.GetString(16)));

    private static string EscapeLike(string value) =>
        value.Replace("\\", "\\\\", StringComparison.Ordinal).Replace("%", "\\%", StringComparison.Ordinal).Replace("_", "\\_", StringComparison.Ordinal);

    public async Task<CallPermissionsPage> PermissionsAsync(string? status, string? query, int page, CancellationToken ct)
    {
        status = status == "all" || Statuses.Contains(status) ? status : "requested";
        page = Math.Max(1, page);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{EscapeLike(query.Trim().TrimStart('@'))}%";

        var items = new List<CallPermissionRow>();
        var total = 0;
        await using (var cmd = db.CreateCommand(
            $"""
            {RowSelect}
            where (@status = 'all' or p.status = @status)
              and (@q::text is null or pr.username ilike @q escape '\' or pr.display_name ilike @q escape '\' or g.name ilike @q escape '\')
            order by case when @status = 'requested' then p.requested_at end asc nulls last,
                     coalesce(p.decided_at, p.requested_at, p.updated_at) desc, p.user_id
            limit @size offset @offset
            """))
        {
            cmd.Parameters.AddWithValue("status", status!);
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.AddWithValue("size", PageSize);
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) items.Add(ReadRow(r));
        }
        await using (var count = db.CreateCommand(
            """
            select count(*)::int
            from public.call_permissions p
            join public.profiles pr on pr.id = p.user_id
            left join public.groups g on g.id = p.group_id
            where (@status = 'all' or p.status = @status)
              and (@q::text is null or pr.username ilike @q escape '\' or pr.display_name ilike @q escape '\' or g.name ilike @q escape '\')
            """))
        {
            count.Parameters.AddWithValue("status", status!);
            count.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }
        return new CallPermissionsPage(items, total, page, PageSize, await SummaryAsync(ct));
    }

    private async Task<CallPermissionSummary> SummaryAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select count(*) filter (where status = 'requested')::int,
                   count(*) filter (where status = 'active')::int,
                   count(*) filter (where status = 'declined')::int,
                   count(*) filter (where status = 'revoked')::int,
                   min(requested_at) filter (where status = 'requested'),
                   (select count(*)::int from public.calls where created_at > now() - interval '24 hours'),
                   (select coalesce(sum(extract(epoch from (coalesce(ended_at, now()) - answered_at))), 0)::int / 60
                    from public.calls where created_at > now() - interval '24 hours' and answered_at is not null)
            from public.call_permissions
            """);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        return new CallPermissionSummary(
            r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3),
            r.IsDBNull(4) ? null : r.GetFieldValue<DateTimeOffset>(4), r.GetInt32(5), r.GetInt32(6));
    }

    public async Task<Result<CallUserDetail>> UserAsync(Guid userId, CancellationToken ct)
    {
        string? username = null, displayName = null;
        await using (var person = db.CreateCommand("select username, display_name from public.profiles where id = @u"))
        {
            person.Parameters.AddWithValue("u", userId);
            await using var r = await person.ExecuteReaderAsync(ct);
            if (await r.ReadAsync(ct)) (username, displayName) = (r.GetString(0), r.GetString(1));
        }
        if (username is null) return UserNotFound;

        CallPermissionRow? permission = null;
        await using (var cmd = db.CreateCommand($"{RowSelect} where p.user_id = @u"))
        {
            cmd.Parameters.AddWithValue("u", userId);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (await r.ReadAsync(ct)) permission = ReadRow(r);
        }

        var history = new List<CallPermissionEvent>();
        await using (var cmd = db.CreateCommand(
            """
            select a.occurred_at, a.action, a.actor_kind, ap.username, ap.display_name, g.name, a.data->>'reason'
            from public.audit_log a
            left join public.profiles ap on ap.id = a.actor_id
            left join public.groups g on g.id = a.group_id
            where a.target_type = 'user' and a.target_id = @u and a.action like 'call\_permission.%'
            order by a.occurred_at desc
            limit 50
            """))
        {
            cmd.Parameters.AddWithValue("u", userId.ToString());
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                history.Add(new CallPermissionEvent(
                    r.GetFieldValue<DateTimeOffset>(0), r.GetString(1), r.GetString(2),
                    r.IsDBNull(3) ? null : r.GetString(3), r.IsDBNull(4) ? null : r.GetString(4),
                    r.IsDBNull(5) ? null : r.GetString(5), r.IsDBNull(6) ? null : r.GetString(6)));
            }
        }
        return new CallUserDetail(userId, username, displayName!, permission, history);
    }

    private static readonly Error UserNotFound = Error.NotFound("call.user_not_found", "Kullanıcı bulunamadı.");

    public async Task<Result> SetPermissionAsync(Guid actorId, Guid userId, bool active, string? reason, CancellationToken ct)
    {
        reason = reason?.Trim();
        if (!active && reason is not { Length: >= 3 and <= 500 })
            return Error.Validation("call.invalid_reason", "Gerekçe 3–500 karakter olmalı.");
        if (actorId == userId) return Error.Forbidden("call.self", "Kendi sesli görüşme yetkine karar veremezsin.");

        var result = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            if (await ActingTransaction.ScalarAsync(conn, tx, "select 1 from public.profiles where id = @u", ct, ("u", userId)) is null)
                return UserNotFound;

            string? current = null;
            Guid? group = null;
            await using (var cmd = new NpgsqlCommand(
                "select status, group_id from public.call_permissions where user_id = @u for update", conn, tx))
            {
                cmd.Parameters.AddWithValue("u", userId);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (await r.ReadAsync(ct)) (current, group) = (r.GetString(0), r.IsDBNull(1) ? null : r.GetGuid(1));
            }

            string action;
            if (active)
            {
                if (current == "active") return Error.Conflict("call.already_open", "Bu kişinin sesli görüşme yetkisi zaten açık.");
                // The platform's permission rests on no group: leaving one does not close it.
                await ActingTransaction.ExecuteAsync(conn, tx,
                    """
                    insert into public.call_permissions (user_id, status, updated_at)
                    values (@u, 'active', now())
                    on conflict (user_id) do update
                      set status = 'active', group_id = null, reason = null, updated_at = now()
                    """, ct, ("u", userId));
                action = "call_permission.granted";
            }
            else
            {
                var next = current switch
                {
                    "requested" => "declined",
                    "active" => "revoked",
                    _ => null,
                };
                if (next is null)
                    return Error.Conflict("call.not_open", "Bu kişinin bekleyen talebi ya da açık sesli görüşme yetkisi yok.");
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "update public.call_permissions set status = @status, reason = @reason, updated_at = now() where user_id = @u",
                    ct, ("u", userId), ("status", next), ("reason", reason));
                action = next == "declined" ? "call_permission.declined" : "call_permission.revoked";
            }

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, action, "user", userId.ToString(),
                new { reason = active ? null : reason, from = current, by = "platform" }, group), ct);
            return Result.Success();
        }, RuleError, ct);

        // A closed permission ends the person's call at once.
        if (result.IsSuccess && !active) await SuperviseAsync(ct);
        return result;
    }

    public async Task<Result<Guid>> GrantByUsernameAsync(Guid actorId, string username, CancellationToken ct)
    {
        var name = username?.Trim().TrimStart('@').ToLowerInvariant();
        if (string.IsNullOrEmpty(name)) return Error.Validation("call.invalid_username", "Kullanıcı adını yaz.");
        await using var cmd = db.CreateCommand("select id from public.profiles where lower(username) = @n");
        cmd.Parameters.AddWithValue("n", name);
        if (await cmd.ExecuteScalarAsync(ct) is not Guid userId)
            return Error.NotFound("call.user_not_found", "Bu kullanıcı adıyla kimse yok.");
        var granted = await SetPermissionAsync(actorId, userId, true, null, ct);
        return granted.IsSuccess ? userId : granted.Error!;
    }
}
