using System.Net;
using System.Net.Http.Json;
using Gway.Modules.Admin;

namespace Gway.Api.Tests;

[Collection("Billing")]
public sealed class LegalTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    // distance_sales is shared seed data the billing tests rely on; this test publishes versions to it, so it
    // records the starting high-water mark and deletes everything it added afterwards.
    private int _baseline;

    public async ValueTask InitializeAsync()
    {
        await _db.InitializeAsync();
        _baseline = await _db.ScalarAsync<int>("select coalesce(max(version), 0) from public.legal_documents where kind = 'distance_sales'");
    }

    public async ValueTask DisposeAsync()
    {
        await _db.ExecuteWithoutTriggersAsync(
            """
            delete from public.consents where kind = 'distance_sales' and version > @b;
            delete from public.legal_documents where kind = 'distance_sales' and version > @b;
            """, ("b", _baseline));
        await _db.DisposeAsync();
    }

    private static string Unique(string p) => $"{p}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    [Fact]
    public async Task An_admin_publishes_edits_and_freezes_legal_versions()
    {
        var (admin, support, member) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")),
            await _db.CreateUserAsync(Unique("m_")));
        await _db.MakeStaffAsync(admin, "admin");
        await _db.MakeStaffAsync(support, "support");
        var adminClient = factory.ClientFor(admin);

        // Only an admin may even look at legal texts.
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(support).GetAsync(Path("/admin/legal"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(member).GetAsync(Path("/admin/legal"), Ct)).StatusCode);

        // distance_sales has no seeded version; publish the first one.
        var publish = await adminClient.PostAsJsonAsync(Path("/admin/legal/distance_sales"),
            new LegalVersionRequest("Mesafeli Satış Sözleşmesi", new string('x', 50), null), Ct);
        publish.EnsureSuccessStatusCode();
        var v = await publish.Content.ReadFromJsonAsync<int>(Ct);

        // It appears in the list as current (the newest published version), with its audience derived from the kind.
        var kinds = await adminClient.GetFromJsonAsync<List<AdminLegalKind>>(Path("/admin/legal"), Ct);
        var sales = kinds!.Single(k => k.Kind == "distance_sales");
        Assert.Equal("purchase", sales.Audience);
        var row = sales.Versions.Single(x => x.Version == v);
        Assert.True(row.IsCurrent);
        Assert.Equal(0, row.ConsentCount);

        // Editing an un-consented version is allowed.
        Assert.Equal(HttpStatusCode.NoContent, (await adminClient.PutAsJsonAsync(Path($"/admin/legal/distance_sales/{v}"),
            new LegalVersionRequest("Mesafeli Satış Sözleşmesi düzeltme", new string('y', 60), null), Ct)).StatusCode);
        var doc = await adminClient.GetFromJsonAsync<AdminLegalDocument>(Path($"/admin/legal/distance_sales/{v}"), Ct);
        Assert.Equal("Mesafeli Satış Sözleşmesi düzeltme", doc!.Title);

        // Once someone consents, the version is frozen: no edit, no delete.
        await _db.ExecuteAsync("insert into public.consents (user_id, kind, version) values (@u, 'distance_sales', @v)",
            ("u", member), ("v", v));
        var edit = await adminClient.PutAsJsonAsync(Path($"/admin/legal/distance_sales/{v}"),
            new LegalVersionRequest("Değişiklik", new string('z', 60), null), Ct);
        Assert.Equal(HttpStatusCode.Conflict, edit.StatusCode);
        Assert.Contains("admin.legal_consented", await edit.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.Equal(HttpStatusCode.Conflict, (await adminClient.DeleteAsync(Path($"/admin/legal/distance_sales/{v}"), Ct)).StatusCode);

        // The way forward is a new version (max+1); the unconsented new one can be deleted.
        var next = await adminClient.PostAsJsonAsync(Path("/admin/legal/distance_sales"),
            new LegalVersionRequest("Mesafeli Satış Sözleşmesi v-sonraki", new string('x', 60), null), Ct);
        var vNext = await next.Content.ReadFromJsonAsync<int>(Ct);
        Assert.Equal(v + 1, vNext);
        Assert.Equal(HttpStatusCode.NoContent, (await adminClient.DeleteAsync(Path($"/admin/legal/distance_sales/{vNext}"), Ct)).StatusCode);

        // Validation and audit trail.
        Assert.Equal(HttpStatusCode.BadRequest, (await adminClient.PostAsJsonAsync(Path("/admin/legal/distance_sales"),
            new LegalVersionRequest("ok", "kısa", null), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await adminClient.PostAsJsonAsync(Path("/admin/legal/made_up_kind"),
            new LegalVersionRequest("Başlık", new string('x', 40), null), Ct)).StatusCode);
        Assert.Equal(2L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'legal.published' and actor_id = @id", ("id", admin)));
    }

    [Fact]
    public async Task A_future_published_version_is_a_draft_until_its_time()
    {
        var admin = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(admin, "admin");
        var client = factory.ClientFor(admin);

        var vPast = await (await client.PostAsJsonAsync(Path("/admin/legal/distance_sales"),
            new LegalVersionRequest("Yürürlükteki", new string('a', 40), DateTimeOffset.UtcNow.AddDays(-1)), Ct))
            .Content.ReadFromJsonAsync<int>(Ct);
        var vFuture = await (await client.PostAsJsonAsync(Path("/admin/legal/distance_sales"),
            new LegalVersionRequest("Gelecek sürüm", new string('b', 40), DateTimeOffset.UtcNow.AddDays(30)), Ct))
            .Content.ReadFromJsonAsync<int>(Ct);

        var sales = (await client.GetFromJsonAsync<List<AdminLegalKind>>(Path("/admin/legal"), Ct))!.Single(k => k.Kind == "distance_sales");
        var future = sales.Versions.Single(x => x.Version == vFuture);
        Assert.True(future.IsDraft);
        Assert.False(future.IsCurrent, "a future version is not yet current");
        Assert.True(sales.Versions.Single(x => x.Version == vPast).IsCurrent, "the newest published version is current");
    }
}
