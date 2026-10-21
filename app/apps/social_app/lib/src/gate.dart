import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';
import 'package:profile/profile.dart';

/// Where the signed-in (or not) user must be. Enforces the order
/// sign-in → KVKK consents → onboarding → app (docs/ARCHITECTURE.md §3a).
enum AppGate {
  loading,
  error,
  signedOut,
  passwordRecovery,
  suspended,
  deletionPending,
  needsConsent,
  needsOnboarding,
  ready,
}

AppGate resolveGate({
  required bool signedIn,
  required bool passwordRecovery,
  required AsyncValue<AccountState?> account,
  required AsyncValue<List<LegalDocument>> pendingConsents,
  required AsyncValue<Profile?> profile,
  required DateTime now,
}) {
  if (!signedIn) return AppGate.signedOut;
  if (passwordRecovery) return AppGate.passwordRecovery;

  // Keep the previous value while refreshing so the screen does not flicker.
  if (!account.hasValue) return account.hasError ? AppGate.error : AppGate.loading;
  final state = account.value;
  if (state != null) {
    if (state.isSuspendedAt(now)) return AppGate.suspended;
    if (state.status == AccountStatus.pendingDeletion) return AppGate.deletionPending;
  }

  if (!pendingConsents.hasValue) return pendingConsents.hasError ? AppGate.error : AppGate.loading;
  if (pendingConsents.value!.isNotEmpty) return AppGate.needsConsent;

  if (!profile.hasValue) return profile.hasError ? AppGate.error : AppGate.loading;
  if (profile.value == null) return AppGate.needsOnboarding;

  return AppGate.ready;
}

final gateProvider = Provider<AppGate>(
  (ref) => resolveGate(
    signedIn: ref.watch(currentUserIdProvider) != null,
    passwordRecovery: ref.watch(passwordRecoveryProvider),
    account: ref.watch(accountStateProvider),
    pendingConsents: ref.watch(pendingConsentsProvider),
    profile: ref.watch(myProfileProvider),
    now: DateTime.now(),
  ),
);

/// Reloads everything the gate depends on (retry after an error).
void refreshGate(WidgetRef ref) {
  ref
    ..invalidate(accountStateProvider)
    ..invalidate(pendingConsentsProvider)
    ..invalidate(myProfileProvider);
}
