import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';
import 'package:identity/src/data/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeConsents implements ConsentRepository {
  List<LegalDocument>? accepted;

  @override
  Future<Result<void>> accept(List<LegalDocument> documents) async {
    accepted = documents;
    return const Ok(null);
  }

  @override
  Future<Result<List<LegalDocument>>> latest() async => const Ok([]);

  @override
  Future<Result<List<LegalDocument>>> pending() async => const Ok([]);
}

class _FakeAuth implements AuthRepository {
  int signInCalls = 0;
  Result<void> signInResult = const Ok(null);

  final captchaTokens = <String?>[];

  @override
  Future<Result<void>> signIn({required String email, required String password, String? captchaToken}) async {
    signInCalls++;
    captchaTokens.add(captchaToken);
    return signInResult;
  }

  @override
  Future<Result<void>> signOut() async => const Ok(null);

  Set<SocialProvider> social = {SocialProvider.google, SocialProvider.apple};

  @override
  Future<Set<SocialProvider>> socialProviders() async => social;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _docs = [
  LegalDocument(kind: LegalKind.terms, version: 1, title: 'Kullanım Koşulları', body: 'a'),
  LegalDocument(kind: LegalKind.privacyNotice, version: 1, title: 'KVKK Aydınlatma Metni', body: 'b'),
  LegalDocument(kind: LegalKind.explicitConsent, version: 1, title: 'Açık Rıza Metni', body: 'c'),
  LegalDocument(kind: LegalKind.communityRules, version: 1, title: 'Topluluk Kuralları', body: 'd'),
];

Widget _app(Widget child, List<dynamic> overrides) => ProviderScope(
      // The screens are written in Turkish; the test device speaks English.
      // No Turnstile key: the bot check shows nothing (it runs in a web view the test cannot load).
      overrides: [
        deviceLocalesProvider.overrideWithValue(const [Locale('tr')]),
        humanCheckSiteKeyProvider.overrideWithValue(''),
        ...overrides.cast(),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: child),
    );

void main() {
  group('validators', () {
    test('email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('ayse@'), isNotNull);
      expect(validateEmail(' ayse@gway.app '), isNull);
    });

    test('new password mirrors Supabase rules', () {
      expect(validateNewPassword('Kisa1'), contains('8'));
      expect(validateNewPassword('kucukharf1'), isNotNull);
      expect(validateNewPassword('BUYUKHARF1'), isNotNull);
      expect(validateNewPassword('Harfsiz!!'), isNotNull);
      expect(validateNewPassword('Guvenli1x'), isNull);
    });
  });

  group('failureFromAuth', () {
    test('known codes become Turkish rule failures', () {
      final f = failureFromAuth(const AuthException('Invalid login', code: 'invalid_credentials'));

      expect(f, isA<RuleFailure>());
      expect(f.userMessage, 'E-posta adresi veya şifre hatalı.');
    });

    test('rate limits are typed', () {
      expect(
        failureFromAuth(const AuthException('x', code: 'over_email_send_rate_limit')),
        const RateLimitedFailure(),
      );
    });

    test('a failed bot check says so, not a raw error', () {
      final f = failureFromAuth(const AuthException('captcha protection: request disallowed', code: 'captcha_failed'));
      expect(f.userMessage, 'Robot olmadığını doğrulayamadık. Kutudaki doğrulamayı tamamlayıp tekrar dene.');
    });

    test('the bot check is ready when off or with a token; each attempt spends the token', () {
      final check = HumanCheckController();
      expect(check.ready, isTrue, reason: 'off: nothing to wait for');
      check.report(enabled: true);
      expect(check.ready, isFalse);
      check.report(enabled: true, token: 't1');
      expect((check.ready, check.token), (true, 't1'));
      check.spend();
      expect((check.ready, check.token), (false, null), reason: 'a token works once');
      check.dispose();
    });

    test('unknown errors never show the raw server message', () {
      final f = failureFromAuth(const AuthException('pq: internal stack', code: 'something_new'));

      expect(f.userMessage, isNot(contains('pq')));
    });
  });

  group('AccountState', () {
    test('parses API JSON', () {
      final s = AccountState.fromJson({
        'status': 'pending_deletion',
        'deletionScheduledFor': '2026-11-17T10:00:00Z',
      });

      expect(s.status, AccountStatus.pendingDeletion);
      expect(s.deletionScheduledFor, DateTime.utc(2026, 11, 17, 10));
    });

    test('expired suspension no longer applies', () {
      final now = DateTime.utc(2026, 10, 18);
      final s = AccountState(status: AccountStatus.suspended, suspendedUntil: now.subtract(const Duration(minutes: 1)));
      const indefinite = AccountState(status: AccountStatus.suspended);

      expect(s.isSuspendedAt(now), isFalse);
      expect(indefinite.isSuspendedAt(now), isTrue);
    });
  });

  testWidgets('consent requires every document to be read and accepted', (tester) async {
    final consents = _FakeConsents();
    await tester.pumpWidget(
      _app(const ConsentScreen(), [
        pendingConsentsProvider.overrideWith((ref) async => _docs),
        consentRepositoryProvider.overrideWithValue(consents),
      ]),
    );
    await tester.pumpAndSettle();

    final button = find.widgetWithText(FilledButton, 'Devam et');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    final boxes = find.byType(Checkbox);
    expect(boxes, findsNWidgets(4));
    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> read(int i) async {
      await tap(find.widgetWithText(TextButton, 'Metni oku').at(i));
      Navigator.of(tester.element(find.text(_docs[i].body))).pop();
      await tester.pumpAndSettle();
    }

    await tap(boxes.at(0));
    expect(find.text('Lütfen metnin tamamını okuyup öyle onaylayın.'), findsOneWidget);
    expect(find.text(_docs[0].body), findsOneWidget, reason: 'ticking unread text opens it');
    Navigator.of(tester.element(find.text(_docs[0].body))).pop();
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(boxes.at(0)).value, isFalse, reason: 'unread text cannot be accepted');
    for (var i = 0; i < 3; i++) {
      await read(i);
      await tap(boxes.at(i));
    }
    expect(tester.widget<FilledButton>(button).onPressed, isNull, reason: 'community rules still missing');

    await read(3);
    await tap(boxes.at(3));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();

    expect(consents.accepted, hasLength(4));
  });

  testWidgets('a long text is accepted with the button after its last line', (tester) async {
    final doc = LegalDocument(
      kind: LegalKind.terms,
      version: 1,
      title: 'Kullanım Koşulları',
      body: List.filled(300, 'Uzun bir hukuki metin satırı.').join(' '),
    );
    await tester.pumpWidget(
      _app(const ConsentScreen(), [
        pendingConsentsProvider.overrideWith((ref) async => [doc]),
        consentRepositoryProvider.overrideWithValue(_FakeConsents()),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Metni oku'));
    await tester.pumpAndSettle();

    final accept = find.widgetWithText(FilledButton, 'Okudum, onaylıyorum');
    expect(accept, findsNothing, reason: 'the button sits after the last line');
    for (var i = 0; i < 30 && accept.evaluate().isEmpty; i++) {
      await tester.flingFrom(const Offset(400, 400), const Offset(0, -300), 3000);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(accept);
    await tester.pumpAndSettle();
    await tester.tap(accept);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Devam et')).onPressed, isNotNull);
  });

  testWidgets('sign-in validates before calling the server and shows safe errors', (tester) async {
    final auth = _FakeAuth()..signInResult = const Err(RuleFailure('auth.invalid_credentials', 'E-posta adresi veya şifre hatalı.'));
    await tester.pumpWidget(_app(const SignInScreen(), [authRepositoryProvider.overrideWithValue(auth)]));

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pump();
    expect(auth.signInCalls, 0);
    expect(find.text('E-posta adresini gir.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ayse@gway.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'yanlis');
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, 1);
    expect(auth.captchaTokens, [null], reason: 'no Turnstile key: no token is sent');
    expect(find.text('E-posta adresi veya şifre hatalı.'), findsOneWidget);
  });

  testWidgets('sign-in does not overflow at 130% text scale on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(const SignInScreen(), [authRepositoryProvider.overrideWithValue(_FakeAuth())]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
  testWidgets('only the providers the server serves get a button', (tester) async {
    final auth = _FakeAuth()..social = {SocialProvider.google};
    await tester.pumpWidget(_app(const SignInScreen(), [authRepositoryProvider.overrideWithValue(auth)]));
    await tester.pumpAndSettle();
    expect(find.text('Google ile devam et'), findsOneWidget);
    expect(find.text('Apple ile devam et'), findsNothing);

    final none = _FakeAuth()..social = {};
    await tester.pumpWidget(_app(const SignInScreen(), [authRepositoryProvider.overrideWithValue(none)]));
    await tester.pumpAndSettle();
    expect(find.text('veya'), findsNothing);
  });
}
