import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Building blocks of the end-to-end encrypted voice (docs/ARCHITECTURE.md §8c calls, §8 live rooms): a P-256 key
/// pair made fresh for each connection, ECDH, HKDF-SHA256, HMAC-SHA256 and AES-GCM. Nothing here is kept on disk.
class E2eeKeyPair {
  E2eeKeyPair._(this._private, this._public);

  factory E2eeKeyPair.generate() {
    final random = FortunaRandom()..seed(KeyParameter(e2eeRandomBytes(32)));
    final generator = ECKeyGenerator()..init(ParametersWithRandom(ECKeyGeneratorParameters(_curve), random));
    final pair = generator.generateKeyPair();
    return E2eeKeyPair._(pair.privateKey, pair.publicKey.Q!.getEncoded(false));
  }

  static final _curve = ECCurve_secp256r1();

  final ECPrivateKey _private;
  final Uint8List _public;

  /// The uncompressed public point (65 bytes).
  Uint8List get publicBytes => _public;

  /// What this device tells the others, through the room.
  String get publicKey => base64Url.encode(_public);

  /// The 32-byte ECDH secret shared with the owner of [peerPublicKey]; null when it is not a valid key or is our own.
  Uint8List? agree(String peerPublicKey) {
    final peer = decodePublicKey(peerPublicKey);
    if (peer == null || e2eeCompare(peer, _public) == 0) return null;
    final point = _curve.curve.decodePoint(peer)!;
    final secret = (ECDHBasicAgreement()..init(_private)).calculateAgreement(ECPublicKey(point, _curve));
    final out = Uint8List(32);
    var v = secret;
    for (var i = 31; i >= 0; i--) {
      out[i] = (v & BigInt.from(0xff)).toInt();
      v >>= 8;
    }
    return out;
  }

  /// The raw bytes of a valid P-256 public key; null otherwise.
  static Uint8List? decodePublicKey(String key) {
    try {
      final bytes = base64Url.decode(key);
      if (bytes.length != 65) return null;
      final point = _curve.curve.decodePoint(bytes);
      if (point == null || point.isInfinity) return null;
      return bytes;
    } on Object {
      return null;
    }
  }
}

Uint8List e2eeRandomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

Uint8List e2eeSha256(List<int> data) => SHA256Digest().process(Uint8List.fromList(data));

/// HKDF-SHA256 of [secret] into [length] bytes.
Uint8List e2eeHkdf(Uint8List secret, {required Uint8List salt, required String info, int length = 32}) {
  final out = Uint8List(length);
  (HKDFKeyDerivator(SHA256Digest())..init(HkdfParameters(secret, length, salt, utf8.encode(info))))
      .deriveKey(null, 0, out, 0);
  return out;
}

Uint8List e2eeHmac(Uint8List key, List<int> data) =>
    (HMac(SHA256Digest(), 64)..init(KeyParameter(key))).process(Uint8List.fromList(data));

/// AES-256-GCM: a fresh 12-byte nonce, then the ciphertext with its 16-byte tag.
Uint8List e2eeSeal(Uint8List key, Uint8List plain, {List<int> aad = const []}) {
  final nonce = e2eeRandomBytes(12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, nonce, Uint8List.fromList(aad)));
  return Uint8List.fromList([...nonce, ...cipher.process(plain)]);
}

/// Opens what [e2eeSeal] made; null when the key is wrong or the bytes were changed.
Uint8List? e2eeOpen(Uint8List key, Uint8List sealed, {List<int> aad = const []}) {
  if (sealed.length < 12 + 16) return null;
  try {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, sealed.sublist(0, 12), Uint8List.fromList(aad)));
    return cipher.process(sealed.sublist(12));
  } on Object {
    return null;
  }
}

/// Byte order, for putting two keys in the same order on both devices.
int e2eeCompare(Uint8List a, Uint8List b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return a[i] - b[i];
  }
  return a.length - b.length;
}

/// 12 digits in groups of four from the first 8 bytes of [hash].
String e2eeDigits(Uint8List hash) {
  var n = BigInt.zero;
  for (final byte in hash.take(8)) {
    n = (n << 8) | BigInt.from(byte);
  }
  final digits = (n % BigInt.from(10).pow(12)).toString().padLeft(12, '0');
  return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
}
