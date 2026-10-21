import 'package:core/core.dart';

import 'admin_user.dart';

enum AdminEventStatus {
  upcoming('upcoming', 'Yaklaşan'),
  past('past', 'Geçmiş'),
  canceled('canceled', 'İptal edilen');

  const AdminEventStatus(this.code, this.label);

  final String code;
  final String label;
}

class AdminEvent {
  const AdminEvent({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.startsAt,
    required this.location,
    required this.goingCount,
    required this.waitlistCount,
    this.capacity,
    this.canceledAt,
    this.cancelReason,
    this.approvalRequired = false,
    this.requestedCount = 0,
    this.ratingAvg,
    this.ratingCount = 0,
    this.postsCount = 0,
  });

  factory AdminEvent.fromJson(Map<String, Object?> j) => AdminEvent(
        id: j['id']! as String,
        title: j['title']! as String,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        location: j['location']! as String,
        capacity: j['capacity'] as int?,
        goingCount: j['goingCount']! as int,
        waitlistCount: j['waitlistCount']! as int,
        canceledAt: j['canceledAt'] == null ? null : DateTime.parse(j['canceledAt']! as String),
        cancelReason: j['cancelReason'] as String?,
        approvalRequired: j['approvalRequired'] as bool? ?? false,
        requestedCount: j['requestedCount'] as int? ?? 0,
        ratingAvg: (j['ratingAvg'] as num?)?.toDouble(),
        ratingCount: j['ratingCount'] as int? ?? 0,
        postsCount: j['postsCount'] as int? ?? 0,
      );

  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final DateTime startsAt;
  final String location;
  final int? capacity;
  final int goingCount;
  final int waitlistCount;
  final DateTime? canceledAt;
  final String? cancelReason;

  /// Joining needs a manager's approval; [requestedCount] people are waiting.
  final bool approvalRequired;
  final int requestedCount;

  /// Attendees' average stars and memories (Faz 10).
  final double? ratingAvg;
  final int ratingCount;
  final int postsCount;

  bool get isCanceled => canceledAt != null;
}

typedef AdminEventPage = PagedList<AdminEvent>;

enum AdminGoalStatus {
  running('running', 'Süren'),
  ended('ended', 'Biten'),
  canceled('canceled', 'İptal edilen');

  const AdminGoalStatus(this.code, this.label);

  final String code;
  final String label;
}

const goalKindLabels = {'personal': 'Kişisel', 'group': 'Grup', 'team': 'Takım', 'task': 'Onaylı görev'};
const goalMetricLabels = {'attended': 'katılım', 'organized': 'düzenleme', 'memories': 'anı'};

/// A group's goal (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).
class AdminGoal {
  const AdminGoal({
    required this.id,
    required this.title,
    required this.kind,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.startsAt,
    required this.endsAt,
    required this.completions,
    this.metric,
    this.target,
    this.canceledAt,
  });

  factory AdminGoal.fromJson(Map<String, Object?> j) => AdminGoal(
        id: j['id']! as String,
        title: j['title']! as String,
        kind: j['kind']! as String,
        metric: j['metric'] as String?,
        target: j['target'] as int?,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        endsAt: DateTime.parse(j['endsAt']! as String),
        canceledAt: j['canceledAt'] == null ? null : DateTime.parse(j['canceledAt']! as String),
        completions: j['completions']! as int,
      );

  final String id;
  final String title;
  final String kind;
  final String? metric;
  final int? target;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;
  final int completions;

  bool get isRunning => canceledAt == null && endsAt.isAfter(DateTime.now());

  String get summary => [
        goalKindLabels[kind] ?? kind,
        if (target != null) '$target ${goalMetricLabels[metric] ?? ''}',
        '$completions tamamlayan',
      ].join(' · ');
}

typedef AdminGoalPage = PagedList<AdminGoal>;

abstract interface class AdminEventsRepository {
  Future<Result<AdminEventPage>> search({String? query, AdminEventStatus? status, int page = 1});

  /// Cancels for everyone; attendees are notified.
  Future<Result<void>> cancel(String id, {required String reason});

  Future<Result<AdminGoalPage>> goals({AdminGoalStatus? status, int page = 1});

  Future<Result<void>> cancelGoal(String id);
}
