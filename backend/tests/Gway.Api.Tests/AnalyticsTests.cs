using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

/// <summary>Runs alone: one test compares platform-wide user counts, which other classes change.</summary>
[Collection(nameof(AnalyticsTests))]
public sealed class AnalyticsTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private static AdminMetric Metric(AdminOverview overview, string key) => overview.Metrics.Single(m => m.Key == key);

    [Fact]
    public async Task The_overview_counts_today_and_shows_revenue_only_to_billing_roles()
    {
        var (admin, moderator, member) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")),
            await _db.CreateUserAsync(Unique("a_")));
        await _db.MakeStaffAsync(admin, "admin");
        await _db.MakeStaffAsync(moderator, "moderator");
        // Creating a group makes its owner a member: one new group and one active person today.
        (await factory.ClientFor(member).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Analiz Grubu", "music", "open", null), Ct)).EnsureSuccessStatusCode();
        // A shared year card (the person's own write in the app).
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @m::text, 'role', 'authenticated')::text, true);
            select public.record_card_share('year');
            """, ("m", member));

        var overview = await factory.ClientFor(admin).GetFromJsonAsync<AdminOverview>(Path("/admin/analytics/overview?days=7"), Ct);
        Assert.Equal("day", overview!.Bucket);
        Assert.Equal(7, overview.Buckets.Count);
        var users = Metric(overview, "new_users");
        Assert.Equal(7, users.Points.Count);
        Assert.Equal(7, users.PreviousPoints.Count);
        Assert.True(users.Points[^1] >= 3, "today's sign-ups land in the last bucket");
        Assert.Equal(users.Points.Sum(), users.Current);
        Assert.True(Metric(overview, "active_users").Current >= 1);
        Assert.True(Metric(overview, "new_groups").Points[^1] >= 1);
        Assert.True(Metric(overview, "card_shares_year").Points[^1] >= 1);
        Assert.Contains(overview.Metrics, m => m.Key == "revenue_try");
        Assert.True(overview.Snapshot.Users >= 3);

        var forModerator = await factory.ClientFor(moderator).GetFromJsonAsync<AdminOverview>(Path("/admin/analytics/overview"), Ct);
        Assert.Equal(30, forModerator!.Buckets.Count);
        Assert.DoesNotContain(forModerator.Metrics, m => m.Key.StartsWith("revenue_", StringComparison.Ordinal));

        var year = await factory.ClientFor(admin).GetFromJsonAsync<AdminOverview>(Path("/admin/analytics/overview?days=365"), Ct);
        Assert.Equal("week", year!.Bucket);
        Assert.Equal(52, year.Buckets.Count);

        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(admin).GetAsync(Path("/admin/analytics/overview?days=12"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(member).GetAsync(Path("/admin/analytics/overview"), Ct)).StatusCode);
    }

    [Fact]
    public async Task A_sign_up_without_a_profile_is_counted_like_on_the_users_page()
    {
        var admin = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(admin, "admin");
        var client = factory.ClientFor(admin);

        var before = await client.GetFromJsonAsync<AdminOverview>(Path("/admin/analytics/overview?days=7"), Ct);
        // Signed up, onboarding not finished yet: an auth user with no profile row.
        await _db.CreateUserAsync();
        var after = await client.GetFromJsonAsync<AdminOverview>(Path("/admin/analytics/overview?days=7"), Ct);
        var stats = await client.GetFromJsonAsync<AdminUserStats>(Path("/admin/users/stats"), Ct);

        Assert.Equal(before!.Snapshot.Users + 1, after!.Snapshot.Users);
        Assert.Equal(Metric(before, "new_users").Current + 1, Metric(after, "new_users").Current);
        Assert.Equal(stats!.Total, after.Snapshot.Users);
    }
}

[CollectionDefinition(nameof(AnalyticsTests), DisableParallelization = true)]
public sealed class AnalyticsCollection;
