import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../domain/security.dart';

PasskeyAuthenticator createPasskeyAuthenticator() => _WebPasskeyAuthenticator();

/// `navigator.credentials` with the server's WebAuthn JSON: binary fields arrive as base64url and go back the same way.
class _WebPasskeyAuthenticator implements PasskeyAuthenticator {
  @override
  bool get isSupported => web.window.isSecureContext && globalContext.has('PublicKeyCredential');

  @override
  Future<Map<String, Object?>?> create(String optionsJson) async {
    final options = _withoutNulls(jsonDecode(optionsJson)) as Map<String, Object?>;
    final publicKey = options.jsify()! as JSObject;
    publicKey.setProperty('challenge'.toJS, _bytes(options['challenge']));
    publicKey.getProperty<JSObject>('user'.toJS).setProperty('id'.toJS, _bytes((options['user']! as Map)['id']));
    _descriptors(publicKey, options, 'excludeCredentials');

    final web.Credential? credential;
    try {
      credential = await web.window.navigator.credentials
          .create(web.CredentialCreationOptions(publicKey: publicKey as web.PublicKeyCredentialCreationOptions))
          .toDart;
    } on Object {
      return null; // cancelled, timed out or refused (e.g. this key is already registered)
    }
    if (credential == null) return null;
    final c = credential as web.PublicKeyCredential;
    final r = c.response as web.AuthenticatorAttestationResponse;
    return {
      'id': c.id,
      'rawId': _base64Url(c.rawId),
      'type': c.type,
      'response': {
        'clientDataJSON': _base64Url(r.clientDataJSON),
        'attestationObject': _base64Url(r.attestationObject),
        'transports': [for (final t in r.getTransports().toDart) t.toDart],
      },
      'clientExtensionResults': <String, Object?>{},
    };
  }

  @override
  Future<Map<String, Object?>?> get(String optionsJson) async {
    final options = _withoutNulls(jsonDecode(optionsJson)) as Map<String, Object?>;
    final publicKey = options.jsify()! as JSObject;
    publicKey.setProperty('challenge'.toJS, _bytes(options['challenge']));
    _descriptors(publicKey, options, 'allowCredentials');

    final web.Credential? credential;
    try {
      credential = await web.window.navigator.credentials
          .get(web.CredentialRequestOptions(publicKey: publicKey as web.PublicKeyCredentialRequestOptions))
          .toDart;
    } on Object {
      return null;
    }
    if (credential == null) return null;
    final c = credential as web.PublicKeyCredential;
    final r = c.response as web.AuthenticatorAssertionResponse;
    return {
      'id': c.id,
      'rawId': _base64Url(c.rawId),
      'type': c.type,
      'response': {
        'authenticatorData': _base64Url(r.authenticatorData),
        'clientDataJSON': _base64Url(r.clientDataJSON),
        'signature': _base64Url(r.signature),
        if (r.userHandle case final handle?) 'userHandle': _base64Url(handle),
      },
      'clientExtensionResults': <String, Object?>{},
    };
  }

  /// Credential descriptors carry their id as bytes.
  static void _descriptors(JSObject target, Map<String, Object?> options, String key) {
    final list = options[key];
    if (list is! List) return;
    target.setProperty(
      key.toJS,
      [
        for (final d in list.cast<Map<String, Object?>>())
          (d.jsify()! as JSObject)..setProperty('id'.toJS, _bytes(d['id'])),
      ].toJS,
    );
  }

  /// Browsers reject `null` for optional dictionary members such as `authenticatorAttachment`.
  static Object? _withoutNulls(Object? value) => switch (value) {
        Map() => {
            for (final e in value.entries)
              if (e.value != null) e.key as String: _withoutNulls(e.value),
          },
        List() => [for (final v in value) _withoutNulls(v)],
        _ => value,
      };

  static JSUint8Array _bytes(Object? base64Url) =>
      Uint8List.fromList(base64Url is String ? base64.decode(base64.normalize(base64Url.replaceAll('-', '+').replaceAll('_', '/'))) : const [])
          .toJS;

  static String _base64Url(JSArrayBuffer buffer) =>
      base64Url.encode(buffer.toDart.asUint8List()).replaceAll('=', '');
}
