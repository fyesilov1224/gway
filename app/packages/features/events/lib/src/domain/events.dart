import 'package:core/core.dart';

class EventGroup {
  const EventGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

class EventPerson {
  const EventPerson({required this.id, required this.username, required this.displayName, this.avatarUrl});

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
}

enum AttendanceStatus {
  /// Waiting for a manager's approval (approval events, Faz 8).
  requested('requested'),
  going('going'),
  waitlisted('waitlisted');

  const AttendanceStatus(this.code);

  final String code;

  static AttendanceStatus? tryParse(Object? code) => values.where((s) => s.code == code).firstOrNull;
}

/// Shown only; the platform never collects it (docs/ARCHITECTURE.md §3d).
class EventFee {
  const EventFee({required this.amountMinor, required this.currency});

  final int amountMinor;

  /// `TRY`, `USD` or `EUR`.
  final String currency;

  String get label => formatMoney(amountMinor, currency);
}

class GroupEvent {
  const GroupEvent({
    required this.id,
    required this.group,
    required this.title,
    required this.startsAt,
    required this.location,
    this.description = '',
    this.endsAt,
    this.linkUrl,
    this.capacity,
    this.fee,
    this.feeNote,
    this.coverUrl,
    this.coverPath,
    this.goingCount = 0,
    this.waitlistCount = 0,
    this.canceledAt,
    this.cancelReason,
    this.myStatus,
    this.myPlace,
    this.categoryName,
    this.requirements = '',
    this.equipment = const [],
    this.approvalRequired = false,
    this.ratingAvg,
    this.ratingCount = 0,
    this.postsCount = 0,
  });

  final String id;
  final EventGroup group;

  /// The group's category (docs/ARCHITECTURE.md §3d, Faz 8).
  final String? categoryName;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String? linkUrl;

  /// Null means unlimited.
  final int? capacity;
  final EventFee? fee;
  final String? feeNote;
  final String? coverUrl;
  final String? coverPath;
  final int goingCount;
  final int waitlistCount;
  final DateTime? canceledAt;
  final String? cancelReason;
  final AttendanceStatus? myStatus;

  /// Place on the waitlist, 1 being next.
  final int? myPlace;

  /// Who may come and what to bring.
  final String requirements;
  final List<String> equipment;

  /// Joining sends a request a manager approves.
  final bool approvalRequired;

  /// Attendees' stars after the end (docs/ARCHITECTURE.md §3d, Organizasyon sonrası).
  final double? ratingAvg;
  final int ratingCount;

  /// Memories shared as posts.
  final int postsCount;

  bool get isCanceled => canceledAt != null;
  bool hasStarted(DateTime now) => !startsAt.isAfter(now);
  bool get isFull => capacity != null && goingCount >= capacity!;

  /// Joining still possible: not canceled and not started.
  bool isOpen(DateTime now) => !isCanceled && !hasStarted(now);

  /// Without an end an event takes two hours (as in the calendar file).
  DateTime get endsOrDefault => endsAt ?? startsAt.add(const Duration(hours: 2));

  bool hasEnded(DateTime now) => !endsOrDefault.isAfter(now);

  /// On the user's own calendar: attending, waiting or requested, and not canceled.
  bool get isMine => myStatus != null && !isCanceled;
}

/// Ids of the user's own events whose times overlap another of their own (docs/ARCHITECTURE.md §3d, Takvim).
Set<String> conflictingIds(Iterable<GroupEvent> events) {
  final mine = [for (final e in events) if (e.isMine) e]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  final ids = <String>{};
  for (var i = 0; i < mine.length; i++) {
    for (var j = i + 1; j < mine.length && mine[j].startsAt.isBefore(mine[i].endsOrDefault); j++) {
      ids..add(mine[i].id)..add(mine[j].id);
    }
  }
  return ids;
}

/// "4,6" — Turkish decimal comma.
String ratingLabel(double avg) => avg.toStringAsFixed(1).replaceAll('.', ',');

/// A review: the user's own, or one a manager reads.
class EventReview {
  const EventReview({required this.rating, this.comment = '', this.person, this.updatedAt});

  /// 1–5 stars.
  final int rating;
  final String comment;

  /// Who wrote it; set in the managers' list.
  final EventPerson? person;
  final DateTime? updatedAt;
}

/// A badge: earned (name and what it took) or, in the catalog, how to earn it (docs/ARCHITECTURE.md §3d, Katkı ve rozetler).
class ContributionBadge {
  const ContributionBadge({required this.slug, required this.name, required this.description});

  final String slug;
  final String name;
  final String description;
}

/// What a person did in groups, counted on the server from real records; no ranking.
class Contributions {
  const Contributions({
    this.attended = 0,
    this.organized = 0,
    this.memories = 0,
    this.reviews = 0,
    this.groups = 0,
    this.badges = const [],
  });

  final int attended;
  final int organized;
  final int memories;
  final int reviews;

  /// Different groups whose events the person attended.
  final int groups;
  final List<ContributionBadge> badges;

  bool get isEmpty => attended == 0 && organized == 0 && memories == 0 && reviews == 0;
}

/// A going attendee in the roll call, and whether they were marked as not there.
class RollEntry {
  const RollEntry({required this.person, this.noShow = false});

  final EventPerson person;
  final bool noShow;
}

/// Another event of the user at the same time.
class EventConflict {
  const EventConflict({required this.id, required this.title, required this.startsAt});

  final String id;
  final String title;
  final DateTime startsAt;
}

class EventDetail {
  const EventDetail({
    required this.event,
    this.canManage = false,
    this.isMember = false,
    this.attendees,
    this.requests,
    this.conflicts = const [],
    this.canPost = false,
    this.canReview = false,
    this.myReview,
    this.reviews,
    this.roll,
  });

  final GroupEvent event;
  final bool canManage;
  final bool isMember;

  /// The first people going; members only.
  final List<EventPerson>? attendees;

  /// Join requests waiting for approval, oldest first; managers only.
  final List<EventPerson>? requests;

  /// The user's other events at the same time.
  final List<EventConflict> conflicts;

  /// May share a memory (went, or manages; the event started).
  final bool canPost;

  /// Went, and the event ended less than 30 days ago.
  final bool canReview;
  final EventReview? myReview;

  /// Every review with its note; managers only.
  final List<EventReview>? reviews;

  /// Going attendees while the roll call is open (7 days after the end); managers only.
  final List<RollEntry>? roll;
}

class GroupEvents {
  const GroupEvents({this.events = const [], this.eventsLeft});

  final List<GroupEvent> events;

  /// Events the group may still create this month; managers only.
  final int? eventsLeft;
}

/// The create / edit form; an edit sends every field.
class EventForm {
  const EventForm({
    required this.title,
    required this.startsAt,
    required this.location,
    this.description = '',
    this.endsAt,
    this.linkUrl,
    this.capacity,
    this.fee,
    this.feeNote,
    this.coverPath,
    this.requirements = '',
    this.equipment = const [],
    this.approvalRequired = false,
  });

  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String? linkUrl;
  final int? capacity;
  final EventFee? fee;
  final String? feeNote;
  final String? coverPath;
  final String requirements;
  final List<String> equipment;
  final bool approvalRequired;

  Map<String, Object?> toJson() => {
        'title': title.trim(),
        'description': description.trim(),
        'startsAt': startsAt.toUtc().toIso8601String(),
        'endsAt': endsAt?.toUtc().toIso8601String(),
        'location': location.trim(),
        'linkUrl': linkUrl,
        'capacity': capacity,
        'feeAmount': fee?.amountMinor,
        'feeCurrency': fee?.currency,
        'feeNote': feeNote,
        'coverPath': coverPath,
        'requirements': requirements.trim(),
        'equipment': [for (final e in equipment) e.trim()],
        'approvalRequired': approvalRequired,
      };
}

class PollOption {
  const PollOption({required this.id, required this.label, this.votes = 0, this.mine = false});

  final int id;
  final String label;
  final int votes;
  final bool mine;
}

class Poll {
  const Poll({
    required this.id,
    required this.question,
    required this.options,
    this.eventId,
    this.allowsMultiple = false,
    this.isAnonymous = false,
    this.closesAt,
    this.isOpen = true,
    this.voters = 0,
  });

  final String id;
  final String? eventId;
  final String question;
  final List<PollOption> options;
  final bool allowsMultiple;
  final bool isAnonymous;
  final DateTime? closesAt;
  final bool isOpen;

  /// People who voted (one person may pick several options).
  final int voters;

  bool get voted => options.any((o) => o.mine);
  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  /// Share of the votes, 0–1.
  double share(PollOption o) => totalVotes == 0 ? 0 : o.votes / totalVotes;
}

class PollForm {
  const PollForm({
    required this.question,
    required this.options,
    this.allowsMultiple = false,
    this.isAnonymous = false,
    this.closesAt,
    this.eventId,
  });

  final String question;
  final List<String> options;
  final bool allowsMultiple;
  final bool isAnonymous;
  final DateTime? closesAt;
  final String? eventId;

  Map<String, Object?> toJson() => {
        'question': question.trim(),
        'options': [for (final o in options) o.trim()],
        'allowsMultiple': allowsMultiple,
        'isAnonymous': isAnonymous,
        'closesAt': closesAt?.toUtc().toIso8601String(),
        'eventId': eventId,
      };
}

typedef AttendanceResult = ({AttendanceStatus status, int? place});

abstract interface class EventsRepository {
  Future<Result<GroupEvents>> groupEvents(String groupId);

  Future<Result<EventDetail>> event(String id);

  /// Uploads a cover to the group's folder and returns its storage path.
  Future<Result<String>> uploadCover(String groupId, ImageUpload image);

  Future<Result<String>> create(String groupId, EventForm form);

  Future<Result<void>> update(String id, EventForm form);

  Future<Result<void>> cancel(String id, {required String reason});

  Future<Result<AttendanceResult>> attend(String id);

  Future<Result<void>> leave(String id);

  /// A manager's answer to a join request.
  Future<Result<void>> decideRequest(String eventId, String userId, {required bool approve});

  /// The event as an iCalendar file for "Takvime ekle".
  Uri calendarUrl(String id);

  /// The user's own review (Supabase, RLS); [comment] is for the managers only.
  Future<Result<void>> saveReview(String eventId, {required int rating, String comment = ''});

  Future<Result<void>> deleteReview(String eventId);

  /// Marks a going attendee as not there, or clears it (a manager, within 7 days after the end).
  Future<Result<void>> setNoShow(String eventId, String userId, {required bool noShow});

  /// Null when the person's content is private to the viewer.
  Future<Result<Contributions?>> contributions(String userId);

  /// Every badge and how to earn it.
  Future<Result<List<ContributionBadge>>> badgeCatalog();

  /// Attended and organized events in the group, per member who has any.
  Future<Result<Map<String, ({int attended, int organized})>>> groupContributions(String groupId);

  /// The group's past events, newest first; [before] pages back by start time.
  Future<Result<List<GroupEvent>>> history(String groupId, {DateTime? before});

  /// Events starting in [from, to) (at most 62 days): a group's, or the user's own and, with
  /// [includeGroups], every event of their groups.
  Future<Result<List<GroupEvent>>> calendar(DateTime from, DateTime to, {String? groupId, bool includeGroups = false});

  /// A group's polls, or only those of [eventId].
  Future<Result<List<Poll>>> polls(String groupId, {String? eventId});

  Future<Result<void>> createPoll(String groupId, PollForm form);

  Future<Result<void>> closePoll(String id);

  Future<Result<void>> deletePoll(String id);

  /// Replaces the signed-in user's votes on the poll with [optionIds].
  Future<Result<void>> vote(Poll poll, Set<int> optionIds);

  /// Who picked an option; open (not anonymous) polls only.
  Future<Result<List<EventPerson>>> voters(int optionId);
}
