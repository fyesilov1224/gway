using GrupX.Modules.Groups.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Database;
using Npgsql;

namespace GrupX.Modules.Groups;

internal sealed record GroupRow(Guid Id, string Handle, Guid OwnerId, string JoinPolicy, string Status, int MemberCount);

/// <summary>A user's standing in a group: roles (owner, member, assigned) and the highest rank.</summary>
internal sealed record MemberStanding(IReadOnlyList<string> Roles, int Rank)
{
    public bool IsMember => Roles.Contains(GroupRoles.Member);

    public bool IsOwner => Roles.Contains(GroupRoles.Owner);
}

internal static class GroupErrors
{
    public static readonly Error NotFound = Error.NotFound("group.not_found", "Grup bulunamadı.");
    public static readonly Error Forbidden = Error.Forbidden("group.forbidden", "Bu işlem için yetkin yok.");
    public static readonly Error Suspended = Error.RuleViolation("group.suspended", "Bu grup askıya alındığı için bu işlem yapılamaz.");
    public static readonly Error AccountInactive = Error.RuleViolation("group.account_inactive", "Hesabın aktif olmadığı için bu işlem yapılamaz.");
    public static readonly Error RankViolation = Error.RuleViolation(
        "group.rank_violation", "Kendinle eşit ya da senden yüksek rütbeli birine bu işlemi uygulayamazsın.");
    public static readonly Error Banned = Error.RuleViolation(
        "group.banned", "Bu gruptan uzaklaştırıldığın için şu anda katılamazsın.");
    public static readonly Error MemberLimitReached = Error.RuleViolation(
        "group.member_limit_reached", "Grup, paketinin üye limitine ulaştı. Yeni üye alınabilmesi için grup sahibinin paketini yükseltmesi gerekiyor.");
}

/// <summary>Transactions and permission checks shared by the group services.</summary>
internal sealed class GroupAccess(NpgsqlDataSource db)
{
    /// <summary>
    /// Runs <paramref name="work"/> in a transaction that names <paramref name="actorId"/> to the database
    /// triggers. Commits only on success. A trigger rejection (a rule the C# checks missed, e.g. a race)
    /// becomes a rule violation instead of a server error.
    /// </summary>
    public async Task<Result<T>> RunAsync<T>(
        Guid actorId, Func<NpgsqlConnection, NpgsqlTransaction, Task<Result<T>>> work, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        await ActingUser.SetAsync(conn, tx, actorId, ct);
        try
        {
            var result = await work(conn, tx);
            if (result.IsSuccess) await tx.CommitAsync(ct);
            return result;
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.RaiseException)
        {
            return ex.MessageText switch
            {
                "member_limit_reached" => GroupErrors.MemberLimitReached,
                "banned" => GroupErrors.Banned,
                _ => Error.RuleViolation($"group.{ex.MessageText}", "Bu işlem grup kurallarına uygun değil."),
            };
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UniqueViolation)
        {
            return Error.Conflict("group.conflict", "Bu işlem başka bir değişiklikle çakıştı. Sayfayı yenileyip tekrar dene.");
        }
    }

    /// <summary><see cref="RunAsync{T}"/> for work without a result value.</summary>
    public async Task<Result> RunActionAsync(
        Guid actorId, Func<NpgsqlConnection, NpgsqlTransaction, Task<Result>> work, CancellationToken ct)
    {
        var result = await RunAsync(actorId, async (conn, tx) =>
        {
            var inner = await work(conn, tx);
            return inner.IsSuccess ? Result<bool>.Success(true) : Result<bool>.Failure(inner.Error);
        }, ct);
        return result.IsSuccess ? Result.Success() : Result.Failure(result.Error);
    }

    /// <summary>Locks the group row for the rest of the transaction.</summary>
    public static async Task<GroupRow?> LockGroupAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id, handle, owner_id, join_policy, status, member_count from public.groups where id = @id for update", conn, tx);
        cmd.Parameters.AddWithValue("id", groupId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        return await reader.ReadAsync(ct)
            ? new GroupRow(reader.GetGuid(0), reader.GetString(1), reader.GetGuid(2), reader.GetString(3), reader.GetString(4), reader.GetInt32(5))
            : null;
    }

    public static async Task<MemberStanding> StandingAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select x.role, r.rank
            from (
              select 'owner' as role from public.groups where id = @group and owner_id = @user
              union all
              select 'member' from public.group_members where group_id = @group and user_id = @user
              union all
              select role from public.group_member_roles where group_id = @group and user_id = @user
            ) x
            join public.group_roles r on r.slug = x.role
            """, conn, tx);
        cmd.Parameters.AddWithValue("group", groupId);
        cmd.Parameters.AddWithValue("user", userId);
        var roles = new List<string>();
        var rank = 0;
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            roles.Add(reader.GetString(0));
            rank = Math.Max(rank, reader.GetInt32(1));
        }
        return new MemberStanding(roles, rank);
    }

    /// <summary>Permissions granted by <paramref name="standing"/> according to the catalog. The owner holds all.</summary>
    public static async Task<IReadOnlySet<string>> PermissionsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, MemberStanding standing, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            standing.IsOwner
                ? "select slug from public.group_permissions"
                : "select distinct permission from public.group_role_permissions where role = any(@roles)",
            conn, tx);
        cmd.Parameters.AddWithValue("roles", standing.Roles.ToArray());
        var permissions = new HashSet<string>(StringComparer.Ordinal);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) permissions.Add(reader.GetString(0));
        return permissions;
    }

    public static async Task<bool> HasProfileAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select 1 from public.profiles where id = @id", conn, tx);
        cmd.Parameters.AddWithValue("id", userId);
        return await cmd.ExecuteScalarAsync(ct) is not null;
    }

    public static async Task<bool> IsAccountActiveAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select private.is_account_active(@id)", conn, tx);
        cmd.Parameters.AddWithValue("id", userId);
        return (bool)(await cmd.ExecuteScalarAsync(ct))!;
    }

    /// <summary>
    /// Locks the active group and checks that the actor (active account, member) holds
    /// <paramref name="permission"/>. Returns the group and the actor's standing.
    /// </summary>
    public static async Task<Result<(GroupRow Group, MemberStanding Actor)>> AuthorizeAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid actorId, string permission, CancellationToken ct)
    {
        var group = await LockGroupAsync(conn, tx, groupId, ct);
        if (group is null) return GroupErrors.NotFound;
        if (group.Status != GroupStatuses.Active) return GroupErrors.Suspended;
        if (!await IsAccountActiveAsync(conn, tx, actorId, ct)) return GroupErrors.AccountInactive;

        var actor = await StandingAsync(conn, tx, groupId, actorId, ct);
        if (!actor.IsMember || !(await PermissionsAsync(conn, tx, actor, ct)).Contains(permission)) return GroupErrors.Forbidden;
        return (group, actor);
    }

    /// <summary>Invitations the group sent in the last 24 hours, revoked ones included (§3b, Gruplar arası denge).</summary>
    public static async Task<int> InvitationsSentTodayAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select private.group_invitations_sent_today(@group)", conn, tx);
        cmd.Parameters.AddWithValue("group", groupId);
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    /// <summary>A running ban (docs/ARCHITECTURE.md §3e); the triggers check it again.</summary>
    public static async Task<bool> IsBannedAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, Guid userId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select private.is_group_banned(@group, @user)", conn, tx);
        cmd.Parameters.AddWithValue("group", groupId);
        cmd.Parameters.AddWithValue("user", userId);
        return (bool)(await cmd.ExecuteScalarAsync(ct))!;
    }

    public static async Task<bool> ExistsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string sql, Guid groupId, Guid userId, CancellationToken ct)
    {
#pragma warning disable CA2100 // sql is a compile-time constant of this module
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("group", groupId);
        cmd.Parameters.AddWithValue("user", userId);
        return await cmd.ExecuteScalarAsync(ct) is not null;
    }

    /// <summary>Executes a statement with <c>@group</c> and <c>@user</c> parameters; returns affected rows.</summary>
    public static async Task<int> ExecuteAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string sql, Guid groupId, Guid userId, CancellationToken ct)
    {
#pragma warning disable CA2100 // sql is a compile-time constant of this module
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("group", groupId);
        cmd.Parameters.AddWithValue("user", userId);
        return await cmd.ExecuteNonQueryAsync(ct);
    }

    public const string IsMemberSql = "select 1 from public.group_members where group_id = @group and user_id = @user";
    public const string HasRequestSql = "select 1 from public.group_join_requests where group_id = @group and user_id = @user";
    public const string HasInvitationSql = "select 1 from public.group_invitations where group_id = @group and user_id = @user";
}
