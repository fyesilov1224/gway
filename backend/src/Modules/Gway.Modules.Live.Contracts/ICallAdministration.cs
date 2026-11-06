using Gway.SharedKernel;

namespace Gway.Modules.Live.Contracts;

/// <summary>The group a request went to or a permission rests on; null when the platform team opened it.</summary>
public sealed record CallPermissionGroup(Guid Id, string Handle, string Name, string Status);

/// <summary>Who decided: <c>platform</c>, <c>group_owner</c>, <c>group_manager</c> or <c>system</c> (left the group).</summary>
public sealed record CallPermissionDecider(Guid? Id, string? Username, string? DisplayName, string Kind);

/// <summary>A person's voice call permission as the platform team sees it (docs/ARCHITECTURE.md §8c, Admin).</summary>
public sealed record CallPermissionRow(
    Guid UserId,
    string Username,
    string DisplayName,
    string? AvatarPath,
    string Status,
    string? Note,
    DateTimeOffset? RequestedAt,
    DateTimeOffset? DecidedAt,
    string? Reason,
    CallPermissionGroup? Group,
    CallPermissionDecider? DecidedBy);

/// <summary>How many in each state, the oldest waiting request, and calls of the last 24 hours (counts only: never who).</summary>
public sealed record CallPermissionSummary(
    int Requested,
    int Active,
    int Declined,
    int Revoked,
    DateTimeOffset? OldestRequestAt,
    int Calls24h,
    int Minutes24h);

public sealed record CallPermissionsPage(
    IReadOnlyList<CallPermissionRow> Items,
    int Total,
    int Page,
    int PageSize,
    CallPermissionSummary Summary);

/// <summary>One decision on a person's permission, from the audit log.</summary>
public sealed record CallPermissionEvent(
    DateTimeOffset At,
    string Action,
    string ActorKind,
    string? ActorUsername,
    string? ActorDisplayName,
    string? GroupName,
    string? Reason);

/// <summary>A person's permission (null: never asked) and its history. Their calls are never shown.</summary>
public sealed record CallUserDetail(
    Guid UserId,
    string Username,
    string DisplayName,
    CallPermissionRow? Permission,
    IReadOnlyList<CallPermissionEvent> History);

/// <summary>Platform team decisions on voice calls. Callers check the platform staff roles first.</summary>
public interface ICallAdministration
{
    /// <summary><paramref name="status"/>: requested (default), active, declined, revoked or all; <paramref name="query"/> matches the
    /// person's name or @username or the group's name.</summary>
    Task<CallPermissionsPage> PermissionsAsync(string? status, string? query, int page, CancellationToken ct);

    Task<Result<CallUserDetail>> UserAsync(Guid userId, CancellationToken ct);

    /// <summary>Opens (<paramref name="active"/>), declines a waiting request or closes an open permission; declining and
    /// closing need a reason, closing ends the person's call.</summary>
    Task<Result> SetPermissionAsync(Guid actorId, Guid userId, bool active, string? reason, CancellationToken ct);

    /// <summary>Opens voice calls for someone who never asked, found by username.</summary>
    Task<Result<Guid>> GrantByUsernameAsync(Guid actorId, string username, CancellationToken ct);
}
