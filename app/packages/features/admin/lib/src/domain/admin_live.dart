import 'package:core/core.dart';

import 'admin_user.dart';

class AdminBroadcast {
  const AdminBroadcast({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    this.hostUsername,
    this.startedAt,
    this.endedAt,
    this.endReason,
    this.participants,
  });

  factory AdminBroadcast.fromJson(Map<String, Object?> j) => AdminBroadcast(
        id: j['id']! as String,
        title: j['title']! as String,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        hostUsername: j['hostUsername'] as String?,
        startedAt: j['startedAt'] == null ? null : DateTime.parse(j['startedAt']! as String),
        endedAt: j['endedAt'] == null ? null : DateTime.parse(j['endedAt']! as String),
        endReason: j['endReason'] as String?,
        participants: j['participants'] as int?,
      );

  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final String? hostUsername;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? endReason;

  /// People in the room now; live broadcasts only.
  final int? participants;

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
  /// Live rooms with their participant counts, or (with [ended]) finished broadcasts, newest first.
  Future<Result<BroadcastPage>> search({required bool ended, int page = 1});

  /// Emergency close for everyone in the room.
  Future<Result<void>> end(String id, {required String reason});
}
