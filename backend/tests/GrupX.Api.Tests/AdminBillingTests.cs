using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Billing;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Groups;

namespace GrupX.Api.Tests;

[Collection("Billing")]
public sealed class AdminBillingTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private async Task<Guid> StaffAsync(string role)
    {
        var id = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    /// <summary>A group with a paid monthly Başlangıç plan.</summary>
    private async Task<(CreatedGroup Group, Guid Order)> PaidGroupAsync()
    {
        var owner = await _db.CreateUserAsync(Unique("o_"));
        var owners = factory.ClientFor(owner);
        owners.DefaultRequestHeaders.Add(ApiFactory.CountryHeader, "TR");
        var created = await owners.PostAsJsonAsync(Path("/groups"), new CreateGroupRequest(Unique("ab_"), "Abone Grup", "music", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!;

        var ordered = await owners.PostAsJsonAsync(Path($"/billing/groups/{group.Id}/orders"), new CreateOrderRequest(
            "starter", "month", "TRY", 1, new BillingDetails("Ada", "Yilmaz", "05550000000", "Moda Cad. 1", "Istanbul", "Turkiye")), Ct);
        var order = (await ordered.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!.OrderId;

        using var notification = FakePaymentProviders.PaytrNotification(order, "success", 24900);
        (await factory.CreateClient().PostAsync(Path("/billing/paytr/notify"), notification, Ct)).EnsureSuccessStatusCode();
        return (group, order);
    }

    [Fact]
    public async Task Revenue_is_for_platform_admins_only()
    {
        var support = await StaffAsync("support");
        var admin = await StaffAsync("admin");
        await PaidGroupAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).GetAsync(Path("/admin/billing/stats"), Ct)).StatusCode);

        var stats = await factory.ClientFor(admin).GetFromJsonAsync<AdminBillingStats>("/admin/billing/stats", Ct);
        Assert.Equal(12, stats!.Months.Count);
        Assert.True(stats.ActiveSubscriptions >= 1);
        Assert.True(stats.RevenueThisMonth.Single(m => m.Currency == "TRY").AmountMinor >= 24900);
    }

    [Fact]
    public async Task Support_finds_orders_and_subscriptions_of_a_group()
    {
        var support = await StaffAsync("support");
        var moderator = await StaffAsync("moderator");
        var (group, order) = await PaidGroupAsync();

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(moderator).GetAsync(Path("/admin/billing/orders"), Ct)).StatusCode);

        var orders = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminOrder>>(
            $"/admin/billing/orders?q={group.Handle}&status=paid&provider=paytr", Ct);
        var found = Assert.Single(orders!.Items);
        Assert.Equal(order, found.Id);
        Assert.Equal(24900, found.AmountMinor);

        var subscriptions = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminSubscription>>(
            $"/admin/billing/subscriptions?q={group.Handle}", Ct);
        Assert.Equal("starter", Assert.Single(subscriptions!.Items).PlanSlug);

        var detail = await factory.ClientFor(support).GetFromJsonAsync<AdminGroupDetail>($"/admin/groups/{group.Id}", Ct);
        Assert.Equal("starter", detail!.Plan.Slug);
        Assert.Single(detail.Subscriptions);
    }

    [Fact]
    public async Task Admin_cancels_a_refunded_subscription_and_the_group_falls_back_to_free()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");
        var (group, order) = await PaidGroupAsync();
        var subscription = await _db.ScalarAsync<Guid>("select id from public.group_subscriptions where order_id = @o", ("o", order));
        var url = Path($"/admin/subscriptions/{subscription}/cancellation");
        var body = new CancelSubscriptionRequest("Kullanıcı talebiyle iade edildi", Refunded: true);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PostAsJsonAsync(url, body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PostAsJsonAsync(url, body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(admin).PostAsJsonAsync(url, body, Ct)).StatusCode);

        Assert.Equal("free", await _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group.Id)));
        Assert.Equal("refunded", await _db.ScalarAsync<string>("select status from public.billing_orders where id = @o", ("o", order)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'subscription.canceled' and group_id = @g", ("g", group.Id)));
    }

    [Fact]
    public async Task Admin_edits_a_plan_and_support_cannot()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");
        // Only the community plan, which no other test buys.
        var original = (await factory.ClientFor(admin).GetFromJsonAsync<List<AdminPlan>>("/admin/plans", Ct))!.Single(p => p.Slug == "community");
        var restore = new PlanUpdate(original.Name, original.MaxMembers, original.MonthlyEvents, original.MonthlyLiveMinutes, original.IsActive,
            [.. original.Prices.Select(p => new PlanPriceUpdate(p.Currency, p.Period, p.AmountMinor))]);
        var change = restore with
        {
            Name = "Topluluk+",
            MaxMembers = 12000,
            Prices = [.. restore.Prices.Select(p => p with { AmountMinor = p.AmountMinor + 100 })],
        };
        var url = Path("/admin/plans/community");

        try
        {
            Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PutAsJsonAsync(url, change, Ct)).StatusCode);
            Assert.Equal(HttpStatusCode.BadRequest,
                (await factory.ClientFor(admin).PutAsJsonAsync(url, change with { Prices = change.Prices.Take(3).ToList() }, Ct)).StatusCode);
            Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PutAsJsonAsync(url, change, Ct)).StatusCode);

            var updated = (await factory.ClientFor(admin).GetFromJsonAsync<List<AdminPlan>>("/admin/plans", Ct))!.Single(p => p.Slug == "community");
            Assert.Equal(("Topluluk+", 12000), (updated.Name, updated.MaxMembers));
            Assert.Equal(200000, updated.Prices.Single(p => p is { Currency: "TRY", Period: "month" }).AmountMinor);
            Assert.True(await _db.ScalarAsync<long>(
                "select count(*) from public.audit_log where action = 'plan.updated' and target_id = 'community'") > 0);
        }
        finally
        {
            (await factory.ClientFor(admin).PutAsJsonAsync(url, restore, Ct)).EnsureSuccessStatusCode();
        }
    }
}
