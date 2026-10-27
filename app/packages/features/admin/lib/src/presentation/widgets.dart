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
  final GxBadgeTone tone;
  final bool selected;

  /// Null for a card that only shows a number.
  final VoidCallback? onTap;

  /// Shown instead of [value], e.g. an amount of money.
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = switch (tone) {
      GxBadgeTone.primary => (GxColors.primarySoft, GxColors.primary),
      GxBadgeTone.danger => (GxColors.errorSoft, GxColors.error),
      GxBadgeTone.info => (GxColors.secondarySoft, GxColors.secondary),
      GxBadgeTone.neutral => (GxColors.surfaceMuted, GxColors.textSecondary),
      GxBadgeTone.warning => (GxColors.warningSoft, GxColors.warning),
      GxBadgeTone.success => (GxColors.successSoft, GxColors.success),
    };
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '$label: ${valueText ?? (value == null ? '-' : formatCount(value!))}',
      excludeSemantics: true,
      child: Material(
        color: GxColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: GxRadius.lgAll,
          side: selected ? const BorderSide(color: GxColors.primary, width: 1.5) : GxBorders.hairline,
        ),
        child: InkWell(
          borderRadius: GxRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GxSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: textTheme.labelLarge?.copyWith(color: GxColors.textSecondary)),
                      const SizedBox(height: GxSpacing.xxs),
                      switch ((valueText, value)) {
                        (final String text, _) => Text(text, style: textTheme.headlineMedium),
                        (_, final int v) => Text(formatCount(v), style: textTheme.headlineMedium),
                        _ => const GxSkeleton(width: GxSpacing.xxl, height: GxSpacing.xl),
                      },
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(GxSpacing.xs),
                  decoration: BoxDecoration(color: background, borderRadius: GxRadius.mdAll),
                  child: Icon(icon, color: foreground, size: GxSpacing.lg),
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
        final columns = constraints.maxWidth >= GxLayout.contentMaxWidth ? wideColumns : 2;
        final width = (constraints.maxWidth - GxSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: GxSpacing.md,
          runSpacing: GxSpacing.md,
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
    if (filters.isEmpty) return Padding(padding: const EdgeInsets.all(GxSpacing.md), child: search);
    final chips = Wrap(
      spacing: GxSpacing.xs,
      runSpacing: GxSpacing.xs,
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
      padding: const EdgeInsets.all(GxSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GxLayout.contentMaxWidth
            ? Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: GxSpacing.md),
                  chips,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [search, const SizedBox(height: GxSpacing.sm), chips],
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
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$from–$to / $total $noun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
            ),
          ),
          IconButton.outlined(
            tooltip: 'Önceki sayfa',
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 ? () => onPage(page - 1) : null,
          ),
          const SizedBox(width: GxSpacing.xs),
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

  final GxBadgeTone tone;
  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = tone == GxBadgeTone.danger
        ? (GxColors.errorSoft, GxColors.error)
        : (GxColors.surfaceMuted, GxColors.textPrimary);
    return Container(
      padding: const EdgeInsets.all(GxSpacing.md),
      decoration: BoxDecoration(color: background, borderRadius: GxRadius.lgAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: GxSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium?.copyWith(color: foreground)),
                if (body != null) Text(body!, style: textTheme.bodyMedium?.copyWith(color: GxColors.textPrimary)),
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
    final labelText = Text(label, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary));
    final valueText = SelectableText(value, style: textTheme.bodyMedium);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GxLayout.formMaxWidth
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: GxSpacing.xxl * 3, child: labelText),
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
    return GxPanel(
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

/// Audit history as a vertical timeline.
class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    super.key,
    required this.history,
    required this.labels,
    required this.emptyText,
    this.userActorLabel,
    this.detailLabels = const {},
  });

  final List<AdminAuditItem> history;

  /// Shown for actions users took themselves; defaults to the actor's name.
  final String? userActorLabel;

  /// Readable names for recorded details, e.g. role slugs.
  final Map<String, String> detailLabels;

  /// Action code → (label, icon). Unknown actions show their code.
  final Map<String, (String, IconData)> labels;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    return GxPanel(
      title: 'İşlem geçmişi',
      child: history.isEmpty
          ? Text(emptyText, style: secondary)
          : Column(
              children: [
                for (final (i, h) in history.indexed)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(GxSpacing.xxs + 2),
                              decoration: const BoxDecoration(color: GxColors.primarySoft, shape: BoxShape.circle),
                              child: Icon(labels[h.action]?.$2 ?? Icons.history, size: GxSpacing.md, color: GxColors.primary),
                            ),
                            if (i < history.length - 1)
                              const Expanded(child: VerticalDivider(width: GxSpacing.md, thickness: 1)),
                          ],
                        ),
                        const SizedBox(width: GxSpacing.sm),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: GxSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(labels[h.action]?.$1 ?? h.action, style: textTheme.labelLarge),
                                if (h.targetName != null || h.detail != null)
                                  Text(
                                    [?h.targetName, if (h.detail case final d?) detailLabels[d] ?? d].join(' · '),
                                    style: textTheme.bodyMedium,
                                  ),
                                Text('${formatDateTimeTr(h.occurredAt)} · ${_actor(h, userActorLabel)}', style: secondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  static String _actor(AdminAuditItem h, String? userLabel) => switch (h.actorKind) {
        'staff' => h.actorName ?? 'Platform ekibi',
        'system' => 'Sistem',
        _ => userLabel ?? h.actorName ?? 'Kullanıcı',
      };
}
