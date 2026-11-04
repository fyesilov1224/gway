import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:support/support.dart';

import 'l10n.dart';

/// For group managers (owner, Yönetici): write to the platform team about this group.
Widget groupSupportSection(BuildContext context, Group group, MyMembership me) {
  if (!me.can(GroupPermission.edit)) return const SizedBox.shrink();
  return Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: () => context.push(SupportRoutes.create(groupId: group.id)),
      icon: const Icon(Icons.support_agent_outlined, size: GwSpacing.md + GwSpacing.xxs),
      label: Text(socialAppL10n.writeSupportAboutGroup),
    ),
  );
}
