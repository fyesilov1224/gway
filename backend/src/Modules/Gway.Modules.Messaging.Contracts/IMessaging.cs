using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Messaging.Contracts;

/// <summary>
/// Platform team actions on messages (docs/ARCHITECTURE.md §3f). Callers check platform staff roles first.
/// The platform team never reads private messages; it can only remove a reported one.
/// </summary>
public interface IMessagingAdministration
{
    Task<Result> RemoveMessageAsync(Guid actorId, Guid messageId, string reason, CancellationToken ct);
}

/// <summary>A group's moderation removing a group chat message, inside the caller's transaction.</summary>
public interface IMessagingModeration
{
    /// <summary>Clears the message as removed; the database checks the actor's review permission. False when already gone.</summary>
    Task<bool> RemoveMessageAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid messageId, string reason, CancellationToken ct);
}
