import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/support.dart';
import '../l10n.dart';
import 'providers.dart';

/// Color and icon of a message kind: problem red, request yellow, suggestion green.
extension SupportKindStyle on SupportKind {
  IconData get icon => switch (this) {
        SupportKind.problem => Icons.report_problem_outlined,
        SupportKind.request => Icons.assignment_outlined,
        SupportKind.suggestion => Icons.lightbulb_outline,
      };

  Color get color => switch (this) {
        SupportKind.problem => GwColors.error,
        SupportKind.request => GwColors.warning,
        SupportKind.suggestion => GwColors.success,
      };

  Color get softColor => switch (this) {
        SupportKind.problem => GwColors.errorSoft,
        SupportKind.request => GwColors.warningSoft,
        SupportKind.suggestion => GwColors.successSoft,
      };

  GwBadgeTone get tone => switch (this) {
        SupportKind.problem => GwBadgeTone.danger,
        SupportKind.request => GwBadgeTone.warning,
        SupportKind.suggestion => GwBadgeTone.success,
      };
}

const _iconSize = GwSpacing.md + GwSpacing.xxs;

/// The kind's icon on its soft color, in a rounded square.
class SupportKindIcon extends StatelessWidget {
  const SupportKindIcon(this.kind, {super.key});

  final SupportKind kind;

  @override
  Widget build(BuildContext context) => Semantics(
        label: kind.label,
        child: Container(
          padding: const EdgeInsets.all(GwSpacing.xs),
          decoration: BoxDecoration(color: kind.softColor, borderRadius: GwRadius.mdAll),
          child: Icon(kind.icon, color: kind.color, size: _iconSize),
        ),
      );
}

/// Statuses are neutral; color belongs to the kind.
class SupportStatusBadge extends StatelessWidget {
  const SupportStatusBadge(this.status, {super.key});

  final SupportStatus status;

  @override
  Widget build(BuildContext context) => GwBadge(
        status.label,
        dot: true,
        tone: status == SupportStatus.inProgress ? GwBadgeTone.info : GwBadgeTone.neutral,
      );
}

/// Up to [SupportRules.maxImages] picked screenshots with remove buttons.
class ImageAttachments extends StatelessWidget {
  const ImageAttachments({super.key, required this.images, required this.onAdd, required this.onRemove});

  final List<ImageUpload> images;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    const size = GwSpacing.xxl + GwSpacing.md;
    return Wrap(
      spacing: GwSpacing.xs,
      runSpacing: GwSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, image) in images.indexed)
          Stack(
            children: [
              ClipRRect(
                borderRadius: GwRadius.mdAll,
                child: Image.memory(image.bytes, width: size, height: size, fit: BoxFit.cover),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton.filledTonal(
                  tooltip: supportL10n.removeImage,
                  visualDensity: VisualDensity.compact,
                  iconSize: GwSpacing.md,
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemove(i),
                ),
              ),
            ],
          ),
        if (images.length < SupportRules.maxImages)
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: _iconSize),
            label: Text(supportL10n.screenshots(images.length, SupportRules.maxImages)),
          ),
      ],
    );
  }
}

/// A private attachment, loaded through a short-lived signed link; tap to enlarge.
class AttachmentThumbnail extends ConsumerWidget {
  const AttachmentThumbnail({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const size = GwSpacing.xxl + GwSpacing.md;
    final url = ref.watch(attachmentUrlProvider(path)).value;
    if (url == null) return const GwSkeleton(width: size, height: size);
    return Semantics(
      button: true,
      label: supportL10n.enlargeScreenshot,
      child: InkWell(
        borderRadius: GwRadius.mdAll,
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll),
            child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
          ),
        ),
        child: ClipRRect(
          borderRadius: GwRadius.mdAll,
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: size,
              height: size,
              child: Icon(Icons.broken_image_outlined, color: GwColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
