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
SecurityStatus _security(SecurityStep step) => SecurityStatus(enforced: true, sessionVerified: false, step: step);

AppGate _gate({
  bool signedIn = true,
  bool recovery = false,
  AsyncValue<AccountState?> account = const AsyncData(AccountState(status: AccountStatus.active)),
  AsyncValue<SecurityStatus?>? security,
  AsyncValue<List<LegalDocument>> consents = const AsyncData([]),
  AsyncValue<Profile?>? profile,
}) =>
    resolveGate(
      signedIn: signedIn,
      passwordRecovery: recovery,
      account: account,
      security: security ?? AsyncData(_security(SecurityStep.done)),
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

    test('every security step holds the user before consents and onboarding', () {
      for (final step in [SecurityStep.location, SecurityStep.phone, SecurityStep.secondFactor, SecurityStep.restricted]) {
        expect(
          _gate(security: AsyncData(_security(step)), consents: const AsyncData([_doc]), profile: const AsyncData(null)),
          AppGate.security,
        );
      }
      expect(_gate(security: const AsyncLoading()), AppGate.loading);
      expect(_gate(security: AsyncError(Exception(), StackTrace.empty)), AppGate.error);
    });

    test('suspension comes before security', () {
      expect(
        _gate(
          account: const AsyncData(AccountState(status: AccountStatus.suspended)),
          security: AsyncData(_security(SecurityStep.restricted)),
        ),
        AppGate.suspended,
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
      expect(redirectFor(AppGate.security, u('/consent')), IdentityRoutes.security);
      expect(redirectFor(AppGate.security, u('/security')), isNull);
      expect(redirectFor(AppGate.ready, u('/security')), FeedRoutes.home);
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
