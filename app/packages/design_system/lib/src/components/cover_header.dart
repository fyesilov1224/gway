import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'avatar.dart';
import 'skeleton.dart';

/// Centered reading column ([GxLayout.contentMaxWidth]); on wide screens it
/// gets hairline side borders. Used by profile and group pages; the feed
/// passes [GxLayout.feedMaxWidth].
class GxReadingColumn extends StatelessWidget {
  const GxReadingColumn({super.key, required this.child, this.maxWidth = GxLayout.contentMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > maxWidth;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: wide ? const BoxDecoration(border: Border.symmetric(vertical: GxBorders.hairline)) : null,
        child: child,
      ),
    );
  }
}

/// Edge of the header avatar: 96 on phones, 128 from the reading width on.
double gxHeaderAvatarSize(BuildContext context) =>
    (MediaQuery.sizeOf(context).width >= GxLayout.contentMaxWidth ? GxAvatarSize.xxl : GxAvatarSize.xl).dimension;

/// Ring around the header avatar, in pixels.
const double _ring = GxSpacing.xxs;

/// 3:1 cover (soft brand tint until one is uploaded) with the avatar
/// overlapping its bottom edge inside a white ring. The avatar sticks out
/// by half its size; callers reserve that space below.
class GxCoverHeader extends StatelessWidget {
  const GxCoverHeader({
    super.key,
    required this.name,
    required this.shape,
    this.coverUrl,
    this.avatarUrl,
  });

  final String name;
  final GxAvatarShape shape;
  final String? coverUrl;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final size = gxHeaderAvatarSize(context);
    final cover = coverUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 3,
          child: cover == null
              ? const _CoverPlaceholder()
              : Image.network(
                  cover,
                  fit: BoxFit.cover,
                  semanticLabel: 'Kapak fotoğrafı',
                  errorBuilder: (_, _, _) => const _CoverPlaceholder(),
                ),
        ),
        Positioned(
          left: GxSpacing.md,
          bottom: -size / 2,
          child: Container(
            padding: const EdgeInsets.all(_ring),
            decoration: ShapeDecoration(color: GxColors.background, shape: _ringShape(shape, size)),
            child: SizedBox.square(
              dimension: size,
              child: FittedBox(
                child: GxAvatar(name: name, shape: shape, imageUrl: avatarUrl, size: GxAvatarSize.xxl),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

ShapeBorder _ringShape(GxAvatarShape shape, double size) => switch (shape) {
      GxAvatarShape.user => const CircleBorder(),
      GxAvatarShape.group => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular((size + 2 * _ring) * GxRadius.lg / GxAvatarSize.lg.dimension),
        ),
    };

/// Loading state of [GxCoverHeader].
class GxCoverHeaderSkeleton extends StatelessWidget {
  const GxCoverHeaderSkeleton({super.key, required this.shape});

  final GxAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final size = gxHeaderAvatarSize(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const AspectRatio(aspectRatio: 3, child: GxSkeleton(height: double.infinity, borderRadius: BorderRadius.zero)),
        Positioned(
          left: GxSpacing.md,
          bottom: -size / 2,
          child: shape == GxAvatarShape.user
              ? GxSkeleton.circle(size: size)
              : GxSkeleton(width: size, height: size, borderRadius: BorderRadius.circular(size * GxRadius.lg / GxAvatarSize.lg.dimension)),
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: GxColors.primarySoft,
      child: Align(
        alignment: Alignment(0.85, 0),
        child: Icon(Icons.groups_2_outlined, size: GxSpacing.xxl * 2, color: GxColors.background),
      ),
    );
  }
}
