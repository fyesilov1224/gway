using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Live;
using Gway.Modules.Live.Contracts;
using Gway.Modules.Notifications;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

/// <summary>Voice calls between matched people with permission (docs/ARCHITECTURE.md §8c).</summary>
public sealed class CallTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>Two matched people with a direct chat and the Eşleşme Sohbeti package; no call permission yet.</summary>
    private async Task<(Guid A, Guid B, Guid Chat)> MatchedPairAsync()
    {
        var (a, b) = (await _db.CreateUserAsync(Unique("c_")), await _db.CreateUserAsync(Unique("c_")));
        var (low, high) = a.CompareTo(b) < 0 ? (a, b) : (b, a);
        await _db.ExecuteAsync("insert into public.matches (user_a, user_b, mode) values (@a, @b, 'friend')", ("a", low), ("b", high));
        var chat = await _db.ScalarAsync<Guid>(
            "insert into public.conversations (kind, user_a, user_b, created_by) values ('direct', @a, @b, @a) returning id", ("a", low), ("b", high));
        await _db.ExecuteAsync(
            "insert into public.conversation_members (conversation_id, user_id, state) values (@c, @a, 'active'), (@c, @b, 'active')",
            ("c", chat), ("a", a), ("b", b));
        await _db.ExecuteAsync(
            """
            alter table public.user_subscriptions disable trigger user_subscriptions_guard;
            insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at)
            select u, 'matching_chat', 'test', now() - interval '1 minute', now() + interval '1 day' from unnest(array[@a, @b]) u;
            alter table public.user_subscriptions enable trigger user_subscriptions_guard;
            """, ("a", a), ("b", b));
        return (a, b, chat);
    }

    private async Task<Guid> StaffAsync(string role)
    {
        var staff = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(staff, role);
        return staff;
    }

    private Task<HttpResponseMessage> SetPermissionAsync(Guid staff, Guid user, bool active, string? reason = null) =>
        factory.ClientFor(staff).PutAsJsonAsync(Path($"/admin/calls/permissions/{user}"), new CallPermissionRequest(active, reason), Ct);

    [Fact]
    public async Task A_person_asks_the_team_opens_it_and_matched_people_call_each_other()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var admin = await StaffAsync("admin");

        // Without permission the chat explains why there is no call button.
        var before = await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct);
        Assert.False(before!.Allowed);
        Assert.Equal("call.no_permission", before.Code);

        // a asks and the request waits in the panel; a moderator sees it but cannot decide.
        await _db.ExecuteAsync("select set_config('request.jwt.claims', json_build_object('sub', @a::text)::text, true); select public.request_call_permission('Lütfen')",
            ("a", a));
        var requests = await factory.ClientFor(admin).GetFromJsonAsync<CallPermissionsPage>(Path("/admin/calls/permissions"), Ct);
        Assert.Contains(requests!.Items, p => p.UserId == a && p.Note == "Lütfen");
        var moderator = await StaffAsync("moderator");
        Assert.Equal(HttpStatusCode.Forbidden, (await SetPermissionAsync(moderator, a, true)).StatusCode);

        (await SetPermissionAsync(admin, a, true)).EnsureSuccessStatusCode();
        var peerMissing = await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct);
        Assert.Equal("call.peer_no_permission", peerMissing!.Code);
        (await SetPermissionAsync(admin, b, true)).EnsureSuccessStatusCode();
        Assert.True((await factory.ClientFor(a).GetFromJsonAsync<CallEligibility>(Path($"/conversations/{chat}/calls/eligibility"), Ct))!.Allowed);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'call_permission.granted' and target_id = @u", ("u", a.ToString())));

        // a calls: a room opens, b's phone rings with a push naming a.
        var started = await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct);
        started.EnsureSuccessStatusCode();
        var call = (await started.Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        Assert.True(factory.LiveKit.HasRoom($"call-{call.CallId}"));
        Assert.StartsWith($"token:call-{call.CallId}:{a}", call.Token, StringComparison.Ordinal);

        var phone = Unique("phone-of-b-") + "-token";
        await _db.ExecuteAsync("insert into public.push_devices (token, user_id, platform) values (@t, @u, 'android')", ("t", phone), ("u", b));
        await factory.Services.GetRequiredService<PushService>().DispatchAsync(Ct);
        var ring = Assert.Single(factory.Push.Sent, s => s.Token == phone).Message;
        Assert.Equal("call_incoming", ring.Data["type"]);
        Assert.Equal(call.CallId.ToString(), ring.Data["call_id"]);
        Assert.Equal("gway_calls", ring.Channel);

        // A second call while this one rings is refused.
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(b).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).StatusCode);

        // b answers, then hangs up: the room closes.
        var answered = await factory.ClientFor(b).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct);
        answered.EnsureSuccessStatusCode();
        Assert.Equal("active", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
        (await factory.ClientFor(b).PostAsync(Path($"/calls/{call.CallId}/end"), null, Ct)).EnsureSuccessStatusCode();
        Assert.Equal("ended", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
        Assert.False(factory.LiveKit.HasRoom($"call-{call.CallId}"));

        // The panel shows the call on the person's page.
        var detail = await factory.ClientFor(admin).GetFromJsonAsync<CallUserDetail>(Path($"/admin/calls/users/{a}"), Ct);
        Assert.Equal("active", detail!.Permission!.Status);
        Assert.Contains(detail.Calls, c => c.Id == call.CallId && c.Outgoing && c.Status == "ended");
    }

    [Fact]
    public async Task An_unanswered_call_is_missed_and_closing_the_permission_ends_a_call()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var support = await StaffAsync("support");
        (await SetPermissionAsync(support, a, true)).EnsureSuccessStatusCode();
        (await SetPermissionAsync(support, b, true)).EnsureSuccessStatusCode();
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
        Assert.Equal(HttpStatusCode.BadRequest, (await SetPermissionAsync(support, a, false)).StatusCode);
        (await SetPermissionAsync(support, a, false, "Şikayet incelemesi")).EnsureSuccessStatusCode();
        Assert.Equal("not_allowed", await _db.ScalarAsync<string>("select end_reason from public.calls where id = @id", ("id", second.CallId)));
        Assert.Equal("revoked", await _db.ScalarAsync<string>("select status from public.call_permissions where user_id = @a", ("a", a)));
        var after = await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, after.StatusCode);
    }

    [Fact]
    public async Task Strangers_cannot_answer_or_end_someone_elses_call()
    {
        var (a, b, chat) = await MatchedPairAsync();
        var admin = await StaffAsync("admin");
        (await SetPermissionAsync(admin, a, true)).EnsureSuccessStatusCode();
        (await SetPermissionAsync(admin, b, true)).EnsureSuccessStatusCode();
        var stranger = await _db.CreateUserAsync(Unique("x_"));

        var call = (await (await factory.ClientFor(a).PostAsync(Path($"/conversations/{chat}/calls"), null, Ct)).Content.ReadFromJsonAsync<CallJoin>(Ct))!;
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(stranger).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(stranger).PostAsync(Path($"/calls/{call.CallId}/end"), null, Ct)).StatusCode);
        // The caller cannot answer their own call.
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(a).PostAsync(Path($"/calls/{call.CallId}/accept"), null, Ct)).StatusCode);
        Assert.Equal("ringing", await _db.ScalarAsync<string>("select status from public.calls where id = @id", ("id", call.CallId)));
    }
}
