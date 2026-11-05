import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_support.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Kind colors: problem red, request yellow, suggestion green (docs/DESIGN.md §1).
extension AdminSupportKindStyle on AdminSupportKind {
  IconData get icon => switch (this) {
        AdminSupportKind.problem => Icons.report_problem_outlined,
        AdminSupportKind.request => Icons.assignment_outlined,
        AdminSupportKind.suggestion => Icons.lightbulb_outline,
      };

  GwBadgeTone get tone => switch (this) {
        AdminSupportKind.problem => GwBadgeTone.danger,
        AdminSupportKind.request => GwBadgeTone.warning,
        AdminSupportKind.suggestion => GwBadgeTone.success,
      };

  (Color, Color) get colors => switch (this) {
        AdminSupportKind.problem => (GwColors.errorSoft, GwColors.error),
        AdminSupportKind.request => (GwColors.warningSoft, GwColors.warning),
        AdminSupportKind.suggestion => (GwColors.successSoft, GwColors.success),
      };
}

/// The kind's icon on its soft color.
class SupportKindIcon extends StatelessWidget {
  const SupportKindIcon(this.kind, {super.key});

  final AdminSupportKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = kind.colors;
    return Semantics(
      label: kind.label,
      child: Container(
        padding: const EdgeInsets.all(GwSpacing.xs),
        decoration: BoxDecoration(color: background, borderRadius: GwRadius.mdAll),
        child: Icon(kind.icon, color: foreground, size: GwSpacing.md + GwSpacing.xxs),
      ),
    );
  }
}

class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge(this.status, {super.key});

  final AdminSupportStatus status;

  @override
  Widget build(BuildContext context) =>
      GwBadge(status.label, dot: true, tone: status == AdminSupportStatus.inProgress ? GwBadgeTone.info : GwBadgeTone.neutral);
}

/// Colored counters by kind, then every message; those waiting for the team come first.
class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminSupportKind? _kind;
  AdminSupportStatus? _status;
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
      _kind = null;
      _status = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: _query, kind: _kind, status: _status, page: _page);
    final result = ref.watch(ticketSearchProvider(key));
    final stats = ref.watch(supportStatsProvider).value;
    final filtered = _query.isNotEmpty || _kind != null || _status != null;

    return AdminPage(
      title: 'Destek',
      subtitle: 'Kullanıcıların ve grup yöneticilerinin sorunları, talepleri ve istekleri.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref
            ..invalidate(supportStatsProvider)
            ..invalidate(ticketSearchProvider),
        ),
      ],
      children: [
        StatCardRow(
          cards: [
            for (final kind in AdminSupportKind.values)
              StatCard(
                label: 'Açık ${kind.plural.toLowerCase()}',
                value: stats?.openOf(kind),
                icon: kind.icon,
                tone: kind.tone,
                selected: _kind == kind,
                onTap: () => setState(() {
                  _kind = _kind == kind ? null : kind;
                  _page = 1;
                }),
              ),
            StatCard(
              label: 'Yanıt bekleyen',
              value: stats?.awaitingReply,
              icon: Icons.mark_chat_unread_outlined,
              tone: GwBadgeTone.primary,
            ),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminSupportStatus>(
                controller: _search,
                hint: 'Konu, kullanıcı adı veya grup ile ara',
                query: _query,
                filters: [for (final s in AdminSupportStatus.values) (s, s.label)],
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
                            message: 'Aramana ve filtrene uygun mesaj bulunamadı.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clear,
                          )
                        : GwEmptyState(
                            icon: Icons.support_agent_outlined,
                            message: 'Henüz destek mesajı yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(ticketSearchProvider(key)),
                          ),
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final t in value.items) ...[_TicketRow(ticket: t), const Divider()],
                      PageFooter(
                        from: value.range.$1,
                        to: value.range.$2,
                        total: value.total,
                        noun: 'mesaj',
                        page: value.page,
                        pageCount: value.pageCount,
                        onPage: (p) => setState(() => _page = p),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(ticketSearchProvider(key))),
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

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final AdminTicket ticket;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = ticket;
    final who = t.username == null ? 'silinmiş hesap' : '@${t.username}';
    final meta = [t.kind.label, who, ?t.groupName, '${t.messageCount} mesaj', formatDateTime(t.lastMessageAt)].join(' · ');
    return InkWell(
      onTap: () => context.go(AdminRoutes.ticket(t.id)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            SupportKindIcon(t.kind),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TicketStatusBadge(t.status),
                if (t.awaitingReply) ...[
                  const SizedBox(height: GwSpacing.xxs),
                  const GwBadge('Yanıt bekliyor', tone: GwBadgeTone.primary),
                ],
              ],
            ),
            const SizedBox(width: GwSpacing.xs),
            const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
          ],
        ),
      ),
    );
  }
}
