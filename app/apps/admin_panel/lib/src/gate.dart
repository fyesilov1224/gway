import 'package:admin/admin.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';

/// Staff pass the same security verification as everyone (docs/ARCHITECTURE.md §3h) before their role is read.
enum AdminGate { loading, error, signedOut, passwordRecovery, security, notAuthorized, ready }

AdminGate resolveAdminGate({
  required bool signedIn,
  required bool passwordRecovery,
  required AsyncValue<SecurityStatus?> security,
  required AsyncValue<StaffRole?> role,
}) {
  if (!signedIn) return AdminGate.signedOut;
  if (passwordRecovery) return AdminGate.passwordRecovery;
  if (!security.hasValue) return security.hasError ? AdminGate.error : AdminGate.loading;
  if (security.value case final s? when s.step != SecurityStep.done) return AdminGate.security;
  if (!role.hasValue) return role.hasError ? AdminGate.error : AdminGate.loading;
  return role.value == null ? AdminGate.notAuthorized : AdminGate.ready;
}

final adminGateProvider = Provider<AdminGate>((ref) {
  final security = ref.watch(securityStatusProvider);
  // An unverified token cannot read the staff table; ask only once the session is verified.
  final verified = security.value?.step == SecurityStep.done;
  return resolveAdminGate(
    signedIn: ref.watch(currentUserIdProvider) != null,
    passwordRecovery: ref.watch(passwordRecoveryProvider),
    security: security,
    role: verified ? ref.watch(myStaffRoleProvider) : const AsyncLoading(),
  );
});
