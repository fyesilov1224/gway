import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_live.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

String _minutes(Duration d) => '${formatCount(d.inMinutes)} dk';

/// Live rooms across the platform with an emergency close, scheduled and past broadcasts (docs/ARCHITECTURE.md §8).
class AdminLiveScreen extends ConsumerStatefulWidget {
  const AdminLiveScreen({super.key});

  @override
  ConsumerState<AdminLiveScreen> createState() => _AdminLiveScreenState();
}

class _AdminLiveScreenState extends ConsumerState<AdminLiveScreen> {
  AdminLiveStatus _tab = AdminLiveStatus.live;
  int _page = 1;

  Future<void> _end(AdminBroadcast b) async {
    final request = await showSuspendDialog(
      context,
      title: 'Yayını kapat',
      description: '"${b.title}" herkes için hemen kapanır. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'Kapat',
    );
    if (request == null || !mounted) return;
    final result = await ref.read(adminLiveRepositoryProvider).end(b.id, reason: request.reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => 'Yayın kapatıldı.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(broadcastSearchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final key = (status: _tab, page: _page);
    final result = ref.watch(broadcastSearchProvider(key));
    final canEnd = ref.watch(myStaffRoleProvider).value?.canSuspend ?? false;

    return AdminPage(
      title: 'Canlı yayınlar',
      subtitle: 'Grupların sesli yayınları ve kaç üyeye bildirildikleri. Acil durumda bir yayını herkes için kapatabilirsin.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(broadcastSearchProvider),
        ),
      ],
      children: [
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<AdminLiveStatus>(
                    segments: [for (final t in AdminLiveStatus.values) ButtonSegment(value: t, label: Text(t.label))],
                    selected: {_tab},
                    onSelectionChanged: (s) => setState(() {
                      _tab = s.first;
                      _page = 1;
                    }),
                  ),
                ),
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwEmptyState(
                      icon: Icons.podcasts_outlined,
                      message: switch (_tab) {
                        AdminLiveStatus.live => 'Şu anda canlı yayın yok.',
                        AdminLiveStatus.scheduled => 'Planlanmış yayın yok.',
                        AdminLiveStatus.ended => 'Henüz biten yayın yok.',
                      },
                      actionLabel: 'Yenile',
                      onAction: () => ref.invalidate(broadcastSearchProvider(key)),
                    ),
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final b in value.items) ...[
                        _BroadcastRow(broadcast: b, onEnd: canEnd && _tab == AdminLiveStatus.live ? () => _end(b) : null),
                        const Divider(),
                      ],
                      PageFooter(
                        from: value.range.$1,
                        to: value.range.$2,
                        total: value.total,
                        noun: 'yayın',
                        page: value.page,
                        pageCount: value.pageCount,
                        onPage: (p) => setState(() => _page = p),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(broadcastSearchProvider(key))),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.all(GwSpacing.lg),
                    child: Column(children: [
                      GwSkeleton(height: GwSpacing.xl),
                      SizedBox(height: GwSpacing.md),
                      GwSkeleton(height: GwSpacing.xl),
                    ]),
                  ),
              },
            ],
          ),
        ),
      ],
    );
  }
}

class _BroadcastRow extends StatelessWidget {
  const _BroadcastRow({required this.broadcast, required this.onEnd});

  final AdminBroadcast broadcast;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final b = broadcast;
    final live = b.status == AdminLiveStatus.live;
    final scheduled = b.status == AdminLiveStatus.scheduled;
    final meta = [
      '${b.groupName} (@${b.groupHandle})',
      if (b.hostUsername != null) 'Sunucu @${b.hostUsername}',
      if (scheduled && b.scheduledAt != null) 'Planlanan ${formatDateTime(b.scheduledAt!)}',
      if (b.startedAt != null) formatDateTime(b.startedAt!),
      if (!scheduled) _minutes(b.duration(DateTime.now())),
      if (live && b.participants != null) '${formatCount(b.participants!)} kişi',
      if (scheduled) '${formatCount(b.notified)} üyeye duyuruldu',
      if (!scheduled && b.notified > 0) '${formatCount(b.notified)} üyeye başladığı bildirildi',
      ?b.endReasonLabel,
    ].join(' · ');
    return InkWell(
      onTap: () => context.go(AdminRoutes.group(b.groupId)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (live) ...[const GwLiveBadge(), const SizedBox(width: GwSpacing.xs)],
                      Flexible(child: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge)),
                    ],
                  ),
                  Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            if (onEnd != null) ...[
              const SizedBox(width: GwSpacing.sm),
              GwButton(label: 'Kapat', icon: Icons.stop_circle_outlined, variant: GwButtonVariant.secondary, onPressed: onEnd),
            ],
          ],
        ),
      ),
    );
  }
}
