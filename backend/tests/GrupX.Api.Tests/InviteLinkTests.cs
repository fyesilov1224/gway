using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Groups;

namespace GrupX.Api.Tests;

public sealed class InviteLinkTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<Guid> UserAsync() => _db.CreateUserAsync(Unique("u_"));

    private async Task<CreatedGroup> GroupAsync(Guid owner, string policy)
    {
        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Doğa Yürüyüşü", "nature", policy, "Her cumartesi yürüyüş."), Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!;
    }

    private async Task<InviteLinkResponse> LinkAsync(Guid actor, Guid group, int days = 7, int? maxUses = null)
    {
        var response = await factory.ClientFor(actor).PostAsJsonAsync(Path($"/groups/{group}/invite-links"), new CreateInviteLinkRequest(days, maxUses), Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<InviteLinkResponse>(Ct))!;
    }

    private Task<HttpResponseMessage> AcceptAsync(Guid user, string code) =>
        factory.ClientFor(user).PostAsync(Path($"/invites/{code}/acceptance"), null, Ct);

    private Task<bool> IsMemberAsync(Guid group, Guid user) =>
        _db.ScalarAsync<bool>("select exists (select 1 from public.group_members where group_id = @g and user_id = @u)", ("g", group), ("u", user));

    [Fact]
    public async Task A_link_lets_people_into_an_invite_only_group_until_its_limit()
    {
        var (owner, first, second) = (await UserAsync(), await UserAsync(), await UserAsync());
        var group = await GroupAsync(owner, "invite");

        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(owner).PostAsJsonAsync(Path($"/groups/{group.Id}/invite-links"), new CreateInviteLinkRequest(3, null), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(first).PostAsJsonAsync(Path($"/groups/{group.Id}/invite-links"), new CreateInviteLinkRequest(7, null), Ct)).StatusCode);

        var link = await LinkAsync(owner, group.Id, maxUses: 1);
        Assert.Matches("^[a-hj-km-np-z2-9]{12}$", link.Code);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'group.invite_link_created' and group_id = @g", ("g", group.Id)));

        var accepted = await AcceptAsync(first, link.Code);
        accepted.EnsureSuccessStatusCode();
        Assert.Equal(group.Id, (await accepted.Content.ReadFromJsonAsync<InviteAcceptance>(Ct))!.GroupId);
        Assert.True(await IsMemberAsync(group.Id, first));
        // Opening it again as a member just opens the group.
        (await AcceptAsync(first, link.Code)).EnsureSuccessStatusCode();

        var used = await AcceptAsync(second, link.Code);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, used.StatusCode);
        Assert.Contains("group.invite_link_invalid", await used.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.False(await IsMemberAsync(group.Id, second));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await AcceptAsync(second, "nosuchcode22")).StatusCode);
    }

    [Fact]
    public async Task A_revoked_link_closes_and_a_member_can_rejoin_with_a_live_one()
    {
        var (owner, member) = (await UserAsync(), await UserAsync());
        var group = await GroupAsync(owner, "request");
        var link = await LinkAsync(owner, group.Id);

        (await AcceptAsync(member, link.Code)).EnsureSuccessStatusCode();
        Assert.True(await IsMemberAsync(group.Id, member));
        (await factory.ClientFor(member).DeleteAsync(Path($"/groups/{group.Id}/membership"), Ct)).EnsureSuccessStatusCode();
        (await AcceptAsync(member, link.Code)).EnsureSuccessStatusCode();
        Assert.Equal(2, await _db.ScalarAsync<int>("select use_count from public.group_invite_links where id = @id", ("id", link.Id)));

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(member).DeleteAsync(Path($"/groups/{group.Id}/invite-links/{link.Id}"), Ct)).StatusCode);
        (await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/invite-links/{link.Id}"), Ct)).EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(owner).DeleteAsync(Path($"/groups/{group.Id}/invite-links/{link.Id}"), Ct)).StatusCode);

        var newcomer = await UserAsync();
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await AcceptAsync(newcomer, link.Code)).StatusCode);
    }

    [Fact]
    public async Task Staff_see_links_without_codes_and_revoke_them()
    {
        var (owner, moderator, support) = (await UserAsync(), await UserAsync(), await UserAsync());
        await _db.MakeStaffAsync(moderator, "moderator");
        await _db.MakeStaffAsync(support, "support");
        var group = await GroupAsync(owner, "open");
        var link = await LinkAsync(owner, group.Id, days: 30, maxUses: 50);

        var detail = (await factory.ClientFor(support).GetFromJsonAsync<AdminGroupDetail>($"/admin/groups/{group.Id}", Ct))!;
        var row = Assert.Single(detail.InviteLinks!);
        Assert.Equal((link.Id, 50, 0, true), (row.Id, row.MaxUses, row.UseCount, row.Valid));

        var url = Path($"/admin/groups/{group.Id}/invite-links/{link.Id}/revocation");
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PostAsync(url, null, Ct)).StatusCode);
        (await factory.ClientFor(moderator).PostAsync(url, null, Ct)).EnsureSuccessStatusCode();
        Assert.Equal("staff", await _db.ScalarAsync<string>(
            "select actor_kind from public.audit_log where action = 'group.invite_link_revoked' and target_id = @id", ("id", link.Id.ToString())));
    }

    [Fact]
    public async Task Share_pages_preview_public_information_and_send_people_to_the_app()
    {
        var owner = await UserAsync();
        var group = await GroupAsync(owner, "invite");
        var link = await LinkAsync(owner, group.Id);
        var handle = await _db.ScalarAsync<string>("select handle from public.groups where id = @id", ("id", group.Id));
        var anonymous = factory.CreateClient();

        var page = await anonymous.GetStringAsync(Path($"/s/g/{handle}"), Ct);
        Assert.Contains("<meta property=\"og:title\" content=\"Doğa Yürüyüşü\">", page, StringComparison.Ordinal);
        Assert.Contains($"/#/g/{handle}", page, StringComparison.Ordinal);

        var invite = await anonymous.GetStringAsync(Path($"/s/i/{link.Code}"), Ct);
        Assert.Contains("Doğa Yürüyüşü grubuna davetlisin", invite, StringComparison.Ordinal);
        Assert.Contains($"/#/i/{link.Code}", invite, StringComparison.Ordinal);

        var unknown = await anonymous.GetStringAsync(Path("/s/g/no.such.group"), Ct);
        Assert.Contains("<title>GrupX</title>", unknown, StringComparison.Ordinal);
        var noEvent = await anonymous.GetAsync(Path($"/s/e/{Guid.NewGuid()}"), Ct);
        Assert.Equal(HttpStatusCode.OK, noEvent.StatusCode);
    }
}
