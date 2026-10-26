using GrupX.Modules.Notifications.Contracts;
using Npgsql;

namespace GrupX.Modules.Notifications;

internal sealed class NotificationsAdministration(NpgsqlDataSource db, IPushSender sender) : INotificationsAdministration
{
    public async Task<PushStats> PushStatsAsync(CancellationToken ct)
    {
        await using var conn = await db.OpenConnectionAsync(ct);
        int[] counts;
        await using (var cmd = new NpgsqlCommand(
            """
            select
              (select count(*)::int from public.push_devices where platform = 'android'),
              (select count(*)::int from public.push_devices where platform = 'ios'),
              (select count(*)::int from public.push_devices where platform = 'web'),
              (select count(distinct user_id)::int from public.push_devices),
              (select count(*)::int from public.notifications where created_at > now() - interval '24 hours'),
              (select count(*)::int from public.notifications where created_at > now() - interval '24 hours' and push_deliveries > 0),
              (select coalesce(sum(push_deliveries), 0)::int from public.notifications where created_at > now() - interval '24 hours'),
              (select count(*)::int from public.notifications where pushed_at is null and created_at > now() - interval '15 minutes')
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            await r.ReadAsync(ct);
            counts = [.. Enumerable.Range(0, 8).Select(r.GetInt32)];
        }

        var byType = new List<NotificationTypeCount>();
        await using (var cmd = new NpgsqlCommand(
            """
            select type, count(*)::int from public.notifications
            where created_at > now() - interval '24 hours'
            group by type order by count(*) desc, type
            """, conn))
        await using (var r = await cmd.ExecuteReaderAsync(ct))
        {
            while (await r.ReadAsync(ct)) byType.Add(new NotificationTypeCount(r.GetString(0), r.GetInt32(1)));
        }

        return new PushStats(sender.IsConfigured, counts[0], counts[1], counts[2], counts[3], counts[4], counts[5], counts[6], counts[7], byType);
    }
}
