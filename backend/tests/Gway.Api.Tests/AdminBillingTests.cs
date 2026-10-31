using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Billing;
using Gway.Modules.Billing.Contracts;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

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
        // A profile, as staff who give plans are named on them.
        var id = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    /// <summary>A group on the free plan and its owner's client.</summary>
    private async Task<(CreatedGroup Group, HttpClient Owner)> FreeGroupAsync()
    {
        var owner = await _db.CreateUserAsync(Unique("o_"));
        var owners = factory.ClientFor(owner);
        owners.DefaultRequestHeaders.Add(ApiFactory.CountryHeader, "TR");
        var created = await owners.PostAsJsonAsync(Path("/groups"), new CreateGroupRequest(Unique("ab_"), "Abone Grup", "music", "open", null), Ct);
        return ((await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!, owners);
    }

    /// <summary>A group with a paid monthly Başlangıç plan.</summary>
    private async Task<(CreatedGroup Group, Guid Order)> PaidGroupAsync()
    {
        var (group, owners) = await FreeGroupAsync();

        var ordered = await owners.PostAsJsonAsync(Path($"/billing/groups/{group.Id}/orders"), new CreateOrderRequest(
            "starter", "month", "TRY", BillingTests.SalesTerms, new BillingDetails("Ada", "Yilmaz", "05550000000", "Moda Cad. 1", "Istanbul", "Turkiye")), Ct);
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
        Assert.Equal("Kullanıcı talebiyle iade edildi", await _db.ScalarAsync<string>(
            "select cancel_note from public.group_subscriptions where id = @s", ("s", subscription)));
    }

    [Fact]
    public async Task Admin_gives_a_free_group_a_plan_with_a_reason_and_support_cannot()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");
        var (group, _) = await FreeGroupAsync();
        var url = Path($"/admin/groups/{group.Id}/plan");
        var body = new GrantGroupPlanRequest("pro", 30, "Festival sponsorluğu");

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PostAsJsonAsync(url, body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(admin).PostAsJsonAsync(url, body with { Reason = "x" }, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(admin).PostAsJsonAsync(url, body with { Days = 0 }, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(admin).PostAsJsonAsync(url, body with { Slug = "free" }, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await factory.ClientFor(admin).PostAsJsonAsync(Path($"/admin/groups/{Guid.NewGuid()}/plan"), body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PostAsJsonAsync(url, body, Ct)).StatusCode);

        Assert.Equal("pro", await _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group.Id)));
        var detail = await factory.ClientFor(support).GetFromJsonAsync<AdminGroupDetail>($"/admin/groups/{group.Id}", Ct);
        var slice = Assert.Single(detail!.Subscriptions);
        Assert.Equal("Festival sponsorluğu", slice.GrantReason);
        Assert.Null(slice.OrderId);
        Assert.Null(slice.Period);
        Assert.NotNull(slice.GrantedByUsername);
        Assert.Equal(30, (int)Math.Round((slice.EndsAt - slice.StartsAt).TotalDays));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'subscription.granted' and group_id = @g", ("g", group.Id)));
    }

    [Fact]
    public async Task A_higher_plan_starts_now_with_the_paid_time_carried_over_and_a_lower_one_follows()
    {
        var admin = await StaffAsync("admin");
        var (group, order) = await PaidGroupAsync();
        var url = Path($"/admin/groups/{group.Id}/plan");

        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(admin).PostAsJsonAsync(url, new GrantGroupPlanRequest("pro", 30, "Yükseltme hediyesi"), Ct)).StatusCode);
        Assert.Equal("pro", await _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group.Id)));
        Assert.Equal("upgraded", await _db.ScalarAsync<string>(
            "select cancel_reason from public.group_subscriptions where order_id = @o", ("o", order)));
        Assert.True(await _db.ScalarAsync<long>(
            "select credit_seconds from public.group_subscriptions where group_id = @g and order_id is null", ("g", group.Id)) > 0);

        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(admin).PostAsJsonAsync(url, new GrantGroupPlanRequest("starter", 10, "Ek süre"), Ct)).StatusCode);
        Assert.Equal("pro", await _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group.Id)));
        Assert.True(await _db.ScalarAsync<bool>(
            """
            select s.starts_at = (select max(p.ends_at) from public.group_subscriptions p where p.group_id = s.group_id and p.plan_slug = 'pro')
            from public.group_subscriptions s where s.group_id = @g and s.plan_slug = 'starter' and s.order_id is null
            """, ("g", group.Id)));
    }

    [Fact]
    public async Task Admin_cancels_the_whole_plan_and_the_reason_is_kept()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");
        var (group, order) = await PaidGroupAsync();
        (await factory.ClientFor(admin).PostAsJsonAsync(Path($"/admin/groups/{group.Id}/plan"),
            new GrantGroupPlanRequest("starter", 30, "Ek süre"), Ct)).EnsureSuccessStatusCode();
        var url = Path($"/admin/groups/{group.Id}/plan/cancellation");
        var body = new CancelSubscriptionRequest("Topluluk kuralları ihlali", Refunded: true);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).PostAsJsonAsync(url, body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(admin).PostAsJsonAsync(url, body, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(admin).PostAsJsonAsync(url, body, Ct)).StatusCode);

        Assert.Equal("free", await _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group.Id)));
        Assert.Equal("refunded", await _db.ScalarAsync<string>("select status from public.billing_orders where id = @o", ("o", order)));
        Assert.Equal(2L, await _db.ScalarAsync<long>(
            "select count(*) from public.group_subscriptions where group_id = @g and cancel_note = 'Topluluk kuralları ihlali'", ("g", group.Id)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'group_plan.canceled' and group_id = @g", ("g", group.Id)));
    }

    [Fact]
    public async Task Admins_see_the_provider_setup_and_the_addresses_to_enter_but_never_a_key()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).GetAsync(Path("/admin/billing/providers"), Ct)).StatusCode);

        var response = await factory.ClientFor(admin).GetAsync(Path("/admin/billing/providers"), Ct);
        var text = await response.Content.ReadAsStringAsync(Ct);
        Assert.DoesNotContain(ApiFactory.PaytrKey, text, StringComparison.Ordinal);
        Assert.DoesNotContain(ApiFactory.PaytrSalt, text, StringComparison.Ordinal);
        Assert.DoesNotContain(ApiFactory.IyzicoSecret, text, StringComparison.Ordinal);

        var status = (await response.Content.ReadFromJsonAsync<PaymentProvidersStatus>(Ct))!;
        var paytr = status.Providers.Single(p => p.Provider == "paytr");
        var iyzico = status.Providers.Single(p => p.Provider == "iyzico");
        Assert.True(paytr.Configured && iyzico.Configured);
        Assert.Equal("http://api.test/billing/paytr/notify", Assert.Single(paytr.Addresses).Url);
        Assert.Equal("http://api.test/billing/iyzico/webhook", Assert.Single(iyzico.Addresses).Url);
        // The test API address is plain http, so both are warned.
        Assert.Contains(paytr.Warnings, w => w.Contains("https", StringComparison.Ordinal));
        Assert.Contains(paytr.Warnings, w => w.Contains("Test modu", StringComparison.Ordinal));
        Assert.False(iyzico.TestMode);
    }

    [Fact]
    public async Task Admins_check_the_provider_keys()
    {
        var admin = await StaffAsync("admin");
        var support = await StaffAsync("support");
        var admins = factory.ClientFor(admin);

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).PostAsync(Path("/admin/billing/providers/paytr/check"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await admins.PostAsync(Path("/admin/billing/providers/stripe/check"), null, Ct)).StatusCode);

        foreach (var provider in new[] { "paytr", "iyzico" })
        {
            var check = await (await admins.PostAsync(Path($"/admin/billing/providers/{provider}/check"), null, Ct))
                .Content.ReadFromJsonAsync<ProviderCheck>(Ct);
            Assert.True(check!.Connected, provider);
        }
        Assert.StartsWith("IYZWSv2 ", factory.Payments.IyzicoRequests.Last(r => r.Path == "/payment/iyzipos/installment").Authorization,
            StringComparison.Ordinal);

        factory.Payments.Refuse = true;
        try
        {
            var paytr = await (await admins.PostAsync(Path("/admin/billing/providers/paytr/check"), null, Ct)).Content.ReadFromJsonAsync<ProviderCheck>(Ct);
            Assert.False(paytr!.Connected);
            Assert.Contains("test refusal", paytr.Message, StringComparison.Ordinal);

            var iyzico = await (await admins.PostAsync(Path("/admin/billing/providers/iyzico/check"), null, Ct)).Content.ReadFromJsonAsync<ProviderCheck>(Ct);
            Assert.False(iyzico!.Connected);
            Assert.Contains("1001", iyzico.Message, StringComparison.Ordinal);
        }
        finally
        {
            factory.Payments.Refuse = false;
        }
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
