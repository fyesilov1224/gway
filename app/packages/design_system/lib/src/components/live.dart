import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

/// "CANLI" on the purple→blue gradient; the gradient is reserved for this and [GxLiveButton].
class GxLiveBadge extends StatelessWidget {
  const GxLiveBadge({super.key, this.label = 'CANLI'});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Canlı yayın',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: GxColors.liveGradient, borderRadius: GxRadius.smAll),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs / 2),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GxColors.onPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
}

/// The "start live" action on the live gradient.
class GxLiveButton extends StatelessWidget {
  const GxLiveButton({super.key, required this.label, required this.onPressed, this.icon = Icons.mic_rounded, this.expand = false});

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
          gradient: enabled ? GxColors.liveGradient : null,
          color: enabled ? null : GxColors.surfaceMuted,
          borderRadius: GxRadius.mdAll,
        ),
        child: InkWell(
          borderRadius: GxRadius.mdAll,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: GxSpacing.buttonHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: enabled ? GxColors.onPrimary : GxColors.textSecondary, size: GxSpacing.md + GxSpacing.xxs),
                  const SizedBox(width: GxSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: enabled ? GxColors.onPrimary : GxColors.textSecondary,
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
