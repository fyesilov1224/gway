using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Events;
using Gway.Modules.Groups;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

/// <summary>Faz 18h: surprise events; the venue stays hidden until the reveal (docs/ARCHITECTURE.md §3d, Sürpriz organizasyon).</summary>
public sealed class SurpriseEventTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid Group, Guid Owner, Guid Member)> GroupAsync()
    {
        var (owner, member) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Sürpriz Kulübü", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        return (group, owner, member);
    }

    private static EventRequest Form(SurpriseRequest? surprise, string? link = null, RepeatRequest? repeat = null, DateTimeOffset? startsAt = null) =>
        new("Gizemli akşam yürüyüşü", "", startsAt ?? DateTimeOffset.UtcNow.AddDays(2), null, "Kadıköy, deniz kenarında", link,
            null, null, null, null, null, Meeting: new MeetingPoint(40.985, 29.026), Repeat: repeat, Surprise: surprise);

    private Task<HttpResponseMessage> CreateAsync(Guid actor, Guid group, EventRequest form) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path($"/groups/{group}/events"), form, Ct);

    [Fact]
    public async Task The_venue_and_its_point_stay_hidden_and_only_the_hint_is_public()
    {
        var (group, owner, _) = await GroupAsync();
        foreach (var invalid in new[]
                 {
                     Form(new SurpriseRequest(2, "Moda Sahnesi")),
                     Form(new SurpriseRequest(3, "M")),
                     Form(new SurpriseRequest(3, "Moda Sahnesi"), link: "https://maps.example/moda"),
                     Form(new SurpriseRequest(3, "Moda Sahnesi"), repeat: new RepeatRequest(1, null)),
                 })
            Assert.Equal(HttpStatusCode.BadRequest, (await CreateAsync(owner, group, invalid)).StatusCode);

        var response = await CreateAsync(owner, group, Form(new SurpriseRequest(3, " Moda Sahnesi ")));
        response.EnsureSuccessStatusCode();
        var ev = (await response.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;

        Assert.Equal(3, await _db.ScalarAsync<short>("select surprise_reveal_hours from public.events where id = @e", ("e", ev)));
        Assert.True(await _db.ScalarAsync<bool>("select meeting_lat is null from public.events where id = @e", ("e", ev)));
        Assert.Equal("Moda Sahnesi", await _db.ScalarAsync<string>("select location from public.event_venues where event_id = @e", ("e", ev)));
        Assert.Equal(40.985, await _db.ScalarAsync<double>("select meeting_lat from public.event_venues where event_id = @e", ("e", ev)));

        using var visitor = factory.CreateClient();
        var ics = await visitor.GetStringAsync(Path($"/events/{ev}/calendar.ics"), Ct);
        Assert.Contains("Sürpriz mekan: Kadıköy", ics, StringComparison.Ordinal);
        Assert.DoesNotContain("Moda", ics, StringComparison.Ordinal);

        var admin = await _db.CreateUserAsync(Unique("a_"));
        await _db.MakeStaffAsync(admin, "support");
        var page = await factory.ClientFor(admin).GetFromJsonAsync<PagedResult<AdminEvent>>(Path("/admin/events?status=upcoming&q=Gizemli"), Ct);
        var listed = Assert.Single(page!.Items, e => e.Id == ev);
        Assert.Equal(3, listed.SurpriseRevealHours);
        Assert.Equal("Moda Sahnesi", listed.SurpriseVenue);

        // Turning the surprise off makes the location public again and drops the hidden venue.
        var plain = Form(null) with { Location = "Moda Sahnesi" };
        (await factory.ClientFor(owner).PutAsJsonAsync(Path($"/events/{ev}"), plain, Ct)).EnsureSuccessStatusCode();
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.event_venues where event_id = @e", ("e", ev)));
        Assert.Equal(40.985, await _db.ScalarAsync<double>("select meeting_lat from public.events where id = @e", ("e", ev)));
    }

    [Fact]
    public async Task Those_going_are_told_when_the_venue_opens()
    {
        var (group, owner, member) = await GroupAsync();
        var response = await CreateAsync(owner, group, Form(new SurpriseRequest(1, "Moda Sahnesi"), startsAt: DateTimeOffset.UtcNow.AddMinutes(50)));
        response.EnsureSuccessStatusCode();
        var ev = (await response.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/events/{ev}/attendance"), null, Ct)).EnsureSuccessStatusCode();

        var events = factory.Services.GetRequiredService<EventService>();
        await events.SendRemindersAsync(Ct);
        await events.SendRemindersAsync(Ct);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'event_venue_revealed' and recipient_id = @m and event_id = @e",
            ("m", member), ("e", ev)));
        Assert.True(await _db.ScalarAsync<bool>("select venue_revealed_at is not null from public.events where id = @e", ("e", ev)));
    }
}
