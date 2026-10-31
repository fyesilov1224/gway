using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Events;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

/// <summary>Phase 14: tiles through the API, the group province and the event meeting point.</summary>
public sealed class MapTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid Owner, Guid Group)> GroupAsync(int? province = null)
    {
        var owner = await _db.CreateUserAsync(Unique("m_"));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Doğa Yürüyüşü", "hiking", "open", null, province), Ct);
        created.EnsureSuccessStatusCode();
        return (owner, (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id);
    }

    private static EventRequest Form(MeetingPoint? meeting) =>
        new("Belgrad Ormanı yürüyüşü", "", DateTimeOffset.UtcNow.AddDays(2), null, "Bahçeköy girişi", null, null, null, null, null, null,
            Meeting: meeting);

    [Fact]
    public async Task Tiles_come_through_the_api_with_the_key_kept_on_the_server()
    {
        var user = await _db.CreateUserAsync(Unique("m_"));
        var client = factory.ClientFor(user);

        Assert.Equal(HttpStatusCode.Unauthorized, (await factory.CreateClient().GetAsync(Path("/map/tiles/3/2/1.png"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await client.GetAsync(Path("/map/tiles/3/8/1.png"), Ct)).StatusCode);

        var before = factory.Tiles.Requests.Count;
        var first = await client.GetAsync(Path("/map/tiles/5/17/11.png"), Ct);
        var second = await client.GetAsync(Path("/map/tiles/5/17/11.png"), Ct);
        first.EnsureSuccessStatusCode();
        second.EnsureSuccessStatusCode();
        Assert.Equal("image/png", first.Content.Headers.ContentType?.MediaType);
        Assert.Equal(before + 1, factory.Tiles.Requests.Count);
        Assert.Contains(factory.Tiles.Requests, u => u.AbsolutePath == "/5/17/11.png" && u.Query == $"?api_key={FakeTiles.ApiKey}");
    }

    [Fact]
    public async Task Groups_pick_a_province()
    {
        var (owner, group) = await GroupAsync(province: 34);
        Task<short?> ProvinceAsync() => _db.ScalarAsync<short?>("select province from public.groups where id = @g", ("g", group));
        Assert.Equal((short)34, await ProvinceAsync());

        var client = factory.ClientFor(owner);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await client.PatchAsJsonAsync(Path($"/groups/{group}"), new UpdateGroupRequest(Province: 82), Ct)).StatusCode);
        (await client.PatchAsJsonAsync(Path($"/groups/{group}"), new UpdateGroupRequest(About: "Yeni"), Ct)).EnsureSuccessStatusCode();
        Assert.Equal((short)34, await ProvinceAsync());
        (await client.PatchAsJsonAsync(Path($"/groups/{group}"), new UpdateGroupRequest(Province: 6), Ct)).EnsureSuccessStatusCode();
        Assert.Equal((short)6, await ProvinceAsync());
        (await client.PatchAsJsonAsync(Path($"/groups/{group}"), new UpdateGroupRequest(Province: 0), Ct)).EnsureSuccessStatusCode();
        Assert.Null(await ProvinceAsync());
    }

    [Fact]
    public async Task Events_carry_a_meeting_point_that_staff_can_remove()
    {
        var (owner, group) = await GroupAsync();
        var client = factory.ClientFor(owner);

        Assert.Equal(HttpStatusCode.BadRequest,
            (await client.PostAsJsonAsync(Path($"/groups/{group}/events"), Form(new MeetingPoint(95, 29)), Ct)).StatusCode);
        var created = await client.PostAsJsonAsync(Path($"/groups/{group}/events"), Form(new MeetingPoint(41.1801, 28.9862)), Ct);
        created.EnsureSuccessStatusCode();
        var ev = (await created.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
        Assert.Equal(41.1801, await _db.ScalarAsync<double>("select meeting_lat from public.events where id = @e", ("e", ev)));

        (await client.PutAsJsonAsync(Path($"/events/{ev}"), Form(new MeetingPoint(41.0, 29.0)), Ct)).EnsureSuccessStatusCode();
        Assert.Equal(29.0, await _db.ScalarAsync<double>("select meeting_lng from public.events where id = @e", ("e", ev)));

        var moderator = await _db.CreateUserAsync(Unique("m_"));
        await _db.MakeStaffAsync(moderator, "moderator");
        var staff = factory.ClientFor(moderator);
        Assert.Equal(HttpStatusCode.NoContent, (await staff.DeleteAsync(Path($"/admin/events/{ev}/meeting-point"), Ct)).StatusCode);
        Assert.True(await _db.ScalarAsync<bool>("select meeting_lat is null and meeting_lng is null from public.events where id = @e", ("e", ev)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'event.meeting_point_removed_by_admin' and target_id = @e", ("e", ev.ToString())));
        Assert.Equal(HttpStatusCode.NotFound, (await staff.DeleteAsync(Path($"/admin/events/{ev}/meeting-point"), Ct)).StatusCode);

        var page = await staff.GetFromJsonAsync<PagedResult<AdminEvent>>($"/admin/events?q={Uri.EscapeDataString("Belgrad")}", Ct);
        Assert.Contains(page!.Items, e => e.Id == ev && e.MeetingLat is null);
    }
}
