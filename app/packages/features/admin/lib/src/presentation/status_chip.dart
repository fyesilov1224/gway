import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../domain/admin_user.dart';

GxBadgeTone statusTone(AdminAccountStatus status) => switch (status) {
      AdminAccountStatus.active => GxBadgeTone.primary,
      AdminAccountStatus.suspended => GxBadgeTone.danger,
      AdminAccountStatus.pendingDeletion => GxBadgeTone.neutral,
    };

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.banned = false});

  final AdminAccountStatus status;

  /// Suspended without an end date (docs/ARCHITECTURE.md §3a).
  final bool banned;

  @override
  Widget build(BuildContext context) => GxBadge(banned ? 'Banlı' : status.label, tone: statusTone(status), dot: true);
}

class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final StaffRole role;

  @override
  Widget build(BuildContext context) => GxBadge(role.label, tone: GxBadgeTone.info);
}
