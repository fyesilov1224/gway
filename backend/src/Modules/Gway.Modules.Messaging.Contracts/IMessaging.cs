using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Messaging.Contracts;

/// <summary>A message as the platform team sees it when reviewing a report.</summary>
public sealed record ContextMessage(
    Guid Id,
    Guid SenderId,
    string? SenderUsername,
    string? SenderName,
    string Body,
    bool HasImage,
    DateTimeOffset CreatedAt,
    bool Deleted,
    bool Reported);

/// <summary>Platform team actions on messages (docs/ARCHITECTURE.md §3f). Callers check platform staff roles first.</summary>
public interface IMessagingAdministration
{
    /// <summary>The reported message and the five before it in its conversation; the viewing is audited.</summary>
    Task<Result<IReadOnlyList<ContextMessage>>> ContextAsync(Guid actorId, Guid messageId, Guid reportId, CancellationToken ct);

    Task<Result> RemoveMessageAsync(Guid actorId, Guid messageId, string reason, CancellationToken ct);
}

/// <summary>A group's moderation removing a group chat message, inside the caller's transaction.</summary>
public interface IMessagingModeration
{
    /// <summary>Clears the message as removed; the database checks the actor's review permission. False when already gone.</summary>
    Task<bool> RemoveMessageAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid messageId, string reason, CancellationToken ct);
}
