using GrupX.SharedKernel.Auditing;
using GrupX.SharedKernel.Supabase;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace GrupX.Modules.Identity;

/// <summary>Permanently deletes accounts whose 30-day deletion grace period has ended.</summary>
internal sealed partial class AccountPurger(NpgsqlDataSource db, ISupabaseStorage storage, ILogger<AccountPurger> logger)
{
    private const int BatchSize = 100;

    public async Task<int> PurgeDueAsync(CancellationToken ct)
    {
        var due = new List<Guid>();
        await using (var cmd = db.CreateCommand(
            $"""
            select user_id from public.account_status
            where status = 'pending_deletion' and deletion_scheduled_for <= now()
            order by deletion_scheduled_for
            limit {BatchSize}
            """))
        await using (var reader = await cmd.ExecuteReaderAsync(ct))
        {
            while (await reader.ReadAsync(ct)) due.Add(reader.GetGuid(0));
        }

        var purged = 0;
        foreach (var userId in due)
        {
            try
            {
                if (await PurgeAsync(userId, ct)) purged++;
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogPurgeFailed(logger, ex, userId);
            }
        }
        return purged;
    }

    private async Task<bool> PurgeAsync(Guid userId, CancellationToken ct)
    {
        // Files first: if this fails the account stays pending and is retried next run.
        await storage.DeleteFolderAsync("avatars", userId.ToString(), ct);
        await storage.DeleteFolderAsync("covers", userId.ToString(), ct);
        await storage.DeleteFolderAsync("support-attachments", userId.ToString(), ct);
        await storage.DeleteFolderAsync("media", userId.ToString(), ct);
        await storage.DeleteFolderAsync("match-photos", userId.ToString(), ct);

        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        // Re-check under lock: the user may have cancelled meanwhile.
        await using (var check = new NpgsqlCommand(
            """
            select 1 from public.account_status
            where user_id = @id and status = 'pending_deletion' and deletion_scheduled_for <= now()
            for update
            """, conn, tx))
        {
            check.Parameters.AddWithValue("id", userId);
            if (await check.ExecuteScalarAsync(ct) is null) return false;
        }

        // Cascades to account_status, consents, profiles, profile_interests and support tickets.
        await using (var delete = new NpgsqlCommand("delete from auth.users where id = @id", conn, tx))
        {
            delete.Parameters.AddWithValue("id", userId);
            await delete.ExecuteNonQueryAsync(ct);
        }

        await AuditLog.AppendAsync(conn, tx,
            new AuditEntry(null, AuditActor.System, "account.purged", "user", userId.ToString()), ct);
        await tx.CommitAsync(ct);
        return true;
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Purging account {UserId} failed; will retry")]
    private static partial void LogPurgeFailed(ILogger logger, Exception ex, Guid userId);
}

internal sealed partial class AccountPurgeService(
    AccountPurger purger, SecurityService security, IConfiguration configuration, ILogger<AccountPurgeService> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Identity:PurgeInterval", TimeSpan.FromHours(1));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database outage must not stop the API; the next run retries.
            try
            {
                await purger.PurgeDueAsync(stoppingToken);
                await security.PurgeExpiredAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Account purge run failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
