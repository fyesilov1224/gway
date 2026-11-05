using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using Gway.Modules.Games;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

public sealed class MindQuestionsTests
{
    private static JsonElement Answer(object value) => JsonSerializer.SerializeToElement(value);

    [Fact]
    public void Multiplication_and_division_come_first()
    {
        object[] tokens = [49, '+', 9, '×', 2];
        Assert.Equal(67, MindQuestions.Evaluate(tokens));
        Assert.Equal(116, MindQuestions.LeftToRight(tokens));
        object[] mixed = [30, '−', 24, '÷', 6, '+', 5];
        Assert.Equal(31, MindQuestions.Evaluate(mixed));
    }

    [Fact]
    public void Every_block_of_four_holds_each_kind_once_and_levels_rise()
    {
        var order = MindQuestions.KindOrder(20, new Random(7));
        for (var block = 0; block < 5; block++)
        {
            Assert.Equal(4, order.Skip(block * 4).Take(4).Distinct().Count());
        }
        Assert.Equal([1, 1, 2, 2, 3, 3, 4, 4], Enumerable.Range(0, 8).Select(i => MindQuestions.LevelOf(i, 8)));
        Assert.Equal(4, MindQuestions.LevelOf(49, 50));
    }

    [Fact]
    public void Generated_questions_are_well_formed()
    {
        var random = new Random(11);
        for (var round = 0; round < 200; round++)
        {
            foreach (var q in MindQuestions.Generate(MindQuestions.Lengths[round % 4], random))
            {
                switch (q.Kind)
                {
                    case MindQuestions.Math:
                    {
                        var choices = q.Payload["choices"]!.AsArray().Select(n => (int)n!).ToList();
                        Assert.Equal(4, choices.Distinct().Count());
                        var tokens = q.Payload["expression"]!.ToString().Split(' ')
                            .Select(t => int.TryParse(t, out var n) ? (object)n : t[0]).ToList();
                        Assert.Equal(MindQuestions.Evaluate(tokens), choices[(int)q.Solution["choice"]!]);
                        Assert.True(choices[(int)q.Solution["choice"]!] >= 0);
                        break;
                    }
                    case MindQuestions.Attention:
                    {
                        Assert.NotEqual(q.Payload["color"]!.ToString(), q.Payload["ink"]!.ToString());
                        var figures = q.Payload["choices"]!.AsArray().Select(f => f!.ToJsonString()).ToList();
                        Assert.Equal(4, figures.Distinct().Count());
                        var right = q.Payload["choices"]![(int)q.Solution["choice"]!]!;
                        Assert.Equal(q.Payload["color"]!.ToString(), right["color"]!.ToString());
                        Assert.Equal(q.Payload["shape"]!.ToString(), right["shape"]!.ToString());
                        Assert.Equal(q.Payload["pattern"]!.ToString(), right["pattern"]!.ToString());
                        // The ink's trap is always among the choices.
                        Assert.Contains(q.Payload["choices"]!.AsArray(), f => f!["color"]!.ToString() == q.Payload["ink"]!.ToString()
                            && f["shape"]!.ToString() == q.Payload["shape"]!.ToString());
                        break;
                    }
                    case MindQuestions.Memory:
                    {
                        var items = q.Payload["items"]!.AsArray();
                        var options = q.Payload["options"]!.AsArray().Select(o => o!.ToJsonString()).ToList();
                        Assert.Equal(options.Count, options.Distinct().Count());
                        Assert.Equal(3 + q.Level, items.Count);
                        var picks = q.Solution["picks"]!.AsArray().Select(n => (int)n!).ToList();
                        Assert.Equal(items.Select(i => i!.ToJsonString()), picks.Select(p => options[p]));
                        break;
                    }
                    default:
                    {
                        var grid = (int)q.Payload["grid"]!;
                        Assert.Equal(grid * grid, q.Payload["decoys"]!.AsArray().Count);
                        var target = q.Payload["target"]!.ToJsonString();
                        Assert.DoesNotContain(q.Payload["decoys"]!.AsArray(), d => d!.ToJsonString() == target);
                        Assert.InRange((int)q.Solution["cell"]!, 0, grid * grid - 1);
                        break;
                    }
                }
            }
        }
    }

    [Fact]
    public void Right_and_fast_scores_more_wrong_and_late_score_nothing()
    {
        var payload = new JsonObject();
        var solution = new JsonObject { ["choice"] = 2 };
        Assert.Equal(new MindScore(200, true), MindQuestions.Score("math", payload, solution, 10_000, Answer(new { choice = 2 }), 0, 100));
        Assert.Equal(new MindScore(150, true), MindQuestions.Score("math", payload, solution, 10_000, Answer(new { choice = 2 }), 5_000, 5_100));
        Assert.Equal(new MindScore(0, false), MindQuestions.Score("math", payload, solution, 10_000, Answer(new { choice = 1 }), 100, 200));
        Assert.Equal(new MindScore(0, false), MindQuestions.Score("math", payload, solution, 10_000, Answer(new { choice = 2 }), 100, 12_500));
        // The app may not claim it was much faster than the server saw.
        Assert.Equal(170, MindQuestions.Score("attention", payload, solution, 10_000, Answer(new { choice = 2 }), 0, 5_000).Points);
    }

    [Fact]
    public void Memory_counts_places_and_full_marks_need_the_whole_sequence()
    {
        var payload = new JsonObject { ["showMs"] = 4_000 };
        var solution = new JsonObject { ["picks"] = new JsonArray(3, 0, 5, 1) };
        var all = MindQuestions.Score("memory", payload, solution, 16_000, Answer(new { picks = new[] { 3, 0, 5, 1 } }), 10_000, 10_100);
        Assert.Equal(new MindScore(150, true), all);
        Assert.Equal(new MindScore(30, false), MindQuestions.Score("memory", payload, solution, 16_000, Answer(new { picks = new[] { 3, 0, 1, 5 } }), 10_000, 10_100));
    }

    [Fact]
    public void A_reflex_tap_too_early_or_on_the_wrong_cell_loses_points()
    {
        var payload = new JsonObject { ["delayMs"] = 2_000, ["visibleMs"] = 1_000 };
        var solution = new JsonObject { ["cell"] = 4 };
        Assert.Equal(new MindScore(150, true), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = 4, reactionMs = 500 }), null, 2_700));
        Assert.Equal(new MindScore(-50, false), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = 4, reactionMs = -300 }), null, 1_800));
        Assert.Equal(new MindScore(-50, false), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = 4, reactionMs = 80 }), null, 2_300));
        Assert.Equal(new MindScore(-50, false), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = 4, reactionMs = 400 }), null, 1_000));
        Assert.Equal(new MindScore(-50, false), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = 3, reactionMs = 400 }), null, 2_600));
        Assert.Equal(new MindScore(0, false), MindQuestions.Score("reflex", payload, solution, 4_000, Answer(new { cell = -1, reactionMs = 0 }), null, 3_100));
    }
}

public sealed class MindTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid A, Guid B)> PlayersAsync() =>
        (await _db.CreateUserAsync(Unique("md_")), await _db.CreateUserAsync(Unique("md_")));

    /// <summary>A challenges B, B accepts and the countdown is skipped.</summary>
    private async Task<Guid> StartAsync(Guid a, Guid b, int length = 5, bool rated = true, bool skipCountdown = true)
    {
        var sent = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/mind/challenges"), new MindChallengeRequest(b, length, rated), Ct);
        Assert.Equal(HttpStatusCode.OK, sent.StatusCode);
        var challenge = (await sent.Content.ReadFromJsonAsync<ChallengeCreated>(Ct))!.Id;
        var accepted = await factory.ClientFor(b).PostAsync(Path($"/games/mind/challenges/{challenge}/accept"), null, Ct);
        Assert.Equal(HttpStatusCode.OK, accepted.StatusCode);
        var match = (await accepted.Content.ReadFromJsonAsync<MindMatchStarted>(Ct))!.MatchId;
        if (skipCountdown) await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '1 second' where id = @id", ("id", match));
        return match;
    }

    private async Task<JsonElement> NextAsync(Guid user, Guid match)
    {
        var response = await factory.ClientFor(user).PostAsync(Path($"/games/mind/{match}/next"), null, Ct);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        return await response.Content.ReadFromJsonAsync<JsonElement>(Ct);
    }

    /// <summary>The right answer for a question, read the way only the server can.</summary>
    private async Task<object> RightAnswerAsync(Guid match, int index)
    {
        var kind = (await _db.ScalarAsync<string>("select kind from public.mind_questions where match_id = @m and idx = @i", ("m", match), ("i", index)))!;
        var solution = JsonNode.Parse((await _db.ScalarAsync<string>(
            "select solution::text from public.mind_questions where match_id = @m and idx = @i", ("m", match), ("i", index)))!)!;
        if (kind == MindQuestions.Reflex)
        {
            // As if the target appeared and was tapped half a second later.
            var delay = await _db.ScalarAsync<int>("select (payload->>'delayMs')::int from public.mind_questions where match_id = @m and idx = @i",
                ("m", match), ("i", index));
            await _db.ExecuteAsync("update public.mind_answers set served_at = now() - @ms * interval '1 millisecond' where match_id = @m and idx = @i",
                ("ms", delay + 600), ("m", match), ("i", index));
            return new { cell = (int)solution["cell"]!, reactionMs = 500 };
        }
        return kind == MindQuestions.Memory ? new { picks = solution["picks"]!.AsArray().Select(n => (int)n!).ToArray() } : new { choice = (int)solution["choice"]! };
    }

    private Task<HttpResponseMessage> AnswerAsync(Guid user, Guid match, int index, object answer, int elapsed = 1_000) =>
        factory.ClientFor(user).PostAsJsonAsync(Path($"/games/mind/{match}/answers"),
            new MindAnswerRequest(index, JsonSerializer.SerializeToElement(answer), elapsed), Ct);

    [Fact]
    public async Task Both_answer_the_same_questions_and_the_higher_score_wins_rating()
    {
        var (a, b) = await PlayersAsync();
        var match = await StartAsync(a, b);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @b and actor_id = @a and type = 'mind_challenge'", ("a", a), ("b", b)));

        for (var i = 0; i < 5; i++)
        {
            var next = await NextAsync(a, match);
            var question = next.GetProperty("question");
            Assert.Equal(i, question.GetProperty("index").GetInt32());
            Assert.False(question.TryGetProperty("solution", out _));
            var answered = await AnswerAsync(a, match, i, await RightAnswerAsync(match, i));
            Assert.Equal(HttpStatusCode.OK, answered.StatusCode);
            var body = await answered.Content.ReadFromJsonAsync<JsonElement>(Ct);
            Assert.True(body.GetProperty("correct").GetBoolean());
            Assert.True(body.GetProperty("points").GetInt32() > 100);

            // B takes the same question and gets it wrong.
            var theirs = (await NextAsync(b, match)).GetProperty("question");
            Assert.Equal(question.GetProperty("payload").GetRawText(), theirs.GetProperty("payload").GetRawText());
            var wrong = await AnswerAsync(b, match, i, new { choice = -1, picks = Array.Empty<int>(), cell = -1 });
            Assert.Equal(HttpStatusCode.OK, wrong.StatusCode);
        }

        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.mind_matches where id = @id", ("id", match)));
        Assert.Equal("a", await _db.ScalarAsync<string>("select result from public.mind_matches where id = @id", ("id", match)));
        Assert.Equal("completed", await _db.ScalarAsync<string>("select termination from public.mind_matches where id = @id", ("id", match)));
        Assert.Equal(5, await _db.ScalarAsync<int>("select cardinality(b_points) from public.mind_matches where id = @id", ("id", match)));
        Assert.Equal(1220, await _db.ScalarAsync<int>("select rating from public.mind_ratings where user_id = @a and length = 5", ("a", a)));
        Assert.Equal(1180, await _db.ScalarAsync<int>("select rating from public.mind_ratings where user_id = @b and length = 5", ("b", b)));
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.mind_ratings where user_id = @a and length <> 5", ("a", a)));
    }

    [Fact]
    public async Task Questions_wait_for_the_start_and_come_one_at_a_time()
    {
        var (a, b) = await PlayersAsync();
        var match = await StartAsync(a, b, skipCountdown: false);
        Assert.Equal(JsonValueKind.Null, (await NextAsync(a, match)).GetProperty("question").ValueKind);
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '1 second' where id = @id", ("id", match));

        var first = (await NextAsync(a, match)).GetProperty("question");
        var again = (await NextAsync(a, match)).GetProperty("question");
        Assert.Equal(0, again.GetProperty("index").GetInt32());
        Assert.Equal(first.GetProperty("servedAt").GetString(), again.GetProperty("servedAt").GetString());
        Assert.Equal(HttpStatusCode.Conflict, (await AnswerAsync(a, match, 1, new { choice = 0 })).StatusCode);

        // A question left past its time counts zero and the next one comes.
        await _db.ExecuteAsync("update public.mind_answers set served_at = now() - interval '60 seconds' where match_id = @m and user_id = @a",
            ("m", match), ("a", a));
        Assert.Equal(1, (await NextAsync(a, match)).GetProperty("question").GetProperty("index").GetInt32());
        Assert.Equal(0, await _db.ScalarAsync<int>("select a_points[1] from public.mind_matches where id = @id", ("id", match)));

        // One duel at a time.
        var other = await _db.CreateUserAsync(Unique("md_"));
        var busy = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/mind/seeks"), new MindSeekRequest(10), Ct);
        Assert.Equal(HttpStatusCode.Conflict, busy.StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(other).PostAsJsonAsync(Path("/games/mind/seeks"), new MindSeekRequest(7), Ct)).StatusCode);
    }

    [Fact]
    public async Task Leaving_before_both_joined_aborts_and_after_it_loses()
    {
        var (a, b) = await PlayersAsync();
        var early = await StartAsync(a, b);
        await NextAsync(a, early);
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(a).PostAsync(Path($"/games/mind/{early}/resign"), null, Ct)).StatusCode);
        Assert.Equal("aborted", await _db.ScalarAsync<string>("select status from public.mind_matches where id = @id", ("id", early)));

        var played = await StartAsync(a, b);
        await NextAsync(a, played);
        await NextAsync(b, played);
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(a).PostAsync(Path($"/games/mind/{played}/resign"), null, Ct)).StatusCode);
        Assert.Equal("b", await _db.ScalarAsync<string>("select result from public.mind_matches where id = @id", ("id", played)));
        Assert.Equal("resign", await _db.ScalarAsync<string>("select termination from public.mind_matches where id = @id", ("id", played)));

        // A rematch from the loser waits for the winner; the winner's request starts it.
        var asked = await factory.ClientFor(a).PostAsync(Path($"/games/mind/{played}/rematch"), null, Ct);
        Assert.Null((await asked.Content.ReadFromJsonAsync<MindRematch>(Ct))!.MatchId);
        var started = await factory.ClientFor(b).PostAsync(Path($"/games/mind/{played}/rematch"), null, Ct);
        Assert.NotNull((await started.Content.ReadFromJsonAsync<MindRematch>(Ct))!.MatchId);
    }

    [Fact]
    public async Task The_monitor_aborts_no_shows_and_ends_matches_at_the_deadline()
    {
        var (a, b) = await PlayersAsync();
        var absent = await StartAsync(a, b, rated: true);
        await NextAsync(a, absent);
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '31 seconds' where id = @id", ("id", absent));
        var monitor = factory.Services.GetRequiredService<MindService>();
        await monitor.SweepAsync(Ct);
        Assert.Equal("aborted", await _db.ScalarAsync<string>("select status from public.mind_matches where id = @id", ("id", absent)));

        var late = await StartAsync(a, b);
        await NextAsync(a, late);
        await NextAsync(b, late);
        await AnswerAsync(a, late, 0, await RightAnswerAsync(late, 0));
        await _db.ExecuteAsync("update public.mind_matches set deadline_at = now() - interval '1 second', starts_at = now() - interval '2 seconds' where id = @id",
            ("id", late));
        await monitor.SweepAsync(Ct);
        Assert.Equal("time", await _db.ScalarAsync<string>("select termination from public.mind_matches where id = @id", ("id", late)));
        Assert.Equal("a", await _db.ScalarAsync<string>("select result from public.mind_matches where id = @id", ("id", late)));
    }

    [Fact]
    public async Task Quick_match_pairs_two_seekers_and_staff_can_abort_with_an_audit_trail()
    {
        var (a, b) = await PlayersAsync();
        var first = await factory.ClientFor(a).PostAsJsonAsync(Path("/games/mind/seeks"), new MindSeekRequest(20), Ct);
        Assert.Null((await first.Content.ReadFromJsonAsync<MindSeekResult>(Ct))!.MatchId);
        var second = await factory.ClientFor(b).PostAsJsonAsync(Path("/games/mind/seeks"), new MindSeekRequest(20), Ct);
        var match = (await second.Content.ReadFromJsonAsync<MindSeekResult>(Ct))!.MatchId;
        Assert.NotNull(match);
        Assert.Equal(20, await _db.ScalarAsync<long>("select count(*) from public.mind_questions where match_id = @id", ("id", match!.Value)));
        Assert.Equal(match, (await (await factory.ClientFor(a).PostAsync(Path("/games/mind/seeks/heartbeat"), null, Ct))
            .Content.ReadFromJsonAsync<MindSeekResult>(Ct))!.MatchId);

        var staff = await _db.CreateUserAsync(Unique("md_"));
        await _db.MakeStaffAsync(staff, "moderator");
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(a).GetAsync(Path("/admin/games/mind"), Ct)).StatusCode);
        var overview = await (await factory.ClientFor(staff).GetAsync(Path("/admin/games/mind"), Ct)).Content.ReadFromJsonAsync<JsonElement>(Ct);
        Assert.Contains(overview.GetProperty("active").EnumerateArray(), m => m.GetProperty("id").GetGuid() == match);
        var aborted = await factory.ClientFor(staff).PostAsJsonAsync(Path($"/admin/games/mind/{match}/abort"), new { reason = "Teknik sorun" }, Ct);
        Assert.Equal(HttpStatusCode.NoContent, aborted.StatusCode);
        Assert.Equal("aborted", await _db.ScalarAsync<string>("select status from public.mind_matches where id = @id", ("id", match.Value)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'games.mind_match_aborted' and actor_id = @s", ("s", staff)));
    }
}
