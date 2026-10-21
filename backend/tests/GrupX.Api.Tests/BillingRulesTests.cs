using System.Security.Cryptography;
using System.Text;
using GrupX.Modules.Billing;
using GrupX.Modules.Billing.Providers;

namespace GrupX.Api.Tests;

/// <summary>Billing rules without the database: timeline placement, provider signatures, markets.</summary>
public sealed class BillingRulesTests
{
    private static readonly DateTimeOffset Now = new(2026, 10, 19, 12, 0, 0, TimeSpan.Zero);

    // TRY list prices of the seed catalog.
    private static int? Price(string plan, string period) => (plan, period) switch
    {
        ("starter", "month") => 24900,
        ("starter", "year") => 249000,
        ("pro", "month") => 69900,
        ("pro", "year") => 699000,
        ("community", "month") => 199900,
        _ => null,
    };

    private static Slice SliceOf(string plan, int tier, string period, DateTimeOffset start, DateTimeOffset end) =>
        new(Guid.NewGuid(), plan, tier, period, start, end);

    [Fact]
    public void First_purchase_starts_now_without_credit()
    {
        var placement = SubscriptionTimeline.Place(Now, [], "starter", 1, "month", Price).Value;

        Assert.Equal(ChangeKinds.Upgrade, placement.Kind);
        Assert.Equal(Now, placement.StartsAt);
        Assert.Equal(Now.AddMonths(1), placement.EndsAt);
        Assert.Equal(TimeSpan.Zero, placement.Credit);
        Assert.Empty(placement.Replaced);
    }

    [Fact]
    public void Upgrade_starts_now_and_converts_the_remaining_time_at_daily_prices()
    {
        var current = SliceOf("starter", 1, "month", Now.AddDays(-20), Now.AddDays(10));

        var placement = SubscriptionTimeline.Place(Now, [current], "pro", 2, "month", Price).Value;

        // 10 days × 249 / 699 ≈ 3.56 days (docs/ARCHITECTURE.md §7 example).
        Assert.Equal(ChangeKinds.Upgrade, placement.Kind);
        Assert.Equal(Now, placement.StartsAt);
        Assert.Equal(Math.Floor(10 * 86400 * 24900m / 69900m), (decimal)placement.Credit.TotalSeconds);
        Assert.Equal(Now.AddMonths(1) + placement.Credit, placement.EndsAt);
        Assert.Equal([current.Id], placement.Replaced);
    }

    [Fact]
    public void Upgrade_also_converts_queued_slices_and_compares_daily_prices_across_periods()
    {
        var current = SliceOf("starter", 1, "month", Now.AddDays(-5), Now.AddDays(25));
        var queued = SliceOf("starter", 1, "year", Now.AddDays(25), Now.AddDays(25 + 365));

        var placement = SubscriptionTimeline.Place(Now, [current, queued], "pro", 2, "year", Price).Value;

        // Daily prices: starter monthly 24900/30, starter yearly 249000/365, pro yearly 699000/365.
        var expected = Math.Floor(25 * 86400m * (24900m / 30) / (699000m / 365))
                       + Math.Floor(365 * 86400m * (249000m / 365) / (699000m / 365));
        Assert.Equal(expected, (decimal)placement.Credit.TotalSeconds);
        Assert.Equal([current.Id, queued.Id], placement.Replaced);
    }

    [Fact]
    public void Renewal_is_appended_to_the_end_of_the_timeline()
    {
        var current = SliceOf("pro", 2, "month", Now.AddDays(-20), Now.AddDays(10));

        var placement = SubscriptionTimeline.Place(Now, [current], "pro", 2, "year", Price).Value;

        Assert.Equal(ChangeKinds.Renewal, placement.Kind);
        Assert.Equal(current.EndsAt, placement.StartsAt);
        Assert.Equal(current.EndsAt.AddYears(1), placement.EndsAt);
        Assert.Empty(placement.Replaced);
    }

    [Fact]
    public void Downgrade_waits_for_the_end_of_the_timeline()
    {
        var current = SliceOf("pro", 2, "month", Now.AddDays(-20), Now.AddDays(10));
        var queued = SliceOf("pro", 2, "month", Now.AddDays(10), Now.AddDays(40));

        var placement = SubscriptionTimeline.Place(Now, [current, queued], "starter", 1, "month", Price).Value;

        Assert.Equal(ChangeKinds.Downgrade, placement.Kind);
        Assert.Equal(queued.EndsAt, placement.StartsAt);
    }

    [Fact]
    public void Renewal_is_refused_beyond_the_horizon_but_settlement_still_places_it()
    {
        var current = SliceOf("pro", 2, "year", Now.AddDays(-1), Now.AddDays(401));

        var refused = SubscriptionTimeline.Place(Now, [current], "pro", 2, "month", Price);
        var settled = SubscriptionTimeline.Place(Now, [current], "pro", 2, "month", Price, enforceMaxAhead: false);
        var upgrade = SubscriptionTimeline.Place(Now, [current], "community", 3, "month", Price);

        Assert.Equal("billing.timeline_too_long", refused.Error?.Code);
        Assert.Equal(current.EndsAt, settled.Value.StartsAt);
        Assert.True(upgrade.IsSuccess);
    }

    [Fact]
    public void Paytr_notification_hash_matches_its_documented_formula()
    {
        var options = Microsoft.Extensions.Options.Options.Create(new BillingOptions
        {
            Paytr = new PaytrOptions { MerchantId = "1", MerchantKey = "key", MerchantSalt = "salt" },
        });
        var client = new PaytrClient(new HttpClient(), options, Microsoft.Extensions.Logging.Abstractions.NullLogger<PaytrClient>.Instance);
        var hash = Convert.ToBase64String(HMACSHA256.HashData("key"u8, Encoding.UTF8.GetBytes("abc" + "salt" + "success" + "24900")));

        Assert.True(client.Verify("abc", "success", "24900", hash));
        Assert.False(client.Verify("abc", "success", "100", hash));
        Assert.False(client.Verify("abc", "success", "24900", "forged"));
    }

    [Fact]
    public void Iyzico_authorization_signs_random_key_path_and_body()
    {
        var header = IyzicoClient.Authorization("api", "secret", "123", "/payment/test", "{\"a\":1}");

        Assert.StartsWith("IYZWSv2 ", header, StringComparison.Ordinal);
        var decoded = Encoding.UTF8.GetString(Convert.FromBase64String(header["IYZWSv2 ".Length..]));
        var signature = Convert.ToHexStringLower(HMACSHA256.HashData("secret"u8, Encoding.UTF8.GetBytes("123/payment/test{\"a\":1}")));
        Assert.Equal($"apiKey:api&randomKey:123&signature:{signature}", decoded);
    }

    [Theory]
    [InlineData("tr", "TR")]
    [InlineData(" de ", "DE")]
    [InlineData("XX", null)]
    [InlineData("T1", null)]
    [InlineData("TUR", null)]
    [InlineData("", null)]
    public void Country_codes_are_normalized(string input, string? expected) =>
        Assert.Equal(expected, CountryResolver.Normalize(input));

    [Fact]
    public void Turkiye_pays_with_paytr_in_lira_everyone_else_with_iyzico_in_dollars()
    {
        Assert.Equal(new Market("TR", "paytr", "TRY"), Market.For("TR"));
        Assert.Equal(new Market("DE", "iyzico", "USD"), Market.For("DE"));
    }
}
