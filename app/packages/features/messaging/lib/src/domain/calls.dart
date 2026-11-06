import 'package:core/core.dart';

import '../l10n.dart';

/// One-to-one voice calls between matched people (docs/ARCHITECTURE.md §8c).
enum CallStatus {
  ringing,
  active,
  ended,
  missed,
  declined,
  canceled;

  static CallStatus parse(Object? value) => values.where((s) => s.name == value).firstOrNull ?? ended;

  bool get isOpen => this == ringing || this == active;
}

class CallInfo {
  const CallInfo({
    required this.id,
    required this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.status,
    required this.createdAt,
    this.answeredAt,
    this.endReason,
  });

  final String id;
  final String conversationId;
  final String callerId;
  final String calleeId;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final String? endReason;

  String peerOf(String me) => callerId == me ? calleeId : callerId;

  /// Why the call is over, as the call screen says it to [me].
  String endedText(String me) {
    final l = messagingL10n;
    return switch (status) {
      CallStatus.missed => callerId == me ? l.noAnswer : l.missedCall,
      CallStatus.declined => callerId == me ? l.callDeclined : l.youDeclined,
      CallStatus.canceled => endReason == 'not_allowed' ? l.callNotAllowed : l.callCanceled,
      _ => switch (endReason) {
          'time_limit' => l.timeLimit,
          'not_allowed' => l.endedNotAllowed,
          _ => l.callEnded,
        },
    };
  }
}

/// Whether this chat may call now; when not, the sentence why (from the server).
class CallEligibility {
  const CallEligibility({required this.allowed, this.code, this.message});

  final bool allowed;
  final String? code;
  final String? message;

  /// Not worth showing a call button at all (not a one-to-one chat, or an account is closed).
  bool get hidden => code == 'call.forbidden';
}

class CallJoin {
  const CallJoin({required this.callId, required this.url, required this.token});

  final String callId;
  final String url;
  final String token;
}

enum CallPermissionStatus {
  none,
  requested,
  active,
  declined,
  revoked;

  static CallPermissionStatus parse(Object? value) => values.where((s) => s.name == value).firstOrNull ?? none;
}

class CallPermission {
  const CallPermission({
    this.status = CallPermissionStatus.none,
    this.note,
    this.reason,
    this.decidedAt,
    this.decidedByPerson = false,
    this.groupName,
  });

  final CallPermissionStatus status;
  final String? note;

  /// Why it was declined or closed.
  final String? reason;
  final DateTime? decidedAt;

  /// A group manager decided (not closed by leaving the group, which needs no wait).
  final bool decidedByPerson;

  /// The group the request went to (none for permissions the platform team opened before 2026-11-03).
  final String? groupName;

  /// Declined or closed by someone: asking again waits a week.
  DateTime? get canAskAgainAt => switch (status) {
        CallPermissionStatus.declined || CallPermissionStatus.revoked when decidedByPerson =>
          decidedAt?.add(CallRules.askAgainAfter),
        _ => null,
      };
}

/// A group the person may ask for voice calls.
class CallGroup {
  const CallGroup({required this.id, required this.name});

  final String id;
  final String name;
}

/// A member's request or open permission, as the group's managers see it.
class GroupCallRequest {
  const GroupCallRequest({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.rank,
    required this.status,
    this.avatarUrl,
    this.note,
    this.requestedAt,
    this.decidedAt,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  /// The person's rank in the group: declining and closing need a higher one (docs/ARCHITECTURE.md §8c).
  final int rank;
  final CallPermissionStatus status;
  final String? note;
  final DateTime? requestedAt;
  final DateTime? decidedAt;
}

/// The group's voice call requests for its owner and calls.manage holders.
class GroupCallDesk {
  const GroupCallDesk({required this.rank, required this.items});

  /// The manager's own rank.
  final int rank;
  final List<GroupCallRequest> items;

  List<GroupCallRequest> get pending => [for (final i in items) if (i.status == CallPermissionStatus.requested) i];

  List<GroupCallRequest> get active => [for (final i in items) if (i.status == CallPermissionStatus.active) i];
}

abstract final class CallRules {
  static const noteMax = 300;
  static const askAgainAfter = Duration(days: 7);
  static const maxLength = Duration(minutes: 60);
}

/// Profile bits the call screen shows for the other person.
class CallPeer {
  const CallPeer({required this.id, required this.displayName, required this.username, this.avatarUrl});

  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
}

abstract interface class CallsRepository {
  Future<Result<CallEligibility>> eligibility(String conversationId);

  Future<Result<CallJoin>> start(String conversationId);

  Future<Result<CallJoin>> accept(String callId);

  /// A new token: the caller while ringing, either person while connected.
  Future<Result<CallJoin>> rejoin(String callId);

  Future<Result<void>> decline(String callId);

  Future<Result<void>> end(String callId);

  /// The call as it changes (Realtime); ends when the call is gone.
  Stream<CallInfo?> watch(String callId);

  /// The call as it is now, read once; null when it is gone. Realtime can drop while the app sits in the background,
  /// so the call screen also reads the row itself (docs/ARCHITECTURE.md §8c, Cevapla her durumda açılır).
  Future<Result<CallInfo?>> fetch(String callId);

  /// Calls ringing for the signed-in person right now.
  Stream<List<CallInfo>> incoming();

  Future<Result<CallPeer>> peer(String userId);

  Future<Result<CallPermission>> myPermission();

  /// Groups the person belongs to, to send the request to.
  Future<Result<List<CallGroup>>> myGroups();

  Future<Result<void>> requestPermission(String groupId, String? note);

  /// Null when the person may not decide this group's requests.
  Future<Result<GroupCallDesk?>> groupDesk(String groupId);

  /// Opens a request ([active]), or declines it / closes the permission with a [reason].
  Future<Result<void>> decide(String groupId, String userId, {required bool active, String? reason});
}

