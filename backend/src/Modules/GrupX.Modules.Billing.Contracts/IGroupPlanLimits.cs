using Npgsql;

namespace GrupX.Modules.Billing.Contracts;

/// <summary>Limits of the plan a group is on right now (free without a paid slice).</summary>
public sealed record GroupPlanLimits(string PlanSlug, int MaxMembers, int MonthlyEvents, int MonthlyLiveMinutes);

/// <summary>Plan limits for other modules' checks (docs/ARCHITECTURE.md §7, Limitler).</summary>
public interface IGroupPlanLimits
{
    /// <summary>Reads inside the caller's transaction, so the check sees the caller's locks.</summary>
    Task<GroupPlanLimits> GetAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid groupId, CancellationToken ct);
}
