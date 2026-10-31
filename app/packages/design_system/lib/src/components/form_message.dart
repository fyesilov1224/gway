import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

enum GwFormMessageKind { error, info }

/// Inline message under a form: an error after a failed submit, or info
/// such as "link sent".
class GwFormMessage extends StatelessWidget {
  const GwFormMessage(this.message, {super.key, this.kind = GwFormMessageKind.error});

  final String message;
  final GwFormMessageKind kind;

  @override
  Widget build(BuildContext context) {
    final isError = kind == GwFormMessageKind.error;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GwSpacing.sm),
        decoration: BoxDecoration(
          color: isError ? GwColors.errorSoft : GwColors.secondarySoft,
          borderRadius: GwRadius.mdAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              size: GwSpacing.md + GwSpacing.xxs,
              color: isError ? GwColors.error : GwColors.textPrimary,
            ),
            const SizedBox(width: GwSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isError ? GwColors.error : GwColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
