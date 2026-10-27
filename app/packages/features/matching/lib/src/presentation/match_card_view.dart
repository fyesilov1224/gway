import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/matching.dart';

/// One person in the deck, the whole card a photo (docs/ARCHITECTURE.md §3g, Kart): tap the sides
/// to step through the photos; name, age, city, shared groups and interests sit on the photo.
class MatchCardView extends ConsumerStatefulWidget {
  const MatchCardView({super.key, required this.card, this.stamp, this.stampStrength = 0, this.onMenu, this.onInfo});

  final MatchCard card;

  /// What the drag will do, shown as a stamp; null shows none.
  final SwipeKind? stamp;

  /// 0–1: how sure the drag is.
  final double stampStrength;

  /// Report and block; null hides the menu.
  final void Function(BuildContext context, int photoIndex)? onMenu;

  /// Opens the whole profile; null hides the button.
  final VoidCallback? onInfo;

  @override
  ConsumerState<MatchCardView> createState() => _MatchCardViewState();
}

class _MatchCardViewState extends ConsumerState<MatchCardView> {
  int _photo = 0;

  void _step(int by) {
    final count = widget.card.photoUrls.length;
    if (count == 0) return;
    setState(() => _photo = (_photo + by).clamp(0, count - 1));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    final textTheme = Theme.of(context).textTheme;
    final names = categoryNames(ref);
    final interests = sortedInterests(c);
    final onMedia = textTheme.bodyMedium?.copyWith(color: GxColors.onMedia);

    return ClipRRect(
      borderRadius: GxRadius.xlAll,
      child: ColoredBox(
        color: GxColors.media,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (c.photoUrls.isNotEmpty)
              Image.network(
                c.photoUrls[_photo],
                key: ValueKey(c.photoUrls[_photo]),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                semanticLabel: '${c.displayName}, fotoğraf ${_photo + 1}',
                errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted),
              ),
            // Left and right halves step through the photos.
            Row(
              children: [
                Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _step(-1))),
                Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _step(1))),
              ],
            ),
            if (c.photoUrls.length > 1)
              Positioned(
                top: GxSpacing.xs,
                left: GxSpacing.xs,
                right: GxSpacing.xs,
                child: Row(
                  children: [
                    for (var i = 0; i < c.photoUrls.length; i++)
                      Expanded(
                        child: Container(
                          height: GxSpacing.xxs,
                          margin: const EdgeInsets.symmetric(horizontal: GxSpacing.xxs / 2),
                          decoration: BoxDecoration(
                            color: i == _photo ? GxColors.onMedia : GxColors.onMedia.withValues(alpha: 0.4),
                            borderRadius: GxRadius.smAll,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (c.superLikedMe)
              const Positioned(
                top: GxSpacing.lg,
                left: GxSpacing.sm,
                child: _Pill(icon: Icons.star_rounded, label: 'Seni süper beğendi', color: GxColors.secondary),
              ),
            if (widget.onMenu != null)
              Positioned(
                top: GxSpacing.sm,
                right: GxSpacing.xxs,
                child: IconButton(
                  tooltip: 'Seçenekler',
                  color: GxColors.onMedia,
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => widget.onMenu!(context, _photo),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, GxColors.mediaScrim, GxColors.media],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.xxl, GxSpacing.xs, GxSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IgnorePointer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: c.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  TextSpan(text: '  ${c.age}', style: const TextStyle(fontWeight: FontWeight.w400)),
                                ]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineMedium?.copyWith(color: GxColors.onMedia),
                              ),
                              const SizedBox(height: GxSpacing.xxs),
                              if (c.job.isNotEmpty) _Line(icon: Icons.work_outline, text: c.job, style: onMedia),
                              if (c.provinceLabel.isNotEmpty) _Line(icon: Icons.location_on_outlined, text: c.provinceLabel, style: onMedia),
                              if (c.sharedGroups.isNotEmpty) _Line(icon: Icons.groups_2_outlined, text: c.sharedGroupsLine, style: onMedia),
                              if (interests.isNotEmpty) ...[
                                const SizedBox(height: GxSpacing.xs),
                                Wrap(
                                  spacing: GxSpacing.xxs,
                                  runSpacing: GxSpacing.xxs,
                                  children: [
                                    for (final slug in interests.take(3))
                                      _Pill(
                                        icon: c.sharedInterests.contains(slug) ? Icons.favorite_rounded : null,
                                        label: names[slug] ?? slug,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (widget.onInfo != null)
                        IconButton(
                          tooltip: 'Profilin tamamı',
                          color: GxColors.onMedia,
                          icon: const Icon(Icons.info_outline_rounded),
                          onPressed: widget.onInfo,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.stamp case final stamp? when widget.stampStrength > 0)
              _Stamp(kind: stamp, strength: widget.stampStrength),
          ],
        ),
      ),
    );
  }
}

/// Category names by slug, for interest tags.
Map<String, String> categoryNames(WidgetRef ref) =>
    {for (final cat in ref.watch(categoriesProvider).value ?? const <Category>[]) cat.slug: cat.name};

/// Interests with the shared ones first.
List<String> sortedInterests(MatchCard c) =>
    [...c.interests]..sort((a, b) => (c.sharedInterests.contains(a) ? 0 : 1) - (c.sharedInterests.contains(b) ? 0 : 1));

/// The colour each swipe stands for, everywhere in the deck.
Color swipeColor(SwipeKind kind) => switch (kind) {
      SwipeKind.pass => GxColors.error,
      SwipeKind.like => GxColors.success,
      SwipeKind.superLike => GxColors.secondary,
    };

class _Stamp extends StatelessWidget {
  const _Stamp({required this.kind, required this.strength});

  final SwipeKind kind;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final color = swipeColor(kind);
    final (label, alignment, angle) = switch (kind) {
      SwipeKind.like => ('BEĞEN', const Alignment(-0.7, -0.7), -0.25),
      SwipeKind.pass => ('GEÇ', const Alignment(0.7, -0.7), 0.25),
      SwipeKind.superLike => ('SÜPER', const Alignment(0, 0.3), 0.0),
    };
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: strength.clamp(0, 1),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xxs),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: GxSpacing.xxs),
                borderRadius: GxRadius.mdAll,
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: GxSpacing.xxs / 2),
        child: Row(
          children: [
            Icon(icon, size: GxSpacing.md, color: GxColors.onMedia),
            const SizedBox(width: GxSpacing.xxs),
            Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          ],
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;

  /// A solid pill; null is a translucent one on the photo.
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs),
        decoration: BoxDecoration(
          color: color ?? GxColors.onMedia.withValues(alpha: 0.2),
          borderRadius: GxRadius.lgAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: GxSpacing.sm + GxSpacing.xxs / 2, color: GxColors.onMedia),
              const SizedBox(width: GxSpacing.xxs),
            ],
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GxColors.onMedia)),
          ],
        ),
      );
}

/// The whole profile in a sheet: every photo, about, details, interests and shared groups.
/// [actions] (e.g. like and pass for an admirer) sit at the bottom.
Future<void> showMatchDetails(BuildContext context, MatchCard card, {List<Widget> actions = const []}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            Expanded(child: _Details(card: card, controller: controller)),
            if (actions.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(GxSpacing.md),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: actions),
                ),
              ),
          ],
        ),
      ),
    );

class _Details extends ConsumerWidget {
  const _Details({required this.card, required this.controller});

  final MatchCard card;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = card;
    final textTheme = Theme.of(context).textTheme;
    final names = categoryNames(ref);
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(top: GxSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: textTheme.titleSmall), const SizedBox(height: GxSpacing.xs), child],
          ),
        );

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg),
      children: [
        for (final url in c.photoUrls)
          Padding(
            padding: const EdgeInsets.only(bottom: GxSpacing.xs),
            child: ClipRRect(
              borderRadius: GxRadius.lgAll,
              child: AspectRatio(
                aspectRatio: GxMedia.portrait,
                child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted)),
              ),
            ),
          ),
        const SizedBox(height: GxSpacing.xs),
        Text('${c.displayName}, ${c.age}', style: textTheme.headlineSmall),
        if (c.superLikedMe)
          Padding(
            padding: const EdgeInsets.only(top: GxSpacing.xxs),
            child: Row(children: [
              const Icon(Icons.star_rounded, size: GxSpacing.md, color: GxColors.secondary),
              const SizedBox(width: GxSpacing.xxs),
              Text('Seni süper beğendi', style: textTheme.labelLarge?.copyWith(color: GxColors.secondary)),
            ]),
          ),
        const SizedBox(height: GxSpacing.xs),
        for (final (icon, text) in [
          if (c.job.isNotEmpty) (Icons.work_outline, c.job),
          if (c.education.isNotEmpty) (Icons.school_outlined, c.education),
          if (c.provinceLabel.isNotEmpty) (Icons.location_on_outlined, c.provinceLabel),
          (Icons.person_outline, c.gender.label),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: GxSpacing.xxs),
            child: Row(children: [
              Icon(icon, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
              const SizedBox(width: GxSpacing.xs),
              Expanded(child: Text(text, style: secondary)),
            ]),
          ),
        if (c.about.isNotEmpty) section('Hakkında', Text(c.about, style: textTheme.bodyLarge)),
        if (c.interests.isNotEmpty)
          section(
            'İlgi alanları',
            Wrap(
              spacing: GxSpacing.xs,
              runSpacing: GxSpacing.xs,
              children: [
                for (final slug in sortedInterests(c))
                  GxTag(
                    label: names[slug] ?? slug,
                    icon: c.sharedInterests.contains(slug) ? Icons.favorite_rounded : null,
                    tone: c.sharedInterests.contains(slug) ? GxTone.lilac : GxTone.mist,
                  ),
              ],
            ),
          ),
        if (c.sharedGroups.isNotEmpty)
          section(
            'Ortak gruplarınız',
            Column(
              children: [
                for (final g in c.sharedGroups)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: GxAvatar(name: g.name, shape: GxAvatarShape.group),
                    title: Text(g.name),
                    subtitle: Text('@${g.handle}'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
