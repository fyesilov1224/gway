using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

public sealed class GroupsTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<Guid> UserAsync() => _db.CreateUserAsync(Unique("u_"));

    private async Task<CreatedGroup> CreateAsync(Guid owner, string policy = "open")
    {
        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Koşu Kulübü", "running", policy, "Her pazar koşu."), Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!;
    }

    private async Task<string?> JoinAsync(Guid user, Guid group)
    {
        var response = await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<JoinResponse>(Ct))?.Status;
    }

    private Task<HttpResponseMessage> AssignAsync(Guid actor, Guid group, Guid user, string role) =>
        factory.ClientFor(actor).PutAsync(Path($"/groups/{group}/members/{user}/roles/{role}"), null, Ct);

    private Task<long> AuditCountAsync(string action, Guid group) =>
        _db.ScalarAsync<long>("select count(*) from public.audit_log where action = @a and group_id = @g", ("a", action), ("g", group));

    private Task<bool> IsMemberAsync(Guid group, Guid user) =>
        _db.ScalarAsync<bool>("select exists (select 1 from public.group_members where group_id = @g and user_id = @u)", ("g", group), ("u", user));

    // Creation -------------------------------------------------------------------

    [Fact]
    public async Task Creator_becomes_owner_and_member_and_creation_is_audited()
    {
        var owner = await UserAsync();

        var group = await CreateAsync(owner);

        Assert.Equal(owner, await _db.ScalarAsync<Guid>("select owner_id from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select member_count from public.groups where id = @id", ("id", group.Id)));
        Assert.True(await IsMemberAsync(group.Id, owner));
        Assert.Equal(1L, await AuditCountAsync("group.created", group.Id));
    }

    [Fact]
    public async Task Creating_a_group_requires_a_profile()
    {
        var user = await _db.CreateUserAsync();

        var response = await factory.ClientFor(user).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Grup", "music", "open", null), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }

    [Theory]
    [InlineData("ab", "Koşu", "running", "open", HttpStatusCode.BadRequest)]
    [InlineData("kosu..grup", "Koşu", "running", "open", HttpStatusCode.BadRequest)]
    [InlineData("gecerli_adres", "K", "running", "open", HttpStatusCode.BadRequest)]
    [InlineData("gecerli_adres", "Koşu", "yok", "open", HttpStatusCode.BadRequest)]
    [InlineData("gecerli_adres", "Koşu", "running", "secret", HttpStatusCode.BadRequest)]
    [InlineData("destek", "Koşu", "running", "open", HttpStatusCode.Conflict)]
    public async Task Invalid_creation_input_is_rejected(string handle, string name, string category, string policy, HttpStatusCode expected)
    {
        var owner = await UserAsync();

        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(handle, name, category, policy, null), Ct);

        Assert.Equal(expected, response.StatusCode);
    }

    [Fact]
    public async Task Handle_must_be_unique()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);

        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(group.Handle, "Başka", "music", "open", null), Ct);

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }

    // Joining ----------------------------------------------------------------------

    [Fact]
    public async Task Open_group_is_joined_directly_once()
    {
        var group = await CreateAsync(await UserAsync());
        var user = await UserAsync();

        Assert.Equal(JoinResponse.Member, await JoinAsync(user, group.Id));
        var again = await factory.ClientFor(user).PostAsync(Path($"/groups/{group.Id}/join"), null, Ct);

        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
        Assert.Equal(2, await _db.ScalarAsync<int>("select member_count from public.groups where id = @id", ("id", group.Id)));
    }

    [Fact]
    public async Task Request_group_needs_approval_from_an_approver()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "request");
        var member = await UserAsync();
        var applicant = await UserAsync();
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @o)::text, true);
            insert into public.group_invitations (group_id, user_id) values (@g, @m);
            """, ("o", owner), ("g", group.Id), ("m", member));
        Assert.Equal(JoinResponse.Member, await JoinAsync(member, group.Id));

        Assert.Equal(JoinResponse.Requested, await JoinAsync(applicant, group.Id));
        var approval = Path($"/groups/{group.Id}/join-requests/{applicant}/approval");
        var byMember = await factory.ClientFor(member).PostAsync(approval, null, Ct);
        var byOwner = await factory.ClientFor(owner).PostAsync(approval, null, Ct);

        Assert.Equal(HttpStatusCode.Forbidden, byMember.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, byOwner.StatusCode);
        Assert.True(await IsMemberAsync(group.Id, applicant));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.group_join_requests where group_id = @g", ("g", group.Id)));
        Assert.Equal(1L, await AuditCountAsync("group.join_approved", group.Id));
    }

    [Fact]
    public async Task Join_request_can_be_cancelled_or_rejected()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "request");
        var first = await UserAsync();
        var second = await UserAsync();
        await JoinAsync(first, group.Id);
        await JoinAsync(second, group.Id);

        var cancel = await factory.ClientFor(first).DeleteAsync(Path($"/groups/{group.Id}/join-request"), Ct);
        var reject = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/join-requests/{second}"), Ct);
        var rejectAgain = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/join-requests/{second}"), Ct);

        Assert.Equal(HttpStatusCode.NoContent, cancel.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, reject.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, rejectAgain.StatusCode);
        Assert.Equal(1L, await AuditCountAsync("group.join_rejected", group.Id));
    }

    [Fact]
    public async Task Invite_group_is_joined_only_with_an_invitation()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "invite");
        var username = Unique("davetli_");
        var invitee = await _db.CreateUserAsync(username);
        var client = factory.ClientFor(invitee);

        var uninvited = await client.PostAsync(Path($"/groups/{group.Id}/join"), null, Ct);
        var invite = await factory.ClientFor(owner).PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest($"@{username}"), Ct);
        var inviteAgain = await factory.ClientFor(owner).PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest(username), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, uninvited.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, invite.StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, inviteAgain.StatusCode);
        Assert.Equal(JoinResponse.Member, await JoinAsync(invitee, group.Id));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.group_invitations where group_id = @g", ("g", group.Id)));
        Assert.Equal(1L, await AuditCountAsync("group.invitation_sent", group.Id));
    }

    [Fact]
    public async Task A_group_sends_at_most_fifty_invitations_a_day()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "invite");
        var first = Unique("davetli_");
        var second = Unique("davetli_");
        await _db.CreateUserAsync(first);
        await _db.CreateUserAsync(second);
        // Yesterday's invitations do not count; revoked ones of the last 24 hours do.
        await _db.ExecuteAsync(
            """
            insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, group_id, occurred_at)
            select @o, 'user', 'group.invitation_sent', 'user', gen_random_uuid()::text, @g,
                   now() - case when i <= 49 then interval '1 hour' else interval '25 hours' end
            from generate_series(1, 60) i;
            """, ("o", owner), ("g", group.Id));
        var ownerClient = factory.ClientFor(owner);

        var fiftieth = await ownerClient.PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest(first), Ct);
        var over = await ownerClient.PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest(second), Ct);

        Assert.Equal(HttpStatusCode.NoContent, fiftieth.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, over.StatusCode);
        Assert.Contains("group.invitation_limit_reached", await over.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
    }

    [Fact]
    public async Task Invitation_can_be_declined_or_revoked()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "invite");
        var (firstName, secondName) = (Unique("ilk_"), Unique("ikinci_"));
        var first = await _db.CreateUserAsync(firstName);
        var second = await _db.CreateUserAsync(secondName);
        var ownerClient = factory.ClientFor(owner);
        await ownerClient.PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest(firstName), Ct);
        await ownerClient.PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest(secondName), Ct);

        var decline = await factory.ClientFor(first).DeleteAsync(Path($"/groups/{group.Id}/invitation"), Ct);
        var revoke = await ownerClient.DeleteAsync(Path($"/groups/{group.Id}/invitations/{second}"), Ct);
        var unknown = await ownerClient.PostAsJsonAsync(Path($"/groups/{group.Id}/invitations"), new InviteRequest("boyle_biri_yok"), Ct);

        Assert.Equal(HttpStatusCode.NoContent, decline.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, revoke.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, unknown.StatusCode);
        Assert.Equal(1L, await AuditCountAsync("group.invitation_revoked", group.Id));
    }

    // Roles and rank rule ----------------------------------------------------------------

    [Fact]
    public async Task Only_the_owner_assigns_roles_and_admins_gain_their_permissions()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner, "request");
        var admin = await UserAsync();
        var other = await UserAsync();
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @o)::text, true);
            insert into public.group_invitations (group_id, user_id) values (@g, @a), (@g, @x);
            """, ("o", owner), ("g", group.Id), ("a", admin), ("x", other));
        await JoinAsync(admin, group.Id);
        await JoinAsync(other, group.Id);

        Assert.Equal(HttpStatusCode.NoContent, (await AssignAsync(owner, group.Id, admin, "admin")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await AssignAsync(owner, group.Id, admin, "admin")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await AssignAsync(admin, group.Id, other, "moderator")).StatusCode);
        Assert.Equal(1L, await AuditCountAsync("group.role_assigned", group.Id));

        var applicant = await UserAsync();
        await JoinAsync(applicant, group.Id);
        var approve = await factory.ClientFor(admin).PostAsync(Path($"/groups/{group.Id}/join-requests/{applicant}/approval"), null, Ct);
        Assert.Equal(HttpStatusCode.NoContent, approve.StatusCode);
    }

    [Fact]
    public async Task Rank_rule_and_role_validation_apply()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var member = await UserAsync();
        var outsider = await UserAsync();
        await JoinAsync(member, group.Id);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await AssignAsync(owner, group.Id, owner, "admin")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await AssignAsync(owner, group.Id, member, "owner")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await AssignAsync(owner, group.Id, outsider, "moderator")).StatusCode);

        Assert.Equal(HttpStatusCode.NoContent, (await AssignAsync(owner, group.Id, member, "moderator")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await AssignAsync(owner, group.Id, member, "discipline")).StatusCode);
        var remove = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/members/{member}/roles/moderator"), Ct);
        var removeAgain = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/members/{member}/roles/moderator"), Ct);

        Assert.Equal(HttpStatusCode.NoContent, remove.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, removeAgain.StatusCode);
        Assert.Equal(1L, await AuditCountAsync("group.role_removed", group.Id));
    }

    // Leaving and ownership ------------------------------------------------------------------

    [Fact]
    public async Task Owner_cannot_leave_but_members_can_and_lose_their_roles()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var member = await UserAsync();
        await JoinAsync(member, group.Id);
        await AssignAsync(owner, group.Id, member, "moderator");

        var ownerLeaves = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/membership"), Ct);
        var memberLeaves = await factory.ClientFor(member).DeleteAsync(Path($"/groups/{group.Id}/membership"), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, ownerLeaves.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, memberLeaves.StatusCode);
        Assert.False(await IsMemberAsync(group.Id, member));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.group_member_roles where group_id = @g", ("g", group.Id)));
    }

    [Fact]
    public async Task Ownership_moves_only_to_a_member()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var member = await UserAsync();
        var outsider = await UserAsync();
        await JoinAsync(member, group.Id);
        var client = factory.ClientFor(owner);

        var toOutsider = await client.PostAsJsonAsync(Path($"/groups/{group.Id}/ownership"), new TransferOwnershipRequest(outsider), Ct);
        var byMember = await factory.ClientFor(member).PostAsJsonAsync(Path($"/groups/{group.Id}/ownership"), new TransferOwnershipRequest(member), Ct);
        var toMember = await client.PostAsJsonAsync(Path($"/groups/{group.Id}/ownership"), new TransferOwnershipRequest(member), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, toOutsider.StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, byMember.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, toMember.StatusCode);
        Assert.Equal(member, await _db.ScalarAsync<Guid>("select owner_id from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal(1L, await AuditCountAsync("group.ownership_transferred", group.Id));

        // The previous owner is now a regular member and may leave.
        Assert.Equal(HttpStatusCode.NoContent, (await client.DeleteAsync(Path($"/groups/{group.Id}/membership"), Ct)).StatusCode);
    }

    // Editing and deletion --------------------------------------------------------------------

    [Fact]
    public async Task Editors_update_only_the_fields_they_send()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var member = await UserAsync();
        await JoinAsync(member, group.Id);
        var uri = Path($"/groups/{group.Id}");

        var byMember = await factory.ClientFor(member).PatchAsJsonAsync(uri, new UpdateGroupRequest(Name: "Ele geçirildi"), Ct);
        var update = await factory.ClientFor(owner).PatchAsJsonAsync(uri, new UpdateGroupRequest(
            Rules: "  Saygılı ol.  ",
            Links: [new GroupLink(" Instagram ", "https://instagram.com/kosu")],
            LogoPath: $"{group.Id}/logo-1.jpg"), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, byMember.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, update.StatusCode);
        Assert.Equal("Koşu Kulübü", await _db.ScalarAsync<string>("select name from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal("Saygılı ol.", await _db.ScalarAsync<string>("select rules from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal("Instagram", await _db.ScalarAsync<string>("select links->0->>'label' from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal($"{group.Id}/logo-1.jpg", await _db.ScalarAsync<string>("select logo_path from public.groups where id = @id", ("id", group.Id)));

        var clear = await factory.ClientFor(owner).PatchAsJsonAsync(uri, new UpdateGroupRequest(LogoPath: ""), Ct);
        Assert.Equal(HttpStatusCode.NoContent, clear.StatusCode);
        Assert.Null(await _db.ScalarAsync<string>("select logo_path from public.groups where id = @id", ("id", group.Id)));
        Assert.Equal(2L, await AuditCountAsync("group.updated", group.Id));
    }

    [Theory]
    [InlineData("ftp://dosya.example")]
    [InlineData("instagram.com/kosu")]
    public async Task Links_must_be_http_addresses(string url)
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);

        var response = await factory.ClientFor(owner).PatchAsJsonAsync(
            Path($"/groups/{group.Id}"), new UpdateGroupRequest(Links: [new GroupLink("Bağlantı", url)]), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Image_path_must_be_inside_the_group_folder()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);

        var response = await factory.ClientFor(owner).PatchAsJsonAsync(
            Path($"/groups/{group.Id}"), new UpdateGroupRequest(CoverPath: $"{Guid.NewGuid()}/cover.jpg"), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Only_the_owner_deletes_the_group_and_its_images()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var admin = await UserAsync();
        await JoinAsync(admin, group.Id);
        await AssignAsync(owner, group.Id, admin, "admin");

        var byAdmin = await factory.ClientFor(admin).DeleteAsync(Path($"/groups/{group.Id}"), Ct);
        var byOwner = await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}"), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, byAdmin.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, byOwner.StatusCode);
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.group_members where group_id = @g", ("g", group.Id)));
        Assert.Contains(("group-images", group.Id.ToString()), factory.Storage.DeletedFolders);
        Assert.Equal(1L, await AuditCountAsync("group.deleted", group.Id));
    }

    [Fact]
    public async Task Group_owner_cannot_request_account_deletion()
    {
        var owner = await UserAsync();
        await CreateAsync(owner);

        var response = await factory.ClientFor(owner).PostAsync(Path("/account/deletion"), null, Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }

    [Fact]
    public async Task Suspended_group_rejects_joins_and_edits()
    {
        var owner = await UserAsync();
        var group = await CreateAsync(owner);
        var staff = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(staff, "moderator");
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @s)::text, true);
            update public.groups set status = 'suspended', suspended_at = now(), suspension_reason = 'x' where id = @id;
            """, ("s", staff), ("id", group.Id));
        var user = await UserAsync();

        var join = await factory.ClientFor(user).PostAsync(Path($"/groups/{group.Id}/join"), null, Ct);
        var edit = await factory.ClientFor(owner).PatchAsJsonAsync(Path($"/groups/{group.Id}"), new UpdateGroupRequest(About: "x"), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, join.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, edit.StatusCode);
    }

    [Fact]
    public async Task Unknown_group_is_404()
    {
        var user = await UserAsync();

        var response = await factory.ClientFor(user).PostAsync(Path($"/groups/{Guid.NewGuid()}/join"), null, Ct);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }
}
