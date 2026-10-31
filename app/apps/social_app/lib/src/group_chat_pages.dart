import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:groups/groups.dart';
import 'package:messaging/messaging.dart';
import 'package:profile/profile.dart';

/// "Grup sohbeti" on the group page, for members of an active group.
Widget groupChatSection(BuildContext context, Group group, MyMembership me) {
  if (!me.isMember || group.isSuspended) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: GwSpacing.md),
    child: GroupChatButton(groupId: group.id),
  );
}

/// "Mesaj" next to "Takip et" on someone else's profile.
Widget profileMessageAction(BuildContext context, Profile profile, bool isOwn) => MessageUserButton(userId: profile.id);
