import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/call_encryption.dart';
import '../domain/calls.dart';

enum CallConnection { idle, connecting, connected, failed }

/// The audio side of a call: one LiveKit room with two people, microphone only, end-to-end encrypted
/// (docs/ARCHITECTURE.md §8c, Uçtan uca şifreleme). Whether the call goes on is the call row's business; this only
/// carries the sound.
class CallSession extends ChangeNotifier {
  /// The participant attribute carrying a phone's encryption public key.
  static const keyAttribute = 'gway_e2ee';

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _events;
  lk.BaseKeyProvider? _keys;
  CallKeyAgreement? _agreement;
  String? _callId;
  String? _peerKey;
  bool _disposed = false;

  CallConnection connection = CallConnection.idle;
  bool micOn = true;
  bool speakerOn = false;

  /// The audio key is agreed with the other phone: sound goes out and comes in encrypted. Until then the
  /// microphone stays off, so unencrypted sound is never sent.
  bool secure = false;

  /// The digits both people may compare; null until [secure].
  String? safetyCode;

  /// The other phone sent unencrypted sound (an old app version); it is not played.
  bool peerUnencrypted = false;

  /// The other person is in the room.
  bool get peerJoined => _room?.remoteParticipants.isNotEmpty ?? false;

  Future<void> connect(CallJoin join) async {
    if (connection == CallConnection.connecting || connection == CallConnection.connected) return;
    connection = CallConnection.connecting;
    secure = false;
    safetyCode = null;
    peerUnencrypted = false;
    _peerKey = null;
    _notify();
    try {
      final keys = await lk.BaseKeyProvider.create();
      final agreement = CallKeyAgreement.generate();
      final room = lk.Room(
        roomOptions: lk.RoomOptions(
          defaultAudioPublishOptions: const lk.AudioPublishOptions(dtx: true),
          encryption: lk.E2EEOptions(keyProvider: keys),
        ),
      );
      _room = room;
      _keys = keys;
      _agreement = agreement;
      _callId = join.callId;
      room.addListener(_notify);
      _events = room.createListener()
        ..on<lk.ParticipantConnectedEvent>((_) => _applyPeerKey())
        ..on<lk.ParticipantAttributesChanged>((_) => _applyPeerKey())
        ..on<lk.TrackSubscribedEvent>(_checkEncrypted);
      await room.connect(join.url, join.token);
      await room.startAudio();
      _publishKey(room, agreement.publicKey);
      connection = CallConnection.connected;
      await _applyPeerKey();
    } on Object catch (e) {
      debugPrint('Call connect failed: $e');
      connection = CallConnection.failed;
    }
    _notify();
  }

  /// Writes this phone's public key into its room attributes. The server's acknowledgement is not waited for: LiveKit
  /// 1.9.1 sent it without the request id, so the wait timed out although the key had arrived, and the call failed
  /// with "Sese bağlanılamadı" (2026-11-04). One retry covers a request that really got lost.
  void _publishKey(lk.Room room, String publicKey) {
    Future<void> publish() async => room.localParticipant?.setAttributes({keyAttribute: publicKey});
    unawaited(publish().catchError((Object e) async {
      if (_room != room) return;
      if (room.localParticipant?.attributes[keyAttribute] == publicKey) return;
      debugPrint('Call key not confirmed, sending again: $e');
      await publish().catchError((Object e) => debugPrint('Call key not confirmed: $e'));
    }));
  }

  /// Once the other phone's public key is in the room: derive the audio key, then open the microphone. A new key
  /// (the other person came back) is agreed again.
  Future<void> _applyPeerKey() async {
    final room = _room;
    final keys = _keys;
    final agreement = _agreement;
    final callId = _callId;
    if (room == null || keys == null || agreement == null || callId == null) return;
    final peerKey = room.remoteParticipants.values.firstOrNull?.attributes[keyAttribute];
    if (peerKey == null || peerKey == _peerKey) return;
    final derived = agreement.derive(peerKey, callId);
    if (derived == null) return;
    _peerKey = peerKey;
    try {
      await keys.setSharedKey(derived.audioKey);
      secure = true;
      safetyCode = derived.safetyCode;
      await room.localParticipant?.setMicrophoneEnabled(micOn);
    } on Object catch (e) {
      debugPrint('Call encryption failed: $e');
      secure = false;
      safetyCode = null;
    }
    _notify();
  }

  /// Sound the other phone did not encrypt is never played.
  Future<void> _checkEncrypted(lk.TrackSubscribedEvent event) async {
    if (event.publication.encryptionType != lk.EncryptionType.kNone) return;
    peerUnencrypted = true;
    _notify();
    await event.publication.unsubscribe();
  }

  /// Null when done; otherwise the sentence to show.
  Future<String?> setMicrophone(bool on) async {
    try {
      // Before the key is agreed only the wish is kept; the microphone opens with the key.
      if (secure) await _room?.localParticipant?.setMicrophoneEnabled(on);
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
    _forgetKeys();
    if (room == null) return;
    room.removeListener(_notify);
    await room.disconnect();
    await room.dispose();
    connection = CallConnection.idle;
    _notify();
  }

  /// The private key and the audio key live only as long as the connection.
  void _forgetKeys() {
    unawaited(_events?.dispose());
    _events = null;
    _room = null;
    _keys = null;
    _agreement = null;
    _callId = null;
    _peerKey = null;
    secure = false;
    safetyCode = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final room = _room;
    _forgetKeys();
    if (room != null) {
      room.removeListener(_notify);
      room.disconnect().then((_) => room.dispose()).ignore();
    }
    super.dispose();
  }
}
