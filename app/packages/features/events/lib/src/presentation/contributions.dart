import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import 'providers.dart';

/// "12 katılım · 3 düzenleme · 5 anı"; empty parts are left out.
String contributionLine(Contributions c) => [
      if (c.attended > 0) '${formatCount(c.attended)} katılım',
      if (c.organized > 0) '${formatCount(c.organized)} düzenleme',
      if (c.memories > 0) '${formatCount(c.memories)} anı',
      if (c.reviews > 0) '${formatCount(c.reviews)} değerlendirme',
      if (c.welcomed > 0) '${formatCount(c.welcomed)} karşılama',
    ].join(' · ');

/// A member's line in a group's list: "12 katılım · 2 düzenleme".
String? groupContributionLine(({int attended, int organized})? c) => c == null
    ? null
    : [
        if (c.attended > 0) '${formatCount(c.attended)} katılım',
        if (c.organized > 0) '${formatCount(c.organized)} düzenleme',
      ].join(' · ');

/// Contributions and badges on a profile (docs/ARCHITECTURE.md §3d, Katkı ve rozetler); nothing when private.
class ContributionsSection extends ConsumerWidget {
  const ContributionsSection({super.key, required this.userId, required this.isOwn});

  final String userId;
  final bool isOwn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(contributionsProvider(userId)).value;
    if (c == null || (c.isEmpty && !isOwn)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.md, GxSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Topluluk katkısı', style: textTheme.titleLarge)),
              TextButton(onPressed: () => showBadgeGuide(context), child: const Text('Rozetler nasıl kazanılır?')),
            ],
          ),
          Text(
            c.isEmpty ? 'Bir organizasyona katıldığında katkın ve ilk rozetin burada görünür.' : contributionLine(c),
            style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
          ),
          if (c.badges.isNotEmpty) ...[
            const SizedBox(height: GxSpacing.xs),
            Wrap(
              spacing: GxSpacing.xs,
              runSpacing: GxSpacing.xs,
              children: [
                for (final b in c.badges)
                  Tooltip(message: b.description, child: GxBadge(b.name, tone: GxBadgeTone.primary, dot: true)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Every badge and what it takes; the rules come from the server's catalog.
Future<void> showBadgeGuide(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _BadgeGuide(),
    );

class _BadgeGuide extends ConsumerWidget {
  const _BadgeGuide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(badgeCatalogProvider);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg),
      children: [
        Text('Rozetler nasıl kazanılır?', style: textTheme.titleLarge),
        const SizedBox(height: GxSpacing.xs),
        Text(
          'Rozetler yalnızca gerçekten yaptıklarından hesaplanır: katıldığın ve düzenlediğin organizasyonlar, '
          'paylaştığın anılar ve değerlendirmelerin. Beğeni ve takipçi sayısı sayılmaz. Düzenleyenin "gelmedi" '
          'olarak işaretlediği katılımlar sayılmaz. Kimse sıralanmaz.',
          style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
        ),
        const SizedBox(height: GxSpacing.sm),
        ...switch (catalog) {
          AsyncData(:final value) => [
              for (final b in value)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined, color: GxColors.primary),
                  title: Text(b.slug == 'category' ? 'Kategori tutkunu' : b.name),
                  subtitle: Text(b.description),
                ),
            ],
          AsyncError(:final error) => [Text(userMessageOf(error))],
          _ => const [GxSkeleton(height: GxSpacing.xxl * 3)],
        },
      ],
    );
  }
}
