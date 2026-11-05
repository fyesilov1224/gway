import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/live_encryption.dart';
import '../domain/live.dart';
import '../l10n.dart';
import 'live_key_exchange.dart';

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
/// the client only toggles its own microphone and sends reactions. The sound is end-to-end encrypted with a key the
/// phones share among themselves ([LiveKeyExchange], docs/ARCHITECTURE.md §8); the microphone opens only once the
/// key is here.
class LiveSession extends ChangeNotifier {
  LiveSession({required LiveRepository repository, required this.broadcastId, required String? Function(String path) avatarUrl})
      : _repository = repository,
        _avatarUrl = avatarUrl;

  final LiveRepository _repository;
  final String broadcastId;
  final String? Function(String path) _avatarUrl;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _events;
  lk.BaseKeyProvider? _keys;
  LiveKeyExchange? _exchange;
  final _reactions = StreamController<String>.broadcast();
  DateTime _lastReaction = DateTime.fromMillisecondsSinceEpoch(0);
  bool _micWanted = false;
  bool _leaving = false;
  bool _disposed = false;

  LiveSessionState state = LiveSessionState.connecting;
  String? errorMessage;

  /// Someone on stage sent sound that was not encrypted (an older app version); it is not played.
  bool peerUnencrypted = false;

  /// Connected or still connecting.
  bool get isActive => state == LiveSessionState.connecting || state == LiveSessionState.connected;

  /// The room key is here: sound goes out and comes in encrypted.
  bool get secure => _exchange?.key != null;

  /// The 12 digits everyone in the room sees alike; null until [secure].
  String? get safetyCode => _exchange?.key?.safetyCode;

  LiveCheck get check => _exchange?.check ?? LiveCheck.waiting;

  /// Emojis as they arrive, including your own.
  Stream<String> get reactions => _reactions.stream;

  Future<void> connect() async {
    if (_disposed) return;
    // A retry starts from a clean room: the failed one is closed first.
    if (_room != null) await _drop();
    _leaving = false;
    state = LiveSessionState.connecting;
    errorMessage = null;
    peerUnencrypted = false;
    _notify();
    final join = await _repository.join(broadcastId);
    if (_disposed) return;
    switch (join) {
      case Err(:final failure):
        state = LiveSessionState.failed;
        errorMessage = failure.userMessage;
        _notify();
        return;
      case Ok(:final value):
        try {
          final keys = await lk.BaseKeyProvider.create();
          final room = lk.Room(
            roomOptions: lk.RoomOptions(
              defaultAudioPublishOptions: const lk.AudioPublishOptions(dtx: true),
              // Frame encryption only: the key exchange travels in data messages a newcomer must read before it has
              // the key (they are sealed on their own); `encryption` would encrypt data messages with the room key.
              // ignore: deprecated_member_use
              e2eeOptions: lk.E2EEOptions(keyProvider: keys),
            ),
          );
          _room = room;
          _keys = keys;
          _events = room.createListener()
            ..on<lk.RoomDisconnectedEvent>(_onDisconnected)
            ..on<lk.DataReceivedEvent>(_onData)
            ..on<lk.ParticipantDisconnectedEvent>((e) => _exchange?.left(e.participant.identity))
            ..on<lk.ParticipantAttributesChanged>((_) => _exchange?.stageChanged())
            ..on<lk.TrackSubscribedEvent>(_checkEncrypted);
          room.addListener(_notify);
          await room.connect(value.url, value.token);
          await room.startAudio();
          if (_room != room || _disposed) return;
          _micWanted = value.role == LiveRole.host;
          _exchange = LiveKeyExchange(
            broadcastId: broadcastId,
            me: room.localParticipant?.identity ?? '',
            room: _LiveKitKeyRoom(room),
            onKey: _useKey,
            onChange: _notify,
          )..start(amHost: value.role == LiveRole.host);
          state = LiveSessionState.connected;
        } on Object catch (e) {
          debugPrint('LiveKit connect failed: $e');
          await _drop();
          state = LiveSessionState.failed;
          errorMessage = liveL10n.connectFailed;
        }
        _notify();
    }
  }

  /// Why the room closed: removed by a manager, the broadcast ended, or the connection was lost (which can be
  /// retried). Before 2026-11-05 a lost connection said "thanks for joining" as if the broadcast had ended.
  void _onDisconnected(lk.RoomDisconnectedEvent e) {
    if (_leaving) return;
    state = switch (e.reason) {
      lk.DisconnectReason.participantRemoved => LiveSessionState.kicked,
      lk.DisconnectReason.roomDeleted => LiveSessionState.ended,
      // Opened on another device with the same account: this one steps aside.
      lk.DisconnectReason.duplicateIdentity => LiveSessionState.ended,
      _ => LiveSessionState.failed,
    };
    if (state == LiveSessionState.failed) errorMessage = liveL10n.connectionLost;
    _exchange?.dispose();
    _notify();
  }

  void _onData(lk.DataReceivedEvent e) {
    switch (e.topic) {
      case LiveReactions.topic:
        _reactions.add(utf8.decode(e.data, allowMalformed: true));
      case LiveKeyMessage.topic:
        final from = e.participant?.identity;
        final message = LiveKeyMessage.decode(e.data);
        if (from != null && message != null) _exchange?.receive(from, message);
    }
  }

  /// The room key arrived (or changed): encrypt and decrypt with it, then open the microphone if it was wanted.
  Future<void> _useKey(LiveRoomKey key) async {
    final keys = _keys;
    final room = _room;
    if (keys == null || room == null) return;
    await keys.setSharedKey(key.audioKey);
    final local = room.localParticipant;
    if (_micWanted && local != null && local.permissions.canPublish && !local.isMicrophoneEnabled()) {
      try {
        await local.setMicrophoneEnabled(true);
      } on Object catch (e) {
        debugPrint('Microphone failed: $e');
      }
    }
    _notify();
  }

  /// Sound that was not encrypted is never played.
  Future<void> _checkEncrypted(lk.TrackSubscribedEvent event) async {
    if (event.publication.encryptionType != lk.EncryptionType.kNone) return;
    peerUnencrypted = true;
    _notify();
    await event.publication.unsubscribe();
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
      name: p.name.isEmpty ? liveL10n.participant : p.name,
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

  /// Turns your microphone on or off; the server decides whether you may publish at all. Before the room key is
  /// here only the wish is kept: unencrypted sound is never sent.
  Future<String?> setMicrophone(bool on) async {
    final local = _room?.localParticipant;
    if (local == null) return null;
    if (on && !local.permissions.canPublish) return liveL10n.micNeedsManager;
    _micWanted = on;
    if (on && !secure) {
      _notify();
      return liveL10n.micAfterEncryption;
    }
    try {
      await local.setMicrophoneEnabled(on);
      return null;
    } on Object catch (e) {
      debugPrint('Microphone failed: $e');
      return liveL10n.micFailed;
    }
  }

  Future<void> sendReaction(String emoji) async {
    final now = DateTime.now();
    final local = _room?.localParticipant;
    if (local == null || now.difference(_lastReaction) < LiveReactions.minInterval) return;
    _lastReaction = now;
    _reactions.add(emoji);
    try {
      await local.publishData(utf8.encode(emoji), reliable: false, topic: LiveReactions.topic);
    } on Object catch (e) {
      debugPrint('Reaction not sent: $e');
    }
  }

  Future<void> leave() async {
    _leaving = true;
    await _drop();
  }

  /// Closes the current connection, if any, and forgets its keys.
  Future<void> _drop() async {
    _exchange?.dispose();
    _exchange = null;
    _keys = null;
    final room = _room;
    _room = null;
    final events = _events;
    _events = null;
    await events?.dispose();
    if (room == null) return;
    room.removeListener(_notify);
    await room.disconnect().catchError((Object _) {});
    await room.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _leaving = true;
    unawaited(_drop());
    unawaited(_reactions.close());
    super.dispose();
  }
}

/// The key exchange's view of a LiveKit room.
class _LiveKitKeyRoom implements LiveKeyRoom {
  _LiveKitKeyRoom(this._room);

  final lk.Room _room;

  @override
  Set<String> get others => {for (final p in _room.remoteParticipants.values) p.identity};

  lk.RemoteParticipant? _find(String identity) =>
      _room.remoteParticipants.values.where((p) => p.identity == identity).firstOrNull;

  @override
  bool isHost(String identity) => LiveRole.parse(_find(identity)?.attributes['role']) == LiveRole.host;

  @override
  bool isOnStage(String identity) => LiveRole.parse(_find(identity)?.attributes['role']).onStage;

  @override
  Future<void> send(LiveKeyMessage message, {String? to}) async {
    await _room.localParticipant?.publishData(
      message.encode(),
      reliable: true,
      topic: LiveKeyMessage.topic,
      destinationIdentities: to == null ? null : [to],
    );
  }
}
