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

    public async Task<PersonalPlanSummary> PersonalPlanAsync(string slug, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        string name;
        bool active;
        int members, granted;
        await using (var cmd = new NpgsqlCommand(
            """
            select p.name, p.is_active,
                   (select count(distinct s.user_id)::int from public.user_subscriptions s
                    where s.plan_slug = p.slug and now() >= s.starts_at and now() < s.ends_at),
                   (select count(distinct s.user_id)::int from public.user_subscriptions s
                    where s.plan_slug = p.slug and s.order_id is null and now() >= s.starts_at and now() < s.ends_at)
            from public.personal_plans p where p.slug = @slug
            """, conn))
        {
            cmd.Parameters.AddWithValue("slug", slug);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) throw new InvalidOperationException($"Personal plan {slug} is missing.");
            (name, active, members, granted) = (r.GetString(0), r.GetBoolean(1), r.GetInt32(2), r.GetInt32(3));
        }

        var prices = new List<PlanPriceUpdate>();
        await using (var cmd = new NpgsqlCommand(
            "select currency, period, amount_minor from public.personal_plan_prices where plan_slug = @slug order by currency desc, period", conn))
        {
            cmd.Parameters.AddWithValue("slug", slug);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) prices.Add(new PlanPriceUpdate(r.GetString(0), r.GetString(1), r.GetInt32(2)));
        }

        var revenue = new List<PersonalRevenue>();
        await using (var cmd = new NpgsqlCommand(
            """
            select currency, sum(amount_minor)::bigint, count(*)::int from public.billing_orders
            where personal_plan_slug = @slug and status = 'paid' and paid_at > now() - interval '30 days'
            group by currency order by currency desc
            """, conn))
        {
            cmd.Parameters.AddWithValue("slug", slug);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) revenue.Add(new PersonalRevenue(r.GetString(0), r.GetInt64(1), r.GetInt32(2)));
        }

        return new PersonalPlanSummary(slug, name, active, prices, members, granted, revenue);
    }

    public async Task<Result> UpdatePersonalPlanAsync(Guid actorId, string slug, PersonalPlanUpdate update, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(update);
        var name = update.Name?.Trim() ?? "";
        if (name.Length is < 2 or > 40) return Error.Validation("billing.invalid_plan", "Ürün adı 2–40 karakter olmalı.");
        var prices = update.Prices ?? [];
        var expected = (from c in new[] { Currencies.Try, Currencies.Usd } from p in Periods.All select (c, p)).ToHashSet();
        if (prices.Count != expected.Count || !prices.Select(p => (p.Currency, p.Period)).ToHashSet().SetEquals(expected)
            || prices.Any(p => p.AmountMinor is < 1 or > 100_000_000))
            return Error.Validation("billing.invalid_prices", "Her para birimi ve dönem için bir fiyat gir.");

        var result = await BillingStore.RunAsync<bool>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);
            await using (var cmd = new NpgsqlCommand(
                "update public.personal_plans set name = @name, is_active = @active where slug = @slug", conn, tx))
            {
                cmd.Parameters.AddWithValue("slug", slug);
                cmd.Parameters.AddWithValue("name", name);
                cmd.Parameters.AddWithValue("active", update.IsActive);
                if (await cmd.ExecuteNonQueryAsync(ct) == 0) return PlanNotFound;
            }
            foreach (var price in prices)
            {
                await using var cmd = new NpgsqlCommand(
                    "update public.personal_plan_prices set amount_minor = @amount where plan_slug = @slug and currency = @currency and period = @period",
                    conn, tx);
                cmd.Parameters.AddWithValue("slug", slug);
                cmd.Parameters.AddWithValue("currency", price.Currency);
                cmd.Parameters.AddWithValue("period", price.Period);
                cmd.Parameters.AddWithValue("amount", price.AmountMinor);
                await cmd.ExecuteNonQueryAsync(ct);
            }
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "personal_plan.updated", "personal_plan", slug,
                new { name, isActive = update.IsActive, prices }), ct);
            return true;
        }, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    public Task<Result> GrantPersonalPlanAsync(Guid actorId, string username, string slug, int days, string reason, CancellationToken ct) =>
        GrantAsync(actorId, slug, days, reason, async (conn, tx) =>
        {
            await using var find = new NpgsqlCommand("select id from public.profiles where username = @username", conn, tx);
            find.Parameters.AddWithValue("username", (username ?? "").Trim().TrimStart('@').ToLowerInvariant());
            return await find.ExecuteScalarAsync(ct) as Guid?;
        }, Error.NotFound("billing.user_not_found", "Bu kullanıcı adıyla biri bulunamadı."), ct);

    public Task<Result> GrantPersonalPlanAsync(Guid actorId, Guid userId, string slug, int days, string reason, CancellationToken ct) =>
        GrantAsync(actorId, slug, days, reason, async (conn, tx) =>
        {
            await using var find = new NpgsqlCommand("select id from public.profiles where id = @id", conn, tx);
            find.Parameters.AddWithValue("id", userId);
            return await find.ExecuteScalarAsync(ct) as Guid?;
        }, Error.NotFound("billing.user_not_found", "Kullanıcı bulunamadı."), ct);

    private async Task<Result> GrantAsync(
        Guid actorId, string slug, int days, string reason, Func<NpgsqlConnection, NpgsqlTransaction, Task<Guid?>> findUser, Error notFound,
        CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Error.Validation("billing.invalid_reason", "Gerekçe 3–500 karakter olmalı.");
        if (days is < 1 or > 365) return Error.Validation("billing.invalid_days", "Süre 1–365 gün olmalı.");

        var result = await BillingStore.RunAsync<bool>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);
            if (await findUser(conn, tx) is not { } userId) return notFound;

            var slice = await PersonalTimeline.AppendAsync(conn, tx, userId, slug, time.GetUtcNow(), s => s.AddDays(days), ct);
            await using (var insert = new NpgsqlCommand(
                """
                insert into public.user_subscriptions (user_id, plan_slug, granted_by, grant_reason, starts_at, ends_at)
                values (@user, @slug, @actor, @reason, @starts, @ends)
                returning id
                """, conn, tx))
            {
                insert.Parameters.AddWithValue("user", userId);
                insert.Parameters.AddWithValue("slug", slug);
                insert.Parameters.AddWithValue("actor", actorId);
                insert.Parameters.AddWithValue("reason", reason);
                insert.Parameters.AddWithValue("starts", slice.StartsAt);
                insert.Parameters.AddWithValue("ends", slice.EndsAt);
                var id = (Guid)(await insert.ExecuteScalarAsync(ct))!;
                await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "personal_plan.granted", "user_subscription",
                    id.ToString(), new { userId, plan = slug, days, reason, startsAt = slice.StartsAt, endsAt = slice.EndsAt }), ct);
            }
            return true;
        }, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }

    public async Task<IReadOnlyList<PersonalSubscription>> PersonalSubscriptionsAsync(Guid userId, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select s.id, s.plan_slug, p.name, s.period, s.starts_at, s.ends_at, s.canceled_at, s.order_id, o.status, o.amount_minor,
                   o.currency, s.grant_reason, g.username
            from public.user_subscriptions s
            join public.personal_plans p on p.slug = s.plan_slug
            left join public.billing_orders o on o.id = s.order_id
            left join public.profiles g on g.id = s.granted_by
            where s.user_id = @user
            order by s.starts_at desc, s.id
            """);
        cmd.Parameters.AddWithValue("user", userId);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        var items = new List<PersonalSubscription>();
        string? Text(int i) => r.IsDBNull(i) ? null : r.GetString(i);
        DateTimeOffset At(int i) => new(DateTime.SpecifyKind(r.GetDateTime(i), DateTimeKind.Utc));
        while (await r.ReadAsync(ct))
        {
            items.Add(new PersonalSubscription(
                r.GetGuid(0), r.GetString(1), r.GetString(2), Text(3), At(4), At(5), r.IsDBNull(6) ? null : At(6),
                r.IsDBNull(7) ? null : r.GetGuid(7), Text(8), r.IsDBNull(9) ? null : r.GetInt32(9), Text(10), Text(11), Text(12)));
        }
        return items;
    }

    public async Task<Result> CancelPersonalPlanAsync(Guid actorId, Guid userId, string slug, string reason, bool refunded, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Error.Validation("billing.invalid_reason", "İptal gerekçesi 3–500 karakter olmalı.");

        var result = await BillingStore.RunAsync<bool>(db, async (conn, tx) =>
        {
            await ActingUser.SetAsync(conn, tx, actorId, ct);
            // The same lock as adding time, so a payment settling now lands before or after, never in between.
            await using (var lockUser = new NpgsqlCommand("select pg_advisory_xact_lock(hashtextextended(@key, 11))", conn, tx))
            {
                lockUser.Parameters.AddWithValue("key", $"{userId}:{slug}");
                await lockUser.ExecuteNonQueryAsync(ct);
            }

            // Running and upcoming slices end now; an upcoming one becomes empty and never starts.
            var canceled = new List<(Guid Id, Guid? OrderId)>();
            await using (var cancel = new NpgsqlCommand(
                """
                update public.user_subscriptions
                set ends_at = greatest(starts_at, @now), canceled_at = @now, cancel_reason = 'admin'
                where user_id = @user and plan_slug = @slug and canceled_at is null and ends_at > @now
                returning id, order_id
                """, conn, tx))
            {
                cancel.Parameters.AddWithValue("user", userId);
                cancel.Parameters.AddWithValue("slug", slug);
                cancel.Parameters.AddWithValue("now", time.GetUtcNow());
                await using var r = await cancel.ExecuteReaderAsync(ct);
                while (await r.ReadAsync(ct)) canceled.Add((r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1)));
            }
            if (canceled.Count == 0) return Error.NotFound("billing.subscription_not_found", "Bu kişinin bu pakette süren ya da sıradaki bir süresi yok.");

            var orders = canceled.Where(c => c.OrderId is not null).Select(c => c.OrderId!.Value).ToArray();
            if (refunded && orders.Length > 0)
            {
                await using var refund = new NpgsqlCommand(
                    "update public.billing_orders set status = 'refunded' where id = any(@ids) and status = 'paid'", conn, tx);
                refund.Parameters.AddWithValue("ids", orders);
                await refund.ExecuteNonQueryAsync(ct);
            }

            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "personal_plan.canceled", "user", userId.ToString(),
                new { plan = slug, reason, refunded, subscriptions = canceled.Select(c => c.Id), orders }), ct);
            return true;
        }, ct);
        return result.IsSuccess ? Result.Success() : result.Error;
    }
}

/// <summary>Where a person's next slice of a personal plan goes: right after the time they already have.</summary>
internal static class PersonalTimeline
{
    public static async Task<(DateTimeOffset StartsAt, DateTimeOffset EndsAt)> AppendAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string slug, DateTimeOffset now,
        Func<DateTimeOffset, DateTimeOffset> length, CancellationToken ct)
    {
        // One change per person and plan at a time.
        await using (var lockUser = new NpgsqlCommand("select pg_advisory_xact_lock(hashtextextended(@key, 11))", conn, tx))
        {
            lockUser.Parameters.AddWithValue("key", $"{userId}:{slug}");
            await lockUser.ExecuteNonQueryAsync(ct);
        }
        var until = await UntilAsync(conn, tx, userId, slug, ct);
        var starts = until is { } u && u > now ? u : now;
        return (starts, length(starts));
    }

    /// <summary>The end of the time the person has paid or been given, if any is left.</summary>
    public static async Task<DateTimeOffset?> UntilAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid userId, string slug, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand("select private.personal_plan_until(@user, @slug)", conn, tx);
        cmd.Parameters.AddWithValue("user", userId);
        cmd.Parameters.AddWithValue("slug", slug);
        return await cmd.ExecuteScalarAsync(ct) is DateTime d ? new DateTimeOffset(DateTime.SpecifyKind(d, DateTimeKind.Utc)) : null;
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
