import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// White, hairline-bordered content block with an optional header.
/// Always fills the available width.
class GwPanel extends StatelessWidget {
  const GwPanel({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(GwSpacing.lg),
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
        color: GwColors.background,
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.md),
              decoration: const BoxDecoration(border: Border(bottom: GwBorders.hairline)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: textTheme.titleMedium),
                        if (subtitle != null)
                          Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
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
