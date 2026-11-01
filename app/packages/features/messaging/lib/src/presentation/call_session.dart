import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../domain/calls.dart';

enum CallConnection { idle, connecting, connected, failed }

/// The audio side of a call: one LiveKit room with two people, microphone only.
/// Whether the call goes on is the call row's business; this only carries the sound.
class CallSession extends ChangeNotifier {
  lk.Room? _room;
  bool _disposed = false;

  CallConnection connection = CallConnection.idle;
  bool micOn = true;
  bool speakerOn = false;

  /// The other person is in the room.
  bool get peerJoined => _room?.remoteParticipants.isNotEmpty ?? false;

  Future<void> connect(CallJoin join) async {
    if (connection == CallConnection.connecting || connection == CallConnection.connected) return;
    connection = CallConnection.connecting;
    _notify();
    final room = lk.Room(roomOptions: const lk.RoomOptions(defaultAudioPublishOptions: lk.AudioPublishOptions(dtx: true)));
    _room = room;
    room.addListener(_notify);
    try {
      await room.connect(join.url, join.token);
      await room.startAudio();
      await room.localParticipant?.setMicrophoneEnabled(micOn);
      connection = CallConnection.connected;
    } on Object catch (e) {
      debugPrint('Call connect failed: $e');
      connection = CallConnection.failed;
    }
    _notify();
  }

  /// Null when done; otherwise the sentence to show.
  Future<String?> setMicrophone(bool on) async {
    try {
      await _room?.localParticipant?.setMicrophoneEnabled(on);
      micOn = on;
      _notify();
      return null;
    } on Object catch (e) {
      debugPrint('Microphone failed: $e');
      return 'Mikrofon açılamadı. Mikrofon iznini kontrol et.';
    }
  }

  /// Loudspeaker or earpiece; phones only.
  Future<void> setSpeaker(bool on) async {
    try {
      await lk.AudioManager.instance.setSpeakerOutputPreferred(on, force: true);
      speakerOn = on;
      _notify();
    } on Object catch (e) {
      debugPrint('Speaker switch failed: $e');
    }
  }

  Future<void> leave() async {
    final room = _room;
    _room = null;
    if (room == null) return;
    room.removeListener(_notify);
    await room.disconnect();
    await room.dispose();
    connection = CallConnection.idle;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final room = _room;
    _room = null;
    if (room != null) {
      room.removeListener(_notify);
      room.disconnect().then((_) => room.dispose()).ignore();
    }
    super.dispose();
  }
}
