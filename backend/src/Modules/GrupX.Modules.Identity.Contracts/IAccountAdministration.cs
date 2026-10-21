using GrupX.SharedKernel;

namespace GrupX.Modules.Identity.Contracts;

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
