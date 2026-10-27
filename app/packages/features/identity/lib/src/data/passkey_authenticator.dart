import '../domain/security.dart';
import 'passkey_authenticator_stub.dart' if (dart.library.js_interop) 'passkey_authenticator_web.dart' as platform;

/// The browser's WebAuthn on the web; unsupported elsewhere until the mobile app adds it.
PasskeyAuthenticator createPasskeyAuthenticator() => platform.createPasskeyAuthenticator();
