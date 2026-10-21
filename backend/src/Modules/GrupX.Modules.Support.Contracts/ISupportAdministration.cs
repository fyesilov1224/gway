using GrupX.SharedKernel;

namespace GrupX.Modules.Support.Contracts;

public static class SupportStatuses
{
    public const string Open = "open";
    public const string InProgress = "in_progress";
    public const string Resolved = "resolved";
    public const string Closed = "closed";

    public static readonly string[] All = [Open, InProgress, Resolved, Closed];
}

public static class SupportKinds
{
    public static readonly string[] All = ["problem", "request", "suggestion"];
}

/// <summary>Platform team actions on support tickets. Callers check platform staff roles first.</summary>
public interface ISupportAdministration
{
    Task<Result> ReplyAsync(Guid actorId, Guid ticketId, string body, CancellationToken ct);

    Task<Result> SetStatusAsync(Guid actorId, Guid ticketId, string status, CancellationToken ct);
}
