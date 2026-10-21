import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'button.dart';

/// Shown when content fails to load: an icon, a safe message and a retry.
class GxErrorState extends StatelessWidget {
  const GxErrorState({
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
        padding: const EdgeInsets.all(GxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(GxSpacing.md),
              decoration: const ShapeDecoration(
                color: GxColors.errorSoft,
                shape: CircleBorder(),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: GxSpacing.xl,
                color: GxColors.error,
              ),
            ),
            const SizedBox(height: GxSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: GxColors.textSecondary,
              ),
            ),
            const SizedBox(height: GxSpacing.lg),
            GxButton(
              label: 'Tekrar dene',
              onPressed: onRetry,
              variant: GxButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
