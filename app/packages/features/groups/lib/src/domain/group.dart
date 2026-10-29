import 'package:core/core.dart';

/// How users get into a group (docs/ARCHITECTURE.md §3b).
enum JoinPolicy {
  open('open', 'Serbest katılım', 'Herkes doğrudan katılabilir.'),
  request('request', 'İstekle katılım', 'Katılım istekleri yöneticiler tarafından onaylanır.'),
  invite('invite', 'Davetle katılım', 'Yalnızca davet edilen kişiler katılabilir.');

  const JoinPolicy(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;

  static JoinPolicy parse(Object? code) => values.firstWhere((p) => p.code == code, orElse: () => open);
}

/// Group roles and their rank. Owner and member are structural; the rest are assigned by the owner.
enum GroupRole {
  owner('owner', 'Grup Sahibi', 100),
  admin('admin', 'Yönetici', 80),
  discipline('discipline', 'Disiplin Kurulu', 60),
  moderator('moderator', 'Moderatör', 50),
  member('member', 'Üye', 10);

  const GroupRole(this.code, this.label, this.rank);

  final String code;
  final String label;
  final int rank;

  static const assignable = [admin, discipline, moderator];

  static GroupRole? tryParse(Object? code) {
    for (final r in values) {
      if (r.code == code) return r;
    }
    return null;
  }
}

/// Permission slugs of the catalog (`public.group_permissions`).
/// The highest rank of [roles] (docs/ARCHITECTURE.md §3b); sanctions need a higher one than the target's.
int rankOf(Iterable<GroupRole> roles) => roles.fold(0, (rank, r) => r.rank > rank ? r.rank : rank);

abstract final class GroupPermission {
  static const edit = 'group.edit';
  static const delete = 'group.delete';
  static const transfer = 'group.transfer';
  static const assignRoles = 'roles.assign';
  static const approveMembers = 'members.approve';
  static const inviteMembers = 'members.invite';
  static const manageBilling = 'billing.manage';
  static const publishPosts = 'posts.publish';
  static const manageEvents = 'events.manage';
  static const startLive = 'live.start';
  static const moderateLive = 'live.moderate';
  static const reviewReports = 'reports.review';
  static const muteMembers = 'members.mute';
}

class GroupLink {
  const GroupLink({required this.label, required this.url});

  final String label;
  final String url;

  Map<String, Object?> toJson() => {'label': label, 'url': url};
}

class Group {
  const Group({
    required this.id,
    required this.handle,
    required this.name,
    required this.categorySlug,
    required this.joinPolicy,
    required this.ownerId,
    required this.memberCount,
    required this.createdAt,
    this.about = '',
    this.rules = '',
    this.links = const [],
    this.logoPath,
    this.coverPath,
    this.logoUrl,
    this.coverUrl,
    this.isSuspended = false,
    this.province,
  });

  final String id;
  final String handle;
  final String name;
  final String categorySlug;
  final JoinPolicy joinPolicy;
  final String ownerId;
  final int memberCount;
  final DateTime createdAt;
  final String about;
  final String rules;
  final List<GroupLink> links;
  final String? logoPath;
  final String? coverPath;
  final String? logoUrl;
  final String? coverUrl;

  /// Suspended by the platform team: only members see it, nothing but leaving works.
  final bool isSuspended;

  /// Plate number (1–81); the group is shown there on the map (docs/ARCHITECTURE.md §3d, Harita ile keşif).
  final int? province;

  String? get provinceName => province == null ? null : turkishProvinces[province! - 1];
}

enum GroupImage { logo, cover }

/// A member as listed on the group: profile basics and every role they hold.
class GroupPerson {
  const GroupPerson({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.roles,
    this.avatarUrl,
    this.since,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  /// Highest first; always contains [GroupRole.member] for members.
  final List<GroupRole> roles;

  /// Joined (members) or requested / invited (pending people).
  final DateTime? since;

  GroupRole get topRole => roles.isEmpty ? GroupRole.member : roles.first;

  int get rank => rankOf(roles);

  /// Roles worth a badge: everything above plain membership.
  List<GroupRole> get titles => [for (final r in roles) if (r != GroupRole.member) r];
}

/// The signed-in user's relation to one group.
class MyMembership {
  const MyMembership({
    this.isMember = false,
    this.roles = const [],
    this.permissions = const {},
    this.hasPendingRequest = false,
    this.hasInvitation = false,
    this.isFollowing = false,
  });

  final bool isMember;
  final List<GroupRole> roles;
  final Set<String> permissions;
  final bool hasPendingRequest;
  final bool hasInvitation;

  /// Follows the group's posts without being a member.
  final bool isFollowing;

  bool can(String permission) => permissions.contains(permission);

  int get rank => rankOf(roles);

  /// Sees the members screen's request and invitation tabs.
  bool get managesMembers => can(GroupPermission.approveMembers) || can(GroupPermission.inviteMembers);
}

/// What the main action on a group page offers.
enum JoinState { suspended, owner, member, invited, requested, canJoin, canRequest, inviteOnly }

JoinState joinStateOf(Group group, MyMembership me, {required String? userId}) {
  if (group.ownerId == userId) return group.isSuspended ? JoinState.suspended : JoinState.owner;
  if (me.isMember) return group.isSuspended ? JoinState.suspended : JoinState.member;
  if (group.isSuspended) return JoinState.suspended;
  if (me.hasInvitation) return JoinState.invited;
  if (me.hasPendingRequest) return JoinState.requested;
  return switch (group.joinPolicy) {
    JoinPolicy.open => JoinState.canJoin,
    JoinPolicy.request => JoinState.canRequest,
    JoinPolicy.invite => JoinState.inviteOnly,
  };
}

/// An invitation the signed-in user received.
class GroupInvitation {
  const GroupInvitation({required this.group, required this.createdAt, this.invitedBy});

  final Group group;
  final DateTime createdAt;

  /// Display name of the inviter, when still visible.
  final String? invitedBy;
}

enum JoinOutcome { member, requested }

/// A shareable invite link (docs/ARCHITECTURE.md §3b, Davet bağlantısı).
class InviteLink {
  const InviteLink({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.useCount,
    this.maxUses,
    this.revokedAt,
  });

  /// Lengths a link can last, in days.
  static const durations = [1, 7, 30];

  /// Use limits offered; null is no limit.
  static const useLimits = <int?>[null, 10, 50, 100];

  final String id;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int useCount;
  final int? maxUses;
  final DateTime? revokedAt;

  bool isValidAt(DateTime now) => revokedAt == null && expiresAt.isAfter(now) && (maxUses == null || useCount < maxUses!);
}

/// What anyone holding an invite code sees: the public group and whether the link still works.
class InvitePreview {
  const InvitePreview({
    required this.valid,
    required this.groupId,
    required this.handle,
    required this.name,
    required this.categorySlug,
    required this.about,
    required this.memberCount,
    this.logoUrl,
    this.coverUrl,
  });

  final bool valid;
  final String groupId;
  final String handle;
  final String name;
  final String categorySlug;
  final String about;
  final int memberCount;
  final String? logoUrl;
  final String? coverUrl;
}

class GroupDraft {
  const GroupDraft({
    required this.handle,
    required this.name,
    required this.categorySlug,
    required this.joinPolicy,
    this.about = '',
    this.province,
  });

  final String handle;
  final String name;
  final String categorySlug;
  final JoinPolicy joinPolicy;
  final String about;
  final int? province;
}

/// Profile edit; null fields stay as they are.
class GroupUpdate {
  const GroupUpdate({this.name, this.categorySlug, this.joinPolicy, this.about, this.rules, this.links, this.province});

  final String? name;
  final String? categorySlug;
  final JoinPolicy? joinPolicy;
  final String? about;
  final String? rules;
  final List<GroupLink>? links;

  /// 0 removes the province.
  final int? province;

  Map<String, Object?> toJson() => {
        'name': ?name,
        'categorySlug': ?categorySlug,
        'joinPolicy': ?joinPolicy?.code,
        'about': ?about,
        'rules': ?rules,
        if (links != null) 'links': [for (final l in links!) l.toJson()],
        'province': ?province,
      };
}

/// Input rules of docs/ARCHITECTURE.md §3b, checked again by the API and the database.
abstract final class GroupRules {
  static const handleMaxLength = 30;
  static const nameMaxLength = 60;
  static const aboutMaxLength = 1000;
  static const rulesMaxLength = 2000;
  static const maxLinks = 5;
  static const linkLabelMaxLength = 40;
  static const linkUrlMaxLength = 300;

  static final _handle = RegExp(r'^[a-z0-9_.]{3,30}$');

  static String normalizeHandle(String value) => value.trim().toLowerCase();

  static String? validateHandle(String? value) {
    final v = normalizeHandle(value ?? '');
    if (v.length < 3) return 'Grup adresi en az 3 karakter olmalı.';
    if (!_handle.hasMatch(v)) return 'Yalnızca küçük harf, rakam, alt çizgi ve nokta kullanabilirsin.';
    if (v.startsWith('.') || v.endsWith('.') || v.contains('..')) {
      return 'Nokta ile başlayamaz, bitemez ve art arda kullanılamaz.';
    }
    return null;
  }

  static String? validateName(String? value) {
    final v = (value ?? '').trim();
    if (v.length < 3) return 'Grup adı en az 3 karakter olmalı.';
    if (v.length > nameMaxLength) return 'Grup adı en fazla $nameMaxLength karakter olabilir.';
    return null;
  }

  static String? validateLinkUrl(String? value) {
    final v = (value ?? '').trim();
    final uri = Uri.tryParse(v);
    if (v.isEmpty || v.length > linkUrlMaxLength || uri == null || !uri.hasAuthority || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return 'https:// ile başlayan bir adres gir.';
    }
    return null;
  }

  /// Suggests a handle from a group name: Turkish letters folded, spaces become dots.
  static String suggestHandle(String name) {
    const fold = {'ç': 'c', 'ğ': 'g', 'ı': 'i', 'İ': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u', 'â': 'a', 'î': 'i', 'û': 'u'};
    final buffer = StringBuffer();
    for (final ch in name.trim().split('')) {
      final lower = fold[ch] ?? ch.toLowerCase();
      buffer.write(fold[lower] ?? lower);
    }
    final handle = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9_.]+'), '.')
        .replaceAll(RegExp(r'\.{2,}'), '.')
        .replaceAll(RegExp(r'^\.+|\.+$'), '');
    return handle.length > handleMaxLength ? handle.substring(0, handleMaxLength).replaceAll(RegExp(r'\.+$'), '') : handle;
  }
}

abstract interface class GroupsRepository {
  /// Active groups, most members first; [query] matches name or handle.
  Future<Result<List<Group>>> discover({String query = '', String? categorySlug, required int limit});

  /// Groups [userId] belongs to, most recently joined first.
  Future<Result<List<Group>>> groupsOf(String userId);

  Future<Result<Group>> byHandle(String handle);

  Future<Result<bool>> isHandleAvailable(String handle);

  Future<Result<MyMembership>> myMembership(String groupId);

  /// Members with their roles; [ownerId] identifies the owner row.
  Future<Result<List<GroupPerson>>> members(String groupId, {required String ownerId});

  Future<Result<List<GroupPerson>>> joinRequests(String groupId);

  Future<Result<List<GroupPerson>>> invitations(String groupId);

  Future<Result<List<GroupInvitation>>> myInvitations();

  /// Creates the group; returns its handle.
  Future<Result<String>> create(GroupDraft draft);

  Future<Result<void>> update(String groupId, GroupUpdate update);

  /// Uploads the image, points the group at it and removes the old file.
  Future<Result<void>> setImage(Group group, GroupImage kind, ImageUpload upload);

  Future<Result<void>> removeImage(Group group, GroupImage kind);

  Future<Result<void>> delete(String groupId);

  Future<Result<JoinOutcome>> join(String groupId);

  Future<Result<void>> cancelRequest(String groupId);

  Future<Result<void>> leave(String groupId);

  Future<Result<void>> declineInvitation(String groupId);

  /// The user's own follow (RLS); members get the posts anyway.
  Future<Result<void>> setFollowing(String groupId, bool follow);

  Future<Result<void>> approve(String groupId, String userId);

  Future<Result<void>> reject(String groupId, String userId);

  Future<Result<void>> invite(String groupId, String username);

  Future<Result<void>> revokeInvitation(String groupId, String userId);

  /// The group's links, newest first (visible to inviters).
  Future<Result<List<InviteLink>>> inviteLinks(String groupId);

  Future<Result<InviteLink>> createInviteLink(String groupId, {required int days, int? maxUses});

  Future<Result<void>> revokeInviteLink(String groupId, String linkId);

  /// Null when no active group has this code.
  Future<Result<InvitePreview?>> invitePreview(String code);

  /// Joins with the link; returns the group's handle.
  Future<Result<String>> acceptInvite(String code);

  Future<Result<void>> assignRole(String groupId, String userId, GroupRole role);

  Future<Result<void>> removeRole(String groupId, String userId, GroupRole role);

  Future<Result<void>> transferOwnership(String groupId, String userId);
}
