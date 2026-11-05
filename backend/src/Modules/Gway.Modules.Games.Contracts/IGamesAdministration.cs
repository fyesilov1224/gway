using Gway.SharedKernel;

namespace Gway.Modules.Games.Contracts;

/// <summary>Chess at a glance for the admin panel (docs/ARCHITECTURE.md §3i, Yönetim paneli).</summary>
public sealed record ChessAdminOverview(
    int GamesToday,
    int GamesTotal,
    int ActiveGames,
    int WaitingSeeks,
    int PendingChallenges,
    int RatedPlayers,
    IReadOnlyList<ChessAdminGame> Active,
    IReadOnlyList<ChessAdminSuspension> Suspended);

/// <param name="Plies">Half-moves played so far.</param>
public sealed record ChessAdminGame(
    Guid Id, Guid? WhiteId, string? White, Guid? BlackId, string? Black, string Category, int BaseSeconds, int IncrementSeconds, bool Rated,
    int Plies, DateTimeOffset CreatedAt);

/// <param name="Until">Null: for good.</param>
public sealed record ChessAdminSuspension(Guid UserId, string Username, DateTimeOffset? Until, string? Reason);

/// <summary>Platform team actions on chess. Callers check platform staff roles first; every action is audited.</summary>
public interface IGamesAdministration
{
    Task<ChessAdminOverview> ChessOverviewAsync(CancellationToken ct);

    /// <summary>Ends an active game without a result or rating change.</summary>
    Task<Result> AbortChessGameAsync(Guid actorId, Guid gameId, string reason, CancellationToken ct);

    /// <summary>Keeps the person out of chess (games, seeks, challenges, leaderboard) until <paramref name="until"/> (null: for good).</summary>
    Task<Result> SuspendChessPlayerAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct);

    Task<Result> RestoreChessPlayerAsync(Guid actorId, Guid userId, CancellationToken ct);
}
