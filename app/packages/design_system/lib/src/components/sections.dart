import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/tones.dart';

/// White card with the large radius and a hairline. Pages are built from
/// these on the tinted canvas instead of edge-to-edge rows with dividers.
class GwCard extends StatelessWidget {
  const GwCard({super.key, required this.child, this.padding = EdgeInsets.zero, this.onTap, this.radius = GwRadius.xlAll});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Material(
      color: GwColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius, side: GwBorders.hairline),
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// A page section's title with an optional "Tümü"-style link on the right.
class GwSectionHeader extends StatelessWidget {
  const GwSectionHeader({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction, this.padding});

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Defaults to the page gutter with room above.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.lg, GwSpacing.xs, GwSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleLarge),
                  if (subtitle case final text?)
                    Text(text, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
          ),
          if (actionLabel case final label?)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(label), const Icon(Icons.chevron_right_rounded, size: GwSpacing.md + GwSpacing.xxs)],
              ),
            ),
        ],
      ),
    );
  }
}

String _monthShort(DateTime d) {
  final code = currentAppLanguage.code;
  return DateFormat.MMM(code).format(d).replaceAll('.', '').toUpperCase();
}

/// The calendar leaf of organizations: short month over a large day.
class GwDateTile extends StatelessWidget {
  const GwDateTile({super.key, required this.date, this.tone = GwTone.lilac});

  final DateTime date;
  final GwTone tone;

  static const double size = GwSpacing.xxl + GwSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final local = date.toLocal();
    return Semantics(
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_monthShort(local),
                textScaler: TextScaler.noScaling, style: textTheme.labelMedium?.copyWith(color: tone.strong, fontWeight: FontWeight.w700)),
            Text('${local.day}', textScaler: TextScaler.noScaling, style: textTheme.titleLarge?.copyWith(height: 1.1)),
          ],
        ),
      ),
    );
  }
}

/// A soft pill with an icon: categories, interests, quick filters.
class GwTag extends StatelessWidget {
  const GwTag({super.key, required this.label, this.icon, this.tone = GwTone.lilac});

  final String label;
  final IconData? icon;
  final GwTone tone;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xxs),
        decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.xlAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final i?) ...[
              Icon(i, size: GwSpacing.md, color: tone.strong),
              const SizedBox(width: GwSpacing.xxs),
            ],
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ),
      );
}
