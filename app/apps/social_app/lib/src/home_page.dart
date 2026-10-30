import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:live/live.dart';
import 'package:messaging/messaging.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

import 'router.dart' show openTonightChat;

/// "Bugün": live broadcasts and upcoming organizations of the user's groups
/// come before the posts (docs/DESIGN.md §7, Bugün).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => HomeFeedScreen(
        title: const _Greeting(),
        onRefresh: refreshToday,
        actions: [
          IconButton(tooltip: 'Ara', icon: const Icon(Icons.search_rounded), onPressed: () => context.go(FeedRoutes.explore)),
          IconButton(
            tooltip: 'Bildirimler',
            icon: const NotificationsIcon(),
            onPressed: () => context.go(NotificationRoutes.list),
          ),
          const MessagesButton(),
        ],
        top: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LiveNowTray(),
            const StartingSoonSection(),
            const TonightCard(openChat: openTonightChat),
            UpcomingEventsSection(onFindGroups: () => context.go(GroupRoutes.discover)),
          ],
        ),
      );
}

const _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

/// "Günaydın, Demo" under today's date.
class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final name = ref.watch(myProfileProvider).value?.displayName.split(' ').first;
    final hello = switch (now.hour) {
      < 5 => 'İyi geceler',
      < 12 => 'Günaydın',
      < 18 => 'İyi günler',
      _ => 'İyi akşamlar',
    };
    final date = formatDateTr(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${date.substring(0, date.lastIndexOf(' '))}, ${_weekdays[now.weekday - 1]}',
          style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
        ),
        // Shrinks instead of cutting the name off at large text sizes.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(name == null ? hello : '$hello, $name', maxLines: 1, style: textTheme.headlineMedium),
        ),
      ],
    );
  }
}
