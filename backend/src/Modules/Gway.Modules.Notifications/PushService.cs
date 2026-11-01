using Gway.Modules.Notifications.Contracts;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Gway.Modules.Notifications;

public static class NotificationsModule
{
    /// <summary>Push delivery of the notification rows (docs/ARCHITECTURE.md §3c, Push). The rows themselves come from triggers.</summary>
    public static IServiceCollection AddNotificationsModule(this IServiceCollection services)
    {
        services.AddOptions<PushOptions>().BindConfiguration(PushOptions.Section);
        services.TryAddSingleton(TimeProvider.System);
        services.AddHttpClient<IPushSender, FcmClient>(http => http.Timeout = TimeSpan.FromSeconds(10));
        services.AddSingleton<PushService>();
        services.AddSingleton<INotificationsAdministration, NotificationsAdministration>();
        services.AddHostedService<PushDispatcher>();
        return services;
    }
}

internal sealed partial class PushService(NpgsqlDataSource db, IPushSender sender, ILogger<PushService> log)
{
    /// <summary>Older notifications are not pushed any more; they are only in the app.</summary>
    private static readonly TimeSpan MaxAge = TimeSpan.FromMinutes(15);

    /// <summary>
    /// Marks waiting notifications as pushed, then sends them to the recipients' devices: each goes at most once.
    /// Returns how many messages reached a device.
    /// </summary>
    public async Task<int> DispatchAsync(CancellationToken ct)
    {
        if (!sender.IsConfigured) return 0;

        var batch = await ClaimAsync(ct);
        if (batch.Count == 0) return 0;
        var devices = await DevicesAsync([.. batch.Select(n => n.RecipientId).Distinct()], ct);

        var deliveries = new Dictionary<long, int>();
        var gone = new List<string>();
        foreach (var n in batch)
        {
            if (!devices.TryGetValue(n.RecipientId, out var tokens)) continue;
            var message = PushTexts.For(n);
            foreach (var token in tokens)
            {
                PushResult result;
                try
                {
                    result = await sender.SendAsync(token, message, ct);
                }
                catch (HttpRequestException ex)
                {
                    LogSendFailed(log, ex, n.Id);
                    continue;
                }
                if (result == PushResult.Sent) deliveries[n.Id] = deliveries.GetValueOrDefault(n.Id) + 1;
                else if (result == PushResult.Unregistered) gone.Add(token);
                else LogRejected(log, n.Id);
            }
        }

        if (deliveries.Count > 0)
        {
            await using var cmd = db.CreateCommand(
                "update public.notifications n set push_deliveries = d.devices from unnest(@ids, @devices) as d(id, devices) where n.id = d.id");
            cmd.Parameters.AddWithValue("ids", deliveries.Keys.ToArray());
            cmd.Parameters.AddWithValue("devices", deliveries.Values.ToArray());
            await cmd.ExecuteNonQueryAsync(ct);
        }
        if (gone.Count > 0)
        {
            await using var cmd = db.CreateCommand("delete from public.push_devices where token = any(@tokens)");
            cmd.Parameters.AddWithValue("tokens", gone.ToArray());
            await cmd.ExecuteNonQueryAsync(ct);
        }
        return deliveries.Values.Sum();
    }

    /// <summary>A device whose app was not opened this long is dropped; opening the app registers it again.</summary>
    private static readonly TimeSpan DeviceMaxIdle = TimeSpan.FromDays(60);

    /// <summary>How often each token is probed.</summary>
    private static readonly TimeSpan ProbeEvery = TimeSpan.FromDays(1);

    /// <summary>
    /// Removes devices that no longer receive push: not opened for <see cref="DeviceMaxIdle"/>, or whose token FCM
    /// no longer knows (app removed, data cleared, signed out offline). Probes at most 200 tokens a run.
    /// Returns how many devices were removed (docs/ARCHITECTURE.md §3c, Cihaz kaydının temizliği).
    /// </summary>
    public async Task<int> SweepDevicesAsync(CancellationToken ct)
    {
        if (!sender.IsConfigured) return 0;

        int removed;
        await using (var idle = db.CreateCommand("delete from public.push_devices where updated_at < now() - @idle"))
        {
            idle.Parameters.AddWithValue("idle", DeviceMaxIdle);
            removed = await idle.ExecuteNonQueryAsync(ct);
        }

        var tokens = new List<string>();
        await using (var due = db.CreateCommand(
            """
            select token from public.push_devices
            where last_checked_at is null or last_checked_at < now() - @every
            order by last_checked_at nulls first
            limit 200
            """))
        {
            due.Parameters.AddWithValue("every", ProbeEvery);
            await using var r = await due.ExecuteReaderAsync(ct);
            while (await r.ReadAsync(ct)) tokens.Add(r.GetString(0));
        }

        var alive = new List<string>();
        var gone = new List<string>();
        foreach (var token in tokens)
        {
            PushResult result;
            try
            {
                result = await sender.ProbeAsync(token, ct);
            }
            catch (HttpRequestException ex)
            {
                LogProbeFailed(log, ex);
                continue;
            }
            if (result == PushResult.Unregistered) gone.Add(token);
            else if (result == PushResult.Sent) alive.Add(token);
        }

        if (alive.Count > 0)
        {
            await using var cmd = db.CreateCommand("update public.push_devices set last_checked_at = now() where token = any(@tokens)");
            cmd.Parameters.AddWithValue("tokens", alive.ToArray());
            await cmd.ExecuteNonQueryAsync(ct);
        }
        if (gone.Count > 0)
        {
            await using var cmd = db.CreateCommand("delete from public.push_devices where token = any(@tokens)");
            cmd.Parameters.AddWithValue("tokens", gone.ToArray());
            removed += await cmd.ExecuteNonQueryAsync(ct);
        }
        return removed;
    }

    private async Task<List<PendingPush>> ClaimAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        await using (var stale = new NpgsqlCommand(
            "update public.notifications set pushed_at = now() where pushed_at is null and created_at <= now() - @age", conn, tx))
        {
            stale.Parameters.AddWithValue("age", MaxAge);
            await stale.ExecuteNonQueryAsync(ct);
        }

        var batch = new List<PendingPush>();
        await using (var cmd = new NpgsqlCommand(
            """
            with due as (
              select id from public.notifications
              where pushed_at is null
              order by id
              limit 200
              for update skip locked
            ), marked as (
              update public.notifications n set pushed_at = now() from due where n.id = due.id returning n.*
            )
            select m.id, m.recipient_id, m.type, m.created_at, a.username,
                   (select left(c.body, 120) from public.comments c where c.id = m.comment_id),
                   m.live_id,
                   (select b.title from public.live_broadcasts b where b.id = m.live_id),
                   (select b.scheduled_at from public.live_broadcasts b where b.id = m.live_id),
                   (select e.title from public.events e where e.id = m.event_id),
                   (select e.starts_at from public.events e where e.id = m.event_id),
                   (select g.name from public.groups g where g.id = m.group_id),
                   (select s.type from public.sanctions s where s.id = m.sanction_id),
                   (select g.title from public.goals g where g.id = m.goal_id)
            from marked m
            join public.profiles a on a.id = m.actor_id
            order by m.id
            """, conn, tx))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct))
            {
                batch.Add(new PendingPush(
                    r.GetInt64(0), r.GetGuid(1), r.GetString(2), r.GetFieldValue<DateTimeOffset>(3), r.GetString(4),
                    r.IsDBNull(5) ? null : r.GetString(5),
                    r.IsDBNull(6) ? null : r.GetGuid(6),
                    r.IsDBNull(7) ? null : r.GetString(7),
                    r.IsDBNull(8) ? null : r.GetFieldValue<DateTimeOffset>(8),
                    r.IsDBNull(9) ? null : r.GetString(9),
                    r.IsDBNull(10) ? null : r.GetFieldValue<DateTimeOffset>(10),
                    r.IsDBNull(11) ? null : r.GetString(11),
                    r.IsDBNull(12) ? null : r.GetString(12),
                    r.IsDBNull(13) ? null : r.GetString(13)));
            }
        }
        await tx.CommitAsync(ct);
        return batch;
    }

    private async Task<Dictionary<Guid, List<string>>> DevicesAsync(Guid[] recipients, CancellationToken ct)
    {
        var devices = new Dictionary<Guid, List<string>>();
        await using var cmd = db.CreateCommand("select user_id, token from public.push_devices where user_id = any(@ids)");
        cmd.Parameters.AddWithValue("ids", recipients);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        while (await r.ReadAsync(ct))
        {
            var user = r.GetGuid(0);
            if (!devices.TryGetValue(user, out var tokens)) devices[user] = tokens = [];
            tokens.Add(r.GetString(1));
        }
        return devices;
    }

    [LoggerMessage(Level = LogLevel.Warning, Message = "FCM rejected notification {NotificationId}; it stays in the app")]
    private static partial void LogRejected(ILogger logger, long notificationId);

    [LoggerMessage(Level = LogLevel.Warning, Message = "Could not push notification {NotificationId}; it stays in the app")]
    private static partial void LogSendFailed(ILogger logger, Exception ex, long notificationId);

    [LoggerMessage(Level = LogLevel.Warning, Message = "Could not probe a push token; it is tried again on the next sweep")]
    private static partial void LogProbeFailed(ILogger logger, Exception ex);
}

/// <summary>
/// Pushes new notifications every <c>Push:DispatchInterval</c> (default 5 seconds; zero turns it off) and sweeps the
/// device list every <c>Push:SweepInterval</c> (default 1 hour; zero turns the sweep off).
/// </summary>
internal sealed partial class PushDispatcher(PushService push, IConfiguration configuration, ILogger<PushDispatcher> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = configuration.GetValue("Push:DispatchInterval", TimeSpan.FromSeconds(5));
        if (interval <= TimeSpan.Zero) return;
        var sweepEvery = configuration.GetValue("Push:SweepInterval", TimeSpan.FromHours(1));
        var nextSweep = DateTimeOffset.UtcNow;

        using var timer = new PeriodicTimer(interval);
        do
        {
            // A database or FCM outage must not stop the API; the next run retries.
            try
            {
                await push.DispatchAsync(stoppingToken);
                if (sweepEvery > TimeSpan.Zero && DateTimeOffset.UtcNow >= nextSweep)
                {
                    nextSweep = DateTimeOffset.UtcNow + sweepEvery;
                    await push.SweepDevicesAsync(stoppingToken);
                }
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                LogRunFailed(logger, ex);
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    [LoggerMessage(Level = LogLevel.Error, Message = "Push dispatch failed; will retry on the next run")]
    private static partial void LogRunFailed(ILogger logger, Exception ex);
}
