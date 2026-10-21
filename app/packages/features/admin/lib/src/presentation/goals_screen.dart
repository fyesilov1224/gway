import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_events.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Goals across the platform (docs/ARCHITECTURE.md §3d, Hedefler ve görevler): status filter, cancel.
class AdminGoalsScreen extends ConsumerStatefulWidget {
  const AdminGoalsScreen({super.key});

  @override
  ConsumerState<AdminGoalsScreen> createState() => _AdminGoalsScreenState();
}

class _AdminGoalsScreenState extends ConsumerState<AdminGoalsScreen> {
  AdminGoalStatus? _status = AdminGoalStatus.running;
  int _page = 1;

  void _filter(AdminGoalStatus? status) => setState(() {
        _status = status;
        _page = 1;
      });

  Future<void> _cancel(AdminGoal g) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedefi iptal et'),
        content: Text('"${g.title}" iptal edilir; kazanılmış rozetler kalır. İşlem kayda geçer.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GxButton(label: 'İptal et', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(adminEventsRepositoryProvider).cancelGoal(g.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => 'Hedef iptal edildi.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(adminGoalSearchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final key = (status: _status, page: _page);
    final result = ref.watch(adminGoalSearchProvider(key));
    final canCancel = ref.watch(myStaffRoleProvider).value?.canSuspend ?? false;
    final textTheme = Theme.of(context).textTheme;
    return AdminPage(
      title: 'Hedefler',
      subtitle: 'Grupların hedefleri ve görevleri. Kurallara aykırı bir hedefi iptal edebilirsin.',
      actions: [
        GxButton(label: 'Yenile', icon: Icons.refresh, variant: GxButtonVariant.secondary, onPressed: () => ref.invalidate(adminGoalSearchProvider)),
      ],
      children: [
        GxPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GxSpacing.md),
                child: Wrap(
                  spacing: GxSpacing.xs,
                  runSpacing: GxSpacing.xs,
                  children: [
                    ChoiceChip(label: const Text('Tümü'), selected: _status == null, onSelected: (_) => _filter(null)),
                    for (final s in AdminGoalStatus.values)
                      ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (_) => _filter(s)),
                  ],
                ),
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
                    child: GxEmptyState(
                      icon: Icons.flag_circle_outlined,
                      message: 'Bu filtrede hedef yok.',
                      actionLabel: 'Yenile',
                      onAction: () => ref.invalidate(adminGoalSearchProvider(key)),
                    ),
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final g in value.items) ...[
                        InkWell(
                          onTap: () => context.go(AdminRoutes.group(g.groupId)),
                          hoverColor: GxColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(g.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                                      Text(
                                        '${g.groupName} (@${g.groupHandle}) · ${g.summary} · ${formatDateTr(g.startsAt)} – ${formatDateTr(g.endsAt)}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (g.canceledAt != null) const GxBadge('İptal edildi', tone: GxBadgeTone.danger),
                                if (canCancel && g.isRunning) ...[
                                  const SizedBox(width: GxSpacing.sm),
                                  GxButton(label: 'İptal et', variant: GxButtonVariant.secondary, onPressed: () => _cancel(g)),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                      PageFooter(
                        from: value.range.$1,
                        to: value.range.$2,
                        total: value.total,
                        noun: 'hedef',
                        page: value.page,
                        pageCount: value.pageCount,
                        onPage: (p) => setState(() => _page = p),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
                    child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminGoalSearchProvider(key))),
                  ),
                _ => const Padding(padding: EdgeInsets.all(GxSpacing.lg), child: GxSkeleton(height: GxSpacing.xl)),
              },
            ],
          ),
        ),
      ],
    );
  }
}
