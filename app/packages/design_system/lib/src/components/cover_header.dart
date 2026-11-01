import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/media.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/tones.dart';
import 'avatar.dart';
import 'network_image.dart';
import 'sections.dart';
import 'skeleton.dart';

/// Centered column for pages that read top to bottom ([GwLayout.contentMaxWidth];
/// the home page passes [GwLayout.feedMaxWidth]).
class GwReadingColumn extends StatelessWidget {
  const GwReadingColumn({super.key, required this.child, this.maxWidth = GwLayout.contentMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}

/// Edge of the hero avatar: 64 on phones, 96 from the reading width on.
GwAvatarSize gwHeroAvatarSize(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= GwLayout.contentMaxWidth ? GwAvatarSize.xl : GwAvatarSize.lg;

/// Cover proportion: 2:1 on phones, a little flatter from the reading width on.
double gwCoverAspectRatio(BuildContext context) => MediaQuery.sizeOf(context).width >= GwLayout.contentMaxWidth ? 2.5 : 2;

/// The identity card at the top of a profile or group page: a rounded card
/// with the cover inside it, the avatar beside the name (it never overlaps
/// the cover) and the page's own content ([children]) below.
class GwHeroCard extends StatelessWidget {
  const GwHeroCard({
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
  final GwAvatarShape shape;
  final String? coverUrl;
  final String? avatarUrl;

  /// Tone of the cover placeholder and the avatar fallback; defaults to the name's.
  final GwTone? tone;

  /// Drawn on the cover placeholder (e.g. the group's category).
  final IconData coverIcon;

  /// Next to the subtitle, e.g. a lock for private accounts.
  final Widget? subtitleTrailing;

  /// Bio, meta, stats and actions, separated by [GwSpacing.sm].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = tone ?? GwTone.of(name);
    final cover = coverUrl;
    final placeholder = _CoverPlaceholder(tone: palette, icon: coverIcon);
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, 0),
      child: GwCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: gwCoverAspectRatio(context),
              child: cover == null
                  ? placeholder
                  : LayoutBuilder(
                      builder: (context, constraints) => Image(
                        image: gwNetworkImage(cover, cacheWidth: gwCacheWidth(constraints.maxWidth, MediaQuery.devicePixelRatioOf(context))),
                        fit: BoxFit.cover,
                        semanticLabel: 'Kapak fotoğrafı',
                        errorBuilder: (_, _, _) => placeholder,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GwAvatar(name: name, shape: shape, imageUrl: avatarUrl, size: gwHeroAvatarSize(context), tone: palette),
                      const SizedBox(width: GwSpacing.md),
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
                                      style: textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary)),
                                ),
                                if (subtitleTrailing case final trailing?) ...[const SizedBox(width: GwSpacing.xxs), trailing],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  for (final child in children) ...[const SizedBox(height: GwSpacing.sm), child],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state of [GwHeroCard].
class GwHeroCardSkeleton extends StatelessWidget {
  const GwHeroCardSkeleton({super.key, required this.shape});

  final GwAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final size = gwHeroAvatarSize(context).dimension;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, 0),
      child: GwCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: gwCoverAspectRatio(context),
              child: const GwSkeleton(height: double.infinity, borderRadius: BorderRadius.zero),
            ),
            Padding(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Row(
                children: [
                  if (shape == GwAvatarShape.user)
                    GwSkeleton.circle(size: size)
                  else
                    GwSkeleton(width: size, height: size, borderRadius: BorderRadius.circular(size * GwRadius.lg / GwAvatarSize.lg.dimension)),
                  const SizedBox(width: GwSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GwSkeleton(width: GwSpacing.xxl * 3, height: GwSpacing.lg),
                        SizedBox(height: GwSpacing.xs),
                        GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.md),
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

  final GwTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final faint = tone.strong.withValues(alpha: 0.12);
    return ColoredBox(
      color: tone.soft,
      child: Stack(
        children: [
          Positioned(right: GwSpacing.lg, bottom: -GwSpacing.md, child: Icon(icon, size: GwSpacing.xxl * 2.5, color: faint)),
          Positioned(right: GwSpacing.xxl * 3, top: GwSpacing.md, child: Icon(icon, size: GwSpacing.xxl, color: faint)),
        ],
      ),
    );
  }
}
