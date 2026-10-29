using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Events;
using GrupX.Modules.Groups;

namespace GrupX.Api.Tests;

public sealed class EventSeriesTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>An owner and a member of a fresh group on the free plan (two events a month).</summary>
    private async Task<(Guid Group, Guid Owner, Guid Member)> GroupAsync()
    {
        var (owner, member) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Salı Koşucuları", "running", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        return (group, owner, member);
    }

    private static EventRequest Form(RepeatRequest? repeat) =>
        new("Salı akşamı koşusu", "", DateTimeOffset.UtcNow.AddDays(1), DateTimeOffset.UtcNow.AddDays(1).AddHours(1), "Moda sahili",
            null, 30, null, null, null, null, Repeat: repeat);

    private Task<HttpResponseMessage> CreateAsync(Guid actor, Guid group, EventRequest form) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path($"/groups/{group}/events"), form, Ct);

    private Task<Guid> SeriesOfAsync(Guid group) =>
        _db.ScalarAsync<Guid>("select id from public.event_series where group_id = @g", ("g", group));

    [Fact]
    public async Task A_weekly_event_opens_its_next_dates_within_the_monthly_limit()
    {
        var (group, owner, _) = await GroupAsync();

        Assert.Equal(HttpStatusCode.BadRequest, (await CreateAsync(owner, group, Form(new RepeatRequest(3, null)))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await CreateAsync(owner, group, Form(new RepeatRequest(1, DateOnly.FromDateTime(DateTime.UtcNow))))).StatusCode);

        (await CreateAsync(owner, group, Form(new RepeatRequest(1, null)))).EnsureSuccessStatusCode();
        var series = await SeriesOfAsync(group);

        // The free plan has two events a month: the first date and one more open, then the owner is told.
        Assert.Equal(2L, await _db.ScalarAsync<long>("select count(*) from public.events where series_id = @s", ("s", series)));
        Assert.Equal(7.0, await _db.ScalarAsync<double>(
            "select (extract(epoch from max(starts_at) - min(starts_at)) / 86400)::float8 from public.events where series_id = @s", ("s", series)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'event_series_limit' and recipient_id = @o", ("o", owner)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'event_series.created' and group_id = @g", ("g", group)));
    }

    [Fact]
    public async Task Managers_and_staff_stop_a_series_and_its_open_dates_stay()
    {
        var (group, owner, member) = await GroupAsync();
        (await CreateAsync(owner, group, Form(new RepeatRequest(2, null)))).EnsureSuccessStatusCode();
        var series = await SeriesOfAsync(group);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(member).DeleteAsync(Path($"/event-series/{series}"), Ct)).StatusCode);
        (await factory.ClientFor(owner).DeleteAsync(Path($"/event-series/{series}"), Ct)).EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(owner).DeleteAsync(Path($"/event-series/{series}"), Ct)).StatusCode);
        Assert.Equal(2L, await _db.ScalarAsync<long>(
            "select count(*) from public.events where series_id = @s and canceled_at is null", ("s", series)));

        var (other, otherOwner, _) = await GroupAsync();
        (await CreateAsync(otherOwner, other, Form(new RepeatRequest(1, null)))).EnsureSuccessStatusCode();
        var otherSeries = await SeriesOfAsync(other);
        var moderator = await _db.CreateUserAsync(Unique("m_"));
        await _db.MakeStaffAsync(moderator, "moderator");

        var events = await factory.ClientFor(moderator).GetFromJsonAsync<PagedResult<AdminEvent>>("/admin/events?status=upcoming", Ct);
        Assert.Contains(events!.Items, e => e.SeriesId == otherSeries && e.SeriesWeeks == 1 && e.SeriesActive);
        (await factory.ClientFor(moderator).PostAsync(Path($"/admin/event-series/{otherSeries}/stop"), null, Ct)).EnsureSuccessStatusCode();
        Assert.Equal("staff", await _db.ScalarAsync<string>(
            "select actor_kind from public.audit_log where action = 'event_series.stopped' and target_id = @s", ("s", otherSeries.ToString())));
    }
}
