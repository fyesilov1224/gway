import 'package:core/core.dart';

/// Voice call permissions as the platform team sees them (docs/ARCHITECTURE.md §8c). The team never sees calls.
enum AdminCallPermissionStatus {
  requested('requested', 'Bekleyen'),
  active('active', 'Açık'),
  declined('declined', 'Reddedilen'),
  revoked('revoked', 'Kapatılan');

  const AdminCallPermissionStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminCallPermissionStatus parse(Object? code) => values.where((s) => s.code == code).firstOrNull ?? requested;
}

class AdminCallPermission {
  const AdminCallPermission({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.status,
    this.avatarPath,
    this.note,
    this.requestedAt,
    this.decidedAt,
    this.reason,
  });

  factory AdminCallPermission.fromJson(Map<String, Object?> j) => AdminCallPermission(
        userId: j['userId']! as String,
        username: j['username']! as String,
        displayName: j['displayName']! as String,
        avatarPath: j['avatarPath'] as String?,
        status: AdminCallPermissionStatus.parse(j['status']),
        note: j['note'] as String?,
        requestedAt: j['requestedAt'] is String ? DateTime.parse(j['requestedAt']! as String) : null,
        decidedAt: j['decidedAt'] is String ? DateTime.parse(j['decidedAt']! as String) : null,
        reason: j['reason'] as String?,
      );

  final String userId;
  final String username;
  final String displayName;
  final String? avatarPath;
  final AdminCallPermissionStatus status;
  final String? note;
  final DateTime? requestedAt;
  final DateTime? decidedAt;
  final String? reason;
}

class AdminCallPermissionsPage {
  const AdminCallPermissionsPage({required this.items, required this.calls24h, required this.minutes24h});

  factory AdminCallPermissionsPage.fromJson(Map<String, Object?> j) => AdminCallPermissionsPage(
        items: [for (final i in j['items']! as List) AdminCallPermission.fromJson((i as Map).cast())],
        calls24h: (j['calls24h']! as num).toInt(),
        minutes24h: (j['minutes24h']! as num).toInt(),
      );

  final List<AdminCallPermission> items;

  /// Platform-wide totals of the last 24 hours; nothing about who called whom.
  final int calls24h;
  final int minutes24h;
}

abstract interface class AdminCallsRepository {
  Future<Result<AdminCallPermissionsPage>> permissions(AdminCallPermissionStatus status);

  /// Opens the feature, or closes / declines it with a reason (closing ends the person's call).
  Future<Result<void>> setPermission(String userId, {required bool active, String? reason});

  /// The person's permission; null when they never asked.
  Future<Result<AdminCallPermission?>> userPermission(String userId);
}
