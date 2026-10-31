import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'button.dart';

/// Shown for every empty list: an icon, one sentence and one action.
class GwEmptyState extends StatelessWidget {
  const GwEmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GwSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(GwSpacing.md),
              decoration: const ShapeDecoration(
                color: GwColors.primarySoft,
                shape: CircleBorder(),
              ),
              child: Icon(icon, size: GwSpacing.xl, color: GwColors.primary),
            ),
            const SizedBox(height: GwSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: GwColors.textSecondary,
              ),
            ),
            const SizedBox(height: GwSpacing.lg),
            GwButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
