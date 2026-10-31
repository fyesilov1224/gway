using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Live.Contracts;

/// <summary>Platform team actions on live broadcasts. Callers check platform staff roles first.</summary>
public interface ILiveAdministration
{
    /// <summary>Emergency close: ends the broadcast and closes its room for everyone.</summary>
    Task<Result> ForceEndAsync(Guid actorId, Guid broadcastId, string reason, CancellationToken ct);

    /// <summary>People in each broadcast's room right now; rooms that are gone are left out.</summary>
    Task<IReadOnlyDictionary<Guid, int>> ParticipantCountsAsync(IReadOnlyCollection<Guid> broadcastIds, CancellationToken ct);
}

/// <summary>Group sanctions in live rooms (docs/ARCHITECTURE.md §3e).</summary>
public interface ILiveModeration
{
    /// <summary>Deletes a live comment inside the caller's transaction (the database checks the actor). False when already gone.</summary>
    Task<bool> RemoveCommentAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, long commentId, CancellationToken ct);

    /// <summary>
    /// Applies the person's standing to the group's live room right now: out of the room when no longer a member,
    /// off the stage and without microphone while muted. Best effort; a LiveKit outage is only logged.
    /// </summary>
    Task EnforceSanctionAsync(Guid groupId, Guid userId, CancellationToken ct);
}
