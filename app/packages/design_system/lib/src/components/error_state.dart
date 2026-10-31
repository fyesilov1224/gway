import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'button.dart';

/// Shown when content fails to load: an icon, a safe message and a retry.
class GwErrorState extends StatelessWidget {
  const GwErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
                color: GwColors.errorSoft,
                shape: CircleBorder(),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: GwSpacing.xl,
                color: GwColors.error,
              ),
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
            GwButton(
              label: 'Tekrar dene',
              onPressed: onRetry,
              variant: GwButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
