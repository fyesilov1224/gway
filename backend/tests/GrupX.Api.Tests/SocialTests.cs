using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Feed;
using GrupX.Modules.Groups;
using GrupX.Modules.Profile;

namespace GrupX.Api.Tests;

public sealed class SocialTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<Guid> UserAsync(bool isPrivate = false) => UserAsync(isPrivate, $"s_{Guid.NewGuid():N}"[..20]);

    private async Task<Guid> UserAsync(bool isPrivate, string username)
    {
        var id = await _db.CreateUserAsync(username);
        if (isPrivate) await _db.ExecuteAsync("update public.profiles set is_private = true where id = @id", ("id", id));
        return id;
    }

    private async Task<string?> FollowAsync(Guid actor, Guid target)
    {
        var response = await factory.ClientFor(actor).PostAsync(Path($"/users/{target}/follow"), null, Ct);
        return response.IsSuccessStatusCode ? (await response.Content.ReadFromJsonAsync<FollowResponse>(Ct))!.Status : $"{(int)response.StatusCode}";
    }

    private Task<bool> FollowsAsync(Guid a, Guid b) =>
        _db.ScalarAsync<bool>("select exists (select 1 from public.follows where follower_id = @a and followee_id = @b)", ("a", a), ("b", b));

    private Task<bool> RequestedAsync(Guid a, Guid b) =>
        _db.ScalarAsync<bool>("select exists (select 1 from public.follow_requests where requester_id = @a and target_id = @b)", ("a", a), ("b", b));

    // Follows ------------------------------------------------------------------------------

    [Fact]
    public async Task Following_a_public_account_is_immediate_and_idempotent()
    {
        var (me, them) = (await UserAsync(), await UserAsync());

        Assert.Equal(FollowResponse.Following, await FollowAsync(me, them));
        Assert.Equal(FollowResponse.Following, await FollowAsync(me, them));
        Assert.True(await FollowsAsync(me, them));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @r and type = 'follow'", ("r", them)));

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(me).DeleteAsync(Path($"/users/{them}/follow"), Ct)).StatusCode);
        Assert.False(await FollowsAsync(me, them));
        Assert.Equal("400", await FollowAsync(me, me));
    }

    [Fact]
    public async Task A_private_account_accepts_rejects_and_removes_followers()
    {
        var (owner, fan, other) = (await UserAsync(isPrivate: true), await UserAsync(), await UserAsync());

        Assert.Equal(FollowResponse.Requested, await FollowAsync(fan, owner));
        Assert.Equal(FollowResponse.Requested, await FollowAsync(other, owner));
        Assert.True(await RequestedAsync(fan, owner));

        var client = factory.ClientFor(owner);
        Assert.Equal(HttpStatusCode.NoContent, (await client.PostAsync(Path($"/me/follow-requests/{fan}/approval"), null, Ct)).StatusCode);
        Assert.True(await FollowsAsync(fan, owner));
        Assert.False(await RequestedAsync(fan, owner));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @r and type = 'follow_accepted'", ("r", fan)));

        Assert.Equal(HttpStatusCode.NoContent, (await client.DeleteAsync(Path($"/me/follow-requests/{other}"), Ct)).StatusCode);
        Assert.False(await RequestedAsync(other, owner));
        Assert.Equal(HttpStatusCode.NotFound, (await client.PostAsync(Path($"/me/follow-requests/{other}/approval"), null, Ct)).StatusCode);

        Assert.Equal(HttpStatusCode.NoContent, (await client.DeleteAsync(Path($"/me/followers/{fan}"), Ct)).StatusCode);
        Assert.False(await FollowsAsync(fan, owner));
        Assert.Equal(HttpStatusCode.NotFound, (await client.DeleteAsync(Path($"/me/followers/{fan}"), Ct)).StatusCode);
    }

    [Fact]
    public async Task Blocking_cuts_follows_both_ways_and_hides_the_blocker()
    {
        var (me, them) = (await UserAsync(), await UserAsync());
        await FollowAsync(me, them);
        await FollowAsync(them, me);

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(me).PostAsync(Path($"/users/{them}/block"), null, Ct)).StatusCode);

        Assert.False(await FollowsAsync(me, them));
        Assert.False(await FollowsAsync(them, me));
        Assert.Equal("404", await FollowAsync(them, me));
        Assert.Equal("422", await FollowAsync(me, them));

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(me).DeleteAsync(Path($"/users/{them}/block"), Ct)).StatusCode);
        Assert.Equal(FollowResponse.Following, await FollowAsync(them, me));
    }

    // Posts ---------------------------------------------------------------------------------

    private async Task<string> MediaAsync(Guid owner, string ext = "jpg", string mime = "image/jpeg", long size = 100_000)
    {
        var path = $"{owner}/{Guid.NewGuid():N}.{ext}";
        await _db.StoreMediaAsync(owner, path, mime, size);
        return path;
    }

    private Task<HttpResponseMessage> PostAsync(Guid actor, string caption, params PostMediaInput[] media) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path("/posts"), new CreatePostRequest(caption, media, null, false, false), Ct);

    [Fact]
    public async Task An_author_posts_a_carousel_and_hashtags_are_indexed()
    {
        var author = await UserAsync();
        var photo = await MediaAsync(author);
        var video = await MediaAsync(author, "mp4", "video/mp4", 20_000_000);
        var poster = await MediaAsync(author);
        var thumb = await MediaAsync(author);

        var response = await PostAsync(author, "Sahil koşusu #Koşu #sabah",
            new PostMediaInput("image", photo, 1080, 1350, null, null, thumb),
            new PostMediaInput("video", video, 1080, 1920, 15_000, poster, null));

        response.EnsureSuccessStatusCode();
        var id = (await response.Content.ReadFromJsonAsync<CreatedPost>(Ct))!.Id;
        Assert.Equal(2L, await _db.ScalarAsync<long>("select count(*) from public.post_media where post_id = @id", ("id", id)));
        Assert.Equal(2L, await _db.ScalarAsync<long>("select count(*) from public.post_hashtags where post_id = @id", ("id", id)));
        Assert.Equal(thumb, await _db.ScalarAsync<string>("select thumb_path from public.post_media where post_id = @id and position = 0", ("id", id)));
    }

    [Fact]
    public async Task Invalid_media_is_refused()
    {
        var (author, other) = (await UserAsync(), await UserAsync());
        var theirs = await MediaAsync(other);
        var huge = await MediaAsync(author, size: 11L * 1024 * 1024);
        var mislabeled = await MediaAsync(author, "mp4", "image/jpeg");
        var video = await MediaAsync(author, "mp4", "video/mp4");
        var photo = await MediaAsync(author);

        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", theirs, 10, 10, null, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", $"{author}/missing.jpg", 10, 10, null, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", huge, 10, 10, null, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("video", mislabeled, 10, 10, 1000, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("video", video, 10, 10, 61_000, null, null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", photo, 10, 10, null, null, theirs))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", photo, 10, 10, null, null, mislabeled))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("image", photo, 10, 10, null, null, photo))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "", new PostMediaInput("video", video, 10, 10, 1000, null, photo))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await PostAsync(author, "x")).StatusCode);
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.posts where author_id = @id", ("id", author)));
    }

    [Fact]
    public async Task Group_posts_need_the_publish_permission()
    {
        var owner = await UserAsync();
        var member = await UserAsync();
        var created = await factory.ClientFor(owner).PostAsJsonAsync(Path("/groups"),
            new CreateGroupRequest($"gp_{Guid.NewGuid():N}"[..20], "Paylaşım Grubu", "music", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();

        var byMember = await factory.ClientFor(member).PostAsJsonAsync(Path("/posts"), new CreatePostRequest(
            "Duyuru", [new PostMediaInput("image", await MediaAsync(member), 10, 10, null, null, null)], group, false, false), Ct);
        var byOwner = await factory.ClientFor(owner).PostAsJsonAsync(Path("/posts"), new CreatePostRequest(
            "Duyuru", [new PostMediaInput("image", await MediaAsync(owner), 10, 10, null, null, null)], group, false, false), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, byMember.StatusCode);
        byOwner.EnsureSuccessStatusCode();
        Assert.Equal(group, await _db.ScalarAsync<Guid>("select group_id from public.posts where author_id = @id", ("id", owner)));
    }

    [Fact]
    public async Task Only_the_author_edits_and_deleting_removes_the_files()
    {
        var (author, other) = (await UserAsync(), await UserAsync());
        var photo = await MediaAsync(author);
        var thumb = await MediaAsync(author);
        var id = (await (await PostAsync(author, "İlk hali", new PostMediaInput("image", photo, 10, 10, null, null, thumb)))
            .Content.ReadFromJsonAsync<CreatedPost>(Ct))!.Id;

        var edit = new UpdatePostRequest("Yeni hali #düzenlendi", CommentsDisabled: true, HideLikeCount: null);
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(other).PatchAsJsonAsync(Path($"/posts/{id}"), edit, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(author).PatchAsJsonAsync(Path($"/posts/{id}"), edit, Ct)).StatusCode);
        Assert.True(await _db.ScalarAsync<bool>("select comments_disabled and edited_at is not null from public.posts where id = @id", ("id", id)));

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(other).DeleteAsync(Path($"/posts/{id}"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(author).DeleteAsync(Path($"/posts/{id}"), Ct)).StatusCode);
        Assert.Contains(("media", photo), factory.Storage.DeletedObjects);
        Assert.Contains(("media", thumb), factory.Storage.DeletedObjects);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(author).DeleteAsync(Path($"/posts/{id}"), Ct)).StatusCode);
    }

    // Admin --------------------------------------------------------------------------------

    [Fact]
    public async Task Moderators_remove_and_restore_posts_and_comments()
    {
        var author = await UserAsync();
        var moderator = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(moderator, "moderator");
        var support = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(support, "support");
        var id = (await (await PostAsync(author, "Kurala aykırı", new PostMediaInput("image", await MediaAsync(author), 10, 10, null, null, null)))
            .Content.ReadFromJsonAsync<CreatedPost>(Ct))!.Id;
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @a::text)::text, true);
            insert into public.comments (post_id, author_id, body) values (@post, @a, 'Kötü yorum');
            """, ("a", author), ("post", id));
        var comment = await _db.ScalarAsync<Guid>("select id from public.comments where post_id = @id", ("id", id));

        var page = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminPostSummary>>($"/admin/posts?q=aykırı", Ct);
        Assert.Contains(page!.Items, p => p.Id == id);
        var removal = new RemoveContentRequest("Topluluk kurallarına aykırı");
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PostAsJsonAsync(Path($"/admin/posts/{id}/removal"), removal, Ct)).StatusCode);

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/posts/{id}/removal"), removal, Ct)).StatusCode);
        var detail = await factory.ClientFor(support).GetFromJsonAsync<AdminPostDetail>($"/admin/posts/{id}", Ct);
        Assert.Equal("Topluluk kurallarına aykırı", detail!.Post.RemovedReason);
        Assert.Single(detail.Comments);

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(moderator).DeleteAsync(Path($"/admin/posts/{id}/removal"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/comments/{comment}/removal"), removal, Ct)).StatusCode);
        Assert.Equal(0, await _db.ScalarAsync<int>("select comment_count from public.posts where id = @id", ("id", id)));
        Assert.Equal(3L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where target_id in (@p, @c) and action in ('post.removed', 'post.restored', 'comment.removed')",
            ("p", id.ToString()), ("c", comment.ToString())));
    }
}
