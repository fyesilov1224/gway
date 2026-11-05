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

/// <summary>An open team match in the admin panel: chess with its time control, or a Zihin Düellosu match with its question count.</summary>
public sealed record TeamMatchAdminRow(
    Guid Id, string Home, string Away, int Boards, int? BaseSeconds, int? IncrementSeconds, string Status, DateTimeOffset StartsAt, string Game,
    int? Length);

/// <summary>Platform team actions on team matches. Callers check platform staff roles first; every action is audited.</summary>
public interface ITeamMatchAdministration
{
    Task<IReadOnlyList<TeamMatchAdminRow>> OpenMatchesAsync(CancellationToken ct);

    /// <summary>Calls off a match that has not started yet.</summary>
    Task<Result> CancelAsStaffAsync(Guid actorId, Guid id, string reason, CancellationToken ct);
}

/// <summary>An arena in the admin panel; <see cref="Title"/> is null for the weekly and monthly ones.</summary>
public sealed record TournamentAdminRow(
    Guid Id, string Kind, string? Title, int BaseSeconds, int IncrementSeconds, DateTimeOffset StartsAt, DateTimeOffset EndsAt, string Status,
    int Players);

/// <summary>An extra arena opened by the platform team.</summary>
public sealed record TournamentDraft(string Title, int BaseSeconds, int IncrementSeconds, DateTimeOffset StartsAt, int Minutes);

/// <summary>Platform team actions on arenas. Callers check platform staff roles first; every action is audited.</summary>
public interface ITournamentAdministration
{
    Task<IReadOnlyList<TournamentAdminRow>> ListAsync(CancellationToken ct);

    Task<Result<Guid>> CreateAsync(Guid actorId, TournamentDraft draft, CancellationToken ct);

    /// <summary>Only an arena that has not started.</summary>
    Task<Result> CancelAsync(Guid actorId, Guid id, string reason, CancellationToken ct);
}

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

/// <summary>Zihin Düellosu at a glance for the admin panel (docs/ARCHITECTURE.md §3j, Yönetim paneli).</summary>
public sealed record MindAdminOverview(
    int MatchesToday,
    int MatchesTotal,
    int ActiveMatches,
    int WaitingSeeks,
    int PendingChallenges,
    int RatedPlayers,
    IReadOnlyList<MindAdminMatch> Active);

/// <param name="AAnswered">Questions the first player has answered so far.</param>
public sealed record MindAdminMatch(
    Guid Id, string? A, string? B, int Length, bool Rated, int AScore, int BScore, int AAnswered, int BAnswered, DateTimeOffset CreatedAt);

/// <summary>Platform team actions on duels. Callers check platform staff roles first; every action is audited.</summary>
public interface IMindAdministration
{
    Task<MindAdminOverview> MindOverviewAsync(CancellationToken ct);

    /// <summary>Ends a running duel without a result or rating change.</summary>
    Task<Result> AbortMindMatchAsync(Guid actorId, Guid matchId, string reason, CancellationToken ct);
}
