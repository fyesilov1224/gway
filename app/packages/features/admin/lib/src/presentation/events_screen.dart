import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_events.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Events across the platform (docs/ARCHITECTURE.md §3d): search, status filter, cancel.
class AdminEventsScreen extends ConsumerStatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  ConsumerState<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends ConsumerState<AdminEventsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminEventStatus? _status = AdminEventStatus.upcoming;
  int _page = 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => setState(() {
          _query = value.trim();
          _page = 1;
        }));
  }

  void _clear() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _status = null;
      _page = 1;
    });
  }

  Future<void> _cancel(AdminEvent e) async {
    final request = await showSuspendDialog(
      context,
      title: 'Organizasyonu iptal et',
      description: '"${e.title}" iptal edilir; katılanlara ve bekleyenlere bildirim gider. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'İptal et',
    );
    if (request == null || !mounted) return;
    final result = await ref.read(adminEventsRepositoryProvider).cancel(e.id, reason: request.reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => 'Organizasyon iptal edildi.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(adminEventSearchProvider);
  }

  Future<void> _removePoint(AdminEvent e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buluşma noktasını kaldır'),
        content: Text('"${e.title}" haritadan kalkar; yer metni kalır. İşlem kayda geçer.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: 'Kaldır', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(adminEventsRepositoryProvider).removeMeetingPoint(e.id);
    if (!mounted) return;
    _show(result, 'Buluşma noktası kaldırıldı.');
  }

  Future<void> _stopSeries(AdminEvent e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tekrarı durdur'),
        content: Text('"${e.title}" için yeni tarih açılmaz; açılmış tarihler kalır. İşlem kayda geçer.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: 'Durdur', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(adminEventsRepositoryProvider).stopSeries(e.seriesId!);
    if (!mounted) return;
    _show(result, 'Tekrar durduruldu.');
  }

  void _show(Result<void> result, String done) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => done,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(adminEventSearchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: _query, status: _status, page: _page);
    final result = ref.watch(adminEventSearchProvider(key));
    final canCancel = ref.watch(myStaffRoleProvider).value?.canSuspend ?? false;
    final filtered = _query.isNotEmpty || _status != null;

    return AdminPage(
      title: 'Organizasyonlar',
      subtitle: 'Grupların organizasyonları. Kurallara aykırı bir organizasyonu iptal edebilirsin.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(adminEventSearchProvider),
        ),
      ],
      children: [
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminEventStatus>(
                controller: _search,
                hint: 'Başlık, grup adı veya adresi ile ara',
                query: _query,
                filters: [for (final s in AdminEventStatus.values) (s, s.label)],
                selected: _status,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: (s) => setState(() {
                  _status = s;
                  _page = 1;
                }),
                onClear: _clear,
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: filtered
                        ? GwEmptyState(
                            icon: Icons.search_off,
                            message: 'Aramana ve filtrene uygun organizasyon bulunamadı.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clear,
                          )
                        : GwEmptyState(
                            icon: Icons.event_outlined,
                            message: 'Henüz organizasyon yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(adminEventSearchProvider(key)),
                          ),
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final e in value.items) ...[
                        _EventRow(
                          event: e,
                          onCancel: canCancel && !e.isCanceled && e.startsAt.isAfter(DateTime.now()) ? () => _cancel(e) : null,
                          onRemovePoint: canCancel && e.meetingLat != null ? () => _removePoint(e) : null,
                          onStopSeries: canCancel && e.seriesActive ? () => _stopSeries(e) : null,
                        ),
                        const Divider(),
                      ],
                      PageFooter(
                        from: value.range.$1,
                        to: value.range.$2,
                        total: value.total,
                        noun: 'organizasyon',
                        page: value.page,
                        pageCount: value.pageCount,
                        onPage: (p) => setState(() => _page = p),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminEventSearchProvider(key))),
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

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onCancel, required this.onRemovePoint, required this.onStopSeries});

  final AdminEvent event;
  final VoidCallback? onCancel;
  final VoidCallback? onRemovePoint;
  final VoidCallback? onStopSeries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = event;
    final seats = e.capacity == null ? '${formatCount(e.goingCount)} katılan' : '${formatCount(e.goingCount)} / ${formatCount(e.capacity!)}';
    final meta = [
      '${e.groupName} (@${e.groupHandle})',
      formatDateTimeTr(e.startsAt),
      e.location,
      seats,
      if (e.confirmedCount > 0) '${formatCount(e.confirmedCount)} teyit',
      if (e.waitlistCount > 0) '${formatCount(e.waitlistCount)} bekleyen',
      if (e.approvalRequired) 'Onaylı katılım${e.requestedCount > 0 ? ' · ${formatCount(e.requestedCount)} istek' : ''}',
      if (e.ratingAvg case final avg?) '${avg.toStringAsFixed(1).replaceAll('.', ',')} ★ (${formatCount(e.ratingCount)})',
      if (e.postsCount > 0) '${formatCount(e.postsCount)} anı',
      if (e.meetingLabel case final point?) 'Buluşma noktası: $point',
      if (e.seriesLabel case final series?) 'Tekrar: $series',
      if (e.cancelReason != null) 'İptal: ${e.cancelReason}',
    ].join(' · ');
    return InkWell(
      onTap: () => context.go(AdminRoutes.group(e.groupId)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            if (e.isCanceled) ...[const SizedBox(width: GwSpacing.sm), const GwBadge('İptal edildi', dot: true, tone: GwBadgeTone.danger)],
            if (onRemovePoint != null)
              IconButton(tooltip: 'Buluşma noktasını kaldır', icon: const Icon(Icons.wrong_location_outlined), onPressed: onRemovePoint),
            if (onStopSeries != null)
              IconButton(tooltip: 'Tekrarı durdur', icon: const Icon(Icons.event_repeat_outlined), onPressed: onStopSeries),
            if (onCancel != null) ...[
              const SizedBox(width: GwSpacing.sm),
              GwButton(label: 'İptal et', icon: Icons.event_busy_outlined, variant: GwButtonVariant.secondary, onPressed: onCancel),
            ],
          ],
        ),
      ),
    );
  }
}
