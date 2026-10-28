using Npgsql;

namespace GrupX.Modules.Admin;

public sealed record AdminMoney(string Currency, long AmountMinor);

public sealed record AdminRevenueMonth(DateOnly Month, IReadOnlyList<AdminMoney> Revenue, int PaidOrders);

public sealed record AdminBillingStats(
    int ActiveSubscriptions,
    int PaidGroups,
    IReadOnlyList<AdminMoney> RevenueThisMonth,
    int PendingOrders,
    IReadOnlyList<AdminRevenueMonth> Months);

public sealed record AdminOrder(
    Guid Id,
    Guid? GroupId,
    string? GroupName,
    string? GroupHandle,
    Guid BuyerId,
    string? BuyerUsername,
    string? BuyerDisplayName,
    string PlanSlug,
    string PlanName,
    string Period,
    string Provider,
    string? Country,
    string Currency,
    int AmountMinor,
    string Status,
    string? FailureReason,
    DateTimeOffset CreatedAt,
    DateTimeOffset? PaidAt);

public sealed record AdminSubscription(
    Guid Id,
    Guid GroupId,
    string GroupName,
    string GroupHandle,
    string PlanSlug,
    string PlanName,
    string? Period,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    DateTimeOffset? CanceledAt,
    string? CancelReason,
    Guid? OrderId,
    string? OrderStatus,
    string? Provider,
    string? Currency,
    int? AmountMinor,
    string? GrantReason,
    string? GrantedByUsername,
    string? CancelNote);

public sealed record AdminPlanPrice(string Currency, string Period, int AmountMinor);

public sealed record AdminPlan(
    string Slug,
    string Name,
    int Tier,
    int MaxMembers,
    int MonthlyEvents,
    int MonthlyLiveMinutes,
    bool IsActive,
    int ActiveGroups,
    IReadOnlyList<AdminPlanPrice> Prices);

/// <summary>Read side of the admin billing pages (docs/ARCHITECTURE.md §7).</summary>
internal sealed class AdminBilling(NpgsqlDataSource db)
{
    public const int PageSize = 20;
    private const int RevenueMonths = 12;

    public static readonly string[] OrderStatuses = ["pending", "paid", "failed", "refunded"];
    public static readonly string[] Providers = ["paytr", "iyzico"];

    private const string Current = "s.starts_at <= now() and now() < s.ends_at";

    public async Task<AdminBillingStats> StatsAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);

        // Months follow Turkish time, like the business that reports them.
        int active, groups, pending;
        DateOnly thisMonth;
        await using (var cmd = new NpgsqlCommand(
            $"""
            select (select count(*)::int from public.group_subscriptions s where {Current}),
                   (select count(distinct s.group_id)::int from public.group_subscriptions s where {Current}),
                   (select count(*)::int from public.billing_orders where status = 'pending' and created_at > now() - interval '1 hour'),
                   date_trunc('month', now() at time zone 'Europe/Istanbul')::date
            """, conn))
        {
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            await reader.ReadAsync(ct);
            (active, groups, pending) = (reader.GetInt32(0), reader.GetInt32(1), reader.GetInt32(2));
            thisMonth = reader.GetFieldValue<DateOnly>(3);
        }

        var months = new SortedDictionary<DateOnly, (List<AdminMoney> Revenue, int Orders)>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select date_trunc('month', paid_at at time zone 'Europe/Istanbul')::date, currency, sum(amount_minor)::bigint, count(*)::int
            from public.billing_orders
            where status = 'paid'
              and paid_at >= (date_trunc('month', now() at time zone 'Europe/Istanbul') - interval '{RevenueMonths - 1} months')
                             at time zone 'Europe/Istanbul'
            group by 1, 2
            order by 1, 2
            """, conn))
        {
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                var month = reader.GetFieldValue<DateOnly>(0);
                var entry = months.TryGetValue(month, out var e) ? e : ([], 0);
                entry.Revenue.Add(new AdminMoney(reader.GetString(1), reader.GetInt64(2)));
                months[month] = (entry.Revenue, entry.Orders + reader.GetInt32(3));
            }
        }

        // Every month of the window, newest first, empty ones included.
        var window = Enumerable.Range(0, RevenueMonths)
            .Select(i => thisMonth.AddMonths(-i))
            .Select(m => months.TryGetValue(m, out var e)
                ? new AdminRevenueMonth(m, e.Revenue, e.Orders)
                : new AdminRevenueMonth(m, [], 0))
            .ToList();

        return new AdminBillingStats(active, groups, window[0].Revenue, pending, window);
    }

    private const string OrderFilter =
        """
        where (@q is null or o.group_name ilike @q escape '\' or o.group_handle ilike @q escape '\'
               or o.personal_plan_slug is not null and exists (select 1 from public.profiles b where b.id = o.buyer_id and b.username ilike @q escape '\'))
          and (@status is null or o.status = @status)
          and (@provider is null or o.provider = @provider)
        """;

    public async Task<PagedResult<AdminOrder>> OrdersAsync(string? query, string? status, string? provider, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";
        await using var conn = await db.OpenConnectionAsync(ct);

        void Bind(NpgsqlCommand cmd)
        {
            cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("status", status));
            cmd.Parameters.Add(new NpgsqlParameter<string?>("provider", provider));
        }

        int total;
        await using (var count = new NpgsqlCommand($"select count(*)::int from public.billing_orders o {OrderFilter}", conn))
        {
            Bind(count);
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        var items = new List<AdminOrder>();
        await using (var cmd = new NpgsqlCommand(
            $"""
            select o.id, o.group_id, o.group_name, o.group_handle, o.buyer_id, p.username, p.display_name,
                   coalesce(o.plan_slug, o.personal_plan_slug), coalesce(pl.name, pp.name), o.period, o.provider, o.country,
                   o.currency, o.amount_minor, o.status, o.failure_reason, o.created_at, o.paid_at
            from public.billing_orders o
            left join public.plans pl on pl.slug = o.plan_slug
            left join public.personal_plans pp on pp.slug = o.personal_plan_slug
            left join public.profiles p on p.id = o.buyer_id
            {OrderFilter}
            order by o.created_at desc, o.id
            limit {PageSize} offset @offset
            """, conn))
        {
            Bind(cmd);
            cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                items.Add(new AdminOrder(
                    r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2),
                    r.IsDBNull(3) ? null : r.GetString(3), r.GetGuid(4),
                    r.IsDBNull(5) ? null : r.GetString(5), r.IsDBNull(6) ? null : r.GetString(6),
                    r.GetString(7), r.GetString(8), r.GetString(9), r.GetString(10), r.IsDBNull(11) ? null : r.GetString(11),
                    r.GetString(12), r.GetInt32(13), r.GetString(14), r.IsDBNull(15) ? null : r.GetString(15),
                    r.GetFieldValue<DateTimeOffset>(16), r.IsDBNull(17) ? null : r.GetFieldValue<DateTimeOffset>(17)));
            }
        }

        return new PagedResult<AdminOrder>(items, total, page, PageSize);
    }

    private const string SubscriptionSelect =
        """
        select s.id, s.group_id, g.name, g.handle, s.plan_slug, pl.name, s.period, s.starts_at, s.ends_at,
               s.canceled_at, s.cancel_reason, s.order_id, o.status, o.provider, o.currency, o.amount_minor,
               s.grant_reason, gb.username, s.cancel_note
        from public.group_subscriptions s
        join public.groups g on g.id = s.group_id
        join public.plans pl on pl.slug = s.plan_slug
        left join public.billing_orders o on o.id = s.order_id
        left join public.profiles gb on gb.id = s.granted_by
        """;

    /// <summary>Current and queued slices, the soonest to end first.</summary>
    public async Task<PagedResult<AdminSubscription>> SubscriptionsAsync(string? query, int page, CancellationToken ct)
    {
        page = Math.Max(page, 1);
        var pattern = string.IsNullOrWhiteSpace(query) ? null : $"%{AdminUsers.EscapeLike(query.Trim())}%";
        const string filter =
            """
            where s.ends_at > now() and s.ends_at > s.starts_at
              and (@q is null or g.name ilike @q escape '\' or g.handle ilike @q escape '\')
            """;
        await using var conn = await db.OpenConnectionAsync(ct);

        int total;
        await using (var count = new NpgsqlCommand(
            $"select count(*)::int from public.group_subscriptions s join public.groups g on g.id = s.group_id {filter}", conn))
        {
            count.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
            total = (int)(await count.ExecuteScalarAsync(ct))!;
        }

        await using var cmd = new NpgsqlCommand(
            $"{SubscriptionSelect} {filter} order by s.ends_at, s.id limit {PageSize} offset @offset", conn);
        cmd.Parameters.Add(new NpgsqlParameter<string?>("q", pattern));
        cmd.Parameters.AddWithValue("offset", (page - 1) * PageSize);
        return new PagedResult<AdminSubscription>(await ReadSubscriptionsAsync(cmd, ct), total, page, PageSize);
    }

    /// <summary>A group's whole timeline, newest first (group detail page).</summary>
    public static async Task<List<AdminSubscription>> GroupSubscriptionsAsync(NpgsqlConnection conn, Guid groupId, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand($"{SubscriptionSelect} where s.group_id = @id order by s.starts_at desc limit 50", conn);
        cmd.Parameters.AddWithValue("id", groupId);
        return await ReadSubscriptionsAsync(cmd, ct);
    }

    private static async Task<List<AdminSubscription>> ReadSubscriptionsAsync(NpgsqlCommand cmd, CancellationToken ct)
    {
        var items = new List<AdminSubscription>();
        await using var r = await cmd.ExecuteReaderAsync(ct);
        string? Text(int i) => r.IsDBNull(i) ? null : r.GetString(i);
        while (await r.ReadAsync(ct))
        {
            items.Add(new AdminSubscription(
                r.GetGuid(0), r.GetGuid(1), r.GetString(2), r.GetString(3), r.GetString(4), r.GetString(5), Text(6),
                r.GetFieldValue<DateTimeOffset>(7), r.GetFieldValue<DateTimeOffset>(8),
                r.IsDBNull(9) ? null : r.GetFieldValue<DateTimeOffset>(9), Text(10),
                r.IsDBNull(11) ? null : r.GetGuid(11), Text(12), Text(13), Text(14), r.IsDBNull(15) ? null : r.GetInt32(15),
                Text(16), Text(17), Text(18)));
        }
        return items;
    }

    public async Task<IReadOnlyList<AdminPlan>> PlansAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            $"""
            select p.slug, p.name, p.tier, p.max_members, p.monthly_events, p.monthly_live_minutes, p.is_active,
                   -- Groups without a paid slice right now are on the free plan.
                   case when p.slug = 'free'
                        then (select count(*)::int from public.groups g
                              where not exists (select 1 from public.group_subscriptions s where s.group_id = g.id and {Current}))
                        else (select count(distinct s.group_id)::int from public.group_subscriptions s where s.plan_slug = p.slug and {Current})
                   end,
                   coalesce(array_agg(pp.currency order by pp.currency, pp.period) filter (where pp.currency is not null), array[]::text[]),
                   coalesce(array_agg(pp.period order by pp.currency, pp.period) filter (where pp.currency is not null), array[]::text[]),
                   coalesce(array_agg(pp.amount_minor order by pp.currency, pp.period) filter (where pp.currency is not null), array[]::int[])
            from public.plans p
            left join public.plan_prices pp on pp.plan_slug = p.slug
            group by p.slug
            order by p.tier
            """);
        var plans = new List<AdminPlan>();
        await using var r = await cmd.ExecuteReaderAsync(ct);
        while (await r.ReadAsync(ct))
        {
            var currencies = r.GetFieldValue<string[]>(8);
            var periods = r.GetFieldValue<string[]>(9);
            var amounts = r.GetFieldValue<int[]>(10);
            plans.Add(new AdminPlan(r.GetString(0), r.GetString(1), r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5),
                r.GetBoolean(6), r.GetInt32(7),
                [.. currencies.Select((c, i) => new AdminPlanPrice(c, periods[i], amounts[i]))]));
        }
        return plans;
    }
}
