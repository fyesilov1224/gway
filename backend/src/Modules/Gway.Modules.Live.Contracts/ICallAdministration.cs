using Gway.SharedKernel;

namespace Gway.Modules.Live.Contracts;

/// <summary>A person's voice call permission as the platform team sees it (docs/ARCHITECTURE.md §8c).</summary>
public sealed record CallPermissionRow(
    Guid UserId,
    string Username,
    string DisplayName,
    string? AvatarPath,
    string Status,
    string? Note,
    DateTimeOffset? RequestedAt,
    DateTimeOffset? DecidedAt,
    string? Reason);

/// <summary>A person's call permission. The platform team never sees whom a person called (docs/ARCHITECTURE.md §8c).</summary>
public sealed record CallUserDetail(CallPermissionRow? Permission);

public sealed record CallPermissionsPage(IReadOnlyList<CallPermissionRow> Items, int Calls24h, int Minutes24h);

/// <summary>Platform team decisions on voice calls. Callers check platform staff roles first.</summary>
public interface ICallAdministration
{
    /// <summary><paramref name="status"/>: requested (default), active, declined or revoked.</summary>
    Task<CallPermissionsPage> PermissionsAsync(string? status, CancellationToken ct);

    /// <summary>Opens (<paramref name="active"/>) or closes the feature for a person; closing needs a reason and ends their call.</summary>
    Task<Result> SetPermissionAsync(Guid actorId, Guid userId, bool active, string? reason, CancellationToken ct);

    Task<Result<CallUserDetail>> UserAsync(Guid userId, CancellationToken ct);
}
