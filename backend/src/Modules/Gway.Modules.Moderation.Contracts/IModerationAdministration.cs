using Gway.SharedKernel;

namespace Gway.Modules.Moderation.Contracts;

/// <summary>Platform team actions on reports and appeals (docs/ARCHITECTURE.md §3e). Callers check platform staff roles first.</summary>
public interface IModerationAdministration
{
    /// <summary>Closes the open reports of the same target: dismissed, or actioned when the team acted with its own tools.</summary>
    Task<Result> ReviewReportAsync(Guid actorId, Guid reportId, bool actioned, CancellationToken ct);

    /// <summary>Decides an appeal the platform handles; overturning lifts the sanction.</summary>
    Task<Result> DecideAppealAsync(Guid actorId, Guid appealId, bool overturn, string? note, CancellationToken ct);

    /// <summary>
    /// Decides an illegal-activity referral (docs/ARCHITECTURE.md §3e): a ban closes the account for <paramref name="banDays"/>
    /// or for good; clearing lifts the review suspension. The caller ends the person's paid plans and groups after a ban.
    /// </summary>
    Task<Result<ReferralDecision>> DecideReferralAsync(
        Guid actorId, Guid referralId, bool ban, int? banDays, bool notifyAuthorities, string note, CancellationToken ct);

    /// <summary>Records that the team notified the authorities about a referral marked for it.</summary>
    Task<Result> MarkAuthoritiesNotifiedAsync(Guid actorId, Guid referralId, string note, CancellationToken ct);
}

/// <summary>A decided referral: whose account and whether it was banned (until is null for a permanent ban).</summary>
public sealed record ReferralDecision(Guid SubjectId, bool Banned, DateTimeOffset? Until);
