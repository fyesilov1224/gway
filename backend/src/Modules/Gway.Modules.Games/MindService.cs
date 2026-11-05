using System.Text.Json;
using System.Text.Json.Nodes;
using Gway.Modules.Games.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Npgsql;

namespace Gway.Modules.Games;

public sealed record MindSeekRequest(int Length);

/// <summary>Null <see cref="MatchId"/>: still waiting.</summary>
public sealed record MindSeekResult(Guid? MatchId);

public sealed record MindChallengeRequest(Guid OpponentId, int Length, bool Rated = true);

public sealed record MindMatchStarted(Guid MatchId);

/// <param name="Answer">By kind: <c>{"choice": 2}</c>, <c>{"picks": [4, 0, 7]}</c>, <c>{"cell": 5, "reactionMs": 412}</c> (cell −1: no tap).</param>
/// <param name="ElapsedMs">The app's own measure from showing the question to the answer.</param>
public sealed record MindAnswerRequest(int Index, JsonElement Answer, int? ElapsedMs);

/// <summary>The match as the app reads it from Realtime (snake_case row) and the server's clock.</summary>
public sealed record MindView(DateTimeOffset ServerNow, JsonElement Match);

/// <summary>A question as served: the solution never comes with it.</summary>
public sealed record MindQuestionView(int Index, string Kind, int Level, JsonElement Payload, int LimitMs, DateTimeOffset ServedAt);

/// <summary>Null <see cref="Question"/>: not started yet, all answered, or the match is over.</summary>
public sealed record MindNext(DateTimeOffset ServerNow, JsonElement Match, MindQuestionView? Question);

public sealed record MindAnswered(int Points, bool Correct, JsonElement Solution, DateTimeOffset ServerNow, JsonElement Match);

public sealed record MindRematch(Guid? ChallengeId, Guid? MatchId);

/// <summary>
/// Zihin Düellosu (docs/ARCHITECTURE.md §3j): two people answer the same questions at the same time. Every write
/// happens here with the match row locked; the questions and their solutions never leave the server before an answer.
/// </summary>
internal sealed class MindService(NpgsqlDataSource db) : IMindAdministration
{
    private static readonly Error LengthInvalid = Error.Validation("games.mind_length_invalid", "Soru sayısı 5, 10, 20 ya da 50 olmalı.");
    private static readonly Error Suspended = Error.RuleViolation("games.suspended", "Oyun oynaman şu anda kapalı.");
    private static readonly Error Busy = Error.Conflict("games.mind_busy", "Önce süren düellonu bitir.");
    private static readonly Error OpponentBusy = Error.Conflict("games.opponent_busy", "Rakibin şu anda başka bir oyunda.");
    private static readonly Error MatchNotFound = Error.NotFound("games.mind_not_found", "Düello bulunamadı.");
    private static readonly Error NotPlayer = Error.Forbidden("games.not_player", "Bu düelloda oyuncu değilsin.");
    private static readonly Error MatchOver = Error.Conflict("games.over", "Düello bitti.");
    private static readonly Error OutOfSync = Error.Conflict("games.out_of_sync", "Düello güncellendi, soru yenileniyor.");
    private static readonly Error ChallengeNotFound = Error.NotFound("games.challenge_not_found", "Davet bulunamadı.");
    private static readonly Error ChallengeClosed = Error.Conflict("games.challenge_closed", "Bu davet artık geçerli değil.");
    private static readonly Error ChallengeSelf = Error.Validation("games.challenge_self", "Kendini davet edemezsin.");
    private static readonly Error OpponentUnavailable = Error.RuleViolation("games.opponent_unavailable", "Bu kişi şu anda davet edilemez.");
    private static readonly Error ChallengeLimit = Error.RuleViolation("games.challenge_limit", "En fazla 5 açık davetin olabilir.");
    private static readonly Error ChallengePending = Error.Conflict("games.challenge_pending", "Bu kişiye zaten bir davetin var.");
    private static readonly Error RematchUnavailable = Error.RuleViolation("games.rematch_unavailable", "Rövanş şu anda istenemez.");

    private const int MaxOpenChallenges = 5;

    /// <summary>The countdown before the first question.</summary>
    public static readonly TimeSpan StartDelay = TimeSpan.FromSeconds(5);

    /// <summary>Each player must take their first question within this after the start, or the match is aborted.</summary>
    public static readonly TimeSpan JoinWindow = TimeSpan.FromSeconds(30);

    private static Error RuleError(string code) =>
        Error.RuleViolation($"games.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene.");

    private static bool ValidLength(int length) => MindQuestions.Lengths.Contains(length);

    // -----------------------------------------------------------------------
    // Quick match
    // -----------------------------------------------------------------------

    public Task<Result<MindSeekResult>> SeekAsync(Guid actor, MindSeekRequest request, CancellationToken ct)
    {
        if (!ValidLength(request.Length)) return Task.FromResult<Result<MindSeekResult>>(LengthInvalid);
        return ActingTransaction.RunAsync<MindSeekResult>(db, actor, async (conn, tx) =>
        {
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            if (await ActiveMatchAsync(conn, tx, actor, ct) is not null) return Busy;
            await LockPoolAsync(conn, tx, request.Length, ct);
            var rating = await RatingAsync(conn, tx, actor, request.Length, ct);
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.mind_seeks (user_id, length, rating) values (@me, @length, @rating)
                on conflict (user_id) do update set length = excluded.length, rating = excluded.rating, match_id = null,
                  created_at = now(), touched_at = now()
                """, ct, ("me", actor), ("length", request.Length), ("rating", rating));
            return new MindSeekResult(await PairAsync(conn, tx, actor, request.Length, ct));
        }, RuleError, ct);
    }

    public Task<Result<MindSeekResult>> HeartbeatAsync(Guid actor, CancellationToken ct) =>
        ActingTransaction.RunAsync<MindSeekResult>(db, actor, async (conn, tx) =>
        {
            await using var cmd = new NpgsqlCommand("select length, match_id from public.mind_seeks where user_id = @me", conn, tx);
            cmd.Parameters.AddWithValue("me", actor);
            int length;
            Guid? paired;
            await using (var r = await cmd.ExecuteReaderAsync(ct))
            {
                if (!await r.ReadAsync(ct)) return new MindSeekResult(null);
                (length, paired) = (r.GetInt32(0), r.IsDBNull(1) ? null : r.GetGuid(1));
            }
            if (paired is not null) return new MindSeekResult(paired);
            await ActingTransaction.ExecuteAsync(conn, tx, "update public.mind_seeks set touched_at = now() where user_id = @me", ct, ("me", actor));
            await LockPoolAsync(conn, tx, length, ct);
            return new MindSeekResult(await PairAsync(conn, tx, actor, length, ct));
        }, RuleError, ct);

    public async Task<Result> CancelSeekAsync(Guid actor, CancellationToken ct)
    {
        await using var cmd = db.CreateCommand("delete from public.mind_seeks where user_id = @me and match_id is null");
        cmd.Parameters.AddWithValue("me", actor);
        await cmd.ExecuteNonQueryAsync(ct);
        return Result.Success();
    }

    private static Task LockPoolAsync(NpgsqlConnection conn, NpgsqlTransaction tx, int length, CancellationToken ct) =>
        ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended('mind_pool:' || @length, 30))", ct, ("length", length));

    /// <summary>The oldest compatible seek: same length, rating within ±200 widening by 100 every 10 s up to ±600.</summary>
    private static async Task<Guid?> PairAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, int length, CancellationToken ct)
    {
        var partner = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            select s.user_id
            from public.mind_seeks me
            join public.mind_seeks s
              on s.length = me.length and s.user_id <> me.user_id and s.match_id is null and s.touched_at > now() - interval '60 seconds'
            where me.user_id = @me and me.match_id is null
              and abs(s.rating - me.rating) <= least(600, 200 + 100 * floor(extract(epoch from now() - least(s.created_at, me.created_at)) / 10))
              and not private.is_blocked_between(s.user_id, me.user_id)
              and private.is_account_active(s.user_id)
              and not exists (select 1 from public.mind_matches m where m.status = 'active' and s.user_id in (m.a_id, m.b_id))
            order by s.created_at
            limit 1
            """, ct, ("me", actor));
        if (partner is not { } other) return null;
        var match = await CreateMatchAsync(conn, tx, actor, other, length, true, "seek", null, ct);
        await ActingTransaction.ExecuteAsync(conn, tx,
            "update public.mind_seeks set match_id = @match where user_id in (@me, @other)", ct, ("match", match), ("me", actor), ("other", other));
        return match;
    }

    // -----------------------------------------------------------------------
    // Challenges
    // -----------------------------------------------------------------------

    public Task<Result<ChallengeCreated>> ChallengeAsync(Guid actor, MindChallengeRequest request, CancellationToken ct)
    {
        if (!ValidLength(request.Length)) return Task.FromResult<Result<ChallengeCreated>>(LengthInvalid);
        if (request.OpponentId == actor) return Task.FromResult<Result<ChallengeCreated>>(ChallengeSelf);
        return ActingTransaction.RunAsync<ChallengeCreated>(db, actor, async (conn, tx) =>
        {
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            var id = await CreateChallengeAsync(conn, tx, actor, request.OpponentId, request.Length, request.Rated, null, ct);
            return id.IsSuccess ? new ChallengeCreated(id.Value) : id.Error;
        }, RuleError, ct);
    }

    private static async Task<Result<Guid>> CreateChallengeAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid actor, Guid opponent, int length, bool rated, Guid? rematchOf, CancellationToken ct)
    {
        await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@me::text, 31))", ct, ("me", actor));
        var available = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
            """
            select exists (select 1 from public.profiles p where p.id = @them)
               and private.is_account_active(@them)
               and not private.is_blocked_between(@me, @them)
               and not exists (select 1 from public.chess_players c where c.user_id = @them and c.suspended_until > now())
            """, ct, ("me", actor), ("them", opponent)))!;
        if (!available) return OpponentUnavailable;
        var open = (long)(await ActingTransaction.ScalarAsync(conn, tx,
            "select count(*) from public.mind_challenges where challenger_id = @me and status = 'pending' and expires_at > now()", ct, ("me", actor)))!;
        if (open >= MaxOpenChallenges) return ChallengeLimit;
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.mind_challenges set status = 'expired', responded_at = now()
            where challenger_id = @me and opponent_id = @them and status = 'pending' and expires_at <= now()
            """, ct, ("me", actor), ("them", opponent));
        var id = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            insert into public.mind_challenges (challenger_id, opponent_id, length, rated, rematch_of)
            values (@me, @them, @length, @rated, @rematch)
            on conflict (challenger_id, opponent_id) where status = 'pending' do nothing
            returning id
            """, ct, ("me", actor), ("them", opponent), ("length", length), ("rated", rated), ("rematch", rematchOf));
        return id is { } created ? created : ChallengePending;
    }

    public Task<Result<MindMatchStarted>> AcceptChallengeAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync<MindMatchStarted>(db, actor, async (conn, tx) =>
        {
            await using var cmd = new NpgsqlCommand(
                "select challenger_id, opponent_id, length, rated, status, expires_at <= now(), rematch_of from public.mind_challenges where id = @id for update",
                conn, tx);
            cmd.Parameters.AddWithValue("id", id);
            Guid challenger, opponent;
            int length;
            bool rated, expired;
            string status;
            Guid? rematchOf;
            await using (var r = await cmd.ExecuteReaderAsync(ct))
            {
                if (!await r.ReadAsync(ct)) return ChallengeNotFound;
                (challenger, opponent, length, rated, status, expired) =
                    (r.GetGuid(0), r.GetGuid(1), r.GetInt32(2), r.GetBoolean(3), r.GetString(4), r.GetBoolean(5));
                rematchOf = r.IsDBNull(6) ? null : r.GetGuid(6);
            }
            if (opponent != actor) return challenger == actor ? ChallengeClosed : ChallengeNotFound;
            if (status != "pending" || expired) return ChallengeClosed;
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            if (await ActiveMatchAsync(conn, tx, actor, ct) is not null) return Busy;
            if (await ActiveMatchAsync(conn, tx, challenger, ct) is not null || await IsSuspendedAsync(conn, tx, challenger, ct)) return OpponentBusy;

            var match = await CreateMatchAsync(conn, tx, challenger, opponent, length, rated, "challenge", rematchOf, ct);
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.mind_challenges set status = 'accepted', match_id = @match, responded_at = now() where id = @id", ct,
                ("match", match), ("id", id));
            await ActingTransaction.ExecuteAsync(conn, tx,
                "delete from public.mind_seeks where user_id in (@a, @b) and match_id is null", ct, ("a", challenger), ("b", opponent));
            return new MindMatchStarted(match);
        }, RuleError, ct);

    public Task<Result> DeclineChallengeAsync(Guid actor, Guid id, CancellationToken ct) => CloseChallengeAsync(actor, id, "declined", ct);

    public Task<Result> CancelChallengeAsync(Guid actor, Guid id, CancellationToken ct) => CloseChallengeAsync(actor, id, "canceled", ct);

    private Task<Result> CloseChallengeAsync(Guid actor, Guid id, string status, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var found = await ActingTransaction.ScalarAsync(conn, tx,
                status == "declined"
                    ? "select status from public.mind_challenges where id = @id and opponent_id = @me for update"
                    : "select status from public.mind_challenges where id = @id and challenger_id = @me for update", ct,
                ("id", id), ("me", actor));
            if (found is not string current) return ChallengeNotFound;
            if (current != "pending") return ChallengeClosed;
            await ActingTransaction.ExecuteAsync(conn, tx,
                "update public.mind_challenges set status = @status, responded_at = now() where id = @id", ct, ("status", status), ("id", id));
            return Result.Success();
        }, RuleError, ct);

    // -----------------------------------------------------------------------
    // The match
    // -----------------------------------------------------------------------

    private sealed record MatchRow(
        Guid Id, Guid? A, Guid? B, int Length, bool Rated, string Status, int AAnswered, int BAnswered, int AScore, int BScore,
        bool AJoined, bool BJoined, DateTimeOffset StartsAt, DateTimeOffset DeadlineAt, DateTimeOffset Now)
    {
        public string? SideOf(Guid user) => user == A ? "a" : user == B ? "b" : null;

        public int AnsweredBy(string side) => side == "a" ? AAnswered : BAnswered;
    }

    private static async Task<MatchRow?> LockMatchAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        await using var cmd = new NpgsqlCommand(
            """
            select id, a_id, b_id, length, rated, status, cardinality(a_points), cardinality(b_points), a_score, b_score, a_joined, b_joined,
                   starts_at, deadline_at, now()
            from public.mind_matches where id = @id for update
            """, conn, tx);
        cmd.Parameters.AddWithValue("id", id);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        if (!await r.ReadAsync(ct)) return null;
        return new MatchRow(r.GetGuid(0), r.IsDBNull(1) ? null : r.GetGuid(1), r.IsDBNull(2) ? null : r.GetGuid(2), r.GetInt32(3), r.GetBoolean(4),
            r.GetString(5), r.GetInt32(6), r.GetInt32(7), r.GetInt32(8), r.GetInt32(9), r.GetBoolean(10), r.GetBoolean(11),
            r.GetFieldValue<DateTimeOffset>(12), r.GetFieldValue<DateTimeOffset>(13), r.GetFieldValue<DateTimeOffset>(14));
    }

    private static async Task<(DateTimeOffset Now, JsonElement Match)> ReadViewAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        var json = (string)(await ActingTransaction.ScalarAsync(conn, tx,
            "select jsonb_build_object('now', now(), 'match', to_jsonb(m))::text from public.mind_matches m where m.id = @id", ct, ("id", id)))!;
        using var doc = JsonDocument.Parse(json);
        return (doc.RootElement.GetProperty("now").GetDateTimeOffset(), doc.RootElement.GetProperty("match").Clone());
    }

    private static async Task<MindView> ViewAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        var (now, match) = await ReadViewAsync(conn, tx, id, ct);
        return new MindView(now, match);
    }

    public async Task<Result<MindView>> GetAsync(Guid actor, Guid id, CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var visible = (bool?)await ActingTransaction.ScalarAsync(conn, tx,
            """
            select @me in (a_id, b_id)
                or ((a_id is null or private.is_account_visible(a_id)) and (b_id is null or private.is_account_visible(b_id)))
            from public.mind_matches where id = @id
            """, ct, ("me", actor), ("id", id));
        if (visible is not true) return MatchNotFound;
        return await ViewAsync(conn, tx, id, ct);
    }

    /// <summary>Records a timed-out question as 0 points for the side.</summary>
    private static Task AppendPointsAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid match, string side, int points, CancellationToken ct) =>
        ActingTransaction.ExecuteAsync(conn, tx,
            side == "a"
                ? "update public.mind_matches set a_points = a_points || @p, a_score = a_score + @p where id = @id"
                : "update public.mind_matches set b_points = b_points || @p, b_score = b_score + @p where id = @id", ct, ("p", points), ("id", match));

    /// <summary>The player's current question: served now, or again with its first serving time. Timed-out ones count 0 and are skipped.</summary>
    public Task<Result<MindNext>> NextAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync<MindNext>(db, actor, async (conn, tx) =>
        {
            var match = await LockMatchAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (match.SideOf(actor) is not { } side) return NotPlayer;
            if (await SettleAsync(conn, tx, match, ct) || match.Status != "active" || match.Now < match.StartsAt)
            {
                var (now0, view0) = await ReadViewAsync(conn, tx, id, ct);
                return new MindNext(now0, view0, null);
            }

            var index = match.AnsweredBy(side);
            MindQuestionView? question = null;
            while (index < match.Length)
            {
                await using var cmd = new NpgsqlCommand(
                    """
                    select q.kind, q.level, q.payload::text, q.limit_ms, a.served_at, a.served_at is not null and a.answered_at is null
                           and now() > a.served_at + (q.limit_ms + @grace) * interval '1 millisecond'
                    from public.mind_questions q
                    left join public.mind_answers a on a.match_id = q.match_id and a.idx = q.idx and a.user_id = @me
                    where q.match_id = @id and q.idx = @idx
                    """, conn, tx);
                cmd.Parameters.AddWithValue("me", actor);
                cmd.Parameters.AddWithValue("id", id);
                cmd.Parameters.AddWithValue("idx", index);
                cmd.Parameters.AddWithValue("grace", MindQuestions.GraceMs);
                string kind, payload;
                int level, limit;
                DateTimeOffset? servedAt;
                bool timedOut;
                await using (var r = await cmd.ExecuteReaderAsync(ct))
                {
                    await r.ReadAsync(ct);
                    (kind, level, payload, limit) = (r.GetString(0), r.GetInt32(1), r.GetString(2), r.GetInt32(3));
                    servedAt = r.IsDBNull(4) ? null : r.GetFieldValue<DateTimeOffset>(4);
                    timedOut = !r.IsDBNull(5) && r.GetBoolean(5);
                }
                if (timedOut)
                {
                    await ActingTransaction.ExecuteAsync(conn, tx,
                        "update public.mind_answers set answered_at = now(), points = 0, correct = false where match_id = @id and user_id = @me and idx = @idx",
                        ct, ("id", id), ("me", actor), ("idx", index));
                    await AppendPointsAsync(conn, tx, id, side, 0, ct);
                    index++;
                    continue;
                }
                if (servedAt is null)
                {
                    servedAt = new DateTimeOffset((DateTime)(await ActingTransaction.ScalarAsync(conn, tx,
                        "insert into public.mind_answers (match_id, user_id, idx) values (@id, @me, @idx) returning served_at", ct,
                        ("id", id), ("me", actor), ("idx", index)))!);
                    if (index == 0)
                    {
                        await ActingTransaction.ExecuteAsync(conn, tx,
                            side == "a" ? "update public.mind_matches set a_joined = true where id = @id" : "update public.mind_matches set b_joined = true where id = @id",
                            ct, ("id", id));
                    }
                }
                using var doc = JsonDocument.Parse(payload);
                question = new MindQuestionView(index, kind, level, doc.RootElement.Clone(), limit, servedAt.Value);
                break;
            }
            if (question is null) await FinishIfCompleteAsync(conn, tx, id, ct);
            var (now, view) = await ReadViewAsync(conn, tx, id, ct);
            return new MindNext(now, view, question);
        }, RuleError, ct);

    public Task<Result<MindAnswered>> AnswerAsync(Guid actor, Guid id, MindAnswerRequest request, CancellationToken ct) =>
        ActingTransaction.RunAsync<MindAnswered>(db, actor, async (conn, tx) =>
        {
            var match = await LockMatchAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (match.SideOf(actor) is not { } side) return NotPlayer;
            if (match.Status != "active" || await SettleAsync(conn, tx, match, ct)) return MatchOver;
            if (request.Index != match.AnsweredBy(side)) return OutOfSync;

            await using var cmd = new NpgsqlCommand(
                """
                select q.kind, q.payload::text, q.solution::text, q.limit_ms, (extract(epoch from now() - a.served_at) * 1000)::int
                from public.mind_questions q
                join public.mind_answers a on a.match_id = q.match_id and a.idx = q.idx and a.user_id = @me
                where q.match_id = @id and q.idx = @idx and a.answered_at is null
                """, conn, tx);
            cmd.Parameters.AddWithValue("me", actor);
            cmd.Parameters.AddWithValue("id", id);
            cmd.Parameters.AddWithValue("idx", request.Index);
            string kind, payload, solution;
            int limit, serverMs;
            await using (var r = await cmd.ExecuteReaderAsync(ct))
            {
                if (!await r.ReadAsync(ct)) return OutOfSync;
                (kind, payload, solution, limit, serverMs) = (r.GetString(0), r.GetString(1), r.GetString(2), r.GetInt32(3), r.GetInt32(4));
            }
            var solutionNode = JsonNode.Parse(solution)!.AsObject();
            var score = MindQuestions.Score(kind, JsonNode.Parse(payload)!.AsObject(), solutionNode, limit, request.Answer, request.ElapsedMs, serverMs);
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                update public.mind_answers set answered_at = now(), answer = @answer::jsonb, elapsed_ms = @elapsed, points = @points, correct = @correct
                where match_id = @id and user_id = @me and idx = @idx
                """, ct, ("answer", request.Answer.GetRawText()), ("elapsed", MindQuestions.CountedMs(request.ElapsedMs, serverMs)),
                ("points", score.Points), ("correct", score.Correct), ("id", id), ("me", actor), ("idx", request.Index));
            await AppendPointsAsync(conn, tx, id, side, score.Points, ct);
            await FinishIfCompleteAsync(conn, tx, id, ct);
            var (now, view) = await ReadViewAsync(conn, tx, id, ct);
            using var doc = JsonDocument.Parse(solution);
            return new MindAnswered(score.Points, score.Correct, doc.RootElement.Clone(), now, view);
        }, RuleError, ct);

    public Task<Result<MindView>> ResignAsync(Guid actor, Guid id, CancellationToken ct) =>
        ActingTransaction.RunAsync<MindView>(db, actor, async (conn, tx) =>
        {
            var match = await LockMatchAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (match.SideOf(actor) is not { } side) return NotPlayer;
            if (match.Status != "active" || await SettleAsync(conn, tx, match, ct)) return MatchOver;
            // Before both took their first question nothing was played: no rating for it.
            if (!(match.AJoined && match.BJoined)) await FinishAsync(conn, tx, match, null, "aborted", ct);
            else await FinishAsync(conn, tx, match, side == "a" ? "b" : "a", "resign", ct);
            return await ViewAsync(conn, tx, id, ct);
        }, RuleError, ct);

    public async Task<Result<MindRematch>> RematchAsync(Guid actor, Guid id, CancellationToken ct)
    {
        var asked = await ActingTransaction.RunAsync<(Guid Challenge, bool Theirs)>(db, actor, async (conn, tx) =>
        {
            var match = await LockMatchAsync(conn, tx, id, ct);
            if (match is null) return MatchNotFound;
            if (match.SideOf(actor) is not { } side) return NotPlayer;
            if (match.Status == "active" || match.A is null || match.B is null) return RematchUnavailable;
            var opponent = side == "a" ? match.B.Value : match.A.Value;
            var theirs = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
                """
                select id from public.mind_challenges
                where challenger_id = @them and opponent_id = @me and rematch_of = @match and status = 'pending' and expires_at > now()
                """, ct, ("them", opponent), ("me", actor), ("match", id));
            if (theirs is { } waiting) return (waiting, true);
            if (await IsSuspendedAsync(conn, tx, actor, ct)) return Suspended;
            var created = await CreateChallengeAsync(conn, tx, actor, opponent, match.Length, match.Rated, id, ct);
            return created.IsSuccess ? (created.Value, false) : created.Error;
        }, RuleError, ct);
        if (!asked.IsSuccess) return asked.Error;
        if (!asked.Value.Theirs) return new MindRematch(asked.Value.Challenge, null);
        var accepted = await AcceptChallengeAsync(actor, asked.Value.Challenge, ct);
        return accepted.IsSuccess ? new MindRematch(null, accepted.Value.MatchId) : accepted.Error;
    }

    // -----------------------------------------------------------------------
    // Shared steps
    // -----------------------------------------------------------------------

    /// <summary>Opens a match with all its questions; it starts after <see cref="StartDelay"/>.</summary>
    internal static async Task<Guid> CreateMatchAsync(
        NpgsqlConnection conn, NpgsqlTransaction tx, Guid a, Guid b, int length, bool rated, string source, Guid? rematchOf, CancellationToken ct)
    {
        var questions = MindQuestions.Generate(length, Random.Shared);
        var startsAt = DateTimeOffset.UtcNow + StartDelay;
        var deadline = startsAt + TimeSpan.FromMilliseconds(questions.Sum(q => q.LimitMs) + 3000L * length);
        var id = (Guid)(await ActingTransaction.ScalarAsync(conn, tx,
            """
            insert into public.mind_matches (a_id, b_id, length, rated, source, a_rating, b_rating, starts_at, deadline_at, rematch_of)
            values (@a, @b, @length, @rated, @source, @ar, @br, @starts, @deadline, @rematch)
            returning id
            """, ct, ("a", a), ("b", b), ("length", length), ("rated", rated), ("source", source),
            ("ar", await RatingAsync(conn, tx, a, length, ct)), ("br", await RatingAsync(conn, tx, b, length, ct)),
            ("starts", startsAt), ("deadline", deadline), ("rematch", rematchOf)))!;
        foreach (var q in questions)
        {
            await ActingTransaction.ExecuteAsync(conn, tx,
                """
                insert into public.mind_questions (match_id, idx, kind, level, payload, solution, limit_ms)
                values (@id, @idx, @kind, @level, @payload::jsonb, @solution::jsonb, @limit)
                """, ct, ("id", id), ("idx", q.Index), ("kind", q.Kind), ("level", q.Level), ("payload", q.Payload.ToJsonString()),
                ("solution", q.Solution.ToJsonString()), ("limit", q.LimitMs));
        }
        return id;
    }

    private static async Task<int> RatingAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, int length, CancellationToken ct) =>
        (int?)await ActingTransaction.ScalarAsync(conn, tx,
            "select rating from public.mind_ratings where user_id = @u and length = @l", ct, ("u", user), ("l", length))
        ?? ChessRules.StartRating;

    private static async Task<bool> IsSuspendedAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, CancellationToken ct) =>
        (bool)(await ActingTransaction.ScalarAsync(conn, tx,
            "select exists (select 1 from public.chess_players where user_id = @u and suspended_until > now())", ct, ("u", user)))!;

    private static async Task<Guid?> ActiveMatchAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid user, CancellationToken ct) =>
        (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
            "select id from public.mind_matches where status = 'active' and @u in (a_id, b_id) limit 1", ct, ("u", user));

    /// <summary>Ends a match whose join window or deadline passed. True when it ended.</summary>
    private static async Task<bool> SettleAsync(NpgsqlConnection conn, NpgsqlTransaction tx, MatchRow match, CancellationToken ct)
    {
        if (match.Status != "active") return false;
        if (match.Now > match.StartsAt + JoinWindow && !(match.AJoined && match.BJoined))
        {
            await FinishAsync(conn, tx, match, null, "aborted", ct);
            return true;
        }
        if (match.Now < match.DeadlineAt) return false;
        await FinishAsync(conn, tx, match, Winner(match.AScore, match.BScore), "time", ct);
        return true;
    }

    private static string Winner(int a, int b) => a > b ? "a" : b > a ? "b" : "draw";

    private static async Task FinishIfCompleteAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid id, CancellationToken ct)
    {
        var match = await LockMatchAsync(conn, tx, id, ct);
        if (match is { Status: "active" } && match.AAnswered == match.Length && match.BAnswered == match.Length)
            await FinishAsync(conn, tx, match, Winner(match.AScore, match.BScore), "completed", ct);
    }

    /// <summary>Writes the end and, for a rated decided or drawn match, both players' new ratings at the length.</summary>
    private static async Task FinishAsync(NpgsqlConnection conn, NpgsqlTransaction tx, MatchRow match, string? result, string termination, CancellationToken ct)
    {
        await ActingTransaction.ExecuteAsync(conn, tx,
            """
            update public.mind_matches
            set status = case when @result::text is null then 'aborted' else 'finished' end, result = @result, termination = @termination, ended_at = now()
            where id = @id
            """, ct, ("result", result), ("termination", termination), ("id", match.Id));
        await ActingTransaction.ExecuteAsync(conn, tx, "delete from public.mind_seeks where match_id = @id", ct, ("id", match.Id));
        if (!match.Rated || result is null || match.A is not { } a || match.B is not { } b) return;

        await ActingTransaction.ExecuteAsync(conn, tx,
            "insert into public.mind_ratings (user_id, length) values (@a, @l), (@b, @l) on conflict do nothing", ct, ("a", a), ("b", b), ("l", match.Length));
        async Task<(int Rating, int Games)> Read(Guid user)
        {
            await using var cmd = new NpgsqlCommand("select rating, games from public.mind_ratings where user_id = @u and length = @l for update", conn, tx);
            cmd.Parameters.AddWithValue("u", user);
            cmd.Parameters.AddWithValue("l", match.Length);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            await r.ReadAsync(ct);
            return (r.GetInt32(0), r.GetInt32(1));
        }
        var ra = await Read(a);
        var rb = await Read(b);
        var score = result switch { "a" => 1.0, "b" => 0.0, _ => 0.5 };
        var (da, dbDelta) = ChessRules.EloDeltas(ra.Rating, ra.Games, rb.Rating, rb.Games, score);
        const string Update =
            """
            update public.mind_ratings
            set rating = rating + @d, peak = greatest(peak, rating + @d), games = games + 1,
                wins = wins + @win, draws = draws + @draw, losses = losses + @loss, updated_at = now()
            where user_id = @u and length = @l
            """;
        await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", da), ("win", score == 1 ? 1 : 0), ("draw", score == 0.5 ? 1 : 0),
            ("loss", score == 0 ? 1 : 0), ("u", a), ("l", match.Length));
        await ActingTransaction.ExecuteAsync(conn, tx, Update, ct, ("d", dbDelta), ("win", score == 0 ? 1 : 0), ("draw", score == 0.5 ? 1 : 0),
            ("loss", score == 1 ? 1 : 0), ("u", b), ("l", match.Length));
        await ActingTransaction.ExecuteAsync(conn, tx,
            "update public.mind_matches set a_delta = @da, b_delta = @db where id = @id", ct, ("da", da), ("db", dbDelta), ("id", match.Id));
    }

    // -----------------------------------------------------------------------
    // Monitor (GamesMonitor)
    // -----------------------------------------------------------------------

    /// <summary>Ends matches past their join window or deadline, expires challenges, drops stale seeks.</summary>
    public async Task<int> SweepAsync(CancellationToken ct)
    {
        var due = new List<Guid>();
        await using (var cmd = db.CreateCommand(
            """
            select id from public.mind_matches
            where status = 'active' and (deadline_at <= now() or (starts_at + interval '30 seconds' < now() and not (a_joined and b_joined)))
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
            if (await LockMatchAsync(conn, tx, id, ct) is { } match && await SettleAsync(conn, tx, match, ct)) await tx.CommitAsync(ct);
        }
        await using var cleanup = db.CreateCommand(
            """
            update public.mind_challenges set status = 'expired', responded_at = now() where status = 'pending' and expires_at <= now();
            delete from public.mind_seeks where (match_id is null and touched_at < now() - interval '60 seconds')
                                             or (match_id is not null and created_at < now() - interval '30 minutes');
            """);
        await cleanup.ExecuteNonQueryAsync(ct);
        return due.Count;
    }

    // -----------------------------------------------------------------------
    // Administration
    // -----------------------------------------------------------------------

    public async Task<MindAdminOverview> MindOverviewAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        int today, total, active, seeks, challenges, rated;
        await using (var cmd = new NpgsqlCommand(
            """
            select
              (select count(*) from public.mind_matches
               where created_at >= (date_trunc('day', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul'))::int,
              (select count(*) from public.mind_matches where status = 'finished')::int,
              (select count(*) from public.mind_matches where status = 'active')::int,
              (select count(*) from public.mind_seeks where match_id is null)::int,
              (select count(*) from public.mind_challenges where status = 'pending' and expires_at > now())::int,
              (select count(distinct user_id) from public.mind_ratings where games > 0)::int
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            await r.ReadAsync(ct);
            (today, total, active, seeks, challenges, rated) = (r.GetInt32(0), r.GetInt32(1), r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5));
        }
        var matches = new List<MindAdminMatch>();
        await using (var cmd = new NpgsqlCommand(
            """
            select m.id, pa.username, pb.username, m.length, m.rated, m.a_score, m.b_score, cardinality(m.a_points), cardinality(m.b_points), m.created_at
            from public.mind_matches m
            left join public.profiles pa on pa.id = m.a_id
            left join public.profiles pb on pb.id = m.b_id
            where m.status = 'active'
            order by m.created_at desc
            limit 100
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct))
            {
                matches.Add(new MindAdminMatch(r.GetGuid(0), r.IsDBNull(1) ? null : r.GetString(1), r.IsDBNull(2) ? null : r.GetString(2), r.GetInt32(3),
                    r.GetBoolean(4), r.GetInt32(5), r.GetInt32(6), r.GetInt32(7), r.GetInt32(8), r.GetFieldValue<DateTimeOffset>(9)));
            }
        }
        return new MindAdminOverview(today, total, active, seeks, challenges, rated, matches);
    }

    public Task<Result> AbortMindMatchAsync(Guid actorId, Guid matchId, string reason, CancellationToken ct)
    {
        reason = reason?.Trim() ?? "";
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("games.reason_invalid", "Gerekçe 3–500 karakter olmalı."));
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var match = await LockMatchAsync(conn, tx, matchId, ct);
            if (match is null) return MatchNotFound;
            if (match.Status != "active") return MatchOver;
            await FinishAsync(conn, tx, match, null, "aborted", ct);
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "games.mind_match_aborted", "mind_match",
                matchId.ToString(), new { reason }), ct);
            return Result.Success();
        }, RuleError, ct);
    }
}
