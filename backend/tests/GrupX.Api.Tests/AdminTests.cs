using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Identity.Contracts;

namespace GrupX.Api.Tests;

public sealed class AdminTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private async Task<Guid> StaffAsync(string role)
    {
        var id = await _db.CreateUserAsync();
        await _db.MakeStaffAsync(id, role);
        return id;
    }

    private static Uri Suspension(Guid id) => new($"/admin/users/{id}/suspension", UriKind.Relative);

    [Fact]
    public async Task Non_staff_cannot_list_users()
    {
        var user = await _db.CreateUserAsync();

        var response = await factory.ClientFor(user).GetAsync(new Uri("/admin/users", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Support_can_search_users_by_username_and_see_email()
    {
        var support = await StaffAsync("support");
        var username = $"ara_{Guid.NewGuid():N}"[..20];
        var target = await _db.CreateUserAsync(username);

        var page = await factory.ClientFor(support)
            .GetFromJsonAsync<PagedResult<AdminUserSummary>>($"/admin/users?q={username}", Ct);

        var found = Assert.Single(page!.Items);
        Assert.Equal(target, found.Id);
        Assert.Equal($"{target:N}@test.local", found.Email);
    }

    [Fact]
    public async Task Search_treats_wildcards_literally()
    {
        var support = await StaffAsync("support");
        await _db.CreateUserAsync();

        var page = await factory.ClientFor(support)
            .GetFromJsonAsync<PagedResult<AdminUserSummary>>("/admin/users?q=%25", Ct);

        Assert.Empty(page!.Items);
    }

    [Fact]
    public async Task Status_filter_uses_effective_status()
    {
        var support = await StaffAsync("support");
        var username = $"durum_{Guid.NewGuid():N}"[..20];
        var target = await _db.CreateUserAsync(username);
        await _db.ExecuteAsync(
            "update public.account_status set status = 'suspended', suspension_reason = 'x', suspended_until = now() + interval '1 day' where user_id = @id",
            ("id", target));
        var client = factory.ClientFor(support);

        var suspended = await client.GetFromJsonAsync<PagedResult<AdminUserSummary>>($"/admin/users?q={username}&status=suspended", Ct);
        var active = await client.GetFromJsonAsync<PagedResult<AdminUserSummary>>($"/admin/users?q={username}&status=active", Ct);

        Assert.Single(suspended!.Items);
        Assert.Empty(active!.Items);

        // Once the suspension end passes, the user counts as active again.
        await _db.ExecuteAsync("update public.account_status set suspended_until = now() - interval '1 minute' where user_id = @id", ("id", target));
        var expired = await client.GetFromJsonAsync<PagedResult<AdminUserSummary>>($"/admin/users?q={username}&status=active", Ct);
        Assert.Equal("active", Assert.Single(expired!.Items).Status);
    }

    [Fact]
    public async Task Invalid_status_filter_is_400()
    {
        var support = await StaffAsync("support");

        var response = await factory.ClientFor(support).GetAsync(new Uri("/admin/users?status=deleted", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Stats_add_up_and_count_suspensions()
    {
        var support = await StaffAsync("support");
        var target = await _db.CreateUserAsync();
        await _db.ExecuteAsync(
            "update public.account_status set status = 'suspended', suspension_reason = 'x' where user_id = @id", ("id", target));

        var stats = await factory.ClientFor(support).GetFromJsonAsync<AdminUserStats>("/admin/users/stats", Ct);

        Assert.True(stats!.Suspended >= 1);
        Assert.Equal(stats.Total, stats.Active + stats.Suspended + stats.PendingDeletion);
    }

    [Fact]
    public async Task Non_staff_cannot_read_stats()
    {
        var user = await _db.CreateUserAsync();

        var response = await factory.ClientFor(user).GetAsync(new Uri("/admin/users/stats", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Support_cannot_suspend()
    {
        var support = await StaffAsync("support");
        var target = await _db.CreateUserAsync();

        var response = await factory.ClientFor(support)
            .PostAsJsonAsync(Suspension(target), new SuspendUserRequest("Spam", null), Ct);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Moderator_suspends_and_unsuspends_with_audit()
    {
        var moderator = await StaffAsync("moderator");
        var target = await _db.CreateUserAsync();
        var client = factory.ClientFor(moderator);
        var until = DateTimeOffset.UtcNow.AddDays(7);

        var suspend = await client.PostAsJsonAsync(Suspension(target), new SuspendUserRequest("  Taciz  ", until), Ct);

        suspend.EnsureSuccessStatusCode();
        var state = await suspend.Content.ReadFromJsonAsync<AccountState>(Ct);
        Assert.Equal(AccountStatuses.Suspended, state?.Status);
        Assert.Equal("Taciz", state?.SuspensionReason);
        // No Supabase Auth ban: the person signs in to the locked screen with the reason (docs/ARCHITECTURE.md §3a).
        Assert.True(await _db.ScalarAsync<bool>("select banned_until is null from auth.users where id = @id", ("id", target)));

        var detail = await client.GetFromJsonAsync<AdminUserDetail>($"/admin/users/{target}", Ct);
        Assert.Contains(detail!.History, h => h.Action == "user.suspended" && h.ActorId == moderator);
        Assert.Equal(new AdminTeammates(false, 0, 0, 0), detail.Teammates);

        var unsuspend = await client.DeleteAsync(Suspension(target), Ct);

        unsuspend.EnsureSuccessStatusCode();
        Assert.Equal(AccountStatuses.Active, (await unsuspend.Content.ReadFromJsonAsync<AccountState>(Ct))?.Status);
        Assert.True(await _db.ScalarAsync<bool>("select banned_until is null from auth.users where id = @id", ("id", target)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'user.unsuspended' and target_id = @id",
            ("id", target.ToString())));
    }

    [Fact]
    public async Task A_suspended_person_reads_the_reason_but_an_earlier_token_does_nothing_else()
    {
        var moderator = await StaffAsync("moderator");
        var target = await _db.CreateUserAsync();
        (await factory.ClientFor(moderator).PostAsJsonAsync(
            Suspension(target), new SuspendUserRequest("Spam", DateTimeOffset.UtcNow.AddDays(3)), Ct)).EnsureSuccessStatusCode();

        // This token predates the suspension and still says `authenticated` (docs/ARCHITECTURE.md §3a).
        var own = factory.ClientFor(target);
        Assert.Equal(HttpStatusCode.Forbidden, (await own.PostAsync(new Uri("/account/deletion", UriKind.Relative), null, Ct)).StatusCode);
        var state = await own.GetFromJsonAsync<AccountState>(new Uri("/account", UriKind.Relative), Ct);
        Assert.Equal("Spam", state?.SuspensionReason);
    }

    [Fact]
    public async Task Staff_members_cannot_be_suspended()
    {
        var admin = await StaffAsync("admin");
        var otherStaff = await StaffAsync("support");

        var response = await factory.ClientFor(admin)
            .PostAsJsonAsync(Suspension(otherStaff), new SuspendUserRequest("Test", null), Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public async Task Suspension_requires_a_reason(string reason)
    {
        var admin = await StaffAsync("admin");
        var target = await _db.CreateUserAsync();

        var response = await factory.ClientFor(admin)
            .PostAsJsonAsync(Suspension(target), new SuspendUserRequest(reason, null), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Suspension_end_must_be_in_the_future()
    {
        var admin = await StaffAsync("admin");
        var target = await _db.CreateUserAsync();

        var response = await factory.ClientFor(admin)
            .PostAsJsonAsync(Suspension(target), new SuspendUserRequest("Spam", DateTimeOffset.UtcNow.AddDays(-1)), Ct);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Unknown_user_detail_is_404()
    {
        var support = await StaffAsync("support");

        var response = await factory.ClientFor(support).GetAsync(new Uri($"/admin/users/{Guid.NewGuid()}", UriKind.Relative), Ct);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }
}
