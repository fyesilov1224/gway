using GrupX.SharedKernel;

namespace GrupX.Modules.Moderation.Contracts;

/// <summary>Platform team actions on reports and appeals (docs/ARCHITECTURE.md §3e). Callers check platform staff roles first.</summary>
public interface IModerationAdministration
{
    /// <summary>Closes the open reports of the same target: dismissed, or actioned when the team acted with its own tools.</summary>
    Task<Result> ReviewReportAsync(Guid actorId, Guid reportId, bool actioned, CancellationToken ct);

    /// <summary>Decides an appeal the platform handles; overturning lifts the sanction.</summary>
    Task<Result> DecideAppealAsync(Guid actorId, Guid appealId, bool overturn, string? note, CancellationToken ct);
}
