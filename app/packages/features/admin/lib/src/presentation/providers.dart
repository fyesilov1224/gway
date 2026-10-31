import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/admin_analytics.dart';
import '../domain/admin_billing.dart';
import '../domain/admin_content.dart';
import '../domain/admin_events.dart';
import '../domain/admin_group.dart';
import '../domain/admin_legal.dart';
import '../domain/admin_live.dart';
import '../domain/admin_matching.dart';
import '../domain/admin_message_logs.dart';
import '../domain/admin_moderation.dart';
import '../domain/admin_notifications.dart';
import '../domain/admin_security.dart';
import '../domain/admin_support.dart';
import '../domain/admin_user.dart';

final staffRepositoryProvider = Provider<StaffRepository>(
  (ref) => SupabaseStaffRepository(ref.watch(supabaseClientProvider)),
);

final adminUsersRepositoryProvider = Provider<AdminUsersRepository>(
  (ref) => ApiAdminUsersRepository(ref.watch(apiClientProvider)),
);

/// Platform role of the signed-in user; null when signed out or not staff.
final myStaffRoleProvider = FutureProvider<StaffRole?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  return (await ref.watch(staffRepositoryProvider).myRole()).getOrThrow();
});

typedef UserSearch = ({String query, AdminAccountStatus? status, int page});

final userSearchProvider = FutureProvider.autoDispose.family<UserPage, UserSearch>(
  (ref, search) async => (await ref
          .watch(adminUsersRepositoryProvider)
          .search(query: search.query, status: search.status, page: search.page))
      .getOrThrow(),
);

final userStatsProvider = FutureProvider.autoDispose<AdminUserStats>(
  (ref) async => (await ref.watch(adminUsersRepositoryProvider).stats()).getOrThrow(),
);

/// E-mail of the signed-in staff member, for the panel's account menu.
final currentEmailProvider = Provider<String?>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser?.email;
});

final userDetailProvider = FutureProvider.autoDispose.family<AdminUserDetail, String>(
  (ref, id) async => (await ref.watch(adminUsersRepositoryProvider).get(id)).getOrThrow(),
);

/// Public URL of an avatar stored in the `avatars` bucket.
final avatarUrlProvider = Provider.family<String?, String?>(
  (ref, path) => path == null ? null : ref.watch(supabaseClientProvider).storage.from('avatars').getPublicUrl(path),
);

final adminGroupsRepositoryProvider = Provider<AdminGroupsRepository>(
  (ref) => ApiAdminGroupsRepository(ref.watch(apiClientProvider)),
);

typedef GroupSearch = ({String query, AdminGroupStatus? status, int page});

final groupSearchProvider = FutureProvider.autoDispose.family<GroupPage, GroupSearch>(
  (ref, search) async => (await ref
          .watch(adminGroupsRepositoryProvider)
          .search(query: search.query, status: search.status, page: search.page))
      .getOrThrow(),
);

final groupStatsProvider = FutureProvider.autoDispose<AdminGroupStats>(
  (ref) async => (await ref.watch(adminGroupsRepositoryProvider).stats()).getOrThrow(),
);

final groupDetailProvider = FutureProvider.autoDispose.family<AdminGroupDetail, String>(
  (ref, id) async => (await ref.watch(adminGroupsRepositoryProvider).get(id)).getOrThrow(),
);

/// Public URL of a group logo stored in the `group-images` bucket.
final groupLogoUrlProvider = Provider.family<String?, String?>(
  (ref, path) => path == null ? null : ref.watch(supabaseClientProvider).storage.from('group-images').getPublicUrl(path),
);

final adminContentRepositoryProvider = Provider<AdminContentRepository>(
  (ref) => ApiAdminContentRepository(ref.watch(apiClientProvider)),
);

typedef ContentSearch = ({String query, AdminContentFilter? filter, int page});

final contentSearchProvider = FutureProvider.autoDispose.family<PostPage, ContentSearch>(
  (ref, search) async => (await ref
          .watch(adminContentRepositoryProvider)
          .search(query: search.query, filter: search.filter, page: search.page))
      .getOrThrow(),
);

final postDetailProvider = FutureProvider.autoDispose.family<AdminPostDetail, String>(
  (ref, id) async => (await ref.watch(adminContentRepositoryProvider).get(id)).getOrThrow(),
);

/// Public URL of post media in the `media` bucket.
final mediaUrlProvider = Provider.family<String, String>(
  (ref, path) => ref.watch(supabaseClientProvider).storage.from('media').getPublicUrl(path),
);

final adminEventsRepositoryProvider = Provider<AdminEventsRepository>(
  (ref) => ApiAdminEventsRepository(ref.watch(apiClientProvider)),
);

typedef AdminEventSearch = ({String query, AdminEventStatus? status, int page});

final adminEventSearchProvider = FutureProvider.autoDispose.family<AdminEventPage, AdminEventSearch>(
  (ref, search) async => (await ref
          .watch(adminEventsRepositoryProvider)
          .search(query: search.query, status: search.status, page: search.page))
      .getOrThrow(),
);

final adminModerationRepositoryProvider = Provider<AdminModerationRepository>(
  (ref) => ApiAdminModerationRepository(ref.watch(apiClientProvider)),
);

typedef AdminReportSearch = ({AdminReportScope? scope, AdminReportStatus? status, int page});

final adminReportSearchProvider = FutureProvider.autoDispose.family<AdminReportPage, AdminReportSearch>(
  (ref, search) async => (await ref
          .watch(adminModerationRepositoryProvider)
          .reports(scope: search.scope, status: search.status, page: search.page))
      .getOrThrow(),
);

typedef AdminAppealSearch = ({AdminAppealStatus? status, int page});

final adminAppealSearchProvider = FutureProvider.autoDispose.family<AdminAppealPage, AdminAppealSearch>(
  (ref, search) async =>
      (await ref.watch(adminModerationRepositoryProvider).appeals(status: search.status, page: search.page)).getOrThrow(),
);

typedef AdminReferralSearch = ({AdminReferralStatus? status, int page});

final adminReferralSearchProvider = FutureProvider.autoDispose.family<AdminReferralPage, AdminReferralSearch>(
  (ref, search) async =>
      (await ref.watch(adminModerationRepositoryProvider).referrals(status: search.status, page: search.page)).getOrThrow(),
);

typedef AdminGoalSearch = ({AdminGoalStatus? status, int page});

final adminLeaguesProvider = FutureProvider.autoDispose.family<AdminLeagueMonth, DateTime>(
  (ref, month) async => (await ref.watch(adminEventsRepositoryProvider).leagues(month)).getOrThrow(),
);

final adminLeagueTableProvider = FutureProvider.autoDispose.family<AdminLeagueTable, AdminLeagueKey>(
  (ref, key) async => (await ref.watch(adminEventsRepositoryProvider).leagueTable(key)).getOrThrow(),
);

final adminGoalSearchProvider = FutureProvider.autoDispose.family<AdminGoalPage, AdminGoalSearch>(
  (ref, search) async =>
      (await ref.watch(adminEventsRepositoryProvider).goals(status: search.status, page: search.page)).getOrThrow(),
);

final adminLiveRepositoryProvider = Provider<AdminLiveRepository>(
  (ref) => ApiAdminLiveRepository(ref.watch(apiClientProvider)),
);

typedef BroadcastSearch = ({AdminLiveStatus status, int page});

final broadcastSearchProvider = FutureProvider.autoDispose.family<BroadcastPage, BroadcastSearch>(
  (ref, search) async => (await ref.watch(adminLiveRepositoryProvider).search(status: search.status, page: search.page)).getOrThrow(),
);

final adminMatchingRepositoryProvider = Provider<AdminMatchingRepository>(
  (ref) => ApiAdminMatchingRepository(ref.watch(apiClientProvider), ref.watch(supabaseClientProvider)),
);

final matchingStatsProvider = FutureProvider.autoDispose<AdminMatchingStats>(
  (ref) async => (await ref.watch(adminMatchingRepositoryProvider).stats()).getOrThrow(),
);

final matchingPackagesProvider = FutureProvider.autoDispose<List<AdminPremium>>(
  (ref) async => (await ref.watch(adminMatchingRepositoryProvider).packages()).getOrThrow(),
);

/// One person's package slices (user page).
final userPackagesProvider = FutureProvider.autoDispose.family<List<AdminPersonalSubscription>, String>(
  (ref, userId) async => (await ref.watch(adminMatchingRepositoryProvider).userPackages(userId)).getOrThrow(),
);

final adminLegalRepositoryProvider = Provider<AdminLegalRepository>(
  (ref) => ApiAdminLegalRepository(ref.watch(apiClientProvider)),
);

/// Legal text kinds and their versions.
final legalKindsProvider = FutureProvider.autoDispose<List<LegalKind>>(
  (ref) async => (await ref.watch(adminLegalRepositoryProvider).list()).getOrThrow(),
);

/// One version's full body.
final legalDocumentProvider = FutureProvider.autoDispose.family<LegalDocument, ({String kind, int version})>(
  (ref, key) async => (await ref.watch(adminLegalRepositoryProvider).get(key.kind, key.version)).getOrThrow(),
);

final adminSecurityRepositoryProvider = Provider<AdminSecurityRepository>(
  (ref) => ApiAdminSecurityRepository(ref.watch(apiClientProvider)),
);

/// The enforcement switch (admin only).
final securitySettingsProvider = FutureProvider.autoDispose<AdminSecuritySettings>(
  (ref) async => (await ref.watch(adminSecurityRepositoryProvider).settings()).getOrThrow(),
);

final securityReviewsProvider = FutureProvider.autoDispose.family<List<AdminSecurityReview>, AdminReviewStatus?>(
  (ref, status) async => (await ref.watch(adminSecurityRepositoryProvider).reviews(status)).getOrThrow(),
);

final userSecurityProvider = FutureProvider.autoDispose.family<AdminUserSecurity, String>(
  (ref, userId) async => (await ref.watch(adminSecurityRepositoryProvider).user(userId)).getOrThrow(),
);

final adminAnalyticsRepositoryProvider = Provider<AdminAnalyticsRepository>(
  (ref) => ApiAdminAnalyticsRepository(ref.watch(apiClientProvider)),
);

/// The overview for a range of 7, 30, 90 or 365 days.
final overviewProvider = FutureProvider.autoDispose.family<AdminOverview, int>(
  (ref, days) async => (await ref.watch(adminAnalyticsRepositoryProvider).overview(days)).getOrThrow(),
);

final adminNotificationsRepositoryProvider = Provider<AdminNotificationsRepository>(
  (ref) => ApiAdminNotificationsRepository(ref.watch(apiClientProvider)),
);

final pushStatsProvider = FutureProvider.autoDispose<AdminPushStats>(
  (ref) async => (await ref.watch(adminNotificationsRepositoryProvider).stats()).getOrThrow(),
);

final adminBillingRepositoryProvider = Provider<AdminBillingRepository>(
  (ref) => ApiAdminBillingRepository(ref.watch(apiClientProvider)),
);

final billingStatsProvider = FutureProvider.autoDispose<AdminBillingStats>(
  (ref) async => (await ref.watch(adminBillingRepositoryProvider).stats()).getOrThrow(),
);

final paymentProvidersProvider = FutureProvider.autoDispose<List<PaymentProviderStatus>>(
  (ref) async => (await ref.watch(adminBillingRepositoryProvider).providers()).getOrThrow(),
);

typedef OrderSearch = ({String query, AdminOrderStatus? status, int page});

final orderSearchProvider = FutureProvider.autoDispose.family<OrderPage, OrderSearch>(
  (ref, search) async => (await ref
          .watch(adminBillingRepositoryProvider)
          .orders(query: search.query, status: search.status, page: search.page))
      .getOrThrow(),
);

typedef SubscriptionSearch = ({String query, int page});

final subscriptionSearchProvider = FutureProvider.autoDispose.family<SubscriptionPage, SubscriptionSearch>(
  (ref, search) async =>
      (await ref.watch(adminBillingRepositoryProvider).subscriptions(query: search.query, page: search.page)).getOrThrow(),
);

final adminPlansProvider = FutureProvider.autoDispose<List<AdminPlan>>(
  (ref) async => (await ref.watch(adminBillingRepositoryProvider).plans()).getOrThrow(),
);

final adminSupportRepositoryProvider = Provider<AdminSupportRepository>(
  (ref) => ApiAdminSupportRepository(ref.watch(apiClientProvider), ref.watch(supabaseClientProvider)),
);

final supportStatsProvider = FutureProvider.autoDispose<AdminSupportStats>(
  (ref) async => (await ref.watch(adminSupportRepositoryProvider).stats()).getOrThrow(),
);

typedef TicketSearch = ({String query, AdminSupportKind? kind, AdminSupportStatus? status, int page});

final ticketSearchProvider = FutureProvider.autoDispose.family<TicketPage, TicketSearch>(
  (ref, search) async => (await ref
          .watch(adminSupportRepositoryProvider)
          .search(query: search.query, kind: search.kind, status: search.status, page: search.page))
      .getOrThrow(),
);

final ticketDetailProvider = FutureProvider.autoDispose.family<AdminTicketDetail, String>(
  (ref, id) async => (await ref.watch(adminSupportRepositoryProvider).get(id)).getOrThrow(),
);

final supportAttachmentUrlProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) async => (await ref.watch(adminSupportRepositoryProvider).attachmentUrl(path)).getOrThrow(),
);

final adminMessageLogsRepositoryProvider = Provider<AdminMessageLogsRepository>(
  (ref) => ApiAdminMessageLogsRepository(ref.watch(apiClientProvider)),
);

/// The last message log search.
typedef MessageLogSearch = ({String username, String? withUsername, LogConversationKind? kind, int page});

/// The admin's message log session: the reason (sent with every request; the API audits it) and the last search.
class MessageLogSession {
  const MessageLogSession({this.reason, this.search});

  final String? reason;
  final MessageLogSearch? search;
}

final messageLogSessionProvider = NotifierProvider<MessageLogSessionNotifier, MessageLogSession>(MessageLogSessionNotifier.new);

class MessageLogSessionNotifier extends Notifier<MessageLogSession> {
  @override
  MessageLogSession build() => const MessageLogSession();

  void setReason(String reason) => state = MessageLogSession(reason: reason, search: state.search);

  void search(String reason, MessageLogSearch search) => state = MessageLogSession(reason: reason, search: search);

  void page(int page) {
    final search = state.search;
    if (search == null) return;
    state = MessageLogSession(
      reason: state.reason,
      search: (username: search.username, withUsername: search.withUsername, kind: search.kind, page: page),
    );
  }
}

/// The conversations of the last search; null before the first search.
final messageLogResultsProvider = FutureProvider.autoDispose<LogConversationPage?>((ref) async {
  final session = ref.watch(messageLogSessionProvider);
  final (search, reason) = (session.search, session.reason);
  if (search == null || reason == null) return null;
  return (await ref.watch(adminMessageLogsRepositoryProvider).search(
            username: search.username,
            withUsername: search.withUsername,
            kind: search.kind,
            page: search.page,
            reason: reason,
          ))
      .getOrThrow();
});
