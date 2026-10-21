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

/// <summary>Billing actions the admin module may trigger. Callers check platform staff roles first.</summary>
public interface IBillingAdministration
{
    Task<Result> UpdatePlanAsync(Guid actorId, string slug, PlanUpdate update, CancellationToken ct);

    /// <summary>Ends a slice now (a future slice never starts); <paramref name="refunded"/> marks its order refunded.</summary>
    Task<Result> CancelSubscriptionAsync(Guid actorId, Guid subscriptionId, string reason, bool refunded, CancellationToken ct);
}
