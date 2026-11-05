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

import 'l10n.dart';

/// "Bugün": live broadcasts and what starts within hours come before the posts;
/// "Bu akşam" and "Yaklaşanlar" open from the create button (docs/DESIGN.md §7, Bugün).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => HomeFeedScreen(
        title: const _Greeting(),
        onRefresh: refreshToday,
        actions: [
          IconButton(tooltip: socialAppL10n.search, icon: const Icon(Icons.search_rounded), onPressed: () => context.go(FeedRoutes.explore)),
          IconButton(
            tooltip: socialAppL10n.notifications,
            icon: const NotificationsIcon(),
            onPressed: () => context.go(NotificationRoutes.list),
          ),
          const MessagesButton(),
        ],
        top: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [LiveNowTray(), StartingSoonSection()],
        ),
      );
}

/// The splash while the gate resolves. A token that already carries the verified role can read, so Bugün's data
/// loads alongside the gate instead of after it; the screen cache (`ref.cacheFor`) hands it to [HomePage].
class StartupSplash extends ConsumerWidget {
  const StartupSplash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    if (me != null && ref.watch(sessionRoleProvider) == 'authenticated') {
      ref
        ..watch(postListProvider(const HomeFeed()))
        ..watch(storyTrayProvider)
        ..watch(myLiveProvider)
        ..watch(startingSoonProvider)
        ..watch(unreadNotificationsProvider)
        ..watch(userGroupsProvider(me));
    }
    return const GwSplash();
  }
}

/// "Günaydın, Demo" under today's date.
class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final name = ref.watch(myProfileProvider).value?.displayName.split(' ').first;
    final hello = switch (now.hour) {
      < 5 => socialAppL10n.goodNight,
      < 12 => socialAppL10n.goodMorning,
      < 18 => socialAppL10n.goodAfternoon,
      _ => socialAppL10n.goodEvening,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatWeekdayDate(now),
          style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary),
        ),
        // Shrinks instead of cutting the name off at large text sizes.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(name == null ? hello : socialAppL10n.greetingName(hello, name), maxLines: 1, style: textTheme.headlineMedium),
        ),
      ],
    );
  }
}
