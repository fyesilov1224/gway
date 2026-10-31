import 'dart:convert';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

class _FakeSecurity implements SecurityRepository {
  DeviceSignals? sentLocation;
  String? startedPhone;
  (String, String)? verifiedPhone;
  (String, String)? secondFactor;
  int secondFactorSends = 0;

  static const _done = SecurityStatus(enforced: true, sessionVerified: true, step: SecurityStep.done);

  @override
  Future<Result<SecurityStatus>> sendLocation(DeviceSignals signals) async {
    sentLocation = signals;
    return const Ok(SecurityStatus(enforced: true, sessionVerified: false, step: SecurityStep.phone));
  }

  @override
  Future<Result<void>> startPhone(String phone) async {
    startedPhone = phone;
    return const Ok(null);
  }

  @override
  Future<Result<SecurityStatus>> verifyPhone(String phone, String code) async {
    verifiedPhone = (phone, code);
    return const Ok(_done);
  }

  @override
  Future<Result<void>> startSecondFactor() async {
    secondFactorSends++;
    return const Ok(null);
  }

  @override
  Future<Result<SecurityStatus>> verifySecondFactor(String method, String code) async {
    secondFactor = (method, code);
    return const Ok(_done);
  }

  Map<String, Object?>? passkeyResponse;

  @override
  Future<Result<String>> passkeyAssertionOptions() async => const Ok('{"challenge":"AAAA"}');

  @override
  Future<Result<SecurityStatus>> verifyPasskey(Map<String, Object?> response) async {
    passkeyResponse = response;
    return const Ok(_done);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePasskeys implements PasskeyAuthenticator {
  @override
  bool get isSupported => true;

  @override
  Future<Map<String, Object?>?> create(String optionsJson) async => {'id': 'new'};

  @override
  Future<Map<String, Object?>?> get(String optionsJson) async => {'id': 'signed'};
}

class _WarningSecurity extends _FakeSecurity {
  @override
  Future<Result<SecurityStatus>> sendLocation(DeviceSignals signals) async {
    sentLocation = signals;
    return const Ok(SecurityStatus(
      enforced: true,
      sessionVerified: false,
      step: SecurityStep.phone,
      warnings: ['vpn_installed'],
    ));
  }
}

class _RefusingSecurity extends _FakeSecurity {
  @override
  Future<Result<SecurityStatus>> sendLocation(DeviceSignals signals) async => const Err(ForbiddenFailure());
}

class _FakeDevice implements DeviceSignalSource {
  _FakeDevice(this.reading);

  LocationReading reading;
  int reads = 0;

  @override
  Future<bool> hasPermission() async => reading is LocationRead;

  @override
  Future<LocationReading> read() async {
    reads++;
    return reading;
  }

  @override
  Future<void> openSettings() async {}
}

const _signals = DeviceSignals(
  latitude: 41.0,
  longitude: 29.0,
  accuracy: 12,
  isMocked: false,
  vpn: false,
  simCountry: 'TR',
  platform: 'android',
);

SecurityStatus _status(SecurityStep step, {bool totp = false, int passkeys = 0}) => SecurityStatus(
      enforced: true,
      sessionVerified: false,
      step: step,
      allowedCountry: 'TR',
      callingCode: 90,
      phoneMasked: '+90 ••• ••• •• 34',
      totpEnabled: totp,
      passkeyCount: passkeys,
    );

Widget _app(SecurityStatus status, _FakeSecurity security, [_FakeDevice? device]) => ProviderScope(
      overrides: [
        passkeyAuthenticatorProvider.overrideWithValue(_FakePasskeys()),
        securityStatusProvider.overrideWith((ref) async => status),
        securityRepositoryProvider.overrideWithValue(security),
        deviceSignalSourceProvider.overrideWithValue(device ?? _FakeDevice(const LocationRead(_signals))),
        accountStateProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const SecurityScreen()),
    );

void main() {
  testWidgets('the location step sends the device signals', (tester) async {
    final security = _FakeSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.location), security));
    await tester.pumpAndSettle();

    expect(find.text('Konumunu doğrulayalım'), findsOneWidget);
    await tester.tap(find.text('Konum iznini ver'));
    await tester.pumpAndSettle();
    expect(security.sentLocation?.simCountry, 'TR');
  });

  testWidgets('an installed VPN app shows the warning dialog', (tester) async {
    final security = _WarningSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.location), security));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Konum iznini ver'));
    // The button keeps spinning while the dialog is open, so pump a while instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(vpnInstalledWarning), findsOneWidget);
    await tester.tap(find.text('Anladım'));
    await tester.pumpAndSettle();
    expect(find.text(vpnInstalledWarning), findsNothing);
  });

  testWidgets('a permanently refused permission points to the settings', (tester) async {
    final device = _FakeDevice(const LocationDenied(permanently: true));
    await tester.pumpWidget(_app(_status(SecurityStep.location), _FakeSecurity(), device));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Konum iznini ver'));
    await tester.pumpAndSettle();
    expect(find.text('Ayarları aç'), findsOneWidget);
    expect(find.textContaining('Cihaz ayarlarından'), findsOneWidget);
  });

  testWidgets('the phone step locks the dialling code and drops a leading zero', (tester) async {
    final security = _FakeSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.phone), security));
    await tester.pumpAndSettle();

    expect(find.text('+90 '), findsOneWidget);
    await tester.enterText(find.byType(TextField), '05321234567');
    await tester.tap(find.text('Kod gönder'));
    await tester.pumpAndSettle();
    expect(security.startedPhone, '+905321234567');

    await tester.enterText(find.widgetWithText(TextField, '6 haneli kod'), '246810');
    await tester.tap(find.text('Doğrula'));
    await tester.pump();
    expect(security.verifiedPhone, ('+905321234567', '246810'));

    // The resend button waits out its cooldown.
    await tester.pump(const Duration(seconds: 61));
  });

  testWidgets('a registered passkey comes first in the second factor', (tester) async {
    final security = _FakeSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.secondFactor, totp: true, passkeys: 1), security));
    await tester.pumpAndSettle();

    expect(find.text('Parmak izi'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Parmak iziyle doğrula'));
    await tester.pump();
    expect(security.passkeyResponse, {'id': 'signed'});
  });

  testWidgets('a verified phone is followed by the faster sign-in offer', (tester) async {
    final security = _FakeSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.phone), security));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '5321234567');
    await tester.tap(find.text('Kod gönder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '6 haneli kod'), '246810');
    await tester.tap(find.text('Doğrula'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Girişlerini hızlandır'), findsOneWidget);
    expect(find.text('Parmak izi ekle'), findsOneWidget);
    expect(find.text('Google Authenticator ekle'), findsOneWidget);
    await tester.tap(find.text('Şimdi değil'));
    await tester.pump(const Duration(seconds: 61));
  });

  testWidgets('the second factor offers the authenticator app when set up', (tester) async {
    final security = _FakeSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.secondFactor, totp: true), security));
    await tester.pumpAndSettle();

    expect(find.text('Uygulama'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Doğrula'));
    await tester.pump();
    expect(security.secondFactor, ('totp', '123456'));
    expect(security.secondFactorSends, 0);
  });

  testWidgets('the restricted notice shows the warning', (tester) async {
    await tester.pumpWidget(_app(_status(SecurityStep.restricted), _FakeSecurity()));
    await tester.pumpAndSettle();

    expect(find.text('Güvenli giriş yapılamadı'), findsOneWidget);
    expect(find.text(securityWarning), findsOneWidget);
    expect(find.text('Durumu yenile'), findsOneWidget);
  });

  testWidgets('a refused location check shows the warning, not a blank page', (tester) async {
    final security = _RefusingSecurity();
    await tester.pumpWidget(_app(_status(SecurityStep.location), security));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Konum iznini ver'));
    await tester.pumpAndSettle();
    expect(find.text(securityWarning), findsOneWidget);
  });

  testWidgets('security steps fit a small phone at 130% text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final step in [SecurityStep.location, SecurityStep.phone, SecurityStep.secondFactor, SecurityStep.restricted]) {
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _app(_status(step, totp: true), _FakeSecurity()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$step');
    }
  });

  test('tokenRole reads the role claim', () {
    String token(Map<String, Object?> payload) =>
        'x.${base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '')}.y';
    expect(tokenRole(token({'role': 'unverified'})), 'unverified');
    expect(tokenRole(token({'sub': 'u'})), isNull);
    expect(tokenRole('broken'), isNull);
    expect(tokenRole(null), isNull);
  });
}
