import 'package:admin/admin.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';

enum AdminGate { loading, error, signedOut, passwordRecovery, notAuthorized, ready }

AdminGate resolveAdminGate({
  required bool signedIn,
  required bool passwordRecovery,
  required AsyncValue<StaffRole?> role,
}) {
  if (!signedIn) return AdminGate.signedOut;
  if (passwordRecovery) return AdminGate.passwordRecovery;
  if (!role.hasValue) return role.hasError ? AdminGate.error : AdminGate.loading;
  return role.value == null ? AdminGate.notAuthorized : AdminGate.ready;
}

final adminGateProvider = Provider<AdminGate>(
  (ref) => resolveAdminGate(
    signedIn: ref.watch(currentUserIdProvider) != null,
    passwordRecovery: ref.watch(passwordRecoveryProvider),
    role: ref.watch(myStaffRoleProvider),
  ),
);
