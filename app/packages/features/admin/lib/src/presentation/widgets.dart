import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/admin_user.dart';

/// Summary counter that filters a list when tapped.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    this.selected = false,
    this.onTap,
    this.valueText,
  });

  final String label;
  final int? value;
  final IconData icon;
  final GwBadgeTone tone;
  final bool selected;

  /// Null for a card that only shows a number.
  final VoidCallback? onTap;

  /// Shown instead of [value], e.g. an amount of money.
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = switch (tone) {
      GwBadgeTone.primary => (GwColors.primarySoft, GwColors.primary),
      GwBadgeTone.danger => (GwColors.errorSoft, GwColors.error),
      GwBadgeTone.info => (GwColors.secondarySoft, GwColors.secondary),
      GwBadgeTone.neutral => (GwColors.surfaceMuted, GwColors.textSecondary),
      GwBadgeTone.warning => (GwColors.warningSoft, GwColors.warning),
      GwBadgeTone.success => (GwColors.successSoft, GwColors.success),
    };
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '$label: ${valueText ?? (value == null ? '-' : formatCount(value!))}',
      excludeSemantics: true,
      child: Material(
        color: GwColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: GwRadius.lgAll,
          side: selected ? const BorderSide(color: GwColors.primary, width: 1.5) : GwBorders.hairline,
        ),
        child: InkWell(
          borderRadius: GwRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
                      const SizedBox(height: GwSpacing.xxs),
                      switch ((valueText, value)) {
                        (final String text, _) => Text(text, style: textTheme.headlineMedium),
                        (_, final int v) => Text(formatCount(v), style: textTheme.headlineMedium),
                        _ => const GwSkeleton(width: GwSpacing.xxl, height: GwSpacing.xl),
                      },
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(GwSpacing.xs),
                  decoration: BoxDecoration(color: background, borderRadius: GwRadius.mdAll),
                  child: Icon(icon, color: foreground, size: GwSpacing.lg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A responsive row of [StatCard]s: [wideColumns] (four) from the reading width on, two below.
class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.cards, this.wideColumns = 4});

  final List<StatCard> cards;
  final int wideColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= GwLayout.contentMaxWidth ? wideColumns : 2;
        final width = (constraints.maxWidth - GwSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: GwSpacing.md,
          runSpacing: GwSpacing.md,
          children: [for (final card in cards) SizedBox(width: width, child: card)],
        );
      },
    );
  }
}

/// Search field plus "Tümü" and one choice chip per filter value (none without filters).
class ListToolbar<T> extends StatelessWidget {
  const ListToolbar({
    super.key,
    required this.controller,
    required this.hint,
    required this.query,
    required this.filters,
    required this.selected,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final String query;
  final List<(T, String)> filters;
  final T? selected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<T?> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: controller,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(tooltip: 'Aramayı temizle', icon: const Icon(Icons.close), onPressed: onClear),
      ),
    );
    if (filters.isEmpty) return Padding(padding: const EdgeInsets.all(GwSpacing.md), child: search);
    final chips = Wrap(
      spacing: GwSpacing.xs,
      runSpacing: GwSpacing.xs,
      children: [
        for (final (value, label) in <(T?, String)>[(null, 'Tümü'), ...filters])
          ChoiceChip(
            label: Text(label),
            selected: selected == value,
            showCheckmark: false,
            onSelected: (_) => onFilterChanged(value),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GwLayout.contentMaxWidth
            ? Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: GwSpacing.md),
                  chips,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [search, const SizedBox(height: GwSpacing.sm), chips],
              ),
      ),
    );
  }
}

/// "1–20 / 57 kayıt" with previous / next page buttons.
class PageFooter extends StatelessWidget {
  const PageFooter({
    super.key,
    required this.from,
    required this.to,
    required this.total,
    required this.noun,
    required this.page,
    required this.pageCount,
    required this.onPage,
  });

  final int from;
  final int to;
  final int total;
  final String noun;
  final int page;
  final int pageCount;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$from–$to / $total $noun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
          ),
          IconButton.outlined(
            tooltip: 'Önceki sayfa',
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 ? () => onPage(page - 1) : null,
          ),
          const SizedBox(width: GwSpacing.xs),
          IconButton.outlined(
            tooltip: 'Sonraki sayfa',
            icon: const Icon(Icons.chevron_right),
            onPressed: page < pageCount ? () => onPage(page + 1) : null,
          ),
        ],
      ),
    );
  }
}

/// Status notice on detail pages (suspension, scheduled deletion).
class DetailBanner extends StatelessWidget {
  const DetailBanner({super.key, required this.tone, required this.icon, required this.title, this.body});

  final GwBadgeTone tone;
  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = tone == GwBadgeTone.danger
        ? (GwColors.errorSoft, GwColors.error)
        : (GwColors.surfaceMuted, GwColors.textPrimary);
    return Container(
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: BoxDecoration(color: background, borderRadius: GwRadius.lgAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium?.copyWith(color: foreground)),
                if (body != null) Text(body!, style: textTheme.bodyMedium?.copyWith(color: GwColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label / value pair; stacks on narrow widths.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelText = Text(label, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary));
    final valueText = SelectableText(value, style: textTheme.bodyMedium);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GwLayout.formMaxWidth
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: GwSpacing.xxl * 3, child: labelText),
                  Expanded(child: valueText),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [labelText, valueText]),
      ),
    );
  }
}

/// Panel of [InfoRow]s separated by dividers.
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return GwPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (label, value)) in rows.indexed) ...[
            if (i > 0) const Divider(),
            InfoRow(label: label, value: value),
          ],
        ],
      ),
    );
  }
}

/// Kinds of recorded actions, read from the action code's prefix; each has its own color and filter chip.
enum _HistoryKind {
  account('Hesap', GwColors.primarySoft, GwColors.primary),
  security('Güvenlik', GwColors.warningSoft, GwColors.warning),
  groups('Gruplar', GwColors.secondarySoft, GwColors.secondary),
  moderation('Moderasyon', GwColors.errorSoft, GwColors.error),
  plans('Paketler', GwColors.successSoft, GwColors.success),
  messages('Mesaj kayıtları', GwColors.surfaceMuted, GwColors.textSecondary),
  other('Diğer', GwColors.surfaceMuted, GwColors.textSecondary);

  const _HistoryKind(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  static _HistoryKind of(String action) => switch (action.split('.').first) {
        'user' || 'account' => account,
        'security' => security,
        'group' || 'role' || 'event' || 'poll' || 'goal' || 'league' => groups,
        'moderation' || 'sanction' || 'report' || 'appeal' || 'case' || 'referral' || 'post' || 'comment' => moderation,
        'plans' || 'personal_plan' || 'subscription' || 'plan' || 'order' || 'billing' => plans,
        'message' => messages,
        _ => other,
      };
}

/// Audit history: filter chips by kind, day headings and compact rows, a page at a time.
class HistoryPanel extends StatefulWidget {
  const HistoryPanel({
    super.key,
    required this.history,
    required this.labels,
    required this.emptyText,
    this.userActorLabel,
    this.detailLabels = const {},
  });

  /// Rows per page.
  static const pageSize = 8;

  final List<AdminAuditItem> history;

  /// Shown for actions users took themselves; defaults to the actor's name.
  final String? userActorLabel;

  /// Readable names for recorded details, e.g. role slugs.
  final Map<String, String> detailLabels;

  /// Action code → (label, icon). Unknown actions show a generic name.
  final Map<String, (String, IconData)> labels;
  final String emptyText;

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  _HistoryKind? _kind;
  int _page = 1;

  String _actor(AdminAuditItem h) => switch (h.actorKind) {
        'staff' => 'Ekip: ${h.actorName ?? 'Platform ekibi'}',
        'system' => 'Sistem',
        _ => widget.userActorLabel ?? h.actorName ?? 'Kullanıcı',
      };

  static String _day(DateTime at) {
    final day = DateUtils.dateOnly(at.toLocal());
    final today = DateUtils.dateOnly(DateTime.now());
    if (day == today) return 'Bugün';
    if (day == today.subtract(const Duration(days: 1))) return 'Dün';
    return formatDateTr(day);
  }

  static String _time(DateTime at) {
    final local = at.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final counts = <_HistoryKind, int>{};
    for (final h in widget.history) {
      counts.update(_HistoryKind.of(h.action), (c) => c + 1, ifAbsent: () => 1);
    }
    final filtered = _kind == null ? widget.history : [for (final h in widget.history) if (_HistoryKind.of(h.action) == _kind) h];
    final pageCount = filtered.isEmpty ? 1 : (filtered.length / HistoryPanel.pageSize).ceil();
    final page = _page.clamp(1, pageCount);
    final from = (page - 1) * HistoryPanel.pageSize;
    final rows = filtered.skip(from).take(HistoryPanel.pageSize).toList();

    return GwPanel(
      title: 'İşlem geçmişi',
      subtitle: widget.history.isEmpty ? null : 'Son ${widget.history.length} kayıt, en yenisi üstte.',
      padding: EdgeInsets.zero,
      child: widget.history.isEmpty
          ? Padding(padding: const EdgeInsets.all(GwSpacing.lg), child: Text(widget.emptyText, style: secondary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (counts.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.md),
                    child: Wrap(
                      spacing: GwSpacing.xs,
                      runSpacing: GwSpacing.xs,
                      children: [
                        for (final (value, label) in <(_HistoryKind?, String)>[
                          (null, 'Tümü (${widget.history.length})'),
                          for (final k in _HistoryKind.values)
                            if (counts[k] case final n?) (k, '${k.label} ($n)'),
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: _kind == value,
                            showCheckmark: false,
                            onSelected: (_) => setState(() {
                              _kind = value;
                              _page = 1;
                            }),
                          ),
                      ],
                    ),
                  ),
                const Divider(),
                for (final (i, h) in rows.indexed) ...[
                  if (i == 0 || _day(rows[i - 1].occurredAt) != _day(h.occurredAt))
                    Container(
                      color: GwColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.xxs),
                      child: Text(_day(h.occurredAt), style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                    ),
                  _HistoryRow(
                    item: h,
                    label: widget.labels[h.action]?.$1 ?? 'Kayıtlı işlem',
                    icon: widget.labels[h.action]?.$2 ?? Icons.history,
                    detail: [?h.targetName, if (h.detail case final d?) widget.detailLabels[d] ?? d, _actor(h)].join(' · '),
                    time: _time(h.occurredAt),
                  ),
                  if (i < rows.length - 1) const Divider(),
                ],
                if (filtered.length > HistoryPanel.pageSize) ...[
                  const Divider(),
                  PageFooter(
                    from: from + 1,
                    to: from + rows.length,
                    total: filtered.length,
                    noun: 'kayıt',
                    page: page,
                    pageCount: pageCount,
                    onPage: (p) => setState(() => _page = p),
                  ),
                ],
              ],
            ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.label, required this.icon, required this.detail, required this.time});

  final AdminAuditItem item;
  final String label;
  final IconData icon;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final kind = _HistoryKind.of(item.action);
    return Tooltip(
      message: formatDateTimeTr(item.occurredAt),
      waitDuration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            Semantics(
              label: kind.label,
              child: Container(
                padding: const EdgeInsets.all(GwSpacing.xs),
                decoration: BoxDecoration(color: kind.background, borderRadius: GwRadius.mdAll),
                child: Icon(icon, size: GwSpacing.md + GwSpacing.xxs, color: kind.foreground),
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Text(time, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
