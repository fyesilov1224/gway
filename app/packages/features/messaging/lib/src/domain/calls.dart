import 'package:core/core.dart';

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
  String endedText(String me) => switch (status) {
        CallStatus.missed => callerId == me ? 'Cevap verilmedi' : 'Cevapsız arama',
        CallStatus.declined => callerId == me ? 'Arama reddedildi' : 'Aramayı reddettin',
        CallStatus.canceled => endReason == 'not_allowed' ? 'Arama artık mümkün değil' : 'Arama iptal edildi',
        _ => switch (endReason) {
            'time_limit' => '60 dakika doldu, görüşme bitti',
            'not_allowed' => 'Görüşme sona erdi: sesli görüşme artık mümkün değil',
            _ => 'Görüşme bitti',
          },
      };
}

/// Whether this chat may call now; when not, the sentence why (from the server).
class CallEligibility {
  const CallEligibility({required this.allowed, this.code, this.message});

  final bool allowed;
  final String? code;
  final String? message;

  /// Not worth showing a call button at all (not a match chat, or the person has no permission yet).
  bool get hidden => code == 'call.forbidden' || code == 'call.not_matched';
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
  const CallPermission({this.status = CallPermissionStatus.none, this.note, this.reason, this.decidedAt});

  final CallPermissionStatus status;
  final String? note;

  /// Why it was declined or closed.
  final String? reason;
  final DateTime? decidedAt;

  /// Declined or closed: asking again waits a week.
  DateTime? get canAskAgainAt => switch (status) {
        CallPermissionStatus.declined || CallPermissionStatus.revoked => decidedAt?.add(CallRules.askAgainAfter),
        _ => null,
      };
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

  /// Calls ringing for the signed-in person right now.
  Stream<List<CallInfo>> incoming();

  Future<Result<CallPeer>> peer(String userId);

  Future<Result<CallPermission>> myPermission();

  Future<Result<void>> requestPermission(String? note);
}
