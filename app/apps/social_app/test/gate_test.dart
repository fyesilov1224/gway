import 'package:feed/feed.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';
import 'package:profile/profile.dart';
import 'package:social_app/src/gate.dart';
import 'package:social_app/src/router.dart';

final _now = DateTime.utc(2026, 10, 18);
final _profile = Profile(id: 'u1', username: 'ayse', displayName: 'Ayşe', bio: '', createdAt: _now);
const _doc = LegalDocument(kind: LegalKind.terms, version: 1, title: 't', body: 'b');

AppGate _gate({
  bool signedIn = true,
  bool recovery = false,
  AsyncValue<AccountState?> account = const AsyncData(AccountState(status: AccountStatus.active)),
  AsyncValue<List<LegalDocument>> consents = const AsyncData([]),
  AsyncValue<Profile?>? profile,
}) =>
    resolveGate(
      signedIn: signedIn,
      passwordRecovery: recovery,
      account: account,
      pendingConsents: consents,
      profile: profile ?? AsyncData(_profile),
      now: _now,
    );

void main() {
  group('resolveGate', () {
    test('signed out wins over everything', () {
      expect(_gate(signedIn: false, recovery: true), AppGate.signedOut);
    });

    test('password recovery comes before the app', () {
      expect(_gate(recovery: true), AppGate.passwordRecovery);
    });

    test('suspension and deletion block consent and onboarding', () {
      expect(
        _gate(
          account: const AsyncData(AccountState(status: AccountStatus.suspended)),
          consents: const AsyncData([_doc]),
        ),
        AppGate.suspended,
      );
      expect(
        _gate(account: AsyncData(AccountState(status: AccountStatus.pendingDeletion, deletionScheduledFor: _now))),
        AppGate.deletionPending,
      );
    });

    test('expired suspension lets the user in', () {
      expect(
        _gate(
          account: AsyncData(
            AccountState(status: AccountStatus.suspended, suspendedUntil: _now.subtract(const Duration(hours: 1))),
          ),
        ),
        AppGate.ready,
      );
    });

    test('consents come before onboarding', () {
      expect(_gate(consents: const AsyncData([_doc]), profile: const AsyncData(null)), AppGate.needsConsent);
      expect(_gate(profile: const AsyncData(null)), AppGate.needsOnboarding);
    });

    test('loading and errors', () {
      expect(_gate(account: const AsyncLoading()), AppGate.loading);
      expect(_gate(consents: AsyncError(Exception(), StackTrace.empty)), AppGate.error);
      expect(_gate(), AppGate.ready);
    });
  });

  group('redirectFor', () {
    Uri u(String s) => Uri.parse(s);

    test('signed-out users may browse auth screens only', () {
      expect(redirectFor(AppGate.signedOut, u('/sign-up')), isNull);
      expect(redirectFor(AppGate.signedOut, u('/u/ayse')), IdentityRoutes.signIn);
      expect(redirectFor(AppGate.signedOut, u('/consent')), IdentityRoutes.signIn);
    });

    test('incomplete accounts are held at their step', () {
      expect(redirectFor(AppGate.needsConsent, u('/')), IdentityRoutes.consent);
      expect(redirectFor(AppGate.needsOnboarding, u('/settings')), ProfileRoutes.onboarding);
      expect(redirectFor(AppGate.needsOnboarding, u('/onboarding')), isNull);
    });

    test('a deep link opened while loading is restored when ready', () {
      final loading = redirectFor(AppGate.loading, u('/u/ayse'));
      expect(loading, '/loading?from=%2Fu%2Fayse');

      expect(redirectFor(AppGate.ready, u(loading!)), '/u/ayse');
    });

    test('ready users leave gate screens for their profile', () {
      expect(redirectFor(AppGate.ready, u('/sign-in')), FeedRoutes.home);
      expect(redirectFor(AppGate.ready, u('/consent')), FeedRoutes.home);
      expect(redirectFor(AppGate.ready, u('/u/ayse')), isNull);
    });
  });
}
