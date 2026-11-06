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

  /// Opening, declining and closing voice call permissions (docs/ARCHITECTURE.md §8c, Admin); moderators only view.
  bool get canManageCalls => this == admin || this == support;

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

  /// A suspension without an end date is a ban: the account is hidden everywhere (docs/ARCHITECTURE.md §3a).
  bool get isBanned => status == AdminAccountStatus.suspended && suspendedUntil == null;
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
    this.contributions = const AdminContributions(),
    this.teammates = const AdminTeammates(),
  });

  factory AdminUserDetail.fromJson(Map<String, Object?> j) => AdminUserDetail(
        contributions: j['contributions'] == null
            ? const AdminContributions()
            : AdminContributions.fromJson((j['contributions']! as Map).cast()),
        teammates: j['teammates'] == null ? const AdminTeammates() : AdminTeammates.fromJson((j['teammates']! as Map).cast()),
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
  final AdminContributions contributions;
  final AdminTeammates teammates;
}

/// Teammate activity, for spotting request spam (docs/ARCHITECTURE.md §3c, Ekip arkadaşı); the province is never shown.
class AdminTeammates {
  const AdminTeammates({this.looking = false, this.teammates = 0, this.requestsSentToday = 0, this.requestsPending = 0});

  factory AdminTeammates.fromJson(Map<String, Object?> j) => AdminTeammates(
        looking: j['looking']! as bool,
        teammates: j['teammates']! as int,
        requestsSentToday: j['requestsSentToday']! as int,
        requestsPending: j['requestsPending']! as int,
      );

  final bool looking;
  final int teammates;
  final int requestsSentToday;
  final int requestsPending;
}

/// What the person did in groups (docs/ARCHITECTURE.md §3d, Katkı ve rozetler).
class AdminContributions {
  const AdminContributions({
    this.attended = 0,
    this.organized = 0,
    this.memories = 0,
    this.reviews = 0,
    this.noShows = 0,
    this.welcomed = 0,
    this.exploredProvinces = 0,
    this.handshakes = 0,
  });

  factory AdminContributions.fromJson(Map<String, Object?> j) => AdminContributions(
        attended: j['attended']! as int,
        organized: j['organized']! as int,
        memories: j['memories']! as int,
        reviews: j['reviews']! as int,
        noShows: j['noShows']! as int,
        welcomed: j['welcomed'] as int? ?? 0,
        exploredProvinces: j['exploredProvinces'] as int? ?? 0,
        handshakes: j['handshakes'] as int? ?? 0,
      );

  final int attended;
  final int organized;
  final int memories;
  final int reviews;
  final int noShows;

  /// First-timers this person greeted (docs/ARCHITECTURE.md §3d, Karşılama).
  final int welcomed;

  /// Provinces of the events attended (Keşif haritam).
  final int exploredProvinces;

  /// People met at events (El sıkış).
  final int handshakes;
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

/// Where someone has the app open (docs/ARCHITECTURE.md §8b, Canlı kullanıcılar).
enum AdminPlatform {
  android('Android'),
  ios('iOS'),
  web('Web');

  const AdminPlatform(this.label);

  final String label;

  static AdminPlatform parse(Object? code) => values.firstWhere((p) => p.name == code, orElse: () => web);
}

/// Someone with the app open now.
class AdminOnlineUser {
  const AdminOnlineUser({
    required this.id,
    required this.platform,
    required this.onlineSince,
    required this.lastSeenAt,
    this.email,
    this.username,
    this.displayName,
    this.avatarPath,
  });

  factory AdminOnlineUser.fromJson(Map<String, Object?> j) => AdminOnlineUser(
        id: j['id']! as String,
        email: j['email'] as String?,
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
        avatarPath: j['avatarPath'] as String?,
        platform: AdminPlatform.parse(j['platform']),
        onlineSince: DateTime.parse(j['onlineSince']! as String),
        lastSeenAt: DateTime.parse(j['lastSeenAt']! as String),
      );

  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarPath;
  final AdminPlatform platform;
  final DateTime onlineSince;
  final DateTime lastSeenAt;

  String get title => displayName ?? username ?? email ?? 'Adsız kullanıcı';
}

/// A page of the live list, and everyone online by platform whatever the search.
class AdminOnlinePage {
  const AdminOnlinePage({required this.users, required this.online, required this.android, required this.ios, required this.web});

  factory AdminOnlinePage.fromJson(Map<String, Object?> j) => AdminOnlinePage(
        users: PagedList.fromJson((j['users']! as Map).cast(), AdminOnlineUser.fromJson),
        online: j['online']! as int,
        android: j['android']! as int,
        ios: j['ios']! as int,
        web: j['web']! as int,
      );

  final PagedList<AdminOnlineUser> users;
  final int online;
  final int android;
  final int ios;
  final int web;

  int count(AdminPlatform platform) => switch (platform) {
        AdminPlatform.android => android,
        AdminPlatform.ios => ios,
        AdminPlatform.web => web,
      };
}

abstract interface class StaffRepository {
  /// The signed-in user's platform role, or null if they are not staff.
  Future<Result<StaffRole?>> myRole();
}

abstract interface class AdminUsersRepository {
  Future<Result<UserPage>> search({String? query, AdminAccountStatus? status, int page = 1});

  Future<Result<AdminUserStats>> stats();

  /// Who has the app open now (docs/ARCHITECTURE.md §8b, Canlı kullanıcılar).
  Future<Result<AdminOnlinePage>> online({String? query, AdminPlatform? platform, int page = 1});

  Future<Result<AdminUserDetail>> get(String id);

  /// [until] null suspends indefinitely.
  Future<Result<void>> suspend(String id, {required String reason, DateTime? until});

  Future<Result<void>> unsuspend(String id);
}
