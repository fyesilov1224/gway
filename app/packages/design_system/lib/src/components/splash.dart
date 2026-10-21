import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'badge.dart';
import 'logo.dart';

/// Brand screen shown while the app decides where to go.
class GxSplash extends StatelessWidget {
  const GxSplash({super.key, this.caption});

  /// Optional product label under the logo, e.g. "Yönetim".
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GxLogo(size: GxSpacing.xxl, wordmark: true),
            if (caption != null) ...[
              const SizedBox(height: GxSpacing.sm),
              GxBadge(caption!, tone: GxBadgeTone.primary),
            ],
            const SizedBox(height: GxSpacing.xl),
            const SizedBox.square(
              dimension: GxSpacing.lg,
              child: CircularProgressIndicator(strokeWidth: 2, color: GxColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
