import 'package:core/core.dart';

import '../l10n.dart';

enum ReportReason {
  spam('spam'),
  harassment('harassment'),
  hate('hate'),
  violence('violence'),
  sexual('sexual'),
  misinformation('misinformation'),
  other('other');

  const ReportReason(this.code);

  final String code;

  String get label => switch (this) {
        spam => moderationL10n.reasonSpam,
        harassment => moderationL10n.reasonHarassment,
        hate => moderationL10n.reasonHate,
        violence => moderationL10n.reasonViolence,
        sexual => moderationL10n.reasonSexual,
        misinformation => moderationL10n.reasonMisinformation,
        other => moderationL10n.reasonOther,
      };

  static ReportReason parse(Object? code) => values.firstWhere((r) => r.code == code, orElse: () => other);
}

enum SanctionType {
  warning('warning'),
  mute('mute'),
  kick('kick'),
  ban('ban');

  const SanctionType(this.code);

  final String code;

  String get label => switch (this) {
        warning => moderationL10n.sanctionWarning,
        mute => moderationL10n.sanctionMute,
        kick => moderationL10n.sanctionKick,
        ban => moderationL10n.sanctionBan,
      };

  static SanctionType parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => warning);

  /// Allowed durations in days (docs/ARCHITECTURE.md §3e); null in the list is "permanent".
  List<int?> get durations => switch (this) {
        mute => const [1, 3, 7, 30, 90],
        ban => const [7, 30, 90, 365, null],
        _ => const [],
      };
}

/// What counts as illegal activity (docs/ARCHITECTURE.md §3e, Yasa dışı faaliyet). An approved ban case marked
/// with one goes to the platform team, which may close the account.
enum IllegalCategory {
  violence('violence'),
  threat('threat'),
  insult('insult'),
  hate('hate'),
  sexual('sexual'),
  fraud('fraud'),
  drugs('drugs'),
  terror('terror'),
  otherCrime('other_crime');

  const IllegalCategory(this.code);

  final String code;

  String get label => switch (this) {
        violence => moderationL10n.illegalViolence,
        threat => moderationL10n.illegalThreat,
        insult => moderationL10n.illegalInsult,
        hate => moderationL10n.illegalHate,
        sexual => moderationL10n.illegalSexual,
        fraud => moderationL10n.illegalFraud,
        drugs => moderationL10n.illegalDrugs,
        terror => moderationL10n.illegalTerror,
        otherCrime => moderationL10n.illegalOther,
      };

  static IllegalCategory? parse(Object? code) => values.where((c) => c.code == code).firstOrNull;
}

/// "7 gün ban", "Kalıcı ban", "Uyarı".
String sanctionLabel(SanctionType type, int? days) => switch (type) {
      SanctionType.mute => moderationL10n.muteDays(days ?? 0),
      SanctionType.ban => days == null ? moderationL10n.permanentBan : moderationL10n.banDays(days),
      _ => type.label,
    };

enum CaseThreshold {
  majority('majority'),
  twoThirds('two_thirds'),
  unanimous('unanimous');

  const CaseThreshold(this.code);

  final String code;

  String get label => switch (this) {
        majority => moderationL10n.thresholdMajority,
        twoThirds => moderationL10n.thresholdTwoThirds,
        unanimous => moderationL10n.thresholdUnanimous,
      };

  String get description => switch (this) {
        majority => moderationL10n.thresholdMajorityText,
        twoThirds => moderationL10n.thresholdTwoThirdsText,
        unanimous => moderationL10n.thresholdUnanimousText,
      };

  static CaseThreshold parse(Object? code) => values.firstWhere((t) => t.code == code, orElse: () => majority);
}

class ModerationPerson {
  const ModerationPerson({required this.id, required this.username, required this.displayName, this.avatarUrl, this.rank = 0});

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  /// Rank in the group (docs/ARCHITECTURE.md §3b); actions need a higher one.
  final int rank;
}

/// The open reports of one target, grouped; reporters are never shown to the group.
class GroupReport {
  const GroupReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.excerpt,
    required this.reasons,
    required this.count,
    required this.lastAt,
    this.subject,
    this.postId,
    this.notes = const [],
  });

  /// The newest report; actions apply to every open report of the target.
  final String id;
  final String targetType;
  final String targetId;

  /// The post of a reported comment, to open it in context.
  final String? postId;
  final ModerationPerson? subject;
  final String excerpt;
  final List<ReportReason> reasons;
  final List<String> notes;
  final int count;
  final DateTime lastAt;

  /// Comments and chat messages are removed by the group's moderation; posts and events by their managers.
  bool get removable => targetType == 'comment' || targetType == 'live_comment' || targetType == 'message';

  String get targetLabel => switch (targetType) {
        'post' => moderationL10n.targetPost,
        'comment' => moderationL10n.targetComment,
        'event' => moderationL10n.targetEvent,
        'live_comment' => moderationL10n.targetLiveComment,
        'message' => moderationL10n.targetMessage,
        _ => moderationL10n.targetMember,
      };
}

enum CaseStatus {
  voting('voting'),
  approved('approved'),
  rejected('rejected');

  const CaseStatus(this.code);

  final String code;

  static CaseStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => voting);
}

class ModerationCase {
  const ModerationCase({
    required this.id,
    required this.subject,
    required this.sanction,
    required this.reason,
    required this.status,
    required this.votingEndsAt,
    required this.createdAt,
    required this.voters,
    this.openedBy,
    this.durationDays,
    this.illegalCategory,
    this.direct = false,
    this.threshold = CaseThreshold.majority,
    this.decidedAt,
    this.approvals = 0,
    this.rejections = 0,
    this.isVoter = false,
    this.myVote,
  });

  final String id;
  final ModerationPerson subject;
  final ModerationPerson? openedBy;
  final SanctionType sanction;
  final int? durationDays;

  /// Set when the case is about illegal activity; approved, it goes to the platform team.
  final IllegalCategory? illegalCategory;

  /// A ban the owner or a Yönetici applied without a vote (§3e, Oylamasız ban).
  final bool direct;
  final String reason;
  final CaseThreshold threshold;
  final CaseStatus status;
  final DateTime votingEndsAt;
  final DateTime? decidedAt;
  final DateTime createdAt;
  final int voters;
  final int approvals;
  final int rejections;
  final bool isVoter;

  /// `true` approve, `false` reject, null not voted.
  final bool? myVote;

  bool get isOpen => status == CaseStatus.voting;

  String get proposal => sanctionLabel(sanction, durationDays);
}

enum AppealStatus {
  pending('pending'),
  upheld('upheld'),
  overturned('overturned');

  const AppealStatus(this.code);

  final String code;

  String get label => switch (this) {
        pending => moderationL10n.appealPending,
        upheld => moderationL10n.appealUpheld,
        overturned => moderationL10n.appealOverturned,
      };

  static AppealStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => pending);
}

class Appeal {
  const Appeal({required this.id, required this.body, required this.status, required this.createdAt, this.byPlatform = false, this.decisionNote});

  final String id;
  final String body;
  final AppealStatus status;

  /// The owner took part in the case: the platform team decides.
  final bool byPlatform;
  final String? decisionNote;
  final DateTime createdAt;
}

class GroupSanction {
  const GroupSanction({
    required this.id,
    required this.user,
    required this.type,
    required this.startsAt,
    required this.reason,
    this.interim = false,
    this.endsAt,
    this.liftedAt,
    this.appeal,
  });

  final String id;
  final ModerationPerson user;
  final SanctionType type;
  final bool interim;
  final DateTime startsAt;
  final DateTime? endsAt;
  final DateTime? liftedAt;
  final String reason;
  final Appeal? appeal;

  bool get isRunning => liftedAt == null && (endsAt == null ? type == SanctionType.ban : endsAt!.isAfter(DateTime.now()));
}

/// The moderation desk of a group for reports.review holders (docs/ARCHITECTURE.md §3e).
class GroupModeration {
  const GroupModeration({
    required this.rank,
    this.isOwner = false,
    this.canMute = false,
    this.canBan = false,
    this.threshold = CaseThreshold.majority,
    this.reports = const [],
    this.cases = const [],
    this.sanctions = const [],
  });

  final int rank;
  final bool isOwner;
  final bool canMute;

  /// members.ban: a ban without the board's vote.
  final bool canBan;
  final CaseThreshold threshold;
  final List<GroupReport> reports;
  final List<ModerationCase> cases;
  final List<GroupSanction> sanctions;

  int get awaitingMyVote => cases.where((c) => c.isOpen && c.isVoter && c.myVote == null).length;

  /// Appeals the owner decides.
  List<GroupSanction> get pendingAppeals => [
        if (isOwner)
          for (final s in sanctions)
            if (s.appeal case Appeal(status: AppealStatus.pending, byPlatform: false)) s,
      ];

  /// Open work, for the entry card on the group page.
  int get pending => reports.length + awaitingMyVote + pendingAppeals.length;
}

class SanctionGroup {
  const SanctionGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

/// One of the user's own sanctions.
class MySanction {
  const MySanction({
    required this.id,
    required this.group,
    required this.type,
    required this.startsAt,
    required this.reason,
    this.interim = false,
    this.endsAt,
    this.liftedAt,
    this.canAppeal = false,
    this.appeal,
  });

  final String id;
  final SanctionGroup group;
  final SanctionType type;
  final bool interim;
  final DateTime startsAt;
  final DateTime? endsAt;
  final DateTime? liftedAt;
  final String reason;
  final bool canAppeal;
  final Appeal? appeal;
}

class CaseForm {
  const CaseForm({
    required this.subjectId,
    required this.sanction,
    required this.reason,
    this.durationDays,
    this.reportId,
    this.muteNow = false,
    this.illegalCategory,
    this.direct = false,
  });

  final String subjectId;
  final SanctionType sanction;
  final int? durationDays;
  final String reason;
  final String? reportId;
  final bool muteNow;

  /// Only with a ban.
  final IllegalCategory? illegalCategory;

  /// A ban applied at once, without the board's vote (members.ban).
  final bool direct;

  Map<String, Object?> toJson() => {
        'subjectId': subjectId,
        'sanction': sanction.code,
        'durationDays': durationDays,
        'reason': reason.trim(),
        'reportId': reportId,
        'muteNow': muteNow,
        'illegalCategory': illegalCategory?.code,
        'direct': direct,
      };

}

abstract interface class ModerationRepository {
  /// The user's own report (Supabase, RLS).
  Future<Result<void>> report(ReportTarget target, ReportReason reason, {String? note});

  /// Null when the user may not review the group's reports.
  Future<Result<GroupModeration?>> groupModeration(String groupId);

  Future<Result<void>> dismiss(String reportId);

  Future<Result<void>> removeContent(String reportId, {required String reason});

  Future<Result<void>> openCase(String groupId, CaseForm form);

  /// Returns the case status after the vote.
  Future<Result<CaseStatus>> vote(String caseId, {required bool approve});

  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, String? note});

  Future<Result<void>> setThreshold(String groupId, CaseThreshold threshold);

  Future<Result<List<MySanction>>> mySanctions();

  /// The user's own appeal (Supabase, RLS).
  Future<Result<void>> appeal(String sanctionId, String body);
}
