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

/// <summary>A person as the message logs show them; null when the account is gone.</summary>
public sealed record LogPerson(Guid Id, string Username, string DisplayName, string? AvatarPath);

public sealed record LogGroup(Guid Id, string Handle, string Name, string? LogoPath);

/// <summary>One conversation in a person's message log (docs/ARCHITECTURE.md §3f, Mesaj kayıtları).</summary>
/// <param name="Peer">The other person of a direct conversation.</param>
/// <param name="TableEvening">The evening of a "Bu akşam boşum" table.</param>
public sealed record LogConversation(
    Guid Id,
    string Kind,
    DateTimeOffset CreatedAt,
    DateTimeOffset? LastMessageAt,
    int MessageCount,
    int TargetMessageCount,
    int DeletedCount,
    LogPerson? Peer,
    LogGroup? Group,
    DateOnly? TableEvening);

public sealed record LogConversationPage(
    LogPerson User,
    LogPerson? WithUser,
    IReadOnlyList<LogConversation> Items,
    int Page,
    int PageSize,
    int Total);

/// <param name="Body">For a deleted message the archived text; empty when the archive no longer holds it.</param>
/// <param name="ImageUrl">A short-lived signed URL of the photo; deleted messages keep no photo.</param>
/// <param name="Archived">Deleted, and the text comes from the archive.</param>
/// <param name="RemovedReason">Set when moderation removed the message; a deletion by the sender has none.</param>
public sealed record LogMessage(
    Guid Id,
    LogPerson? Sender,
    string Body,
    string? ImageUrl,
    bool HadImage,
    bool Archived,
    DateTimeOffset CreatedAt,
    DateTimeOffset? DeletedAt,
    string? RemovedReason,
    DateTimeOffset? PurgeAfter);

public sealed record LogConversationHeader(
    Guid Id,
    string Kind,
    DateTimeOffset CreatedAt,
    DateTimeOffset? LastMessageAt,
    int MessageCount,
    LogGroup? Group,
    DateOnly? TableEvening,
    IReadOnlyList<LogPerson> Participants);

/// <param name="Messages">Oldest first.</param>
/// <param name="HasOlder">Older messages exist; ask again with the first message's time as <c>before</c>.</param>
public sealed record LogConversationView(LogConversationHeader Conversation, IReadOnlyList<LogMessage> Messages, bool HasOlder);

/// <param name="Kind">'direct', 'group' or 'table'; null for all.</param>
public sealed record MessageLogSearch(string Username, string? WithUsername, string? Kind, int Page, string Reason);

public sealed record MessageLogQuery(string Reason, DateTimeOffset? Before, string? Query);

/// <summary>The platform admin reading conversations, with a reason; every read is audited. Callers check the admin role first.</summary>
public interface IMessageLogs
{
    Task<Result<LogConversationPage>> SearchAsync(Guid actorId, MessageLogSearch search, CancellationToken ct);

    Task<Result<LogConversationView>> ViewAsync(Guid actorId, Guid conversationId, MessageLogQuery query, CancellationToken ct);
}
