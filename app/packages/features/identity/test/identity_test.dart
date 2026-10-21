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

  @override
  Future<Result<void>> signIn({required String email, required String password}) async {
    signInCalls++;
    return signInResult;
  }

  @override
  Future<Result<void>> signOut() async => const Ok(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _docs = [
  LegalDocument(kind: LegalKind.terms, version: 1, title: 'Kullanım Koşulları', body: 'a'),
  LegalDocument(kind: LegalKind.privacyNotice, version: 1, title: 'KVKK Aydınlatma Metni', body: 'b'),
  LegalDocument(kind: LegalKind.explicitConsent, version: 1, title: 'Açık Rıza Metni', body: 'c'),
];

Widget _app(Widget child, List<dynamic> overrides) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(theme: GxTheme.light(), home: child),
    );

void main() {
  group('validators', () {
    test('email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('ayse@'), isNotNull);
      expect(validateEmail(' ayse@grupx.app '), isNull);
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

  testWidgets('consent requires every document to be accepted', (tester) async {
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
    expect(boxes, findsNWidgets(3));
    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pump();
    }

    await tap(boxes.at(0));
    await tap(boxes.at(1));
    expect(tester.widget<FilledButton>(button).onPressed, isNull, reason: 'explicit consent still missing');

    await tap(boxes.at(2));
    await tap(button);

    expect(consents.accepted, hasLength(3));
  });

  testWidgets('sign-in validates before calling the server and shows safe errors', (tester) async {
    final auth = _FakeAuth()..signInResult = const Err(RuleFailure('auth.invalid_credentials', 'E-posta adresi veya şifre hatalı.'));
    await tester.pumpWidget(_app(const SignInScreen(), [authRepositoryProvider.overrideWithValue(auth)]));

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pump();
    expect(auth.signInCalls, 0);
    expect(find.text('E-posta adresini gir.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ayse@grupx.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'yanlis');
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, 1);
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
}
