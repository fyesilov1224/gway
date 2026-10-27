import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'routes.dart';

/// Admin panel frame: side navigation on wide screens, a drawer on narrow ones.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child, required this.onSignOut});

  final Widget child;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    final sidebar = _Sidebar(onSignOut: onSignOut, inDrawer: !wide);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: GxLayout.sidebarWidth, child: sidebar),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const _Brand(compact: true)),
      drawer: Drawer(
        width: GxLayout.sidebarWidth,
        shape: const RoundedRectangleBorder(),
        backgroundColor: GxColors.background,
        child: sidebar,
      ),
      body: child,
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GxLogo(size: compact ? GxSpacing.lg : GxSpacing.lg + GxSpacing.xxs, wordmark: true),
        const SizedBox(width: GxSpacing.xs),
        const GxBadge('Yönetim', tone: GxBadgeTone.primary),
      ],
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.onSignOut, required this.inDrawer});

  final VoidCallback onSignOut;
  final bool inDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final path = GoRouterState.of(context).uri.path;
    final email = ref.watch(currentEmailProvider) ?? '';
    final role = ref.watch(myStaffRoleProvider).value;

    void go(String location) {
      if (inDrawer) Navigator.of(context).pop();
      context.go(location);
    }

    return ColoredBox(
      color: GxColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GxSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xs),
                child: _Brand(),
              ),
              const SizedBox(height: GxSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
                child: Text(
                  'YÖNETİM',
                  style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: GxSpacing.xs),
              _NavItem(
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
                label: 'Kullanıcılar',
                selected: path == AdminRoutes.users || path.startsWith('/users'),
                onTap: () => go(AdminRoutes.users),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.groups_2_outlined,
                selectedIcon: Icons.groups_2,
                label: 'Gruplar',
                selected: path.startsWith(AdminRoutes.groups),
                onTap: () => go(AdminRoutes.groups),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.photo_library_outlined,
                selectedIcon: Icons.photo_library,
                label: 'İçerik',
                selected: path.startsWith(AdminRoutes.content),
                onTap: () => go(AdminRoutes.content),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.flag_outlined,
                selectedIcon: Icons.flag,
                label: 'Şikayetler',
                selected: path.startsWith(AdminRoutes.reports),
                onTap: () => go(AdminRoutes.reports),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.event_outlined,
                selectedIcon: Icons.event,
                label: 'Organizasyonlar',
                selected: path.startsWith(AdminRoutes.events),
                onTap: () => go(AdminRoutes.events),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.flag_circle_outlined,
                selectedIcon: Icons.flag_circle,
                label: 'Hedefler',
                selected: path.startsWith(AdminRoutes.goals),
                onTap: () => go(AdminRoutes.goals),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.podcasts_outlined,
                selectedIcon: Icons.podcasts,
                label: 'Canlı yayınlar',
                selected: path.startsWith(AdminRoutes.live),
                onTap: () => go(AdminRoutes.live),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                label: 'Bildirimler',
                selected: path.startsWith(AdminRoutes.notifications),
                onTap: () => go(AdminRoutes.notifications),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: 'Eşleşme',
                selected: path.startsWith(AdminRoutes.matching),
                onTap: () => go(AdminRoutes.matching),
              ),
              const SizedBox(height: GxSpacing.xxs),
              _NavItem(
                icon: Icons.support_agent_outlined,
                selectedIcon: Icons.support_agent,
                label: 'Destek',
                selected: path.startsWith(AdminRoutes.support),
                onTap: () => go(AdminRoutes.support),
              ),
              if (role?.canSeeBilling ?? false) ...[
                const SizedBox(height: GxSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
                  child: Text(
                    'GELİR',
                    style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary, letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(height: GxSpacing.xs),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Abonelikler',
                  selected: path.startsWith(AdminRoutes.billing),
                  onTap: () => go(AdminRoutes.billing),
                ),
                const SizedBox(height: GxSpacing.xxs),
                _NavItem(
                  icon: Icons.workspace_premium_outlined,
                  selectedIcon: Icons.workspace_premium,
                  label: 'Paketler',
                  selected: path.startsWith(AdminRoutes.plans),
                  onTap: () => go(AdminRoutes.plans),
                ),
              ],
              const Spacer(),
              const Divider(),
              const SizedBox(height: GxSpacing.sm),
              Row(
                children: [
                  GxAvatar(name: email.isEmpty ? '?' : email, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                  const SizedBox(width: GxSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                        if (role != null)
                          Text(role.label, style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(tooltip: 'Çıkış yap', icon: const Icon(Icons.logout), onPressed: onSignOut),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GxColors.primary : GxColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? GxColors.primarySoft : Colors.transparent,
        borderRadius: GxRadius.mdAll,
        child: InkWell(
          borderRadius: GxRadius.mdAll,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
              child: Row(
                children: [
                  Icon(selected ? selectedIcon : icon, color: color, size: GxSpacing.md + GxSpacing.xxs),
                  const SizedBox(width: GxSpacing.sm),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? GxColors.primary : GxColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrollable page body with a header, limited to the dashboard width.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    this.breadcrumbs = const [],
    this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
  });

  /// Earlier levels as (label, location); the current page is [title].
  final List<(String, String)> breadcrumbs;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? GxSpacing.xl : GxSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GxLayout.dashboardMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (breadcrumbs.isNotEmpty) ...[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final (label, location) in breadcrumbs) ...[
                      InkWell(
                        borderRadius: GxRadius.smAll,
                        onTap: () => context.go(location),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
                          child: Text(label, style: textTheme.labelLarge?.copyWith(color: GxColors.primary)),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
                    ],
                    if (title != null)
                      Text(title!, style: textTheme.labelLarge?.copyWith(color: GxColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: GxSpacing.md),
              ] else if (title != null) ...[
                Wrap(
                  spacing: GxSpacing.md,
                  runSpacing: GxSpacing.md,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: textTheme.headlineMedium),
                        if (subtitle != null) ...[
                          const SizedBox(height: GxSpacing.xxs),
                          Text(subtitle!, style: textTheme.bodyLarge?.copyWith(color: GxColors.textSecondary)),
                        ],
                      ],
                    ),
                    if (actions.isNotEmpty) Wrap(spacing: GxSpacing.sm, children: actions),
                  ],
                ),
                const SizedBox(height: GxSpacing.lg),
              ],
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
