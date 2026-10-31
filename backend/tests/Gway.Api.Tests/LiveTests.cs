using System.Net;
using System.Net.Http.Json;
using System.Text;
using Gway.Modules.Admin;
using Gway.Modules.Groups;
using Gway.Modules.Live;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace Gway.Api.Tests;

/// <summary>Not parallel with <see cref="ModerationTests"/>: the monitor runs here end every live broadcast whose room this fake LiveKit lacks, theirs too.</summary>
[Collection("Live rooms")]
public sealed class LiveTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private FakeLiveKit LiveKit => factory.LiveKit;

    /// <summary>Owner, Yönetici, Moderatör and a plain member of a fresh open group.</summary>
    private sealed record Crew(Guid Group, Guid Owner, Guid Admin, Guid Moderator, Guid Member);

    private async Task<Crew> CrewAsync()
    {
        var (owner, admin, moderator, member) = (await User(), await User(), await User(), await User());
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Akustik Geceler", "music", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        foreach (var user in new[] { admin, moderator, member })
            (await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(owner).PutAsync(Path($"/groups/{group}/members/{admin}/roles/admin"), null, Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(owner).PutAsync(Path($"/groups/{group}/members/{moderator}/roles/moderator"), null, Ct)).EnsureSuccessStatusCode();
        return new Crew(group, owner, admin, moderator, member);

        Task<Guid> User() => _db.CreateUserAsync(Unique("l_"));
    }

    private async Task<Guid> GoLiveAsync(Guid host, Guid group, string title = "Akşam sohbeti")
    {
        var response = await factory.ClientFor(host).PostAsJsonAsync(Path($"/groups/{group}/live"), new StartLiveRequest(title, null), Ct);
        response.EnsureSuccessStatusCode();
        var created = (await response.Content.ReadFromJsonAsync<LiveCreated>(Ct))!;
        LiveKit.Join(created.Id, host, "host");
        return created.Id;
    }

    private Task<HttpResponseMessage> Put(Guid actor, string path) => factory.ClientFor(actor).PutAsync(Path(path), null, Ct);

    private Task<HttpResponseMessage> Delete(Guid actor, string path) => factory.ClientFor(actor).DeleteAsync(Path(path), Ct);

    private Task<HttpResponseMessage> Post(Guid actor, string path) => factory.ClientFor(actor).PostAsync(Path(path), null, Ct);

    private Task<string> StatusOf(Guid broadcast) =>
        _db.ScalarAsync<string>("select status || coalesce(':' || end_reason, '') from public.live_broadcasts where id = @id", ("id", broadcast))!;

    private Task<long> AuditCountAsync(string action, Guid group) =>
        _db.ScalarAsync<long>("select count(*) from public.audit_log where action = @a and group_id = @g", ("a", action), ("g", group));

    // Starting and joining ----------------------------------------------------------------

    [Fact]
    public async Task Owners_and_admins_start_one_broadcast_at_a_time_and_open_its_room()
    {
        var crew = await CrewAsync();

        var denied = await factory.ClientFor(crew.Member).PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Üye yayını", null), Ct);
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);

        var live = await GoLiveAsync(crew.Admin, crew.Group);
        Assert.True(LiveKit.HasRoom(live));
        Assert.Equal("live", await StatusOf(live));
        Assert.Equal(1L, await AuditCountAsync("live.started", crew.Group));

        var second = await factory.ClientFor(crew.Owner).PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("İkinci", null), Ct);
        Assert.Equal(HttpStatusCode.Conflict, second.StatusCode);

        var shortTitle = await factory.ClientFor(crew.Owner).PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("A", null), Ct);
        Assert.Equal(HttpStatusCode.BadRequest, shortTitle.StatusCode);
    }

    [Fact]
    public async Task Members_get_a_listener_token_outsiders_learn_nothing()
    {
        var crew = await CrewAsync();
        var outsider = await _db.CreateUserAsync(Unique("o_"));
        var live = await GoLiveAsync(crew.Admin, crew.Group);

        var join = await (await Post(crew.Member, $"/live/{live}/token")).Content.ReadFromJsonAsync<LiveJoin>(Ct);
        Assert.Equal("listener", join!.Role);
        Assert.Equal("wss://livekit.test", join.Url);
        Assert.Equal($"token:{live}:{crew.Member}:False:listener", join.Token);

        var host = await (await Post(crew.Admin, $"/live/{live}/token")).Content.ReadFromJsonAsync<LiveJoin>(Ct);
        Assert.Equal("host", host!.Role);
        Assert.Contains(":True:host", host.Token, StringComparison.Ordinal);

        Assert.Equal(HttpStatusCode.NotFound, (await Post(outsider, $"/live/{live}/token")).StatusCode);
    }

    [Fact]
    public async Task Without_LiveKit_broadcasts_are_unavailable()
    {
        var crew = await CrewAsync();
        using var unconfigured = factory.WithWebHostBuilder(b => b.UseSetting("LiveKit:ApiKey", ""));
        var client = unconfigured.CreateClient();
        client.DefaultRequestHeaders.Authorization = new("Bearer", ApiFactory.CreateToken(crew.Owner));

        var response = await client.PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Konser", null), Ct);

        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    [Fact]
    public async Task A_failing_LiveKit_rolls_the_start_back()
    {
        var crew = await CrewAsync();
        LiveKit.Fail = true;
        try
        {
            var response = await factory.ClientFor(crew.Owner).PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Konser", null), Ct);
            Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        }
        finally
        {
            LiveKit.Fail = false;
        }
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.live_broadcasts where group_id = @g", ("g", crew.Group)));
    }

    // Stage and moderation ------------------------------------------------------------------

    [Fact]
    public async Task Hands_go_up_and_managers_bring_people_on_stage()
    {
        var crew = await CrewAsync();
        var live = await GoLiveAsync(crew.Admin, crew.Group);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await Put(crew.Member, $"/live/{live}/hand")).StatusCode);
        LiveKit.Join(live, crew.Member);
        LiveKit.Join(live, crew.Moderator);
        Assert.Equal(HttpStatusCode.NoContent, (await Put(crew.Member, $"/live/{live}/hand")).StatusCode);
        Assert.True(LiveKit.Find(live, crew.Member)!.Attributes.ContainsKey("hand"));

        Assert.Equal(HttpStatusCode.Forbidden, (await Put(crew.Member, $"/live/{live}/speakers/{crew.Moderator}")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Put(crew.Moderator, $"/live/{live}/speakers/{crew.Member}")).StatusCode);
        var speaker = LiveKit.Find(live, crew.Member)!;
        Assert.True(speaker.CanPublish);
        Assert.Equal("speaker", speaker.Attributes["role"]);
        Assert.False(speaker.Attributes.ContainsKey("hand"));

        Assert.Equal(HttpStatusCode.NoContent, (await Delete(crew.Member, $"/live/{live}/speakers/{crew.Member}")).StatusCode);
        Assert.False(LiveKit.Find(live, crew.Member)!.CanPublish);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await Delete(crew.Owner, $"/live/{live}/speakers/{crew.Admin}")).StatusCode);
    }

    [Fact]
    public async Task Mute_and_kick_follow_the_rank_rule_and_kicked_people_cannot_return()
    {
        var crew = await CrewAsync();
        var live = await GoLiveAsync(crew.Admin, crew.Group);
        LiveKit.Join(live, crew.Member);
        Assert.Equal(HttpStatusCode.NoContent, (await Put(crew.Admin, $"/live/{live}/speakers/{crew.Member}")).StatusCode);

        Assert.Equal(HttpStatusCode.Forbidden, (await Put(crew.Moderator, $"/live/{live}/muted/{crew.Admin}")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Put(crew.Moderator, $"/live/{live}/muted/{crew.Member}")).StatusCode);
        var muted = LiveKit.Find(live, crew.Member)!;
        Assert.False(muted.CanPublish);
        Assert.Equal("1", muted.Attributes["muted"]);
        Assert.Equal("speaker", muted.Attributes["role"]);
        Assert.Equal(HttpStatusCode.NoContent, (await Delete(crew.Moderator, $"/live/{live}/muted/{crew.Member}")).StatusCode);
        Assert.True(LiveKit.Find(live, crew.Member)!.CanPublish);

        Assert.Equal(HttpStatusCode.Forbidden, (await Post(crew.Moderator, $"/live/{live}/kicks/{crew.Admin}")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Post(crew.Moderator, $"/live/{live}/kicks/{crew.Member}")).StatusCode);
        Assert.Null(LiveKit.Find(live, crew.Member));
        var again = await Post(crew.Member, $"/live/{live}/token");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, again.StatusCode);
        Assert.Contains("live.kicked", await again.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);

        Assert.Equal(1L, await AuditCountAsync("live.muted", crew.Group));
        Assert.Equal(1L, await AuditCountAsync("live.kicked", crew.Group));
    }

    [Fact]
    public async Task Comments_of_others_are_deleted_by_outranking_managers()
    {
        var crew = await CrewAsync();
        var live = await GoLiveAsync(crew.Admin, crew.Group);
        var memberComment = await _db.ScalarAsync<long>(
            "insert into public.live_comments (broadcast_id, user_id, body) values (@b, @u, 'Merhaba') returning id", ("b", live), ("u", crew.Member));
        var adminComment = await _db.ScalarAsync<long>(
            "insert into public.live_comments (broadcast_id, user_id, body) values (@b, @u, 'Hoş geldiniz') returning id", ("b", live), ("u", crew.Admin));

        Assert.Equal(HttpStatusCode.Forbidden, (await Delete(crew.Member, $"/live/{live}/comments/{adminComment}")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await Delete(crew.Moderator, $"/live/{live}/comments/{adminComment}")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Delete(crew.Moderator, $"/live/{live}/comments/{memberComment}")).StatusCode);
        Assert.Equal(1L, await AuditCountAsync("live.comment_removed", crew.Group));
    }

    // Ending ------------------------------------------------------------------------------------

    [Fact]
    public async Task Only_the_host_or_an_outranking_manager_ends_a_broadcast()
    {
        var crew = await CrewAsync();
        var live = await GoLiveAsync(crew.Admin, crew.Group);

        Assert.Equal(HttpStatusCode.Forbidden, (await Post(crew.Moderator, $"/live/{live}/end")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Post(crew.Owner, $"/live/{live}/end")).StatusCode);
        Assert.Equal("ended:moderator", await StatusOf(live));
        Assert.False(LiveKit.HasRoom(live));
        Assert.Equal(HttpStatusCode.Conflict, (await Post(crew.Member, $"/live/{live}/token")).StatusCode);

        var next = await GoLiveAsync(crew.Admin, crew.Group, "Gece yayını");
        Assert.Equal(HttpStatusCode.NoContent, (await Post(crew.Admin, $"/live/{next}/end")).StatusCode);
        Assert.Equal("ended:host", await StatusOf(next));
    }

    [Fact]
    public async Task Scheduled_broadcasts_start_near_their_time_and_are_canceled_by_the_host()
    {
        var crew = await CrewAsync();
        var response = await factory.ClientFor(crew.Owner).PostAsJsonAsync(
            Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Pazar konseri", DateTimeOffset.UtcNow.AddHours(2)), Ct);
        var planned = (await response.Content.ReadFromJsonAsync<LiveCreated>(Ct))!;
        Assert.Equal("scheduled", planned.Status);

        var early = await Post(crew.Owner, $"/live/{planned.Id}/start");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, early.StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await Post(crew.Admin, $"/live/{planned.Id}/start")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await Delete(crew.Admin, $"/live/{planned.Id}")).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Delete(crew.Owner, $"/live/{planned.Id}")).StatusCode);
        Assert.Equal("canceled", await StatusOf(planned.Id));

        var past = await factory.ClientFor(crew.Owner).PostAsJsonAsync(
            Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Dün", DateTimeOffset.UtcNow.AddMinutes(-5)), Ct);
        Assert.Equal(HttpStatusCode.BadRequest, past.StatusCode);
    }

    [Fact]
    public async Task The_monitor_ends_rooms_without_their_host_and_empty_rooms()
    {
        var crew = await CrewAsync();
        var clock = new ShiftedTime();
        using var shifted = factory.WithWebHostBuilder(b => b.ConfigureTestServices(s => s.AddSingleton<TimeProvider>(clock)));
        var live = shifted.Services.GetRequiredService<LiveService>();

        var hostless = await GoLiveAsync(crew.Admin, crew.Group);
        await LiveKit.RemoveParticipantAsync(hostless.ToString(), crew.Admin, Ct);
        LiveKit.Join(hostless, crew.Member);

        await live.SuperviseAsync(Ct);
        Assert.Equal("live", await StatusOf(hostless));
        clock.Shift = LiveService.HostGrace + TimeSpan.FromSeconds(1);
        await live.SuperviseAsync(Ct);
        Assert.Equal("ended:host_left", await StatusOf(hostless));
        Assert.False(LiveKit.HasRoom(hostless));

        var empty = await GoLiveAsync(crew.Admin, crew.Group, "Boş oda");
        LiveKit.CloseRoom(empty);
        clock.Shift = TimeSpan.Zero;
        await live.SuperviseAsync(Ct);
        Assert.Equal("live", await StatusOf(empty));
        clock.Shift = TimeSpan.FromMinutes(2);
        await live.SuperviseAsync(Ct);
        Assert.Equal("ended:empty", await StatusOf(empty));
    }

    // Platform team ----------------------------------------------------------------------------

    [Fact]
    public async Task Staff_see_live_rooms_and_close_them_in_an_emergency()
    {
        var crew = await CrewAsync();
        var (moderator, support) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(moderator, "moderator");
        await _db.MakeStaffAsync(support, "support");
        var live = await GoLiveAsync(crew.Admin, crew.Group);
        LiveKit.Join(live, crew.Member);

        var page = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminBroadcast>>(Path("/admin/live"), Ct);
        var row = Assert.Single(page!.Items, b => b.Id == live);
        Assert.Equal(2, row.Participants);

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).PostAsJsonAsync(Path($"/admin/live/{live}/end"), new EndLiveRequest("Taciz"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/live/{live}/end"), new EndLiveRequest("Canlı yayında taciz"), Ct)).StatusCode);
        Assert.Equal("ended:admin", await StatusOf(live));
        Assert.False(LiveKit.HasRoom(live));
        Assert.Equal(1L, await AuditCountAsync("live.force_ended", crew.Group));
    }

    // LiveKit tokens ------------------------------------------------------------------------------

    [Fact]
    public async Task Join_tokens_are_signed_LiveKit_grants_for_the_microphone_only()
    {
        var options = Options.Create(new LiveKitOptions { Url = "wss://x", ApiKey = "key", ApiSecret = ApiFactory.LiveKitSecret });
        using var http = new HttpClient();
        var client = new LiveKitClient(http, options, TimeProvider.System);
        var room = Guid.NewGuid().ToString();
        var user = Guid.NewGuid();

        var token = client.CreateJoinToken(room, user, "Ayşe", canPublish: false, new Dictionary<string, string> { ["role"] = "listener" });

        var result = await new JsonWebTokenHandler().ValidateTokenAsync(token, new TokenValidationParameters
        {
            ValidIssuer = "key",
            ValidateAudience = false,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(ApiFactory.LiveKitSecret)),
        });
        Assert.True(result.IsValid, result.Exception?.Message);
        var jwt = (JsonWebToken)result.SecurityToken;
        Assert.Equal(user.ToString(), jwt.Subject);
        var video = jwt.GetPayloadValue<Dictionary<string, object>>("video");
        Assert.Equal(room, video["room"].ToString());
        Assert.Equal("False", video["canPublish"].ToString());
        Assert.Equal("False", video["canUpdateOwnMetadata"].ToString());
        Assert.True(jwt.ValidTo - jwt.ValidFrom <= TimeSpan.FromMinutes(11));
    }

    private sealed class ShiftedTime : TimeProvider
    {
        public TimeSpan Shift { get; set; }

        public override DateTimeOffset GetUtcNow() => base.GetUtcNow() + Shift;
    }
}
