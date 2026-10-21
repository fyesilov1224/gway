using System.Net;
using System.Text.Json;
using GrupX.Modules.Billing.Providers;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Database;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;
using NpgsqlTypes;

namespace GrupX.Modules.Billing;

public sealed record OfferOption(
    string PlanSlug,
    string Period,
    int AmountMinor,
    string Change,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    long CreditSeconds,
    bool Available);

public sealed record OfferResponse(
    Market Market,
    bool PurchasesEnabled,
    string CurrentPlanSlug,
    int SalesTermsVersion,
    IReadOnlyList<OfferOption> Options);

public sealed record CreateOrderRequest(string? PlanSlug, string? Period, string? Currency, int SalesTermsVersion, BillingDetails? Billing);

public sealed record CreateOrderResponse(Guid OrderId, Uri PaymentUrl);

/// <summary>Offers and checkout (docs/ARCHITECTURE.md §7, Satın alma akışı). Settlement is <see cref="PaymentService"/>.</summary>
internal sealed class CheckoutService(
    NpgsqlDataSource db,
    PaytrClient paytr,
    IyzicoClient iyzico,
    IOptions<BillingOptions> options,
    TimeProvider time,
    ILogger<CheckoutService> log)
{
    private bool PurchasesEnabled(Market market) =>
        market.Provider == PaymentProviders.Paytr ? paytr.IsConfigured : iyzico.IsConfigured;

    public Task<Result<OfferResponse>> GetOfferAsync(Guid actorId, Guid groupId, Market market, CancellationToken ct) =>
        BillingStore.RunAsync<OfferResponse>(db, async (conn, tx) =>
        {
            var group = await BillingStore.AuthorizeAsync(conn, tx, groupId, actorId, lockGroup: false, ct);
            if (!group.IsSuccess) return group.Error;

            var now = time.GetUtcNow();
            var plans = await BillingStore.PlansAsync(conn, tx, ct);
            var prices = await BillingStore.PricesAsync(conn, tx, market.Currency, ct);
            var slices = await BillingStore.LiveSlicesAsync(conn, tx, groupId, now, ct);
            int? Price(string plan, string period) => prices.TryGetValue((plan, period), out var p) ? p : null;

            var offers = new List<OfferOption>();
            foreach (var plan in plans.Where(p => p.IsActive))
            {
                foreach (var period in Periods.All)
                {
                    if (Price(plan.Slug, period) is not { } amount) continue;
                    var placement = SubscriptionTimeline.Place(now, slices, plan.Slug, plan.Tier, period, Price);
                    // Too far ahead: still show where it would go, but it cannot be bought now.
                    var shown = placement.IsSuccess
                        ? placement.Value
                        : SubscriptionTimeline.Place(now, slices, plan.Slug, plan.Tier, period, Price, enforceMaxAhead: false).Value;
                    offers.Add(new OfferOption(plan.Slug, period, amount, shown.Kind, shown.StartsAt, shown.EndsAt,
                        (long)shown.Credit.TotalSeconds, placement.IsSuccess));
                }
            }

            var current = slices.FirstOrDefault(s => s.StartsAt <= now && now < s.EndsAt)?.PlanSlug ?? "free";
            var terms = await BillingStore.SalesTermsVersionAsync(conn, tx, ct) ?? 0;
            return new OfferResponse(market, PurchasesEnabled(market), current, terms, offers);
        }, ct);

    public async Task<Result<CreateOrderResponse>> CreateOrderAsync(
        Guid actorId, Guid groupId, CreateOrderRequest request, Market market, IPAddress? clientIp, CancellationToken ct)
    {
        if (request.Period is not { } period || !Periods.All.Contains(period)) return BillingErrors.InvalidPeriod;
        var details = (request.Billing ?? new BillingDetails(null, null, null, null, null, null)).Validate();
        if (!details.IsSuccess) return details.Error;
        if (request.Currency != market.Currency) return BillingErrors.MarketChanged;
        if (!PurchasesEnabled(market)) return BillingErrors.ProviderUnavailable;

        var ip = clientIp is { IsIPv4MappedToIPv6: true } ? clientIp.MapToIPv4() : clientIp;
        var opened = await BillingStore.RunAsync<OpenedOrder>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);
            var group = await BillingStore.AuthorizeAsync(conn, tx, groupId, actorId, lockGroup: true, ct);
            if (!group.IsSuccess) return group.Error;

            var plan = (await BillingStore.PlansAsync(conn, tx, ct)).FirstOrDefault(p => p.Slug == request.PlanSlug && p.IsActive);
            var prices = await BillingStore.PricesAsync(conn, tx, market.Currency, ct);
            if (plan is null || !prices.TryGetValue((plan.Slug, period), out var amount)) return BillingErrors.PlanNotForSale;
            if (await BillingStore.SalesTermsVersionAsync(conn, tx, ct) != request.SalesTermsVersion) return BillingErrors.TermsOutdated;

            var now = time.GetUtcNow();
            var slices = await BillingStore.LiveSlicesAsync(conn, tx, groupId, now, ct);
            var placement = SubscriptionTimeline.Place(now, slices, plan.Slug, plan.Tier, period,
                (p, q) => prices.TryGetValue((p, q), out var v) ? v : null);
            if (!placement.IsSuccess) return placement.Error;

            string email;
            await using (var findEmail = new NpgsqlCommand("select email from auth.users where id = @id", conn, tx))
            {
                findEmail.Parameters.AddWithValue("id", actorId);
                email = (string)(await findEmail.ExecuteScalarAsync(ct))!;
            }

            await using var insert = new NpgsqlCommand(
                """
                insert into public.billing_orders (group_id, group_name, group_handle, buyer_id, plan_slug, period, provider,
                                                   country, currency, amount_minor, billing_details, sales_terms_version, client_ip)
                values (@group, @name, @handle, @buyer, @plan, @period, @provider, @country, @currency, @amount, @details, @terms, @ip)
                returning id
                """, conn, tx);
            insert.Parameters.AddWithValue("group", groupId);
            insert.Parameters.AddWithValue("name", group.Value.Name);
            insert.Parameters.AddWithValue("handle", group.Value.Handle);
            insert.Parameters.AddWithValue("buyer", actorId);
            insert.Parameters.AddWithValue("plan", plan.Slug);
            insert.Parameters.AddWithValue("period", period);
            insert.Parameters.AddWithValue("provider", market.Provider);
            insert.Parameters.AddWithValue("country", market.Country);
            insert.Parameters.AddWithValue("currency", market.Currency);
            insert.Parameters.AddWithValue("amount", amount);
            insert.Parameters.Add(new NpgsqlParameter("details", NpgsqlDbType.Jsonb)
            {
                Value = JsonSerializer.Serialize(details.Value, JsonSerializerOptions.Web),
            });
            insert.Parameters.AddWithValue("terms", request.SalesTermsVersion);
            insert.Parameters.Add(new NpgsqlParameter<IPAddress?>("ip", NpgsqlDbType.Inet) { TypedValue = ip });

            return new OpenedOrder((Guid)(await insert.ExecuteScalarAsync(ct))!, group.Value.Handle, plan.Name, amount, email);
        }, ct);
        if (!opened.IsSuccess) return opened.Error;

        var order = opened.Value;
        var started = await StartPaymentAsync(order, period, market, details.Value, ip, actorId, ct);
        await RecordStartAsync(order.Id, started, ct);
        return started.IsSuccess ? new CreateOrderResponse(order.Id, started.Value.PaymentUrl) : started.Error;
    }

    private sealed record OpenedOrder(Guid Id, string Handle, string PlanName, int AmountMinor, string Email);

    private async Task<Result<(string Token, Uri PaymentUrl)>> StartPaymentAsync(
        OpenedOrder order, string period, Market market, BillingDetails details, IPAddress? ip, Guid buyerId, CancellationToken ct)
    {
        var o = options.Value;
        try
        {
            if (market.Provider == PaymentProviders.Paytr)
            {
                return await paytr.StartAsync(new PaytrCheckout(
                    order.Id.ToString("N"),
                    ip?.ToString() ?? "127.0.0.1",
                    order.Email,
                    order.AmountMinor,
                    $"GrupX {order.PlanName} paketi ({(period == Periods.Year ? "yıllık" : "aylık")}) - @{order.Handle}",
                    $"{details.FirstName} {details.LastName}",
                    $"{details.Address}, {details.City}, {details.Country}",
                    details.Phone!,
                    BillingLinks.Plan(o, order.Handle, order.Id)), ct);
            }

            return await iyzico.StartAsync(new IyzicoCheckout(
                order.Id,
                order.AmountMinor,
                market.Currency,
                $"GrupX {order.PlanName} ({(period == Periods.Year ? "yearly" : "monthly")}) - @{order.Handle}",
                new IyzicoBuyer(buyerId, details.FirstName!, details.LastName!, order.Email, details.Phone!, details.Address!,
                    details.City!, details.Country!, ip?.ToString() ?? "127.0.0.1"),
                BillingLinks.IyzicoCallback(o, order.Id)), ct);
        }
        catch (Exception ex) when (ex is HttpRequestException or JsonException or TaskCanceledException && !ct.IsCancellationRequested)
        {
            log.LogWarning(ex, "Payment provider {Provider} unreachable for order {OrderId}", market.Provider, order.Id);
            return BillingErrors.ProviderFailed;
        }
    }

    /// <summary>Keeps the provider token for settlement, or closes an order the provider refused.</summary>
    private async Task RecordStartAsync(Guid orderId, Result<(string Token, Uri PaymentUrl)> started, CancellationToken ct)
    {
        await using var cmd = started.IsSuccess
            ? db.CreateCommand("update public.billing_orders set provider_token = @token where id = @id")
            : db.CreateCommand("update public.billing_orders set status = 'failed', failure_reason = 'provider_rejected' where id = @id");
        cmd.Parameters.AddWithValue("id", orderId);
        if (started.IsSuccess) cmd.Parameters.AddWithValue("token", started.Value.Token);
        await cmd.ExecuteNonQueryAsync(CancellationToken.None);
    }
}

internal static class BillingLinks
{
    /// <summary>The group's plan screen in the web app (hash routes), showing <paramref name="orderId"/>.</summary>
    public static Uri Plan(BillingOptions options, string handle, Guid orderId) =>
        new($"{options.AppUrl.TrimEnd('/')}/#/g/{handle}/plan?order={orderId}");

    public static Uri IyzicoCallback(BillingOptions options, Guid orderId) =>
        new($"{options.PublicApiUrl.TrimEnd('/')}/billing/iyzico/callback?order={orderId}");
}
