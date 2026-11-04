import 'package:flutter/material.dart';

import '../l10n.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// "CANLI" (in the app language) on the purple→blue gradient; the gradient is reserved for this and [GwLiveButton].
class GwLiveBadge extends StatelessWidget {
  const GwLiveBadge({super.key, this.label});

  /// Defaults to the localized "LIVE".
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: designSystemL10n.liveBroadcast,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: GwColors.liveGradient, borderRadius: GwRadius.smAll),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs / 2),
            child: Text(
              label ?? designSystemL10n.liveBadge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GwColors.onPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
}

/// The "start live" action on the live gradient.
class GwLiveButton extends StatelessWidget {
  const GwLiveButton({super.key, required this.label, required this.onPressed, this.icon = Icons.mic_rounded, this.expand = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final child = Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          gradient: enabled ? GwColors.liveGradient : null,
          color: enabled ? null : GwColors.surfaceMuted,
          borderRadius: GwRadius.mdAll,
        ),
        child: InkWell(
          borderRadius: GwRadius.mdAll,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: GwSpacing.buttonHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: enabled ? GwColors.onPrimary : GwColors.textSecondary, size: GwSpacing.md + GwSpacing.xxs),
                  const SizedBox(width: GwSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: enabled ? GwColors.onPrimary : GwColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(button: true, enabled: enabled, child: child);
  }
}
