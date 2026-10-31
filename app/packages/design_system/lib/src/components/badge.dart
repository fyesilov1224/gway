import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

enum GwBadgeTone { neutral, primary, info, danger, warning, success }

/// Small status label, e.g. "Aktif" or "Yönetici". Text always meets AA on
/// its soft background.
class GwBadge extends StatelessWidget {
  const GwBadge(this.label, {super.key, this.tone = GwBadgeTone.neutral, this.dot = false});

  final String label;
  final GwBadgeTone tone;

  /// Leading colored dot, for statuses.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      GwBadgeTone.neutral => (GwColors.surfaceMuted, GwColors.textSecondary),
      GwBadgeTone.primary => (GwColors.primarySoft, GwColors.primary),
      GwBadgeTone.info => (GwColors.secondarySoft, GwColors.textPrimary),
      GwBadgeTone.danger => (GwColors.errorSoft, GwColors.error),
      GwBadgeTone.warning => (GwColors.warningSoft, GwColors.warning),
      GwBadgeTone.success => (GwColors.successSoft, GwColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs / 2),
      decoration: BoxDecoration(color: background, borderRadius: GwRadius.smAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: GwSpacing.xs - 2,
              height: GwSpacing.xs - 2,
              decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: GwSpacing.xxs + 2),
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
