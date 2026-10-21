import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/support.dart';
import 'providers.dart';

/// Color and icon of a message kind: problem red, request yellow, suggestion green.
extension SupportKindStyle on SupportKind {
  IconData get icon => switch (this) {
        SupportKind.problem => Icons.report_problem_outlined,
        SupportKind.request => Icons.assignment_outlined,
        SupportKind.suggestion => Icons.lightbulb_outline,
      };

  Color get color => switch (this) {
        SupportKind.problem => GxColors.error,
        SupportKind.request => GxColors.warning,
        SupportKind.suggestion => GxColors.success,
      };

  Color get softColor => switch (this) {
        SupportKind.problem => GxColors.errorSoft,
        SupportKind.request => GxColors.warningSoft,
        SupportKind.suggestion => GxColors.successSoft,
      };

  GxBadgeTone get tone => switch (this) {
        SupportKind.problem => GxBadgeTone.danger,
        SupportKind.request => GxBadgeTone.warning,
        SupportKind.suggestion => GxBadgeTone.success,
      };
}

const _iconSize = GxSpacing.md + GxSpacing.xxs;

/// The kind's icon on its soft color, in a rounded square.
class SupportKindIcon extends StatelessWidget {
  const SupportKindIcon(this.kind, {super.key});

  final SupportKind kind;

  @override
  Widget build(BuildContext context) => Semantics(
        label: kind.label,
        child: Container(
          padding: const EdgeInsets.all(GxSpacing.xs),
          decoration: BoxDecoration(color: kind.softColor, borderRadius: GxRadius.mdAll),
          child: Icon(kind.icon, color: kind.color, size: _iconSize),
        ),
      );
}

/// Statuses are neutral; color belongs to the kind.
class SupportStatusBadge extends StatelessWidget {
  const SupportStatusBadge(this.status, {super.key});

  final SupportStatus status;

  @override
  Widget build(BuildContext context) => GxBadge(
        status.label,
        dot: true,
        tone: status == SupportStatus.inProgress ? GxBadgeTone.info : GxBadgeTone.neutral,
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
    const size = GxSpacing.xxl + GxSpacing.md;
    return Wrap(
      spacing: GxSpacing.xs,
      runSpacing: GxSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, image) in images.indexed)
          Stack(
            children: [
              ClipRRect(
                borderRadius: GxRadius.mdAll,
                child: Image.memory(image.bytes, width: size, height: size, fit: BoxFit.cover),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filledTonal(
                  tooltip: 'Görseli kaldır',
                  visualDensity: VisualDensity.compact,
                  iconSize: GxSpacing.md,
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
            label: Text('Ekran görüntüsü (${images.length}/${SupportRules.maxImages})'),
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
    const size = GxSpacing.xxl + GxSpacing.md;
    final url = ref.watch(attachmentUrlProvider(path)).value;
    if (url == null) return const GxSkeleton(width: size, height: size);
    return Semantics(
      button: true,
      label: 'Ekran görüntüsünü büyüt',
      child: InkWell(
        borderRadius: GxRadius.mdAll,
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(borderRadius: GxRadius.lgAll),
            child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
          ),
        ),
        child: ClipRRect(
          borderRadius: GxRadius.mdAll,
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: size,
              height: size,
              child: Icon(Icons.broken_image_outlined, color: GxColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
