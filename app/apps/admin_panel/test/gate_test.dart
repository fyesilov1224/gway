import 'package:admin/admin.dart';
import 'package:admin_panel/src/gate.dart';
import 'package:admin_panel/src/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

SecurityStatus _security(SecurityStep step) => SecurityStatus(enforced: true, sessionVerified: false, step: step);

void main() {
  test('only platform staff get past the gate', () {
    AdminGate gate(AsyncValue<StaffRole?> role, {bool signedIn = true}) => resolveAdminGate(
          signedIn: signedIn,
          passwordRecovery: false,
          security: AsyncData(_security(SecurityStep.done)),
          role: role,
        );

    expect(gate(const AsyncData(null), signedIn: false), AdminGate.signedOut);
    expect(gate(const AsyncLoading()), AdminGate.loading);
    expect(gate(const AsyncData(null)), AdminGate.notAuthorized);
    expect(gate(const AsyncData(StaffRole.support)), AdminGate.ready);
  });

  test('staff pass security verification before their role counts', () {
    AdminGate gate(AsyncValue<SecurityStatus?> security) => resolveAdminGate(
          signedIn: true,
          passwordRecovery: false,
          security: security,
          role: const AsyncData(StaffRole.admin),
        );

    for (final step in [SecurityStep.location, SecurityStep.phone, SecurityStep.secondFactor, SecurityStep.restricted]) {
      expect(gate(AsyncData(_security(step))), AdminGate.security);
    }
    expect(gate(const AsyncLoading()), AdminGate.loading);
    expect(gate(AsyncError(Exception(), StackTrace.empty)), AdminGate.error);
  });

  test('redirects follow the gate', () {
    Uri u(String s) => Uri.parse(s);

    expect(adminRedirectFor(AdminGate.signedOut, u('/users/1')), IdentityRoutes.signIn);
    expect(adminRedirectFor(AdminGate.signedOut, u('/forgot-password')), isNull);
    expect(adminRedirectFor(AdminGate.security, u('/users/1')), IdentityRoutes.security);
    expect(adminRedirectFor(AdminGate.notAuthorized, u('/')), AdminRoutes.notAuthorized);
    expect(adminRedirectFor(AdminGate.ready, u('/sign-in')), AdminRoutes.overview);
    expect(adminRedirectFor(AdminGate.ready, u('/security')), AdminRoutes.overview);
    expect(adminRedirectFor(AdminGate.ready, u('/users/1')), isNull);
  });
}
