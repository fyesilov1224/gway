using System.Security.Claims;
using Gway.Modules.Games.Contracts;
using Gway.SharedKernel.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Gway.Modules.Games;

public static class GamesModule
{
    public static IServiceCollection AddGamesModule(this IServiceCollection services)
    {
        services.AddSingleton<ChessService>();
        services.AddSingleton<IGamesAdministration>(sp => sp.GetRequiredService<ChessService>());
        services.AddSingleton<TeamMatchService>();
        services.AddSingleton<TournamentService>();
        services.AddSingleton<ITournamentAdministration>(sp => sp.GetRequiredService<TournamentService>());
        services.AddSingleton<ITeamMatchAdministration>(sp => sp.GetRequiredService<TeamMatchService>());
        services.AddSingleton<MindService>();
        services.AddSingleton<IMindAdministration>(sp => sp.GetRequiredService<MindService>());
        services.AddHostedService<GamesMonitor>();
        return services;
    }

    /// <summary>Chess (docs/ARCHITECTURE.md §3i, API) and Zihin Düellosu (§3j). Reads go through Supabase; every write is here.</summary>
    public static IEndpointRouteBuilder MapGamesEndpoints(this IEndpointRouteBuilder app)
    {
        var chess = app.MapGroup("/games/chess");

        chess.MapPost("/seeks", async (SeekRequest body, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.SeekAsync(user.GetUserId(), body, ct)).ToHttpResult());
        chess.MapPost("/seeks/heartbeat", async (ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.HeartbeatAsync(user.GetUserId(), ct)).ToHttpResult());
        chess.MapDelete("/seeks", async (ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.CancelSeekAsync(user.GetUserId(), ct)).ToHttpResult());

        chess.MapPost("/challenges", async (ChallengeRequest body, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.ChallengeAsync(user.GetUserId(), body, ct)).ToHttpResult());
        chess.MapPost("/challenges/{id:guid}/accept", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.AcceptChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/challenges/{id:guid}/decline", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.DeclineChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapDelete("/challenges/{id:guid}", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.CancelChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());

        chess.MapGet("/{id:guid}", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.GetAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/moves", async (Guid id, MoveRequest body, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.MoveAsync(user.GetUserId(), id, body, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/resign", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.ResignAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/abort", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.AbortAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/draw-offer", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.OfferDrawAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/draw-accept", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.AcceptDrawAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/draw-decline", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.DeclineDrawAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/flag", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.FlagAsync(user.GetUserId(), id, ct)).ToHttpResult());
        chess.MapPost("/{id:guid}/rematch", async (Guid id, ClaimsPrincipal user, ChessService s, CancellationToken ct) =>
            (await s.RematchAsync(user.GetUserId(), id, ct)).ToHttpResult());

        var arenas = chess.MapGroup("/tournaments");
        arenas.MapPost("/{id:guid}/join", async (Guid id, ClaimsPrincipal user, TournamentService s, CancellationToken ct) =>
            (await s.JoinAsync(user.GetUserId(), id, ct)).ToHttpResult());
        arenas.MapPost("/{id:guid}/pause", async (Guid id, ClaimsPrincipal user, TournamentService s, CancellationToken ct) =>
            (await s.PauseAsync(user.GetUserId(), id, ct)).ToHttpResult());
        arenas.MapDelete("/{id:guid}/registration", async (Guid id, ClaimsPrincipal user, TournamentService s, CancellationToken ct) =>
            (await s.LeaveAsync(user.GetUserId(), id, ct)).ToHttpResult());

        var teams = chess.MapGroup("/team-matches");
        teams.MapPost("", async (TeamMatchRequest body, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.CreateAsync(user.GetUserId(), body, ct)).ToHttpResult());
        teams.MapPost("/{id:guid}/accept", async (Guid id, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.RespondAsync(user.GetUserId(), id, true, ct)).ToHttpResult());
        teams.MapPost("/{id:guid}/decline", async (Guid id, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.RespondAsync(user.GetUserId(), id, false, ct)).ToHttpResult());
        teams.MapDelete("/{id:guid}", async (Guid id, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.CancelAsync(user.GetUserId(), id, ct)).ToHttpResult());
        teams.MapPut("/{id:guid}/lineup", async (Guid id, LineupRequest body, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.SetLineupAsync(user.GetUserId(), id, body, ct)).ToHttpResult());

        var mind = app.MapGroup("/games/mind");
        mind.MapPost("/seeks", async (MindSeekRequest body, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.SeekAsync(user.GetUserId(), body, ct)).ToHttpResult());
        mind.MapPost("/seeks/heartbeat", async (ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.HeartbeatAsync(user.GetUserId(), ct)).ToHttpResult());
        mind.MapDelete("/seeks", async (ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.CancelSeekAsync(user.GetUserId(), ct)).ToHttpResult());
        mind.MapPost("/challenges", async (MindChallengeRequest body, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.ChallengeAsync(user.GetUserId(), body, ct)).ToHttpResult());
        mind.MapPost("/challenges/{id:guid}/accept", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.AcceptChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapPost("/challenges/{id:guid}/decline", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.DeclineChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapDelete("/challenges/{id:guid}", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.CancelChallengeAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapGet("/{id:guid}", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.GetAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapPost("/{id:guid}/next", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.NextAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapPost("/{id:guid}/answers", async (Guid id, MindAnswerRequest body, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.AnswerAsync(user.GetUserId(), id, body, ct)).ToHttpResult());
        mind.MapPost("/{id:guid}/resign", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.ResignAsync(user.GetUserId(), id, ct)).ToHttpResult());
        mind.MapPost("/team-matches", async (MindTeamMatchRequest body, ClaimsPrincipal user, TeamMatchService s, CancellationToken ct) =>
            (await s.CreateAsync(user.GetUserId(),
                new TeamMatchRequest(body.HomeGroupId, body.AwayGroupId, body.Boards, 0, 0, body.StartsAt, "mind", body.Length), ct)).ToHttpResult());
        mind.MapPost("/{id:guid}/rematch", async (Guid id, ClaimsPrincipal user, MindService s, CancellationToken ct) =>
            (await s.RematchAsync(user.GetUserId(), id, ct)).ToHttpResult());

        return app;
    }
}

/// <summary>Ends games and duels whose time ran out (<c>Games:MonitorInterval</c>, default one second; zero turns it off).</summary>
internal sealed partial class GamesMonitor(
    ChessService chess, TeamMatchService teams, TournamentService arenas, MindService mind, IConfiguration configuration, ILogger<GamesMonitor> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Games:MonitorInterval", TimeSpan.FromSeconds(1));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database outage must not stop the API; the next run retries.
            try
            {
                await chess.SweepAsync(stoppingToken);
                await teams.StartDueAsync(stoppingToken);
                await arenas.TickAsync(stoppingToken);
                await mind.SweepAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Games monitor run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
