using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Groups.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using Npgsql;

namespace GrupX.Modules.Groups;

public sealed record JoinResponse(string Status)
{
    public const string Member = "member";
    public const string Requested = "requested";
}

public sealed record InviteRequest(string Username);

/// <summary>Joining, leaving, join requests, invitations and role assignment (docs/ARCHITECTURE.md §3b).</summary>
internal sealed class MembershipService(GroupAccess access, IGroupPlanLimits planLimits) : IGroupMembership
{
    private static readonly Error NoRequest = Error.NotFound("group.no_request", "Bekleyen bir katılım isteği bulunamadı.");
    private static readonly Error NoInvitation = Error.NotFound("group.no_invitation", "Bekleyen bir davet bulunamadı.");

    private const string DeleteRequestSql = "delete from public.group_join_requests where group_id = @group and user_id = @user";
    private const string DeleteInvitationSql = "delete from public.group_invitations where group_id = @group and user_id = @user";
    private const string InsertMemberSql = "insert into public.group_members (group_id, user_id) values (@group, @user)";

    public Task<Result<JoinResponse>> JoinAsync(Guid actorId, Guid groupId, CancellationToken ct) =>
        access.RunAsync<JoinResponse>(actorId, async (conn, tx) =>
        {
            var group = await GroupAccess.LockGroupAsync(conn, tx, groupId, ct);
            if (group is null) return GroupErrors.NotFound;
            if (group.Status != GroupStatuses.Active) return GroupErrors.Suspended;
            if (!await GroupAccess.IsAccountActiveAsync(conn, tx, actorId, ct)) return GroupErrors.AccountInactive;
            if (!await GroupAccess.HasProfileAsync(conn, tx, actorId, ct))
                return Error.RuleViolation("group.profile_required", "Gruba katılmak için önce profilini tamamlamalısın.");
            if (await GroupAccess.ExistsAsync(conn, tx, GroupAccess.IsMemberSql, groupId, actorId, ct))
                return Error.Conflict("group.already_member", "Zaten bu grubun üyesisin.");
            if (await GroupAccess.IsBannedAsync(conn, tx, groupId, actorId, ct)) return GroupErrors.Banned;

            var invited = await GroupAccess.ExistsAsync(conn, tx, GroupAccess.HasInvitationSql, groupId, actorId, ct);
            if (group.JoinPolicy == JoinPolicies.Open || invited)
            {
                if (await IsFullAsync(conn, tx, group, ct)) return GroupErrors.MemberLimitReached;
                await GroupAccess.ExecuteAsync(conn, tx, InsertMemberSql, groupId, actorId, ct);
                await GroupAccess.ExecuteAsync(conn, tx, DeleteRequestSql, groupId, actorId, ct);
                await GroupAccess.ExecuteAsync(conn, tx, DeleteInvitationSql, groupId, actorId, ct);
                return new JoinResponse(JoinResponse.Member);
            }
            if (group.JoinPolicy == JoinPolicies.Invite)
                return Error.RuleViolation("group.invitation_required", "Bu gruba yalnızca davetle katılabilirsin.");
            if (await GroupAccess.ExistsAsync(conn, tx, GroupAccess.HasRequestSql, groupId, actorId, ct))
                return Error.Conflict("group.request_pending", "Katılım isteğin zaten gönderildi.");

            await GroupAccess.ExecuteAsync(conn, tx,
                "insert into public.group_join_requests (group_id, user_id) values (@group, @user)", groupId, actorId, ct);
            return new JoinResponse(JoinResponse.Requested);
        }, ct);

    /// <summary>The plan's member limit (docs/ARCHITECTURE.md §7); a full group takes nobody new.</summary>
    private async Task<bool> IsFullAsync(NpgsqlConnection conn, NpgsqlTransaction tx, GroupRow group, CancellationToken ct) =>
        group.MemberCount >= (await planLimits.GetAsync(conn, tx, group.Id, ct)).MaxMembers;

    public Task<Result> CancelRequestAsync(Guid actorId, Guid groupId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
            await GroupAccess.ExecuteAsync(conn, tx, DeleteRequestSql, groupId, actorId, ct) > 0 ? Result.Success() : NoRequest, ct);

    public Task<Result> DeclineInvitationAsync(Guid actorId, Guid groupId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
            await GroupAccess.ExecuteAsync(conn, tx, DeleteInvitationSql, groupId, actorId, ct) > 0 ? Result.Success() : NoInvitation, ct);

    /// <summary>Leaving works in suspended groups too; the owner must transfer ownership first.</summary>
    public Task<Result> LeaveAsync(Guid actorId, Guid groupId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var group = await GroupAccess.LockGroupAsync(conn, tx, groupId, ct);
            if (group is null) return GroupErrors.NotFound;
            if (group.OwnerId == actorId)
                return Error.RuleViolation("group.owner_cannot_leave", "Grup sahibi gruptan ayrılamaz. Önce sahipliği bir üyeye devretmelisin.");
            if (await GroupAccess.ExecuteAsync(conn, tx,
                    "delete from public.group_members where group_id = @group and user_id = @user", groupId, actorId, ct) == 0)
                return Error.NotFound("group.not_member", "Bu grubun üyesi değilsin.");
            return Result.Success();
        }, ct);

    public Task<Result> ApproveRequestAsync(Guid actorId, Guid groupId, Guid userId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.ApproveMembers, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (!await GroupAccess.ExistsAsync(conn, tx, GroupAccess.HasRequestSql, groupId, userId, ct)) return NoRequest;
            if (!await GroupAccess.IsAccountActiveAsync(conn, tx, userId, ct))
                return Error.RuleViolation("group.member_inactive", "Bu kullanıcının hesabı aktif olmadığı için isteği onaylanamaz.");
            if (await IsFullAsync(conn, tx, auth.Value.Group, ct)) return GroupErrors.MemberLimitReached;

            await GroupAccess.ExecuteAsync(conn, tx, InsertMemberSql, groupId, userId, ct);
            await GroupAccess.ExecuteAsync(conn, tx, DeleteRequestSql, groupId, userId, ct);
            await GroupAccess.ExecuteAsync(conn, tx, DeleteInvitationSql, groupId, userId, ct);
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.join_approved", "user", userId.ToString(), null, groupId), ct);
            return Result.Success();
        }, ct);

    public Task<Result> RejectRequestAsync(Guid actorId, Guid groupId, Guid userId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.ApproveMembers, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (await GroupAccess.ExecuteAsync(conn, tx, DeleteRequestSql, groupId, userId, ct) == 0) return NoRequest;

            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.join_rejected", "user", userId.ToString(), null, groupId), ct);
            return Result.Success();
        }, ct);

    public Task<Result> InviteAsync(Guid actorId, Guid groupId, string? username, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.InviteMembers, ct);
            if (!auth.IsSuccess) return auth.Error;

            // Hidden (inactive) accounts are reported as not found.
            var userId = await FindActiveUserAsync(conn, tx, username?.Trim().TrimStart('@').ToLowerInvariant() ?? "", ct);
            if (userId is not { } invitee)
                return Error.NotFound("group.user_not_found", "Bu kullanıcı adıyla bir kullanıcı bulunamadı.");
            if (await GroupAccess.ExistsAsync(conn, tx, GroupAccess.IsMemberSql, groupId, invitee, ct))
                return Error.Conflict("group.already_member", "Bu kişi zaten grubun üyesi.");
            if (await GroupAccess.ExistsAsync(conn, tx, GroupAccess.HasInvitationSql, groupId, invitee, ct))
                return Error.Conflict("group.already_invited", "Bu kişiye zaten davet gönderildi.");
            if (await GroupAccess.IsBannedAsync(conn, tx, groupId, invitee, ct))
                return Error.RuleViolation("group.user_banned", "Bu kişi gruptan uzaklaştırıldığı için şu anda davet edilemez.");

            await GroupAccess.ExecuteAsync(conn, tx,
                "insert into public.group_invitations (group_id, user_id) values (@group, @user)", groupId, invitee, ct);
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.invitation_sent", "user", invitee.ToString(), null, groupId), ct);
            return Result.Success();
        }, ct);

    public Task<Result> RevokeInvitationAsync(Guid actorId, Guid groupId, Guid userId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.InviteMembers, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (await GroupAccess.ExecuteAsync(conn, tx, DeleteInvitationSql, groupId, userId, ct) == 0) return NoInvitation;

            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.invitation_revoked", "user", userId.ToString(), null, groupId), ct);
            return Result.Success();
        }, ct);

    /// <summary>Idempotent: assigning a role the member already holds succeeds without a new audit entry.</summary>
    public Task<Result> AssignRoleAsync(Guid actorId, Guid groupId, Guid userId, string role, CancellationToken ct) =>
        ChangeRoleAsync(actorId, groupId, userId, role, assign: true, ct);

    public Task<Result> RemoveRoleAsync(Guid actorId, Guid groupId, Guid userId, string role, CancellationToken ct) =>
        ChangeRoleAsync(actorId, groupId, userId, role, assign: false, ct);

    private Task<Result> ChangeRoleAsync(Guid actorId, Guid groupId, Guid userId, string role, bool assign, CancellationToken ct)
    {
        if (!GroupRoles.Assignable.Contains(role))
            return Task.FromResult<Result>(Error.Validation("group.invalid_role", "Bu rol atanamaz."));

        return access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.AssignRoles, ct);
            if (!auth.IsSuccess) return auth.Error;

            var target = await GroupAccess.StandingAsync(conn, tx, groupId, userId, ct);
            if (!target.IsMember) return Error.NotFound("group.not_member", "Bu kişi grubun üyesi değil.");

            // Rank rule: the actor must outrank both the member and the role.
            var actorRank = auth.Value.Actor.Rank;
            if (actorRank <= target.Rank || actorRank <= await RoleRankAsync(conn, tx, role, ct)) return GroupErrors.RankViolation;

            var holds = target.Roles.Contains(role);
            if (assign && holds) return Result.Success();
            if (!assign && !holds) return Error.NotFound("group.role_not_found", "Bu üyenin böyle bir rolü yok.");

            await using (var cmd = new NpgsqlCommand(
                assign
                    ? "insert into public.group_member_roles (group_id, user_id, role) values (@group, @user, @role)"
                    : "delete from public.group_member_roles where group_id = @group and user_id = @user and role = @role",
                conn, tx))
            {
                cmd.Parameters.AddWithValue("group", groupId);
                cmd.Parameters.AddWithValue("user", userId);
                cmd.Parameters.AddWithValue("role", role);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, assign ? "group.role_assigned" : "group.role_removed",
                    "user", userId.ToString(), new { role }, groupId), ct);
            return Result.Success();
        }, ct);
    }

    public async Task<bool> RemoveAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid groupId, Guid userId, CancellationToken ct) =>
        await GroupAccess.ExecuteAsync(connection, transaction,
            "delete from public.group_members where group_id = @group and user_id = @user", groupId, userId, ct) > 0;

    private static async Task<int> RoleRankAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string role, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select rank from public.group_roles where slug = @slug", conn, tx);
        cmd.Parameters.AddWithValue("slug", role);
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    private static async Task<Guid?> FindActiveUserAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string username, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select id from public.profiles where username = @username and private.is_account_active(id)", conn, tx);
        cmd.Parameters.AddWithValue("username", username);
        return await cmd.ExecuteScalarAsync(ct) as Guid?;
    }
}
