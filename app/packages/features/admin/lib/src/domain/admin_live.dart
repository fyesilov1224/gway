import 'package:core/core.dart';

import 'admin_user.dart';

/// Which broadcasts the live page lists (docs/ARCHITECTURE.md §8, Admin).
enum AdminLiveStatus {
  live('live', 'Şu an canlı'),
  scheduled('scheduled', 'Planlı'),
  ended('ended', 'Geçmiş');

  const AdminLiveStatus(this.code, this.label);

  final String code;
  final String label;
}

class AdminBroadcast {
  const AdminBroadcast({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    this.status = AdminLiveStatus.live,
    this.hostUsername,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.endReason,
    this.participants,
    this.notified = 0,
  });

  factory AdminBroadcast.fromJson(Map<String, Object?> j) => AdminBroadcast(
        id: j['id']! as String,
        title: j['title']! as String,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        status: AdminLiveStatus.values.firstWhere((s) => s.code == j['status'], orElse: () => AdminLiveStatus.ended),
        hostUsername: j['hostUsername'] as String?,
        scheduledAt: j['scheduledAt'] == null ? null : DateTime.parse(j['scheduledAt']! as String),
        startedAt: j['startedAt'] == null ? null : DateTime.parse(j['startedAt']! as String),
        endedAt: j['endedAt'] == null ? null : DateTime.parse(j['endedAt']! as String),
        endReason: j['endReason'] as String?,
        participants: j['participants'] as int?,
        notified: j['notified'] as int? ?? 0,
      );

  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String groupHandle;

  /// A canceled broadcast is listed with the ended ones.
  final AdminLiveStatus status;
  final String? hostUsername;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? endReason;

  /// People in the room now; live broadcasts only.
  final int? participants;

  /// Members announced to while scheduled; members told of the start afterwards.
  final int notified;

  Duration duration(DateTime now) => (endedAt ?? now).difference(startedAt ?? now);

  /// Why it ended (docs/ARCHITECTURE.md §8).
  String? get endReasonLabel => switch (endReason) {
        'host' => 'Sunucu bitirdi',
        'moderator' => 'Grup yöneticisi bitirdi',
        'admin' => 'Platform ekibi kapattı',
        'limit' => 'Aylık dakika doldu',
        'host_left' => 'Sunucu ayrıldı',
        'empty' => 'Oda boşaldı',
        _ => null,
      };
}

typedef BroadcastPage = PagedList<AdminBroadcast>;

abstract interface class AdminLiveRepository {
  /// Live rooms with their participant counts, scheduled broadcasts soonest first, or finished ones newest first.
  Future<Result<BroadcastPage>> search({required AdminLiveStatus status, int page = 1});

  /// Emergency close for everyone in the room.
  Future<Result<void>> end(String id, {required String reason});
}
