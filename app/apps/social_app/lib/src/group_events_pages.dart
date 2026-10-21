import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:profile/profile.dart';

/// Event pages open groups and profiles through the app (features stay independent).
final eventLinks = EventLinks(
  openGroup: (context, handle) => context.push(GroupRoutes.group(handle)),
  openProfile: (context, username) => context.push(ProfileRoutes.user(username)),
);

/// Upcoming events on the group page; events.manage holders (owner, Yönetici) create them.
Widget groupEventsSection(BuildContext context, Group group, MyMembership me) =>
    GroupEventsSection(groupId: group.id, canManage: me.can(GroupPermission.manageEvents) && !group.isSuspended);

/// The group's polls; members only.
Widget groupPollsSection(BuildContext context, Group group, MyMembership me) {
  if (!me.isMember) return const SizedBox.shrink();
  return PollsSection(scope: (groupId: group.id, eventId: null), canManage: me.can(GroupPermission.manageEvents) && !group.isSuspended);
}
