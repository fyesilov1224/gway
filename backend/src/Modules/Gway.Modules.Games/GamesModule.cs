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
        services.AddSingleton<ITeamMatchAdministration>(sp => sp.GetRequiredService<TeamMatchService>());
        services.AddHostedService<ChessMonitor>();
        return services;
    }

    /// <summary>Chess (docs/ARCHITECTURE.md §3i, API). Reads go through Supabase; every write is here.</summary>
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

        return app;
    }
}

/// <summary>Ends games whose clock ran out (<c>Games:MonitorInterval</c>, default one second; zero turns it off).</summary>
internal sealed partial class ChessMonitor(ChessService chess, TeamMatchService teams, IConfiguration configuration, ILogger<ChessMonitor> logger)
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
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Chess monitor run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
