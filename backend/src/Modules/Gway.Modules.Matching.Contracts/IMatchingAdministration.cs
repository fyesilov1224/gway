using Gway.SharedKernel;

namespace Gway.Modules.Matching.Contracts;

/// <summary>Matching at a glance for the admin panel (docs/ARCHITECTURE.md §3g, Admin). Counts only.</summary>
public sealed record MatchingStats(
    int Profiles,
    int FriendProfiles,
    int DatingProfiles,
    int Women,
    int Men,
    int Nonbinary,
    int Paused,
    int Suspended,
    int Likes24h,
    int Passes24h,
    int Matches24h,
    int ActiveMatches,
    int OpenReports,
    /// <summary>Profiles whose owner has any matching package now.</summary>
    int PremiumProfiles,
    int SuperLikes24h,
    int ActiveBoosts,
    MatchingSettings Settings);

/// <summary>The daily allowances (Turkey's day) and the boost length.</summary>
public sealed record MatchingSettings(int DailyFreeLikes, int DailyFreeSuperLikes, int DailyPremiumSuperLikes, int BoostMinutes);

/// <summary>Platform team actions on matching. Callers check platform staff roles first.</summary>
public interface IMatchingAdministration
{
    Task<MatchingStats> StatsAsync(CancellationToken ct);

    /// <summary>Hides the person's matching profile until <paramref name="until"/> (null: for good) and ends their matches.</summary>
    Task<Result> SuspendAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct);

    Task<Result> LiftSuspensionAsync(Guid actorId, Guid userId, CancellationToken ct);

    /// <summary>Removes one photo from the profile and from Storage.</summary>
    Task<Result> RemovePhotoAsync(Guid actorId, Guid photoId, string reason, CancellationToken ct);

    Task<Result> UpdateSettingsAsync(Guid actorId, MatchingSettings settings, CancellationToken ct);
}
