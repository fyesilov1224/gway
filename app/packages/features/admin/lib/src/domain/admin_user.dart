import 'package:core/core.dart';

enum StaffRole {
  admin('admin', 'Yönetici'),
  moderator('moderator', 'Moderatör'),
  support('support', 'Destek');

  const StaffRole(this.code, this.label);

  final String code;
  final String label;

  bool get canSuspend => this == admin || this == moderator;

  /// Removing and restoring posts and comments; support only views.
  bool get canModerateContent => this == admin || this == moderator;

  /// Orders, subscriptions and plans (read).
  bool get canSeeBilling => this == admin || this == support;

  /// Revenue, plan edits and cancellations.
  bool get canManageBilling => this == admin;

  static StaffRole? tryParse(Object? code) {
    for (final r in values) {
      if (r.code == code) return r;
    }
    return null;
  }
}

enum AdminAccountStatus {
  active('Aktif', 'active'),
  suspended('Askıda', 'suspended'),
  pendingDeletion('Silinecek', 'pending_deletion');

  const AdminAccountStatus(this.label, this.code);

  final String label;
  final String code;

  static AdminAccountStatus parse(Object? code) => switch (code) {
        'suspended' => suspended,
        'pending_deletion' => pendingDeletion,
        _ => active,
      };
}

DateTime? _date(Object? v) => v is String ? DateTime.parse(v) : null;

class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.status,
    this.email,
    this.username,
    this.displayName,
    this.avatarPath,
    this.suspendedUntil,
    this.deletionScheduledFor,
    this.staffRole,
    this.createdAt,
    this.lastSignInAt,
  });

  factory AdminUserSummary.fromJson(Map<String, Object?> j) => AdminUserSummary(
        id: j['id']! as String,
        email: j['email'] as String?,
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
        avatarPath: j['avatarPath'] as String?,
        status: AdminAccountStatus.parse(j['status']),
        suspendedUntil: _date(j['suspendedUntil']),
        deletionScheduledFor: _date(j['deletionScheduledFor']),
        staffRole: StaffRole.tryParse(j['staffRole']),
        createdAt: _date(j['createdAt']),
        lastSignInAt: _date(j['lastSignInAt']),
      );

  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarPath;
  final AdminAccountStatus status;
  final DateTime? suspendedUntil;
  final DateTime? deletionScheduledFor;
  final StaffRole? staffRole;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  /// Name to show; users who have not finished onboarding have no profile.
  String get title => displayName ?? email ?? id;
}

class AdminConsent {
  const AdminConsent({required this.kind, required this.version, required this.acceptedAt});

  final String kind;
  final int version;
  final DateTime acceptedAt;
}

class AdminAuditItem {
  const AdminAuditItem({
    required this.occurredAt,
    required this.action,
    required this.actorKind,
    this.actorId,
    this.actorName,
    this.targetName,
    this.detail,
  });

  factory AdminAuditItem.fromJson(Map<String, Object?> j) => AdminAuditItem(
        occurredAt: DateTime.parse(j['occurredAt']! as String),
        action: j['action']! as String,
        actorKind: j['actorKind']! as String,
        actorId: j['actorId'] as String?,
        actorName: j['actorName'] as String?,
        targetName: j['targetName'] as String?,
        detail: j['detail'] as String?,
      );

  final DateTime occurredAt;
  final String action;
  final String actorKind;
  final String? actorId;

  /// Display name or e-mail of the actor, when the actor still exists.
  final String? actorName;

  /// Display name of the affected user (group history).
  final String? targetName;

  /// Role or reason recorded with the action.
  final String? detail;
}

class AdminUserStats {
  const AdminUserStats({
    required this.total,
    required this.active,
    required this.suspended,
    required this.pendingDeletion,
  });

  factory AdminUserStats.fromJson(Map<String, Object?> j) => AdminUserStats(
        total: j['total']! as int,
        active: j['active']! as int,
        suspended: j['suspended']! as int,
        pendingDeletion: j['pendingDeletion']! as int,
      );

  final int total;
  final int active;
  final int suspended;
  final int pendingDeletion;
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    required this.consents,
    required this.history,
    this.bio,
    this.suspensionReason,
  });

  factory AdminUserDetail.fromJson(Map<String, Object?> j) => AdminUserDetail(
        user: AdminUserSummary.fromJson((j['user']! as Map).cast()),
        bio: j['bio'] as String?,
        suspensionReason: j['suspensionReason'] as String?,
        consents: [
          for (final c in (j['consents']! as List).cast<Map<String, Object?>>())
            AdminConsent(
              kind: c['kind']! as String,
              version: c['version']! as int,
              acceptedAt: DateTime.parse(c['acceptedAt']! as String),
            ),
        ],
        history: [
          for (final h in (j['history']! as List).cast<Map<String, Object?>>()) AdminAuditItem.fromJson(h),
        ],
      );

  final AdminUserSummary user;
  final String? bio;
  final String? suspensionReason;
  final List<AdminConsent> consents;
  final List<AdminAuditItem> history;
}

/// One page of a paged admin list.
class PagedList<T> {
  const PagedList({required this.items, required this.total, required this.page, required this.pageSize});

  factory PagedList.fromJson(Map<String, Object?> j, T Function(Map<String, Object?> item) item) => PagedList(
        items: [for (final i in (j['items']! as List).cast<Map<String, Object?>>()) item(i)],
        total: j['total']! as int,
        page: j['page']! as int,
        pageSize: j['pageSize']! as int,
      );

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  int get pageCount => total == 0 ? 1 : (total / pageSize).ceil();

  /// 1-based index of the first and last item on this page.
  (int, int) get range => items.isEmpty ? (0, 0) : ((page - 1) * pageSize + 1, (page - 1) * pageSize + items.length);
}

typedef UserPage = PagedList<AdminUserSummary>;

abstract interface class StaffRepository {
  /// The signed-in user's platform role, or null if they are not staff.
  Future<Result<StaffRole?>> myRole();
}

abstract interface class AdminUsersRepository {
  Future<Result<UserPage>> search({String? query, AdminAccountStatus? status, int page = 1});

  Future<Result<AdminUserStats>> stats();

  Future<Result<AdminUserDetail>> get(String id);

  /// [until] null suspends indefinitely.
  Future<Result<void>> suspend(String id, {required String reason, DateTime? until});

  Future<Result<void>> unsuspend(String id);
}
