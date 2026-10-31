import 'package:core/core.dart';

import 'admin_user.dart';

enum AdminEventStatus {
  upcoming('upcoming', 'Yaklaşan'),
  past('past', 'Geçmiş'),
  canceled('canceled', 'İptal edilen');

  const AdminEventStatus(this.code, this.label);

  final String code;
  final String label;
}

class AdminEvent {
  const AdminEvent({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.startsAt,
    required this.location,
    required this.goingCount,
    required this.waitlistCount,
    this.capacity,
    this.canceledAt,
    this.cancelReason,
    this.approvalRequired = false,
    this.requestedCount = 0,
    this.ratingAvg,
    this.ratingCount = 0,
    this.postsCount = 0,
    this.meetingLat,
    this.meetingLng,
    this.seriesId,
    this.seriesWeeks,
    this.seriesActive = false,
    this.confirmedCount = 0,
    this.surpriseRevealHours,
    this.surpriseVenue,
    this.venueRevealedAt,
  });

  factory AdminEvent.fromJson(Map<String, Object?> j) => AdminEvent(
        id: j['id']! as String,
        title: j['title']! as String,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        location: j['location']! as String,
        capacity: j['capacity'] as int?,
        goingCount: j['goingCount']! as int,
        waitlistCount: j['waitlistCount']! as int,
        canceledAt: j['canceledAt'] == null ? null : DateTime.parse(j['canceledAt']! as String),
        cancelReason: j['cancelReason'] as String?,
        approvalRequired: j['approvalRequired'] as bool? ?? false,
        requestedCount: j['requestedCount'] as int? ?? 0,
        ratingAvg: (j['ratingAvg'] as num?)?.toDouble(),
        ratingCount: j['ratingCount'] as int? ?? 0,
        postsCount: j['postsCount'] as int? ?? 0,
        meetingLat: (j['meetingLat'] as num?)?.toDouble(),
        meetingLng: (j['meetingLng'] as num?)?.toDouble(),
        seriesId: j['seriesId'] as String?,
        seriesWeeks: j['seriesWeeks'] as int?,
        seriesActive: j['seriesActive'] == true,
        confirmedCount: j['confirmedCount'] as int? ?? 0,
        surpriseRevealHours: j['surpriseRevealHours'] as int?,
        surpriseVenue: j['surpriseVenue'] as String?,
        venueRevealedAt: j['venueRevealedAt'] == null ? null : DateTime.parse(j['venueRevealedAt']! as String),
      );

  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final DateTime startsAt;
  final String location;
  final int? capacity;
  final int goingCount;
  final int waitlistCount;
  final DateTime? canceledAt;
  final String? cancelReason;

  /// Joining needs a manager's approval; [requestedCount] people are waiting.
  final bool approvalRequired;
  final int requestedCount;

  /// Attendees' average stars and memories (Faz 10).
  final double? ratingAvg;
  final int ratingCount;
  final int postsCount;

  /// The meeting point picked on the map (Faz 14); staff may remove an inappropriate one.
  final double? meetingLat;
  final double? meetingLng;

  /// The repeat the date belongs to (Faz 18k); staff may stop a running one.
  final String? seriesId;
  final int? seriesWeeks;
  final bool seriesActive;

  /// Going attendees who said "Evet, geliyorum" (Faz 18l).
  final int confirmedCount;

  /// Set for a surprise: [location] is the public hint, [surpriseVenue] the hidden venue staff always see.
  final int? surpriseRevealHours;
  final String? surpriseVenue;
  final DateTime? venueRevealedAt;

  String? get surpriseLabel => surpriseRevealHours == null
      ? null
      : 'Sürpriz: ${surpriseVenue ?? '—'} · $surpriseRevealHours saat önce ${venueRevealedAt == null ? 'açıklanacak' : 'açıklandı'}';

  bool get isCanceled => canceledAt != null;

  String? get seriesLabel => seriesWeeks == null
      ? null
      : '${seriesWeeks == 1 ? 'Her hafta' : 'İki haftada bir'}${seriesActive ? '' : ' (durduruldu)'}';

  String? get meetingLabel =>
      meetingLat == null ? null : '${meetingLat!.toStringAsFixed(5)}, ${meetingLng!.toStringAsFixed(5)}';
}

typedef AdminEventPage = PagedList<AdminEvent>;

enum AdminGoalStatus {
  running('running', 'Süren'),
  ended('ended', 'Biten'),
  canceled('canceled', 'İptal edilen');

  const AdminGoalStatus(this.code, this.label);

  final String code;
  final String label;
}

const goalKindLabels = {'personal': 'Kişisel', 'group': 'Grup', 'team': 'Takım', 'task': 'Onaylı görev'};
const goalMetricLabels = {'attended': 'katılım', 'organized': 'düzenleme', 'memories': 'anı'};

/// A group's goal (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).
class AdminGoal {
  const AdminGoal({
    required this.id,
    required this.title,
    required this.kind,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.startsAt,
    required this.endsAt,
    required this.completions,
    this.metric,
    this.target,
    this.canceledAt,
  });

  factory AdminGoal.fromJson(Map<String, Object?> j) => AdminGoal(
        id: j['id']! as String,
        title: j['title']! as String,
        kind: j['kind']! as String,
        metric: j['metric'] as String?,
        target: j['target'] as int?,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        endsAt: DateTime.parse(j['endsAt']! as String),
        canceledAt: j['canceledAt'] == null ? null : DateTime.parse(j['canceledAt']! as String),
        completions: j['completions']! as int,
      );

  final String id;
  final String title;
  final String kind;
  final String? metric;
  final int? target;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;
  final int completions;

  bool get isRunning => canceledAt == null && endsAt.isAfter(DateTime.now());

  String get summary => [
        goalKindLabels[kind] ?? kind,
        if (target != null) '$target ${goalMetricLabels[metric] ?? ''}',
        '$completions tamamlayan',
      ].join(' · ');
}

typedef AdminGoalPage = PagedList<AdminGoal>;

/// `2026-10` for the admin API.
String leagueMonthCode(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';

/// One league of a month on the admin page (docs/ARCHITECTURE.md §3d, Gruplar Ligi).
class AdminLeague {
  const AdminLeague({
    required this.category,
    required this.categoryName,
    required this.province,
    required this.groups,
    required this.leaderId,
    required this.leaderName,
    required this.leaderPoints,
    this.excluded = 0,
  });

  factory AdminLeague.fromJson(Map<String, Object?> j) => AdminLeague(
        category: j['category']! as String,
        categoryName: j['categoryName']! as String,
        province: j['province']! as int,
        groups: j['groups']! as int,
        leaderId: j['leaderId']! as String,
        leaderName: j['leaderName']! as String,
        leaderPoints: j['leaderPoints']! as int,
        excluded: j['excluded'] as int? ?? 0,
      );

  final String category;
  final String categoryName;
  final int province;
  final int groups;
  final String leaderId;
  final String leaderName;
  final int leaderPoints;
  final int excluded;
}

class AdminLeagueMonth {
  const AdminLeagueMonth({required this.month, this.finalized = false, this.leagues = const []});

  factory AdminLeagueMonth.fromJson(Map<String, Object?> j) => AdminLeagueMonth(
        month: DateTime.parse(j['month']! as String),
        finalized: j['finalized'] == true,
        leagues: [for (final l in (j['leagues']! as List).cast<Map<String, Object?>>()) AdminLeague.fromJson(l)],
      );

  final DateTime month;
  final bool finalized;
  final List<AdminLeague> leagues;
}

class AdminLeagueRow {
  const AdminLeagueRow({
    required this.rank,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.points,
    this.attended = 0,
    this.held = 0,
    this.welcomes = 0,
    this.goodReviews = 0,
  });

  factory AdminLeagueRow.fromJson(Map<String, Object?> j) {
    final g = (j['group']! as Map).cast<String, Object?>();
    return AdminLeagueRow(
      rank: j['rank']! as int,
      groupId: g['id']! as String,
      groupName: g['name']! as String,
      groupHandle: g['handle']! as String,
      points: j['points']! as int,
      attended: j['attended'] as int? ?? 0,
      held: j['held'] as int? ?? 0,
      welcomes: j['welcomes'] as int? ?? 0,
      goodReviews: j['good_reviews'] as int? ?? 0,
    );
  }

  final int rank;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final int points;
  final int attended;
  final int held;
  final int welcomes;
  final int goodReviews;

  String get breakdown => '$attended katılım · $held organizasyon · $welcomes karşılama · $goodReviews memnuniyet';
}

class AdminLeagueExclusion {
  const AdminLeagueExclusion({
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.reason,
    required this.createdAt,
    this.by,
  });

  factory AdminLeagueExclusion.fromJson(Map<String, Object?> j) => AdminLeagueExclusion(
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        reason: j['reason']! as String,
        createdAt: DateTime.parse(j['createdAt']! as String),
        by: j['by'] as String?,
      );

  final String groupId;
  final String groupName;
  final String groupHandle;
  final String reason;
  final DateTime createdAt;

  /// Username of the staff member; null when the account is gone.
  final String? by;
}

class AdminLeagueTable {
  const AdminLeagueTable({required this.finalized, this.rows = const [], this.exclusions = const []});

  factory AdminLeagueTable.fromJson(Map<String, Object?> j) {
    final t = (j['table']! as Map).cast<String, Object?>();
    return AdminLeagueTable(
      finalized: t['finalized'] == true,
      rows: [for (final r in (t['rows']! as List).cast<Map<String, Object?>>()) AdminLeagueRow.fromJson(r)],
      exclusions: [for (final x in (j['exclusions']! as List).cast<Map<String, Object?>>()) AdminLeagueExclusion.fromJson(x)],
    );
  }

  final bool finalized;
  final List<AdminLeagueRow> rows;
  final List<AdminLeagueExclusion> exclusions;
}

typedef AdminLeagueKey = ({DateTime month, String category, int province});

abstract interface class AdminEventsRepository {
  Future<Result<AdminEventPage>> search({String? query, AdminEventStatus? status, int page = 1});

  /// Cancels for everyone; attendees are notified.
  Future<Result<void>> cancel(String id, {required String reason});

  Future<Result<void>> removeMeetingPoint(String id);

  Future<Result<void>> stopSeries(String seriesId);

  Future<Result<AdminGoalPage>> goals({AdminGoalStatus? status, int page = 1});

  Future<Result<void>> cancelGoal(String id);

  Future<Result<AdminLeagueMonth>> leagues(DateTime month);

  Future<Result<AdminLeagueTable>> leagueTable(AdminLeagueKey key);

  /// Takes a group out of an open season; audited.
  Future<Result<void>> excludeFromLeague(DateTime month, String groupId, {required String reason});

  Future<Result<void>> restoreToLeague(DateTime month, String groupId);
}
