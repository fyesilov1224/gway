using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Games;
using Gway.Modules.Games.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace Gway.Api.Tests;

/// <summary>Duel tournaments (docs/ARCHITECTURE.md §3j, Turnuvalar): the chess arena pairing players into duels.</summary>
public sealed class MindArenaTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private Task<HttpResponseMessage> CreateAsync(Guid admin, int length) =>
        factory.ClientFor(admin).PostAsJsonAsync(Path("/admin/games/chess/tournaments"),
            new TournamentDraft("Cuma Düello Turnuvası", 0, 0, DateTimeOffset.UtcNow.AddMinutes(10), 60, "mind", length), Ct);

    private Task<Guid> CurrentDuelAsync(Guid arena, Guid user) => _db.ScalarAsync<Guid>(
        "select current_match_id from public.chess_tournament_players where tournament_id = @t and user_id = @u", ("t", arena), ("u", user));

    private Task<int> PointsAsync(Guid arena, Guid user) => _db.ScalarAsync<int>(
        "select points from public.chess_tournament_players where tournament_id = @t and user_id = @u", ("t", arena), ("u", user));

    [Fact]
    public async Task A_duel_arena_pairs_into_duels_scores_no_shows_and_gives_duel_medals()
    {
        var admin = await _db.CreateUserAsync(Unique("ma_"));
        await _db.MakeStaffAsync(admin, "admin");
        var (a, b) = (await _db.CreateUserAsync(Unique("ma_")), await _db.CreateUserAsync(Unique("ma_")));
        Assert.Equal(HttpStatusCode.BadRequest, (await CreateAsync(admin, 7)).StatusCode);
        var created = await CreateAsync(admin, 5);
        Assert.Equal(HttpStatusCode.OK, created.StatusCode);
        var arena = await created.Content.ReadFromJsonAsync<Guid>(Ct);
        Assert.Equal("mind", await _db.ScalarAsync<string>("select game from public.chess_tournaments where id = @id", ("id", arena)));

        foreach (var u in new[] { a, b })
            Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(u).PostAsync(Path($"/games/chess/tournaments/{arena}/join"), null, Ct)).StatusCode);
        await _db.ExecuteAsync(
            "update public.chess_tournaments set starts_at = now() - interval '1 second', ends_at = now() + interval '1 hour' where id = @id", ("id", arena));
        var arenas = factory.Services.GetRequiredService<TournamentService>();
        await arenas.TickAsync(Ct);
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @u and type = 'mind_arena_start'", ("u", a)));

        // The first duel: b leaves and loses it; both go back to the pool.
        var first = await CurrentDuelAsync(arena, a);
        Assert.Equal(first, await CurrentDuelAsync(arena, b));
        Assert.Equal("arena", await _db.ScalarAsync<string>("select source from public.mind_matches where id = @id", ("id", first)));
        Assert.Equal(5, await _db.ScalarAsync<int>("select length from public.mind_matches where id = @id", ("id", first)));
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(b).PostAsync(Path($"/games/mind/{first}/resign"), null, Ct)).StatusCode);
        Assert.Equal(2, await PointsAsync(arena, a));
        Assert.Equal(0, await PointsAsync(arena, b));
        Assert.True(await _db.ScalarAsync<bool>(
            "select bool_and(waiting) from public.chess_tournament_players where tournament_id = @t", ("t", arena)));

        // The second duel: only a comes; after 30 seconds a wins it and b leaves the pool.
        await arenas.TickAsync(Ct);
        var second = await CurrentDuelAsync(arena, a);
        Assert.NotEqual(first, second);
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '1 second' where id = @id", ("id", second));
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(a).PostAsync(Path($"/games/mind/{second}/next"), null, Ct)).StatusCode);
        await _db.ExecuteAsync("update public.mind_matches set starts_at = now() - interval '31 seconds' where id = @id", ("id", second));
        await factory.Services.GetRequiredService<MindService>().SweepAsync(Ct);
        Assert.Equal("no_show", await _db.ScalarAsync<string>("select termination from public.mind_matches where id = @id", ("id", second)));
        Assert.Equal(4, await PointsAsync(arena, a));
        Assert.False(await _db.ScalarAsync<bool>(
            "select waiting from public.chess_tournament_players where tournament_id = @t and user_id = @u", ("t", arena), ("u", b)));

        // The end: ranks, a duel medal for a, none counted as chess.
        await _db.ExecuteAsync("update public.chess_tournaments set ends_at = now() - interval '1 second' where id = @id", ("id", arena));
        await arenas.TickAsync(Ct);
        Assert.Equal("finished", await _db.ScalarAsync<string>("select status from public.chess_tournaments where id = @id", ("id", arena)));
        Assert.Equal(1, await _db.ScalarAsync<int>("select gold from public.chess_medals(@u, 'mind')", ("u", a)));
        Assert.Equal(0, await _db.ScalarAsync<int>("select gold from public.chess_medals(@u)", ("u", a)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where recipient_id = @u and type = 'mind_arena_medal'", ("u", a)));
    }
}
