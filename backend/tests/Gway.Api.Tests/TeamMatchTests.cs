using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gway.Modules.Admin;
using Gway.Modules.Games;
using Gway.Modules.Groups;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

public sealed class TeamMatchTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>A group owned by its captain with one more member.</summary>
    private async Task<(Guid Group, Guid Captain, Guid Member)> GroupAsync()
    {
        var captain = await _db.CreateUserAsync(Unique("tm_"));
        var member = await _db.CreateUserAsync(Unique("tm_"));
        var created = await factory.ClientFor(captain).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Satranç Kulübü", "chess", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        return (group, captain, member);
    }

    private Task<HttpResponseMessage> InviteAsync(Guid actor, Guid home, Guid away, int boards = 2) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path("/games/chess/team-matches"),
            new TeamMatchRequest(home, away, boards, 180, 2, DateTimeOffset.UtcNow.AddMinutes(20)), Ct);

    private async Task<Guid> AcceptedMatchAsync((Guid Group, Guid Captain, Guid Member) a, (Guid Group, Guid Captain, Guid Member) b)
    {
        var invited = await InviteAsync(a.Captain, a.Group, b.Group);
        Assert.Equal(HttpStatusCode.OK, invited.StatusCode);
        var id = (await invited.Content.ReadFromJsonAsync<TeamMatchCreated>(Ct))!.Id;
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/chess/team-matches/{id}/accept"), null, Ct)).StatusCode);
        return id;
    }

    private Task<HttpResponseMessage> LineupAsync(Guid actor, Guid match, Guid group, params Guid?[] players) =>
        factory.ClientFor(actor).PutAsJsonAsync(Path($"/games/chess/team-matches/{match}/lineup"), new LineupRequest(group, players), Ct);

    private async Task StartAsync(Guid match)
    {
        await _db.ExecuteAsync("update public.chess_team_matches set starts_at = now() - interval '1 second' where id = @id", ("id", match));
        Assert.Equal(1, await factory.Services.GetRequiredService<TeamMatchService>().StartDueAsync(Ct));
    }

    private Task<HttpResponseMessage> MoveAsync(Guid user, Guid game, string uci, int ply) =>
        factory.ClientFor(user).PostAsJsonAsync(Path($"/games/chess/{game}/moves"), new MoveRequest(uci, ply), Ct);

    [Fact]
    public async Task Captains_arrange_a_match_boards_are_played_and_the_score_moves_both_groups_elo()
    {
        var a = await GroupAsync();
        var b = await GroupAsync();

        // Only a captain invites; one open match per pair.
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await InviteAsync(a.Member, a.Group, b.Group)).StatusCode);
        var match = await AcceptedMatchAsync(a, b);
        Assert.Equal(HttpStatusCode.Conflict, (await InviteAsync(b.Captain, b.Group, a.Group)).StatusCode);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @c and type = 'chess_team_invite'", ("c", b.Captain)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @c and type = 'chess_team_accepted'", ("c", a.Captain)));

        // A side lines up its own members only, each once.
        Assert.Equal(HttpStatusCode.BadRequest, (await LineupAsync(a.Captain, match, a.Group, a.Captain, b.Member)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await LineupAsync(a.Captain, match, a.Group, a.Captain, a.Captain)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await LineupAsync(a.Captain, match, b.Group, b.Captain)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await LineupAsync(a.Captain, match, a.Group, a.Captain, a.Member)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await LineupAsync(b.Captain, match, b.Group, b.Captain, null)).StatusCode);

        await StartAsync(match);
        Assert.Equal("live", await _db.ScalarAsync<string>("select status from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(3, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'chess_team_start' and recipient_id in (@a1, @a2, @b1)",
            ("a1", a.Captain), ("a2", a.Member), ("b1", b.Captain)));
        // Board 2 has nobody from B: it goes to A at once. Board 1 is a game, home white.
        Assert.Equal(1m, await _db.ScalarAsync<decimal>("select home_points from public.chess_team_boards where match_id = @m and board = 2", ("m", match)));
        var game = await _db.ScalarAsync<Guid>("select game_id from public.chess_team_boards where match_id = @m and board = 1", ("m", match));
        Assert.Equal(a.Captain, await _db.ScalarAsync<Guid>("select white_id from public.chess_games where id = @g", ("g", game)));

        // No aborting a board.
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/chess/{game}/abort"), null, Ct)).StatusCode);

        string[] mate = ["e2e4", "e7e5", "f1c4", "b8c6", "d1h5", "g8f6", "h5f7"];
        for (var i = 0; i < mate.Length; i++) (await MoveAsync(i % 2 == 0 ? a.Captain : b.Captain, game, mate[i], i)).EnsureSuccessStatusCode();

        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(2m, await _db.ScalarAsync<decimal>("select home_points from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(1216, await _db.ScalarAsync<int>("select rating from public.chess_group_ratings where group_id = @g", ("g", a.Group)));
        Assert.Equal(1184, await _db.ScalarAsync<int>("select rating from public.chess_group_ratings where group_id = @g", ("g", b.Group)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select losses from public.chess_group_ratings where group_id = @g", ("g", b.Group)));
        // The board game was a rated game for both players too.
        Assert.Equal(1220, await _db.ScalarAsync<int>("select rating from public.chess_ratings where user_id = @u and category = 'blitz'", ("u", a.Captain)));
    }

    [Fact]
    public async Task A_player_who_never_moves_loses_the_board_without_rating_and_resigning_early_is_a_loss()
    {
        var a = await GroupAsync();
        var b = await GroupAsync();
        var match = await AcceptedMatchAsync(a, b);
        (await LineupAsync(a.Captain, match, a.Group, a.Captain, a.Member)).EnsureSuccessStatusCode();
        (await LineupAsync(b.Captain, match, b.Group, b.Captain, b.Member)).EnsureSuccessStatusCode();
        await StartAsync(match);
        var board1 = await _db.ScalarAsync<Guid>("select game_id from public.chess_team_boards where match_id = @m and board = 1", ("m", match));
        var board2 = await _db.ScalarAsync<Guid>("select game_id from public.chess_team_boards where match_id = @m and board = 2", ("m", match));

        // Board 1: white (A's captain) never comes; 30 seconds is not enough to lose it, 5 minutes is.
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '1 minute' where id = @g", ("g", board1));
        await factory.Services.GetRequiredService<ChessService>().SweepAsync(Ct);
        Assert.Equal("active", await _db.ScalarAsync<string>("select status from public.chess_games where id = @g", ("g", board1)));
        await _db.ExecuteAsync("update public.chess_games set turn_started_at = now() - interval '6 minutes' where id = @g", ("g", board1));
        await factory.Services.GetRequiredService<ChessService>().SweepAsync(Ct);
        Assert.Equal("no_show", await _db.ScalarAsync<string>("select termination from public.chess_games where id = @g", ("g", board1)));
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.chess_ratings where user_id = @u", ("u", a.Captain)));

        // Board 2: B's member is white (away on even boards) and resigns before moving: a loss, not an abort.
        var view = await factory.ClientFor(b.Member).PostAsync(Path($"/games/chess/{board2}/resign"), null, Ct);
        var g = (await view.Content.ReadFromJsonAsync<JsonElement>(Ct)).GetProperty("game");
        Assert.Equal("black", g.GetProperty("result").GetString());

        // 1–1 between equal groups: both stay at 1200 with a draw.
        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(1200, await _db.ScalarAsync<int>("select rating from public.chess_group_ratings where group_id = @g", ("g", a.Group)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select draws from public.chess_group_ratings where group_id = @g", ("g", b.Group)));
    }

    [Fact]
    public async Task Unanswered_invitations_expire_and_staff_can_call_off_a_match()
    {
        var a = await GroupAsync();
        var b = await GroupAsync();
        var staff = await _db.CreateUserAsync(Unique("tm_"));
        await _db.MakeStaffAsync(staff, "moderator");

        var invited = await InviteAsync(a.Captain, a.Group, b.Group);
        var id = (await invited.Content.ReadFromJsonAsync<TeamMatchCreated>(Ct))!.Id;
        await _db.ExecuteAsync("update public.chess_team_matches set starts_at = now() - interval '1 second' where id = @id", ("id", id));
        await factory.Services.GetRequiredService<TeamMatchService>().StartDueAsync(Ct);
        Assert.Equal("canceled", await _db.ScalarAsync<string>("select status from public.chess_team_matches where id = @id", ("id", id)));

        var match = await AcceptedMatchAsync(a, b);
        var list = await factory.ClientFor(staff).GetFromJsonAsync<JsonElement>(Path("/admin/games/chess/team-matches"), Ct);
        Assert.Contains(list.EnumerateArray(), m => m.GetProperty("id").GetGuid() == match);
        var canceled = await factory.ClientFor(staff).PostAsJsonAsync(Path($"/admin/games/chess/team-matches/{match}/cancel"),
            new CancelTeamMatchRequest("Grup şikayeti"), Ct);
        Assert.Equal(HttpStatusCode.NoContent, canceled.StatusCode);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where actor_id = @s and action = 'games.team_match_canceled'", ("s", staff)));
    }
}
