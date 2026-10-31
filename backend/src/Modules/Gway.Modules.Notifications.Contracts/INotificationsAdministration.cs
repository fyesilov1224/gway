namespace Gway.Modules.Notifications.Contracts;

/// <summary>How many notifications of one type were created in the last 24 hours.</summary>
public sealed record NotificationTypeCount(string Type, int Count);

/// <summary>Push health for the admin panel (docs/ARCHITECTURE.md §3c, Admin). Counts only, no contents or tokens.</summary>
public sealed record PushStats(
    bool Configured,
    int AndroidDevices,
    int IosDevices,
    int WebDevices,
    int UsersWithDevice,
    int Created24h,
    int Delivered24h,
    int Deliveries24h,
    int Waiting,
    IReadOnlyList<NotificationTypeCount> ByType24h);

/// <summary>Read side of notifications for the platform team. Callers check platform staff roles first.</summary>
public interface INotificationsAdministration
{
    Task<PushStats> PushStatsAsync(CancellationToken ct);
}
