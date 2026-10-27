import '../domain/security.dart';

PasskeyAuthenticator createPasskeyAuthenticator() => const _Unsupported();

class _Unsupported implements PasskeyAuthenticator {
  const _Unsupported();

  @override
  bool get isSupported => false;

  @override
  Future<Map<String, Object?>?> create(String optionsJson) async => null;

  @override
  Future<Map<String, Object?>?> get(String optionsJson) async => null;
}
