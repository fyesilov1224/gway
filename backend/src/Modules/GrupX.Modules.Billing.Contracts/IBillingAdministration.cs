using GrupX.SharedKernel;

namespace GrupX.Modules.Billing.Contracts;

public sealed record PlanPriceUpdate(string Currency, string Period, int AmountMinor);

public sealed record PlanUpdate(
    string Name,
    int MaxMembers,
    int MonthlyEvents,
    int MonthlyLiveMinutes,
    bool IsActive,
    IReadOnlyList<PlanPriceUpdate> Prices);

/// <summary>Products a person buys for themselves (docs/ARCHITECTURE.md §7, Kişisel ürünler).</summary>
public static class PersonalPlans
{
    /// <summary>Hepsi Bir Arada: every matching feature.</summary>
    public const string MatchingPremium = "matching_premium";

    /// <summary>The matching packages, as the shop lists them (docs/ARCHITECTURE.md §3g, Ücretli paketler).</summary>
    public static readonly IReadOnlyList<string> Matching =
        ["matching_reveal", "matching_chat", "matching_admirers", "matching_unlimited", "matching_super", "matching_boost", "matching_teammates",
         MatchingPremium];
}

public sealed record PersonalPlanUpdate(string Name, bool IsActive, IReadOnlyList<PlanPriceUpdate> Prices);

public sealed record PersonalRevenue(string Currency, long AmountMinor, int Orders);

/// <summary>A personal plan for the admin panel: catalog, people with time left, the last 30 days' paid orders.</summary>
public sealed record PersonalPlanSummary(
    string Slug,
    string Name,
    bool IsActive,
    IReadOnlyList<PlanPriceUpdate> Prices,
    int ActiveMembers,
    int GrantedMembers,
    IReadOnlyList<PersonalRevenue> Revenue30d);

/// <summary>
/// One slice of a person's personal plan for the admin panel: bought (<see cref="OrderId"/>) or granted (<see cref="GrantReason"/>).
/// A canceled slice ends when it was canceled.
/// </summary>
public sealed record PersonalSubscription(
    Guid Id,
    string PlanSlug,
    string PlanName,
    string? Period,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    DateTimeOffset? CanceledAt,
    Guid? OrderId,
    string? OrderStatus,
    int? AmountMinor,
    string? Currency,
    string? GrantReason,
    string? GrantedByUsername);

/// <summary>Billing actions the admin module may trigger. Callers check platform staff roles first.</summary>
public interface IBillingAdministration
{
    Task<Result> UpdatePlanAsync(Guid actorId, string slug, PlanUpdate update, CancellationToken ct);

    /// <summary>Ends a slice now (a future slice never starts); <paramref name="refunded"/> marks its order refunded.</summary>
    Task<Result> CancelSubscriptionAsync(Guid actorId, Guid subscriptionId, string reason, bool refunded, CancellationToken ct);

    /// <summary>
    /// Gives the group <paramref name="slug"/> for <paramref name="days"/> by the timeline rules: a higher plan starts now and
    /// carries the remaining time over, the same or a lower plan follows the time the group already has.
    /// </summary>
    Task<Result> GrantGroupPlanAsync(Guid actorId, Guid groupId, string slug, int days, string reason, CancellationToken ct);

    /// <summary>Ends the group's running and upcoming slices now, so it is on the free plan; <paramref name="refunded"/> marks their orders refunded.</summary>
    Task<Result> CancelGroupPlanAsync(Guid actorId, Guid groupId, string reason, bool refunded, CancellationToken ct);

    /// <summary>
    /// A platform ban for a violation (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet): ends the person's personal plans and the
    /// plans of the groups they own now, without refund. Returns how many slices ended.
    /// </summary>
    Task<int> CancelForViolationAsync(Guid actorId, Guid userId, string reason, CancellationToken ct);

    /// <summary>Each provider's setup: keys present, test mode, the addresses to enter in its panel and what is missing.</summary>
    PaymentProvidersStatus ProvidersStatus();

    /// <summary>Asks <paramref name="provider"/> whether the configured keys work; not found for an unknown provider.</summary>
    Task<Result<ProviderCheck>> CheckProviderAsync(string provider, string userIp, CancellationToken ct);

    Task<PersonalPlanSummary> PersonalPlanAsync(string slug, CancellationToken ct);

    Task<Result> UpdatePersonalPlanAsync(Guid actorId, string slug, PersonalPlanUpdate update, CancellationToken ct);

    /// <summary>Gives <paramref name="username"/> the plan for <paramref name="days"/>, after any time they already have.</summary>
    Task<Result> GrantPersonalPlanAsync(Guid actorId, string username, string slug, int days, string reason, CancellationToken ct);

    /// <summary>Gives the person the plan for <paramref name="days"/>, after any time they already have; not found when the account is gone.</summary>
    Task<Result> GrantPersonalPlanAsync(Guid actorId, Guid userId, string slug, int days, string reason, CancellationToken ct);

    /// <summary>Every slice of the person's personal plans, newest first.</summary>
    Task<IReadOnlyList<PersonalSubscription>> PersonalSubscriptionsAsync(Guid userId, CancellationToken ct);

    /// <summary>
    /// Ends the person's running and upcoming slices of the plan now; <paramref name="refunded"/> marks their paid orders refunded.
    /// </summary>
    Task<Result> CancelPersonalPlanAsync(Guid actorId, Guid userId, string slug, string reason, bool refunded, CancellationToken ct);
}
