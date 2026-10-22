import 'package:billing/billing.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:identity/identity.dart';
import 'package:live/live.dart';
import 'package:messaging/messaging.dart';
import 'package:moderation/moderation.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';
import 'package:support/support.dart';

import 'feed_pages.dart';
import 'gate.dart';
import 'group_chat_pages.dart';
import 'group_events_pages.dart';
import 'group_live_pages.dart';
import 'group_moderation_pages.dart';
import 'group_plan_pages.dart';
import 'group_support_link.dart';
import 'home_shell.dart';
import 'settings_screen.dart';

abstract final class AppRoutes {
  static const loading = '/loading';
  static const error = '/error';
  static const settings = '/settings';
}

/// The only location allowed for each gate state other than [AppGate.ready].
String? _gateLocation(AppGate gate) => switch (gate) {
      AppGate.loading => AppRoutes.loading,
      AppGate.error => AppRoutes.error,
      AppGate.signedOut => IdentityRoutes.signIn,
      AppGate.passwordRecovery => IdentityRoutes.resetPassword,
      AppGate.suspended => IdentityRoutes.suspended,
      AppGate.deletionPending => IdentityRoutes.deletionPending,
      AppGate.needsConsent => IdentityRoutes.consent,
      AppGate.needsOnboarding => ProfileRoutes.onboarding,
      AppGate.ready => null,
    };

/// Locations that only make sense before the app is ready.
final _gateOnly = {
  AppRoutes.loading,
  AppRoutes.error,
  ...IdentityRoutes.public,
  IdentityRoutes.resetPassword,
  IdentityRoutes.suspended,
  IdentityRoutes.deletionPending,
  IdentityRoutes.consent,
  ProfileRoutes.onboarding,
};

/// Pure redirect rule, tested without a router.
String? redirectFor(AppGate gate, Uri location) {
  final path = location.path;
  final target = _gateLocation(gate);

  if (gate == AppGate.ready) {
    if (!_gateOnly.contains(path)) return null;
    // Return to the deep link the user opened before loading finished.
    final from = location.queryParameters['from'];
    return from != null && !_gateOnly.contains(Uri.parse(from).path) ? from : FeedRoutes.home;
  }
  if (gate == AppGate.signedOut && IdentityRoutes.public.contains(path)) return null;
  if (path == target) return null;
  if (gate == AppGate.loading && !_gateOnly.contains(path)) {
    return Uri(path: AppRoutes.loading, queryParameters: {'from': location.toString()}).toString();
  }
  return target;
}

final routerProvider = Provider<GoRouter>((ref) {
  final gate = ValueNotifier(ref.read(gateProvider));
  ref
    ..listen(gateProvider, (_, next) => gate.value = next)
    ..onDispose(gate.dispose);

  final router = GoRouter(
    refreshListenable: gate,
    redirect: (context, state) => redirectFor(gate.value, state.uri),
    // An unknown or outdated link: a friendly page instead of the router's raw error.
    errorBuilder: (context, _) => Scaffold(
      appBar: AppBar(),
      body: GxEmptyState(
        icon: Icons.link_off,
        message: 'Aradığın sayfa bulunamadı. Bağlantı eski ya da hatalı olabilir.',
        actionLabel: 'Ana sayfaya dön',
        onAction: () => context.go(FeedRoutes.home),
      ),
    ),
    routes: [
      GoRoute(path: AppRoutes.loading, builder: (_, _) => const GxSplash()),
      GoRoute(path: AppRoutes.error, builder: (_, _) => const _GateErrorScreen()),
      GoRoute(path: IdentityRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: IdentityRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: IdentityRoutes.checkEmail,
        builder: (_, state) => CheckEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: IdentityRoutes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: IdentityRoutes.resetPassword, builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(path: IdentityRoutes.suspended, builder: (_, _) => const SuspendedScreen()),
      GoRoute(path: IdentityRoutes.deletionPending, builder: (_, _) => const DeletionPendingScreen()),
      GoRoute(path: IdentityRoutes.consent, builder: (_, _) => const ConsentScreen()),
      GoRoute(
        path: ProfileRoutes.onboarding,
        builder: (_, _) => OnboardingScreen(onSignOut: () => ref.read(authRepositoryProvider).signOut()),
      ),
      ShellRoute(
        builder: (_, _, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: ProfileRoutes.mine,
            builder: (context, _) => ProfileScreen(
              onOpenSettings: () => context.push(AppRoutes.settings),
              sections: const [profileContributionsSection, profilePostsSection, _groupsSection],
            ),
          ),
          GoRoute(path: FeedRoutes.home, builder: (_, _) => const HomeFeedScreen(top: LiveNowTray(), trailingActions: [_teammatesButton, _calendarButton, MessagesButton()])),
          GoRoute(path: FeedRoutes.explore, builder: (_, _) => const ExploreScreen(peopleResults: peopleResults)),
          GoRoute(path: GroupRoutes.discover, builder: (_, _) => const GroupsScreen(actions: [_mapButton])),
          GoRoute(path: NotificationRoutes.list, builder: (_, _) => NotificationsScreen(links: notificationLinks)),
        ],
      ),
      GoRoute(
        path: '/p/:id',
        builder: (_, state) => PostScreen(postId: state.pathParameters['id']!),
        routes: [
          GoRoute(path: 'comments', builder: (_, state) => CommentsScreen(postId: state.pathParameters['id']!)),
          GoRoute(path: 'edit', builder: (_, state) => EditPostScreen(postId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(
        path: FeedRoutes.create,
        builder: (_, state) => CreatePostScreen(
          groupId: state.uri.queryParameters['group'],
          eventId: state.uri.queryParameters['event'],
        ),
      ),
      GoRoute(
        path: '/e/:id',
        builder: (_, state) => EventScreen(eventId: state.pathParameters['id']!, links: eventLinks),
        routes: [GoRoute(path: 'edit', builder: (_, state) => EventEditorScreen(eventId: state.pathParameters['id']))],
      ),
      GoRoute(path: EventRoutes.map, builder: (_, _) => const DiscoverMapScreen(onOpenGroup: _openGroup)),
      GoRoute(path: EventRoutes.calendar, builder: (_, state) => CalendarScreen(groupId: state.uri.queryParameters['group'])),
      GoRoute(path: NotificationRoutes.preferences, builder: (_, _) => const NotificationPreferencesScreen()),
      GoRoute(path: '/goals/:id', builder: (_, state) => GoalScreen(goalId: state.pathParameters['id']!)),
      GoRoute(path: '/events/history', builder: (_, state) => EventHistoryScreen(groupId: state.uri.queryParameters['group'] ?? '')),
      GoRoute(path: '/events/new', builder: (_, state) => EventEditorScreen(groupId: state.uri.queryParameters['group'])),
      GoRoute(path: '/live/:id', builder: (_, state) => LiveRoomScreen(broadcastId: state.pathParameters['id']!)),
      GoRoute(path: FeedRoutes.saved, builder: (_, _) => const SavedPostsScreen()),
      GoRoute(path: '/tags/:tag', builder: (_, state) => HashtagScreen(tag: state.pathParameters['tag']!)),
      GoRoute(path: FeedRoutes.newStory, builder: (_, _) => const NewStoryScreen()),
      GoRoute(path: FeedRoutes.archive, builder: (_, _) => const StoryArchiveScreen()),
      GoRoute(path: '/stories/:userId', builder: (_, state) => StoryViewerScreen(userId: state.pathParameters['userId']!)),
      GoRoute(path: '/highlights/:id', builder: (_, state) => HighlightViewerScreen(highlightId: state.pathParameters['id']!)),
      GoRoute(
        path: '/u/:username',
        builder: (_, state) => ProfileScreen(
          username: state.pathParameters['username'],
          sections: const [profileContributionsSection, profilePostsSection, _groupsSection],
          visitorActions: const [profileMessageAction],
        ),
        routes: [
          GoRoute(path: 'followers', builder: (_, state) => FollowListsScreen(username: state.pathParameters['username']!)),
          GoRoute(
            path: 'following',
            builder: (_, state) => FollowListsScreen(username: state.pathParameters['username']!, initial: FollowList.following),
          ),
        ],
      ),
      GoRoute(path: ProfileRoutes.followRequests, builder: (_, _) => const FollowRequestsScreen()),
      GoRoute(path: ProfileRoutes.blocked, builder: (_, _) => const BlockedAccountsScreen()),
      GoRoute(path: ProfileRoutes.teammates, builder: (_, _) => const TeammatesScreen()),
      GoRoute(path: ProfileRoutes.teammateSettings, builder: (_, _) => const TeammateSettingsScreen()),
      GoRoute(path: GroupRoutes.create, builder: (_, _) => const CreateGroupScreen()),
      GoRoute(
        path: '/g/:handle',
        builder: (_, state) => GroupScreen(
          handle: state.pathParameters['handle']!,
          onOpenProfile: _openProfile,
          sections: const [groupChatSection, groupModerationSection, groupLiveSection, groupPlanSection, groupSupportSection],
          contentSections: const [groupEventsSection, groupGoalsSection, groupPollsSection, groupPostsSection],
        ),
        routes: [
          GoRoute(
            path: 'members',
            builder: (_, state) => GroupMembersScreen(
              handle: state.pathParameters['handle']!,
              onOpenProfile: _openProfile,
              onOpenCase: openCase,
              memberNote: memberContributions,
            ),
          ),
          GoRoute(path: 'edit', builder: (_, state) => EditGroupScreen(handle: state.pathParameters['handle']!)),
          GoRoute(path: 'moderation', builder: (_, state) => GroupModerationPage(handle: state.pathParameters['handle']!)),
          // Payment pages return here with ?order= (docs/ARCHITECTURE.md §7).
          GoRoute(
            path: 'plan',
            builder: (_, state) => GroupPlanPage(
              handle: state.pathParameters['handle']!,
              orderId: state.uri.queryParameters['order'],
            ),
            routes: [
              GoRoute(
                path: 'checkout',
                builder: (_, state) => GroupCheckoutPage(
                  handle: state.pathParameters['handle']!,
                  planSlug: state.uri.queryParameters['plan'] ?? '',
                  period: PlanPeriod.parse(state.uri.queryParameters['period']),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: ProfileRoutes.edit, builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: ModerationRoutes.mySanctions,
        builder: (_, _) => MySanctionsScreen(openGroup: (context, handle) => context.push(GroupRoutes.group(handle))),
      ),
      GoRoute(path: IdentityRoutes.deleteAccount, builder: (_, _) => const DeleteAccountScreen()),
      GoRoute(path: IdentityRoutes.legalDocuments, builder: (_, _) => const LegalDocumentsScreen()),
      GoRoute(path: SupportRoutes.list, builder: (_, _) => const SupportScreen()),
      GoRoute(
        path: '/support/new',
        builder: (_, state) => NewTicketScreen(groupId: state.uri.queryParameters['group']),
      ),
      GoRoute(path: '/support/t/:id', builder: (_, state) => TicketScreen(ticketId: state.pathParameters['id']!)),
      GoRoute(
        path: MessagingRoutes.list,
        builder: (_, _) => ConversationsScreen(onFindPeople: (context) => context.push(ProfileRoutes.teammates)),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                ChatScreen(conversationId: state.pathParameters['id']!, onOpenProfile: _openProfile, onOpenGroup: _openGroup),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

Widget _groupsSection(BuildContext context, Profile profile, bool isOwn) =>
    UserGroupsSection(userId: profile.id, isOwn: isOwn);

void _openProfile(BuildContext context, String username) => context.push(ProfileRoutes.user(username));

void _openGroup(BuildContext context, String handle) => context.push(GroupRoutes.group(handle));

/// "Harita" from the groups page.
const _mapButton = _MapButton();

class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: 'Haritada keşfet', icon: const Icon(Icons.map_outlined), onPressed: () => context.push(EventRoutes.map));
}

/// "Ekip arkadaşı bul" from the home feed.
const _teammatesButton = _TeammatesButton();

class _TeammatesButton extends StatelessWidget {
  const _TeammatesButton();

  @override
  Widget build(BuildContext context) => IconButton(
      tooltip: 'Ekip arkadaşı bul', icon: const Icon(Icons.diversity_3_outlined), onPressed: () => context.push(ProfileRoutes.teammates));
}

/// "Takvimim" from the home feed.
const _calendarButton = _CalendarButton();

class _CalendarButton extends StatelessWidget {
  const _CalendarButton();

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: 'Takvimim', icon: const Icon(Icons.calendar_month_outlined), onPressed: () => context.push(EventRoutes.calendar));
}

class _GateErrorScreen extends ConsumerWidget {
  const _GateErrorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GxErrorState(
        message: 'Bilgilerin yüklenemedi. Bağlantını kontrol edip tekrar dene.',
        onRetry: () => refreshGate(ref),
      ),
    );
  }
}
