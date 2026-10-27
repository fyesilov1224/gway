import 'package:core/core.dart';

/// One measure over the range: its total, the previous range's, and both per bucket (oldest first).
class AdminMetric {
  const AdminMetric({
    required this.key,
    required this.current,
    required this.previous,
    required this.points,
    required this.previousPoints,
  });

  factory AdminMetric.fromJson(Map<String, Object?> j) => AdminMetric(
        key: j['key']! as String,
        current: j['current']! as int,
        previous: j['previous']! as int,
        points: [for (final p in j['points']! as List) p as int],
        previousPoints: [for (final p in j['previousPoints']! as List) p as int],
      );

  final String key;
  final int current;
  final int previous;
  final List<int> points;
  final List<int> previousPoints;

  /// The change against the previous range as a fraction (0.12 = %12); null when the previous range had none.
  double? get change => previous == 0 ? null : (current - previous) / previous;
}

/// What the platform holds right now.
class AdminSnapshot {
  const AdminSnapshot({
    required this.users,
    required this.groups,
    required this.openReports,
    required this.openTickets,
    required this.liveNow,
    required this.matchProfiles,
  });

  factory AdminSnapshot.fromJson(Map<String, Object?> j) => AdminSnapshot(
        users: j['users']! as int,
        groups: j['groups']! as int,
        openReports: j['openReports']! as int,
        openTickets: j['openTickets']! as int,
        liveNow: j['liveNow']! as int,
        matchProfiles: j['matchProfiles']! as int,
      );

  final int users;
  final int groups;
  final int openReports;
  final int openTickets;
  final int liveNow;
  final int matchProfiles;
}

/// The overview page (docs/ARCHITECTURE.md §8b): Turkey's days, or weeks for a year.
class AdminOverview {
  const AdminOverview({required this.days, required this.weekly, required this.buckets, required this.metrics, required this.snapshot});

  factory AdminOverview.fromJson(Map<String, Object?> j) => AdminOverview(
        days: j['days']! as int,
        weekly: j['bucket'] == 'week',
        buckets: [for (final b in j['buckets']! as List) DateTime.parse(b as String)],
        metrics: {
          for (final m in (j['metrics']! as List).cast<Map<String, Object?>>()) m['key']! as String: AdminMetric.fromJson(m),
        },
        snapshot: AdminSnapshot.fromJson((j['snapshot']! as Map).cast()),
      );

  final int days;
  final bool weekly;

  /// The first day of each bucket.
  final List<DateTime> buckets;
  final Map<String, AdminMetric> metrics;
  final AdminSnapshot snapshot;

  /// Revenue is only sent to the roles that see billing.
  bool get hasRevenue => metrics.containsKey('revenue_try');
}

abstract interface class AdminAnalyticsRepository {
  /// [days] is 7, 30, 90 or 365.
  Future<Result<AdminOverview>> overview(int days);
}
