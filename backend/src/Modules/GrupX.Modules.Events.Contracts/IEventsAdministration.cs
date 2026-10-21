using GrupX.SharedKernel;

namespace GrupX.Modules.Events.Contracts;

/// <summary>Platform team actions on events. Callers check platform staff roles first.</summary>
public interface IEventsAdministration
{
    /// <summary>Cancels the event for everyone; attendees are notified.</summary>
    Task<Result> CancelAsync(Guid actorId, Guid eventId, string reason, CancellationToken ct);

    /// <summary>Cancels an inappropriate goal of a group (docs/ARCHITECTURE.md §3d, Hedefler).</summary>
    Task<Result> CancelGoalAsync(Guid actorId, Guid goalId, CancellationToken ct);
}
