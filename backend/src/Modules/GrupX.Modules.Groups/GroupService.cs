using System.Text.Json;
using GrupX.Modules.Groups.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Supabase;
using Microsoft.Extensions.Logging;
using Npgsql;
using NpgsqlTypes;

namespace GrupX.Modules.Groups;

public sealed record CreateGroupRequest(string Handle, string Name, string CategorySlug, string JoinPolicy, string? About, int? Province = null);

public sealed record CreatedGroup(Guid Id, string Handle);

/// <summary>Only the fields that are sent change. An empty image path removes the image; province 0 removes the province.</summary>
public sealed record UpdateGroupRequest(
    string? Name = null,
    string? CategorySlug = null,
    string? JoinPolicy = null,
    string? About = null,
    string? Rules = null,
    IReadOnlyList<GroupLink>? Links = null,
    string? LogoPath = null,
    string? CoverPath = null,
    int? Province = null);

public sealed record TransferOwnershipRequest(Guid UserId);

public sealed record CaseThresholdRequest(string Threshold);

/// <summary>Group lifecycle: creation, profile edits, deletion, ownership and platform suspension.</summary>
internal sealed partial class GroupService(GroupAccess access, ISupabaseStorage storage, ILogger<GroupService> logger) : IGroupAdministration
{
    public const string ImageBucket = "group-images";

    public Task<Result<CreatedGroup>> CreateAsync(Guid actorId, CreateGroupRequest request, CancellationToken ct)
    {
        var handle = request.Handle?.Trim().ToLowerInvariant();
        var invalid = GroupRules.ValidateHandle(handle) ?? GroupRules.ValidateName(request.Name)
            ?? GroupRules.ValidateJoinPolicy(request.JoinPolicy) ?? GroupRules.ValidateAbout(request.About)
            ?? (request.Province is null ? null : GroupRules.ValidateProvince(request.Province.Value));
        if (invalid is not null) return Task.FromResult<Result<CreatedGroup>>(invalid);

        return access.RunAsync<CreatedGroup>(actorId, async (conn, tx) =>
        {
            if (!await GroupAccess.IsAccountActiveAsync(conn, tx, actorId, ct)) return GroupErrors.AccountInactive;
            if (!await GroupAccess.HasProfileAsync(conn, tx, actorId, ct))
                return Error.RuleViolation("group.profile_required", "Grup oluşturmak için önce profilini tamamlamalısın.");
            if (!await CategoryExistsAsync(conn, tx, request.CategorySlug, ct))
                return Error.Validation("group.invalid_category", "Geçerli bir kategori seç.");
            if (await HandleTakenAsync(conn, tx, handle!, ct))
                return Error.Conflict("group.handle_taken", "Bu grup adresi alınmış. Başka bir tane dene.");

            Guid id;
            await using (var cmd = new NpgsqlCommand(
                """
                insert into public.groups (handle, name, category_slug, join_policy, about, owner_id, province)
                values (@handle, @name, @category, @policy, @about, @owner, @province)
                returning id
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("handle", handle!);
                cmd.Parameters.AddWithValue("name", request.Name.Trim());
                cmd.Parameters.AddWithValue("category", request.CategorySlug);
                cmd.Parameters.AddWithValue("policy", request.JoinPolicy);
                cmd.Parameters.AddWithValue("about", request.About?.Trim() ?? "");
                cmd.Parameters.AddWithValue("owner", actorId);
                cmd.Parameters.Add(new NpgsqlParameter<short?>("province", (short?)request.Province));
                id = (Guid)(await cmd.ExecuteScalarAsync(ct))!;
            }
            await GroupAccess.ExecuteAsync(conn, tx,
                "insert into public.group_members (group_id, user_id) values (@group, @user)", id, actorId, ct);

            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.created", "group", id.ToString(),
                    new { handle, joinPolicy = request.JoinPolicy }, id), ct);
            return new CreatedGroup(id, handle!);
        }, ct);
    }

    public Task<Result> UpdateAsync(Guid actorId, Guid groupId, UpdateGroupRequest request, CancellationToken ct)
    {
        var invalid = (request.Name is null ? null : GroupRules.ValidateName(request.Name))
            ?? (request.JoinPolicy is null ? null : GroupRules.ValidateJoinPolicy(request.JoinPolicy))
            ?? GroupRules.ValidateAbout(request.About) ?? GroupRules.ValidateRules(request.Rules)
            ?? GroupRules.ValidateLinks(request.Links)
            ?? GroupRules.ValidateImagePath(groupId, request.LogoPath) ?? GroupRules.ValidateImagePath(groupId, request.CoverPath)
            ?? (request.Province is null or 0 ? null : GroupRules.ValidateProvince(request.Province.Value));
        if (invalid is not null) return Task.FromResult<Result>(invalid);

        return access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.Edit, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (request.CategorySlug is not null && !await CategoryExistsAsync(conn, tx, request.CategorySlug, ct))
                return Error.Validation("group.invalid_category", "Geçerli bir kategori seç.");

            await using (var cmd = new NpgsqlCommand(
                """
                update public.groups set
                  name = coalesce(@name, name),
                  category_slug = coalesce(@category, category_slug),
                  join_policy = coalesce(@policy, join_policy),
                  about = coalesce(@about, about),
                  rules = coalesce(@rules, rules),
                  links = coalesce(@links, links),
                  logo_path = case when @logo is null then logo_path else nullif(@logo, '') end,
                  cover_path = case when @cover is null then cover_path else nullif(@cover, '') end,
                  province = case when @province is null then province else nullif(@province, 0) end
                where id = @id
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("id", groupId);
                cmd.Parameters.Add(new NpgsqlParameter<string?>("name", request.Name?.Trim()));
                cmd.Parameters.Add(new NpgsqlParameter<string?>("category", request.CategorySlug));
                cmd.Parameters.Add(new NpgsqlParameter<string?>("policy", request.JoinPolicy));
                cmd.Parameters.Add(new NpgsqlParameter<string?>("about", request.About?.Trim()));
                cmd.Parameters.Add(new NpgsqlParameter<string?>("rules", request.Rules?.Trim()));
                cmd.Parameters.Add(new NpgsqlParameter("links", NpgsqlDbType.Jsonb)
                {
                    Value = request.Links is null
                        ? DBNull.Value
                        : JsonSerializer.Serialize(GroupRules.Normalize(request.Links), JsonSerializerOptions.Web),
                });
                cmd.Parameters.Add(new NpgsqlParameter<string?>("logo", request.LogoPath));
                cmd.Parameters.Add(new NpgsqlParameter<string?>("cover", request.CoverPath));
                cmd.Parameters.Add(new NpgsqlParameter<short?>("province", (short?)request.Province));
                await cmd.ExecuteNonQueryAsync(ct);
            }

            var fields = new (string Name, object? Value)[]
            {
                ("name", request.Name), ("category", request.CategorySlug), ("joinPolicy", request.JoinPolicy),
                ("about", request.About), ("rules", request.Rules), ("links", request.Links),
                ("logo", request.LogoPath), ("cover", request.CoverPath), ("province", request.Province),
            }.Where(f => f.Value is not null).Select(f => f.Name).ToArray();
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.updated", "group", groupId.ToString(), new { fields }, groupId), ct);
            return Result.Success();
        }, ct);
    }

    /// <summary>The board's decision threshold (docs/ARCHITECTURE.md §3e); the owner's setting.</summary>
    public Task<Result> SetCaseThresholdAsync(Guid actorId, Guid groupId, string? threshold, CancellationToken ct)
    {
        if (threshold is null || !GroupRules.CaseThresholds.Contains(threshold))
            return Task.FromResult<Result>(Error.Validation("group.invalid_case_threshold", "Geçerli bir karar eşiği seç."));

        return access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.AssignRoles, ct);
            if (!auth.IsSuccess) return auth.Error;
            await using (var cmd = new NpgsqlCommand(
                "update public.groups set case_threshold = @threshold where id = @id and case_threshold <> @threshold", conn, tx))
            {
                cmd.Parameters.AddWithValue("id", groupId);
                cmd.Parameters.AddWithValue("threshold", threshold);
                if (await cmd.ExecuteNonQueryAsync(ct) == 0) return Result.Success();
            }
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.case_threshold_changed", "group", groupId.ToString(), new { threshold }, groupId), ct);
            return Result.Success();
        }, ct);
    }

    public async Task<Result> DeleteAsync(Guid actorId, Guid groupId, CancellationToken ct)
    {
        var result = await access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.Delete, ct);
            if (!auth.IsSuccess) return auth.Error;

            // Cascades to memberships, roles, join requests and invitations.
            await using (var cmd = new NpgsqlCommand("delete from public.groups where id = @id", conn, tx))
            {
                cmd.Parameters.AddWithValue("id", groupId);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.deleted", "group", groupId.ToString(),
                    new { handle = auth.Value.Group.Handle }, groupId), ct);
            return Result.Success();
        }, ct);
        if (!result.IsSuccess) return result;

        // The group is gone either way; leftover files are only logged.
        try
        {
            await storage.DeleteFolderAsync(ImageBucket, groupId.ToString(), ct);
        }
        catch (HttpRequestException ex)
        {
            LogImageCleanupFailed(logger, ex, groupId);
        }
        return result;
    }

    public Task<Result> TransferOwnershipAsync(Guid actorId, Guid groupId, Guid newOwnerId, CancellationToken ct) =>
        access.RunActionAsync(actorId, async (conn, tx) =>
        {
            var auth = await GroupAccess.AuthorizeAsync(conn, tx, groupId, actorId, GroupPermissions.Transfer, ct);
            if (!auth.IsSuccess) return auth.Error;
            if (newOwnerId == auth.Value.Group.OwnerId)
                return Error.RuleViolation("group.already_owner", "Bu kişi zaten grubun sahibi.");
            if (!await GroupAccess.ExistsAsync(conn, tx, GroupAccess.IsMemberSql, groupId, newOwnerId, ct))
                return Error.RuleViolation("group.not_member", "Sahiplik yalnızca grubun bir üyesine devredilebilir.");
            if (!await GroupAccess.IsAccountActiveAsync(conn, tx, newOwnerId, ct))
                return Error.RuleViolation("group.member_inactive", "Bu üyenin hesabı aktif olmadığı için sahiplik devredilemez.");

            await GroupAccess.ExecuteAsync(conn, tx, "update public.groups set owner_id = @user where id = @group", groupId, newOwnerId, ct);
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.User, "group.ownership_transferred", "group", groupId.ToString(),
                    new { from = auth.Value.Group.OwnerId, to = newOwnerId }, groupId), ct);
            return Result.Success();
        }, ct);

    public Task<Result<GroupState>> SuspendAsync(Guid actorId, Guid groupId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is 0 or > GroupRules.MaxReason)
        {
            return Task.FromResult<Result<GroupState>>(
                Error.Validation("group.invalid_reason", $"Askıya alma gerekçesi 1-{GroupRules.MaxReason} karakter olmalı."));
        }

        return access.RunAsync(actorId, async (conn, tx) =>
        {
            var group = await GroupAccess.LockGroupAsync(conn, tx, groupId, ct);
            if (group is null) return GroupErrors.NotFound;
            if (group.Status == GroupStatuses.Suspended) return Error.Conflict("group.already_suspended", "Bu grup zaten askıda.");

            var state = await SetStatusAsync(conn, tx, groupId,
                "status = 'suspended', suspension_reason = @reason, suspended_at = now()", reason, ct);
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.Staff, "group.suspended", "group", groupId.ToString(), new { reason }, groupId), ct);
            return state;
        }, ct);
    }

    public Task<Result<GroupState>> UnsuspendAsync(Guid actorId, Guid groupId, CancellationToken ct) =>
        access.RunAsync(actorId, async (conn, tx) =>
        {
            var group = await GroupAccess.LockGroupAsync(conn, tx, groupId, ct);
            if (group is null) return GroupErrors.NotFound;
            if (group.Status != GroupStatuses.Suspended) return Error.Conflict("group.not_suspended", "Bu grup askıda değil.");

            var state = await SetStatusAsync(conn, tx, groupId,
                "status = 'active', suspension_reason = null, suspended_at = null", null, ct);
            await AuditLog.AppendAsync(conn, tx,
                new AuditEntry(actorId, AuditActor.Staff, "group.unsuspended", "group", groupId.ToString(), null, groupId), ct);
            return state;
        }, ct);

    // -------------------------------------------------------------------------

    /// <param name="assignments">Constant SQL only; never user input.</param>
    private static async Task<Result<GroupState>> SetStatusAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid groupId, string assignments, string? reason, CancellationToken ct)
    {
#pragma warning disable CA2100 // assignments are compile-time constants from this class
        await using var cmd = new NpgsqlCommand(
            $"update public.groups set {assignments} where id = @id returning status, suspension_reason, suspended_at", conn, tx);
#pragma warning restore CA2100
        cmd.Parameters.AddWithValue("id", groupId);
        cmd.Parameters.Add(new NpgsqlParameter<string?>("reason", reason));
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        await reader.ReadAsync(ct);
        return new GroupState(
            reader.GetString(0),
            reader.IsDBNull(1) ? null : reader.GetString(1),
            reader.IsDBNull(2) ? null : reader.GetFieldValue<DateTimeOffset>(2));
    }

    private static async Task<bool> CategoryExistsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string? slug, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(slug)) return false;
        await using var cmd = new NpgsqlCommand("select 1 from public.categories where slug = @slug", conn, tx);
        cmd.Parameters.AddWithValue("slug", slug);
        return await cmd.ExecuteScalarAsync(ct) is not null;
    }

    private static async Task<bool> HandleTakenAsync(NpgsqlConnection conn, NpgsqlTransaction tx, string handle, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select private.is_group_handle_taken(@handle)", conn, tx);
        cmd.Parameters.AddWithValue("handle", handle);
        return (bool)(await cmd.ExecuteScalarAsync(ct))!;
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "Deleting images of group {GroupId} failed")]
    private static partial void LogImageCleanupFailed(ILogger logger, Exception ex, Guid groupId);
}
