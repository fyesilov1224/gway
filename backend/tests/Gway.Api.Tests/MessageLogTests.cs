using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Groups;
using Gway.Modules.Messaging;
using Gway.Modules.Messaging.Contracts;
using Gway.Modules.Profile;

namespace Gway.Api.Tests;

/// <summary>Message logs for the platform admin (docs/ARCHITECTURE.md §3f, Mesaj kayıtları).</summary>
public sealed class MessageLogTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private const string Reason = "Taciz şikayeti incelemesi";

    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid Id, string Username)> UserAsync()
    {
        var name = Unique("l_");
        return (await _db.CreateUserAsync(name), name);
    }

    private async Task<Guid> StaffAsync(string role)
    {
        var (id, _) = await UserAsync();
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    private async Task<Guid> SentAsync(Guid actor, Guid conversation, string body, string? image = null)
    {
        var response = await factory.ClientFor(actor).PostAsJsonAsync(
            Path($"/conversations/{conversation}/messages"), new SendMessageRequest(body, image), Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<SentMessage>(Ct))!.Id;
    }

    /// <summary>Two people with the Ekip Arkadaşı package who asked each other, and their direct chat.</summary>
    private async Task<Guid> DirectChatAsync(Guid a, Guid b)
    {
        await _db.ExecuteAsync(
            "insert into public.teammate_preferences (user_id, looking, level) values (@a, true, 'beginner'), (@b, true, 'beginner')", ("a", a), ("b", b));
        await _db.GrantPackageAsync(a, "matching_teammates");
        await _db.GrantPackageAsync(b, "matching_teammates");
        (await factory.ClientFor(a).PostAsJsonAsync(Path($"/users/{b}/teammate"), new TeammateRequestBody(null), Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(b).PostAsJsonAsync(Path($"/users/{a}/teammate"), new TeammateRequestBody(null), Ct)).EnsureSuccessStatusCode();
        var opened = await factory.ClientFor(a).PostAsync(Path($"/messages/direct/{b}"), null, Ct);
        opened.EnsureSuccessStatusCode();
        return (await opened.Content.ReadFromJsonAsync<DirectConversation>(Ct))!.Id;
    }

    private async Task<Guid> GroupChatAsync(Guid owner, Guid member)
    {
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Kayıt Grubu", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        return await _db.ScalarAsync<Guid>("select id from public.conversations where group_id = @g", ("g", group));
    }

    private Task<HttpResponseMessage> SearchAsync(Guid actor, MessageLogSearch search) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path("/admin/message-logs/search"), search, Ct);

    private Task<HttpResponseMessage> ViewAsync(Guid actor, Guid conversation, MessageLogQuery query) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path($"/admin/message-logs/conversations/{conversation}"), query, Ct);

    [Fact]
    public async Task Only_the_platform_admin_searches_with_a_reason()
    {
        var ((me, myName), (friend, friendName), (other, _)) = (await UserAsync(), await UserAsync(), await UserAsync());
        var direct = await DirectChatAsync(me, friend);
        var group = await GroupChatAsync(other, me);
        await SentAsync(me, direct, "Merhaba");
        await SentAsync(me, group, "Selam grup");

        foreach (var role in new[] { "moderator", "support" })
        {
            Assert.Equal(HttpStatusCode.Forbidden,
                (await SearchAsync(await StaffAsync(role), new MessageLogSearch(myName, null, null, 1, Reason))).StatusCode);
        }
        Assert.Equal(HttpStatusCode.Forbidden, (await SearchAsync(me, new MessageLogSearch(myName, null, null, 1, Reason))).StatusCode);

        var admin = await StaffAsync("admin");
        Assert.Equal(HttpStatusCode.BadRequest, (await SearchAsync(admin, new MessageLogSearch(myName, null, null, 1, "kısa"))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await SearchAsync(admin, new MessageLogSearch(myName, null, "secret", 1, Reason))).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await SearchAsync(admin, new MessageLogSearch("yok_" + myName, null, null, 1, Reason))).StatusCode);

        var all = await (await SearchAsync(admin, new MessageLogSearch($"@{myName.ToUpperInvariant()}", null, null, 1, Reason)))
            .Content.ReadFromJsonAsync<LogConversationPage>(Ct);
        Assert.Equal(me, all!.User.Id);
        Assert.Equal(2, all.Total);
        Assert.Contains(all.Items, c => c.Kind == "direct" && c.Peer!.Id == friend && c.TargetMessageCount == 1);
        Assert.Contains(all.Items, c => c.Kind == "group" && c.Group is not null);

        var shared = await (await SearchAsync(admin, new MessageLogSearch(myName, friendName, null, 1, Reason)))
            .Content.ReadFromJsonAsync<LogConversationPage>(Ct);
        Assert.Equal(direct, Assert.Single(shared!.Items).Id);
        var groups = await (await SearchAsync(admin, new MessageLogSearch(myName, null, "group", 1, Reason)))
            .Content.ReadFromJsonAsync<LogConversationPage>(Ct);
        Assert.Equal(group, Assert.Single(groups!.Items).Id);

        Assert.Equal(3, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'message.log_searched' and actor_id = @a and target_id = @t and data->>'reason' = @r",
            ("a", admin), ("t", me.ToString()), ("r", Reason)));
    }

    [Fact]
    public async Task The_admin_reads_a_conversation_with_deleted_texts_photos_and_pages()
    {
        var ((me, _), (friend, _)) = (await UserAsync(), await UserAsync());
        var chat = await DirectChatAsync(me, friend);
        var admin = await StaffAsync("admin");

        // Older messages than the page holds (written without the rate limit).
        await _db.ExecuteWithoutTriggersAsync(
            """
            insert into public.messages (conversation_id, sender_id, body, created_at)
            select @c, @s, 'Eski mesaj ' || i, now() - interval '1 day' + i * interval '1 second' from generate_series(1, 55) i
            """, ("c", chat), ("s", me));
        var secret = await SentAsync(friend, chat, "Bunu kimse görmesin");
        var path = $"{chat}/{Guid.NewGuid():N}.jpg";
        await _db.ExecuteAsync(
            "insert into storage.objects (bucket_id, name, owner_id, metadata) values ('message-images', @p, @o, '{\"mimetype\": \"image/jpeg\"}'::jsonb)",
            ("p", path), ("o", me.ToString()));
        await SentAsync(me, chat, "", path);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(friend).DeleteAsync(Path($"/messages/{secret}"), Ct)).StatusCode);

        Assert.Equal(HttpStatusCode.Forbidden, (await ViewAsync(await StaffAsync("moderator"), chat, new MessageLogQuery(Reason, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await ViewAsync(admin, chat, new MessageLogQuery("", null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await ViewAsync(admin, Guid.NewGuid(), new MessageLogQuery(Reason, null, null))).StatusCode);

        var view = await (await ViewAsync(admin, chat, new MessageLogQuery(Reason, null, null))).Content.ReadFromJsonAsync<LogConversationView>(Ct);
        Assert.Equal(MessageLogService.MessagePageSize, view!.Messages.Count);
        Assert.True(view.HasOlder);
        Assert.Equal(2, view.Conversation.Participants.Count);
        var deleted = Assert.Single(view.Messages, m => m.Id == secret);
        Assert.True(deleted.Archived);
        Assert.Equal("Bunu kimse görmesin", deleted.Body);
        Assert.NotNull(deleted.DeletedAt);
        Assert.Null(deleted.RemovedReason);
        var photo = view.Messages[^1];
        Assert.Contains(path, photo.ImageUrl, StringComparison.Ordinal);
        Assert.True(view.Messages.Zip(view.Messages.Skip(1)).All(p => p.First.CreatedAt <= p.Second.CreatedAt));

        var older = await (await ViewAsync(admin, chat, new MessageLogQuery(Reason, view.Messages[0].CreatedAt, null)))
            .Content.ReadFromJsonAsync<LogConversationView>(Ct);
        Assert.Equal(57 - MessageLogService.MessagePageSize, older!.Messages.Count);
        Assert.False(older.HasOlder);

        var found = await (await ViewAsync(admin, chat, new MessageLogQuery(Reason, null, "KIMSE")))
            .Content.ReadFromJsonAsync<LogConversationView>(Ct);
        Assert.Equal(secret, Assert.Single(found!.Messages).Id);

        Assert.Equal(3, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'message.log_viewed' and actor_id = @a and target_id = @t",
            ("a", admin), ("t", chat.ToString())));
    }
}
