import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:matching/matching.dart';
import 'package:messaging/messaging.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

typedef _Destination = ({String path, String label, IconData icon, IconData selectedIcon});

/// Top-level destinations: a floating dock with the create button on phones
/// (top-level pages only), a labeled sidebar with the user's groups on wide
/// screens (every page in the shell; docs/DESIGN.md §7).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const List<_Destination> _destinations = [
    (path: FeedRoutes.home, label: 'Bugün', icon: Icons.wb_sunny_outlined, selectedIcon: Icons.wb_sunny_rounded),
    (path: GroupRoutes.discover, label: 'Gruplar', icon: Icons.groups_outlined, selectedIcon: Icons.groups_rounded),
    (path: EventRoutes.calendar, label: 'Takvim', icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded),
    (path: ProfileRoutes.mine, label: 'Ben', icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded),
  ];

  /// Pages reached from the navigation itself; they get the dock on phones
  /// and a centered column on wide screens, so the title lines up with the content.
  static final _topLevel = {for (final d in _destinations) d.path, FeedRoutes.explore, NotificationRoutes.list};

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _destinations.indexWhere((d) => d.path == path);
    final topLevel = _topLevel.contains(path);
    if (MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(selected: selected, path: path),
            Expanded(
              child: topLevel
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        // The home column is narrower so photos stay a comfortable size.
                        constraints: BoxConstraints(maxWidth: path == FeedRoutes.home ? GxLayout.feedMaxWidth : GxLayout.contentMaxWidth),
                        child: child,
                      ),
                    )
                  : child,
            ),
          ],
        ),
      );
    }
    return Scaffold(body: child, bottomNavigationBar: topLevel ? _Dock(selected: selected) : null);
  }
}

/// Share a post or a story, or start a group.
Future<void> showCreateSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) {
        void open(String location) {
          Navigator.of(sheet).pop();
          context.push(location);
        }

        Widget option(IconData icon, GxTone tone, String title, String subtitle, String location) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg),
              leading: Container(
                width: GxAvatarSize.md.dimension,
                height: GxAvatarSize.md.dimension,
                decoration: BoxDecoration(color: tone.soft, borderRadius: GxRadius.mdAll),
                child: Icon(icon, color: tone.strong),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              onTap: () => open(location),
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.lg, 0, GxSpacing.lg, GxSpacing.xs),
                child: Text('Paylaş', style: Theme.of(sheet).textTheme.titleLarge),
              ),
              option(Icons.photo_library_outlined, GxTone.lilac, 'Gönderi', '10 fotoğraf ya da videoya kadar', FeedRoutes.create),
              option(Icons.auto_awesome_outlined, GxTone.sky, 'Hikâye', '24 saat görünür', FeedRoutes.newStory),
              option(Icons.group_add_outlined, GxTone.mist, 'Grup', 'Kendi topluluğunu kur', GroupRoutes.create),
              const SizedBox(height: GxSpacing.md),
            ],
          ),
        );
      },
    );

class _Dock extends StatelessWidget {
  const _Dock({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final (i, d) in HomeShell._destinations.indexed) _DockItem(destination: d, selected: i == selected),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GxSpacing.sm, 0, GxSpacing.sm, GxSpacing.sm),
        child: Container(
          height: GxSpacing.xxl + GxSpacing.md,
          padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs),
          decoration: const BoxDecoration(
            color: GxColors.background,
            borderRadius: GxRadius.xlAll,
            border: Border.fromBorderSide(GxBorders.hairline),
          ),
          child: Row(
            children: [
              ...items.take(2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs),
                child: IconButton.filled(
                  tooltip: 'Paylaş',
                  onPressed: () => showCreateSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(GxSpacing.xxl),
                    shape: const RoundedRectangleBorder(borderRadius: GxRadius.lgAll),
                  ),
                ),
              ),
              ...items.skip(2),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({required this.destination, required this.selected});

  final _Destination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GxColors.primary : GxColors.textSecondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: GxRadius.lgAll,
          onTap: () => context.go(destination.path),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xxs),
                decoration: BoxDecoration(color: selected ? GxColors.primarySoft : null, borderRadius: GxRadius.xlAll),
                child: Icon(selected ? destination.selectedIcon : destination.icon, color: color),
              ),
              const SizedBox(height: GxSpacing.xxs),
              Text(
                destination.label,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.selected, required this.path});

  final int selected;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final groups = me == null ? const <Group>[] : ref.watch(userGroupsProvider(me)).value ?? const <Group>[];
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: GxLayout.sidebarWidth,
      decoration: const BoxDecoration(color: GxColors.background, border: Border(right: GxBorders.hairline)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GxSpacing.md),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(GxSpacing.xs, GxSpacing.xs, 0, GxSpacing.lg),
              child: Align(alignment: Alignment.centerLeft, child: GxLogo(size: GxSpacing.lg + GxSpacing.xxs, wordmark: true)),
            ),
            for (final (i, d) in HomeShell._destinations.indexed)
              _SideItem(
                icon: Icon(i == selected ? d.selectedIcon : d.icon),
                label: d.label,
                selected: i == selected,
                onTap: () => context.go(d.path),
              ),
            _SideItem(
              icon: NotificationsIcon(selected: path == NotificationRoutes.list),
              label: 'Bildirimler',
              selected: path == NotificationRoutes.list,
              onTap: () => context.go(NotificationRoutes.list),
            ),
            _SideItem(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: 'Mesajlar',
              selected: false,
              onTap: () => context.push(MessagingRoutes.list),
            ),
            _SideItem(
              icon: const Icon(Icons.favorite_border_rounded),
              label: 'Eşleşme',
              selected: path.startsWith(MatchingRoutes.home),
              onTap: () => context.push(MatchingRoutes.home),
            ),
            const SizedBox(height: GxSpacing.md),
            GxButton(label: 'Paylaş', icon: Icons.add_rounded, expand: true, onPressed: () => showCreateSheet(context)),
            if (groups.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.xs, GxSpacing.lg, GxSpacing.xs, GxSpacing.xs),
                child: Text('Gruplarım', style: textTheme.labelLarge?.copyWith(color: GxColors.textSecondary)),
              ),
              for (final g in groups.take(8))
                _SideItem(
                  icon: GxAvatar(name: g.name, shape: GxAvatarShape.group, imageUrl: g.logoUrl, size: GxAvatarSize.sm),
                  label: g.name,
                  selected: path == GroupRoutes.group(g.handle),
                  onTap: () => context.push(GroupRoutes.group(g.handle)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: GxSpacing.xxs),
        child: Material(
          color: selected ? GxColors.primarySoft : Colors.transparent,
          borderRadius: GxRadius.mdAll,
          child: InkWell(
            borderRadius: GxRadius.mdAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
              child: Row(
                children: [
                  IconTheme.merge(data: IconThemeData(color: selected ? GxColors.primary : GxColors.textPrimary), child: icon),
                  const SizedBox(width: GxSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
