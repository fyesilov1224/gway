using Gway.Modules.Games.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Games;

/// <summary>
/// Arena tournaments (docs/ARCHITECTURE.md §3i, Arena turnuvaları). People join (early joiners are registered); while
/// the arena is live the monitor pairs whoever is waiting, nearest on points first and not the same opponent twice in a
/// row when anyone else is there. Each finished game adds points in its own transaction: 2 for a win, 1 for a draw,
/// doubled from the third win in a row. Games started before the end still count; then the arena closes with ranks.
/// </summary>
internal sealed class TournamentService(NpgsqlDataSource db) : ITournamentAdministration
{
    private static readonly Error NotFound = Error.NotFound("games.arena_not_found", "Turnuva bulunamadı.");
    private static readonly Error Closed = Error.Conflict("games.arena_closed", "Bu turnuva bitti ya da iptal edildi.");
    private static readonly Error AlreadyStarted = Error.RuleViolation("games.arena_started", "Turnuva başladı; kaydını silemezsin, ara verebilirsin.");
    private static readonly Error Suspended = Error.RuleViolation("games.suspended", "Satranç oynaman şu anda kapalı.");

    private int _ticks;

    private static Error RuleError(string code) =>
        Error.RuleViolation($"games.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene.");

    /// <summary>Joins (or comes back from a pause); before the start this registers for the start notice.</summary>
    public Task<Result> JoinAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var status = (string?)await ActingTransaction.ScalarAsync(conn, tx,
                "select case when ends_at <= now() then 'finished' else status end from public.chess_tournaments where id = @id for update", ct,
                ("id", id));
            if (status is null) return NotFound;
            if (status is not ("scheduled" or "live")) return Closed;
            var suspended = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                "select exists (select 1 from public.chess_players where user_id = @u and suspended_until > now())", ct, ("u", actor)))!;
            if (suspended) return Suspended;
            var live = status == "live";
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.chess_tournament_players (tournament_id, user_id, waiting, waiting_since)
                values (@id, @u, @live, case when @live then now() end)
                on conflict (tournament_id, user_id) do update
                  set waiting = excluded.waiting and public.chess_tournament_players.current_game_id is null,
                      waiting_since = excluded.waiting_since
                """, ct, ("id", id), ("u", actor), ("live", live));
            // A quick-game seek would pair the person twice.
            if (live) await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.chess_seeks where user_id = @u and game_id is null", ct, ("u", actor));
            return Result.Success();
        }, RuleError, ct);

    /// <summary>Leaves the pairing pool; points stay. The person can come back with Join.</summary>
    public async Task<Result> PauseAsync(Guid actor, Guid id, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            "update public.chess_tournament_players set waiting = false, waiting_since = null where tournament_id = @id and user_id = @u");
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("u", actor);
        return await cmd.ExecuteNonQueryAsync(ct) == 0 ? NotFound : Result.Success();
    }

    /// <summary>Drops an early registration; after the start a player pauses instead.</summary>
    public Task<Result> LeaveAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var status = (string?)await ActingTransaction.ScalarAsync(conn, tx, "select status from public.chess_tournaments where id = @id", ct, ("id", id));
            if (status is null) return NotFound;
            if (status != "scheduled") return AlreadyStarted;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.chess_tournament_players where tournament_id = @id and user_id = @u", ct, ("id", id), ("u", actor));
            return Result.Success();
        }, RuleError, ct);

    // -----------------------------------------------------------------------
    // Monitor
    // -----------------------------------------------------------------------

    /// <summary>One monitor step: keep the schedule (once a minute), start, pair and close arenas. Returns games started.</summary>
    public async Task<int> TickAsync(CancellationToken ct)
    {
        if (_ticks++ % 60 == 0)
        {
            await using var schedule = db.CreateCommand("select private.chess_schedule_tournaments()");
            await schedule.ExecuteScalarAsync(ct);
        }
        await using (var start = db.CreateCommand(
            """
            update public.chess_tournament_players tp set waiting = true, waiting_since = now()
            from public.chess_tournaments t
            where t.id = tp.tournament_id and t.status = 'scheduled' and t.starts_at <= now() and t.ends_at > now();
            update public.chess_tournaments set status = 'live' where status = 'scheduled' and starts_at <= now() and ends_at > now();
            update public.chess_tournaments set status = 'canceled' where status = 'scheduled' and ends_at <= now();
            """))
        {
            await start.ExecuteNonQueryAsync(ct);
        }

        var live = new List<Guid>();
        await using (var cmd = db.CreateCommand("select id from public.chess_tournaments where status = 'live'"))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct)) live.Add(r.GetGuid(0));
        }
        var started = 0;
        foreach (var id in live)
        {
            started += await PairAsync(id, ct);
            await FinishIfOverAsync(id, ct);
        }
        return started;
    }

    /// <summary>Pairs the waiting players of a live arena: by points, avoiding the last opponent when another is free.</summary>
    internal async Task<int> PairAsync(Guid id, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@id::text, 23))", ct, ("id", id));

        TimeControl tc;
        await using (var cmd = new NpgsqlCommand(
            "select base_seconds, increment_seconds from public.chess_tournaments where id = @id and status = 'live' and ends_at > now()", conn, tx))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct)) return 0;
            tc = new TimeControl(r.GetInt32(0), r.GetInt32(1));
        }

        var pool = new List<(Guid User, Guid? Last)>();
        await using (var cmd = new NpgsqlCommand(
            """
            select tp.user_id, tp.last_opponent
            from public.chess_tournament_players tp
            where tp.tournament_id = @id and tp.waiting and tp.current_game_id is null
              and private.is_account_active(tp.user_id)
              and not exists (select 1 from public.chess_players c where c.user_id = tp.user_id and c.suspended_until > now())
              and not exists (select 1 from public.chess_games g where g.status = 'active' and tp.user_id in (g.white_id, g.black_id))
            order by tp.points desc, tp.waiting_since
            for update of tp
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("id", id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) pool.Add((r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1)));
        }

        var started = 0;
        while (pool.Count >= 2)
        {
            var first = pool[0];
            var at = pool.FindIndex(1, p => p.User != first.Last && p.Last != first.User);
            if (at < 0) at = 1;
            var second = pool[at];
            pool.RemoveAt(at);
            pool.RemoveAt(0);
            var blocked = (bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.is_blocked_between(@a, @b)", ct,
                ("a", first.User), ("b", second.User)))!;
            if (blocked) continue;

            var (white, black) = Random.Shared.Next(2) == 0 ? (first.User, second.User) : (second.User, first.User);
            var game = await ChessService.CreateGameAsync(conn, tx, white, black, tc, true, "arena", null, ct, tournamentId: id);
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.chess_tournament_players
                set waiting = false, waiting_since = null, current_game_id = @g,
                    last_opponent = case when user_id = @a then @b else @a end
                where tournament_id = @t and user_id in (@a, @b)
                """, ct, ("g", game), ("a", white), ("b", black), ("t", id));
            started++;
        }
        await tx.CommitAsync(ct);
        return started;
    }

    /// <summary>After the end, once no arena game is still running: final ranks and the medals.</summary>
    private async Task FinishIfOverAsync(Guid id, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            with due as (
              select t.id from public.chess_tournaments t
              where t.id = @id and t.status = 'live' and t.ends_at <= now()
                and not exists (select 1 from public.chess_games g where g.tournament_id = t.id and g.status = 'active')
              for update
            ), ranked as (
              select s.user_id, s.rank from due, public.chess_tournament_standings(due.id) s where s.games > 0
            ), ranks as (
              update public.chess_tournament_players tp set final_rank = ranked.rank, waiting = false
              from ranked where tp.tournament_id = @id and tp.user_id = ranked.user_id
              returning tp.user_id
            )
            update public.chess_tournaments set status = 'finished', finished_at = now()
            where id in (select id from due);
            """);
        cmd.Parameters.AddWithValue("id", id);
        await cmd.ExecuteNonQueryAsync(ct);
    }

    // -----------------------------------------------------------------------
    // Scoring (inside the game's transaction)
    // -----------------------------------------------------------------------

    /// <summary>The points one arena game is worth for a player: 2 / 1 / 0, doubled when they came in on two wins.</summary>
    internal static int Points(double score, int streakBefore) =>
        (score switch { 1 => 2, 0.5 => 1, _ => 0 }) * (streakBefore >= 2 ? 2 : 1);

    /// <summary>
    /// A game of the arena ended: both players' scores move, and they go back to the pool while the arena runs. A player
    /// who never made a first move (no_show) is paused; an aborted game (staff) scores nothing.
    /// </summary>
    internal static async Task RecordGameAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid tournament, Guid game, Guid? white, Guid? black, string? result, string? absent,
        CancellationToken ct)
    {
        var (whiteRating, blackRating) = (0, 0);
        await using (var cmd = new NpgsqlCommand("select white_rating, black_rating from public.chess_games where id = @g", conn, tx))
        {
            cmd.Parameters.AddWithValue("g", game);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (await r.ReadAsync(ct)) (whiteRating, blackRating) = (r.GetInt32(0), r.GetInt32(1));
        }
        var open = (bool?)await ActingTransaction.ScalarAsync(conn, tx,
            "select status = 'live' and ends_at > now() from public.chess_tournaments where id = @t", ct, ("t", tournament)) ?? false;

        async Task Score(Guid player, string color, int opponentRating)
        {
            double? score = result switch
            {
                null => null,
                "draw" => 0.5,
                _ => result == color ? 1 : 0,
            };
            var streak = (int?)await ActingTransaction.ScalarAsync(conn, tx,
                "select streak from public.chess_tournament_players where tournament_id = @t and user_id = @u for update", ct,
                ("t", tournament), ("u", player));
            if (streak is not { } before) return;
            var back = open && absent != color;
            if (score is not { } s)
            {
                await ActingTransaction.ExecuteAsync(conn, tx,
                    """
                    update public.chess_tournament_players set current_game_id = null, waiting = @back, waiting_since = case when @back then now() end
                    where tournament_id = @t and user_id = @u
                    """, ct, ("back", back), ("t", tournament), ("u", player));
                return;
            }
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.chess_tournament_players
                set points = points + @p, games = games + 1, wins = wins + @w, draws = draws + @d, losses = losses + @l,
                    streak = case when @w = 1 then streak + 1 else 0 end, opponent_rating_sum = opponent_rating_sum + @opp,
                    current_game_id = null, waiting = @back, waiting_since = case when @back then now() end
                where tournament_id = @t and user_id = @u
                """, ct, ("p", Points(s, before)), ("w", s == 1 ? 1 : 0), ("d", s == 0.5 ? 1 : 0), ("l", s == 0 ? 1 : 0),
                ("opp", (long)opponentRating), ("back", back), ("t", tournament), ("u", player));
        }

        if (white is { } w) await Score(w, ChessRules.White, blackRating);
        if (black is { } b) await Score(b, ChessRules.Black, whiteRating);
    }

    // -----------------------------------------------------------------------
    // Administration
    // -----------------------------------------------------------------------

    public async Task<IReadOnlyList<TournamentAdminRow>> ListAsync(CancellationToken ct)
    {
        var rows = new List<TournamentAdminRow>();
        await using var cmd = db.CreateCommand(
            """
            select t.id, t.kind, t.title, t.base_seconds, t.increment_seconds, t.starts_at, t.ends_at, t.status,
                   (select count(*) from public.chess_tournament_players tp where tp.tournament_id = t.id)::int
            from public.chess_tournaments t
            where t.status in ('scheduled', 'live') or t.finished_at > now() - interval '30 days'
            order by t.starts_at
            limit 100
            """);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        while (await r.ReadAsync(ct))
        {
            rows.Add(new TournamentAdminRow(r.GetGuid(0), r.GetString(1), r.IsDBNull(2) ? null : r.GetString(2), r.GetInt32(3), r.GetInt32(4),
                r.GetFieldValue<DateTimeOffset>(5), r.GetFieldValue<DateTimeOffset>(6), r.GetString(7), r.GetInt32(8)));
        }
        return rows;
    }

    public Task<Result<Guid>> CreateAsync(Guid actorId, TournamentDraft draft, CancellationToken ct)
    {
        var tc = new TimeControl(draft.BaseSeconds, draft.IncrementSeconds);
        var title = draft.Title?.Trim() ?? "";
        if (title.Length is < 3 or > 80) return Task.FromResult<Result<Guid>>(Error.Validation("games.arena_title", "Başlık 3–80 karakter olmalı."));
        if (!tc.IsValid) return Task.FromResult<Result<Guid>>(Error.Validation("games.time_control_invalid", "Bu süre seçeneği yok."));
        if (draft.Minutes is < 20 or > 360) return Task.FromResult<Result<Guid>>(Error.Validation("games.arena_minutes", "Süre 20–360 dakika olmalı."));
        if (draft.StartsAt < DateTimeOffset.UtcNow.AddMinutes(5))
            return Task.FromResult<Result<Guid>>(Error.Validation("games.arena_start", "Başlangıç en az 5 dakika sonra olmalı."));

        return ActingTransaction.RunAsync<Guid>(db, actorId, async (conn, tx) =>
        {
            var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.chess_tournaments (kind, title, category, base_seconds, increment_seconds, starts_at, ends_at, created_by)
                values ('custom', @title, @category, @base, @inc, @starts, @starts + make_interval(mins => @minutes), @me)
                returning id
                """, ct, ("title", title), ("category", tc.Category), ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds),
                ("starts", draft.StartsAt), ("minutes", draft.Minutes), ("me", actorId)))!;
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.arena_created", "chess_tournament", id.ToString(),
                new { title, draft.BaseSeconds, draft.IncrementSeconds, draft.StartsAt, draft.Minutes }), ct);
            return id;
        }, RuleError, ct);
    }

    public Task<Result> CancelAsync(Guid actorId, Guid id, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("games.reason_invalid", "Gerekçe 3–500 karakter olmalı."));
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var changed = await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_tournaments set status = 'canceled' where id = @id and status = 'scheduled'", ct, ("id", id));
            if (changed == 0) return Error.Conflict("games.arena_not_scheduled", "Yalnızca başlamamış turnuva iptal edilebilir.");
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.arena_canceled", "chess_tournament", id.ToString(),
                new { reason }), ct);
            return Result.Success();
        }, RuleError, ct);
    }
}
