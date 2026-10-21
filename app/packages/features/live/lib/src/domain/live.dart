import 'package:core/core.dart';

enum LiveStatus {
  scheduled('scheduled'),
  live('live'),
  ended('ended'),
  canceled('canceled');

  const LiveStatus(this.code);

  final String code;

  static LiveStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => ended);
}

/// Who someone is in a room; kept in their LiveKit attributes by the server (docs/ARCHITECTURE.md §8).
enum LiveRole {
  host('host', 'Sunucu'),
  speaker('speaker', 'Konuşmacı'),
  listener('listener', 'Dinleyici');

  const LiveRole(this.code, this.label);

  final String code;
  final String label;

  bool get onStage => this != listener;

  static LiveRole parse(Object? code) => values.firstWhere((r) => r.code == code, orElse: () => listener);
}

class LivePerson {
  const LivePerson({required this.id, required this.username, required this.displayName, this.avatarUrl});

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
}

class LiveGroup {
  const LiveGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

class LiveBroadcast {
  const LiveBroadcast({
    required this.id,
    required this.title,
    required this.status,
    required this.group,
    this.host,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.reminded = false,
  });

  final String id;
  final String title;
  final LiveStatus status;
  final LiveGroup group;

  /// Null when the host deleted their account.
  final LivePerson? host;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  /// The signed-in user asked to be notified when it starts.
  final bool reminded;

  bool get isLive => status == LiveStatus.live;

  /// A scheduled broadcast may start from 15 minutes before its time.
  bool canStartAt(DateTime now) =>
      status == LiveStatus.scheduled && !now.isBefore(scheduledAt!.subtract(const Duration(minutes: 15)));

  LiveBroadcast copyWith({bool? reminded}) => LiveBroadcast(
        id: id,
        title: title,
        status: status,
        group: group,
        host: host,
        scheduledAt: scheduledAt,
        startedAt: startedAt,
        endedAt: endedAt,
        reminded: reminded ?? this.reminded,
      );
}

/// A group's live and upcoming broadcasts.
class GroupLive {
  const GroupLive({this.live, this.scheduled = const [], this.minutesLeft});

  final LiveBroadcast? live;
  final List<LiveBroadcast> scheduled;

  /// This month's live minutes left; only for those who may start a broadcast.
  final int? minutesLeft;
}

class LiveComment {
  const LiveComment({required this.id, required this.author, required this.body, required this.createdAt});

  final int id;
  final LivePerson author;
  final String body;
  final DateTime createdAt;
}

/// What the room's comment list should do with a Realtime change.
sealed class LiveCommentChange {
  const LiveCommentChange();
}

final class LiveCommentAdded extends LiveCommentChange {
  const LiveCommentAdded(this.comment);

  final LiveComment comment;
}

final class LiveCommentRemoved extends LiveCommentChange {
  const LiveCommentRemoved(this.id);

  final int id;
}

/// Where and how to connect to a room.
class LiveJoin {
  const LiveJoin({required this.url, required this.token, required this.role});

  final String url;
  final String token;
  final LiveRole role;
}

/// Reactions travel as LiveKit data messages and are never stored.
abstract final class LiveReactions {
  static const topic = 'reaction';
  static const emojis = ['❤️', '👏', '😂', '🔥', '😮', '🙌'];

  /// At most three a second from one person.
  static const minInterval = Duration(milliseconds: 334);
}

/// Actions on another person in the room, as the server will allow them (docs/ARCHITECTURE.md §8).
enum LiveAction { inviteToStage, removeFromStage, mute, unmute, kick }

/// Someone else in the room as the actions menu sees them.
typedef LiveTarget = ({LiveRole role, int rank, bool muted});

/// [manager] is the host or a live.moderate holder. Sanctions need a higher rank; inviting does not.
List<LiveAction> liveActionsFor({required bool manager, required int myRank, required LiveTarget target}) {
  if (!manager) return const [];
  final outranks = myRank > target.rank;
  return [
    if (target.role == LiveRole.listener) LiveAction.inviteToStage,
    if (target.role == LiveRole.speaker && outranks) LiveAction.removeFromStage,
    if (target.role.onStage && outranks) target.muted ? LiveAction.unmute : LiveAction.mute,
    if (target.role != LiveRole.host && outranks) LiveAction.kick,
  ];
}

abstract interface class LiveRepository {
  Future<Result<GroupLive>> groupLive(String groupId);

  /// Fires when a broadcast of the group starts, ends or is scheduled.
  Stream<void> groupChanges(String groupId);

  /// Live right now in the signed-in user's groups.
  Future<Result<List<LiveBroadcast>>> myLive();

  Future<Result<LiveBroadcast>> broadcast(String id);

  /// The signed-in user's permissions in the group (`live.moderate` decides the room's menu).
  Future<Result<Set<String>>> myPermissions(String groupId);

  /// Starts now, or schedules when [scheduledAt] is given. Returns the broadcast id.
  Future<Result<String>> start(String groupId, {required String title, DateTime? scheduledAt});

  Future<Result<void>> startScheduled(String id);

  Future<Result<void>> cancel(String id);

  Future<Result<void>> end(String id);

  Future<Result<LiveJoin>> join(String id);

  Future<Result<void>> setHand(String id, {required bool raised});

  Future<Result<void>> inviteToStage(String id, String userId);

  /// Also used to leave the stage yourself.
  Future<Result<void>> removeFromStage(String id, String userId);

  Future<Result<void>> setMuted(String id, String userId, {required bool muted});

  Future<Result<void>> kick(String id, String userId);

  /// The latest comments, oldest first.
  Future<Result<List<LiveComment>>> comments(String id);

  Stream<LiveCommentChange> commentChanges(String id);

  Future<Result<void>> comment(String id, String body);

  /// Your own comment goes through Supabase, someone else's through the API.
  Future<Result<void>> deleteComment(String id, LiveComment comment);

  Future<Result<void>> setReminder(String id, {required bool on});
}
