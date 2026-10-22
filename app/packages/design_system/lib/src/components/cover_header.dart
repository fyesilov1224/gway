import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/tones.dart';
import 'avatar.dart';
import 'sections.dart';
import 'skeleton.dart';

/// Centered column for pages that read top to bottom ([GxLayout.contentMaxWidth];
/// the home page passes [GxLayout.feedMaxWidth]).
class GxReadingColumn extends StatelessWidget {
  const GxReadingColumn({super.key, required this.child, this.maxWidth = GxLayout.contentMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}

/// Edge of the hero avatar: 64 on phones, 96 from the reading width on.
GxAvatarSize gxHeroAvatarSize(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= GxLayout.contentMaxWidth ? GxAvatarSize.xl : GxAvatarSize.lg;

/// The identity card at the top of a profile or group page: a rounded card
/// with the cover inside it, the avatar beside the name (it never overlaps
/// the cover) and the page's own content ([children]) below.
class GxHeroCard extends StatelessWidget {
  const GxHeroCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.shape,
    this.coverUrl,
    this.avatarUrl,
    this.tone,
    this.coverIcon = Icons.groups_2_outlined,
    this.subtitleTrailing,
    this.children = const [],
  });

  final String name;

  /// The @handle line under the name.
  final String subtitle;
  final GxAvatarShape shape;
  final String? coverUrl;
  final String? avatarUrl;

  /// Tone of the cover placeholder and the avatar fallback; defaults to the name's.
  final GxTone? tone;

  /// Drawn on the cover placeholder (e.g. the group's category).
  final IconData coverIcon;

  /// Next to the subtitle, e.g. a lock for private accounts.
  final Widget? subtitleTrailing;

  /// Bio, meta, stats and actions, separated by [GxSpacing.sm].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = tone ?? GxTone.of(name);
    final cover = coverUrl;
    final placeholder = _CoverPlaceholder(tone: palette, icon: coverIcon);
    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.xs, GxSpacing.page, 0),
      child: GxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3,
              child: cover == null
                  ? placeholder
                  : Image.network(cover, fit: BoxFit.cover, semanticLabel: 'Kapak fotoğrafı', errorBuilder: (_, _, _) => placeholder),
            ),
            Padding(
              padding: const EdgeInsets.all(GxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GxAvatar(name: name, shape: shape, imageUrl: avatarUrl, size: gxHeroAvatarSize(context), tone: palette),
                      const SizedBox(width: GxSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: textTheme.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyLarge?.copyWith(color: GxColors.textSecondary)),
                                ),
                                if (subtitleTrailing case final trailing?) ...[const SizedBox(width: GxSpacing.xxs), trailing],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  for (final child in children) ...[const SizedBox(height: GxSpacing.sm), child],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state of [GxHeroCard].
class GxHeroCardSkeleton extends StatelessWidget {
  const GxHeroCardSkeleton({super.key, required this.shape});

  final GxAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final size = gxHeroAvatarSize(context).dimension;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.xs, GxSpacing.page, 0),
      child: GxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AspectRatio(aspectRatio: 3, child: GxSkeleton(height: double.infinity, borderRadius: BorderRadius.zero)),
            Padding(
              padding: const EdgeInsets.all(GxSpacing.md),
              child: Row(
                children: [
                  if (shape == GxAvatarShape.user)
                    GxSkeleton.circle(size: size)
                  else
                    GxSkeleton(width: size, height: size, borderRadius: BorderRadius.circular(size * GxRadius.lg / GxAvatarSize.lg.dimension)),
                  const SizedBox(width: GxSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GxSkeleton(width: GxSpacing.xxl * 3, height: GxSpacing.lg),
                        SizedBox(height: GxSpacing.xs),
                        GxSkeleton(width: GxSpacing.xxl * 2, height: GxSpacing.md),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tone's soft color with its icon repeated faintly, like a club banner.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.tone, required this.icon});

  final GxTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final faint = tone.strong.withValues(alpha: 0.12);
    return ColoredBox(
      color: tone.soft,
      child: Stack(
        children: [
          Positioned(right: GxSpacing.lg, bottom: -GxSpacing.md, child: Icon(icon, size: GxSpacing.xxl * 2.5, color: faint)),
          Positioned(right: GxSpacing.xxl * 3, top: GxSpacing.md, child: Icon(icon, size: GxSpacing.xxl, color: faint)),
        ],
      ),
    );
  }
}
