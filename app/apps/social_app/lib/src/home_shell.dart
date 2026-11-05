import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:games/games.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:matching/matching.dart';
import 'package:messaging/messaging.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

import 'l10n.dart';

typedef _Destination = ({String path, String label, IconData icon, IconData selectedIcon});

/// Top-level destinations: a floating dock with the create button on phones
/// (top-level pages only), a labeled sidebar with the user's groups on wide
/// screens (every page in the shell; docs/DESIGN.md §7).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  // A getter, so the labels follow the app language.
  static List<_Destination> get _destinations => [
    (path: FeedRoutes.home, label: socialAppL10n.tabToday, icon: Icons.wb_sunny_outlined, selectedIcon: Icons.wb_sunny_rounded),
    (path: GroupRoutes.discover, label: socialAppL10n.tabGroups, icon: Icons.groups_outlined, selectedIcon: Icons.groups_rounded),
    (path: EventRoutes.calendar, label: socialAppL10n.tabCalendar, icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded),
    (path: ProfileRoutes.mine, label: socialAppL10n.tabMe, icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded),
  ];

  /// Pages reached from the navigation itself; they get the dock on phones
  /// and a centered column on wide screens, so the title lines up with the content.
  static final _topLevel = {for (final d in _destinations) d.path, FeedRoutes.explore, NotificationRoutes.list};

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _destinations.indexWhere((d) => d.path == path);
    final topLevel = _topLevel.contains(path);
    if (MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint) {
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
                        constraints: BoxConstraints(maxWidth: path == FeedRoutes.home ? GwLayout.feedMaxWidth : GwLayout.contentMaxWidth),
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

/// The create button: tonight and upcoming plans first, then sharing a post or a story, or starting a group.
Future<void> showCreateSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => _CreateSheet(
        open: (location) {
          Navigator.of(sheet).pop();
          context.push(location);
        },
      ),
    );

class _CreateSheet extends ConsumerWidget {
  const _CreateSheet({required this.open});

  final ValueChanged<String> open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final tonight = ref.watch(tonightProvider).value;
    final free = ref.watch(tonightPeopleProvider).value?.length ?? 0;
    final now = DateTime.now();
    final upcoming = [
      for (final e in ref.watch(calendarProvider(upcomingQuery())).value ?? const <GroupEvent>[])
        if (!e.isCanceled && (e.endsAt ?? e.startsAt).isAfter(now)) e,
    ];
    final mine = upcoming.where((e) => e.isMine).length;

    final tonightNote = switch (tonight) {
      null => socialAppL10n.tonightSay,
      Tonight(table: _?) => socialAppL10n.tonightTableSet,
      Tonight(invites: [_, ...]) => socialAppL10n.tonightInvited,
      Tonight(isFree: true) when free > 0 => socialAppL10n.tonightFreeWithYou(free),
      Tonight(isFree: true) => socialAppL10n.tonightFreeUntil,
      _ when free > 0 => socialAppL10n.tonightFreeCount(free),
      _ => socialAppL10n.tonightSay,
    };
    final upcomingNote = switch (upcoming.length) {
      0 => socialAppL10n.upcomingNone,
      final n when mine > 0 => socialAppL10n.upcomingMine(n, mine),
      final n => socialAppL10n.upcomingCount(n),
    };

    Widget option(IconData icon, GwTone tone, String title, String subtitle, String location) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg),
          leading: _OptionIcon(icon: icon, tone: tone),
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: () => open(location),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: GwSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.sm),
              child: Text(socialAppL10n.forToday, style: textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PlanTile(
                        icon: Icons.nights_stay_rounded,
                        tone: GwTone.lilac,
                        title: socialAppL10n.tonight,
                        subtitle: tonightNote,
                        highlight: tonight?.isFree ?? false,
                        onTap: () => open(EventRoutes.tonight),
                      ),
                    ),
                    const SizedBox(width: GwSpacing.sm),
                    Expanded(
                      child: _PlanTile(
                        icon: Icons.event_available_rounded,
                        tone: GwTone.sky,
                        title: socialAppL10n.upcoming,
                        subtitle: upcomingNote,
                        onTap: () => open(EventRoutes.upcoming),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.lg, GwSpacing.lg, GwSpacing.lg, GwSpacing.xs),
              child: Text(socialAppL10n.share, style: textTheme.titleLarge),
            ),
            option(Icons.photo_library_outlined, GwTone.lilac, socialAppL10n.post, socialAppL10n.postHint, FeedRoutes.create),
            option(Icons.auto_awesome_outlined, GwTone.sky, socialAppL10n.story, socialAppL10n.storyHint, FeedRoutes.newStory),
            option(Icons.group_add_outlined, GwTone.mist, socialAppL10n.group, socialAppL10n.groupHint, GroupRoutes.create),
            // Games get a card of their own, like today's plans: the games list opens behind it.
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.lg, GwSpacing.lg, GwSpacing.lg, 0),
              child: _PlanTile(
                icon: Icons.sports_esports_rounded,
                tone: GwTone.lilac,
                title: socialAppL10n.games,
                subtitle: socialAppL10n.gamesHint,
                onTap: () => open(GamesRoutes.hub),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionIcon extends StatelessWidget {
  const _OptionIcon({required this.icon, required this.tone});

  final IconData icon;
  final GwTone tone;

  @override
  Widget build(BuildContext context) => Container(
        width: GwAvatarSize.md.dimension,
        height: GwAvatarSize.md.dimension,
        decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
        child: Icon(icon, color: tone.strong),
      );
}

/// A large shortcut in the create sheet: icon, title and a live one-line status.
class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final GwTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// A dot on the icon, e.g. while the user is marked free.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: Material(
        color: tone.soft,
        borderRadius: GwRadius.lgAll,
        child: InkWell(
          borderRadius: GwRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Badge(
                      isLabelVisible: highlight,
                      backgroundColor: GwColors.success,
                      child: Container(
                        width: GwAvatarSize.md.dimension,
                        height: GwAvatarSize.md.dimension,
                        decoration: const BoxDecoration(color: GwColors.background, borderRadius: GwRadius.mdAll),
                        child: Icon(icon, color: tone.strong),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: GwSpacing.md + GwSpacing.xxs, color: tone.strong),
                  ],
                ),
                const SizedBox(height: GwSpacing.sm),
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: GwSpacing.xxs),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.fromLTRB(GwSpacing.sm, 0, GwSpacing.sm, GwSpacing.sm),
        child: Container(
          height: GwSpacing.xxl + GwSpacing.md,
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
          decoration: const BoxDecoration(
            color: GwColors.background,
            borderRadius: GwRadius.xlAll,
            border: Border.fromBorderSide(GwBorders.hairline),
          ),
          child: Row(
            children: [
              ...items.take(2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
                child: IconButton.filled(
                  tooltip: socialAppL10n.create,
                  onPressed: () => showCreateSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(GwSpacing.xxl),
                    shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll),
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
    final color = selected ? GwColors.primary : GwColors.textSecondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: GwRadius.lgAll,
          onTap: () => context.go(destination.path),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xxs),
                decoration: BoxDecoration(color: selected ? GwColors.primarySoft : null, borderRadius: GwRadius.xlAll),
                child: Icon(selected ? destination.selectedIcon : destination.icon, color: color),
              ),
              const SizedBox(height: GwSpacing.xxs),
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
      width: GwLayout.sidebarWidth,
      decoration: const BoxDecoration(color: GwColors.background, border: Border(right: GwBorders.hairline)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GwSpacing.md),
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(GwSpacing.xs, GwSpacing.xs, 0, GwSpacing.lg),
              child: Align(alignment: AlignmentDirectional.centerStart, child: GwLogo(size: GwSpacing.lg + GwSpacing.xxs, wordmark: true)),
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
              label: socialAppL10n.notifications,
              selected: path == NotificationRoutes.list,
              onTap: () => context.go(NotificationRoutes.list),
            ),
            _SideItem(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: socialAppL10n.messages,
              selected: false,
              onTap: () => context.push(MessagingRoutes.list),
            ),
            _SideItem(
              icon: const Icon(Icons.favorite_border_rounded),
              label: socialAppL10n.matching,
              selected: path.startsWith(MatchingRoutes.home),
              onTap: () => context.push(MatchingRoutes.home),
            ),
            const SizedBox(height: GwSpacing.md),
            GwButton(label: socialAppL10n.create, icon: Icons.add_rounded, expand: true, onPressed: () => showCreateSheet(context)),
            if (groups.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.xs, GwSpacing.lg, GwSpacing.xs, GwSpacing.xs),
                child: Text(socialAppL10n.myGroups, style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
              ),
              for (final g in groups.take(8))
                _SideItem(
                  icon: GwAvatar(name: g.name, shape: GwAvatarShape.group, imageUrl: g.logoUrl, size: GwAvatarSize.sm),
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
        padding: const EdgeInsets.only(bottom: GwSpacing.xxs),
        child: Material(
          color: selected ? GwColors.primarySoft : Colors.transparent,
          borderRadius: GwRadius.mdAll,
          child: InkWell(
            borderRadius: GwRadius.mdAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
              child: Row(
                children: [
                  IconTheme.merge(data: IconThemeData(color: selected ? GwColors.primary : GwColors.textPrimary), child: icon),
                  const SizedBox(width: GwSpacing.sm),
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
