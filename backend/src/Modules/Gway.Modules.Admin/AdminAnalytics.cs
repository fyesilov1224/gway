using Npgsql;

namespace Gway.Modules.Admin;

/// <summary>
/// One measure over the chosen range: its total, the previous range's total, and both as points per bucket
/// (oldest first), so a chart can lay the previous range under the current one.
/// </summary>
public sealed record AdminMetric(string Key, long Current, long Previous, IReadOnlyList<long> Points, IReadOnlyList<long> PreviousPoints);

/// <summary>What the platform holds right now, beside the range.</summary>
public sealed record AdminSnapshot(int Users, int Groups, int OpenReports, int OpenTickets, int LiveNow, int MatchProfiles);

/// <summary>The overview page (docs/ARCHITECTURE.md §8b): buckets are Turkey's days, or weeks for a year.</summary>
public sealed record AdminOverview(
    int Days,
    string Bucket,
    IReadOnlyList<DateOnly> Buckets,
    IReadOnlyList<AdminMetric> Metrics,
    AdminSnapshot Snapshot);

/// <summary>Counts for the admin panel's charts; reads the modules' tables, writes nothing.</summary>
internal sealed class AdminAnalytics(NpgsqlDataSource db)
{
    public static readonly int[] Ranges = [7, 30, 90, 365];

    /// <summary>Every measure the overview shows; revenue is left out for roles that do not see billing.</summary>
    private const string DailySql =
        """
        with bounds as (
          select (@today::date - (@days * 2 - 1)) as first_day
        ), since as (
          select (first_day::timestamp at time zone 'Europe/Istanbul') as at from bounds
        ), activity as (
          select author_id as uid, created_at as at from public.posts where author_id is not null and created_at >= (select at from since)
          union all select author_id, created_at from public.comments where created_at >= (select at from since)
          union all select user_id, created_at from public.post_likes where created_at >= (select at from since)
          union all select user_id, created_at from public.post_reactions where created_at >= (select at from since)
          union all select sender_id, created_at from public.messages where sender_id is not null and created_at >= (select at from since)
          union all select swiper_id, created_at from public.match_swipes where created_at >= (select at from since)
          union all select user_id, joined_at from public.group_members where joined_at >= (select at from since)
        ), events (metric, at, value, uid) as (
          select 'new_users', created_at, 1::bigint, null::uuid from public.profiles where created_at >= (select at from since)
          union all select 'new_groups', created_at, 1, null from public.groups where created_at >= (select at from since)
          union all select 'posts', created_at, 1, null from public.posts where created_at >= (select at from since)
          union all select 'comments', created_at, 1, null from public.comments where created_at >= (select at from since)
          union all select 'likes', created_at, 1, null from public.post_likes where created_at >= (select at from since)
          union all select 'reactions', created_at, 1, null from public.post_reactions where created_at >= (select at from since)
          union all select 'messages', created_at, 1, null from public.messages where created_at >= (select at from since)
          union all select 'match_likes', created_at, 1, null from public.match_swipes where liked and not super and created_at >= (select at from since)
          union all select 'super_likes', created_at, 1, null from public.match_swipes where super and created_at >= (select at from since)
          union all select 'matches', created_at, 1, null from public.matches where created_at >= (select at from since)
          union all select 'reports_opened', created_at, 1, null from public.reports where created_at >= (select at from since)
          union all select 'reports_reviewed', reviewed_at, 1, null from public.reports where reviewed_at >= (select at from since)
          union all select 'live_started', started_at, 1, null from public.live_broadcasts where started_at >= (select at from since)
          union all select 'welcome_requests', created_at, 1, null from public.event_welcomes where created_at >= (select at from since)
          union all select 'welcomes_matched', matched_at, 1, null from public.event_welcomes where matched_at >= (select at from since)
          union all select 'welcomes_thanked', thanked_at, 1, null from public.event_welcomes where thanked_at >= (select at from since)
          union all select 'card_shares_year', created_at, 1, null from public.story_card_shares where kind = 'year' and created_at >= (select at from since)
          union all select 'card_shares_event', created_at, 1, null from public.story_card_shares where kind = 'event' and created_at >= (select at from since)
          union all select 'tonight_free', created_at, 1, null from public.tonight_status where created_at >= (select at from since)
          union all select 'tonight_tables', created_at, 1, null from public.tonight_tables where created_at >= (select at from since)
          union all select 'tonight_tables_set', created_at, 1, null from public.conversations where kind = 'table' and created_at >= (select at from since)
          union all select 'active_users', at, 0, uid from activity
          union all select 'revenue_' || lower(currency), paid_at, amount_minor::bigint, null from public.billing_orders
            where @revenue and status = 'paid' and paid_at >= (select at from since)
          union all select 'paid_orders', paid_at, 1, null from public.billing_orders
            where @revenue and status = 'paid' and paid_at >= (select at from since)
        )
        select metric, (at at time zone 'Europe/Istanbul')::date as day,
               case when metric = 'active_users' then count(distinct uid) else sum(value) end
        from events
        group by 1, 2
        """;

    /// <summary>Distinct active people in the current and the previous range (not the sum of the days).</summary>
    private const string ActiveSql =
        """
        with bounds as (
          select @today::date as today
        ), cut as (
          select ((today - (@days - 1))::timestamp at time zone 'Europe/Istanbul') as current_from,
                 ((today - (@days * 2 - 1))::timestamp at time zone 'Europe/Istanbul') as previous_from
          from bounds
        ), activity as (
          select author_id as uid, created_at as at from public.posts where author_id is not null
          union all select author_id, created_at from public.comments
          union all select user_id, created_at from public.post_likes
          union all select user_id, created_at from public.post_reactions
          union all select sender_id, created_at from public.messages where sender_id is not null
          union all select swiper_id, created_at from public.match_swipes
          union all select user_id, joined_at from public.group_members
        )
        select count(distinct uid) filter (where at >= cut.current_from),
               count(distinct uid) filter (where at >= cut.previous_from and at < cut.current_from)
        from activity, cut
        where at >= cut.previous_from
        """;

    private const string SnapshotSql =
        """
        select (select count(*)::int from public.profiles),
               (select count(*)::int from public.groups where status = 'active'),
               (select count(*)::int from public.reports where status = 'open'),
               (select count(*)::int from public.support_tickets where status in ('open', 'in_progress')),
               (select count(*)::int from public.live_broadcasts where status = 'live'),
               (select count(*)::int from public.match_profiles)
        """;

    /// <summary>Measures always present, in the order the page lists them; revenue keys only with <c>includeRevenue</c>.</summary>
    private static readonly string[] Keys =
    [
        "new_users", "active_users", "new_groups", "posts", "comments", "likes", "reactions", "messages",
        "match_likes", "super_likes", "matches", "reports_opened", "reports_reviewed", "live_started",
        "welcome_requests", "welcomes_matched", "welcomes_thanked", "card_shares_year", "card_shares_event",
        "tonight_free", "tonight_tables", "tonight_tables_set",
    ];

    private static readonly string[] RevenueKeys = ["revenue_try", "revenue_usd", "paid_orders"];

    public async Task<AdminOverview> OverviewAsync(int days, bool includeRevenue, DateOnly today, CancellationToken ct)
    {
        // A year is shown as 52 whole weeks.
        var weekly = days == 365;
        var span = weekly ? 364 : days;
        var bucketDays = weekly ? 7 : 1;
        var buckets = span / bucketDays;

        await using var conn = await db.OpenConnectionAsync(ct);

        var daily = new Dictionary<string, Dictionary<DateOnly, long>>();
        await using (var cmd = new NpgsqlCommand(DailySql, conn))
        {
            cmd.Parameters.AddWithValue("days", span);
            cmd.Parameters.AddWithValue("today", today);
            cmd.Parameters.AddWithValue("revenue", includeRevenue);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct))
            {
                var metric = r.GetString(0);
                if (!daily.TryGetValue(metric, out var byDay)) daily[metric] = byDay = [];
                byDay[DateOnly.FromDateTime(r.GetDateTime(1))] = r.GetInt64(2);
            }
        }

        (long Current, long Previous) active;
        await using (var cmd = new NpgsqlCommand(ActiveSql, conn))
        {
            cmd.Parameters.AddWithValue("days", span);
            cmd.Parameters.AddWithValue("today", today);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            active = (r.GetInt64(0), r.GetInt64(1));
        }

        AdminSnapshot snapshot;
        await using (var cmd = new NpgsqlCommand(SnapshotSql, conn))
        {
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            snapshot = new AdminSnapshot(r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5));
        }

        var currentFirst = today.AddDays(-(span - 1));
        var previousFirst = currentFirst.AddDays(-span);
        var bucketStarts = Enumerable.Range(0, buckets).Select(i => currentFirst.AddDays(i * bucketDays)).ToList();

        // Active people per day do not add up across days: a week shows its daily average.
        List<long> Points(string key, Dictionary<DateOnly, long>? byDay, DateOnly first) =>
            Enumerable.Range(0, buckets)
                .Select(b =>
                {
                    var sum = Enumerable.Range(0, bucketDays).Sum(d => byDay?.GetValueOrDefault(first.AddDays(b * bucketDays + d)) ?? 0);
                    return key == "active_users" ? (long)Math.Round(sum / (double)bucketDays) : sum;
                })
                .ToList();

        var metrics = new List<AdminMetric>();
        foreach (var key in includeRevenue ? [.. Keys, .. RevenueKeys] : Keys)
        {
            daily.TryGetValue(key, out var byDay);
            var points = Points(key, byDay, currentFirst);
            var previousPoints = Points(key, byDay, previousFirst);
            // Active people are counted once per range, not once per day.
            var (current, previous) = key == "active_users" ? active : (points.Sum(), previousPoints.Sum());
            metrics.Add(new AdminMetric(key, current, previous, points, previousPoints));
        }

        return new AdminOverview(days, weekly ? "week" : "day", bucketStarts, metrics, snapshot);
    }
}
