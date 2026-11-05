using Gway.Modules.Games.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Games;

public sealed record TeamMatchRequest(Guid HomeGroupId, Guid AwayGroupId, int Boards, int BaseSeconds, int IncrementSeconds, DateTimeOffset StartsAt);

public sealed record TeamMatchCreated(Guid Id);

/// <param name="Players">Board 1 first; a null leaves the board empty (forfeited at the start).</param>
public sealed record LineupRequest(Guid GroupId, IReadOnlyList<Guid?> Players);

/// <summary>
/// Team matches between groups (docs/ARCHITECTURE.md §3i, Takım maçı ve grup Elo'su). Captains (games.team_match) invite,
/// answer and line up; the monitor starts due matches; each finished board game writes its points and the last one
/// settles the match and both groups' Elo, in the same transaction as the game result.
/// </summary>
internal sealed class TeamMatchService(NpgsqlDataSource db) : ITeamMatchAdministration
{
    private static readonly Error TimeControlInvalid = Error.Validation("games.team_time_control", "Takım maçı yalnızca Blitz ya da Rapid oynanır.");
    private static readonly Error BoardsInvalid = Error.Validation("games.team_boards", "Tahta sayısı 2 ile 10 arasında olmalı.");
    private static readonly Error StartInvalid = Error.Validation("games.team_start", "Başlangıç en az 15 dakika, en çok 30 gün sonra olmalı.");
    private static readonly Error SameGroup = Error.Validation("games.team_same_group", "Bir grup kendisiyle maç yapamaz.");
    private static readonly Error NotCaptain = Error.RuleViolation("games.team_not_captain", "Bu grup adına takım maçı düzenleme yetkin yok.");
    private static readonly Error GroupUnavailable = Error.RuleViolation("games.team_group_unavailable", "Bu grup şu anda davet edilemez.");
    private static readonly Error AlreadyOpen = Error.Conflict("games.team_open", "Bu iki grup arasında zaten açık bir maç var.");
    private static readonly Error TooMany = Error.RuleViolation("games.team_limit", "Bir grubun en fazla 5 açık takım maçı olabilir.");
    private static readonly Error MatchNotFound = Error.NotFound("games.team_not_found", "Takım maçı bulunamadı.");
    private static readonly Error MatchClosed = Error.Conflict("games.team_closed", "Bu maç artık değiştirilemez.");
    private static readonly Error LineupInvalid = Error.Validation("games.team_lineup", "Diziliş geçersiz: her oyuncu grubun üyesi olmalı ve bir kez yer almalı.");
    private static readonly Error PlayerUnavailable = Error.RuleViolation("games.team_player", "Dizilişteki bir oyuncu şu anda oynayamaz.");

    private const int MaxOpenPerGroup = 5;

    /// <summary>The group Elo's K-factor: one match moves a group as much as a new player's game.</summary>
    internal const int GroupK = 32;

    private static Error RuleError(string code) =>
        Error.RuleViolation($"games.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene.");

    private static async Task<bool> IsCaptainAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid group, CancellationToken ct) =>
        await ActingTransaction.ScalarAsync(conn, tx, "select private.user_has_group_permission(@u, @g, 'games.team_match')", ct,
            ("u", actor), ("g", group)) is true;

    private sealed record MatchRow(Guid Id, Guid Home, Guid Away, int Boards, string Status, DateTimeOffset StartsAt, int BaseSeconds, int IncrementSeconds, bool Due);

    private static async Task<MatchRow?> LockAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select id, home_group_id, away_group_id, boards, status, starts_at, base_seconds, increment_seconds, starts_at <= now()
            from public.chess_team_matches where id = @id for update
            """, conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return new MatchRow(r.GetGuid(0), r.GetGuid(1), r.GetGuid(2), r.GetInt32(3), r.GetString(4), r.GetFieldValue<DateTimeOffset>(5),
            r.GetInt32(6), r.GetInt32(7), r.GetBoolean(8));
    }

    public Task<Result<TeamMatchCreated>> CreateAsync(Guid actor, TeamMatchRequest request, CancellationToken ct)
    {
        var tc = new TimeControl(request.BaseSeconds, request.IncrementSeconds);
        if (!tc.IsValid || tc.Category == "bullet") return Task.FromResult<Result<TeamMatchCreated>>(TimeControlInvalid);
        if (request.Boards is < 2 or > 10) return Task.FromResult<Result<TeamMatchCreated>>(BoardsInvalid);
        if (request.HomeGroupId == request.AwayGroupId) return Task.FromResult<Result<TeamMatchCreated>>(SameGroup);
        var now = DateTimeOffset.UtcNow;
        if (request.StartsAt < now.AddMinutes(15) || request.StartsAt > now.AddDays(30)) return Task.FromResult<Result<TeamMatchCreated>>(StartInvalid);

        return ActingTransaction.RunAsync<TeamMatchCreated>(db, actor, async (conn, tx) =>
        {
            if (!await IsCaptainAsync(conn, tx, actor, request.HomeGroupId, ct)) return NotCaptain;
            var available = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                "select exists (select 1 from public.groups where id = @g and status = 'active')", ct, ("g", request.AwayGroupId)))!;
            if (!available) return GroupUnavailable;
            await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@g::text, 22))", ct, ("g", request.HomeGroupId));
            var open = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select count(*) from public.chess_team_matches
                where @g in (home_group_id, away_group_id) and status in ('invited', 'accepted', 'live')
                """, ct, ("g", request.HomeGroupId)))!;
            if (open >= MaxOpenPerGroup) return TooMany;
            var id = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.chess_team_matches (home_group_id, away_group_id, boards, category, base_seconds, increment_seconds, starts_at, created_by)
                values (@home, @away, @boards, @category, @base, @inc, @starts, @me)
                on conflict ((least(home_group_id, away_group_id)), (greatest(home_group_id, away_group_id)))
                  where status in ('invited', 'accepted', 'live') do nothing
                returning id
                """, ct, ("home", request.HomeGroupId), ("away", request.AwayGroupId), ("boards", request.Boards), ("category", tc.Category),
                ("base", tc.BaseSeconds), ("inc", tc.IncrementSeconds), ("starts", request.StartsAt), ("me", actor));
            return id is { } created ? new TeamMatchCreated(created) : AlreadyOpen;
        }, RuleError, ct);
    }

    /// <summary>The invited group's captain accepts or declines.</summary>
    public Task<Result> RespondAsync(Guid actor, Guid id, bool accept, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var match = await LockAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (!await IsCaptainAsync(conn, tx, actor, match.Away, ct)) return NotCaptain;
            if (match.Status != "invited" || match.Due) return MatchClosed;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_team_matches set status = @s, responded_by = @me, responded_at = now() where id = @id", ct,
                ("s", accept ? "accepted" : "declined"), ("me", actor), ("id", id));
            return Result.Success();
        }, RuleError, ct);

    /// <summary>Either side's captain calls the match off before it starts.</summary>
    public Task<Result> CancelAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var match = await LockAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (!await IsCaptainAsync(conn, tx, actor, match.Home, ct) && !await IsCaptainAsync(conn, tx, actor, match.Away, ct)) return NotCaptain;
            if (match.Status is not ("invited" or "accepted") || match.Due) return MatchClosed;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_team_matches set status = 'canceled', responded_by = @me, responded_at = now() where id = @id", ct,
                ("me", actor), ("id", id));
            return Result.Success();
        }, RuleError, ct);

    /// <summary>Replaces one side's lineup before the start.</summary>
    public Task<Result> SetLineupAsync(Guid actor, Guid id, LineupRequest request, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var match = await LockAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (request.GroupId != match.Home && request.GroupId != match.Away) return LineupInvalid;
            if (!await IsCaptainAsync(conn, tx, actor, request.GroupId, ct)) return NotCaptain;
            if (match.Status is not ("invited" or "accepted") || match.Due) return MatchClosed;
            var players = request.Players ?? [];
            var chosen = players.Where(p => p is not null).Select(p => p!.Value).ToArray();
            if (players.Count > match.Boards || chosen.Distinct().Count() != chosen.Length) return LineupInvalid;

            var other = request.GroupId == match.Home ? match.Away : match.Home;
            var valid = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select count(*) from unnest(@players::uuid[]) as u (id)
                where exists (select 1 from public.group_members m where m.group_id = @g and m.user_id = u.id)
                  and not exists (select 1 from public.chess_team_lineups l where l.match_id = @match and l.group_id = @other and l.user_id = u.id)
                """, ct, ("players", chosen), ("g", request.GroupId), ("match", id), ("other", other)))!;
            if (valid != chosen.Length) return LineupInvalid;
            var playable = (long)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select count(*) from unnest(@players::uuid[]) as u (id)
                where private.is_account_active(u.id)
                  and not exists (select 1 from public.chess_players c where c.user_id = u.id and c.suspended_until > now())
                """, ct, ("players", chosen)))!;
            if (playable != chosen.Length) return PlayerUnavailable;

            await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.chess_team_lineups where match_id = @m and group_id = @g", ct,
                ("m", id), ("g", request.GroupId));
            for (var board = 1; board <= players.Count; board++)
            {
                if (players[board - 1] is not { } player) continue;
                await ActingTransaction.ExecuteAsync(conn, tx,
                    "insert into public.chess_team_lineups (match_id, group_id, board, user_id) values (@m, @g, @b, @u)", ct,
                    ("m", id), ("g", request.GroupId), ("b", board), ("u", player));
            }
            return Result.Success();
        }, RuleError, ct);

    // -----------------------------------------------------------------------
    // Monitor: starting matches
    // -----------------------------------------------------------------------

    /// <summary>Starts accepted matches whose time came and drops invitations nobody answered in time. Returns how many started.</summary>
    public async Task<int> StartDueAsync(CancellationToken ct)
    {
        await using (var expire = db.CreateCommand(
            "update public.chess_team_matches set status = 'canceled', responded_at = now() where status = 'invited' and starts_at <= now()"))
        {
            await expire.ExecuteNonQueryAsync(ct);
        }
        var due = new List<Guid>();
        await using (var cmd = db.CreateCommand("select id from public.chess_team_matches where status = 'accepted' and starts_at <= now() limit 50"))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct)) due.Add(r.GetGuid(0));
        }
        var started = 0;
        foreach (var id in due)
        {
            await using var conn = await db.OpenConnectionAsync(ct);
            await using var tx = await conn.BeginTransactionAsync(ct);
            if (await LockAsync(conn, tx, id, ct) is not { Status: "accepted", Due: true } match) continue;
            await StartAsync(conn, tx, match, ct);
            await tx.CommitAsync(ct);
            started++;
        }
        return started;
    }

    /// <summary>Opens a game on every board both sides filled; a board with one side forfeits to it, an empty board is 0–0.</summary>
    private static async Task StartAsync(NpgsqlConnection conn, NpgsqlTransaction tx, MatchRow match, CancellationToken ct)
    {
        var lineup = new Dictionary<(Guid Group, int Board), Guid>();
        await using (var cmd = new NpgsqlCommand("select group_id, board, user_id from public.chess_team_lineups where match_id = @m", conn, tx))
        {
            cmd.Parameters.AddWithValue("m", match.Id);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) lineup[(r.GetGuid(0), r.GetInt32(1))] = r.GetGuid(2);
        }
        await ActingTransaction.ExecuteAsync(conn, tx, "update public.chess_team_matches set status = 'live' where id = @id", ct, ("id", match.Id));
        var tc = new TimeControl(match.BaseSeconds, match.IncrementSeconds);
        for (var board = 1; board <= match.Boards; board++)
        {
            Guid? home = lineup.TryGetValue((match.Home, board), out var h) ? h : null;
            Guid? away = lineup.TryGetValue((match.Away, board), out var a) ? a : null;
            Guid? game = null;
            decimal? homePoints = null, awayPoints = null;
            if (home is { } hp && away is { } ap)
            {
                // Colors alternate: the home side has white on odd boards.
                var (white, black) = board % 2 == 1 ? (hp, ap) : (ap, hp);
                game = await ChessService.CreateGameAsync(conn, tx, white, black, tc, true, "team_match", null, ct, match.Id);
            }
            else
            {
                (homePoints, awayPoints) = (home is null ? 0m : 1m, away is null ? 0m : 1m);
            }
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.chess_team_boards (match_id, board, home_id, away_id, game_id, home_points, away_points)
                values (@m, @b, @home, @away, @game, @hp, @ap)
                """, ct, ("m", match.Id), ("b", board), ("home", home), ("away", away), ("game", game), ("hp", homePoints), ("ap", awayPoints));
        }
        await SettleIfDoneAsync(conn, tx, match.Id, ct);
    }

    // -----------------------------------------------------------------------
    // Results
    // -----------------------------------------------------------------------

    /// <summary>A board's game ended (inside its transaction): writes the board points, then settles the match when it was the last.</summary>
    internal static async Task RecordBoardAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid match, Guid game, string? result, CancellationToken ct)
    {
        // White is the home side on odd boards. An aborted game (only the platform team can abort a board) counts 0–0.
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.chess_team_boards b
            set home_points = case
                  when @result::text is null then 0
                  when @result = 'draw' then 0.5
                  when (@result = 'white') = (b.board % 2 = 1) then 1 else 0 end,
                away_points = case
                  when @result::text is null then 0
                  when @result = 'draw' then 0.5
                  when (@result = 'white') = (b.board % 2 = 1) then 0 else 1 end
            where b.match_id = @m and b.game_id = @g and b.home_points is null
            """, ct, ("result", result), ("m", match), ("g", game));
        await SettleIfDoneAsync(conn, tx, match, ct);
    }

    /// <summary>Once every board has points: the score, the result for each group and both groups' new Elo.</summary>
    private static async Task SettleIfDoneAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid match, CancellationToken ct)
    {
        Guid home, away;
        decimal homePoints, awayPoints;
        await using (var cmd = new NpgsqlCommand(
            """
            select m.home_group_id, m.away_group_id, coalesce(sum(b.home_points), 0), coalesce(sum(b.away_points), 0),
                   count(*) filter (where b.home_points is null), m.status
            from public.chess_team_matches m left join public.chess_team_boards b on b.match_id = m.id
            where m.id = @m
            group by m.id
            """, conn, tx))
        {
            cmd.Parameters.AddWithValue("m", match);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            if (!await r.ReadAsync(ct) || r.GetInt64(4) > 0 || r.GetString(5) != "live") return;
            (home, away, homePoints, awayPoints) = (r.GetGuid(0), r.GetGuid(1), r.GetDecimal(2), r.GetDecimal(3));
        }

        await ActingTransaction.ExecuteAsync(conn, tx,
            "insert into public.chess_group_ratings (group_id) values (@h), (@a) on conflict do nothing", ct, ("h", home), ("a", away));
        async Task<int> Rating(Guid g) => (int)(await ActingTransaction.ScalarAsync(conn, tx,
            "select rating from public.chess_group_ratings where group_id = @g for update", ct, ("g", g)))!;
        var homeRating = await Rating(home);
        var awayRating = await Rating(away);
        var total = homePoints + awayPoints;
        // Nobody played: the match is closed without moving either Elo.
        var counted = total > 0;
        var score = counted ? (double)(homePoints / total) : 0.5;
        var expected = 1 / (1 + Math.Pow(10, (awayRating - homeRating) / 400.0));
        var homeDelta = counted ? (int)Math.Round(GroupK * (score - expected), MidpointRounding.AwayFromZero) : 0;
        homeDelta = Math.Max(ChessRules.MinRating, homeRating + homeDelta) - homeRating;
        var awayDelta = counted ? Math.Max(ChessRules.MinRating, awayRating - homeDelta) - awayRating : 0;

        if (counted)
        {
            const string Update =
                """
                update public.chess_group_ratings
                set rating = rating + @d, peak = greatest(peak, rating + @d), matches = matches + 1,
                    wins = wins + @w, draws = draws + @dr, losses = losses + @l, updated_at = now()
                where group_id = @g
                """;
            var homeWon = homePoints > awayPoints;
            var drawn = homePoints == awayPoints;
            await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", homeDelta), ("w", homeWon ? 1 : 0), ("dr", drawn ? 1 : 0),
                ("l", !homeWon && !drawn ? 1 : 0), ("g", home));
            await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", awayDelta), ("w", !homeWon && !drawn ? 1 : 0), ("dr", drawn ? 1 : 0),
                ("l", homeWon ? 1 : 0), ("g", away));
        }
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.chess_team_matches
            set status = 'finished', home_points = @hp, away_points = @ap, home_rating = @hr, away_rating = @ar,
                home_delta = @hd, away_delta = @ad, ended_at = now()
            where id = @m
            """, ct, ("hp", homePoints), ("ap", awayPoints), ("hr", homeRating), ("ar", awayRating), ("hd", homeDelta), ("ad", awayDelta),
            ("m", match));
    }

    // -----------------------------------------------------------------------
    // Administration
    // -----------------------------------------------------------------------

    public async Task<IReadOnlyList<TeamMatchAdminRow>> OpenMatchesAsync(CancellationToken ct)
    {
        var rows = new List<TeamMatchAdminRow>();
        await using var cmd = db.CreateCommand(
            """
            select m.id, h.name, a.name, m.boards, m.base_seconds, m.increment_seconds, m.status, m.starts_at
            from public.chess_team_matches m
            join public.groups h on h.id = m.home_group_id
            join public.groups a on a.id = m.away_group_id
            where m.status in ('invited', 'accepted', 'live')
            order by m.starts_at
            limit 100
            """);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        while (await r.ReadAsync(ct))
        {
            rows.Add(new TeamMatchAdminRow(r.GetGuid(0), r.GetString(1), r.GetString(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5),
                r.GetString(6), r.GetFieldValue<DateTimeOffset>(7)));
        }
        return rows;
    }

    public Task<Result> CancelAsStaffAsync(Guid actorId, Guid id, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("games.reason_invalid", "Gerekçe 3–500 karakter olmalı."));
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var match = await LockAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (match.Status is not ("invited" or "accepted")) return MatchClosed;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.chess_team_matches set status = 'canceled', responded_at = now() where id = @id", ct, ("id", id));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.team_match_canceled", "chess_team_match",
                id.ToString(), new { reason }), ct);
            return Result.Success();
        }, RuleError, ct);
    }
}
