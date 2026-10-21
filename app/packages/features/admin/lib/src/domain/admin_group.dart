import 'package:core/core.dart';

import 'admin_billing.dart';
import 'admin_user.dart';

enum AdminGroupStatus {
  active('Aktif', 'active'),
  suspended('Askıda', 'suspended');

  const AdminGroupStatus(this.label, this.code);

  final String label;
  final String code;

  static AdminGroupStatus parse(Object? code) => code == 'suspended' ? suspended : active;
}

class AdminGroupSummary {
  const AdminGroupSummary({
    required this.id,
    required this.handle,
    required this.name,
    required this.categorySlug,
    required this.joinPolicy,
    required this.status,
    required this.memberCount,
    required this.ownerId,
    required this.createdAt,
    this.logoPath,
    this.ownerUsername,
    this.ownerDisplayName,
  });

  factory AdminGroupSummary.fromJson(Map<String, Object?> j) => AdminGroupSummary(
        id: j['id']! as String,
        handle: j['handle']! as String,
        name: j['name']! as String,
        categorySlug: j['categorySlug']! as String,
        joinPolicy: j['joinPolicy']! as String,
        status: AdminGroupStatus.parse(j['status']),
        memberCount: j['memberCount']! as int,
        ownerId: j['ownerId']! as String,
        createdAt: DateTime.parse(j['createdAt']! as String),
        logoPath: j['logoPath'] as String?,
        ownerUsername: j['ownerUsername'] as String?,
        ownerDisplayName: j['ownerDisplayName'] as String?,
      );

  final String id;
  final String handle;
  final String name;
  final String categorySlug;

  /// `open`, `request` or `invite`.
  final String joinPolicy;
  final AdminGroupStatus status;
  final int memberCount;
  final String ownerId;
  final DateTime createdAt;
  final String? logoPath;
  final String? ownerUsername;
  final String? ownerDisplayName;
}

class AdminGroupTeamMember {
  const AdminGroupTeamMember({required this.userId, required this.roles, this.username, this.displayName, this.avatarPath});

  factory AdminGroupTeamMember.fromJson(Map<String, Object?> j) => AdminGroupTeamMember(
        userId: j['userId']! as String,
        roles: (j['roles']! as List).cast<String>(),
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
        avatarPath: j['avatarPath'] as String?,
      );

  final String userId;

  /// Role slugs, highest rank first (`owner`, `admin`, `discipline`, `moderator`).
  final List<String> roles;
  final String? username;
  final String? displayName;
  final String? avatarPath;
}

class AdminGroupPlan {
  const AdminGroupPlan({required this.slug, required this.name, required this.maxMembers});

  factory AdminGroupPlan.fromJson(Map<String, Object?> j) =>
      AdminGroupPlan(slug: j['slug']! as String, name: j['name']! as String, maxMembers: j['maxMembers']! as int);

  final String slug;
  final String name;
  final int maxMembers;
}

class AdminGroupDetail {
  const AdminGroupDetail({
    required this.group,
    required this.plan,
    required this.subscriptions,
    required this.about,
    required this.pendingRequests,
    required this.pendingInvitations,
    required this.team,
    required this.history,
    this.suspensionReason,
    this.suspendedAt,
    this.province,
  });

  factory AdminGroupDetail.fromJson(Map<String, Object?> j) => AdminGroupDetail(
        group: AdminGroupSummary.fromJson((j['group']! as Map).cast()),
        plan: AdminGroupPlan.fromJson((j['plan']! as Map).cast()),
        subscriptions: [
          for (final s in (j['subscriptions']! as List).cast<Map<String, Object?>>()) AdminSubscription.fromJson(s),
        ],
        about: j['about']! as String,
        pendingRequests: j['pendingRequests']! as int,
        pendingInvitations: j['pendingInvitations']! as int,
        team: [for (final t in (j['team']! as List).cast<Map<String, Object?>>()) AdminGroupTeamMember.fromJson(t)],
        history: [for (final h in (j['history']! as List).cast<Map<String, Object?>>()) AdminAuditItem.fromJson(h)],
        suspensionReason: j['suspensionReason'] as String?,
        suspendedAt: j['suspendedAt'] is String ? DateTime.parse(j['suspendedAt']! as String) : null,
        province: j['province'] as int?,
      );

  final AdminGroupSummary group;

  /// The plan in effect now (free without a paid slice).
  final AdminGroupPlan plan;

  /// The group's whole timeline, newest first.
  final List<AdminSubscription> subscriptions;
  final String about;
  final int pendingRequests;
  final int pendingInvitations;
  final List<AdminGroupTeamMember> team;
  final List<AdminAuditItem> history;
  final String? suspensionReason;
  final DateTime? suspendedAt;

  /// Plate number; the group's place on the map (Faz 14).
  final int? province;
}

class AdminGroupStats {
  const AdminGroupStats({required this.total, required this.active, required this.suspended});

  factory AdminGroupStats.fromJson(Map<String, Object?> j) => AdminGroupStats(
        total: j['total']! as int,
        active: j['active']! as int,
        suspended: j['suspended']! as int,
      );

  final int total;
  final int active;
  final int suspended;
}

typedef GroupPage = PagedList<AdminGroupSummary>;

abstract interface class AdminGroupsRepository {
  Future<Result<GroupPage>> search({String? query, AdminGroupStatus? status, int page = 1});

  Future<Result<AdminGroupStats>> stats();

  Future<Result<AdminGroupDetail>> get(String id);

  Future<Result<void>> suspend(String id, {required String reason});

  Future<Result<void>> unsuspend(String id);
}
