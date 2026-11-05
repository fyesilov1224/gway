using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Games;
using Gway.Modules.Groups;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

/// <summary>Group duels (docs/ARCHITECTURE.md §3j, 21b): the chess team match running Zihin Düellosu seats.</summary>
public sealed class MindTeamTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<(Guid Group, Guid Captain, Guid Member)> GroupAsync()
    {
        var captain = await _db.CreateUserAsync(Unique("mt_"));
        var member = await _db.CreateUserAsync(Unique("mt_"));
        var created = await factory.ClientFor(captain).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Zihin Kulübü", "chess", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        return (group, captain, member);
    }

    private Task<HttpResponseMessage> InviteAsync(Guid actor, Guid home, Guid away, int length = 5, int boards = 2) =>
        factory.ClientFor(actor).PostAsJsonAsync(Path("/games/mind/team-matches"),
            new MindTeamMatchRequest(home, away, boards, length, DateTimeOffset.UtcNow.AddMinutes(20)), Ct);

    private async Task<Guid> StartedMatchAsync((Guid Group, Guid Captain, Guid Member) a, (Guid Group, Guid Captain, Guid Member) b,
        Guid?[] home, Guid?[] away)
    {
        var invited = await InviteAsync(a.Captain, a.Group, b.Group);
        Assert.Equal(HttpStatusCode.OK, invited.StatusCode);
        var match = (await invited.Content.ReadFromJsonAsync<TeamMatchCreated>(Ct))!.Id;
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/chess/team-matches/{match}/accept"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(a.Captain).PutAsJsonAsync(
            Path($"/games/chess/team-matches/{match}/lineup"), new LineupRequest(a.Group, home), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(b.Captain).PutAsJsonAsync(
            Path($"/games/chess/team-matches/{match}/lineup"), new LineupRequest(b.Group, away), Ct)).StatusCode);
        await _db.ExecuteAsync("update public.chess_team_matches set starts_at = now() - interval '1 second' where id = @id", ("id", match));
        Assert.Equal(1, await factory.Services.GetRequiredService<TeamMatchService>().StartDueAsync(Ct));
        return match;
    }

    private async Task<Guid> DuelOnAsync(Guid match, int board)
    {
        var duel = await _db.ScalarAsync<Guid>("select mind_match_id from public.chess_team_boards where match_id = @m and board = @b",
            ("m", match), ("b", board));
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '1 second' where id = @id", ("id", duel));
        return duel;
    }

    [Fact]
    public async Task Groups_duel_seat_by_seat_and_the_score_moves_their_own_duel_elo()
    {
        var a = await GroupAsync();
        var b = await GroupAsync();
        Assert.Equal(HttpStatusCode.BadRequest, (await InviteAsync(a.Captain, a.Group, b.Group, length: 7)).StatusCode);

        // Seat 2 has nobody for b: it goes to a at the start.
        var match = await StartedMatchAsync(a, b, [a.Captain, a.Member], [b.Captain]);
        Assert.Equal("mind", await _db.ScalarAsync<string>("select game from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @c and type = 'mind_team_invite'", ("c", b.Captain)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @c and type = 'mind_team_start'", ("c", b.Captain)));
        // The same two groups may still play chess at the same time: one open match per game.
        var chess = await factory.ClientFor(b.Captain).PostAsJsonAsync(Path("/games/chess/team-matches"),
            new TeamMatchRequest(b.Group, a.Group, 2, 180, 2, DateTimeOffset.UtcNow.AddMinutes(20)), Ct);
        Assert.Equal(HttpStatusCode.OK, chess.StatusCode);

        var duel = await DuelOnAsync(match, 1);
        Assert.Equal(match, await _db.ScalarAsync<Guid>("select team_match_id from public.mind_matches where id = @id", ("id", duel)));
        Assert.Equal(a.Captain, await _db.ScalarAsync<Guid>("select a_id from public.mind_matches where id = @id", ("id", duel)));
        Assert.Equal(1m, await _db.ScalarAsync<decimal>("select home_points from public.chess_team_boards where match_id = @m and board = 2", ("m", match)));

        // A team seat is lost by leaving, even before the first question; no rematch for it.
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/mind/{duel}/resign"), null, Ct)).StatusCode);
        Assert.Equal("a", await _db.ScalarAsync<string>("select result from public.mind_matches where id = @id", ("id", duel)));
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/mind/{duel}/rematch"), null, Ct)).StatusCode);

        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(2m, await _db.ScalarAsync<decimal>("select home_points from public.chess_team_matches where id = @id", ("id", match)));
        Assert.Equal(1216, await _db.ScalarAsync<int>(
            "select rating from public.chess_group_ratings where group_id = @g and game = 'mind'", ("g", a.Group)));
        Assert.Equal(1184, await _db.ScalarAsync<int>(
            "select rating from public.chess_group_ratings where group_id = @g and game = 'mind'", ("g", b.Group)));
        Assert.Equal(0, await _db.ScalarAsync<long>(
            "select count(*) from public.chess_group_ratings where group_id in (@a, @b) and game = 'chess'", ("a", a.Group), ("b", b.Group)));
    }

    [Fact]
    public async Task A_seat_nobody_comes_to_on_one_side_goes_to_the_other_without_personal_elo()
    {
        var a = await GroupAsync();
        var b = await GroupAsync();
        var match = await StartedMatchAsync(a, b, [a.Captain], [b.Captain]);
        var duel = await DuelOnAsync(match, 1);
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(b.Captain).PostAsync(Path($"/games/mind/{duel}/next"), null, Ct)).StatusCode);

        // Within five minutes the absent side may still come.
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '2 minutes' where id = @id", ("id", duel));
        var monitor = factory.Services.GetRequiredService<MindService>();
        await monitor.SweepAsync(Ct);
        Assert.Equal("active", await _db.ScalarAsync<string>("select status from public.mind_matches where id = @id", ("id", duel)));

        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '6 minutes' where id = @id", ("id", duel));
        await monitor.SweepAsync(Ct);
        Assert.Equal("no_show", await _db.ScalarAsync<string>("select termination from public.mind_matches where id = @id", ("id", duel)));
        Assert.Equal("b", await _db.ScalarAsync<string>("select result from public.mind_matches where id = @id", ("id", duel)));
        Assert.Equal(0, await _db.ScalarAsync<long>("select count(*) from public.mind_ratings where user_id in (@a, @b)", ("a", a.Captain), ("b", b.Captain)));
        Assert.Equal(1m, await _db.ScalarAsync<decimal>("select away_points from public.chess_team_matches where id = @id", ("id", match)));
    }
}
