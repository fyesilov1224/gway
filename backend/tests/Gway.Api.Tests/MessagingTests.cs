using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Groups;
using Gway.Modules.Messaging;
using Gway.Modules.Messaging.Contracts;
using Gway.Modules.Moderation;
using Gway.Modules.Profile;

namespace Gway.Api.Tests;

/// <summary>Phase 15: direct messages (matches and teammates only), the group chat, photos and reports of messages.</summary>
public sealed class MessagingTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<Guid> UserAsync() => _db.CreateUserAsync(Unique("m_"));

    /// <summary>A report is the reporter's own write through Supabase (RLS); here it runs with their claims.</summary>
    private Task ReportAsync(Guid reporter, Guid message, string reason) =>
        _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @actor::text)::text, true);
            insert into public.reports (reporter_id, target_type, target_id, reason) values (@actor, 'message', @t, @reason)
            """, ("actor", reporter), ("t", message.ToString()), ("reason", reason));

    private async Task<DirectConversation> OpenAsync(Guid actor, Guid other)
    {
        var response = await factory.ClientFor(actor).PostAsync(Path($"/messages/direct/{other}"), null, Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<DirectConversation>(Ct))!;
    }

    private Task<HttpResponseMessage> SendAsync(Guid actor, Guid conversation, string body, string? image = null) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path($"/conversations/{conversation}/messages"), new SendMessageRequest(body, image), Ct);

    private async Task<Guid> SentAsync(Guid actor, Guid conversation, string body)
    {
        var response = await SendAsync(actor, conversation, body);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SentMessage>(Ct))!.Id;
    }

    /// <summary>Two people with the Ekip Arkadaşı package who asked each other (crossed requests), so they may write.</summary>
    private async Task TeammatesAsync(Guid a, Guid b)
    {
        await _db.ExecuteAsync(
            "insert into public.teammate_preferences (user_id, looking, level) values (@a, true, 'beginner'), (@b, true, 'beginner')", ("a", a), ("b", b));
        await _db.GrantPackageAsync(a, "matching_teammates");
        await _db.GrantPackageAsync(b, "matching_teammates");
        (await factory.ClientFor(a).PostAsJsonAsync(Path($"/users/{b}/teammate"), new TeammateRequestBody(null), Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(b).PostAsJsonAsync(Path($"/users/{a}/teammate"), new TeammateRequestBody(null), Ct)).EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task Only_teammates_and_matches_open_a_direct_chat()
    {
        var (me, follower, stranger, teammate) = (await UserAsync(), await UserAsync(), await UserAsync(), await UserAsync());
        (await factory.ClientFor(me).PostAsync(Path($"/users/{follower}/follow"), null, Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(follower).PostAsync(Path($"/users/{me}/follow"), null, Ct)).EnsureSuccessStatusCode();
        await TeammatesAsync(me, teammate);

        foreach (var other in new[] { follower, stranger })
        {
            var refused = await factory.ClientFor(me).PostAsync(Path($"/messages/direct/{other}"), null, Ct);
            Assert.Contains("message.not_allowed", await refused.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        }
        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(me).PostAsync(Path($"/messages/direct/{me}"), null, Ct)).StatusCode);

        var chat = await OpenAsync(me, teammate);
        Assert.Equal(DirectConversation.Active, chat.State);
        await SentAsync(me, chat.Id, "Merhaba, rotayı paylaşır mısın?");
        Assert.Equal(HttpStatusCode.BadRequest, (await SendAsync(me, chat.Id, new string('a', MessagingService.MaxBody + 1))).StatusCode);
        var reply = await SentAsync(teammate, chat.Id, "Tabii, akşam atarım");

        // Only the sender deletes, for everyone.
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(me).DeleteAsync(Path($"/messages/{reply}"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(teammate).DeleteAsync(Path($"/messages/{reply}"), Ct)).StatusCode);
        Assert.Equal("", await _db.ScalarAsync<string>("select body from public.messages where id = @id", ("id", reply)));
    }

    [Fact]
    public async Task A_chat_opened_under_the_old_rules_is_read_only()
    {
        var (me, friend) = (await UserAsync(), await UserAsync());
        var chat = await _db.ScalarAsync<Guid>(
            """
            with c as (
              insert into public.conversations (kind, user_a, user_b, created_by)
              values ('direct', least(@a, @b), greatest(@a, @b), @a) returning id
            ), m as (
              insert into public.conversation_members (conversation_id, user_id, state)
              select id, u, 'active' from c, unnest(array[@a, @b]) u
            )
            select id from c
            """, ("a", me), ("b", friend));

        Assert.Equal(chat, (await OpenAsync(me, friend)).Id);
        var refused = await SendAsync(me, chat, "Selam");
        Assert.Contains("message.not_allowed", await refused.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
    }

    [Fact]
    public async Task Photos_must_be_uploaded_by_the_sender_into_the_conversation()
    {
        var (me, friend) = (await UserAsync(), await UserAsync());
        await TeammatesAsync(me, friend);
        var chat = (await OpenAsync(me, friend)).Id;

        var path = $"{chat}/{Guid.NewGuid():N}.jpg";
        Assert.Equal(HttpStatusCode.BadRequest, (await SendAsync(me, chat, "", path)).StatusCode);
        await _db.ExecuteAsync(
            "insert into storage.objects (bucket_id, name, owner_id, metadata) values ('message-images', @p, @o, '{\"mimetype\": \"image/jpeg\"}'::jsonb)",
            ("p", path), ("o", me.ToString()));
        Assert.Equal(HttpStatusCode.BadRequest, (await SendAsync(friend, chat, "", path)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await SendAsync(me, chat, "", path)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await SendAsync(me, chat, "", $"{Guid.NewGuid()}/x.jpg")).StatusCode);
    }

    private async Task<(Guid Group, Guid Owner, Guid Member, Guid Chat)> GroupChatAsync()
    {
        var (owner, member) = (await UserAsync(), await UserAsync());
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Mesaj Grubu", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        var chat = await _db.ScalarAsync<Guid>("select id from public.conversations where group_id = @g", ("g", group));
        return (group, owner, member, chat);
    }

    [Fact]
    public async Task The_group_chat_can_be_made_admins_only()
    {
        var (group, owner, member, chat) = await GroupChatAsync();
        await SentAsync(member, chat, "Cumartesi kim geliyor?");

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(member).PutAsJsonAsync(Path($"/groups/{group}/chat"), new ChatModeRequest(true), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(owner).PutAsJsonAsync(Path($"/groups/{group}/chat"), new ChatModeRequest(true), Ct)).StatusCode);
        var refused = await SendAsync(member, chat, "Ben!");
        Assert.Contains("message.admins_only", await refused.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        await SentAsync(owner, chat, "Duyuru: rota değişti");
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'group.chat_mode_changed' and group_id = @g", ("g", group)));

        var outsider = await UserAsync();
        Assert.Equal(HttpStatusCode.Forbidden, (await SendAsync(outsider, chat, "Merhaba")).StatusCode);
    }

    [Fact]
    public async Task Reported_group_messages_go_to_the_group_and_direct_ones_to_the_platform()
    {
        var (_, owner, member, chat) = await GroupChatAsync();
        var rude = await SentAsync(member, chat, "Kaba bir mesaj");
        await ReportAsync(owner, rude, "harassment");
        var groupReport = await _db.ScalarAsync<Guid>("select id from public.reports where target_id = @t", ("t", rude.ToString()));
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(owner).PostAsJsonAsync(
            Path($"/reports/{groupReport}/removal"), new RemoveReportedRequest("Hakaret içeriyor"), Ct)).StatusCode);
        Assert.Equal("Hakaret içeriyor", await _db.ScalarAsync<string>("select removed_reason from public.messages where id = @id", ("id", rude)));

        // A direct message: the platform team sees it with the five before it, and the viewing is recorded.
        var (me, friend) = (await UserAsync(), await UserAsync());
        await TeammatesAsync(me, friend);
        var direct = (await OpenAsync(me, friend)).Id;
        for (var i = 1; i <= 7; i++) await SentAsync(i % 2 == 0 ? me : friend, direct, $"Mesaj {i}");
        var reported = await SentAsync(friend, direct, "Tehdit içeren mesaj");
        await SentAsync(me, direct, "Sonraki mesaj");
        await ReportAsync(me, reported, "violence");
        var report = await _db.ScalarAsync<Guid>("select id from public.reports where target_id = @t", ("t", reported.ToString()));

        var support = await UserAsync();
        await _db.MakeStaffAsync(support, "support");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).GetAsync(Path($"/admin/reports/{report}/message-context"), Ct)).StatusCode);

        var moderator = await UserAsync();
        await _db.MakeStaffAsync(moderator, "moderator");
        var staff = factory.ClientFor(moderator);
        var context = await staff.GetFromJsonAsync<List<ContextMessage>>($"/admin/reports/{report}/message-context", Ct);
        Assert.Equal(6, context!.Count);
        Assert.True(context[^1].Reported);
        Assert.Equal("Tehdit içeren mesaj", context[^1].Body);
        Assert.DoesNotContain(context, m => m.Body == "Sonraki mesaj");
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'message.context_viewed' and target_id = @t", ("t", reported.ToString())));

        Assert.Equal(HttpStatusCode.NoContent, (await staff.PostAsJsonAsync(
            Path($"/admin/messages/{reported}/removal"), new RemoveContentRequest("Tehdit"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await staff.PostAsJsonAsync(
            Path($"/admin/messages/{reported}/removal"), new RemoveContentRequest("Tehdit"), Ct)).StatusCode);
    }
}
