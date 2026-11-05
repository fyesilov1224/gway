import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

/// The audio key of a live room (docs/ARCHITECTURE.md §8, Uçtan uca şifreli yayın): 32 random bytes made by one
/// phone in the room and handed to each newcomer sealed for that newcomer alone. Never written anywhere.
class LiveRoomKey {
  LiveRoomKey(this.bytes, this.broadcastId)
      : keyId = base64Url.encode(e2eeHmac(bytes, utf8.encode('$_idInfo|$broadcastId')).sublist(0, 16)),
        safetyCode = e2eeDigits(e2eeHmac(bytes, utf8.encode('$_codeInfo|$broadcastId')));

  factory LiveRoomKey.generate(String broadcastId) => LiveRoomKey(e2eeRandomBytes(32), broadcastId);

  static const _idInfo = 'gway-live-confirm-v1';
  static const _codeInfo = 'gway-live-code-v1';
  static const _wrapInfo = 'gway-live-wrap-v1';

  final Uint8List bytes;
  final String broadcastId;

  /// Who holds which key, told to the room: an HMAC under the key, so it gives nothing of the key away. The same on
  /// every phone that holds the same key.
  final String keyId;

  /// 12 digits everyone in the room sees alike while they hold the same key.
  final String safetyCode;

  /// The form LiveKit's frame encryption takes.
  String get audioKey => base64.encode(bytes);

  /// This key sealed for the owner of [peerPublicKey] alone (ECDH, HKDF-SHA256, AES-256-GCM); null for a bad key.
  String? sealFor(E2eeKeyPair mine, String peerPublicKey) {
    final wrap = _wrapKey(mine, peerPublicKey, broadcastId);
    if (wrap == null) return null;
    return base64Url.encode(e2eeSeal(wrap, bytes, aad: utf8.encode(broadcastId)));
  }

  /// A key another phone sealed for this one; null when it was not sealed for us or was changed on the way.
  static LiveRoomKey? open(E2eeKeyPair mine, String senderPublicKey, String sealed, String broadcastId) {
    final wrap = _wrapKey(mine, senderPublicKey, broadcastId);
    if (wrap == null) return null;
    final Uint8List box;
    try {
      box = base64Url.decode(sealed);
    } on FormatException {
      return null;
    }
    final bytes = e2eeOpen(wrap, box, aad: utf8.encode(broadcastId));
    return bytes == null || bytes.length != 32 ? null : LiveRoomKey(bytes, broadcastId);
  }

  static Uint8List? _wrapKey(E2eeKeyPair mine, String peerPublicKey, String broadcastId) {
    final secret = mine.agree(peerPublicKey);
    if (secret == null) return null;
    return e2eeHkdf(secret, salt: e2eeSha256(utf8.encode(broadcastId)), info: _wrapInfo);
  }
}

/// The messages phones send each other to share the room key, on their own data topic. Their sender is set by the
/// LiveKit server, not by the message.
sealed class LiveKeyMessage {
  const LiveKeyMessage();

  static const topic = 'gway_e2ee';

  static LiveKeyMessage? decode(List<int> data) {
    try {
      return switch (jsonDecode(utf8.decode(data))) {
        {'t': 'hello', 'pub': final String pub, 'direct': final bool direct} => LiveKeyHello(pub, direct: direct),
        {'t': 'key', 'pub': final String pub, 'box': final String box, 'kid': final String kid} => LiveKeyGift(pub, box, kid),
        {'t': 'have', 'kid': final String kid} => LiveKeyHave(kid),
        _ => null,
      };
    } on Object {
      return null;
    }
  }

  Map<String, Object> toJson();

  List<int> encode() => utf8.encode(jsonEncode(toJson()));
}

/// "I need the room key; here is my public key." [direct]: asked of one phone, which answers at once.
class LiveKeyHello extends LiveKeyMessage {
  const LiveKeyHello(this.publicKey, {this.direct = false});

  final String publicKey;
  final bool direct;

  @override
  Map<String, Object> toJson() => {'t': 'hello', 'pub': publicKey, 'direct': direct};
}

/// The room key sealed for the receiver, with the sender's public key to open it.
class LiveKeyGift extends LiveKeyMessage {
  const LiveKeyGift(this.publicKey, this.box, this.keyId);

  final String publicKey;
  final String box;
  final String keyId;

  @override
  Map<String, Object> toJson() => {'t': 'key', 'pub': publicKey, 'box': box, 'kid': keyId};
}

/// "I hold the key with this id."
class LiveKeyHave extends LiveKeyMessage {
  const LiveKeyHave(this.keyId);

  final String keyId;

  @override
  Map<String, Object> toJson() => {'t': 'have', 'kid': keyId};
}
