import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

/// The audio key of a call and the code both people can compare to know nobody is in between.
class CallKeys {
  const CallKeys({required this.audioKey, required this.safetyCode, required this.confirmation});

  /// 32 random-looking bytes (base64) for LiveKit's frame encryption; never leaves the phone.
  final String audioKey;

  /// 12 digits in groups of four, the same on both phones when they talk to each other directly.
  final String safetyCode;

  /// What this phone shows the other one to prove it holds the same audio key and safety code: an HMAC under the
  /// audio key, so it gives nothing of the key away. Equal on both phones only when both derived the same keys.
  final String confirmation;
}

/// End-to-end encryption of a voice call (docs/ARCHITECTURE.md §8c, Uçtan uca şifreleme): a fresh P-256 key pair for
/// each connection; ECDH with the other phone's public key, then HKDF-SHA256 salted with the call id. The server only
/// relays public keys, so it can never work out the audio key.
class CallKeyAgreement {
  CallKeyAgreement._(this._pair);

  factory CallKeyAgreement.generate() => CallKeyAgreement._(E2eeKeyPair.generate());

  static const _info = 'gway-call-e2ee-v1';
  static const _confirmInfo = 'gway-call-confirm-v1';

  final E2eeKeyPair _pair;

  /// What this phone tells the other one, through the room.
  String get publicKey => _pair.publicKey;

  /// The keys shared with the owner of [peerPublicKey]; null when it is not a valid key.
  CallKeys? derive(String peerPublicKey, String callId) {
    final secret = _pair.agree(peerPublicKey);
    if (secret == null) return null;
    final peer = E2eeKeyPair.decodePublicKey(peerPublicKey)!;
    final key = e2eeHkdf(secret, salt: e2eeSha256(utf8.encode(callId)), info: _info);
    final safetyCode = _safetyCode(_pair.publicBytes, peer, callId);
    final tag = e2eeHmac(key, utf8.encode('$_confirmInfo|$safetyCode'));
    return CallKeys(audioKey: base64.encode(key), safetyCode: safetyCode, confirmation: base64Url.encode(tag.sublist(0, 16)));
  }

  /// Both public keys in a fixed order, so both phones get the same digits.
  static String _safetyCode(Uint8List a, Uint8List b, String callId) {
    final (first, second) = e2eeCompare(a, b) <= 0 ? (a, b) : (b, a);
    return e2eeDigits(e2eeSha256([...first, ...second, ...utf8.encode(callId)]));
  }
}
