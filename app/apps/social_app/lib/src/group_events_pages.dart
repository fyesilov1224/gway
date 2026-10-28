import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:profile/profile.dart';

/// Event pages open groups and profiles through the app (features stay independent).
final eventLinks = EventLinks(
  openGroup: (context, handle) => context.push(GroupRoutes.group(handle)),
  openProfile: (context, username) => context.push(ProfileRoutes.user(username)),
  shareMemory: (context, eventId) => context.push(FeedRoutes.createMemory(eventId)),
  memories: (context, eventId) => PostsSection(
    source: EventPosts(eventId),
    emptyMessage: 'Henüz anı paylaşılmadı. Katılanlar fotoğraflarını buraya ekleyebilir.',
  ),
);

/// "12 katılım · 2 düzenleme" under a member's name (docs/ARCHITECTURE.md §3d, Katkı ve rozetler).
String? memberContributions(WidgetRef ref, Group group, GroupPerson person) =>
    groupContributionLine(ref.watch(groupContributionsProvider(group.id)).value?[person.userId]);

/// Contributions and badges on a profile.
Widget profileContributionsSection(BuildContext context, Profile profile, bool isOwn) =>
    ContributionsSection(userId: profile.id, isOwn: isOwn);

/// How many greeters the group has, and "Karşılayıcı ol" for members who may (docs/ARCHITECTURE.md §3d, Karşılama).
Widget groupWelcomeSection(BuildContext context, Group group, MyMembership me) =>
    group.isSuspended ? const SizedBox.shrink() : GroupWelcomeSection(groupId: group.id, isMember: me.isMember);

/// The group's place in its league this month (docs/ARCHITECTURE.md §3d, Gruplar Ligi).
Widget groupLeagueSection(BuildContext context, Group group, MyMembership me) =>
    group.isSuspended ? const SizedBox.shrink() : GroupLeagueSection(groupId: group.id);

/// Upcoming events on the group page; events.manage holders (owner, Yönetici) create them.
Widget groupEventsSection(BuildContext context, Group group, MyMembership me) =>
    GroupEventsSection(groupId: group.id, canManage: me.can(GroupPermission.manageEvents) && !group.isSuspended);

/// The group's goals; events.manage holders (owner, Yönetici) open them.
Widget groupGoalsSection(BuildContext context, Group group, MyMembership me) =>
    GroupGoalsSection(groupId: group.id, canManage: me.can(GroupPermission.manageEvents) && !group.isSuspended);

/// The group's polls; members only.
Widget groupPollsSection(BuildContext context, Group group, MyMembership me) {
  if (!me.isMember) return const SizedBox.shrink();
  return PollsSection(scope: (groupId: group.id, eventId: null), canManage: me.can(GroupPermission.manageEvents) && !group.isSuspended);
}
