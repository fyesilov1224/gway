import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../domain/live.dart';

enum LiveSessionState { connecting, connected, failed, ended, kicked }

/// One person in the room as the screen shows them.
class LiveSeat {
  const LiveSeat({
    required this.id,
    required this.name,
    required this.role,
    required this.rank,
    required this.isMe,
    this.avatarUrl,
    this.handRaisedAt,
    this.mutedByModerator = false,
    this.micOn = false,
    this.speaking = false,
  });

  final String id;
  final String name;
  final LiveRole role;
  final int rank;
  final bool isMe;
  final String? avatarUrl;
  final DateTime? handRaisedAt;

  /// A room manager turned the microphone off; only a manager turns it back on.
  final bool mutedByModerator;
  final bool micOn;
  final bool speaking;

  LiveTarget get asTarget => (role: role, rank: rank, muted: mutedByModerator);
}

/// A connection to one LiveKit room. Permissions and attributes come from the server;
/// the client only toggles its own microphone and sends reactions.
class LiveSession extends ChangeNotifier {
  LiveSession({required LiveRepository repository, required this.broadcastId, required String? Function(String path) avatarUrl})
      : _repository = repository,
        _avatarUrl = avatarUrl;

  final LiveRepository _repository;
  final String broadcastId;
  final String? Function(String path) _avatarUrl;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _events;
  final _reactions = StreamController<String>.broadcast();
  DateTime _lastReaction = DateTime.fromMillisecondsSinceEpoch(0);
  bool _disposed = false;

  LiveSessionState state = LiveSessionState.connecting;
  String? errorMessage;

  /// Connected or still connecting.
  bool get isActive => state == LiveSessionState.connecting || state == LiveSessionState.connected;

  /// Emojis as they arrive, including your own.
  Stream<String> get reactions => _reactions.stream;

  Future<void> connect() async {
    state = LiveSessionState.connecting;
    errorMessage = null;
    _notify();
    final join = await _repository.join(broadcastId);
    switch (join) {
      case Err(:final failure):
        state = LiveSessionState.failed;
        errorMessage = failure.userMessage;
        _notify();
        return;
      case Ok(:final value):
        final room = lk.Room(roomOptions: const lk.RoomOptions(defaultAudioPublishOptions: lk.AudioPublishOptions(dtx: true)));
        _room = room;
        _events = room.createListener()
          ..on<lk.RoomDisconnectedEvent>((e) {
            state = e.reason == lk.DisconnectReason.participantRemoved ? LiveSessionState.kicked : LiveSessionState.ended;
            _notify();
          })
          ..on<lk.DataReceivedEvent>((e) {
            if (e.topic == LiveReactions.topic) _reactions.add(utf8.decode(e.data));
          });
        room.addListener(_notify);
        try {
          await room.connect(value.url, value.token);
          await room.startAudio();
          if (value.role == LiveRole.host) await room.localParticipant?.setMicrophoneEnabled(true);
          state = LiveSessionState.connected;
        } on Object catch (e) {
          debugPrint('LiveKit connect failed: $e');
          state = LiveSessionState.failed;
          errorMessage = 'Yayına bağlanılamadı. Bağlantını kontrol edip tekrar dene.';
        }
        _notify();
    }
  }

  List<LiveSeat> get seats {
    final room = _room;
    if (room == null) return const [];
    final me = room.localParticipant;
    return [
      if (me != null) _seat(me, isMe: true),
      for (final p in room.remoteParticipants.values) _seat(p, isMe: false),
    ];
  }

  LiveSeat? get me => seats.where((s) => s.isMe).firstOrNull;

  /// Hands up, first raised first.
  List<LiveSeat> get raisedHands =>
      [for (final s in seats) if (s.role == LiveRole.listener && s.handRaisedAt != null) s]
        ..sort((a, b) => a.handRaisedAt!.compareTo(b.handRaisedAt!));

  LiveSeat _seat(lk.Participant p, {required bool isMe}) {
    final a = p.attributes;
    final hand = int.tryParse(a['hand'] ?? '');
    final avatar = a['avatar'] ?? '';
    return LiveSeat(
      id: p.identity,
      name: p.name.isEmpty ? 'Katılımcı' : p.name,
      role: LiveRole.parse(a['role']),
      rank: int.tryParse(a['rank'] ?? '') ?? 0,
      isMe: isMe,
      avatarUrl: avatar.isEmpty ? null : _avatarUrl(avatar),
      handRaisedAt: hand == null ? null : DateTime.fromMillisecondsSinceEpoch(hand),
      mutedByModerator: a['muted'] == '1',
      micOn: p.isMicrophoneEnabled(),
      speaking: p.isSpeaking,
    );
  }

  /// Turns your microphone on or off; the server decides whether you may publish at all.
  Future<String?> setMicrophone(bool on) async {
    final local = _room?.localParticipant;
    if (local == null) return null;
    if (on && !local.permissions.canPublish) return 'Mikrofonunu yalnızca yayın yöneticisi açabilir.';
    try {
      await local.setMicrophoneEnabled(on);
      return null;
    } on Object catch (e) {
      debugPrint('Microphone failed: $e');
      return 'Mikrofon açılamadı. Mikrofon iznini kontrol et.';
    }
  }

  Future<void> sendReaction(String emoji) async {
    final now = DateTime.now();
    final local = _room?.localParticipant;
    if (local == null || now.difference(_lastReaction) < LiveReactions.minInterval) return;
    _lastReaction = now;
    _reactions.add(emoji);
    await local.publishData(utf8.encode(emoji), reliable: false, topic: LiveReactions.topic);
  }

  Future<void> leave() async {
    await _room?.disconnect();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final room = _room;
    room?.removeListener(_notify);
    unawaited(_events?.dispose());
    unawaited(room?.disconnect().then((_) => room.dispose()));
    unawaited(_reactions.close());
    super.dispose();
  }
}
