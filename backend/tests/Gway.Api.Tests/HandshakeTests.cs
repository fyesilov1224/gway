using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Events;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

/// <summary>Faz 18e: El sıkış at an event (docs/ARCHITECTURE.md §3d, El sıkış).</summary>
public sealed class HandshakeTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<HandshakeCode> CodeAsync(Guid user, Guid ev)
    {
        var response = await factory.ClientFor(user).PostAsync(Path($"/events/{ev}/handshake-code"), null, Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<HandshakeCode>(Ct))!;
    }

    private Task<HttpResponseMessage> ShakeAsync(Guid user, Guid ev, string code) =>
        factory.ClientFor(user).PostAsJsonAsync(Path($"/events/{ev}/handshakes"), new HandshakeRequest(code), Ct);

    [Fact]
    public async Task People_going_meet_with_each_others_code()
    {
        var (owner, a, b, c) = (await User(), await User(), await User(), await User());
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Tanışma Kulübü", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        foreach (var user in new[] { a, b, c })
            (await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        var response = await factory.ClientFor(owner).PostAsJsonAsync(Path($"/groups/{group}/events"),
            new EventRequest("Akşam yürüyüşü", "", DateTimeOffset.UtcNow.AddMinutes(30), null, "Sahil", null, null, null, null, null, null), Ct);
        response.EnsureSuccessStatusCode();
        var ev = (await response.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
        foreach (var user in new[] { a, b })
            (await factory.ClientFor(user).PostAsync(Path($"/events/{ev}/attendance"), null, Ct)).EnsureSuccessStatusCode();

        // Those who do not go get no code.
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(c).PostAsync(Path($"/events/{ev}/handshake-code"), null, Ct)).StatusCode);

        var code = await CodeAsync(a, ev);
        Assert.Matches("^[A-HJ-NP-Z2-9]{6}$", code.Code);
        Assert.Equal(code.Code, (await CodeAsync(a, ev)).Code);

        Assert.Equal(HttpStatusCode.BadRequest, (await ShakeAsync(a, ev, code.Code)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await ShakeAsync(b, ev, "AAAAAA")).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await ShakeAsync(b, ev, $"gway-handshake:{Guid.NewGuid()}:{code.Code}")).StatusCode);

        var met = await (await ShakeAsync(b, ev, $"gway-handshake:{ev}:{code.Code.ToLowerInvariant()}")).Content.ReadFromJsonAsync<HandshakeResult>(Ct);
        Assert.Equal(a, met!.Person.Id);
        Assert.False(met.AlreadyMet);
        var again = await (await ShakeAsync(b, ev, code.Code)).Content.ReadFromJsonAsync<HandshakeResult>(Ct);
        Assert.True(again!.AlreadyMet);

        Assert.Equal(1, await _db.ScalarAsync<long>("select count(*) from public.handshakes where event_id = @e", ("e", ev)));
        Assert.Equal(1, await _db.ScalarAsync<long>(
            "select count(*) from public.notifications where type = 'handshake' and recipient_id = @a and actor_id = @b", ("a", a), ("b", b)));

        var admin = await User();
        await _db.MakeStaffAsync(admin, "support");
        var detail = await factory.ClientFor(admin).GetFromJsonAsync<AdminUserDetail>($"/admin/users/{a}", Ct);
        Assert.Equal(1, detail!.Contributions.Handshakes);

        Task<Guid> User() => _db.CreateUserAsync(Unique("h_"));
    }
}
