import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

enum GxBadgeTone { neutral, primary, info, danger, warning, success }

/// Small status label, e.g. "Aktif" or "Yönetici". Text always meets AA on
/// its soft background.
class GxBadge extends StatelessWidget {
  const GxBadge(this.label, {super.key, this.tone = GxBadgeTone.neutral, this.dot = false});

  final String label;
  final GxBadgeTone tone;

  /// Leading colored dot, for statuses.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      GxBadgeTone.neutral => (GxColors.surfaceMuted, GxColors.textSecondary),
      GxBadgeTone.primary => (GxColors.primarySoft, GxColors.primary),
      GxBadgeTone.info => (GxColors.secondarySoft, GxColors.textPrimary),
      GxBadgeTone.danger => (GxColors.errorSoft, GxColors.error),
      GxBadgeTone.warning => (GxColors.warningSoft, GxColors.warning),
      GxBadgeTone.success => (GxColors.successSoft, GxColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs / 2),
      decoration: BoxDecoration(color: background, borderRadius: GxRadius.smAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: GxSpacing.xs - 2,
              height: GxSpacing.xs - 2,
              decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: GxSpacing.xxs + 2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
