using Gway.SharedKernel;
using Npgsql;

namespace Gway.Modules.Feed.Contracts;

/// <summary>Platform team actions on content. Callers check platform staff roles first.</summary>
public interface IFeedAdministration
{
    /// <summary>Hides a post from everyone but staff; it is kept as evidence.</summary>
    Task<Result> RemovePostAsync(Guid actorId, Guid postId, string reason, CancellationToken ct);

    Task<Result> RestorePostAsync(Guid actorId, Guid postId, CancellationToken ct);

    Task<Result> RemoveCommentAsync(Guid actorId, Guid commentId, string reason, CancellationToken ct);
}

/// <summary>Content actions of a group's moderation (docs/ARCHITECTURE.md §3e), inside the caller's transaction.</summary>
public interface IFeedModeration
{
    /// <summary>Hides a comment as evidence; the database checks the actor's review permission and rank. False when already gone.</summary>
    Task<bool> RemoveCommentAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid commentId, string reason, CancellationToken ct);
}
