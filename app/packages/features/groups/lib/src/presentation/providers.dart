import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/groups_repository_impl.dart';
import '../domain/group.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>(
  (ref) => GroupsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

typedef GroupSearch = ({String query, String? category, int limit});

final discoverGroupsProvider = FutureProvider.autoDispose.family<List<Group>, GroupSearch>(
  (ref, search) async => (await ref
          .watch(groupsRepositoryProvider)
          .discover(query: search.query, categorySlug: search.category, limit: search.limit))
      .getOrThrow(),
);

/// Groups a user belongs to (profile section, "Gruplarım").
final userGroupsProvider = FutureProvider.autoDispose.family<List<Group>, String>(
  (ref, userId) async => (await ref.watch(groupsRepositoryProvider).groupsOf(userId)).getOrThrow(),
);

final groupByHandleProvider = FutureProvider.autoDispose.family<Group, String>(
  (ref, handle) async => (await ref.watch(groupsRepositoryProvider).byHandle(handle)).getOrThrow(),
);

final myMembershipProvider = FutureProvider.autoDispose.family<MyMembership, String>((ref, groupId) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(groupsRepositoryProvider).myMembership(groupId)).getOrThrow();
});

typedef GroupKey = ({String id, String ownerId});

GroupKey groupKeyOf(Group group) => (id: group.id, ownerId: group.ownerId);

final groupMembersProvider = FutureProvider.autoDispose.family<List<GroupPerson>, GroupKey>(
  (ref, key) async => (await ref.watch(groupsRepositoryProvider).members(key.id, ownerId: key.ownerId)).getOrThrow(),
);

final joinRequestsProvider = FutureProvider.autoDispose.family<List<GroupPerson>, String>(
  (ref, groupId) async => (await ref.watch(groupsRepositoryProvider).joinRequests(groupId)).getOrThrow(),
);

final groupInvitationsProvider = FutureProvider.autoDispose.family<List<GroupPerson>, String>(
  (ref, groupId) async => (await ref.watch(groupsRepositoryProvider).invitations(groupId)).getOrThrow(),
);

final inviteLinksProvider = FutureProvider.autoDispose.family<List<InviteLink>, String>(
  (ref, groupId) async => (await ref.watch(groupsRepositoryProvider).inviteLinks(groupId)).getOrThrow(),
);

final invitePreviewProvider = FutureProvider.autoDispose.family<InvitePreview?, String>(
  (ref, code) async => (await ref.watch(groupsRepositoryProvider).invitePreview(code)).getOrThrow(),
);

final myInvitationsProvider = FutureProvider.autoDispose<List<GroupInvitation>>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(groupsRepositoryProvider).myInvitations()).getOrThrow();
});

/// Reloads everything that shows [group] after a change to it or to the user's membership.
void refreshGroup(WidgetRef ref, Group group) {
  ref
    ..invalidate(groupByHandleProvider(group.handle))
    ..invalidate(myMembershipProvider(group.id))
    ..invalidate(groupMembersProvider)
    ..invalidate(joinRequestsProvider(group.id))
    ..invalidate(groupInvitationsProvider(group.id))
    ..invalidate(userGroupsProvider)
    ..invalidate(myInvitationsProvider)
    ..invalidate(discoverGroupsProvider);
}
