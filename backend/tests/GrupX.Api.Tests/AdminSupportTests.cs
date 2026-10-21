using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;

namespace GrupX.Api.Tests;

public sealed class AdminSupportTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private async Task<Guid> StaffAsync(string role)
    {
        var id = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    /// <summary>Opens a ticket the way the app does: the RPC under the user's claims (RLS-free here, triggers on).</summary>
    private async Task<(Guid User, Guid Ticket)> TicketAsync(string kind = "problem")
    {
        var user = await _db.CreateUserAsync($"u_{Guid.NewGuid():N}"[..20]);
        var ticket = Guid.NewGuid();
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @user::text)::text, true);
            select public.create_support_ticket(@ticket, @kind, 'Kapak yüklenmiyor', 'Hata veriyor.');
            """,
            ("user", user), ("ticket", ticket), ("kind", kind));
        return (user, ticket);
    }

    private Task<string?> StatusAsync(Guid ticket) =>
        _db.ScalarAsync<string>("select status from public.support_tickets where id = @id", ("id", ticket));

    [Fact]
    public async Task Only_platform_staff_see_tickets()
    {
        var user = await _db.CreateUserAsync();

        var response = await factory.ClientFor(user).GetAsync(Path("/admin/support/tickets"), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Support_lists_tickets_waiting_for_a_reply_first_and_opens_the_conversation()
    {
        var support = await StaffAsync("support");
        var (user, ticket) = await TicketAsync("request");

        var stats = await factory.ClientFor(support).GetFromJsonAsync<AdminSupportStats>("/admin/support/stats", Ct);
        Assert.True(stats!.OpenRequests >= 1 && stats.AwaitingReply >= 1);

        var page = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminTicketSummary>>(
            "/admin/support/tickets?kind=request&status=open", Ct);
        var found = Assert.Single(page!.Items, t => t.Id == ticket);
        Assert.Equal(("user", 1), (found.LastMessageBy, found.MessageCount));

        var detail = await factory.ClientFor(support).GetFromJsonAsync<AdminTicketDetail>($"/admin/support/tickets/{ticket}", Ct);
        Assert.Equal(user, detail!.Ticket.UserId);
        Assert.Equal("Hata veriyor.", Assert.Single(detail.Messages).Body);
        Assert.Equal($"{user:N}@test.local", detail.Email);

        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(support).GetAsync(Path("/admin/support/tickets?kind=bug"), Ct)).StatusCode);
    }

    [Fact]
    public async Task Staff_reply_moves_the_ticket_forward_and_is_audited()
    {
        var moderator = await StaffAsync("moderator");
        var (_, ticket) = await TicketAsync();

        var reply = await factory.ClientFor(moderator).PostAsJsonAsync(
            Path($"/admin/support/tickets/{ticket}/messages"), new SupportReplyRequest("İnceliyoruz, teşekkürler."), Ct);

        Assert.Equal(HttpStatusCode.NoContent, reply.StatusCode);
        Assert.Equal("in_progress", await StatusAsync(ticket));
        Assert.Equal(moderator, await _db.ScalarAsync<Guid>(
            "select author_id from public.support_messages where ticket_id = @id and author_kind = 'staff'", ("id", ticket)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'support.replied' and target_id = @id", ("id", ticket.ToString())));
        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(moderator).PostAsJsonAsync(
            Path($"/admin/support/tickets/{ticket}/messages"), new SupportReplyRequest("  "), Ct)).StatusCode);
    }

    [Fact]
    public async Task Staff_change_the_status_and_closed_tickets_take_no_reply()
    {
        var admin = await StaffAsync("admin");
        var (_, ticket) = await TicketAsync("suggestion");
        var client = factory.ClientFor(admin);
        var status = Path($"/admin/support/tickets/{ticket}/status");

        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync(status, new SupportStatusRequest("done"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await client.PutAsJsonAsync(
            Path($"/admin/support/tickets/{Guid.NewGuid()}/status"), new SupportStatusRequest("closed"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await client.PutAsJsonAsync(status, new SupportStatusRequest("closed"), Ct)).StatusCode);

        Assert.Equal("closed", await StatusAsync(ticket));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'support.status_changed' and target_id = @id", ("id", ticket.ToString())));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await client.PostAsJsonAsync(
            Path($"/admin/support/tickets/{ticket}/messages"), new SupportReplyRequest("Ek bilgi"), Ct)).StatusCode);
    }
}
