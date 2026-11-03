using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Groups;
using Gway.Modules.Live;
using Gway.Modules.Notifications;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

/// <summary>Voice calls between matched people or teammates with permission from a group (docs/ARCHITECTURE.md §8c).</summary>
public sealed class CallTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>Two matched people with a direct chat and the Eşleşme Sohbeti package; no call permission yet.</summary>
    private Task<(Guid A, Guid B, Guid Chat)> MatchedPairAsync() =>
        PairAsync("insert into public.matches (user_a, user_b, mode) values (@a, @b, 'friend')", "matching_chat");

    /// <summary>A direct chat between two people related by <paramref name="relation"/> (null: none), both with <paramref name="plan"/>.</summary>
    private async Task<(Guid A, Guid B, Guid Chat)> PairAsync(string? relation, string plan)
    {
        var (a, b) = (await _db.CreateUserAsync(Unique("c_")), await _db.CreateUserAsync(Unique("c_")));
        var (low, high) = a.CompareTo(b) < 0 ? (a, b) : (b, a);
        if (relation is not null) await _db.ExecuteAsync(relation, ("a", low), ("b", high));
        var chat = await _db.ScalarAsync<Guid>(
            "insert into public.conversations (kind, user_a, user_b, created_by) values ('direct', @a, @b, @a) returning id", ("a", low), ("b", high));
        await _db.ExecuteAsync(
            "insert into public.conversation_members (conversation_id, user_id, state) values (@c, @a, 'active'), (@c, @b, 'active')",
            ("c", chat), ("a", a), ("b", b));
        await _db.ExecuteAsync(
            """
            alter table public.user_subscriptions disable trigger user_subscriptions_guard;
            insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
            select u, @plan, 'test', now() - interval '1 minute', now() + interval '1 day' from unnest(array[@a, @b]) u;
            alter table public.user_subscriptions enable trigger user_subscriptions_guard;
            """, ("a", a), ("b", b), ("plan", plan));
        return (a, b, chat);
    }

    /// <summary>A group whose owner decides the call requests of its members.</summary>
    private async Task<(Guid Group, Guid Owner)> GroupAsync()
    {
        var owner = await _db.CreateUserAsync(Unique("o_"));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Arama Kulübü", "running", "open", null), Ct);
        created.EnsureSuccessStatusCode();
        return ((await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id, owner);
    }

    /// <summary>The person joins the group and asks it for voice calls (their own write through Supabase).</summary>
    private async Task AskAsync((Guid Group, Guid Owner) group, Guid user, string? note = null)
    {
        (await factory.ClientFor(user).PostAsync(Path($"/groups/{group.Group}/join"), null, Ct)).EnsureSuccessStatusCode();
        // The first group's welcome trial (0050) would open every package; the package rules are tested without it.
        await _db.ExecuteAsync(
            """
            alter table public.user_subscriptions disable trigger user_subscriptions_guard;
            delete from public.user_subscriptions where user_id = @u and welcome_trial;
            alter table public.user_subscriptions enable trigger user_subscriptions_guard;
            """, ("u", user));
        await _db.ExecuteAsync(
            "select set_config('request.jwt.claims', json_build_object('sub', @u::text)::text, true); select public.request_call_permission(@g, @n)",
            ("u", user), ("g", group.Group), ("n", (object?)note ?? DBNull.Value));
    }

    private Task<HttpResponseMessage> SetPermissionAsync((Guid Group, Guid Owner) group, Guid by, Guid user, bool active, string? reason = null) =>
        factory.ClientFor(by).PutAsJsonAsync(Path($"/groups/{group.Group}/call-permissions/{user}"), new GroupCallPermissionRequest(active, reason), Ct);

    /// <summary>Asks and has the owner open it.</summary>
    private async Task GrantAsync((Guid Group, Guid Owner) group, Guid user)
    {
        await AskAsync(group, user);
        (await SetPermissionAsync(group, group.Owner, user, true)).EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task A_person_asks_a_group_its_owner_opens_it_and_matched_people_call_each_other()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var group = await GroupAsync();

        // Without permission the chat explains why there is no call button.
        var before = await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct);
        Assert.False(before!.Allowed);
        Assert.Equal("call.no_permission", before.Code);

        // a asks the group; a plain member cannot decide, nor can a decide their own request, nor can the platform team.
        await AskAsync(group, a, "Lütfen");
        Assert.Equal(HttpStatusCode.Forbidden, (await SetPermissionAsync(group, b, a, true)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await SetPermissionAsync(group, a, a, true)).StatusCode);
        var staff = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(staff, "admin");
        Assert.Equal(HttpStatusCode.Forbidden, (await SetPermissionAsync(group, staff, a, true)).StatusCode);

        (await SetPermissionAsync(group, group.Owner, a, true)).EnsureSuccessStatusCode();
        var peerMissing = await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct);
        Assert.Equal("call.peer_no_permission", peerMissing!.Code);
        await GrantAsync(group, b);
        Assert.True((await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct))!.Allowed);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'call_permission.granted' and target_id = @u and group_id = @g",
            ("u", a.ToString()), ("g", group.Group)));

        // a calls: a room opens, b's phone rings with a push naming a.
        var started = await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct);
        started.EnsureSuccessStatusCode();
        var call = (await started.Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        Assert.True(factory.LiveKit.HasRoom($"call-{call.CallId}"));
        Assert.StartsWith($"token:call-{call.CallId}:{a}", call.Token, StringComparison.Ordinal);

        var phone = Unique("phone-of-b-") + "-token";
        await _db.ExecuteAsync("insert into public.push_devices (token, user_id, platform) values (@t, @u, 'android')", ("t", phone), ("u", b));
        await factory.Services.GetRequiredService<PushService>().DispatchAsync(Ct);
        // Earlier notices (the match, the opened permission) go out in the same round; the ring is one push.
        var ring = Assert.Single(factory.Push.Sent,
            s => s.Token == phone && s.Message.Data.TryGetValue("type", out var type) && type == "call_incoming").Message;
        Assert.Equal("call_incoming", ring.Data["type"]);
        Assert.Equal(call.CallId.ToString(), ring.Data["call_id"]);
        Assert.Equal("gway_calls", ring.Channel);
        // Android opens the phone's own incoming call screen from a data-only push that is useless after the ring.
        Assert.Equal(TimeSpan.FromSeconds(30), ring.AppHandlesFor);

        // A second call while this one rings is refused.
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(b).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).StatusCode);

        // b answers, then hangs up: the room closes.
        var answered = await factory.ClientFor(b).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct);
        answered.EnsureSuccessStatusCode();
        Assert.Equal("active", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
        // The ring went out, so the phone hears that it stopped ringing (and closes its call screen).
        await factory.Services.GetRequiredService<PushService>().DispatchAsync(Ct);
        var stop = Assert.Single(factory.Push.Sent,
            s => s.Token == phone && s.Message.Data.TryGetValue("type", out var type) && type == "call_ended").Message;
        Assert.Equal(call.CallId.ToString(), stop.Data["call_id"]);
        Assert.True(stop.Silent);
        (await factory.ClientFor(b).PostAsync(Path($"/calls/{call.CallId}/end"), null, Ct)).EnsureSuccessStatusCode();
        Assert.Equal("ended", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
        Assert.False(factory.LiveKit.HasRoom($"call-{call.CallId}"));

        // Leaving the group that gave it closes the permission.
        (await factory.ClientFor(a).DeleteAsync(Path($"/groups/{group.Group}/membership"), Ct)).EnsureSuccessStatusCode();
        Assert.Equal("revoked", await _db.ScalarAsync<string>("select status from public.call_permissions where user_id = @a", ("a", a)));
        Assert.Equal("call.no_permission",
            (await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct))!.Code);
    }

    [Fact]
    public async Task An_unanswered_call_is_missed_and_closing_the_permission_ends_a_call()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var group = await GroupAsync();
        await GrantAsync(group, a);
        await GrantAsync(group, b);
        var calls = factory.Services.GetRequiredService<CallService>();

        var first = (await (await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        await _db.ExecuteAsync("update public.calls set created_at = now() - interval '31 seconds' where id = @id", ("id", first.CallId));
        await calls.SuperviseAsync(Ct);
        Assert.Equal("missed", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", first.CallId)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where call_id = @id and type = 'call_missed' and recipient_id = @b", ("id", first.CallId), ("b", b)));

        var second = (await (await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        (await factory.ClientFor(b).PostAsync(Path($"/calls/{second.CallId}/accept"), null, Ct)).EnsureSuccessStatusCode();

        // Closing needs a reason; then the call ends at once and a can no longer call.
        Assert.Equal(HttpStatusCode.BadRequest, (await SetPermissionAsync(group, group.Owner, a, false)).StatusCode);
        (await SetPermissionAsync(group, group.Owner, a, false, "Şikayet incelemesi")).EnsureSuccessStatusCode();
        Assert.Equal("not_allowed", await _db.ScalarAsync<string>("select end_reason from public.calls where id = @id", ("id", second.CallId)));
        Assert.Equal("revoked", await _db.ScalarAsync<string>("select status from public.call_permissions where user_id = @a", ("a", a)));
        var after = await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, after.StatusCode);
    }

    [Fact]
    public async Task Teammates_call_with_the_teammates_package_and_others_are_told_why_not()
    {
        var group = await GroupAsync();
        async Task<CallEligibility> EligibilityAsync(Guid user, Guid chat) =>
            (await factory.ClientFor(user).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct))!;

        // Teammates, not matched: the Eşleşme Sohbeti package is not what opens it.
        var (a, b, chat) = await PairAsync("alter table public.teammates disable trigger teammates_guard; insert into public.teammates (user_a, user_b) values (@a, @b); alter table public.teammates enable trigger teammates_guard", "matching_chat");
        await GrantAsync(group, a);
        await GrantAsync(group, b);
        Assert.Equal("call.teammate_locked", (await EligibilityAsync(a, chat)).Code);

        var (c, d, teamChat) = await PairAsync("alter table public.teammates disable trigger teammates_guard; insert into public.teammates (user_a, user_b) values (@a, @b); alter table public.teammates enable trigger teammates_guard", "matching_teammates");
        await GrantAsync(group, c);
        await GrantAsync(group, d);
        Assert.True((await EligibilityAsync(c, teamChat)).Allowed);
        var started = await factory.ClientFor(c).PostAsync(Path($"/conversations/{teamChat}/calls"), null, Ct);
        started.EnsureSuccessStatusCode();
        var call = (await started.Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        (await factory.ClientFor(d).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct)).EnsureSuccessStatusCode();

        // Neither matched nor teammates: the button stays, dim, with the sentence why.
        var (e, f, strangers) = await PairAsync(null, "matching_premium");
        await GrantAsync(group, e);
        await GrantAsync(group, f);
        var none = await EligibilityAsync(e, strangers);
        Assert.Equal("call.not_matched", none.Code);
        Assert.Equal("Sesli görüşme yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla yapılabilir.", none.Message);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(e).PostAsync(Path($"/conversations/{strangers}/calls"), null, Ct)).StatusCode);
    }

    [Fact]
    public async Task Strangers_cannot_answer_or_end_someone_elses_call()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var group = await GroupAsync();
        await GrantAsync(group, a);
        await GrantAsync(group, b);
        var stranger
 = await _db.CreateUserAsync(Unique("x_"));

        var call = (await (await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(stranger).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(stranger).PostAsync(Path($"/calls/{call.CallId}/end"), null, Ct)).StatusCode);
        // The caller cannot answer their own call.
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(a).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct)).StatusCode);
        Assert.Equal("ringing", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
    }
}
