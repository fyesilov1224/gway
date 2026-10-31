using System.Security.Cryptography;
using Gway.Modules.Billing.Contracts;
using Gway.Modules.Groups.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Npgsql;

namespace Gway.Modules.Groups;

public sealed record CreateInviteLinkRequest(int Days, int? MaxUses);

public sealed record InviteLinkResponse(Guid Id, string Code, DateTimeOffset ExpiresAt, int? MaxUses);

public sealed record InviteAcceptance(Guid GroupId, string Handle);

/// <summary>Shareable invite links (docs/ARCHITECTURE.md §3b, Davet bağlantısı). The triggers check every rule again.</summary>
internal sealed class InviteLinkService(GroupAccess access, IGroupPlanLimits planLimits)
{
    public const int MaxValidLinks = 20;
    public const int MaxUsesLimit = 1000;
    private const int CodeLength = 12;
    // No i, l, o, 0 or 1: codes are read aloud and typed.
    private const string Alphabet = "abcdefghjkmnpqrstuvwxyz23456789";

    public static readonly int[] Durations = [1, 7, 30];

    private static readonly Error NotFound = Error.NotFound("group.invite_link_not_found", "Davet bağlantısı bulunamadı.");

    public Task<Result<InviteLinkResponse>> CreateAsync(Guid actorId, Guid groupId, CreateInviteLinkRequest body, CancellationToken ct)
    {
        if (!Durations.Contains(body.Days))
            return Task.FromResult<Result<InviteLinkResponse>>(Error.Validation("group.invalid_link_days", "Süre 1, 7 ya da 30 gün olmalı."));
        if (body.MaxUses is < 1 or > MaxUsesLimit)
        {
            return Task.FromResult<Result<InviteLinkResponse>>(
                Error.Validation("group.invalid_link_uses", $"Kullanım sınırı 1–{MaxUsesLimit} kişi olmalı."));
        }

        return access.RunAsync<InviteLinkResponse>(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.InviteMembers, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (await ValidLinksAsync(conn, tx, groupId, ct) >= MaxValidLinks) return GroupErrors.InviteLinkLimitReached;

            InviteLinkResponse link;
            await using (var cmd = new NpgsqlCommand(
                """
                insert into public.group_invite_links (group_id, code, created_by, expires_at, max_uses)
                values (@group, @code, @actor, now() + make_interval(days => @days), @max)
                returning id, code, expires_at, max_uses
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("group", groupId);
                cmd.Parameters.AddWithValue("code", NewCode());
                cmd.Parameters.AddWithValue("actor", actorId);
                cmd.Parameters.AddWithValue("days", body.Days);
                cmd.Parameters.AddWithValue("max", (object?)body.MaxUses ?? DBNull.Value);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                await r.ReadAsync(ct);
                link = new InviteLinkResponse(r.GetGuid(0), r.GetString(1), r.GetFieldValue<DateTimeOffset>(2), r.IsDBNull(3) ? null : r.GetInt32(3));
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.User, "group.invite_link_created", "group_invite_link",
                link.Id.ToString(), new { days = body.Days, maxUses = body.MaxUses }, groupId), ct);
            return link;
        }, ct);
    }

    /// <summary>A group inviter, or platform staff (<paramref name="staff"/>; the caller checked the staff role).</summary>
    public Task<Result> RevokeAsync(Guid actorId, Guid groupId, Guid linkId, bool staff, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            if (!staff)
            {
                var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.InviteMembers, ct);
                if (!auth.IsSuccess) return auth.Error;
            }
            await using (var cmd = new NpgsqlCommand(
                """
                update public.group_invite_links set revoked_at = now(), revoked_by = @actor
                where id = @id and group_id = @group and revoked_at is null
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("id", linkId);
                cmd.Parameters.AddWithValue("group", groupId);
                cmd.Parameters.AddWithValue("actor", actorId);
                if (await cmd.ExecuteNonQueryAsync(ct) == 0) return NotFound;
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, staff ? AuditActor.Staff : AuditActor.User,
                "group.invite_link_revoked", "group_invite_link", linkId.ToString(), null, groupId), ct);
            return Result.Success();
        }, ct);

    /// <summary>Joins the link's group whatever its join policy; joining a group one is already in just opens it.</summary>
    public Task<Result<InviteAcceptance>> AcceptAsync(Guid actorId, string code, CancellationToken ct)
    {
        code = code.Trim().ToLowerInvariant();
        if (code.Length != CodeLength || code.Any(c => !Alphabet.Contains(c, StringComparison.Ordinal)))
            return Task.FromResult<Result<InviteAcceptance>>(GroupErrors.InviteLinkInvalid);

        return access.RunAsync<InviteAcceptance>(actorId, async (conn, tx) =>
        {
            Guid linkId, groupId;
            bool valid;
            await using (var cmd = new NpgsqlCommand(
                "select l.id, l.group_id, private.invite_link_valid(l) from public.group_invite_links l where l.code = @code for update",
                conn, tx))
            {
                cmd.Parameters.AddWithValue("code", code);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (!await r.ReadAsync(ct)) return GroupErrors.InviteLinkInvalid;
                (linkId, groupId, valid) = (r.GetGuid(0), r.GetGuid(1), r.GetBoolean(2));
            }

            var group = await GroupAccess.LockGroupAsync(conn, tx, groupId, ct);
            if (group is null || group.Status != GroupStatuses.Active) return GroupErrors.InviteLinkInvalid;
            var accepted = new InviteAcceptance(group.Id, group.Handle);
            if (await GroupAccess.ExistsAsync(conn, tx, GroupAccess.IsMemberSql, groupId, actorId, ct)) return accepted;
            if (!await GroupAccess.IsAccountActiveAsync(conn, tx, actorId, ct)) return GroupErrors.AccountInactive;
            if (!await GroupAccess.HasProfileAsync(conn, tx, actorId, ct))
                return Error.RuleViolation("group.profile_required", "Gruba katılmak için önce profilini tamamlamalısın.");
            if (await GroupAccess.IsBannedAsync(conn, tx, groupId, actorId, ct)) return GroupErrors.Banned;
            if (!valid) return GroupErrors.InviteLinkInvalid;
            if (group.MemberCount >= (await planLimits.GetAsync(conn, tx, groupId, ct)).MaxMembers) return GroupErrors.MemberLimitReached;

            await using (var use = new NpgsqlCommand(
                "insert into public.group_invite_link_uses (link_id, user_id) values (@link, @user)", conn, tx))
            {
                use.Parameters.AddWithValue("link", linkId);
                use.Parameters.AddWithValue("user", actorId);
                await use.ExecuteNonQueryAsync(ct);
            }
            await GroupAccess.ExecuteAsync(conn, tx, "insert into public.group_members (group_id, user_id) values (@group, @user)", groupId, actorId, ct);
            await GroupAccess.ExecuteAsync(conn, tx, "delete from public.group_join_requests where group_id = @group and user_id = @user", groupId, actorId, ct);
            await GroupAccess.ExecuteAsync(conn, tx, "delete from public.group_invitations where group_id = @group and user_id = @user", groupId, actorId, ct);
            return accepted;
        }, ct);
    }

    private static async Task<int> ValidLinksAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select count(*)::int from public.group_invite_links l where l.group_id = @group and private.invite_link_valid(l)", conn, tx);
        cmd.Parameters.AddWithValue("group", groupId);
        return (int)(await cmd.ExecuteScalarAsync(ct))!;
    }

    private static string NewCode() => RandomNumberGenerator.GetString(Alphabet, CodeLength);
}
