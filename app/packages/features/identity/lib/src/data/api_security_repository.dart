import 'dart:convert';

import 'package:core/core.dart';

import '../domain/security.dart';

class ApiSecurityRepository implements SecurityRepository {
  ApiSecurityRepository(this._api);

  final ApiClient _api;

  static SecurityStatus _status(Object? json) => SecurityStatus.fromJson((json! as Map).cast<String, Object?>());

  @override
  Future<Result<SecurityStatus>> status() => _api.get('/security/status', decode: _status);

  @override
  Future<Result<SecurityStatus>> sendLocation(DeviceSignals signals) =>
      _api.post('/security/location', body: signals.toJson(), decode: _status);

  @override
  Future<Result<void>> startPhone(String phone) =>
      _api.post('/security/phone/start', body: {'phone': phone}, decode: (_) {});

  @override
  Future<Result<SecurityStatus>> verifyPhone(String phone, String code) =>
      _api.post('/security/phone/verify', body: {'phone': phone, 'code': code}, decode: _status);

  @override
  Future<Result<void>> startSecondFactor() => _api.post('/security/second-factor/start', decode: (_) {});

  @override
  Future<Result<SecurityStatus>> verifySecondFactor(String method, String code) =>
      _api.post('/security/second-factor/verify', body: {'method': method, 'code': code}, decode: _status);

  @override
  Future<Result<TotpSetup>> beginTotp() =>
      _api.post('/security/totp', decode: (json) => TotpSetup.fromJson((json! as Map).cast()));

  @override
  Future<Result<void>> confirmTotp(String code) =>
      _api.post('/security/totp/confirm', body: {'code': code}, decode: (_) {});

  @override
  Future<Result<void>> deleteTotp() => _api.delete('/security/totp', decode: (_) {});

  @override
  Future<Result<String>> passkeyRegistrationOptions() => _api.post('/security/passkeys/options', decode: jsonEncode);

  @override
  Future<Result<PasskeyView>> registerPasskey(String name, Map<String, Object?> response) => _api.post(
        '/security/passkeys',
        body: {'name': name, 'response': response},
        decode: (json) => PasskeyView.fromJson((json! as Map).cast()),
      );

  @override
  Future<Result<List<PasskeyView>>> passkeys() => _api.get(
        '/security/passkeys',
        decode: (json) => [for (final p in (json! as List).cast<Map<String, Object?>>()) PasskeyView.fromJson(p)],
      );

  @override
  Future<Result<void>> deletePasskey(String id) => _api.delete('/security/passkeys/$id', decode: (_) {});

  @override
  Future<Result<String>> passkeyAssertionOptions() =>
      _api.post('/security/second-factor/passkey/options', decode: jsonEncode);

  @override
  Future<Result<SecurityStatus>> verifyPasskey(Map<String, Object?> response) =>
      _api.post('/security/second-factor/passkey', body: response, decode: _status);
}
