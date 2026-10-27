using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Groups;
using GrupX.Modules.Matching;
using GrupX.Modules.Matching.Contracts;

namespace GrupX.Api.Tests;

/// <summary>Not parallel with itself: one test lowers the shared daily like limit for a moment.</summary>
public sealed class MatchingTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>Two people with live matching profiles who share a group: a woman and a man looking for each other.</summary>
    private async Task<(Guid Her, Guid Him)> PairAsync()
    {
        var (her, him) = (await _db.CreateUserAsync(Unique("e_")), await _db.CreateUserAsync(Unique("e_")));
        var created = await factory.ClientFor(her).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Kamp Severler", "music", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(him).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        await ProfileAsync(her, "woman", "{man}");
        await ProfileAsync(him, "man", "{woman}");
        return (her, him);
    }

    private async Task ProfileAsync(Guid user, string gender, string interestedIn)
    {
        await _db.ExecuteAsync(
            """
            insert into public.match_profiles (user_id, birth_date, gender, province, friend, dating, interested_in, consent_version)
            values (@id, date '1994-04-04', @gender, 34, true, true, @interested::text[], 'v1')
            """, ("id", user), ("gender", gender), ("interested", interestedIn));
        await _db.ExecuteAsync(
            "insert into public.match_photos (user_id, path, position) values (@id, @id::text || '/a.jpg', 0), (@id, @id::text || '/b.jpg', 1)",
            ("id", user));
    }

    private async Task<SwipeResult?> SwipeAsync(Guid actor, Guid target, bool like = true, string mode = "dating")
    {
        var response = await factory.ClientFor(actor).PostAsJsonAsync(Path("/matching/swipes"), new SwipeRequest(target, mode, like), Ct);
        return response.IsSuccessStatusCode ? await response.Content.ReadFromJsonAsync<SwipeResult>(Ct) : null;
    }

    [Fact]
    public async Task Two_likes_make_a_match_that_opens_a_chat_and_ending_it_closes_the_chat()
    {
        var (her, him) = await PairAsync();

        var first = await SwipeAsync(her, him);
        Assert.False(first!.Matched);
        var second = await SwipeAsync(him, her);
        Assert.True(second!.Matched);
        Assert.Equal(2L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where match_id = @m and type = 'match_created'", ("m", second.MatchId!.Value)));

        var chat = await factory.ClientFor(her).PostAsync(Path($"/messages/direct/{him}"), null, Ct);
        Assert.Equal(HttpStatusCode.OK, chat.StatusCode);
        Assert.Contains("active", await chat.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);

        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(him).DeleteAsync(Path($"/matching/matches/{second.MatchId}"), Ct)).StatusCode);
        // The chat still opens to be read, but takes no new messages.
        var opened = await (await factory.ClientFor(her).PostAsync(Path($"/messages/direct/{him}"), null, Ct))
            .Content.ReadFromJsonAsync<GrupX.Modules.Messaging.DirectConversation>(Ct);
        var closed = await factory.ClientFor(her).PostAsJsonAsync(Path($"/conversations/{opened!.Id}/messages"),
            new GrupX.Modules.Messaging.SendMessageRequest("Selam", null), Ct);
        Assert.Contains("message.match_ended", await closed.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.Equal(HttpStatusCode.NotFound,
            (await factory.ClientFor(her).DeleteAsync(Path($"/matching/matches/{second.MatchId}"), Ct)).StatusCode);
    }

    [Fact]
    public async Task Only_people_in_the_deck_can_be_swiped_and_likes_are_limited_daily()
    {
        var (her, him) = await PairAsync();
        var stranger = await _db.CreateUserAsync(Unique("e_"));
        await ProfileAsync(stranger, "man", "{woman}");

        Assert.Null(await SwipeAsync(her, stranger));
        Assert.Null(await SwipeAsync(her, him, mode: "romance"));

        await _db.ExecuteAsync("update public.matching_settings set daily_free_likes = 1");
        try
        {
            Assert.Equal(0, (await SwipeAsync(her, him, mode: "friend"))!.LikesLeft);
            var limited = await factory.ClientFor(her).PostAsJsonAsync(Path("/matching/swipes"), new SwipeRequest(him, "dating", true), Ct);
            Assert.Contains("match.like_limit", await limited.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
            Assert.NotNull(await SwipeAsync(her, him, like: false));
        }
        finally
        {
            await _db.ExecuteAsync("update public.matching_settings set daily_free_likes = 10");
        }
    }

    [Fact]
    public async Task Deleting_matching_removes_everything_and_ends_matches()
    {
        var (her, him) = await PairAsync();
        await SwipeAsync(her, him);
        var match = (await SwipeAsync(him, her))!.MatchId!.Value;

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(her).DeleteAsync(Path("/me/matching"), Ct)).StatusCode);
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.match_profiles where user_id = @id", ("id", her)));
        Assert.Equal(0L, await _db.ScalarAsync<long>(
            "select count(*) from public.match_swipes where swiper_id = @id or target_id = @id", ("id", her)));
        Assert.True(await _db.ScalarAsync<bool>("select ended_at is not null from public.matches where id = @m", ("m", match)));
        Assert.Contains((MatchingModule.PhotoBucket, her.ToString()), factory.Storage.DeletedFolders);
    }

    [Fact]
    public async Task Staff_see_stats_suspend_profiles_and_remove_photos()
    {
        var (her, him) = await PairAsync();
        await SwipeAsync(her, him);
        await SwipeAsync(him, her);
        var (moderator, support) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(moderator, "moderator");
        await _db.MakeStaffAsync(support, "support");

        var stats = await factory.ClientFor(support).GetFromJsonAsync<MatchingStats>(Path("/admin/matching/stats"), Ct);
        Assert.True(stats!.DatingProfiles >= 2);
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(her).GetAsync(Path("/admin/matching/stats"), Ct)).StatusCode);

        var suspension = new SuspendMatchProfileRequest("Sahte profil", null);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).PostAsJsonAsync(Path($"/admin/matching/profiles/{him}/suspension"), suspension, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/matching/profiles/{him}/suspension"), suspension, Ct)).StatusCode);
        Assert.False(await _db.ScalarAsync<bool>("select private.match_fits(@a, @b, 'friend')", ("a", her), ("b", him)));
        Assert.Equal(0L, await _db.ScalarAsync<long>(
            "select count(*) from public.matches where @id in (user_a, user_b) and ended_at is null", ("id", him)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'match_profile.suspended' and target_id = @id", ("id", him.ToString())));

        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).DeleteAsync(Path($"/admin/matching/profiles/{him}/suspension"), Ct)).StatusCode);

        var photo = await _db.ScalarAsync<Guid>("select id from public.match_photos where user_id = @id and position = 0", ("id", her));
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(moderator).PostAsJsonAsync(
            Path($"/admin/matching/photos/{photo}/removal"), new RemoveContentRequest("Uygunsuz fotoğraf"), Ct)).StatusCode);
        Assert.Contains((MatchingModule.PhotoBucket, $"{her}/a.jpg"), factory.Storage.DeletedObjects);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(moderator).PutAsJsonAsync(
            Path("/admin/matching/settings"), new MatchingSettings(20, 1, 5, 30), Ct)).StatusCode);
    }

    private async Task<string> ErrorOfAsync(HttpResponseMessage response) => await response.Content.ReadAsStringAsync(Ct);

    [Fact]
    public async Task Writing_to_a_match_needs_the_chat_package()
    {
        var (her, him) = await PairAsync();
        await SwipeAsync(her, him);
        await SwipeAsync(him, her);
        var chat = await (await factory.ClientFor(her).PostAsync(Path($"/messages/direct/{him}"), null, Ct))
            .Content.ReadFromJsonAsync<GrupX.Modules.Messaging.DirectConversation>(Ct);
        var message = new GrupX.Modules.Messaging.SendMessageRequest("Merhaba!", null);

        var locked = await factory.ClientFor(her).PostAsJsonAsync(Path($"/conversations/{chat!.Id}/messages"), message, Ct);
        Assert.Contains("message.match_chat_locked", await ErrorOfAsync(locked), StringComparison.Ordinal);

        var admin = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(admin, "admin");
        var herName = await _db.ScalarAsync<string>("select username from public.profiles where id = @id", ("id", her));
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/matching/packages/grants"),
            new GrantPackageRequest(herName!, "matching_chat", 30, "Test sohbeti"), Ct)).StatusCode);
        Assert.True((await factory.ClientFor(her).PostAsJsonAsync(Path($"/conversations/{chat.Id}/messages"), message, Ct)).IsSuccessStatusCode);
        Assert.Equal(0L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @id and type = 'match_created' and actor_id <> recipient_id",
            ("id", her)));
    }

    [Fact]
    public async Task A_free_super_like_a_day_is_seen_first_and_told()
    {
        var (her, him) = await PairAsync();

        var first = await factory.ClientFor(him).PostAsJsonAsync(Path("/matching/swipes"), new SwipeRequest(her, "dating", false, Super: true), Ct);
        var result = await first.Content.ReadFromJsonAsync<SwipeResult>(Ct);
        Assert.Equal(0, result!.SuperLikesLeft);
        Assert.Equal(10, result.LikesLeft);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.match_swipes where swiper_id = @a and target_id = @b and liked and super", ("a", him), ("b", her)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @id and type = 'match_super_liked'", ("id", her)));

        var again = await factory.ClientFor(him).PostAsJsonAsync(Path("/matching/swipes"), new SwipeRequest(her, "friend", true, Super: true), Ct);
        Assert.Contains("match.super_like_limit", await ErrorOfAsync(again), StringComparison.Ordinal);
    }

    [Fact]
    public async Task Packages_are_granted_by_an_admin_and_each_unlocks_its_feature()
    {
        var herName = Unique("e_");
        var her = await _db.CreateUserAsync(herName);
        var (other, him) = await PairAsync();
        await _db.ExecuteAsync("insert into public.group_follows (user_id, group_id) select @her, group_id from public.group_members where user_id = @other",
            ("her", her), ("other", other));
        await ProfileAsync(her, "woman", "{man}");

        Assert.Contains("match.package_required", await ErrorOfAsync(await factory.ClientFor(her).PostAsync(Path("/matching/rewind"), null, Ct)),
            StringComparison.Ordinal);
        Assert.Contains("match.package_required", await ErrorOfAsync(await factory.ClientFor(her).PostAsync(Path("/matching/boost"), null, Ct)),
            StringComparison.Ordinal);

        var (admin, moderator) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(admin, "admin");
        await _db.MakeStaffAsync(moderator, "moderator");
        var grant = new GrantPackageRequest(herName, "matching_unlimited", 7, "Test telafisi");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(moderator).PostAsJsonAsync(Path("/admin/matching/packages/grants"), grant, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/matching/packages/grants"), grant, Ct)).StatusCode);
        Assert.True(await _db.ScalarAsync<bool>("select private.has_matching_feature(@id, 'unlimited')", ("id", her)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'personal_plan.granted' and actor_id = @id", ("id", admin)));

        Assert.Null((await SwipeAsync(her, him, mode: "friend"))!.LikesLeft);
        Assert.NotNull(await SwipeAsync(her, him, like: false));
        var rewind = await factory.ClientFor(her).PostAsync(Path("/matching/rewind"), null, Ct);
        Assert.Equal(new RewindResult(him, "dating"), await rewind.Content.ReadFromJsonAsync<RewindResult>(Ct));
        Assert.Contains("match.nothing_to_rewind", await ErrorOfAsync(await factory.ClientFor(her).PostAsync(Path("/matching/rewind"), null, Ct)),
            StringComparison.Ordinal);

        // Sınırsız Beğeni does not boost; Öne Çık does.
        Assert.Contains("Öne Çık", await ErrorOfAsync(await factory.ClientFor(her).PostAsync(Path("/matching/boost"), null, Ct)),
            StringComparison.Ordinal);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/matching/packages/grants"),
            grant with { Slug = "matching_boost" }, Ct)).StatusCode);
        var boost = await factory.ClientFor(her).PostAsync(Path("/matching/boost"), null, Ct);
        Assert.True((await boost.Content.ReadFromJsonAsync<BoostResult>(Ct))!.EndsAt > DateTimeOffset.UtcNow.AddMinutes(25));
        Assert.Contains("match.boost_used", await ErrorOfAsync(await factory.ClientFor(her).PostAsync(Path("/matching/boost"), null, Ct)),
            StringComparison.Ordinal);
    }
}
