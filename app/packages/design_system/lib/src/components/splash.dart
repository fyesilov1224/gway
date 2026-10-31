import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'badge.dart';
import 'logo.dart';

/// Brand screen shown while the app decides where to go.
class GwSplash extends StatelessWidget {
  const GwSplash({super.key, this.caption});

  /// Optional product label under the logo, e.g. "Yönetim".
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GwLogo(size: GwSpacing.xxl, wordmark: true),
            if (caption != null) ...[
              const SizedBox(height: GwSpacing.sm),
              GwBadge(caption!, tone: GwBadgeTone.primary),
            ],
            const SizedBox(height: GwSpacing.xl),
            const SizedBox.square(
              dimension: GwSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2, color: GwColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
