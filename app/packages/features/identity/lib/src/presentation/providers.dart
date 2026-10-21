import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/api_account_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../data/supabase_consent_repository.dart';
import '../domain/account.dart';
import '../domain/auth.dart';
import '../domain/legal.dart';

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
