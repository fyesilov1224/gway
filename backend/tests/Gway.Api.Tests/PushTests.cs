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
    public async Task The_sweep_drops_removed_and_long_unused_devices_without_ringing_the_live_ones()
    {
        var user = await _db.CreateUserAsync(Unique("p_"));
        var live = Unique("phone-in-use-") + "-token";
        var removed = FakePush.DeadPrefix + Unique("phone-removed-") + "-token";
        var unused = Unique("phone-unused-") + "-token";
        await RegisterAsync(user, live);
        await RegisterAsync(user, removed);
        await RegisterAsync(user, unused);
        await _db.ExecuteAsync("update public.push_devices set updated_at = now() - interval '61 days' where token = @t", ("t", unused));

        var sweep = factory.Services.GetRequiredService<PushService>();
        Assert.True(await sweep.SweepDevicesAsync(Ct) >= 2);

        Assert.Equal(1L, await _db.ScalarAsync<long>("select count(*) from public.push_devices where user_id = @id", ("id", user)));
        Assert.Equal(1L, await _db.ScalarAsync<long>("select count(*) from public.push_devices where token = @t", ("t", live)));
        Assert.Contains(removed, factory.Push.Probed);
        Assert.Empty(SentTo(live));
        Assert.NotNull(await _db.ScalarAsync<DateTime?>("select last_checked_at from public.push_devices where token = @t", ("t", live)));

        // Checked today: the next sweep leaves it alone.
        var probes = factory.Push.Probed.Count(t => t == live);
        await sweep.SweepDevicesAsync(Ct);
        Assert.Equal(probes, factory.Push.Probed.Count(t => t == live));
    }

    [Fact]
    public async Task A_chat_message_rings_the_other_members_phone_and_a_burst_is_one_push()
    {
        var (owner, member) = (await _db.CreateUserAsync(Unique("p_")), await _db.CreateUserAsync(Unique("p_")));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Sabah Koşucuları", "running", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        var chat = await _db.ScalarAsync<Guid>("select id from public.conversations where group_id = @g", ("g", group));
        var ownerPhone = Unique("phone-of-owner-") + "-token";
        var memberPhone = Unique("phone-of-member-") + "-token";
        await RegisterAsync(owner, ownerPhone);
        await RegisterAsync(member, memberPhone);

        foreach (var text in new[] { "Yarın 7'de parkta mıyız?", "Ben geliyorum" })
        {
            (await factory.ClientFor(member).PostAsJsonAsync(
                Path($"/conversations/{chat}/messages"), new Gway.Modules.Messaging.SendMessageRequest(text, null), Ct)).EnsureSuccessStatusCode();
        }
        await DispatchAsync();

        var push = Assert.Single(SentTo(ownerPhone));
        Assert.Equal("Sabah Koşucuları", push.Title);
        Assert.EndsWith(": Ben geliyorum", push.Body, StringComparison.Ordinal);
        Assert.Equal("message", push.Data["type"]);
        Assert.Equal(chat.ToString(), push.Data["conversation_id"]);
        Assert.Empty(SentTo(memberPhone));
    }

    [Fact]
    public async Task A_message_at_tonights_table_rings_the_others_at_the_table()
    {
        var people = new List<Guid>();
        for (var i = 0; i < 3; i++) people.Add(await _db.CreateUserAsync(Unique("t_")));
        var table = await _db.ScalarAsync<Guid>(
            "insert into public.tonight_tables (created_by, evening, closes_at) values (@a, current_date, now() + interval '3 hours') returning id",
            ("a", people[0]));
        foreach (var person in people)
        {
            await _db.ExecuteAsync(
                "insert into public.tonight_table_invites (table_id, user_id, evening, state) values (@t, @u, current_date, 'accepted')",
                ("t", table), ("u", person));
        }
        var chat = await _db.ScalarAsync<Guid>("select id from public.conversations where table_id = @t", ("t", table));
        var phones = new List<string>();
        foreach (var person in people)
        {
            phones.Add(Unique("phone-at-table-") + "-token");
            await RegisterAsync(person, phones[^1]);
        }

        (await factory.ClientFor(people[1]).PostAsJsonAsync(
            Path($"/conversations/{chat}/messages"), new Gway.Modules.Messaging.SendMessageRequest("8'de kafede miyiz?", null), Ct)).EnsureSuccessStatusCode();
        await DispatchAsync();

        var push = Assert.Single(SentTo(phones[0]));
        Assert.Equal("Bu akşamın masası", push.Title);
        Assert.EndsWith(": 8'de kafede miyiz?", push.Body, StringComparison.Ordinal);
        Assert.Equal(chat.ToString(), push.Data["conversation_id"]);
        Assert.Single(SentTo(phones[2]));
        Assert.Empty(SentTo(phones[1]));
    }

    [Fact]
    public void Message_pushes_show_the_group_and_skip_deleted_messages()
    {
        var conversation = Guid.NewGuid();
        PendingPush Message(string? text, bool photo = false, string? group = null) => new(
            1, Guid.NewGuid(), "message", DateTimeOffset.UtcNow, "ayse", null, null, null, null, null, null, null, null, null,
            conversation, text, photo, group);

        var direct = PushTexts.For(Message("Selam!"))!;
        Assert.Equal(("ayse", "Selam!"), (direct.Title, direct.Body));
        var inGroup = PushTexts.For(Message("Selam!", group: "Doğa Yürüyüşü"))!;
        Assert.Equal(("Doğa Yürüyüşü", "ayse: Selam!"), (inGroup.Title, inGroup.Body));
        Assert.Equal("📷 Fotoğraf", PushTexts.For(Message(null, photo: true))!.Body);
        Assert.Null(PushTexts.For(Message(null)));
    }

    [Fact]
    public void Times_are_shown_in_Turkey()
    {
        Assert.Equal("27 Ekim 2026, 20:00", PushTexts.DateTimeTr(new DateTimeOffset(2026, 10, 27, 17, 0, 0, TimeSpan.Zero)));
    }
}
