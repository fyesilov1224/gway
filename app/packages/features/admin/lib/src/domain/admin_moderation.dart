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

typedef AdminReportPage = PagedList<AdminReport>;
typedef AdminAppealPage = PagedList<AdminAppeal>;

abstract interface class AdminModerationRepository {
  Future<Result<AdminReportPage>> reports({AdminReportScope? scope, AdminReportStatus? status, int page = 1});

  /// Closes the open reports of the target: dismissed, or [actioned] after acting with the other pages' tools.
  Future<Result<void>> review(String reportId, {required bool actioned});

  Future<Result<AdminAppealPage>> appeals({AdminAppealStatus? status, int page = 1});

  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, required String note});

  /// The reported message and the five before it; every viewing is audited (docs/ARCHITECTURE.md §3f).
  Future<Result<List<AdminContextMessage>>> messageContext(String reportId);

  Future<Result<void>> removeMessage(String messageId, {required String reason});
}

/// A private message the platform team sees only around a report.
class AdminContextMessage {
  const AdminContextMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.senderUsername,
    this.senderName,
    this.hasImage = false,
    this.deleted = false,
    this.reported = false,
  });

  factory AdminContextMessage.fromJson(Map<String, Object?> j) => AdminContextMessage(
        id: j['id']! as String,
        senderId: j['senderId']! as String,
        senderUsername: j['senderUsername'] as String?,
        senderName: j['senderName'] as String?,
        body: j['body']! as String,
        hasImage: j['hasImage'] == true,
        createdAt: DateTime.parse(j['createdAt']! as String),
        deleted: j['deleted'] == true,
        reported: j['reported'] == true,
      );

  final String id;
  final String senderId;
  final String? senderUsername;
  final String? senderName;
  final String body;
  final bool hasImage;
  final DateTime createdAt;
  final bool deleted;

  /// The message the report is about.
  final bool reported;
}
