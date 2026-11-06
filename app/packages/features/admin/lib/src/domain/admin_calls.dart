import 'package:core/core.dart';

/// Voice call permissions as the platform team sees them (docs/ARCHITECTURE.md §8c, Admin). The team never sees calls.
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

/// Who decided: the platform team, the group's owner, one of its managers, or nobody (the person left the group).
enum AdminCallDeciderKind {
  platform('platform', 'Platform ekibi'),
  groupOwner('group_owner', 'Grup sahibi'),
  groupManager('group_manager', 'Grup yöneticisi'),
  system('system', 'Kendiliğinden');

  const AdminCallDeciderKind(this.code, this.label);

  final String code;
  final String label;

  static AdminCallDeciderKind parse(Object? code) => values.where((k) => k.code == code).firstOrNull ?? system;
}

DateTime? _date(Object? v) => v is String ? DateTime.parse(v) : null;

/// The group a request went to or a permission rests on.
class AdminCallGroup {
  const AdminCallGroup({required this.id, required this.handle, required this.name, required this.status});

  factory AdminCallGroup.fromJson(Map<String, Object?> j) => AdminCallGroup(
        id: j['id']! as String,
        handle: j['handle']! as String,
        name: j['name']! as String,
        status: j['status']! as String,
      );

  final String id;
  final String handle;
  final String name;
  final String status;

  /// A suspended group's permission does not count.
  bool get suspended => status != 'active';
}

class AdminCallDecider {
  const AdminCallDecider({required this.kind, this.id, this.username, this.displayName});

  factory AdminCallDecider.fromJson(Map<String, Object?> j) => AdminCallDecider(
        kind: AdminCallDeciderKind.parse(j['kind']),
        id: j['id'] as String?,
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
      );

  final AdminCallDeciderKind kind;
  final String? id;
  final String? username;
  final String? displayName;
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
    this.group,
    this.decidedBy,
  });

  factory AdminCallPermission.fromJson(Map<String, Object?> j) => AdminCallPermission(
        userId: j['userId']! as String,
        username: j['username']! as String,
        displayName: j['displayName']! as String,
        avatarPath: j['avatarPath'] as String?,
        status: AdminCallPermissionStatus.parse(j['status']),
        note: j['note'] as String?,
        requestedAt: _date(j['requestedAt']),
        decidedAt: _date(j['decidedAt']),
        reason: j['reason'] as String?,
        group: switch (j['group']) {
          final Map<dynamic, dynamic> g => AdminCallGroup.fromJson(g.cast()),
          _ => null,
        },
        decidedBy: switch (j['decidedBy']) {
          final Map<dynamic, dynamic> d => AdminCallDecider.fromJson(d.cast()),
          _ => null,
        },
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

  /// Null: the platform team opened it, it rests on no group.
  final AdminCallGroup? group;
  final AdminCallDecider? decidedBy;
}

class AdminCallSummary {
  const AdminCallSummary({
    required this.requested,
    required this.active,
    required this.declined,
    required this.revoked,
    required this.calls24h,
    required this.minutes24h,
    this.oldestRequestAt,
  });

  factory AdminCallSummary.fromJson(Map<String, Object?> j) => AdminCallSummary(
        requested: (j['requested']! as num).toInt(),
        active: (j['active']! as num).toInt(),
        declined: (j['declined']! as num).toInt(),
        revoked: (j['revoked']! as num).toInt(),
        oldestRequestAt: _date(j['oldestRequestAt']),
        calls24h: (j['calls24h']! as num).toInt(),
        minutes24h: (j['minutes24h']! as num).toInt(),
      );

  final int requested;
  final int active;
  final int declined;
  final int revoked;
  final DateTime? oldestRequestAt;

  /// Platform-wide totals of the last 24 hours; nothing about who called whom.
  final int calls24h;
  final int minutes24h;

  int count(AdminCallPermissionStatus? status) => switch (status) {
        null => requested + active + declined + revoked,
        AdminCallPermissionStatus.requested => requested,
        AdminCallPermissionStatus.active => active,
        AdminCallPermissionStatus.declined => declined,
        AdminCallPermissionStatus.revoked => revoked,
      };
}

class AdminCallPermissionsPage {
  const AdminCallPermissionsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.summary,
  });

  factory AdminCallPermissionsPage.fromJson(Map<String, Object?> j) => AdminCallPermissionsPage(
        items: [for (final i in j['items']! as List) AdminCallPermission.fromJson((i as Map).cast())],
        total: (j['total']! as num).toInt(),
        page: (j['page']! as num).toInt(),
        pageSize: (j['pageSize']! as num).toInt(),
        summary: AdminCallSummary.fromJson((j['summary']! as Map).cast()),
      );

  final List<AdminCallPermission> items;
  final int total;
  final int page;
  final int pageSize;
  final AdminCallSummary summary;

  int get pageCount => total == 0 ? 1 : (total / pageSize).ceil();

  (int, int) get range => items.isEmpty ? (0, 0) : ((page - 1) * pageSize + 1, (page - 1) * pageSize + items.length);
}

/// One decision on a person's permission (the audit log).
class AdminCallEvent {
  const AdminCallEvent({
    required this.at,
    required this.action,
    required this.byStaff,
    this.actorUsername,
    this.actorDisplayName,
    this.groupName,
    this.reason,
  });

  factory AdminCallEvent.fromJson(Map<String, Object?> j) => AdminCallEvent(
        at: DateTime.parse(j['at']! as String),
        action: j['action']! as String,
        byStaff: j['actorKind'] == 'staff',
        actorUsername: j['actorUsername'] as String?,
        actorDisplayName: j['actorDisplayName'] as String?,
        groupName: j['groupName'] as String?,
        reason: j['reason'] as String?,
      );

  final DateTime at;
  final String action;
  final bool byStaff;
  final String? actorUsername;
  final String? actorDisplayName;
  final String? groupName;
  final String? reason;

  String get label => switch (action) {
        'call_permission.granted' => 'Açıldı',
        'call_permission.declined' => 'Talep reddedildi',
        'call_permission.revoked' => 'Kapatıldı',
        _ => action,
      };
}

class AdminCallUserDetail {
  const AdminCallUserDetail({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.history,
    this.permission,
  });

  factory AdminCallUserDetail.fromJson(Map<String, Object?> j) => AdminCallUserDetail(
        userId: j['userId']! as String,
        username: j['username']! as String,
        displayName: j['displayName']! as String,
        permission: switch (j['permission']) {
          final Map<dynamic, dynamic> p => AdminCallPermission.fromJson(p.cast()),
          _ => null,
        },
        history: [for (final e in j['history']! as List) AdminCallEvent.fromJson((e as Map).cast())],
      );

  final String userId;
  final String username;
  final String displayName;

  /// Null: never asked.
  final AdminCallPermission? permission;
  final List<AdminCallEvent> history;
}

typedef AdminCallQuery = ({AdminCallPermissionStatus? status, String query, int page});

abstract interface class AdminCallsRepository {
  /// [AdminCallQuery.status] null lists every state.
  Future<Result<AdminCallPermissionsPage>> permissions(AdminCallQuery query);

  Future<Result<AdminCallUserDetail>> user(String userId);

  /// Opens voice calls, or declines a waiting request / closes an open permission with a reason (ends the person's call).
  Future<Result<void>> setPermission(String userId, {required bool active, String? reason});

  /// Opens voice calls for someone who never asked.
  Future<Result<void>> grant(String username);
}
