using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Games;
using Gway.Modules.Games.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

public sealed class ArenaPointsTests
{
    [Theory]
    [InlineData(1.0, 0, 2)]
    [InlineData(0.5, 0, 1)]
    [InlineData(0.0, 0, 0)]
    [InlineData(1.0, 2, 4)]
    [InlineData(0.5, 3, 2)]
    [InlineData(0.0, 5, 0)]
    public void Two_wins_in_a_row_double_the_next_result(double score, int streak, int points) =>
        Assert.Equal(points, TournamentService.Points(score, streak));
}

public sealed class ArenaTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private TournamentService Arenas => factory.Services.GetRequiredService<TournamentService>();

    private async Task<Guid> ArenaAsync(Guid admin)
    {
        var created = await factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/games/chess/tournaments"),
            new TournamentDraft("Cuma Blitz Arenası", 180, 2, DateTimeOffset.UtcNow.AddMinutes(10), 60), Ct);
        Assert.Equal(HttpStatusCode.OK, created.StatusCode);
        return await created.Content.ReadFromJsonAsync<Guid>(Ct);
    }

    private Task StartNowAsync(Guid arena) => _db.ExecuteAsync(
        "update public.chess_tournaments set starts_at = now() - interval '1 second', ends_at = now() + interval '1 hour' where id = @id", ("id", arena));

    private Task<HttpResponseMessage> JoinAsync(Guid user, Guid arena) => factory.ClientFor(user).PostAsync(Path($"/games/chess/tournaments/{arena}/join"), null, Ct);

    private Task<Guid> CurrentGameAsync(Guid arena, Guid user) => _db.ScalarAsync<Guid>(
        "select current_game_id from public.chess_tournament_players where tournament_id = @t and user_id = @u", ("t", arena), ("u", user));

    private Task<int> PointsAsync(Guid arena, Guid user) => _db.ScalarAsync<int>(
        "select points from public.chess_tournament_players where tournament_id = @t and user_id = @u", ("t", arena), ("u", user));

    /// <summary>The player to win checkmates if white, otherwise the loser resigns after two moves.</summary>
    private async Task WinAsync(Guid game, Guid winner)
    {
        var white = await _db.ScalarAsync<Guid>("select white_id from public.chess_games where id = @g", ("g", game));
        var black = await _db.ScalarAsync<Guid>("select black_id from public.chess_games where id = @g", ("g", game));
        (await factory.ClientFor(white).PostAsJsonAsync(Path($"/games/chess/{game}/moves"), new MoveRequest("e2e4", 0), Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(black).PostAsJsonAsync(Path($"/games/chess/{game}/moves"), new MoveRequest("e7e5", 1), Ct)).EnsureSuccessStatusCode();
        var loser = winner == white ? black : white;
        (await factory.ClientFor(loser).PostAsync(Path($"/games/chess/{game}/resign"), null, Ct)).EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task An_arena_pairs_waiting_players_scores_streaks_double_and_the_top_three_get_medals()
    {
        var admin = await _db.CreateUserAsync(Unique("ar_"));
        await _db.MakeStaffAsync(admin, "admin");
        var (a, b, c) = (await _db.CreateUserAsync(Unique("ar_")), await _db.CreateUserAsync(Unique("ar_")), await _db.CreateUserAsync(Unique("ar_")));
        var arena = await ArenaAsync(admin);

        // Joining early registers; leaving is allowed before the start.
        foreach (var p in new[] { a, b, c }) Assert.Equal(HttpStatusCode.NoContent, (await JoinAsync(p, arena)).StatusCode);
        Assert.False(await _db.ScalarAsync<bool>("select bool_or(waiting) from public.chess_tournament_players where tournament_id = @t", ("t", arena)));

        await StartNowAsync(arena);
        await Arenas.TickAsync(Ct);
        Assert.Equal("live", await _db.ScalarAsync<string>("select status from public.chess_tournaments where id = @id", ("id", arena)));
        Assert.Equal(3, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'chess_arena_start' and recipient_id in (@a, @b, @c)", ("a", a), ("b", b), ("c", c)));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(a).DeleteAsync(Path($"/games/chess/tournaments/{arena}/registration"), Ct)).StatusCode);

        // Two of the three were paired; the arena game can't be aborted.
        var first = await _db.ScalarAsync<long>(
            "select count(*) from public.chess_games where tournament_id = @t and status = 'active'", ("t", arena));
        Assert.Equal(1, first);
        var paired = new List<Guid>();
        foreach (var p in new[] { a, b, c })
            if (await _db.ScalarAsync<object>("select current_game_id from public.chess_tournament_players where tournament_id = @t and user_id = @u",
                    ("t", arena), ("u", p)) is Guid) paired.Add(p);
        Assert.Equal(2, paired.Count);
        var winner = paired[0];
        var game1 = await CurrentGameAsync(arena, winner);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(winner).PostAsync(Path($"/games/chess/{game1}/abort"), null, Ct)).StatusCode);

        // Win, win, then the third win is doubled: 2 + 2 + 4.
        await WinAsync(game1, winner);
        Assert.Equal(2, await PointsAsync(arena, winner));
        for (var round = 0; round < 2; round++)
        {
            await Arenas.TickAsync(Ct);
            var game = await CurrentGameAsync(arena, winner);
            await WinAsync(game, winner);
        }
        Assert.Equal(8, await PointsAsync(arena, winner));
        Assert.Equal(3, await _db.ScalarAsync<int>("select streak from public.chess_tournament_players where tournament_id = @t and user_id = @u",
            ("t", arena), ("u", winner)));

        // Someone who never moves loses the game and is paused; the opponent scores.
        await Arenas.TickAsync(Ct);
        var noShow = await CurrentGameAsync(arena, winner);
        var whiteId = await _db.ScalarAsync<Guid>("select white_id from public.chess_games where id = @g", ("g", noShow));
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '31 seconds' where id = @g", ("g", noShow));
        await factory.Services.GetRequiredService<ChessService>().SweepAsync(Ct);
        Assert.Equal("no_show", await _db.ScalarAsync<string>("select termination from public.chess_games where id = @g", ("g", noShow)));
        Assert.False(await _db.ScalarAsync<bool>("select waiting from public.chess_tournament_players where tournament_id = @t and user_id = @u",
            ("t", arena), ("u", whiteId)));

        // The end: ranks and medals.
        await _db.ExecuteAsync(
            "update public.chess_tournaments set starts_at = now() - interval '2 hours', ends_at = now() - interval '1 second' where id = @id", ("id", arena));
        await Arenas.TickAsync(Ct);
        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.chess_tournaments where id = @id", ("id", arena)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select final_rank from public.chess_tournament_players where tournament_id = @t and user_id = @u",
            ("t", arena), ("u", winner)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'chess_arena_medal' and recipient_id = @u", ("u", winner)));
    }

    [Fact]
    public async Task Only_admins_open_arenas_and_a_scheduled_one_can_be_called_off()
    {
        var admin = await _db.CreateUserAsync(Unique("ar_"));
        var moderator = await _db.CreateUserAsync(Unique("ar_"));
        await _db.MakeStaffAsync(admin, "admin");
        await _db.MakeStaffAsync(moderator, "moderator");
        var denied = await factory.ClientFor(moderator).PostAsJsonAsync(Path("/admin/games/chess/tournaments"),
            new TournamentDraft("Deneme Arenası", 180, 2, DateTimeOffset.UtcNow.AddMinutes(10), 60), Ct);
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);
        var invalid = await factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/games/chess/tournaments"),
            new TournamentDraft("Deneme Arenası", 240, 0, DateTimeOffset.UtcNow.AddMinutes(10), 60), Ct);
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);

        var arena = await ArenaAsync(admin);
        var canceled = await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/games/chess/tournaments/{arena}/cancel"),
            new CancelTournamentRequest("Bakım çalışması"), Ct);
        Assert.Equal(HttpStatusCode.NoContent, canceled.StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await JoinAsync(admin, arena)).StatusCode);
        Assert.Equal(2, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where target_id = @id and action in ('games.arena_created', 'games.arena_canceled')",
            ("id", arena.ToString())));
    }

    [Fact]
    public async Task The_database_keeps_weekly_and_monthly_arenas_scheduled()
    {
        await Arenas.TickAsync(Ct);
        Assert.True(await _db.ScalarAsync<long>(
            "select count(*) from public.chess_tournaments where kind = 'weekly' and status = 'scheduled' and starts_at > now()") >= 4);
        Assert.True(await _db.ScalarAsync<long>(
            "select count(*) from public.chess_tournaments where kind = 'monthly' and status = 'scheduled' and starts_at > now()") >= 1);
        // Chess on Sunday 21:00 in Turkey; duels on Saturday 21:00.
        Assert.Equal(0, await _db.ScalarAsync<long>(
            """
            select count(*) from public.chess_tournaments where kind = 'weekly' and game = 'chess'
              and (extract(isodow from starts_at at time zone 'Europe/Istanbul') <> 7 or extract(hour from starts_at at time zone 'Europe/Istanbul') <> 21)
            """));
        Assert.Equal(0, await _db.ScalarAsync<long>(
            """
            select count(*) from public.chess_tournaments where kind = 'weekly' and game = 'mind'
              and (length <> 10 or extract(isodow from starts_at at time zone 'Europe/Istanbul') <> 6
                   or extract(hour from starts_at at time zone 'Europe/Istanbul') <> 21)
            """));
        Assert.True(await _db.ScalarAsync<long>(
            "select count(*) from public.chess_tournaments where game = 'mind' and kind = 'monthly' and length = 20 and status = 'scheduled'") >= 1);
    }
}
