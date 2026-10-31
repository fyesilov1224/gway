using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Groups;
using Gway.Modules.Live;
using Gway.Modules.Notifications;
using Gway.Modules.Notifications.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

public sealed class PushTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<int> DispatchAsync() => factory.Services.GetRequiredService<PushService>().DispatchAsync(Ct);

    private Task RegisterAsync(Guid user, string token) =>
        _db.ExecuteAsync("insert into public.push_devices (token, user_id, platform) values (@token, @user, 'android')",
            ("token", token), ("user", user));

    private IEnumerable<PushMessage> SentTo(string token) => factory.Push.Sent.Where(s => s.Token == token).Select(s => s.Message);

    [Fact]
    public async Task A_scheduled_broadcast_rings_the_members_phones_once()
    {
        var (owner, member) = (await _db.CreateUserAsync(Unique("p_")), await _db.CreateUserAsync(Unique("p_")));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Akustik Geceler", "music", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        var phone = Unique("phone-of-member-") + "-token";
        await RegisterAsync(member, phone);

        var scheduled = await factory.ClientFor(owner).PostAsJsonAsync(
            Path($"/groups/{group}/live"), new StartLiveRequest("Pazar konseri", DateTimeOffset.UtcNow.AddDays(1)), Ct);
        scheduled.EnsureSuccessStatusCode();
        var live = (await scheduled.Content.ReadFromJsonAsync<LiveCreated>(Ct))!.Id;

        await DispatchAsync();
        var message = Assert.Single(SentTo(phone));
        Assert.Equal(await _db.ScalarAsync<string>("select username from public.profiles where id = @id", ("id", owner)), message.Title);
        Assert.EndsWith("için canlı yayın planladı: Pazar konseri", message.Body, StringComparison.Ordinal);
        Assert.Equal("live_scheduled", message.Data["type"]);
        Assert.Equal(live.ToString(), message.Data["live_id"]);

        await DispatchAsync();
        Assert.Single(SentTo(phone));
        Assert.Equal(0L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @id and pushed_at is null", ("id", member)));
        Assert.Equal(1, await _db.ScalarAsync<int>(
            "select push_deliveries from public.notifications where recipient_id = @id and type = 'live_scheduled'", ("id", member)));

        // The platform team sees the broadcast with the members it was announced to, and the push counts.
        var support = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(support, "support");
        var scheduledPage = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminBroadcast>>(Path("/admin/live?status=scheduled"), Ct);
        var row = Assert.Single(scheduledPage!.Items, b => b.Id == live);
        Assert.Equal(1, row.Notified);
        Assert.NotNull(row.ScheduledAt);

        var stats = await factory.ClientFor(support).GetFromJsonAsync<PushStats>(Path("/admin/notifications/stats"), Ct);
        Assert.True(stats!.Configured);
        Assert.True(stats.AndroidDevices >= 1);
        Assert.True(stats.Deliveries24h >= 1);
        Assert.Contains(stats.ByType24h, t => t.Type == "live_scheduled");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(member).GetAsync(Path("/admin/notifications/stats"), Ct)).StatusCode);
    }

    [Fact]
    public async Task A_removed_app_loses_its_token_and_old_notifications_are_not_pushed()
    {
        var (fan, star) = (await _db.CreateUserAsync(Unique("p_")), await _db.CreateUserAsync(Unique("p_")));
        var dead = FakePush.DeadPrefix + Unique("phone-of-star-") + "-token";
        await RegisterAsync(star, dead);

        (await factory.ClientFor(fan).PostAsync(Path($"/users/{star}/follow"), null, Ct)).EnsureSuccessStatusCode();
        await DispatchAsync();
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.push_devices where token = @t", ("t", dead)));

        var phone = Unique("phone-of-star-") + "-token";
        await RegisterAsync(star, phone);
        (await factory.ClientFor(fan).DeleteAsync(Path($"/users/{star}/follow"), Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(fan).PostAsync(Path($"/users/{star}/follow"), null, Ct)).EnsureSuccessStatusCode();
        await _db.ExecuteAsync(
            "update public.notifications set created_at = now() - interval '1 hour' where recipient_id = @id", ("id", star));
        await DispatchAsync();
        Assert.Empty(SentTo(phone));
    }

    [Fact]
    public void Times_are_shown_in_Turkey()
    {
        Assert.Equal("27 Ekim 2026, 20:00", PushTexts.DateTimeTr(new DateTimeOffset(2026, 10, 27, 17, 0, 0, TimeSpan.Zero)));
    }
}
