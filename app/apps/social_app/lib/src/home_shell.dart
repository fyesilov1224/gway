import 'package:design_system/design_system.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

/// Top-level destinations: a bottom bar on phones, a rail on wide screens.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  /// Notifications have no icon here: they show the unread badge instead.
  static const _destinations = [
    (FeedRoutes.home, 'Akış', Icons.home_outlined, Icons.home_rounded),
    (FeedRoutes.explore, 'Keşfet', Icons.search, Icons.search),
    (GroupRoutes.discover, 'Gruplar', Icons.groups_outlined, Icons.groups),
    (NotificationRoutes.list, 'Bildirimler', null, null),
    (ProfileRoutes.mine, 'Profil', Icons.person_outline, Icons.person),
  ];

  static Widget _icon(IconData? icon, {required bool selected}) =>
      icon == null ? NotificationsIcon(selected: selected) : Icon(icon);

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _destinations.indexWhere((d) => d.$1 == path).clamp(0, _destinations.length - 1);
    void go(int i) => context.go(_destinations[i].$1);

    if (MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: GxSpacing.md),
                child: GxLogo(size: GxSpacing.xl),
              ),
              destinations: [
                for (final (_, label, icon, selectedIcon) in _destinations)
                  NavigationRailDestination(
                    icon: _icon(icon, selected: false),
                    selectedIcon: _icon(selectedIcon, selected: true),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: GxBorders.hairline)),
        child: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: go,
          backgroundColor: GxColors.background,
          indicatorColor: GxColors.primarySoft,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            for (final (_, label, icon, selectedIcon) in _destinations)
              NavigationDestination(
                icon: _icon(icon, selected: false),
                selectedIcon: _icon(selectedIcon, selected: true),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}
