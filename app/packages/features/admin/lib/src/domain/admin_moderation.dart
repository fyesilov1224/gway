import 'package:core/core.dart';

import 'admin_user.dart';

enum AdminReportScope {
  platform('platform', 'Platform'),
  group('group', 'Grup');

  const AdminReportScope(this.code, this.label);

  final String code;
  final String label;
}

enum AdminReportStatus {
  open('open', 'Açık'),
  dismissed('dismissed', 'Reddedilen'),
  actioned('actioned', 'İşlem yapılan');

  const AdminReportStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminReportStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => open);
}

const reportReasonLabels = {
  'spam': 'Spam ya da yanıltıcı',
  'harassment': 'Taciz ya da zorbalık',
  'hate': 'Nefret söylemi',
  'violence': 'Şiddet ya da tehdit',
  'sexual': 'Cinsel içerik',
  'misinformation': 'Yanlış bilgi',
  'other': 'Diğer',
};

const reportTargetLabels = {
  'post': 'Gönderi',
  'comment': 'Yorum',
  'event': 'Organizasyon',
  'live_comment': 'Canlı yayın yorumu',
  'message': 'Mesaj',
  'user': 'Kullanıcı',
  'match_profile': 'Eşleşme profili',
  'match_photo': 'Eşleşme fotoğrafı',
};

const sanctionLabels = {'warning': 'Uyarı', 'mute': 'Susturma', 'kick': 'Gruptan çıkarma', 'ban': 'Ban'};

DateTime? _time(Object? v) => v == null ? null : DateTime.parse(v as String);

class AdminReport {
  const AdminReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.excerpt,
    required this.status,
    required this.openCount,
    required this.createdAt,
    this.postId,
    this.groupId,
    this.groupName,
    this.groupHandle,
    this.reporterId,
    this.reporterUsername,
    this.subjectId,
    this.subjectUsername,
    this.note,
    this.reviewedAt,
  });

  factory AdminReport.fromJson(Map<String, Object?> j) => AdminReport(
        id: j['id']! as String,
        targetType: j['targetType']! as String,
        targetId: j['targetId']! as String,
        postId: j['postId'] as String?,
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        groupHandle: j['groupHandle'] as String?,
        reporterId: j['reporterId'] as String?,
        reporterUsername: j['reporterUsername'] as String?,
        subjectId: j['subjectId'] as String?,
        subjectUsername: j['subjectUsername'] as String?,
        reason: j['reason']! as String,
        note: j['note'] as String?,
        excerpt: j['excerpt']! as String,
        status: AdminReportStatus.parse(j['status']),
        openCount: j['openCount']! as int,
        createdAt: DateTime.parse(j['createdAt']! as String),
        reviewedAt: _time(j['reviewedAt']),
      );

  final String id;
  final String targetType;
  final String targetId;

  /// The post itself, or the post of a reported comment.
  final String? postId;
  final String? groupId;
  final String? groupName;
  final String? groupHandle;
  final String? reporterId;
  final String? reporterUsername;
  final String? subjectId;
  final String? subjectUsername;
  final String reason;
  final String? note;
  final String excerpt;
  final AdminReportStatus status;

  /// Open reports of the same target; a decision closes them all.
  final int openCount;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  String get reasonLabel => reportReasonLabels[reason] ?? reason;

  String get targetLabel => reportTargetLabels[targetType] ?? targetType;
}

enum AdminAppealStatus {
  pending('pending', 'Bekleyen'),
  upheld('upheld', 'Yaptırım sürdü'),
  overturned('overturned', 'Yaptırım kaldırıldı');

  const AdminAppealStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminAppealStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => pending);
}

/// An appeal the platform decides: the group's owner took part in the case (docs/ARCHITECTURE.md §3e).
class AdminAppeal {
  const AdminAppeal({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.sanctionType,
    required this.caseReason,
    required this.body,
    required this.status,
    required this.createdAt,
    this.username,
    this.sanctionEndsAt,
    this.decisionNote,
    this.decidedAt,
  });

  factory AdminAppeal.fromJson(Map<String, Object?> j) => AdminAppeal(
        id: j['id']! as String,
        userId: j['userId']! as String,
        username: j['username'] as String?,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        sanctionType: j['sanctionType']! as String,
        sanctionEndsAt: _time(j['sanctionEndsAt']),
        caseReason: j['caseReason']! as String,
        body: j['body']! as String,
        status: AdminAppealStatus.parse(j['status']),
        decisionNote: j['decisionNote'] as String?,
        createdAt: DateTime.parse(j['createdAt']! as String),
        decidedAt: _time(j['decidedAt']),
      );

  final String id;
  final String userId;
  final String? username;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final String sanctionType;
  final DateTime? sanctionEndsAt;
  final String caseReason;
  final String body;
  final AdminAppealStatus status;
  final String? decisionNote;
  final DateTime createdAt;
  final DateTime? decidedAt;

  String get sanctionLabel => sanctionLabels[sanctionType] ?? sanctionType;
}

/// Illegal-activity kinds a board may mark a ban case with (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet).
const illegalCategoryLabels = {
  'violence': 'Şiddet',
  'threat': 'Tehdit',
  'insult': 'Hakaret',
  'hate': 'Nefret söylemi',
  'sexual': 'Cinsel istismar',
  'fraud': 'Dolandırıcılık',
  'drugs': 'Uyuşturucu',
  'terror': 'Terör',
  'other_crime': 'Başka bir suç',
};

enum AdminReferralStatus {
  pending('pending', 'Karar bekliyor'),
  banned('banned', 'Banlandı'),
  cleared('cleared', 'Temize çıktı');

  const AdminReferralStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminReferralStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => pending);
}

enum LawEnforcementState {
  none('none', 'Kolluk bildirimi yok'),
  toNotify('to_notify', 'Kolluğa bildirilecek'),
  notified('notified', 'Kolluğa bildirildi');

  const LawEnforcementState(this.code, this.label);

  final String code;
  final String label;

  static LawEnforcementState parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => none);
}

/// A copy of one report the case was built on; it stays even if the content is deleted.
class AdminReferralEvidence {
  const AdminReferralEvidence({required this.targetType, required this.reason, required this.excerpt, this.note, this.reportedAt});

  factory AdminReferralEvidence.fromJson(Map<String, Object?> j) => AdminReferralEvidence(
        targetType: j['targetType'] as String? ?? '',
        reason: j['reason'] as String? ?? '',
        excerpt: j['excerpt'] as String? ?? '',
        note: j['note'] as String?,
        reportedAt: _time(j['reportedAt']),
      );

  final String targetType;
  final String reason;
  final String excerpt;
  final String? note;
  final DateTime? reportedAt;

  String get targetLabel => reportTargetLabels[targetType] ?? targetType;
}

/// An approved illegal-activity case a group board sent to the platform team.
class AdminReferral {
  const AdminReferral({
    required this.id,
    required this.groupName,
    required this.subjectId,
    required this.category,
    required this.reason,
    required this.evidence,
    required this.status,
    required this.lawEnforcement,
    required this.createdAt,
    this.groupId,
    this.subjectUsername,
    this.banUntil,
    this.authoritiesNote,
    this.authoritiesNotifiedAt,
    this.decisionNote,
    this.decidedAt,
  });

  factory AdminReferral.fromJson(Map<String, Object?> j) => AdminReferral(
        id: j['id']! as String,
        groupId: j['groupId'] as String?,
        groupName: j['groupName']! as String,
        subjectId: j['subjectId']! as String,
        subjectUsername: j['subjectUsername'] as String?,
        category: j['category']! as String,
        reason: j['reason']! as String,
        evidence: [for (final e in j['evidence'] as List? ?? const []) AdminReferralEvidence.fromJson((e as Map).cast())],
        status: AdminReferralStatus.parse(j['status']),
        banUntil: _time(j['banUntil']),
        lawEnforcement: LawEnforcementState.parse(j['lawEnforcement']),
        authoritiesNote: j['authoritiesNote'] as String?,
        authoritiesNotifiedAt: _time(j['authoritiesNotifiedAt']),
        decisionNote: j['decisionNote'] as String?,
        decidedAt: _time(j['decidedAt']),
        createdAt: DateTime.parse(j['createdAt']! as String),
      );

  final String id;
  final String? groupId;
  final String groupName;
  final String subjectId;
  final String? subjectUsername;
  final String category;
  final String reason;
  final List<AdminReferralEvidence> evidence;
  final AdminReferralStatus status;
  final DateTime? banUntil;
  final LawEnforcementState lawEnforcement;
  final String? authoritiesNote;
  final DateTime? authoritiesNotifiedAt;
  final String? decisionNote;
  final DateTime? decidedAt;
  final DateTime createdAt;

  String get categoryLabel => illegalCategoryLabels[category] ?? category;
}

/// What a decision did: after a ban, how many paid slices ended and how many owned groups were suspended.
class AdminReferralOutcome {
  const AdminReferralOutcome({required this.banned, this.canceledPlans = 0, this.suspendedGroups = 0});

  factory AdminReferralOutcome.fromJson(Map<String, Object?> j) => AdminReferralOutcome(
        banned: j['banned'] == true,
        canceledPlans: (j['canceledPlans'] as num?)?.toInt() ?? 0,
        suspendedGroups: (j['suspendedGroups'] as List?)?.length ?? 0,
      );

  final bool banned;
  final int canceledPlans;
  final int suspendedGroups;
}

typedef AdminReportPage = PagedList<AdminReport>;
typedef AdminAppealPage = PagedList<AdminAppeal>;
typedef AdminReferralPage = PagedList<AdminReferral>;

abstract interface class AdminModerationRepository {
  Future<Result<AdminReportPage>> reports({AdminReportScope? scope, AdminReportStatus? status, int page = 1});

  /// Closes the open reports of the target: dismissed, or [actioned] after acting with the other pages' tools.
  Future<Result<void>> review(String reportId, {required bool actioned});

  Future<Result<AdminAppealPage>> appeals({AdminAppealStatus? status, int page = 1});

  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, required String note});

  Future<Result<AdminReferralPage>> referrals({AdminReferralStatus? status, int page = 1});

  /// Bans the account for [banDays] (null: for good) or clears it; [lawEnforcement] marks it for the authorities.
  Future<Result<AdminReferralOutcome>> decideReferral(
    String referralId, {
    required bool ban,
    int? banDays,
    required bool lawEnforcement,
    required String note,
  });

  Future<Result<void>> markAuthoritiesNotified(String referralId, {required String note});

  Future<Result<void>> removeMessage(String messageId, {required String reason});
}
