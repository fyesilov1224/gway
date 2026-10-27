using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Billing;
using GrupX.Modules.Billing.Contracts;
using GrupX.Modules.Groups;
using Microsoft.AspNetCore.Mvc.Testing;

namespace GrupX.Api.Tests;

public sealed class BillingTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    private static readonly BillingDetails Details = new("Ada", "Yilmaz", "+90 555 000 00 00", "Moda Cad. 1, Kadikoy", "Istanbul", "Turkiye");

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private HttpClient ClientFor(Guid user, string country = "TR")
    {
        var client = factory.ClientFor(user);
        client.DefaultRequestHeaders.Add(ApiFactory.CountryHeader, country);
        return client;
    }

    private async Task<(Guid Owner, Guid Group)> GroupAsync()
    {
        var owner = await _db.CreateUserAsync(Unique("o_"));
        var response = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Pedal Grubu", "cycling", "open", null), Ct);
        response.EnsureSuccessStatusCode();
        return (owner, (await response.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id);
    }

    private async Task<OfferResponse> OfferAsync(Guid owner, Guid group, string country = "TR")
    {
        var response = await ClientFor(owner, country).GetAsync(Path($"/billing/groups/{group}/offer"), Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<OfferResponse>(Ct))!;
    }

    private Task<HttpResponseMessage> OrderAsync(
        Guid owner, Guid group, string plan = "starter", string period = "month", string currency = "TRY",
        string country = "TR", int terms = 1, BillingDetails? details = null) =>
        ClientFor(owner, country).PostAsJsonAsync(
            Path($"/billing/groups/{group}/orders"), new CreateOrderRequest(plan, period, currency, terms, details ?? Details), Ct);

    private async Task<Guid> OrderIdAsync(Guid owner, Guid group, string plan = "starter", string currency = "TRY", string country = "TR")
    {
        var response = await OrderAsync(owner, group, plan, currency: currency, country: country);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!.OrderId;
    }

    private async Task<HttpResponseMessage> NotifyPaytrAsync(Guid order, string status, int total)
    {
        using var form = FakePaymentProviders.PaytrNotification(order, status, total);
        return await factory.CreateClient().PostAsync(Path("/billing/paytr/notify"), form, Ct);
    }

    private Task<string?> OrderStatusAsync(Guid order) =>
        _db.ScalarAsync<string>("select status from public.billing_orders where id = @id", ("id", order));

    private Task<long> SubscriptionCountAsync(Guid group) =>
        _db.ScalarAsync<long>("select count(*) from public.group_subscriptions where group_id = @g and ends_at > now()", ("g", group));

    private Task<string?> CurrentPlanAsync(Guid group) =>
        _db.ScalarAsync<string>("select private.group_plan_slug(@g)", ("g", group));

    // Offer ----------------------------------------------------------------------------

    [Fact]
    public async Task Offer_depends_on_the_country_of_the_request()
    {
        var (owner, group) = await GroupAsync();

        var tr = await OfferAsync(owner, group, "TR");
        var de = await OfferAsync(owner, group, "DE");

        Assert.Equal(new Market("TR", "paytr", "TRY"), tr.Market);
        Assert.Equal(new Market("DE", "iyzico", "USD"), de.Market);
        Assert.Equal("free", tr.CurrentPlanSlug);
        Assert.True(tr.PurchasesEnabled);
        Assert.Equal(1, tr.SalesTermsVersion);
        Assert.Equal(24900, tr.Options.Single(o => o is { PlanSlug: "starter", Period: "month" }).AmountMinor);
        Assert.Equal(999, de.Options.Single(o => o is { PlanSlug: "starter", Period: "month" }).AmountMinor);
        Assert.All(tr.Options, o => Assert.Equal(ChangeKinds.Upgrade, o.Change));
        Assert.DoesNotContain(tr.Options, o => o.PlanSlug == "free");
    }

    [Fact]
    public async Task Only_the_owner_sees_offers_and_orders()
    {
        var (_, group) = await GroupAsync();
        var member = await _db.CreateUserAsync(Unique("m_"));
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();

        Assert.Equal(HttpStatusCode.Forbidden, (await ClientFor(member).GetAsync(Path($"/billing/groups/{group}/offer"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await OrderAsync(member, group)).StatusCode);
    }

    // Checkout --------------------------------------------------------------------------

    [Fact]
    public async Task Turkish_checkout_opens_a_paytr_payment_at_the_list_price()
    {
        var (owner, group) = await GroupAsync();

        var response = await OrderAsync(owner, group);

        response.EnsureSuccessStatusCode();
        var order = (await response.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!;
        Assert.StartsWith($"{FakePaymentProviders.PaytrUrl}/odeme/guvenli/tok-", order.PaymentUrl.ToString(), StringComparison.Ordinal);
        Assert.Equal("pending", await OrderStatusAsync(order.OrderId));

        var form = factory.Payments.PaytrForms[order.OrderId.ToString("N")];
        Assert.Equal("24900", form["payment_amount"]);
        Assert.Equal("TL", form["currency"]);
        Assert.Equal($"http://localhost:3000/#/g/{await HandleAsync(group)}/plan?order={order.OrderId}", form["merchant_ok_url"]);
        var expectedToken = Convert.ToBase64String(HMACSHA256.HashData(Encoding.UTF8.GetBytes(ApiFactory.PaytrKey), Encoding.UTF8.GetBytes(
            form["merchant_id"] + form["user_ip"] + form["merchant_oid"] + form["email"] + form["payment_amount"] + form["user_basket"]
            + form["no_installment"] + form["max_installment"] + form["currency"] + form["test_mode"] + ApiFactory.PaytrSalt)));
        Assert.Equal(expectedToken, form["paytr_token"]);
    }

    private Task<string?> HandleAsync(Guid group) => _db.ScalarAsync<string>("select handle from public.groups where id = @id", ("id", group));

    [Fact]
    public async Task Checkout_rejects_stale_prices_terms_and_bad_details()
    {
        var (owner, group) = await GroupAsync();

        Assert.Equal(HttpStatusCode.Conflict, (await OrderAsync(owner, group, currency: "USD", country: "TR")).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await OrderAsync(owner, group, terms: 99)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await OrderAsync(owner, group, details: Details with { Phone = "abc" })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await OrderAsync(owner, group, plan: "free")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await OrderAsync(owner, group, period: "week")).StatusCode);
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.billing_orders where group_id = @g", ("g", group)));
    }

    [Fact]
    public async Task Checkout_is_closed_when_the_provider_is_not_configured()
    {
        await using var unconfigured = factory.WithWebHostBuilder(b => b.UseSetting("Billing:Iyzico:ApiKey", ""));
        var (owner, group) = await GroupAsync();
        var client = unconfigured.CreateClient();
        client.DefaultRequestHeaders.Authorization = new("Bearer", ApiFactory.CreateToken(owner));
        client.DefaultRequestHeaders.Add(ApiFactory.CountryHeader, "DE");

        var response = await client.PostAsJsonAsync(
            Path($"/billing/groups/{group}/orders"), new CreateOrderRequest("starter", "month", "USD", 1, Details), Ct);

        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    // PayTR settlement --------------------------------------------------------------------

    [Fact]
    public async Task Verified_paytr_notification_activates_the_plan_once()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group);

        var first = await NotifyPaytrAsync(order, "success", 24900);
        var again = await NotifyPaytrAsync(order, "success", 24900);

        Assert.Equal("OK", await first.Content.ReadAsStringAsync(Ct));
        Assert.Equal("OK", await again.Content.ReadAsStringAsync(Ct));
        Assert.Equal("paid", await OrderStatusAsync(order));
        Assert.Equal(1L, await SubscriptionCountAsync(group));
        Assert.Equal("starter", await CurrentPlanAsync(group));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'subscription.activated' and group_id = @g", ("g", group)));
    }

    [Fact]
    public async Task Forged_or_mismatched_paytr_notifications_change_nothing_useful()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group);

        using var forged = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["merchant_oid"] = order.ToString("N"), ["status"] = "success", ["total_amount"] = "24900", ["hash"] = "forged",
        });
        var rejected = await factory.CreateClient().PostAsync(Path("/billing/paytr/notify"), forged, Ct);
        Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);
        Assert.Equal("pending", await OrderStatusAsync(order));

        // Signed, but for a different amount: no plan, and staff are told.
        (await NotifyPaytrAsync(order, "success", 100)).EnsureSuccessStatusCode();
        Assert.Equal("failed", await OrderStatusAsync(order));
        Assert.Equal(0L, await SubscriptionCountAsync(group));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'billing.payment_mismatch' and target_id = @o", ("o", order.ToString())));
    }

    [Fact]
    public async Task Failed_payment_can_still_succeed_later_but_paid_never_fails()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group);

        await NotifyPaytrAsync(order, "failed", 24900);
        Assert.Equal("failed", await OrderStatusAsync(order));

        await NotifyPaytrAsync(order, "success", 24900);
        await NotifyPaytrAsync(order, "failed", 24900);
        Assert.Equal("paid", await OrderStatusAsync(order));
        Assert.Equal(1L, await SubscriptionCountAsync(group));
    }

    [Fact]
    public async Task Upgrade_replaces_the_current_slice_and_carries_its_time_over()
    {
        var (owner, group) = await GroupAsync();
        await NotifyPaytrAsync(await OrderIdAsync(owner, group, "starter"), "success", 24900);

        var offer = await OfferAsync(owner, group);
        Assert.Equal(ChangeKinds.Renewal, offer.Options.Single(o => o is { PlanSlug: "starter", Period: "month" }).Change);
        var pro = offer.Options.Single(o => o is { PlanSlug: "pro", Period: "month" });
        Assert.Equal(ChangeKinds.Upgrade, pro.Change);
        Assert.True(pro.CreditSeconds > 0);

        await NotifyPaytrAsync(await OrderIdAsync(owner, group, "pro"), "success", 69900);

        Assert.Equal("pro", await CurrentPlanAsync(group));
        Assert.Equal(1L, await SubscriptionCountAsync(group));
        Assert.Equal("upgraded", await _db.ScalarAsync<string>(
            "select cancel_reason from public.group_subscriptions where group_id = @g and plan_slug = 'starter'", ("g", group)));
        Assert.True(await _db.ScalarAsync<long>(
            "select credit_seconds from public.group_subscriptions where group_id = @g and plan_slug = 'pro'", ("g", group)) > 0);
    }

    // iyzico settlement -------------------------------------------------------------------

    [Fact]
    public async Task Iyzico_callback_settles_from_iyzicos_own_answer_and_returns_to_the_app()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group, currency: "USD", country: "DE");
        var token = $"iyz-{order}";
        factory.Payments.IyzicoDetails[token] = new
        {
            status = "success", paymentStatus = "SUCCESS", fraudStatus = 1, paidPrice = 9.99, currency = "USD",
            basketId = order.ToString(), paymentId = "pay-1",
        };

        var browser = factory.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
        using var form = new FormUrlEncodedContent(new Dictionary<string, string> { ["token"] = token });
        var response = await browser.PostAsync(Path($"/billing/iyzico/callback?order={order}"), form, Ct);

        Assert.Equal(HttpStatusCode.SeeOther, response.StatusCode);
        Assert.Equal($"http://localhost:3000/#/g/{await HandleAsync(group)}/plan?order={order}", response.Headers.Location?.ToString());
        Assert.Equal("paid", await OrderStatusAsync(order));
        Assert.Equal("starter", await CurrentPlanAsync(group));

        var init = factory.Payments.IyzicoRequests.Single(r => r.Path.EndsWith("/initialize/auth/ecom", StringComparison.Ordinal)
            && r.Body.Contains(order.ToString(), StringComparison.Ordinal));
        Assert.Equal(IyzicoAuthorization(init.RandomKey, init.Path, init.Body), init.Authorization);
        using var body = JsonDocument.Parse(init.Body);
        Assert.Equal("9.99", body.RootElement.GetProperty("paidPrice").GetString());
        Assert.Equal("USD", body.RootElement.GetProperty("currency").GetString());
    }

    private static string IyzicoAuthorization(string randomKey, string path, string body)
    {
        var signature = Convert.ToHexStringLower(HMACSHA256.HashData(
            Encoding.UTF8.GetBytes(ApiFactory.IyzicoSecret), Encoding.UTF8.GetBytes(randomKey + path + body)));
        return "IYZWSv2 " + Convert.ToBase64String(Encoding.UTF8.GetBytes($"apiKey:iyzico-test-key&randomKey:{randomKey}&signature:{signature}"));
    }

    [Fact]
    public async Task Iyzico_callback_with_a_claimed_success_does_nothing_until_iyzico_confirms()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group, currency: "USD", country: "DE");
        factory.Payments.IyzicoDetails[$"iyz-{order}"] = new
        {
            status = "success", paymentStatus = "INIT_THREEDS", fraudStatus = 0, paidPrice = 9.99, currency = "USD", basketId = order.ToString(),
        };

        var browser = factory.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
        using var form = new FormUrlEncodedContent(new Dictionary<string, string> { ["token"] = $"iyz-{order}", ["status"] = "success" });
        await browser.PostAsync(Path($"/billing/iyzico/callback?order={order}"), form, Ct);

        Assert.Equal("pending", await OrderStatusAsync(order));
        Assert.Equal("free", await CurrentPlanAsync(group));
    }

    [Fact]
    public async Task Iyzico_webhook_needs_a_valid_signature()
    {
        var (owner, group) = await GroupAsync();
        var order = await OrderIdAsync(owner, group, currency: "USD", country: "DE");
        var token = $"iyz-{order}";
        factory.Payments.IyzicoDetails[token] = new
        {
            status = "success", paymentStatus = "SUCCESS", fraudStatus = 1, paidPrice = 9.99, currency = "USD", basketId = order.ToString(),
        };
        var payload = JsonSerializer.Serialize(new
        {
            paymentConversationId = order.ToString(), merchantId = "1", token, status = "SUCCESS",
            iyziReferenceCode = "ref", iyziEventType = "CHECKOUT_FORM_AUTH", iyziEventTime = 1, iyziPaymentId = 555,
        });
        var signature = Convert.ToHexStringLower(HMACSHA256.HashData(Encoding.UTF8.GetBytes(ApiFactory.IyzicoSecret),
            Encoding.UTF8.GetBytes(ApiFactory.IyzicoSecret + "CHECKOUT_FORM_AUTH" + "555" + token + order + "SUCCESS")));

        async Task<HttpStatusCode> SendAsync(string sig)
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, Path("/billing/iyzico/webhook"))
            {
                Content = new StringContent(payload, Encoding.UTF8, "application/json"),
            };
            request.Headers.Add("X-IYZ-SIGNATURE-V3", sig);
            return (await factory.CreateClient().SendAsync(request, Ct)).StatusCode;
        }

        Assert.Equal(HttpStatusCode.Unauthorized, await SendAsync("00" + signature[2..]));
        Assert.Equal("pending", await OrderStatusAsync(order));
        Assert.Equal(HttpStatusCode.OK, await SendAsync(signature));
        Assert.Equal("paid", await OrderStatusAsync(order));
    }

    // Member limit --------------------------------------------------------------------------

    [Fact]
    public async Task A_full_group_takes_no_new_member_until_it_upgrades()
    {
        var (owner, group) = await GroupAsync();
        var joiner = await _db.CreateUserAsync(Unique("j_"));
        // Free plan: 50 members. Pretend the group is full.
        await _db.ExecuteAsync("update public.groups set member_count = 50 where id = @id", ("id", group));

        var full = await factory.ClientFor(joiner).PostAsync(Path($"/groups/{group}/join"), null, Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, full.StatusCode);
        Assert.Contains("group.member_limit_reached", await full.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);

        await NotifyPaytrAsync(await OrderIdAsync(owner, group), "success", 24900);
        (await factory.ClientFor(joiner).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task Premium_is_bought_by_the_person_and_stacks_after_the_time_left()
    {
        var buyer = await _db.CreateUserAsync(Unique("b_"));
        var offer = await ClientFor(buyer).GetFromJsonAsync<PersonalOfferResponse>(Path("/billing/me/plans/matching_premium/offer"), Ct);
        Assert.Null(offer!.ActiveUntil);
        Assert.Equal([24900, 249000], offer.Options.Select(o => o.AmountMinor));

        async Task<Guid> BuyAsync()
        {
            var response = await ClientFor(buyer).PostAsJsonAsync(Path("/billing/me/plans/matching_premium/orders"),
                new CreatePersonalOrderRequest("month", "TRY", 1, Details), Ct);
            response.EnsureSuccessStatusCode();
            var order = (await response.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!.OrderId;
            (await NotifyPaytrAsync(order, "success", 24900)).EnsureSuccessStatusCode();
            return order;
        }

        Assert.Equal("paid", await OrderStatusAsync(await BuyAsync()));
        Assert.True(await _db.ScalarAsync<bool>("select private.has_matching_premium(@id)", ("id", buyer)));
        await BuyAsync();
        Assert.Equal(2L, await _db.ScalarAsync<long>("select count(*) from public.user_subscriptions where user_id = @id", ("id", buyer)));
        Assert.True(await _db.ScalarAsync<bool>(
            "select private.personal_plan_until(@id, 'matching_premium') > now() + interval '55 days'", ("id", buyer)));
        Assert.Equal(2L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'personal_plan.activated' and target_id in "
            + "(select id::text from public.user_subscriptions where user_id = @id)", ("id", buyer)));
    }

    [Fact]
    public async Task An_admin_grants_lists_and_cancels_a_persons_packages()
    {
        var buyer = await _db.CreateUserAsync(Unique("b_"));
        var (admin, support) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(admin, "admin");
        await _db.MakeStaffAsync(support, "support");

        // Bought time, then granted time after it.
        var response = await ClientFor(buyer).PostAsJsonAsync(Path("/billing/me/plans/matching_premium/orders"),
            new CreatePersonalOrderRequest("month", "TRY", 1, Details), Ct);
        var order = (await response.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!.OrderId;
        (await NotifyPaytrAsync(order, "success", 24900)).EnsureSuccessStatusCode();
        var grant = new GrantUserPackageRequest("matching_premium", 10, "Destek telafisi");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await ClientFor(support).PostAsJsonAsync(Path($"/admin/users/{buyer}/packages"), grant, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await ClientFor(admin).PostAsJsonAsync(Path($"/admin/users/{buyer}/packages"), grant, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await ClientFor(admin).PostAsJsonAsync(Path($"/admin/users/{Guid.NewGuid()}/packages"), grant, Ct))
            .StatusCode);

        var slices = await ClientFor(support).GetFromJsonAsync<List<PersonalSubscription>>(Path($"/admin/users/{buyer}/packages"), Ct);
        Assert.Equal(2, slices!.Count);
        Assert.Equal("Destek telafisi", slices[0].GrantReason);
        Assert.Equal(order, slices[1].OrderId);

        var cancel = new CancelSubscriptionRequest("Kullanıcı isteği", Refunded: true);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await ClientFor(support).PostAsJsonAsync(Path($"/admin/users/{buyer}/packages/matching_premium/cancellation"), cancel, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await ClientFor(admin).PostAsJsonAsync(Path($"/admin/users/{buyer}/packages/matching_premium/cancellation"), cancel, Ct)).StatusCode);
        Assert.False(await _db.ScalarAsync<bool>("select private.has_matching_premium(@id)", ("id", buyer)));
        Assert.Null(await _db.ScalarAsync<DateTime?>("select private.personal_plan_until(@id, 'matching_premium')", ("id", buyer)));
        Assert.Equal("refunded", await OrderStatusAsync(order));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'personal_plan.canceled' and target_id = @id", ("id", buyer.ToString())));
        // Nothing left to cancel.
        Assert.Equal(HttpStatusCode.NotFound,
            (await ClientFor(admin).PostAsJsonAsync(Path($"/admin/users/{buyer}/packages/matching_premium/cancellation"), cancel, Ct)).StatusCode);
    }

    [Fact]
    public async Task A_personal_order_paid_after_the_buyer_is_deleted_settles_without_a_slice()
    {
        var buyer = await _db.CreateUserAsync(Unique("b_"));
        var response = await ClientFor(buyer).PostAsJsonAsync(Path("/billing/me/plans/matching_premium/orders"),
            new CreatePersonalOrderRequest("month", "TRY", 1, Details), Ct);
        response.EnsureSuccessStatusCode();
        var order = (await response.Content.ReadFromJsonAsync<CreateOrderResponse>(Ct))!.OrderId;
        await _db.ExecuteAsync("delete from auth.users where id = @id", ("id", buyer));

        // PayTR must read "OK" or it retries forever.
        (await NotifyPaytrAsync(order, "success", 24900)).EnsureSuccessStatusCode();
        Assert.Equal("paid", await OrderStatusAsync(order));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.user_subscriptions where order_id = @id", ("id", order)));
    }
}
