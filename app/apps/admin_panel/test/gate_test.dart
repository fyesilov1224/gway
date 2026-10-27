import 'package:admin/admin.dart';
import 'package:admin_panel/src/gate.dart';
import 'package:admin_panel/src/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

void main() {
  test('only platform staff get past the gate', () {
    AdminGate gate(AsyncValue<StaffRole?> role, {bool signedIn = true}) =>
        resolveAdminGate(signedIn: signedIn, passwordRecovery: false, role: role);

    expect(gate(const AsyncData(null), signedIn: false), AdminGate.signedOut);
    expect(gate(const AsyncLoading()), AdminGate.loading);
    expect(gate(const AsyncData(null)), AdminGate.notAuthorized);
    expect(gate(const AsyncData(StaffRole.support)), AdminGate.ready);
  });

  test('redirects follow the gate', () {
    Uri u(String s) => Uri.parse(s);

    expect(adminRedirectFor(AdminGate.signedOut, u('/users/1')), IdentityRoutes.signIn);
    expect(adminRedirectFor(AdminGate.signedOut, u('/forgot-password')), isNull);
    expect(adminRedirectFor(AdminGate.notAuthorized, u('/')), AdminRoutes.notAuthorized);
    expect(adminRedirectFor(AdminGate.ready, u('/sign-in')), AdminRoutes.overview);
    expect(adminRedirectFor(AdminGate.ready, u('/users/1')), isNull);
  });
}
