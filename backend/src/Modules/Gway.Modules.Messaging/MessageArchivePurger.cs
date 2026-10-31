using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Gway.Modules.Messaging;

/// <summary>Deletes archived texts of deleted messages after 180 days (docs/ARCHITECTURE.md §3f, Mesaj kayıtları).</summary>
internal sealed partial class MessageArchivePurger(NpgsqlDataSource db, IConfiguration configuration, ILogger<MessageArchivePurger> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Messaging:ArchivePurgeInterval", TimeSpan.FromHours(1));
        if (interval <= TimeSpan.Zero) return;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database outage must not stop the API; the next run retries.
            try
            {
                await using var cmd = db.CreateCommand("select private.purge_message_archive()");
                await cmd.ExecuteScalarAsync(stoppingToken);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Message archive purge failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
