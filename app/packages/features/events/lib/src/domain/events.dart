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

  bool get isCanceled => canceledAt != null;
  bool hasStarted(DateTime now) => !startsAt.isAfter(now);
  bool get isFull => capacity != null && goingCount >= capacity!;

  /// Joining still possible: not canceled and not started.
  bool isOpen(DateTime now) => !isCanceled && !hasStarted(now);
}

class EventDetail {
  const EventDetail({required this.event, this.canManage = false, this.isMember = false, this.attendees, this.requests});

  final GroupEvent event;
  final bool canManage;
  final bool isMember;

  /// The first people going; members only.
  final List<EventPerson>? attendees;

  /// Join requests waiting for approval, oldest first; managers only.
  final List<EventPerson>? requests;
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
