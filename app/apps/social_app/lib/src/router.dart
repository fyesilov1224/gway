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
import 'package:matching/matching.dart';
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
import 'home_page.dart';
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
      AppGate.security => IdentityRoutes.security,
      AppGate.needsConsent => IdentityRoutes.consent,
      AppGate.needsBirthDate => IdentityRoutes.birthDate,
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
  IdentityRoutes.security,
  IdentityRoutes.consent,
  IdentityRoutes.birthDate,
  ProfileRoutes.onboarding,
};

/// A page someone opened before the app was ready for them, e.g. an invite link before signing in
/// (docs/ARCHITECTURE.md §3b, Paylaşım sayfaları). They land there once sign-in and onboarding are done.
class PendingLink {
  String? location;
}

/// Pure redirect rule, tested without a router.
String? redirectFor(AppGate gate, Uri location, [PendingLink? pending]) {
  final path = location.path;
  final target = _gateLocation(gate);

  // Privacy policy, terms and account deletion stay open in every state (Google Play links).
  if (IdentityRoutes.openToAll.contains(path)) return null;

  if (gate == AppGate.ready) {
    if (!_gateOnly.contains(path)) return null;
    // Return to the deep link the user opened before loading finished, or before signing in.
    final from = location.queryParameters['from'] ?? pending?.location;
    pending?.location = null;
    return from != null && !_gateOnly.contains(Uri.parse(from).path) ? from : FeedRoutes.home;
  }
  if (!_gateOnly.contains(path) && path != FeedRoutes.home) pending?.location = location.toString();
  if (gate == AppGate.signedOut && IdentityRoutes.public.contains(path)) return null;
  if (path == target) return null;
  if (gate == AppGate.loading && !_gateOnly.contains(path)) {
    return Uri(path: AppRoutes.loading, queryParameters: {'from': location.toString()}).toString();
  }
  return target;
}

final routerProvider = Provider<GoRouter>((ref) {
  final gate = ValueNotifier(ref.read(gateProvider));
  final pending = PendingLink();
  ref
    ..listen(gateProvider, (_, next) => gate.value = next)
    ..onDispose(gate.dispose);

  final router = GoRouter(
    refreshListenable: gate,
    redirect: (context, state) => redirectFor(gate.value, state.uri, pending),
    // An unknown or outdated link: a friendly page instead of the router's raw error.
    errorBuilder: (context, _) => Scaffold(
      appBar: AppBar(),
      body: GwEmptyState(
        icon: Icons.link_off,
        message: 'Aradığın sayfa bulunamadı. Bağlantı eski ya da hatalı olabilir.',
        actionLabel: 'Ana sayfaya dön',
        onAction: () => context.go(FeedRoutes.home),
      ),
    ),
    routes: [
      GoRoute(path: AppRoutes.loading, builder: (_, _) => const GwSplash()),
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
      GoRoute(path: IdentityRoutes.security, builder: (_, _) => const SecurityScreen()),
      GoRoute(path: IdentityRoutes.consent, builder: (_, _) => const ConsentScreen()),
      GoRoute(path: IdentityRoutes.birthDate, builder: (_, _) => const BirthDateScreen()),
      GoRoute(
        path: IdentityRoutes.privacyPolicy,
        builder: (_, _) => const PublicLegalScreen(kind: LegalKind.privacyNotice),
      ),
      GoRoute(path: IdentityRoutes.termsOfUse, builder: (_, _) => const PublicLegalScreen(kind: LegalKind.terms)),
      GoRoute(
        path: IdentityRoutes.accountDeletionInfo,
        builder: (context, _) => AccountDeletionInfoScreen(onSignIn: () => context.go(IdentityRoutes.signIn)),
      ),
      GoRoute(
        path: ProfileRoutes.onboarding,
        builder: (_, _) => OnboardingScreen(onSignOut: () => ref.read(authRepositoryProvider).signOut()),
      ),
      // Every page but full-screen media and the live room keeps the navigation on wide screens.
      ShellRoute(
        builder: (_, _, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: ProfileRoutes.mine,
            builder: (context, _) => ProfileScreen(
              onOpenSettings: () => context.push(AppRoutes.settings),
              ownActions: const [_notificationsButton, _savedButton, _matchingButton, _teammatesButton, _yearButton],
              sections: const [profileContributionsSection, profilePostsSection, _groupsSection],
            ),
          ),
          GoRoute(path: FeedRoutes.home, builder: (_, _) => const HomePage()),
          GoRoute(path: '/year', builder: (_, state) => YearSummaryScreen(year: int.tryParse(state.uri.queryParameters['y'] ?? ''))),
          GoRoute(path: EventRoutes.exploration, builder: (_, _) => const ExplorationScreen()),
          GoRoute(path: EventRoutes.met, builder: (_, _) => const MetPeopleScreen()),
          GoRoute(
            path: '/handshake/:id',
            builder: (_, state) => HandshakeScreen(eventId: state.pathParameters['id']!, eventTitle: state.extra as String?),
          ),
          GoRoute(path: EventRoutes.calendar, builder: (_, state) => CalendarScreen(groupId: state.uri.queryParameters['group'])),
          GoRoute(path: FeedRoutes.explore, builder: (_, _) => const ExploreScreen(peopleResults: peopleResults)),
          GoRoute(path: GroupRoutes.discover, builder: (_, _) => const GroupsScreen(actions: [_leagueButton, _mapButton], packages: groupPackagesRow)),
          GoRoute(path: NotificationRoutes.list, builder: (_, _) => NotificationsScreen(links: notificationLinks)),
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
          GoRoute(path: '/i/:code', builder: (_, state) => InviteScreen(code: state.pathParameters['code']!)),
          GoRoute(
            path: '/e/:id',
            builder: (_, state) => EventScreen(eventId: state.pathParameters['id']!, links: eventLinks),
            routes: [GoRoute(path: 'edit', builder: (_, state) => EventEditorScreen(eventId: state.pathParameters['id']))],
          ),
          GoRoute(path: EventRoutes.map, builder: (_, _) => const DiscoverMapScreen(onOpenGroup: _openGroup)),
          GoRoute(path: EventRoutes.tonight, builder: (_, _) => const TonightScreen(openChat: openTonightChat, openProfile: _openProfile)),
          GoRoute(
            path: EventRoutes.upcoming,
            builder: (context, _) => UpcomingScreen(onFindGroups: () => context.go(GroupRoutes.discover)),
          ),
          GoRoute(
            path: '/league',
            builder: (_, state) => LeagueScreen(
              openGroup: _openGroup,
              category: state.uri.queryParameters['category'],
              province: int.tryParse(state.uri.queryParameters['province'] ?? ''),
              month: LeagueScreen.parseMonth(state.uri.queryParameters['month']),
            ),
          ),
          GoRoute(path: NotificationRoutes.preferences, builder: (_, _) => const NotificationPreferencesScreen()),
          GoRoute(path: '/goals/:id', builder: (_, state) => GoalScreen(goalId: state.pathParameters['id']!)),
          GoRoute(path: '/events/history', builder: (_, state) => EventHistoryScreen(groupId: state.uri.queryParameters['group'] ?? '')),
          GoRoute(path: '/events/new', builder: (_, state) => EventEditorScreen(groupId: state.uri.queryParameters['group'])),
          GoRoute(path: FeedRoutes.saved, builder: (_, _) => const SavedPostsScreen()),
          GoRoute(path: '/tags/:tag', builder: (_, state) => HashtagScreen(tag: state.pathParameters['tag']!)),
          GoRoute(path: FeedRoutes.archive, builder: (_, _) => const StoryArchiveScreen()),
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
          GoRoute(path: MatchingRoutes.home, builder: (_, _) => const MatchingScreen(openChat: _openChat)),
          GoRoute(path: MatchingRoutes.matches, builder: (_, _) => const MatchesScreen(openChat: _openChat)),
          GoRoute(path: MatchingRoutes.profile, builder: (_, _) => const MatchProfileScreen()),
          GoRoute(path: MatchingRoutes.setup, builder: (_, _) => const MatchProfileScreen()),
          GoRoute(path: MatchingRoutes.likes, builder: (_, _) => const MatchLikesScreen(openChat: _openChat)),
          GoRoute(path: MatchingRoutes.packages, builder: (_, _) => const MatchPackagesScreen()),
          GoRoute(
            path: '${MatchingRoutes.packages}/:slug',
            builder: (_, state) => switch (MatchPackage.bySlug(state.pathParameters['slug']!)) {
              final package? => MatchPackageScreen(
                  package: package,
                  orderId: state.uri.queryParameters['order'],
                  // Billing sells the packages; matching only shows them.
                  purchase: (context, slug, orderId) => Consumer(
                    builder: (context, ref, _) => PersonalPlanPurchase(
                      slug: slug,
                      orderId: orderId,
                      onPaid: () => ref.invalidate(matchStatusProvider),
                    ),
                  ),
                ),
              null => const MatchPackagesScreen(),
            },
          ),
          GoRoute(
            path: '/premium/:slug/checkout',
            builder: (_, state) => PersonalCheckoutScreen(
              slug: state.pathParameters['slug']!,
              period: PlanPeriod.parse(state.uri.queryParameters['period']),
            ),
          ),
          GoRoute(path: GroupRoutes.create, builder: (_, _) => const CreateGroupScreen(nextRoute: BillingRoutes.newGroupPlan)),
          GoRoute(
            path: '/g/:handle',
            builder: (_, state) => GroupScreen(
              handle: state.pathParameters['handle']!,
              onOpenProfile: _openProfile,
              sections: const [groupChatSection, groupModerationSection, groupLiveSection, groupPlanSection, groupSupportSection],
              contentSections: const [groupWelcomeSection, groupLeagueSection, groupEventsSection, groupGoalsSection, groupPollsSection, groupPostsSection],
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
                  isNewGroup: state.uri.queryParameters['new'] == '1',
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
          GoRoute(path: IdentityRoutes.twoFactor, builder: (_, _) => const TwoFactorSettingsScreen()),
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
                    ChatScreen(
                      conversationId: state.pathParameters['id']!,
                      onOpenProfile: _openProfile,
                      onOpenGroup: _openGroup,
                    ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/live/:id', builder: (_, state) => LiveRoomScreen(broadcastId: state.pathParameters['id']!)),
      GoRoute(path: FeedRoutes.newStory, builder: (_, _) => const NewStoryScreen()),
      GoRoute(path: '/stories/:userId', builder: (_, state) => StoryViewerScreen(userId: state.pathParameters['userId']!)),
      GoRoute(path: '/highlights/:id', builder: (_, state) => HighlightViewerScreen(highlightId: state.pathParameters['id']!)),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

Widget _groupsSection(BuildContext context, Profile profile, bool isOwn) =>
    UserGroupsSection(userId: profile.id, isOwn: isOwn, groupsPublic: profile.groupsPublic);

void _openProfile(BuildContext context, String username) => context.push(ProfileRoutes.user(username));

/// A small table's chat (events does not know the messaging feature).
void openTonightChat(BuildContext context, String conversationId) => context.push(MessagingRoutes.chat(conversationId));

void _openGroup(BuildContext context, String handle) => context.push(GroupRoutes.group(handle));

void _openChat(BuildContext context, String conversationId) => context.push(MessagingRoutes.chat(conversationId));

/// "Eşleşme" on your own profile (docs/ARCHITECTURE.md §3g).
const _matchingButton = _MatchingButton();

class _MatchingButton extends StatelessWidget {
  const _MatchingButton();

  @override
  Widget build(BuildContext context) => IconButton(
      tooltip: 'Eşleşme', icon: const Icon(Icons.favorite_border_rounded), onPressed: () => context.push(MatchingRoutes.home));
}

/// "Gruplar Ligi" from the groups page.
const _leagueButton = _LeagueButton();

class _LeagueButton extends StatelessWidget {
  const _LeagueButton();

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Gruplar Ligi',
        icon: const Icon(Icons.emoji_events_outlined),
        onPressed: () => context.push(EventRoutes.league()),
      );
}

/// "Harita" from the groups page.
const _mapButton = _MapButton();

class _MapButton extends StatelessWidget {
  const _MapButton();

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: 'Haritada keşfet', icon: const Icon(Icons.map_outlined), onPressed: () => context.push(EventRoutes.map));
}

/// "Yılın özeti" and "Keşif haritam" on your own profile (docs/ARCHITECTURE.md §3d), behind one button.
const _yearButton = _YearButton();

class _YearButton extends StatelessWidget {
  const _YearButton();

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Yılın özeti, keşif haritam ve tanıştıklarım',
        icon: const Icon(Icons.auto_awesome_outlined),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Yılın özeti'),
                  subtitle: const Text('Bu yılki buluşmaların, paylaşılabilir kart'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    context.push(EventRoutes.year());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.travel_explore),
                  title: const Text('Keşif haritam'),
                  subtitle: const Text('Katıldığın organizasyonların illeri'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    context.push(EventRoutes.exploration);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.handshake_outlined),
                  title: const Text('Tanıştıklarım'),
                  subtitle: const Text('Organizasyonlarda el sıkıştığın kişiler'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    context.push(EventRoutes.met);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

/// "Ekip arkadaşı bul" on your own profile.
const _teammatesButton = _TeammatesButton();

class _TeammatesButton extends StatelessWidget {
  const _TeammatesButton();

  @override
  Widget build(BuildContext context) => IconButton(
      tooltip: 'Ekip arkadaşı bul', icon: const Icon(Icons.diversity_3_outlined), onPressed: () => context.push(ProfileRoutes.teammates));
}

/// Notifications with the unread count, on your own profile too (not only on "Bugün").
const _notificationsButton = _NotificationsButton();

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) => IconButton(
      tooltip: 'Bildirimler', icon: const NotificationsIcon(), onPressed: () => context.go(NotificationRoutes.list));
}

/// "Kaydedilenler" on your own profile.
const _savedButton = _SavedButton();

class _SavedButton extends StatelessWidget {
  const _SavedButton();

  @override
  Widget build(BuildContext context) => IconButton(
      tooltip: 'Kaydedilenler', icon: const Icon(Icons.bookmark_border_rounded), onPressed: () => context.push(FeedRoutes.saved));
}

class _GateErrorScreen extends ConsumerWidget {
  const _GateErrorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GwErrorState(
        message: 'Bilgilerin yüklenemedi. Bağlantını kontrol edip tekrar dene.',
        onRetry: () => refreshGate(ref),
      ),
    );
  }
}
