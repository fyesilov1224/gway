using System.Net.Http.Json;
using Gway.Modules.Admin;
using Gway.Modules.Events;
using Gway.Modules.Groups;

namespace Gway.Api.Tests;

/// <summary>Faz 18d: the exploration map's count on the admin user page (docs/ARCHITECTURE.md §3d, Keşif haritam).</summary>
public sealed class ExplorationTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    [Fact]
    public async Task The_admin_user_page_counts_the_provinces_attended()
    {
        var (owner, member, admin) = (await _db.CreateUserAsync(Unique("x_")), await _db.CreateUserAsync(Unique("x_")), await _db.CreateUserAsync(Unique("x_")));
        await _db.MakeStaffAsync(admin, "admin");
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            new Uri("/groups", UriKind.Relative), new CreateGroupRequest(Unique("g_"), "Gezi Kulübü", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        (await factory.ClientFor(member).PostAsync(new Uri($"/groups/{group}/join", UriKind.Relative), null, Ct)).EnsureSuccessStatusCode();

        // Bodrum (Muğla) and Kızılay (Ankara).
        var events = new List<Guid>();
        foreach (var point in new[] { new MeetingPoint(37.035, 27.43), new MeetingPoint(39.92, 32.854) })
        {
            var response = await factory.ClientFor(owner).PostAsJsonAsync(new Uri($"/groups/{group}/events", UriKind.Relative),
                new EventRequest("Gezi", "", DateTimeOffset.UtcNow.AddDays(1), null, "Buluşma", null, null, null, null, null, null, Meeting: point), Ct);
            response.EnsureSuccessStatusCode();
            var ev = (await response.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
            (await factory.ClientFor(member).PostAsync(new Uri($"/events/{ev}/attendance", UriKind.Relative), null, Ct)).EnsureSuccessStatusCode();
            events.Add(ev);
        }
        Assert.Equal(48, await _db.ScalarAsync<short>("select province from public.events where id = @e", ("e", events[0])));

        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '2 days' where id = any(@ids)", ("ids", events.ToArray()));
        var detail = await factory.ClientFor(admin).GetFromJsonAsync<AdminUserDetail>($"/admin/users/{member}", Ct);
        Assert.Equal(2, detail!.Contributions.ExploredProvinces);
    }
}
