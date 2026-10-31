using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Identity.Contracts;

public static class AccountStatuses
{
    public const string Active = "active";
    public const string Suspended = "suspended";
    public const string PendingDeletion = "pending_deletion";
}

public sealed record AccountState(
    string Status,
    DateTimeOffset? SuspendedUntil,
    string? SuspensionReason,
    DateTimeOffset? DeletionScheduledFor);

/// <summary>Account actions other modules (admin) may trigger. Callers check their own permissions first.</summary>
public interface IAccountAdministration
{
    /// <param name="until">Null suspends indefinitely.</param>
    Task<Result<AccountState>> SuspendAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct);

    Task<Result<AccountState>> UnsuspendAsync(Guid actorId, Guid userId, CancellationToken ct);
}

/// <summary>
/// Account suspension inside another module's transaction: moderation's illegal-activity referrals
/// (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet). The caller audits the step.
/// </summary>
public interface IAccountSanctions
{
    /// <summary>Suspends the account and ends its sessions; false when it is being deleted (left as it is).</summary>
    /// <param name="until">Null suspends indefinitely.</param>
    Task<bool> SuspendAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct);

    /// <summary>Lifts a suspension; false when the account is not suspended.</summary>
    Task<bool> UnsuspendAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid userId, CancellationToken ct);
}
