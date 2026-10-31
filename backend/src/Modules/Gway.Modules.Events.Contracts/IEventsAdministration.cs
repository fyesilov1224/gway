using Gway.SharedKernel;

namespace Gway.Modules.Events.Contracts;

/// <summary>Platform team actions on events. Callers check platform staff roles first.</summary>
public interface IEventsAdministration
{
    /// <summary>Cancels the event for everyone; attendees are notified.</summary>
    Task<Result> CancelAsync(Guid actorId, Guid eventId, string reason, CancellationToken ct);

    /// <summary>Stops a recurring series (docs/ARCHITECTURE.md §3d, Tekrarlayan organizasyon); open dates stay.</summary>
    Task<Result> StopSeriesAsync(Guid actorId, Guid seriesId, CancellationToken ct);

    /// <summary>Cancels an inappropriate goal of a group (docs/ARCHITECTURE.md §3d, Hedefler).</summary>
    Task<Result> CancelGoalAsync(Guid actorId, Guid goalId, CancellationToken ct);

    /// <summary>Removes an inappropriate meeting point (docs/ARCHITECTURE.md §3d, Harita ile keşif).</summary>
    Task<Result> RemoveMeetingPointAsync(Guid actorId, Guid eventId, CancellationToken ct);

    /// <summary>Takes a group out of an open league season (docs/ARCHITECTURE.md §3d, Gruplar Ligi); audited.</summary>
    Task<Result> ExcludeFromLeagueAsync(Guid actorId, DateOnly month, Guid groupId, string reason, CancellationToken ct);

    /// <summary>Puts an excluded group back into an open league season; audited.</summary>
    Task<Result> RestoreToLeagueAsync(Guid actorId, DateOnly month, Guid groupId, CancellationToken ct);
}
