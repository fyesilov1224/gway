import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/admin_billing.dart';
import '../domain/admin_content.dart';
import '../domain/admin_events.dart';
import '../domain/admin_group.dart';
import '../domain/admin_live.dart';
import '../domain/admin_moderation.dart';
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

typedef AdminGoalSearch = ({AdminGoalStatus? status, int page});

final adminGoalSearchProvider = FutureProvider.autoDispose.family<AdminGoalPage, AdminGoalSearch>(
  (ref, search) async =>
      (await ref.watch(adminEventsRepositoryProvider).goals(status: search.status, page: search.page)).getOrThrow(),
);

final adminLiveRepositoryProvider = Provider<AdminLiveRepository>(
  (ref) => ApiAdminLiveRepository(ref.watch(apiClientProvider)),
);

typedef BroadcastSearch = ({bool ended, int page});

final broadcastSearchProvider = FutureProvider.autoDispose.family<BroadcastPage, BroadcastSearch>(
  (ref, search) async => (await ref.watch(adminLiveRepositoryProvider).search(ended: search.ended, page: search.page)).getOrThrow(),
);

final adminBillingRepositoryProvider = Provider<AdminBillingRepository>(
  (ref) => ApiAdminBillingRepository(ref.watch(apiClientProvider)),
);

final billingStatsProvider = FutureProvider.autoDispose<AdminBillingStats>(
  (ref) async => (await ref.watch(adminBillingRepositoryProvider).stats()).getOrThrow(),
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
