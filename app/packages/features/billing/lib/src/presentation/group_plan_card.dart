import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'widgets.dart';

/// Plan summary on the group page. The owner sees the plan, usage and a way
/// to manage it; people who approve members only see a full-group warning.
class GroupPlanCard extends ConsumerWidget {
  const GroupPlanCard({super.key, required this.groupId, required this.canManage, required this.onManage});

  final String groupId;
  final bool canManage;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing while loading or on error: the card is secondary to the group page.
    final plan = ref.watch(groupPlanProvider(groupId)).value;
    if (plan == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final full = plan.isOverLimit
        ? 'Üye sayısı paketin limitini aşıyor. Limitin altına inilene kadar yeni üye alınamaz.'
        : plan.isFull
            ? 'Grup, paketinin üye limitine ulaştı. Yeni üye alınamaz.'
            : null;

    if (!canManage) {
      return full == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: GwSpacing.md),
              child: PlanNotice(icon: Icons.group_off_outlined, text: full, danger: true),
            );
    }

    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(GwSpacing.md),
        decoration: const BoxDecoration(
          color: GwColors.surface,
          borderRadius: GwRadius.lgAll,
          border: Border.fromBorderSide(GwBorders.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(planIcon, color: GwColors.primary),
                const SizedBox(width: GwSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planStatusLine(plan), style: textTheme.labelLarge),
                      Text(
                        '${formatCount(plan.memberCount)} / ${formatCount(plan.plan.maxMembers)} üye',
                        style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Mobile only shows the status; buying is on the web (docs/ARCHITECTURE.md §7).
                if (!ref.watch(purchasesOnThisPlatformProvider)) TextButton(onPressed: onManage, child: const Text('Paket')),
              ],
            ),
            if (ref.watch(purchasesOnThisPlatformProvider)) ...[
              const SizedBox(height: GwSpacing.sm),
              GwButton(
                label: plan.plan.isFree ? 'Paket al' : 'Paketi yükselt',
                icon: planIcon,
                onPressed: onManage,
              ),
            ],
            if (full != null) ...[
              const SizedBox(height: GwSpacing.sm),
              PlanNotice(icon: Icons.group_off_outlined, text: full, danger: true),
            ] else if (plan.renewalDue(DateTime.now())) ...[
              const SizedBox(height: GwSpacing.sm),
              PlanNotice(
                icon: Icons.schedule,
                text: 'Paketin ${formatDateTr(plan.paidUntil!)} tarihinde bitiyor. Bitince grup Ücretsiz pakete döner.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
