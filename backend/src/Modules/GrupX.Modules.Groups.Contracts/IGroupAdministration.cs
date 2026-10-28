using GrupX.SharedKernel;
using Npgsql;

namespace GrupX.Modules.Groups.Contracts;

public static class GroupStatuses
{
    public const string Active = "active";
    public const string Suspended = "suspended";
}

public sealed record GroupState(string Status, string? SuspensionReason, DateTimeOffset? SuspendedAt);

/// <summary>Group actions the admin module may trigger. Callers check platform staff roles first.</summary>
public interface IGroupAdministration
{
    Task<Result<GroupState>> SuspendAsync(Guid actorId, Guid groupId, string reason, CancellationToken ct);

    Task<Result<GroupState>> UnsuspendAsync(Guid actorId, Guid groupId, CancellationToken ct);

    /// <summary>Suspends every active group <paramref name="ownerId"/> owns (a platform ban); returns their ids.</summary>
    Task<IReadOnlyList<Guid>> SuspendOwnedAsync(Guid actorId, Guid ownerId, string reason, CancellationToken ct);
}

/// <summary>Membership changes other modules make inside their own transaction.</summary>
public interface IGroupMembership
{
    /// <summary>
    /// Removes a member as a kick or ban sanction (docs/ARCHITECTURE.md §3e). The database lets it through only when
    /// that sanction was added in the same transaction. Returns false when the person is no longer a member.
    /// </summary>
    Task<bool> RemoveAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid groupId, Guid userId, CancellationToken ct);
}
