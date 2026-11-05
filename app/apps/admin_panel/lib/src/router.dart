import 'package:admin/admin.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';

import 'gate.dart';

abstract final class PanelRoutes {
  static const loading = '/loading';
  static const error = '/error';
}

const _publicPaths = {IdentityRoutes.signIn, IdentityRoutes.forgotPassword};

final _gateOnly = {
  PanelRoutes.loading,
  PanelRoutes.error,
  ..._publicPaths,
  IdentityRoutes.resetPassword,
  IdentityRoutes.security,
  AdminRoutes.notAuthorized,
};

/// Pure redirect rule, tested without a router.
String? adminRedirectFor(AdminGate gate, Uri location) {
  final path = location.path;
  final target = switch (gate) {
    AdminGate.loading => PanelRoutes.loading,
    AdminGate.error => PanelRoutes.error,
    AdminGate.signedOut => IdentityRoutes.signIn,
    AdminGate.passwordRecovery => IdentityRoutes.resetPassword,
    AdminGate.security => IdentityRoutes.security,
    AdminGate.notAuthorized => AdminRoutes.notAuthorized,
    AdminGate.ready => null,
  };

  if (target == null) return _gateOnly.contains(path) ? AdminRoutes.overview : null;
  if (gate == AdminGate.signedOut && _publicPaths.contains(path)) return null;
  return path == target ? null : target;
}

final routerProvider = Provider<GoRouter>((ref) {
  final gate = ValueNotifier(ref.read(adminGateProvider));
  ref
    ..listen(adminGateProvider, (_, next) => gate.value = next)
    ..onDispose(gate.dispose);

  void signOut() => ref.read(authRepositoryProvider).signOut();

  final router = GoRouter(
    refreshListenable: gate,
    redirect: (context, state) => adminRedirectFor(gate.value, state.uri),
    // An unknown or outdated link: a friendly page instead of the router's raw error.
    errorBuilder: (context, _) => Scaffold(
      appBar: AppBar(),
      body: GwEmptyState(
        icon: Icons.link_off,
        message: 'Aradığın sayfa bulunamadı. Bağlantı eski ya da hatalı olabilir.',
        actionLabel: 'Kullanıcılara dön',
        onAction: () => context.go(AdminRoutes.overview),
      ),
    ),
    routes: [
      GoRoute(path: PanelRoutes.loading, builder: (_, _) => const GwSplash(caption: 'Yönetim')),
      GoRoute(
        path: PanelRoutes.error,
        builder: (_, _) => Scaffold(
          body: GwErrorState(
            message: 'Yetki bilgin yüklenemedi. Bağlantını kontrol edip tekrar dene.',
            onRetry: () => ref.invalidate(myStaffRoleProvider),
          ),
        ),
      ),
      GoRoute(
        path: IdentityRoutes.signIn,
        builder: (_, _) => const SignInScreen(
          title: 'GWAY Yönetim',
          subtitle: 'Platform ekibi hesabınla giriş yap.',
          allowSignUp: false,
          allowSocial: false,
        ),
      ),
      GoRoute(path: IdentityRoutes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: IdentityRoutes.resetPassword, builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(path: IdentityRoutes.security, builder: (_, _) => const SecurityScreen()),
      GoRoute(path: AdminRoutes.notAuthorized, builder: (_, _) => NotAuthorizedScreen(onSignOut: signOut)),
      ShellRoute(
        builder: (_, _, child) => AdminShell(onSignOut: signOut, child: child),
        routes: [
          GoRoute(path: AdminRoutes.overview, builder: (_, _) => const AdminOverviewScreen()),
          GoRoute(path: AdminRoutes.users, builder: (_, _) => const UsersScreen()),
          GoRoute(path: AdminRoutes.online, builder: (_, _) => const LiveUsersScreen()),
          GoRoute(
            path: '/users/:id',
            builder: (_, state) => UserDetailScreen(userId: state.pathParameters['id']!),
          ),
          GoRoute(path: AdminRoutes.groups, builder: (_, _) => const AdminGroupsScreen()),
          GoRoute(
            path: '/groups/:id',
            builder: (_, state) => AdminGroupDetailScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(path: AdminRoutes.content, builder: (_, _) => const AdminContentScreen()),
          GoRoute(
            path: '/content/:id',
            builder: (_, state) => AdminPostDetailScreen(postId: state.pathParameters['id']!),
          ),
          GoRoute(path: AdminRoutes.goals, builder: (_, _) => const AdminGoalsScreen()),
          GoRoute(path: AdminRoutes.leagues, builder: (_, _) => const AdminLeaguesScreen()),
          GoRoute(path: AdminRoutes.reports, builder: (_, _) => const AdminReportsScreen()),
          GoRoute(path: AdminRoutes.events, builder: (_, _) => const AdminEventsScreen()),
          GoRoute(path: AdminRoutes.live, builder: (_, _) => const AdminLiveScreen()),
          GoRoute(path: AdminRoutes.notifications, builder: (_, _) => const AdminNotificationsScreen()),
          GoRoute(path: AdminRoutes.legal, builder: (_, _) => const AdminLegalScreen()),
          GoRoute(path: AdminRoutes.securityReviews, builder: (_, _) => const AdminSecurityScreen()),
          GoRoute(path: AdminRoutes.matching, builder: (_, _) => const AdminMatchingScreen()),
          GoRoute(path: AdminRoutes.games, builder: (_, _) => const AdminGamesScreen()),
          GoRoute(path: AdminRoutes.billing, builder: (_, _) => const AdminBillingScreen()),
          GoRoute(path: AdminRoutes.plans, builder: (_, _) => const AdminPlansScreen()),
          GoRoute(path: AdminRoutes.support, builder: (_, _) => const AdminSupportScreen()),
          GoRoute(
            path: '/support/:id',
            builder: (_, state) => AdminTicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
