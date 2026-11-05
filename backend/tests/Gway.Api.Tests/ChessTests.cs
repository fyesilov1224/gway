using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gway.Modules.Admin;
using Gway.Modules.Games;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

public sealed class ChessRulesTests
{
    [Theory]
    [InlineData(60, 0, "bullet")]
    [InlineData(120, 1, "bullet")]
    [InlineData(180, 0, "blitz")]
    [InlineData(300, 3, "blitz")]
    [InlineData(600, 0, "rapid")]
    [InlineData(900, 10, "rapid")]
    public void Time_controls_fall_into_their_category(int baseSeconds, int increment, string category)
    {
        var tc = new TimeControl(baseSeconds, increment);
        Assert.True(tc.IsValid);
        Assert.Equal(category, tc.Category);
    }

    [Fact]
    public void Only_catalog_time_controls_are_valid() => Assert.False(new TimeControl(240, 0).IsValid);

    [Fact]
    public void Equal_players_trade_twenty_points_while_new()
    {
        Assert.Equal((20, -20), ChessRules.EloDeltas(1200, 0, 1200, 0, 1));
        Assert.Equal((0, 0), ChessRules.EloDeltas(1500, 50, 1500, 50, 0.5));
        // An upset pays more than an expected win.
        var (upset, _) = ChessRules.EloDeltas(1200, 50, 1600, 50, 1);
        var (expected, _) = ChessRules.EloDeltas(1600, 50, 1200, 50, 1);
        Assert.True(upset > expected);
        Assert.Equal(10, ChessRules.KFactor(2450, 100));
        Assert.Equal(20, ChessRules.KFactor(2000, 100));
        Assert.Equal(40, ChessRules.KFactor(2000, 29));
    }

    [Fact]
    public void Ratings_never_go_under_one_hundred() =>
        Assert.Equal(-10, ChessRules.EloDeltas(110, 0, 110, 0, 0).White);

    [Fact]
    public void Moves_are_validated_and_checkmate_ends_the_game()
    {
        string[] moves = ["e2e4", "e7e5", "f1c4", "b8c6", "d1h5", "g8f6"];
        Assert.Null(ChessRules.Play(moves, "h5h7x"));
        Assert.Null(ChessRules.Play(moves, "e1e3"));
        var mate = ChessRules.Play(moves, "h5f7");
        Assert.NotNull(mate);
        Assert.Equal("Qxf7#", mate.San);
        Assert.Equal(new Outcome("white", "checkmate"), mate.End);
    }

    [Fact]
    public void Promotion_keeps_its_piece_and_defaults_to_a_queen()
    {
        string[] moves = ["a2a4", "b7b5", "a4b5", "a7a6", "b5a6", "c8b7", "a6b7", "h7h6"];
        var knight = ChessRules.Play(moves, "b7a8n");
        Assert.Equal("b7a8n", knight!.Uci);
        Assert.StartsWith("N", knight.Fen);
        var queen = ChessRules.Play(moves, "b7a8");
        Assert.Equal("b7a8q", queen!.Uci);
        Assert.StartsWith("Q", queen.Fen);
    }

    [Fact]
    public void Threefold_repetition_is_a_draw()
    {
        string[] moves = ["g1f3", "g8f6", "f3g1", "f6g8", "g1f3", "g8f6", "f3g1"];
        Assert.Equal(new Outcome("draw", "repetition"), ChessRules.Play(moves, "f6g8")!.End);
    }

    [Fact]
    public void A_bare_king_or_a_lone_minor_piece_cannot_mate()
    {
        Assert.False(ChessRules.CanMate("8/8/8/8/8/8/1n6/K6k w - - 0 1", "black"));
        Assert.False(ChessRules.CanMate("8/8/8/8/8/8/1n6/K6k w - - 0 1", "white"));
        Assert.True(ChessRules.CanMate("8/8/8/8/8/8/1q6/K6k w - - 0 1", "black"));
        Assert.True(ChessRules.CanMate("8/8/8/8/8/8/1nn5/K6k w - - 0 1", "black"));
    }
}

public sealed class ChessTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid A, Guid B)> PlayersAsync() =>
        (await _db.CreateUserAsync(Unique("ch_")), await _db.CreateUserAsync(Unique("ch_")));

    private static async Task<JsonElement> GameOf(HttpResponseMessage response)
    {
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var view = await response.Content.ReadFromJsonAsync<JsonElement>(Ct);
        Assert.True(view.TryGetProperty("server_now", out _));
        return view.GetProperty("game");
    }

    /// <summary>A challenges B with A as white; B accepts. Returns the game.</summary>
    private async Task<Guid> StartAsync(Guid a, Guid b, bool rated = true, int baseSeconds = 180, int increment = 2)
    {
        var sent = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/chess/challenges"),
            new ChallengeRequest(b, baseSeconds, increment, rated, "white"), Ct);
        Assert.Equal(HttpStatusCode.OK, sent.StatusCode);
        var challenge = (await sent.Content.ReadFromJsonAsync<ChallengeCreated>(Ct))!.Id;
        var accepted = await factory.ClientFor(b).PostAsync(Path($"/games/chess/challenges/{challenge}/accept"), null, Ct);
        Assert.Equal(HttpStatusCode.OK, accepted.StatusCode);
        return (await accepted.Content.ReadFromJsonAsync<GameStarted>(Ct))!.GameId;
    }

    private Task<HttpResponseMessage> MoveAsync(Guid user, Guid game, string uci, int ply) =>
        factory.ClientFor(user).PostAsJsonAsync(Path($"/games/chess/{game}/moves"), new MoveRequest(uci, ply), Ct);

    [Fact]
    public async Task A_challenge_becomes_a_game_and_checkmate_moves_both_ratings()
    {
        var (a, b) = await PlayersAsync();
        var game = await StartAsync(a, b);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @b and actor_id = @a and type = 'chess_challenge'", ("a", a), ("b", b)));

        string[] moves = ["e2e4", "e7e5", "f1c4", "b8c6", "d1h5", "g8f6", "h5f7"];
        JsonElement last = default;
        for (var i = 0; i < moves.Length; i++)
        {
            last = await GameOf(await MoveAsync(i % 2 == 0 ? a : b, game, moves[i], i));
        }
        Assert.Equal("finished", last.GetProperty("status").GetString());
        Assert.Equal("white", last.GetProperty("result").GetString());
        Assert.Equal("checkmate", last.GetProperty("termination").GetString());
        Assert.Equal("Qxf7#", last.GetProperty("san")[6].GetString());
        Assert.Equal(20, last.GetProperty("white_delta").GetInt32());
        Assert.Equal(-20, last.GetProperty("black_delta").GetInt32());
        Assert.Equal(1220, await _db.ScalarAsync<int>("select rating from public.chess_ratings where user_id = @a and category = 'blitz'", ("a", a)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select losses from public.chess_ratings where user_id = @b and category = 'blitz'", ("b", b)));

        // Over is over.
        Assert.Equal(HttpStatusCode.Conflict, (await MoveAsync(b, game, "a7a6", 7)).StatusCode);
    }

    [Fact]
    public async Task Wrong_turn_stale_position_illegal_moves_and_outsiders_are_refused()
    {
        var (a, b) = await PlayersAsync();
        var outsider = await _db.CreateUserAsync(Unique("ch_"));
        var game = await StartAsync(a, b);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await MoveAsync(b, game, "e7e5", 0)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await MoveAsync(a, game, "e2e5", 0)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await MoveAsync(outsider, game, "e2e4", 0)).StatusCode);
        await GameOf(await MoveAsync(a, game, "e2e4", 0));
        // The same move sent twice: the second one is for a position that is gone.
        Assert.Equal(HttpStatusCode.Conflict, (await MoveAsync(a, game, "e2e4", 0)).StatusCode);
        // A second game while one is going is not allowed.
        var seek = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/chess/seeks"), new SeekRequest(180, 2), Ct);
        Assert.Equal(HttpStatusCode.Conflict, seek.StatusCode);
    }

    [Fact]
    public async Task Leaving_before_both_moved_aborts_without_rating_and_a_draw_needs_both()
    {
        var (a, b) = await PlayersAsync();
        var game = await StartAsync(a, b);
        var aborted = await GameOf(await factory.ClientFor(a).PostAsync(Path($"/games/chess/{game}/resign"), null, Ct));
        Assert.Equal("aborted", aborted.GetProperty("status").GetString());
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.chess_ratings where user_id in (@a, @b)", ("a", a), ("b", b)));

        var second = await StartAsync(a, b);
        var tooSoon = await factory.ClientFor(a).PostAsync(Path($"/games/chess/{second}/draw-offer"), null, Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, tooSoon.StatusCode);
        await GameOf(await MoveAsync(a, second, "e2e4", 0));
        await GameOf(await MoveAsync(b, second, "e7e5", 1));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(a).PostAsync(Path($"/games/chess/{second}/abort"), null, Ct)).StatusCode);
        var offered = await GameOf(await factory.ClientFor(a).PostAsync(Path($"/games/chess/{second}/draw-offer"), null, Ct));
        Assert.Equal("white", offered.GetProperty("draw_offer").GetString());
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await factory.ClientFor(a).PostAsync(Path($"/games/chess/{second}/draw-accept"), null, Ct)).StatusCode);
        var drawn = await GameOf(await factory.ClientFor(b).PostAsync(Path($"/games/chess/{second}/draw-accept"), null, Ct));
        Assert.Equal("draw", drawn.GetProperty("result").GetString());
        Assert.Equal("agreement", drawn.GetProperty("termination").GetString());
        Assert.Equal(1, await _db.ScalarAsync<int>("select draws from public.chess_ratings where user_id = @a and category = 'blitz'", ("a", a)));
    }

    [Fact]
    public async Task The_clock_runs_on_the_server_and_a_flag_loses()
    {
        var (a, b) = await PlayersAsync();
        var game = await StartAsync(a, b, rated: false);
        await GameOf(await MoveAsync(a, game, "e2e4", 0));
        await GameOf(await MoveAsync(b, game, "e7e5", 1));
        // White thought for 10 seconds: 180 s − 10 s + 2 s increment.
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '10 seconds' where id = @id", ("id", game));
        var moved = await GameOf(await MoveAsync(a, game, "g1f3", 2));
        var whiteMs = moved.GetProperty("white_ms").GetInt64();
        Assert.InRange(whiteMs, 171_000, 172_100);

        // Black's time runs out; the monitor ends the game, white still has mating material.
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '200 seconds' where id = @id", ("id", game));
        await factory.Services.GetRequiredService<ChessService>().SweepAsync(Ct);
        Assert.Equal("white", await _db.ScalarAsync<string>("select result from public.chess_games where id = @id", ("id", game)));
        Assert.Equal("timeout", await _db.ScalarAsync<string>("select termination from public.chess_games where id = @id", ("id", game)));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select black_ms from public.chess_games where id = @id", ("id", game)));
        // Unrated: no rating rows.
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.chess_ratings where user_id in (@a, @b)", ("a", a), ("b", b)));
    }

    [Fact]
    public async Task A_missed_first_move_aborts_the_game()
    {
        var (a, b) = await PlayersAsync();
        var game = await StartAsync(a, b);
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '31 seconds' where id = @id", ("id", game));
        var flagged = await GameOf(await factory.ClientFor(b).PostAsync(Path($"/games/chess/{game}/flag"), null, Ct));
        Assert.Equal("aborted", flagged.GetProperty("status").GetString());
    }

    [Fact]
    public async Task Two_seeks_for_the_same_time_pair_and_a_far_rating_waits()
    {
        var (a, b) = await PlayersAsync();
        var strong = await _db.CreateUserAsync(Unique("ch_"));
        await _db.ExecuteAsync("insert into public.chess_ratings (user_id, category, rating, games) values (@u, 'bullet', 2400, 40)", ("u", strong));

        var first = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/chess/seeks"), new SeekRequest(60, 0), Ct);
        Assert.Null((await first.Content.ReadFromJsonAsync<SeekResult>(Ct))!.GameId);
        // 1200 apart: the strong player is not paired with the waiting newcomer.
        var far = await factory.ClientFor(strong).PostAsJsonAsync(Path("/games/chess/seeks"), new SeekRequest(60, 0), Ct);
        Assert.Null((await far.Content.ReadFromJsonAsync<SeekResult>(Ct))!.GameId);
        await factory.ClientFor(strong).DeleteAsync(Path("/games/chess/seeks"), Ct);

        var second = await factory.ClientFor(b).PostAsJsonAsync(Path("/games/chess/seeks"), new SeekRequest(60, 0), Ct);
        var game = (await second.Content.ReadFromJsonAsync<SeekResult>(Ct))!.GameId;
        Assert.NotNull(game);
        var heartbeat = await factory.ClientFor(a).PostAsync(Path("/games/chess/seeks/heartbeat"), null, Ct);
        Assert.Equal(game, (await heartbeat.Content.ReadFromJsonAsync<SeekResult>(Ct))!.GameId);
        Assert.Equal("bullet", await _db.ScalarAsync<string>("select category from public.chess_games where id = @id", ("id", game!.Value)));
    }

    [Fact]
    public async Task Blocked_people_cannot_challenge_and_a_rematch_swaps_colors()
    {
        var (a, b) = await PlayersAsync();
        var blocked = await _db.CreateUserAsync(Unique("ch_"));
        await _db.ExecuteWithoutTriggersAsync("insert into public.blocks (blocker_id, blocked_id) values (@a, @c)", ("a", a), ("c", blocked));
        var refused = await factory.ClientFor(blocked).PostAsJsonAsync(Path("/games/chess/challenges"),
            new ChallengeRequest(a, 180, 2), Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, refused.StatusCode);

        var game = await StartAsync(a, b);
        await GameOf(await MoveAsync(a, game, "f2f3", 0));
        await GameOf(await MoveAsync(b, game, "e7e5", 1));
        await GameOf(await factory.ClientFor(a).PostAsync(Path($"/games/chess/{game}/resign"), null, Ct));

        var asked = await factory.ClientFor(a).PostAsync(Path($"/games/chess/{game}/rematch"), null, Ct);
        var askedResult = (await asked.Content.ReadFromJsonAsync<RematchResult>(Ct))!;
        Assert.NotNull(askedResult.ChallengeId);
        var answered = await factory.ClientFor(b).PostAsync(Path($"/games/chess/{game}/rematch"), null, Ct);
        var rematch = (await answered.Content.ReadFromJsonAsync<RematchResult>(Ct))!.GameId;
        Assert.NotNull(rematch);
        Assert.Equal(b, await _db.ScalarAsync<Guid>("select white_id from public.chess_games where id = @id", ("id", rematch!.Value)));
    }

    [Fact]
    public async Task Staff_abort_games_and_suspend_players_with_an_audit_trail()
    {
        var (a, b) = await PlayersAsync();
        var staff = await _db.CreateUserAsync(Unique("ch_"));
        await _db.MakeStaffAsync(staff, "moderator");
        var game = await StartAsync(a, b);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(a).GetAsync(Path("/admin/games/chess"), Ct)).StatusCode);
        var overview = await factory.ClientFor(staff).GetFromJsonAsync<JsonElement>(Path("/admin/games/chess"), Ct);
        Assert.Contains(overview.GetProperty("active").EnumerateArray(), g => g.GetProperty("id").GetGuid() == game);

        var aborted = await factory.ClientFor(staff).PostAsJsonAsync(Path($"/admin/games/chess/{game}/abort"), new AbortChessGameRequest("Hileli oyun"), Ct);
        Assert.Equal(HttpStatusCode.NoContent, aborted.StatusCode);
        Assert.Equal("aborted", await _db.ScalarAsync<string>("select status from public.chess_games where id = @id", ("id", game)));

        var suspended = await factory.ClientFor(staff).PostAsJsonAsync(Path($"/admin/games/chess/players/{a}/suspension"),
            new SuspendChessPlayerRequest("Motor kullanımı", null), Ct);
        Assert.Equal(HttpStatusCode.NoContent, suspended.StatusCode);
        var seek = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/chess/seeks"), new SeekRequest(180, 2), Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, seek.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await factory.ClientFor(b).PostAsJsonAsync(Path("/games/chess/challenges"), new ChallengeRequest(a, 180, 2), Ct)).StatusCode);

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(staff).DeleteAsync(Path($"/admin/games/chess/players/{a}/suspension"), Ct)).StatusCode);
        Assert.Equal(3, await _db.ScalarAsync<long>(
            """
            select count(*) from public.audit_log where actor_id = @s
              and action in ('games.chess_game_aborted', 'games.chess_player_suspended', 'games.chess_player_restored')
            """, ("s", staff)));
    }
}
