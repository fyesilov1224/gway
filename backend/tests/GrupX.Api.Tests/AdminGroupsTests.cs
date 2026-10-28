using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Events;
using GrupX.Modules.Groups;
using GrupX.Modules.Groups.Contracts;

namespace GrupX.Api.Tests;

public sealed class AdminGroupsTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private async Task<Guid> StaffAsync(string role)
    {
        var id = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    private async Task<(Guid Owner, CreatedGroup Group)> GroupAsync()
    {
        var owner = await _db.CreateUserAsync(Unique("sahip_"));
        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            new Uri("/groups", UriKind.Relative), new CreateGroupRequest(Unique("adm_"), "Pedal Kadıköy", "cycling", "open", null), Ct);
        response.EnsureSuccessStatusCode();
        return (owner, (await response.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!);
    }

    private static Uri Suspension(Guid id) => new($"/admin/groups/{id}/suspension", UriKind.Relative);

    [Fact]
    public async Task Non_staff_cannot_list_groups()
    {
        var user = await _db.CreateUserAsync();

        var response = await factory.ClientFor(user).GetAsync(new Uri("/admin/groups", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Support_finds_groups_by_handle_with_their_owner()
    {
        var support = await StaffAsync("support");
        var (owner, group) = await GroupAsync();

        var page = await factory.ClientFor(support)
            .GetFromJsonAsync<PagedResult<AdminGroupSummary>>($"/admin/groups?q={group.Handle}", Ct);

        var found = Assert.Single(page!.Items);
        Assert.Equal(group.Id, found.Id);
        Assert.Equal(owner, found.OwnerId);
        Assert.NotNull(found.OwnerUsername);
        Assert.Equal(1, found.MemberCount);
    }

    [Fact]
    public async Task Support_cannot_suspend_groups()
    {
        var support = await StaffAsync("support");
        var (_, group) = await GroupAsync();

        var response = await factory.ClientFor(support).PostAsJsonAsync(Suspension(group.Id), new SuspendGroupRequest("Spam"), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Moderator_suspends_and_unsuspends_with_audit_and_history()
    {
        var moderator = await StaffAsync("moderator");
        var (owner, group) = await GroupAsync();
        var client = factory.ClientFor(moderator);

        var suspend = await client.PostAsJsonAsync(Suspension(group.Id), new SuspendGroupRequest("  Dolandırıcılık  "), Ct);
        var again = await client.PostAsJsonAsync(Suspension(group.Id), new SuspendGroupRequest("Tekrar"), Ct);

        suspend.EnsureSuccessStatusCode();
        var state = await suspend.Content.ReadFromJsonAsync<GroupState>(Ct);
        Assert.Equal(GroupStatuses.Suspended, state?.Status);
        Assert.Equal("Dolandırıcılık", state?.SuspensionReason);
        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);

        var detail = await client.GetFromJsonAsync<AdminGroupDetail>($"/admin/groups/{group.Id}", Ct);
        Assert.Equal("suspended", detail!.Group.Status);
        Assert.Contains(detail.History, h => h.Action == "group.suspended" && h.ActorId == moderator && h.Detail == "Dolandırıcılık");
        Assert.Contains(detail.History, h => h.Action == "group.created" && h.ActorId == owner);
        var ownerRow = Assert.Single(detail.Team);
        Assert.Equal(["owner"], ownerRow.Roles);

        var unsuspend = await client.DeleteAsync(Suspension(group.Id), Ct);
        unsuspend.EnsureSuccessStatusCode();
        Assert.Equal(GroupStatuses.Active, (await unsuspend.Content.ReadFromJsonAsync<GroupState>(Ct))?.Status);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'group.unsuspended' and group_id = @id", ("id", group.Id)));
    }

    [Fact]
    public async Task Suspension_requires_a_reason()
    {
        var admin = await StaffAsync("admin");
        var (_, group) = await GroupAsync();

        var response = await factory.ClientFor(admin).PostAsJsonAsync(Suspension(group.Id), new SuspendGroupRequest("  "), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Stats_add_up_and_status_filter_works()
    {
        var support = await StaffAsync("support");
        var moderator = await StaffAsync("moderator");
        var (_, group) = await GroupAsync();
        (await factory.ClientFor(moderator).PostAsJsonAsync(Suspension(group.Id), new SuspendGroupRequest("Spam"), Ct)).EnsureSuccessStatusCode();
        var client = factory.ClientFor(support);

        var stats = await client.GetFromJsonAsync<AdminGroupStats>("/admin/groups/stats", Ct);
        var suspended = await client.GetFromJsonAsync<PagedResult<AdminGroupSummary>>($"/admin/groups?q={group.Handle}&status=suspended", Ct);
        var active = await client.GetFromJsonAsync<PagedResult<AdminGroupSummary>>($"/admin/groups?q={group.Handle}&status=active", Ct);
        var invalid = await client.GetAsync(new Uri("/admin/groups?status=deleted", UriKind.Relative), Ct);

        Assert.True(stats!.Suspended >= 1);
        Assert.Equal(stats.Total, stats.Active + stats.Suspended);
        Assert.Single(suspended!.Items);
        Assert.Empty(active!.Items);
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
    }

    [Fact]
    public async Task Unknown_group_detail_is_404()
    {
        var support = await StaffAsync("support");

        var response = await factory.ClientFor(support).GetAsync(new Uri($"/admin/groups/{Guid.NewGuid()}", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Moderators_take_a_group_out_of_an_open_league_season()
    {
        var owner = await _db.CreateUserAsync(Unique("lig_"));
        var member = await _db.CreateUserAsync(Unique("lig_"));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            new Uri("/groups", UriKind.Relative), new CreateGroupRequest(Unique("lig_"), "Eymir Yürüyüş", "hiking", "open", null, 6), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(new Uri($"/groups/{group}/join", UriKind.Relative), null, Ct)).EnsureSuccessStatusCode();
        var form = new EventRequest("Eymir turu", "", DateTimeOffset.UtcNow.AddDays(2), null, "Eymir", null, null, null, null, null, null);
        var ev = (await (await factory.ClientFor(owner).PostAsJsonAsync(new Uri($"/groups/{group}/events", UriKind.Relative), form, Ct))
            .Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(new Uri($"/events/{ev}/attendance", UriKind.Relative), null, Ct)).EnsureSuccessStatusCode();
        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '3 hours' where id = @e", ("e", ev));
        var month = await _db.ScalarAsync<string>("select to_char(private.turkey_month(now() - interval '3 hours'), 'YYYY-MM')");
        var (support, moderator) = (await StaffAsync("support"), await StaffAsync("moderator"));
        var exclusion = new Uri($"/admin/leagues/{month}/exclusions/{group}", UriKind.Relative);
        var tableUri = new Uri($"/admin/leagues/table?month={month}&category=hiking&province=6", UriKind.Relative);

        var leagues = await factory.ClientFor(support).GetFromJsonAsync<AdminLeagueMonth>(new Uri($"/admin/leagues?month={month}", UriKind.Relative), Ct);
        var bySupport = await factory.ClientFor(support).PutAsJsonAsync(exclusion, new AdminLeagueExclusionRequest("Sahte katılım"), Ct);
        var excluded = await factory.ClientFor(moderator).PutAsJsonAsync(exclusion, new AdminLeagueExclusionRequest("Sahte katılım"), Ct);
        var table = await factory.ClientFor(support).GetFromJsonAsync<AdminLeagueTable>(tableUri, Ct);
        var restored = await factory.ClientFor(moderator).DeleteAsync(exclusion, Ct);
        var restoredAgain = await factory.ClientFor(moderator).DeleteAsync(exclusion, Ct);
        var badMonth = await factory.ClientFor(support).GetAsync(new Uri("/admin/leagues?month=ekim", UriKind.Relative), Ct);

        Assert.Contains(leagues!.Leagues, l => l.Category == "hiking" && l.Province == 6 && l.Groups >= 1);
        Assert.Equal(HttpStatusCode.Forbidden, bySupport.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, excluded.StatusCode);
        Assert.Contains(table!.Exclusions, x => x.GroupId == group && x.Reason == "Sahte katılım");
        Assert.DoesNotContain(table.Table.GetProperty("rows").EnumerateArray(),
            r => r.GetProperty("group").GetProperty("id").GetString() == group.ToString());
        Assert.Equal(HttpStatusCode.NoContent, restored.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, restoredAgain.StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, badMonth.StatusCode);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'league.group_excluded' and group_id = @g", ("g", group)));
    }
}
