import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/api_account_repository.dart';
import '../data/api_security_repository.dart';
import '../data/device_signal_source.dart';
import '../data/passkey_authenticator.dart';
import '../data/supabase_auth_repository.dart';
import '../data/supabase_birth_date_repository.dart';
import '../data/supabase_consent_repository.dart';
import '../domain/account.dart';
import '../domain/age.dart';
import '../domain/auth.dart';
import '../domain/legal.dart';
import '../domain/security.dart';

/// Where e-mail links and OAuth return. Overridden by each app.
final authRedirectUrlProvider = Provider<String>(
  (ref) => throw UnimplementedError('authRedirectUrlProvider must be overridden'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(
    ref.watch(supabaseClientProvider),
    redirectUrl: ref.watch(authRedirectUrlProvider),
  ),
);

final consentRepositoryProvider = Provider<ConsentRepository>(
  (ref) => SupabaseConsentRepository(ref.watch(supabaseClientProvider)),
);

final birthDateRepositoryProvider = Provider<BirthDateRepository>(
  (ref) => SupabaseBirthDateRepository(ref.watch(supabaseClientProvider)),
);

/// The signed-in user's date of birth; null when not given yet (or signed out).
final birthDateProvider = FutureProvider<DateTime?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  return (await ref.watch(birthDateRepositoryProvider).mine()).getOrThrow();
});

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => ApiAccountRepository(ref.watch(apiClientProvider)),
);

/// Documents the signed-in user still has to accept. Empty when signed out.
final pendingConsentsProvider = FutureProvider<List<LegalDocument>>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return const [];
  return (await ref.watch(consentRepositoryProvider).pending()).getOrThrow();
});

final latestLegalDocumentsProvider = FutureProvider<List<LegalDocument>>(
  (ref) async =>
      (await ref.watch(consentRepositoryProvider).latest()).getOrThrow(),
);

/// Account lifecycle state of the signed-in user. Null when signed out.
final accountStateProvider = FutureProvider<AccountState?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  return (await ref.watch(accountRepositoryProvider).get()).getOrThrow();
});

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => ApiSecurityRepository(ref.watch(apiClientProvider)),
);

final deviceSignalSourceProvider = Provider<DeviceSignalSource>((ref) => PlatformDeviceSignalSource());

final passkeyAuthenticatorProvider = Provider<PasskeyAuthenticator>((ref) => createPasskeyAuthenticator());

/// The signed-in user's passkeys (settings).
final passkeysProvider = FutureProvider.autoDispose<List<PasskeyView>>(
  (ref) async => (await ref.watch(securityRepositoryProvider).passkeys()).getOrThrow(),
);

/// Security verification state of this session (docs/ARCHITECTURE.md §3h). Null when signed out.
///
/// The token hook decides the token's role when it is issued. When the server already counts this session as
/// done but the token in hand still says `unverified` (issued before the last step), the session is refreshed
/// first, so everything after the gate runs with an `authenticated` token.
final securityStatusProvider = FutureProvider<SecurityStatus?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  final status = (await ref.watch(securityRepositoryProvider).status()).getOrThrow();
  final auth = ref.read(supabaseClientProvider).auth;
  if (status.step == SecurityStep.done && tokenRole(auth.currentSession?.accessToken) == 'unverified') {
    await auth.refreshSession();
  }
  return status;
});

/// True after the user opened a password reset link, until a new password
/// is set or they sign out.
final passwordRecoveryProvider =
    NotifierProvider<PasswordRecovery, bool>(PasswordRecovery.new);

class PasswordRecovery extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(authStateProvider, (_, next) {
      switch (next.value?.event) {
        case AuthChangeEvent.passwordRecovery:
          state = true;
        case AuthChangeEvent.signedOut:
          state = false;
        default:
          break;
      }
    });
    return false;
  }

  void complete() => state = false;
}
