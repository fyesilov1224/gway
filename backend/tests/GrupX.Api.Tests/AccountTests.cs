using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Identity;
using GrupX.Modules.Identity.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace GrupX.Api.Tests;

public sealed class AccountTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    [Fact]
    public async Task New_account_is_active()
    {
        var user = await _db.CreateUserAsync();

        var state = await factory.ClientFor(user).GetFromJsonAsync<AccountState>("/account", Ct);

        Assert.Equal(AccountStatuses.Active, state?.Status);
    }

    [Fact]
    public async Task Deletion_request_schedules_purge_in_30_days_and_is_audited()
    {
        var user = await _db.CreateUserAsync("silinecek");
        var client = factory.ClientFor(user);

        var response = await client.PostAsync(new Uri("/account/deletion", UriKind.Relative), null, Ct);

        response.EnsureSuccessStatusCode();
        var state = await response.Content.ReadFromJsonAsync<AccountState>(Ct);
        Assert.Equal(AccountStatuses.PendingDeletion, state?.Status);
        Assert.InRange(state!.DeletionScheduledFor!.Value, DateTimeOffset.UtcNow.AddDays(29.9), DateTimeOffset.UtcNow.AddDays(30.1));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'account.deletion_requested' and target_id = @id",
            ("id", user.ToString())));

        var again = await client.PostAsync(new Uri("/account/deletion", UriKind.Relative), null, Ct);
        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
    }

    [Fact]
    public async Task Deletion_can_be_cancelled_once()
    {
        var user = await _db.CreateUserAsync();
        var client = factory.ClientFor(user);
        var uri = new Uri("/account/deletion", UriKind.Relative);
        (await client.PostAsync(uri, null, Ct)).EnsureSuccessStatusCode();

        var cancel = await client.DeleteAsync(uri, Ct);
        var again = await client.DeleteAsync(uri, Ct);

        cancel.EnsureSuccessStatusCode();
        Assert.Equal(AccountStatuses.Active, (await cancel.Content.ReadFromJsonAsync<AccountState>(Ct))?.Status);
        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'account.deletion_cancelled' and target_id = @id",
            ("id", user.ToString())));
    }

    [Fact]
    public async Task Suspended_account_cannot_request_deletion()
    {
        var user = await _db.CreateUserAsync();
        await _db.ExecuteAsync(
            "update public.account_status set status = 'suspended', suspension_reason = 'test' where user_id = @id", ("id", user));

        var response = await factory.ClientFor(user).PostAsync(new Uri("/account/deletion", UriKind.Relative), null, Ct);

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
    }

    [Fact]
    public async Task Purge_deletes_only_due_accounts_with_their_files()
    {
        var due = await _db.CreateUserAsync("vadesi.doldu");
        var notDue = await _db.CreateUserAsync("vadesi.dolmadi");
        const string schedule =
            """
            update public.account_status
            set status = 'pending_deletion', deletion_requested_at = now() - interval '31 days', deletion_scheduled_for = now() + @offset
            where user_id = @id
            """;
        await _db.ExecuteAsync(schedule, ("id", due), ("offset", TimeSpan.FromMinutes(-1)));
        await _db.ExecuteAsync(schedule, ("id", notDue), ("offset", TimeSpan.FromDays(1)));

        var purger = factory.Services.GetRequiredService<AccountPurger>();
        await purger.PurgeDueAsync(Ct);

        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from auth.users where id = @id", ("id", due)));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.profiles where id = @id", ("id", due)));
        Assert.Equal(1L, await _db.ScalarAsync<long>("select count(*) from auth.users where id = @id", ("id", notDue)));
        Assert.Contains(("avatars", due.ToString()), factory.Storage.DeletedFolders);
        Assert.Contains(("covers", due.ToString()), factory.Storage.DeletedFolders);
        Assert.Contains(("match-photos", due.ToString()), factory.Storage.DeletedFolders);
        Assert.DoesNotContain(factory.Storage.DeletedFolders, f => f.Folder == notDue.ToString());
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'account.purged' and actor_kind = 'system' and target_id = @id",
            ("id", due.ToString())));
    }
}
