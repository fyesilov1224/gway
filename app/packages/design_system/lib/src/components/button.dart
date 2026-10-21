import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

enum GxButtonVariant { primary, secondary, text }

/// Standard GrupX button. Styling comes from [GxTheme].
class GxButton extends StatelessWidget {
  const GxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GxButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final GxButtonVariant variant;
  final IconData? icon;

  /// Shows a progress indicator and ignores taps while true.
  final bool isLoading;

  /// Fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    final child = _content(context);

    final button = switch (variant) {
      GxButtonVariant.primary => FilledButton(onPressed: callback, child: child),
      GxButtonVariant.secondary =>
        OutlinedButton(onPressed: callback, child: child),
      GxButtonVariant.text => TextButton(onPressed: callback, child: child),
    };

    return Semantics(
      button: true,
      enabled: callback != null,
      label: isLoading ? '$label, yükleniyor' : null,
      excludeSemantics: isLoading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: GxSpacing.md + GxSpacing.xxs,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: GxSpacing.md + GxSpacing.xxs),
        const SizedBox(width: GxSpacing.xs),
        Flexible(child: text),
      ],
    );
  }
}
