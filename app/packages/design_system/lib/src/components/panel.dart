import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// White, hairline-bordered content block with an optional header.
/// Always fills the available width.
class GxPanel extends StatelessWidget {
  const GxPanel({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(GxSpacing.lg),
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: GxColors.background,
        borderRadius: GxRadius.lgAll,
        border: Border.fromBorderSide(GxBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.md),
              decoration: const BoxDecoration(border: Border(bottom: GxBorders.hairline)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: textTheme.titleMedium),
                        if (subtitle != null)
                          Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
