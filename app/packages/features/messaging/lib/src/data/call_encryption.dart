import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// The audio key of a call and the code both people can compare to know nobody is in between.
class CallKeys {
  const CallKeys({required this.audioKey, required this.safetyCode});

  /// 32 random-looking bytes (base64) for LiveKit's frame encryption; never leaves the phone.
  final String audioKey;

  /// 12 digits in groups of four, the same on both phones when they talk to each other directly.
  final String safetyCode;
}

/// End-to-end encryption of a voice call (docs/ARCHITECTURE.md §8c, Uçtan uca şifreleme): a fresh P-256 key pair for
/// each connection; ECDH with the other phone's public key, then HKDF-SHA256 salted with the call id. The server only
/// relays public keys, so it can never work out the audio key.
class CallKeyAgreement {
  CallKeyAgreement._(this._private, this._public);

  factory CallKeyAgreement.generate() {
    final random = FortunaRandom()..seed(KeyParameter(_randomBytes(32)));
    final generator = ECKeyGenerator()..init(ParametersWithRandom(ECKeyGeneratorParameters(_curve), random));
    final pair = generator.generateKeyPair();
    return CallKeyAgreement._(pair.privateKey, pair.publicKey.Q!.getEncoded(false));
  }

  static final _curve = ECCurve_secp256r1();
  static const _info = 'gway-call-e2ee-v1';

  final ECPrivateKey _private;
  final Uint8List _public;

  /// What this phone tells the other one, through the room.
  String get publicKey => base64Url.encode(_public);

  /// The keys shared with the owner of [peerPublicKey]; null when it is not a valid key.
  CallKeys? derive(String peerPublicKey, String callId) {
    final Uint8List peer;
    final ECPoint point;
    try {
      peer = base64Url.decode(peerPublicKey);
      point = _curve.curve.decodePoint(peer)!;
    } on Object {
      return null;
    }
    if (point.isInfinity || peer.length != 65 || _same(peer, _public)) return null;

    final secret = (ECDHBasicAgreement()..init(_private)).calculateAgreement(ECPublicKey(point, _curve));
    final salt = SHA256Digest().process(Uint8List.fromList(utf8.encode(callId)));
    final key = Uint8List(32);
    (HKDFKeyDerivator(SHA256Digest())..init(HkdfParameters(_bytes32(secret), 32, salt, utf8.encode(_info))))
        .deriveKey(null, 0, key, 0);
    return CallKeys(audioKey: base64.encode(key), safetyCode: _safetyCode(_public, peer, callId));
  }

  /// Both public keys in a fixed order, so both phones get the same digits.
  static String _safetyCode(Uint8List a, Uint8List b, String callId) {
    final first = _compare(a, b) <= 0 ? a : b;
    final second = identical(first, a) ? b : a;
    final hash = SHA256Digest().process(Uint8List.fromList([...first, ...second, ...utf8.encode(callId)]));
    var n = BigInt.zero;
    for (final byte in hash.take(8)) {
      n = (n << 8) | BigInt.from(byte);
    }
    final digits = (n % BigInt.from(10).pow(12)).toString().padLeft(12, '0');
    return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  static Uint8List _bytes32(BigInt value) {
    final out = Uint8List(32);
    var v = value;
    for (var i = 31; i >= 0; i--) {
      out[i] = (v & BigInt.from(0xff)).toInt();
      v >>= 8;
    }
    return out;
  }

  static int _compare(Uint8List a, Uint8List b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return a[i] - b[i];
    }
    return a.length - b.length;
  }

  static bool _same(Uint8List a, Uint8List b) => _compare(a, b) == 0;
}
