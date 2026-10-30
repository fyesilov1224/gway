using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Events;
using GrupX.Modules.Groups;

namespace GrupX.Api.Tests;

/// <summary>"Bu akşam boşum" and the small table (docs/ARCHITECTURE.md §3d, Faz 18g).</summary>
public sealed class TonightTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>The owner of a fresh group and <paramref name="members"/> members; everyone free tonight unless told otherwise.</summary>
    private async Task<Guid[]> PeopleAsync(int members, bool free = true)
    {
        var owner = await _db.CreateUserAsync(Unique("t_"));
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Akşam Yürüyüşü", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        var people = new List<Guid> { owner };
        for (var i = 0; i < members; i++)
        {
            var user = await _db.CreateUserAsync(Unique("t_"));
            (await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
            people.Add(user);
        }
        if (free)
            foreach (var p in people) await FreeAsync(p);
        return [.. people];
    }

    private Task FreeAsync(Guid user) =>
        _db.ExecuteAsync("insert into public.tonight_status (user_id) values (@u)", ("u", user));

    private Task<HttpResponseMessage> AnswerAsync(Guid user, Guid table, bool accept) =>
        factory.ClientFor(user).PostAsJsonAsync(Path($"/tonight/tables/{table}/answer"), new TonightAnswerRequest(accept), Ct);

    private Task<long> ChatMembersAsync(Guid table) =>
        _db.ScalarAsync<long>(
            "select count(*) from public.conversation_members m join public.conversations c on c.id = m.conversation_id where c.table_id = @t",
            ("t", table));

    [Fact]
    public async Task A_table_needs_the_founder_to_be_free()
    {
        var people = await PeopleAsync(3, free: false);

        var response = await factory.ClientFor(people[0]).PostAsync(Path("/tonight/tables"), null, Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("tonight.not_free", await response.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
    }

    [Fact]
    public async Task A_table_needs_two_free_people_besides_the_founder()
    {
        var people = await PeopleAsync(1);

        var response = await factory.ClientFor(people[0]).PostAsync(Path("/tonight/tables"), null, Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("tonight.not_enough_people", await response.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
    }

    [Fact]
    public async Task The_third_person_opens_the_chat_and_a_person_sits_at_one_table_an_evening()
    {
        var (founder, b, c, d) = await PeopleAsync(3) switch { var p => (p[0], p[1], p[2], p[3]) };

        var created = await factory.ClientFor(founder).PostAsync(Path("/tonight/tables"), null, Ct);
        created.EnsureSuccessStatusCode();
        var table = (await created.Content.ReadFromJsonAsync<CreatedTable>(Ct))!;
        Assert.Equal(3, table.Invited);
        Assert.Equal(HttpStatusCode.Conflict, (await factory.ClientFor(founder).PostAsync(Path("/tonight/tables"), null, Ct)).StatusCode);

        (await AnswerAsync(b, table.Id, accept: true)).EnsureSuccessStatusCode();
        Assert.Equal(0L, await ChatMembersAsync(table.Id));
        (await AnswerAsync(c, table.Id, accept: true)).EnsureSuccessStatusCode();
        Assert.Equal(3L, await ChatMembersAsync(table.Id));
        (await AnswerAsync(d, table.Id, accept: false)).EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.NotFound, (await AnswerAsync(d, table.Id, accept: true)).StatusCode);

        // b is at a table tonight: another founder's table cannot seat them.
        var others = await PeopleAsync(2);
        var otherGroup = await _db.ScalarAsync<Guid>("select group_id from public.group_members where user_id = @o", ("o", others[0]));
        (await factory.ClientFor(b).PostAsync(Path($"/groups/{otherGroup}/join"), null, Ct)).EnsureSuccessStatusCode();
        var second = await factory.ClientFor(others[0]).PostAsync(Path("/tonight/tables"), null, Ct);
        second.EnsureSuccessStatusCode();
        var secondId = (await second.Content.ReadFromJsonAsync<CreatedTable>(Ct))!.Id;
        Assert.Equal(0L, await _db.ScalarAsync<long>(
            "select count(*) from public.tonight_table_invites where table_id = @t and user_id = @b", ("t", secondId), ("b", b)));

        (await factory.ClientFor(b).DeleteAsync(Path($"/tonight/tables/{table.Id}/membership"), Ct)).EnsureSuccessStatusCode();
        Assert.Equal(2L, await ChatMembersAsync(table.Id));
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(b).DeleteAsync(Path($"/tonight/tables/{table.Id}/membership"), Ct)).StatusCode);
    }
}
