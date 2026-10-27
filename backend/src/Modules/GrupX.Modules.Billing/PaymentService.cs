using System.Globalization;
using GrupX.Modules.Billing.Providers;
using GrupX.SharedKernel.Auditing;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace GrupX.Modules.Billing;

/// <summary>What a verified provider says about an order.</summary>
internal abstract record PaymentOutcome
{
    public sealed record Paid(int AmountMinor, string Currency, string? PaymentId) : PaymentOutcome;

    public sealed record Failed(string Reason) : PaymentOutcome;
}

/// <summary>An order a provider answered for, so the buyer can be sent back to it: a group's plan or a personal plan.</summary>
internal sealed record OrderRef(Guid Id, string? GroupHandle, string? PersonalPlan);

/// <summary>
/// Settles orders from verified provider notifications only (docs/ARCHITECTURE.md §7, Satın alma akışı).
/// Idempotent: a settled order is never processed twice; a paid order never goes back.
/// </summary>
internal sealed class PaymentService(NpgsqlDataSource db, PaytrClient paytr, IyzicoClient iyzico, TimeProvider time, ILogger<PaymentService> log)
{
    /// <summary>Handles a PayTR notification. False when its hash is wrong (nothing is changed).</summary>
    public async Task<bool> HandlePaytrAsync(IFormCollection form, CancellationToken ct)
    {
        string F(string key) => form[key].ToString();
        if (!paytr.Verify(F("merchant_oid"), F("status"), F("total_amount"), F("hash"))) return false;

        if (!Guid.TryParseExact(F("merchant_oid"), "N", out var orderId))
        {
            log.LogWarning("PayTR notification for unknown order {MerchantOid}", F("merchant_oid"));
            return true;
        }

        PaymentOutcome outcome = F("status") == "success"
            ? new PaymentOutcome.Paid(
                int.TryParse(F("total_amount"), NumberStyles.None, CultureInfo.InvariantCulture, out var total) ? total : -1,
                Currencies.Try, null)
            : new PaymentOutcome.Failed($"paytr:{F("failed_reason_code")}");
        await SettleAsync(orderId, PaymentProviders.Paytr, outcome, ct);
        return true;
    }

    /// <summary>
    /// Settles the iyzico order holding <paramref name="token"/> from iyzico's own answer (callback and webhook only
    /// trigger this). Null when no order has the token.
    /// </summary>
    public async Task<OrderRef?> HandleIyzicoAsync(Guid? orderId, string token, CancellationToken ct)
    {
        OrderRef? order;
        await using (var find = db.CreateCommand(
            """
            select id, group_handle, personal_plan_slug from public.billing_orders
            where provider = 'iyzico' and provider_token = @token and (@id::uuid is null or id = @id)
            """))
        {
            find.Parameters.AddWithValue("token", token);
            find.Parameters.Add(new NpgsqlParameter<Guid?>("id", orderId));
            await using var reader = await find.ExecuteReaderAsync(ct);
            order = await reader.ReadAsync(ct)
                ? new OrderRef(reader.GetGuid(0), reader.IsDBNull(1) ? null : reader.GetString(1), reader.IsDBNull(2) ? null : reader.GetString(2))
                : null;
        }
        if (order is null) return null;

        IyzicoPayment? payment;
        try
        {
            payment = await iyzico.RetrieveAsync(token, order.Id, ct);
        }
        catch (Exception ex) when (ex is HttpRequestException or System.Text.Json.JsonException or TaskCanceledException && !ct.IsCancellationRequested)
        {
            log.LogWarning(ex, "iyzico unreachable while settling {OrderId}", order.Id);
            return order;
        }

        PaymentOutcome? outcome = payment switch
        {
            null => null,
            { BasketId: var basket } when basket != order.Id.ToString() => new PaymentOutcome.Failed("basket_mismatch"),
            { PaymentStatus: "SUCCESS", FraudStatus: 1 } => new PaymentOutcome.Paid(payment.PaidMinor, payment.Currency, payment.PaymentId),
            { PaymentStatus: "FAILURE" } => new PaymentOutcome.Failed("iyzico:failure"),
            { FraudStatus: -1 } => new PaymentOutcome.Failed("iyzico:fraud_rejected"),
            // Still in 3-D Secure or in fraud review: the webhook settles it later.
            _ => null,
        };
        if (outcome is not null) await SettleAsync(order.Id, PaymentProviders.Iyzico, outcome, ct);
        return order;
    }

    private sealed record OrderState(
        string Status, string Provider, Guid? GroupId, string? PlanSlug, string Period, string Currency, int AmountMinor,
        Guid BuyerId, string? PersonalPlan);

    private async Task SettleAsync(Guid orderId, string provider, PaymentOutcome outcome, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var order = await LockOrderAsync(conn, tx, orderId, ct);
        if (order is null || order.Provider != provider || order.Status is "paid" or "refunded") return;

        switch (outcome)
        {
            case PaymentOutcome.Failed failed:
                if (order.Status == "pending") await FailAsync(conn, tx, orderId, failed.Reason, ct);
                break;

            case PaymentOutcome.Paid paid when paid.AmountMinor != order.AmountMinor || paid.Currency != order.Currency:
                if (order.Status == "pending")
                {
                    await FailAsync(conn, tx, orderId, "amount_mismatch", ct);
                    await AuditLog.AppendAsync(conn, tx, new AuditEntry(null, AuditActor.System, "billing.payment_mismatch", "order",
                        orderId.ToString(), new
                        {
                            provider,
                            expected = order.AmountMinor,
                            expectedCurrency = order.Currency,
                            received = paid.AmountMinor,
                            receivedCurrency = paid.Currency,
                        }, order.GroupId), ct);
                }
                break;

            case PaymentOutcome.Paid paid:
                await MarkPaidAsync(conn, tx, orderId, paid.PaymentId, ct);
                if (order.PersonalPlan is { } personal)
                {
                    // The buyer has no foreign key (orders outlive accounts); a purged buyer gets no slice, the payment still settles.
                    if (await BuyerExistsAsync(conn, tx, order.BuyerId, ct)) await ActivatePersonalAsync(conn, tx, orderId, personal, order, ct);
                    else log.LogWarning("Order {OrderId} was paid after its buyer's account was deleted", orderId);
                }
                else if (order.GroupId is { } groupId) await ActivateAsync(conn, tx, orderId, groupId, order, ct);
                else log.LogWarning("Order {OrderId} was paid after its group was deleted", orderId);
                break;
        }

        await tx.CommitAsync(ct);
    }

    /// <summary>Places the paid slice on the group's timeline (docs/ARCHITECTURE.md §7, Abonelik modeli).</summary>
    private async Task ActivateAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid orderId, Guid groupId, OrderState order, CancellationToken ct)
    {
        // One timeline change per group at a time.
        await using (var lockGroup = new NpgsqlCommand("select 1 from public.groups where id = @id for update", conn, tx))
        {
            lockGroup.Parameters.AddWithValue("id", groupId);
            await lockGroup.ExecuteNonQueryAsync(ct);
        }

        var now = time.GetUtcNow();
        // A group order always names its plan (billing_orders_product).
        var planSlug = order.PlanSlug!;
        var tier = (await BillingStore.PlansAsync(conn, tx, ct)).First(p => p.Slug == planSlug).Tier;
        var prices = await BillingStore.PricesAsync(conn, tx, order.Currency, ct);
        var slices = await BillingStore.LiveSlicesAsync(conn, tx, groupId, now, ct);
        var placement = SubscriptionTimeline.Place(now, slices, planSlug, tier, order.Period,
            (p, q) => prices.TryGetValue((p, q), out var v) ? v : null, enforceMaxAhead: false).Value;

        if (placement.Replaced.Count > 0)
        {
            await using var replace = new NpgsqlCommand(
                """
                update public.group_subscriptions
                set ends_at = greatest(starts_at, @now), canceled_at = @now, cancel_reason = 'upgraded'
                where id = any(@ids)
                """, conn, tx);
            replace.Parameters.AddWithValue("now", now);
            replace.Parameters.AddWithValue("ids", placement.Replaced.ToArray());
            await replace.ExecuteNonQueryAsync(ct);
        }

        Guid subscriptionId;
        await using (var insert = new NpgsqlCommand(
            """
            insert into public.group_subscriptions (group_id, plan_slug, period, order_id, starts_at, ends_at, credit_seconds)
            values (@group, @plan, @period, @order, @starts, @ends, @credit)
            returning id
            """, conn, tx))
        {
            insert.Parameters.AddWithValue("group", groupId);
            insert.Parameters.AddWithValue("plan", planSlug);
            insert.Parameters.AddWithValue("period", order.Period);
            insert.Parameters.AddWithValue("order", orderId);
            insert.Parameters.AddWithValue("starts", placement.StartsAt);
            insert.Parameters.AddWithValue("ends", placement.EndsAt);
            insert.Parameters.AddWithValue("credit", (long)placement.Credit.TotalSeconds);
            subscriptionId = (Guid)(await insert.ExecuteScalarAsync(ct))!;
        }

        await AuditLog.AppendAsync(conn, tx, new AuditEntry(null, AuditActor.System, "subscription.activated", "subscription",
            subscriptionId.ToString(), new
            {
                orderId,
                plan = order.PlanSlug,
                period = order.Period,
                change = placement.Kind,
                startsAt = placement.StartsAt,
                endsAt = placement.EndsAt,
                creditSeconds = (long)placement.Credit.TotalSeconds,
                amountMinor = order.AmountMinor,
                currency = order.Currency,
            }, groupId), ct);
    }

    /// <summary>Adds the paid time after whatever the buyer already has (docs/ARCHITECTURE.md §7, Kişisel ürünler).</summary>
    private async Task ActivatePersonalAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid orderId, string slug, OrderState order, CancellationToken ct)
    {
        var slice = await PersonalTimeline.AppendAsync(conn, tx, order.BuyerId, slug, time.GetUtcNow(),
            s => order.Period == Periods.Year ? s.AddYears(1) : s.AddMonths(1), ct);
        Guid subscriptionId;
        await using (var insert = new NpgsqlCommand(
            """
            insert into public.user_subscriptions (user_id, plan_slug, period, order_id, starts_at, ends_at)
            values (@user, @plan, @period, @order, @starts, @ends)
            returning id
            """, conn, tx))
        {
            insert.Parameters.AddWithValue("user", order.BuyerId);
            insert.Parameters.AddWithValue("plan", slug);
            insert.Parameters.AddWithValue("period", order.Period);
            insert.Parameters.AddWithValue("order", orderId);
            insert.Parameters.AddWithValue("starts", slice.StartsAt);
            insert.Parameters.AddWithValue("ends", slice.EndsAt);
            subscriptionId = (Guid)(await insert.ExecuteScalarAsync(ct))!;
        }
        await AuditLog.AppendAsync(conn, tx, new AuditEntry(null, AuditActor.System, "personal_plan.activated", "user_subscription",
            subscriptionId.ToString(), new
            {
                orderId,
                plan = slug,
                period = order.Period,
                startsAt = slice.StartsAt,
                endsAt = slice.EndsAt,
                amountMinor = order.AmountMinor,
                currency = order.Currency,
            }), ct);
    }

    private static async Task<bool> BuyerExistsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid buyerId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select exists (select 1 from public.profiles where id = @id)", conn, tx);
        cmd.Parameters.AddWithValue("id", buyerId);
        return (bool)(await cmd.ExecuteScalarAsync(ct))!;
    }

    private static async Task<OrderState?> LockOrderAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid orderId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select status, provider, group_id, plan_slug, period, currency, amount_minor, buyer_id, personal_plan_slug
            from public.billing_orders where id = @id for update
            """, conn, tx);
        cmd.Parameters.AddWithValue("id", orderId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        return await reader.ReadAsync(ct)
            ? new OrderState(reader.GetString(0), reader.GetString(1), reader.IsDBNull(2) ? null : reader.GetGuid(2),
                reader.IsDBNull(3) ? null : reader.GetString(3), reader.GetString(4), reader.GetString(5), reader.GetInt32(6),
                reader.GetGuid(7), reader.IsDBNull(8) ? null : reader.GetString(8))
            : null;
    }

    private static async Task FailAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid orderId, string reason, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "update public.billing_orders set status = 'failed', failure_reason = left(@reason, 200) where id = @id", conn, tx);
        cmd.Parameters.AddWithValue("id", orderId);
        cmd.Parameters.AddWithValue("reason", reason);
        await cmd.ExecuteNonQueryAsync(ct);
    }

    private static async Task MarkPaidAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid orderId, string? paymentId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "update public.billing_orders set status = 'paid', provider_payment_id = coalesce(@payment, provider_payment_id) where id = @id",
            conn, tx);
        cmd.Parameters.AddWithValue("id", orderId);
        cmd.Parameters.Add(new NpgsqlParameter<string?>("payment", paymentId));
        await cmd.ExecuteNonQueryAsync(ct);
    }
}
