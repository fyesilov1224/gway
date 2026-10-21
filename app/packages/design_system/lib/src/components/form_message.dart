import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

enum GxFormMessageKind { error, info }

/// Inline message under a form: an error after a failed submit, or info
/// such as "link sent".
class GxFormMessage extends StatelessWidget {
  const GxFormMessage(this.message, {super.key, this.kind = GxFormMessageKind.error});

  final String message;
  final GxFormMessageKind kind;

  @override
  Widget build(BuildContext context) {
    final isError = kind == GxFormMessageKind.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GxSpacing.sm),
        decoration: BoxDecoration(
          color: isError ? GxColors.errorSoft : GxColors.secondarySoft,
          borderRadius: GxRadius.mdAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              size: GxSpacing.md + GxSpacing.xxs,
              color: isError ? GxColors.error : GxColors.textPrimary,
            ),
            const SizedBox(width: GxSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isError ? GxColors.error : GxColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
