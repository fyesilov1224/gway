using System.Text.Json;
using Gway.Modules.Games.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Games;

public sealed record SeekRequest(int BaseSeconds, int IncrementSeconds, bool Rated = true);

/// <summary>Null <see cref="GameId"/>: still waiting.</summary>
public sealed record SeekResult(Guid? GameId);

/// <param name="Color">The challenger's color: <c>random</c>, <c>white</c> or <c>black</c>.</param>
public sealed record ChallengeRequest(Guid OpponentId, int BaseSeconds, int IncrementSeconds, bool Rated = true, string Color = "random");

public sealed record ChallengeCreated(Guid Id);

public sealed record GameStarted(Guid GameId);

/// <param name="Ply">The number of half-moves the client has seen; a move for an older position is refused.</param>
public sealed record MoveRequest(string Uci, int Ply);

/// <summary>A rematch either waits for the opponent (<see cref="ChallengeId"/>) or starts at once (<see cref="GameId"/>).</summary>
public sealed record RematchResult(Guid? ChallengeId, Guid? GameId);

/// <summary>
/// Chess games (docs/ARCHITECTURE.md §3i). Every write happens here inside one transaction with the game row locked:
/// the move is checked against the rules, the clock is server time and the rating changes commit with the result.
/// </summary>
internal sealed class ChessService(NpgsqlDataSource db) : IGamesAdministration
{
    private static readonly Error TimeControlInvalid = Error.Validation("games.time_control_invalid", "Bu süre seçeneği yok.");
    private static readonly Error ColorInvalid = Error.Validation("games.color_invalid", "Geçersiz renk.");
    private static readonly Error Suspended = Error.RuleViolation("games.suspended", "Satranç oynaman şu anda kapalı.");
    private static readonly Error Busy = Error.Conflict("games.busy", "Önce süren oyununu bitir.");
    private static readonly Error OpponentBusy = Error.Conflict("games.opponent_busy", "Rakibin şu anda başka bir oyunda.");
    private static readonly Error GameNotFound = Error.NotFound("games.not_found", "Oyun bulunamadı.");
    private static readonly Error NotPlayer = Error.Forbidden("games.not_player", "Bu oyunda oyuncu değilsin.");
    private static readonly Error GameOver = Error.Conflict("games.over", "Oyun bitti.");
    private static readonly Error OutOfSync = Error.Conflict("games.out_of_sync", "Oyun güncellendi, tahta yenileniyor.");
    private static readonly Error NotYourTurn = Error.RuleViolation("games.not_your_turn", "Sıra sende değil.");
    private static readonly Error Illegal = Error.RuleViolation("games.illegal_move", "Bu hamle kurallara uygun değil.");
    private static readonly Error DrawTooSoon = Error.RuleViolation("games.draw_too_soon", "Beraberlik teklifi için biraz daha oynayın.");
    private static readonly Error NoDrawOffer = Error.RuleViolation("games.no_draw_offer", "Beraberlik teklifi yok.");
    private static readonly Error AbortTooLate = Error.RuleViolation("games.abort_too_late", "Oyun başladı; artık iptal edilemez, terk edebilirsin.");
    private static readonly Error ChallengeNotFound = Error.NotFound("games.challenge_not_found", "Davet bulunamadı.");
    private static readonly Error ChallengeClosed = Error.Conflict("games.challenge_closed", "Bu davet artık geçerli değil.");
    private static readonly Error ChallengeSelf = Error.Validation("games.challenge_self", "Kendini davet edemezsin.");
    private static readonly Error OpponentUnavailable = Error.RuleViolation("games.opponent_unavailable", "Bu kişi şu anda davet edilemez.");
    private static readonly Error ChallengeLimit = Error.RuleViolation("games.challenge_limit", "En fazla 5 açık davetin olabilir.");
    private static readonly Error ChallengePending = Error.Conflict("games.challenge_pending", "Bu kişiye zaten bir davetin var.");
    private static readonly Error RematchUnavailable = Error.RuleViolation("games.rematch_unavailable", "Rövanş şu anda istenemez.");
    private static readonly Error TeamNoAbort = Error.RuleViolation("games.team_no_abort", "Takım maçındaki oyun iptal edilemez; terk edebilirsin.");
    private static readonly Error ArenaNoAbort = Error.RuleViolation("games.arena_no_abort", "Turnuva oyunu iptal edilemez; terk edebilirsin.");

    private const int MaxOpenChallenges = 5;

    private static Error RuleError(string code) =>
        Error.RuleViolation($"games.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene.");

    // -----------------------------------------------------------------------
    // Quick game
    // -----------------------------------------------------------------------

    public Task<Result<SeekResult>> SeekAsync(Guid actor, SeekRequest request, CancellationToken ct)
    {
        var tc = new TimeControl(request.BaseSeconds, request.IncrementSeconds);
        if (!tc.IsValid) return Task.FromResult<Result<SeekResult>>(TimeControlInvalid);

        return ActingTransaction.RunAsync<SeekResult>(db, actor, async (conn, tx) =>
        {
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            if (await ActiveGameAsync(conn, tx, actor, ct) is not null) return Busy;
            await LockPoolAsync(conn, tx, tc, ct);
            var rating = await RatingAsync(conn, tx, actor, tc.Category, ct);
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.chess_seeks (user_id, category, base_seconds, increment_seconds, rated, rating)
                values (@me, @category, @base, @inc, @rated, @rating)
                on conflict (user_id) do update set category = excluded.category, base_seconds = excluded.base_seconds,
                  increment_seconds = excluded.increment_seconds, rated = excluded.rated, rating = excluded.rating,
                  game_id = null, created_at = now(), touched_at = now()
                """, ct, ("me", actor), ("category", tc.Category), ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds),
                ("rated", request.Rated), ("rating", rating));
            return new SeekResult(await PairAsync(conn, tx, actor, ct));
        }, RuleError, ct);
    }

    /// <summary>Keeps the seek alive and tries again with the widened rating range.</summary>
    public Task<Result<SeekResult>> HeartbeatAsync(Guid actor, CancellationToken ct) =>
        ActingTransaction.RunAsync<SeekResult>(db, actor, async (conn, tx) =>
        {
            var seek = await ReadSeekAsync(conn, tx, actor, ct);
            if (seek is null) return new SeekResult(null);
            if (seek.Value.GameId is { } paired) return new SeekResult(paired);
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.chess_seeks set touched_at = now() where user_id = @me", ct, ("me", actor));
            await LockPoolAsync(conn, tx, seek.Value.Tc, ct);
            return new SeekResult(await PairAsync(conn, tx, actor, ct));
        }, RuleError, ct);

    public async Task<Result> CancelSeekAsync(Guid actor, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("delete from public.chess_seeks where user_id = @me and game_id is null");
        cmd.Parameters.AddWithValue("me", actor);
        await cmd.ExecuteNonQueryAsync(ct);
        return Result.Success();
    }

    private static Task LockPoolAsync(NpgsqlConnection conn, NpgsqlTransaction tx, TimeControl tc, CancellationToken ct) =>
        // One pairing at a time per pool, so two people waiting for each other are not paired twice.
        ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended('chess_pool:' || @base || ':' || @inc, 20))", ct,
            ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds));

    private static async Task<(TimeControl Tc, bool Rated, Guid? GameId)?> ReadSeekAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            "select base_seconds, increment_seconds, rated, game_id from public.chess_seeks where user_id = @me", conn, tx);
        cmd.Parameters.AddWithValue("me", actor);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return (new TimeControl(r.GetInt32(0), r.GetInt32(1)), r.GetBoolean(2), r.IsDBNull(3) ? null : r.GetGuid(3));
    }

    /// <summary>
    /// Pairs the actor's seek with the oldest compatible one: same time control and rating mode, rating within
    /// ±200, widening by 100 every 10 seconds of the longer wait up to ±600. Both seeks then point at the game.
    /// </summary>
    private static async Task<Guid?> PairAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, CancellationToken ct)
    {
        var partner = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            select s.user_id
            from public.chess_seeks me
            join public.chess_seeks s
              on s.base_seconds = me.base_seconds and s.increment_seconds = me.increment_seconds and s.rated = me.rated
             and s.user_id <> me.user_id and s.game_id is null and s.touched_at > now() - interval '60 seconds'
            where me.user_id = @me and me.game_id is null
              and abs(s.rating - me.rating) <= least(600, 200 + 100 * floor(extract(epoch from now() - least(s.created_at, me.created_at)) / 10))
              and not private.is_blocked_between(s.user_id, me.user_id)
              and private.is_account_active(s.user_id)
              and not exists (select 1 from public.chess_games g where g.status = 'active' and s.user_id in (g.white_id, g.black_id))
            order by s.created_at
            limit 1
            """, ct, ("me", actor));
        if (partner is not { } other) return null;

        var seek = await ReadSeekAsync(conn, tx, actor, ct);
        var (white, black) = Random.Shared.Next(2) == 0 ? (actor, other) : (other, actor);
        var game = await CreateGameAsync(conn, tx, white, black, seek!.Value.Tc, seek.Value.Rated, "seek", null, ct);
        await ActingTransaction.ExecuteAsync(conn, tx,
            "update public.chess_seeks set game_id = @game where user_id in (@me, @other)", ct, ("game", game), ("me", actor), ("other", other));
        return game;
    }

    // -----------------------------------------------------------------------
    // Challenges
    // -----------------------------------------------------------------------

    public Task<Result<ChallengeCreated>> ChallengeAsync(Guid actor, ChallengeRequest request, CancellationToken ct)
    {
        var tc = new TimeControl(request.BaseSeconds, request.IncrementSeconds);
        if (!tc.IsValid) return Task.FromResult<Result<ChallengeCreated>>(TimeControlInvalid);
        if (request.Color is not ("random" or ChessRules.White or ChessRules.Black)) return Task.FromResult<Result<ChallengeCreated>>(ColorInvalid);
        if (request.OpponentId == actor) return Task.FromResult<Result<ChallengeCreated>>(ChallengeSelf);

        return ActingTransaction.RunAsync<ChallengeCreated>(db, actor, async (conn, tx) =>
        {
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            var id = await CreateChallengeAsync(conn, tx, actor, request.OpponentId, tc, request.Rated, request.Color, null, ct);
            return id.IsSuccess ? new ChallengeCreated(id.Value) : id.Error;
        }, RuleError, ct);
    }

    private static async Task<Result<Guid>> CreateChallengeAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid opponent, TimeControl tc, bool rated, string color, Guid? rematchOf,
        CancellationToken ct)
    {
        await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@me::text, 21))", ct, ("me", actor));
        var available = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
            """
            select exists (select 1 from public.profiles p where p.id = @them)
               and private.is_account_active(@them)
               and not private.is_blocked_between(@me, @them)
               and not exists (select 1 from public.chess_players c where c.user_id = @them and c.suspended_until > now())
            """, ct, ("me", actor), ("them", opponent)))!;
        if (!available) return OpponentUnavailable;
        var open = (long)(await ActingTransaction.ScalarAsync(conn, tx,
            "select count(*) from public.chess_challenges where challenger_id = @me and status = 'pending' and expires_at > now()", ct,
            ("me", actor)))!;
        if (open >= MaxOpenChallenges) return ChallengeLimit;
        // A stale pending row past its time no longer blocks a new invitation.
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.chess_challenges set status = 'expired', responded_at = now()
            where challenger_id = @me and opponent_id = @them and status = 'pending' and expires_at <= now()
            """, ct, ("me", actor), ("them", opponent));
        var id = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            insert into public.chess_challenges (challenger_id, opponent_id, category, base_seconds, increment_seconds, rated, color, rematch_of)
            values (@me, @them, @category, @base, @inc, @rated, @color, @rematch)
            on conflict (challenger_id, opponent_id) where status = 'pending' do nothing
            returning id
            """, ct, ("me", actor), ("them", opponent), ("category", tc.Category), ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds),
            ("rated", rated), ("color", color), ("rematch", rematchOf));
        return id is { } created ? created : ChallengePending;
    }

    public Task<Result<GameStarted>> AcceptChallengeAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync<GameStarted>(db, actor, async (conn, tx) =>
        {
            await using var cmd = new NpgsqlCommand(
                """
                select challenger_id, opponent_id, base_seconds, increment_seconds, rated, color, status, expires_at <= now(), rematch_of
                from public.chess_challenges where id = @id for update
                """, conn, tx);
            cmd.Parameters.AddWithValue("id", id);
            Guid challenger, opponent;
            TimeControl tc;
            bool rated, expired;
            string color, status;
            Guid? rematchOf;
            await using (var r = await cmd.ExecuteReaderAsync(ct))
            {
                if (!await r.ReadAsync(ct)) return ChallengeNotFound;
                (challenger, opponent, tc, rated, color, status, expired) =
                    (r.GetGuid(0), r.GetGuid(1), new TimeControl(r.GetInt32(2), r.GetInt32(3)), r.GetBoolean(4), r.GetString(5), r.GetString(6), r.GetBoolean(7));
                rematchOf = r.IsDBNull(8) ? null : r.GetGuid(8);
            }
            if (opponent != actor) return challenger == actor ? ChallengeClosed : ChallengeNotFound;
            if (status != "pending" || expired) return ChallengeClosed;
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            if (await ActiveGameAsync(conn, tx, actor, ct) is not null) return Busy;
            if (await ActiveGameAsync(conn, tx, challenger, ct) is not null || await IsSuspendedAsync(conn, tx, challenger, ct)) return OpponentBusy;

            var challengerWhite = color switch
            {
                ChessRules.White => true,
                ChessRules.Black => false,
                _ => Random.Shared.Next(2) == 0,
            };
            var (white, black) = challengerWhite ? (challenger, opponent) : (opponent, challenger);
            var game = await CreateGameAsync(conn, tx, white, black, tc, rated, "challenge", rematchOf, ct);
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_challenges set status = 'accepted', game_id = @game, responded_at = now() where id = @id", ct,
                ("game", game), ("id", id));
            // Waiting for a quick game ends when a game starts.
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.chess_seeks where user_id in (@a, @b) and game_id is null", ct, ("a", challenger), ("b", opponent));
            return new GameStarted(game);
        }, RuleError, ct);

    public Task<Result> DeclineChallengeAsync(Guid actor, Guid id, CancellationToken ct) => CloseChallengeAsync(actor, id, "declined", ct);

    public Task<Result> CancelChallengeAsync(Guid actor, Guid id, CancellationToken ct) => CloseChallengeAsync(actor, id, "canceled", ct);

    private Task<Result> CloseChallengeAsync(Guid actor, Guid id, string status, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            // The opponent declines, the challenger withdraws.
            var found = await ActingTransaction.ScalarAsync(conn, tx,
                status == "declined"
                    ? "select status from public.chess_challenges where id = @id and opponent_id = @me for update"
                    : "select status from public.chess_challenges where id = @id and challenger_id = @me for update", ct,
                ("id", id), ("me", actor));
            if (found is not string current) return ChallengeNotFound;
            if (current != "pending") return ChallengeClosed;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_challenges set status = @status, responded_at = now() where id = @id", ct, ("status", status), ("id", id));
            return Result.Success();
        }, RuleError, ct);

    // -----------------------------------------------------------------------
    // The game
    // -----------------------------------------------------------------------

    private sealed record GameRow(
        Guid Id, Guid? White, Guid? Black, string Category, int BaseSeconds, int IncrementSeconds, bool Rated, string Status,
        string[] Moves, string Fen, long WhiteMs, long BlackMs, DateTimeOffset TurnStartedAt, string? DrawOffer,
        int? WhiteOfferPly, int? BlackOfferPly, DateTimeOffset Now, Guid? TeamMatchId, Guid? TournamentId)
    {
        /// <summary>A team board or an arena game: never aborted, a missing first move loses.</summary>
        public bool Competitive => TeamMatchId is not null || TournamentId is not null;

        public int Ply => Moves.Length;

        public string? ColorOf(Guid user) => user == White ? ChessRules.White : user == Black ? ChessRules.Black : null;

        public long MsOf(string color) => color == ChessRules.White ? WhiteMs : BlackMs;

        /// <summary>The side to move's time left now; the clock runs only from the third half-move.</summary>
        public long RemainingToMove => Ply < 2 ? MsOf(ChessRules.ToMove(Ply)) : MsOf(ChessRules.ToMove(Ply)) - (long)(Now - TurnStartedAt).TotalMilliseconds;

        public bool FirstMoveMissed => Ply < 2 && Now - TurnStartedAt > (TeamMatchId is null ? ChessRules.FirstMoveWindow : ChessRules.TeamFirstMoveWindow);
    }

    private static async Task<GameRow?> LockGameAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select id, white_id, black_id, category, base_seconds, increment_seconds, rated, status, moves, fen, white_ms, black_ms,
                   turn_started_at, draw_offer, white_offer_ply, black_offer_ply, now(), team_match_id, tournament_id
            from public.chess_games where id = @id for update
            """, conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return new GameRow(
            r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1), r.IsDBNull(2) ? null : r.GetGuid(2), r.GetString(3), r.GetInt32(4), r.GetInt32(5),
            r.GetBoolean(6), r.GetString(7), r.GetFieldValue<string[]>(8), r.GetString(9), r.GetInt64(10), r.GetInt64(11),
            r.GetFieldValue<DateTimeOffset>(12), r.IsDBNull(13) ? null : r.GetString(13), r.IsDBNull(14) ? null : r.GetInt32(14),
            r.IsDBNull(15) ? null : r.GetInt32(15), r.GetFieldValue<DateTimeOffset>(16), r.IsDBNull(17) ? null : r.GetGuid(17),
            r.IsDBNull(18) ? null : r.GetGuid(18));
    }

    /// <summary>The game as the app reads it from Realtime (snake_case row) plus the server's clock.</summary>
    private static async Task<JsonElement> ViewAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        var json = (string)(await ActingTransaction.ScalarAsync(conn, tx,
            "select jsonb_build_object('server_now', now(), 'game', to_jsonb(g))::text from public.chess_games g where g.id = @id", ct, ("id", id)))!;
        using var doc = JsonDocument.Parse(json);
        return doc.RootElement.Clone();
    }

    public async Task<Result<JsonElement>> GetAsync(Guid actor, Guid id, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var visible = (bool?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            select @me in (white_id, black_id)
                or ((white_id is null or private.is_account_visible(white_id)) and (black_id is null or private.is_account_visible(black_id)))
            from public.chess_games where id = @id
            """, ct, ("me", actor), ("id", id));
        if (visible is not true) return GameNotFound;
        return await ViewAsync(conn, tx, id, ct);
    }

    /// <summary>Locks the game, settles an expired clock first, then runs the player's action.</summary>
    private Task<Result<JsonElement>> ActAsync(
        Guid actor, Guid id, Func<NpgsqlConnection, NpgsqlTransaction, GameRow, string, Task<Result>> action, CancellationToken ct) =>
        ActingTransaction.RunAsync<JsonElement>(db, actor, async (conn, tx) =>
        {
            var game = await LockGameAsync(conn, tx, id, ct);
            if (game is null) return GameNotFound;
            if (game.ColorOf(actor) is not { } color) return NotPlayer;
            if (game.Status != "active") return GameOver;
            if (await SettleClockAsync(conn, tx, game, ct)) return await ViewAsync(conn, tx, id, ct);
            var done = await action(conn, tx, game, color);
            if (!done.IsSuccess) return done.Error;
            return await ViewAsync(conn, tx, id, ct);
        }, RuleError, ct);

    /// <summary>Ends the game when the side to move missed the first-move window or ran out of time. True when it ended.</summary>
    private static async Task<bool> SettleClockAsync(NpgsqlConnection conn, NpgsqlTransaction tx, GameRow game, CancellationToken ct)
    {
        if (game.FirstMoveMissed)
        {
            // A team board or an arena game is not aborted: the side that never came loses it.
            var missed = !game.Competitive ? Outcome.Aborted : Outcome.Win(ChessRules.Opposite(ChessRules.ToMove(game.Ply)), "no_show");
            await FinishAsync(conn, tx, game, missed, game.WhiteMs, game.BlackMs, ct);
            return true;
        }
        if (game.Ply < 2 || game.RemainingToMove > 0) return false;
        var loser = ChessRules.ToMove(game.Ply);
        var winner = ChessRules.Opposite(loser);
        var outcome = ChessRules.CanMate(game.Fen, winner) ? Outcome.Win(winner, "timeout") : Outcome.Draw("timeout_draw");
        await FinishAsync(conn, tx, game, outcome, loser == ChessRules.White ? 0 : game.WhiteMs, loser == ChessRules.Black ? 0 : game.BlackMs, ct);
        return true;
    }

    public Task<Result<JsonElement>> MoveAsync(Guid actor, Guid id, MoveRequest request, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, color) =>
        {
            if (request.Ply != game.Ply) return OutOfSync;
            if (ChessRules.ToMove(game.Ply) != color) return NotYourTurn;
            var played = ChessRules.Play(game.Moves, request.Uci?.Trim().ToLowerInvariant() ?? "");
            if (played is null) return Illegal;

            var increment = game.IncrementSeconds * 1000L;
            var whiteMs = game.WhiteMs;
            var blackMs = game.BlackMs;
            if (game.Ply >= 2)
            {
                if (color == ChessRules.White) whiteMs = game.RemainingToMove + increment;
                else blackMs = game.RemainingToMove + increment;
            }
            // Moving declines the opponent's offer; one's own offer stays for the opponent to answer.
            var drawOffer = game.DrawOffer == color ? color : null;
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.chess_games
                set moves = moves || @uci, san = san || @san, fen = @fen, white_ms = @wms, black_ms = @bms,
                    turn_started_at = now(), draw_offer = @offer
                where id = @id
                """, ct, ("uci", played.Uci), ("san", played.San), ("fen", played.Fen), ("wms", whiteMs), ("bms", blackMs),
                ("offer", drawOffer), ("id", game.Id));
            if (played.End is { } end)
            {
                await FinishAsync(conn, tx, game with { Moves = [.. game.Moves, played.Uci] }, end, whiteMs, blackMs, ct);
            }
            return Result.Success();
        }, ct);

    public Task<Result<JsonElement>> ResignAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, color) =>
        {
            var (wms, bms) = Clocks(game);
            // Before both sides moved, leaving is an abort: nobody loses rating for a game that never began. A team board is lost.
            var outcome = game.Ply < 2 && !game.Competitive ? Outcome.Aborted : Outcome.Win(ChessRules.Opposite(color), "resign");
            await FinishAsync(conn, tx, game, outcome, wms, bms, ct);
            return Result.Success();
        }, ct);

    public Task<Result<JsonElement>> AbortAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, _) =>
        {
            if (game.TeamMatchId is not null) return TeamNoAbort;
            if (game.TournamentId is not null) return ArenaNoAbort;
            if (game.Ply >= 2) return AbortTooLate;
            await FinishAsync(conn, tx, game, Outcome.Aborted, game.WhiteMs, game.BlackMs, ct);
            return Result.Success();
        }, ct);

    public Task<Result<JsonElement>> OfferDrawAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, color) =>
        {
            if (game.DrawOffer == ChessRules.Opposite(color))
            {
                var (wms, bms) = Clocks(game);
                await FinishAsync(conn, tx, game, Outcome.Draw("agreement"), wms, bms, ct);
                return Result.Success();
            }
            var last = color == ChessRules.White ? game.WhiteOfferPly : game.BlackOfferPly;
            // Not before both sides moved, and once per opponent move.
            if (game.Ply < 2 || game.DrawOffer == color || (last is { } l && game.Ply < l + 2)) return DrawTooSoon;
            await ActingTransaction.ExecuteAsync(conn, tx,
                color == ChessRules.White
                    ? "update public.chess_games set draw_offer = 'white', white_offer_ply = @ply where id = @id"
                    : "update public.chess_games set draw_offer = 'black', black_offer_ply = @ply where id = @id", ct,
                ("ply", game.Ply), ("id", game.Id));
            return Result.Success();
        }, ct);

    public Task<Result<JsonElement>> AcceptDrawAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, color) =>
        {
            if (game.DrawOffer != ChessRules.Opposite(color)) return NoDrawOffer;
            var (wms, bms) = Clocks(game);
            await FinishAsync(conn, tx, game, Outcome.Draw("agreement"), wms, bms, ct);
            return Result.Success();
        }, ct);

    public Task<Result<JsonElement>> DeclineDrawAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, async (conn, tx, game, color) =>
        {
            if (game.DrawOffer != ChessRules.Opposite(color)) return NoDrawOffer;
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.chess_games set draw_offer = null where id = @id", ct, ("id", game.Id));
            return Result.Success();
        }, ct);

    /// <summary>Asks the server to look at the clock now (the app's clock hit zero). Not an error when time is left.</summary>
    public Task<Result<JsonElement>> FlagAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActAsync(actor, id, (_, _, _, _) => Task.FromResult(Result.Success()), ct);

    /// <summary>The clocks as they stand now, with the running one charged.</summary>
    private static (long White, long Black) Clocks(GameRow game)
    {
        if (game.Ply < 2) return (game.WhiteMs, game.BlackMs);
        var remaining = Math.Max(0, game.RemainingToMove);
        return ChessRules.ToMove(game.Ply) == ChessRules.White ? (remaining, game.BlackMs) : (game.WhiteMs, remaining);
    }

    public async Task<Result<RematchResult>> RematchAsync(Guid actor, Guid id, CancellationToken ct)
    {
        var asked = await ActingTransaction.RunAsync<(Guid Challenge, bool Theirs)>(db, actor, async (conn, tx) =>
        {
            var game = await LockGameAsync(conn, tx, id, ct);
            if (game is null) return GameNotFound;
            if (game.ColorOf(actor) is not { } color) return NotPlayer;
            // An arena pairs its own games.
            if (game.Status == "active" || game.White is null || game.Black is null || game.TournamentId is not null) return RematchUnavailable;
            var opponent = color == ChessRules.White ? game.Black.Value : game.White.Value;

            // The opponent asked first: the actor's request accepts theirs.
            var theirs = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
                """
                select id from public.chess_challenges
                where challenger_id = @them and opponent_id = @me and rematch_of = @game and status = 'pending' and expires_at > now()
                """, ct, ("them", opponent), ("me", actor), ("game", id));
            if (theirs is { } waiting) return (waiting, true);

            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            var created = await CreateChallengeAsync(conn, tx, actor, opponent, new TimeControl(game.BaseSeconds, game.IncrementSeconds), game.Rated,
                ChessRules.Opposite(color), id, ct);
            return created.IsSuccess ? (created.Value, false) : created.Error;
        }, RuleError, ct);
        if (!asked.IsSuccess) return asked.Error;
        if (!asked.Value.Theirs) return new RematchResult(asked.Value.Challenge, null);
        var accepted = await AcceptChallengeAsync(actor, asked.Value.Challenge, ct);
        return accepted.IsSuccess ? new RematchResult(null, accepted.Value.GameId) : accepted.Error;
    }

    // -----------------------------------------------------------------------
    // Shared steps
    // -----------------------------------------------------------------------

    internal static async Task<Guid> CreateGameAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid white, Guid black, TimeControl tc, bool rated, string source, Guid? rematchOf,
        CancellationToken ct, Guid? teamMatchId = null, Guid? tournamentId = null)
    {
        var whiteRating = await RatingAsync(conn, tx, white, tc.Category, ct);
        var blackRating = await RatingAsync(conn, tx, black, tc.Category, ct);
        return (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
            """
            insert into public.chess_games (white_id, black_id, category, base_seconds, increment_seconds, rated, source,
                                            white_ms, black_ms, white_rating, black_rating, rematch_of, team_match_id, tournament_id)
            values (@white, @black, @category, @base, @inc, @rated, @source, @ms, @ms, @wr, @br, @rematch, @team, @tournament)
            returning id
            """, ct, ("white", white), ("black", black), ("category", tc.Category), ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds),
            ("rated", rated), ("source", source), ("ms", tc.BaseSeconds * 1000L), ("wr", whiteRating), ("br", blackRating), ("rematch", rematchOf),
            ("team", teamMatchId), ("tournament", tournamentId)))!;
    }

    private static async Task<int> RatingAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, string category, CancellationToken ct) =>
        (int?)await ActingTransaction.ScalarAsync(conn, tx,
            "select rating from public.chess_ratings where user_id = @u and category = @c", ct, ("u", user), ("c", category))
        ?? ChessRules.StartRating;

    private static async Task<bool> IsSuspendedAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, CancellationToken ct) =>
        (bool)(await ActingTransaction.ScalarAsync(conn, tx,
            "select exists (select 1 from public.chess_players where user_id = @u and suspended_until > now())", ct, ("u", user)))!;

    private static async Task<Guid?> ActiveGameAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, CancellationToken ct) =>
        (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            "select id from public.chess_games where status = 'active' and @u in (white_id, black_id) limit 1", ct, ("u", user));

    /// <summary>Writes the end of the game and, for a rated decisive or drawn game, both players' new ratings.</summary>
    private static async Task FinishAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, GameRow game, Outcome outcome, long whiteMs, long blackMs, CancellationToken ct)
    {
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.chess_games
            set status = case when @result::text is null then 'aborted' else 'finished' end, result = @result, termination = @termination,
                white_ms = @wms, black_ms = @bms, draw_offer = null, ended_at = now()
            where id = @id
            """, ct, ("result", outcome.Result), ("termination", outcome.Termination), ("wms", whiteMs), ("bms", blackMs), ("id", game.Id));
        await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.chess_seeks where game_id = @id", ct, ("id", game.Id));
        if (game.TeamMatchId is { } teamMatch) await TeamMatchService.RecordBoardAsync(conn, tx, teamMatch, game.Id, outcome.Result, ct);
        if (game.TournamentId is { } arena)
        {
            // The side to move is the one that never came.
            var absent = outcome.Termination == "no_show" ? ChessRules.ToMove(game.Ply) : null;
            await TournamentService.RecordGameAsync(conn, tx, arena, game.Id, game.White, game.Black, outcome.Result, absent, ct);
        }
        // A board nobody played is not a game: no rating for a no-show.
        if (!game.Rated || outcome.Result is not { } result || outcome.Termination == "no_show" || game.White is not { } white
            || game.Black is not { } black) return;

        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            insert into public.chess_ratings (user_id, category) values (@w, @c), (@b, @c) on conflict do nothing
            """, ct, ("w", white), ("b", black), ("c", game.Category));
        async Task<(int Rating, int Games)> Read(Guid user)
        {
            await using var cmd = new NpgsqlCommand(
                "select rating, games from public.chess_ratings where user_id = @u and category = @c for update", conn, tx);
            cmd.Parameters.AddWithValue("u", user);
            cmd.Parameters.AddWithValue("c", game.Category);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            return (r.GetInt32(0), r.GetInt32(1));
        }
        var w = await Read(white);
        var b = await Read(black);
        var score = result switch { ChessRules.White => 1.0, ChessRules.Black => 0.0, _ => 0.5 };
        var (dw, db) = ChessRules.EloDeltas(w.Rating, w.Games, b.Rating, b.Games, score);

        const string Update =
            """
            update public.chess_ratings
            set rating = rating + @d, peak = greatest(peak, rating + @d), games = games + 1,
                wins = wins + @win, draws = draws + @draw, losses = losses + @loss, updated_at = now()
            where user_id = @u and category = @c
            """;
        await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", dw), ("win", score == 1 ? 1 : 0), ("draw", score == 0.5 ? 1 : 0),
            ("loss", score == 0 ? 1 : 0), ("u", white), ("c", game.Category));
        await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", db), ("win", score == 0 ? 1 : 0), ("draw", score == 0.5 ? 1 : 0),
            ("loss", score == 1 ? 1 : 0), ("u", black), ("c", game.Category));
        await ActingTransaction.ExecuteAsync(conn, tx,
            "update public.chess_games set white_delta = @dw, black_delta = @db where id = @id", ct, ("dw", dw), ("db", db), ("id", game.Id));
    }

    // -----------------------------------------------------------------------
    // Monitor (GamesMonitor)
    // -----------------------------------------------------------------------

    /// <summary>Ends games whose clock ran out or whose first move never came, expires challenges, drops stale seeks.</summary>
    public async Task<int> SweepAsync(CancellationToken ct)
    {
        var due = new List<Guid>();
        await using (var cmd = db.CreateCommand(
            """
            select id from public.chess_games
            where status = 'active' and (
              (cardinality(moves) < 2 and turn_started_at
                  < now() - case when team_match_id is null then interval '30 seconds' else interval '5 minutes' end)
              or (cardinality(moves) >= 2 and turn_started_at
                  + (case when cardinality(moves) % 2 = 0 then white_ms else black_ms end) * interval '1 millisecond' <= now()))
            limit 200
            """))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct)) due.Add(r.GetGuid(0));
        }
        foreach (var id in due)
        {
            await using var conn = await db.OpenConnectionAsync(ct);
            await using var tx = await conn.BeginTransactionAsync(ct);
            if (await LockGameAsync(conn, tx, id, ct) is { Status: "active" } game && await SettleClockAsync(conn, tx, game, ct))
                await tx.CommitAsync(ct);
        }

        await using var cleanup = db.CreateCommand(
            """
            update public.chess_challenges set status = 'expired', responded_at = now() where status = 'pending' and expires_at <= now();
            delete from public.chess_seeks where (game_id is null and touched_at < now() - interval '60 seconds')
                                              or (game_id is not null and created_at < now() - interval '10 minutes');
            """);
        await cleanup.ExecuteNonQueryAsync(ct);
        return due.Count;
    }

    // -----------------------------------------------------------------------
    // Administration
    // -----------------------------------------------------------------------

    public async Task<ChessAdminOverview> ChessOverviewAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        int gamesToday, gamesTotal, active, seeks, challenges, rated;
        await using (var cmd = new NpgsqlCommand(
            """
            select
              (select count(*) from public.chess_games
               where created_at >= (date_trunc('day', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul'))::int,
              (select count(*) from public.chess_games where status = 'finished')::int,
              (select count(*) from public.chess_games where status = 'active')::int,
              (select count(*) from public.chess_seeks where game_id is null)::int,
              (select count(*) from public.chess_challenges where status = 'pending' and expires_at > now())::int,
              (select count(distinct user_id) from public.chess_ratings where games > 0)::int
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            await r.ReadAsync(ct);
            (gamesToday, gamesTotal, active, seeks, challenges, rated) =
                (r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5));
        }

        var games = new List<ChessAdminGame>();
        await using (var cmd = new NpgsqlCommand(
            """
            select g.id, g.white_id, w.username, g.black_id, b.username, g.category, g.base_seconds, g.increment_seconds, g.rated,
                   cardinality(g.moves), g.created_at
            from public.chess_games g
            left join public.profiles w on w.id = g.white_id
            left join public.profiles b on b.id = g.black_id
            where g.status = 'active'
            order by g.created_at desc
            limit 100
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct))
            {
                games.Add(new ChessAdminGame(r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1), r.IsDBNull(2) ? null : r.GetString(2),
                    r.IsDBNull(3) ? null : r.GetGuid(3), r.IsDBNull(4) ? null : r.GetString(4), r.GetString(5), r.GetInt32(6), r.GetInt32(7),
                    r.GetBoolean(8), r.GetInt32(9), r.GetFieldValue<DateTimeOffset>(10)));
            }
        }

        var suspended = new List<ChessAdminSuspension>();
        await using (var cmd = new NpgsqlCommand(
            """
            select c.user_id, p.username, case when c.suspended_until = 'infinity' then null else c.suspended_until end, c.suspension_reason
            from public.chess_players c join public.profiles p on p.id = c.user_id
            where c.suspended_until > now()
            order by c.updated_at desc
            limit 100
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct))
            {
                suspended.Add(new ChessAdminSuspension(r.GetGuid(0), r.GetString(1),
                    r.IsDBNull(2) ? null : r.GetFieldValue<DateTimeOffset>(2), r.IsDBNull(3) ? null : r.GetString(3)));
            }
        }

        return new ChessAdminOverview(gamesToday, gamesTotal, active, seeks, challenges, rated, games, suspended);
    }

    private static Error? CheckReason(ref string reason)
    {
        reason = reason?.Trim() ?? "";
        return reason.Length is < 3 or > 500 ? Error.Validation("games.reason_invalid", "Gerekçe 3–500 karakter olmalı.") : null;
    }

    public Task<Result> AbortChessGameAsync(Guid actorId, Guid gameId, string reason, CancellationToken ct)
    {
        if (CheckReason(ref reason) is { } invalid) return Task.FromResult<Result>(invalid);
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var game = await LockGameAsync(conn, tx, gameId, ct);
            if (game is null) return GameNotFound;
            if (game.Status != "active") return GameOver;
            await FinishAsync(conn, tx, game, Outcome.Aborted, game.WhiteMs, game.BlackMs, ct);
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.chess_game_aborted", "chess_game",
                gameId.ToString(), new { reason }), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> SuspendChessPlayerAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct)
    {
        if (CheckReason(ref reason) is { } invalid) return Task.FromResult<Result>(invalid);
        if (until is { } u && u <= DateTimeOffset.UtcNow)
            return Task.FromResult<Result>(Error.Validation("games.until_invalid", "Bitiş zamanı gelecekte olmalı."));
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var exists = (bool)(await ActingTransaction.ScalarAsync(conn, tx, "select exists (select 1 from public.profiles where id = @u)", ct,
                ("u", userId)))!;
            if (!exists) return Error.NotFound("games.player_not_found", "Kullanıcı bulunamadı.");
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.chess_players (user_id, suspended_until, suspension_reason)
                values (@u, coalesce(@until::timestamptz, 'infinity'::timestamptz), @reason)
                on conflict (user_id) do update set suspended_until = excluded.suspended_until, suspension_reason = excluded.suspension_reason;
                delete from public.chess_seeks where user_id = @u;
                update public.chess_challenges set status = 'canceled', responded_at = now()
                where status = 'pending' and @u in (challenger_id, opponent_id);
                """, ct, ("u", userId), ("until", until), ("reason", reason));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.chess_player_suspended", "user",
                userId.ToString(), new { reason, until }), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> RestoreChessPlayerAsync(Guid actorId, Guid userId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var changed = await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.chess_players set suspended_until = null, suspension_reason = null
                where user_id = @u and suspended_until is not null
                """, ct, ("u", userId));
            if (changed == 0) return Error.NotFound("games.player_not_suspended", "Bu kişi satrançtan uzaklaştırılmamış.");
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.chess_player_restored", "user",
                userId.ToString()), ct);
            return Result.Success();
        }, RuleError, ct);
}
