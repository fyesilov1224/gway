import 'package:flutter/material.dart';
import 'package:groups/groups.dart';
import 'package:live/live.dart';

/// The live card on the group page: members join and get reminders, live.start holders start broadcasts.
Widget groupLiveSection(BuildContext context, Group group, MyMembership me) {
  if (!me.isMember || group.isSuspended) return const SizedBox.shrink();
  return GroupLiveSection(groupId: group.id, canStart: me.can(GroupPermission.startLive));
}
