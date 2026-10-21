using GrupX.Modules.Billing.Contracts;
using GrupX.SharedKernel;
using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Database;
using Npgsql;

namespace GrupX.Modules.Billing;

/// <summary>Plan catalog edits and subscription cancellation for the admin panel (docs/ARCHITECTURE.md §7).</summary>
internal sealed class BillingAdministration(NpgsqlDataSource db, TimeProvider time) : IBillingAdministration
{
    private static readonly Error PlanNotFound = Error.NotFound("billing.plan_not_found", "Paket bulunamadı.");

    public async Task<Result> UpdatePlanAsync(Guid actorId, string slug, PlanUpdate update, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(update);
        var name = update.Name?.Trim() ?? "";
        if (name.Length is < 2 or > 40) return Error.Validation("billing.invalid_plan", "Paket adı 2–40 karakter olmalı.");
        if (update.MaxMembers is < 1 or > 1_000_000 || update.MonthlyEvents is < 0 or > 100_000 || update.MonthlyLiveMinutes is < 0 or > 10_000_000)
            return Error.Validation("billing.invalid_plan", "Limitler geçerli aralıkta olmalı.");

        var prices = update.Prices ?? [];
        var paid = slug != "free";
        var expected = paid
            ? (from c in new[] { Currencies.Try, Currencies.Usd } from p in Periods.All select (c, p)).ToHashSet()
            : [];
        if (prices.Count != expected.Count || !prices.Select(p => (p.Currency, p.Period)).ToHashSet().SetEquals(expected)
            || prices.Any(p => p.AmountMinor is < 1 or > 100_000_000))
            return Error.Validation("billing.invalid_prices", paid
                ? "Her para birimi ve dönem için bir fiyat gir."
                : "Ücretsiz paketin fiyatı olmaz.");

        var result = await BillingStore.RunAsync<bool>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);

            await using (var cmd = new NpgsqlCommand(
                """
                update public.plans
                set name = @name, max_members = @members, monthly_events = @events, monthly_live_minutes = @minutes, is_active = @active
                where slug = @slug
                """, conn, tx))
            {
                cmd.Parameters.AddWithValue("slug", slug);
                cmd.Parameters.AddWithValue("name", name);
                cmd.Parameters.AddWithValue("members", update.MaxMembers);
                cmd.Parameters.AddWithValue("events", update.MonthlyEvents);
                cmd.Parameters.AddWithValue("minutes", update.MonthlyLiveMinutes);
                cmd.Parameters.AddWithValue("active", update.IsActive);
                if (await cmd.ExecuteNonQueryAsync(ct) == 0) return PlanNotFound;
            }

            foreach (var price in prices)
            {
                await using var cmd = new NpgsqlCommand(
                    "update public.plan_prices set amount_minor = @amount where plan_slug = @slug and currency = @currency and period = @period",
                    conn, tx);
                cmd.Parameters.AddWithValue("slug", slug);
                cmd.Parameters.AddWithValue("currency", price.Currency);
                cmd.Parameters.AddWithValue("period", price.Period);
                cmd.Parameters.AddWithValue("amount", price.AmountMinor);
                await cmd.ExecuteNonQueryAsync(ct);
            }

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "plan.updated", "plan", slug, new
            {
                name,
                maxMembers = update.MaxMembers,
                monthlyEvents = update.MonthlyEvents,
                monthlyLiveMinutes = update.MonthlyLiveMinutes,
                isActive = update.IsActive,
                prices,
            }), ct);
            return true;
        }, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    public async Task<Result> CancelSubscriptionAsync(Guid actorId, Guid subscriptionId, string reason, bool refunded, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Error.Validation("billing.invalid_reason", "İptal gerekçesi 3–500 karakter olmalı.");

        var result = await BillingStore.RunAsync<bool>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);

            Guid groupId, orderId;
            await using (var find = new NpgsqlCommand(
                "select group_id, order_id, canceled_at is not null from public.group_subscriptions where id = @id for update", conn, tx))
            {
                find.Parameters.AddWithValue("id", subscriptionId);
                await using var reader = await find.ExecuteReaderAsync(ct);
                if (!await reader.ReadAsync(ct)) return Error.NotFound("billing.subscription_not_found", "Abonelik bulunamadı.");
                if (reader.GetBoolean(2)) return Error.Conflict("billing.already_canceled", "Bu abonelik zaten iptal edilmiş.");
                groupId = reader.GetGuid(0);
                orderId = reader.GetGuid(1);
            }

            await using (var cancel = new NpgsqlCommand(
                """
                update public.group_subscriptions
                set ends_at = least(ends_at, greatest(starts_at, @now)), canceled_at = @now, cancel_reason = 'admin'
                where id = @id
                """, conn, tx))
            {
                cancel.Parameters.AddWithValue("id", subscriptionId);
                cancel.Parameters.AddWithValue("now", time.GetUtcNow());
                await cancel.ExecuteNonQueryAsync(ct);
            }

            if (refunded)
            {
                await using var refund = new NpgsqlCommand(
                    "update public.billing_orders set status = 'refunded' where id = @id and status = 'paid'", conn, tx);
                refund.Parameters.AddWithValue("id", orderId);
                await refund.ExecuteNonQueryAsync(ct);
            }

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "subscription.canceled", "subscription",
                subscriptionId.ToString(), new { reason, refunded, orderId }, groupId), ct);
            return true;
        }, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }
}

/// <summary><see cref="IGroupPlanLimits"/> over <c>private.group_plan_limits</c>.</summary>
internal sealed class GroupPlanLimitsReader : IGroupPlanLimits
{
    public async Task<GroupPlanLimits> GetAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid groupId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select slug, max_members, monthly_events, monthly_live_minutes from private.group_plan_limits(@group)",
            connection, transaction);
        cmd.Parameters.AddWithValue("group", groupId);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        await reader.ReadAsync(ct);
        return new GroupPlanLimits(reader.GetString(0), reader.GetInt32(1), reader.GetInt32(2), reader.GetInt32(3));
    }
}
