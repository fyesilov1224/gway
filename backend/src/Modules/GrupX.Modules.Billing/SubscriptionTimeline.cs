using GrupX.SharedKernel;

namespace GrupX.Modules.Billing;

internal static class Periods
{
    public const string Month = "month";
    public const string Year = "year";

    public static readonly string[] All = [Month, Year];

    public static DateTimeOffset Add(DateTimeOffset start, string period) =>
        period == Year ? start.AddYears(1) : start.AddMonths(1);

    /// <summary>Days used to compare daily prices (docs/ARCHITECTURE.md §7).</summary>
    public static int NominalDays(string period) => period == Year ? 365 : 30;
}

internal static class ChangeKinds
{
    public const string Upgrade = "upgrade";
    public const string Renewal = "renewal";
    public const string Downgrade = "downgrade";
}

/// <summary>A live (not yet ended) slice of a group's timeline.</summary>
internal sealed record Slice(Guid Id, string PlanSlug, int Tier, string Period, DateTimeOffset StartsAt, DateTimeOffset EndsAt);

/// <summary>Where a new purchase goes and which live slices it replaces.</summary>
internal sealed record Placement(string Kind, DateTimeOffset StartsAt, DateTimeOffset EndsAt, TimeSpan Credit, IReadOnlyList<Guid> Replaced);

/// <summary>
/// Prepaid timeline rules (docs/ARCHITECTURE.md §7, Abonelik modeli). An upgrade starts now and turns the
/// remaining time of every live slice into extra time at the new plan's daily price; a renewal or a
/// downgrade is appended to the end of the timeline.
/// </summary>
internal static class SubscriptionTimeline
{
    public static readonly TimeSpan MaxAhead = TimeSpan.FromDays(400);

    public static readonly Error TooLong = Error.RuleViolation(
        "billing.timeline_too_long", "Paketin bir yıldan uzun süre için zaten ödenmiş. Şimdilik yalnızca üst pakete geçebilirsin.");

    /// <param name="slices">The group's slices that end after <paramref name="now"/>.</param>
    /// <param name="price">List price of (plan, period) in the order's currency; null when there is none.</param>
    /// <param name="enforceMaxAhead">False at settlement: a paid order always gets its time.</param>
    public static Result<Placement> Place(
        DateTimeOffset now,
        IReadOnlyList<Slice> slices,
        string planSlug,
        int tier,
        string period,
        Func<string, string, int?> price,
        bool enforceMaxAhead = true)
    {
        var current = slices.FirstOrDefault(s => s.StartsAt <= now && now < s.EndsAt);

        if (tier > (current?.Tier ?? 0))
        {
            var credit = TimeSpan.Zero;
            if (price(planSlug, period) is { } newPrice)
            {
                var newDaily = (decimal)newPrice / Periods.NominalDays(period);
                foreach (var slice in slices)
                {
                    var remaining = slice.EndsAt - (slice.StartsAt > now ? slice.StartsAt : now);
                    if (remaining <= TimeSpan.Zero || price(slice.PlanSlug, slice.Period) is not { } oldPrice) continue;
                    var oldDaily = (decimal)oldPrice / Periods.NominalDays(slice.Period);
                    credit += TimeSpan.FromSeconds((double)Math.Floor((decimal)remaining.TotalSeconds * oldDaily / newDaily));
                }
            }
            return new Placement(ChangeKinds.Upgrade, now, Periods.Add(now, period) + credit, credit, [.. slices.Select(s => s.Id)]);
        }

        var end = slices.Count == 0 ? now : slices.Max(s => s.EndsAt);
        if (end < now) end = now;
        if (enforceMaxAhead && end - now > MaxAhead) return TooLong;

        var kind = tier == current?.Tier ? ChangeKinds.Renewal : ChangeKinds.Downgrade;
        return new Placement(kind, end, Periods.Add(end, period), TimeSpan.Zero, []);
    }
}
