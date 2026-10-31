import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// The way into a group's moderation desk, with the open work; nothing for those who cannot review.
class GroupModerationEntry extends ConsumerWidget {
  const GroupModerationEntry({super.key, required this.groupId, required this.onOpen});

  final String groupId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desk = ref.watch(groupModerationProvider(groupId)).value;
    if (desk == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final work = [
      if (desk.reports.isNotEmpty) '${desk.reports.length} şikayet',
      if (desk.awaitingMyVote > 0) '${desk.awaitingMyVote} dosya oyunu bekliyor',
      if (desk.pendingAppeals.isNotEmpty) '${desk.pendingAppeals.length} itiraz',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
      child: Material(
        color: GwColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll, side: BorderSide(color: GwColors.border)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onOpen,
          leading: const Icon(Icons.shield_outlined, color: GwColors.primary),
          title: Text('Moderasyon', style: textTheme.labelLarge),
          subtitle: Text(work.isEmpty ? 'Bekleyen iş yok' : work.join(' · ')),
          trailing: desk.pending > 0 ? GwBadge('${desk.pending}', tone: GwBadgeTone.danger) : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
