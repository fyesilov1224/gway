import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import '../l10n.dart';
import 'providers.dart';

/// "12 katılım · 3 düzenleme · 5 anı"; empty parts are left out.
String contributionLine(Contributions c) => [
      if (c.attended > 0) eventsL10n.countAttended(c.attended),
      if (c.organized > 0) eventsL10n.countOrganized(c.organized),
      if (c.memories > 0) eventsL10n.countMemories(c.memories),
      if (c.reviews > 0) eventsL10n.countReviews(c.reviews),
      if (c.welcomed > 0) eventsL10n.countWelcomed(c.welcomed),
      if (c.handshakes > 0) eventsL10n.countHandshakes(c.handshakes),
    ].join(' · ');

/// A member's line in a group's list: "12 katılım · 2 düzenleme".
String? groupContributionLine(({int attended, int organized})? c) => c == null
    ? null
    : [
        if (c.attended > 0) eventsL10n.countAttended(c.attended),
        if (c.organized > 0) eventsL10n.countOrganized(c.organized),
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
      padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.sm, GwSpacing.md, GwSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(eventsL10n.contributions, style: textTheme.titleLarge)),
              TextButton(onPressed: () => showBadgeGuide(context), child: Text(eventsL10n.howBadges)),
            ],
          ),
          Text(
            c.isEmpty ? eventsL10n.badgesEmpty : contributionLine(c),
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          if (c.badges.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final b in c.badges)
                  Tooltip(message: b.description, child: GwBadge(b.name, tone: GwBadgeTone.primary, dot: true)),
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
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg),
      children: [
        Text(eventsL10n.howBadges, style: textTheme.titleLarge),
        const SizedBox(height: GwSpacing.xs),
        Text(
          eventsL10n.badgesRules,
          style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
        ),
        const SizedBox(height: GwSpacing.sm),
        ...switch (catalog) {
          AsyncData(:final value) => [
              for (final b in value)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined, color: GwColors.primary),
                  title: Text(b.slug == 'category' ? eventsL10n.categoryFan : b.name),
                  subtitle: Text(b.description),
                ),
            ],
          AsyncError(:final error) => [Text(userMessageOf(error))],
          _ => const [GwSkeleton(height: GwSpacing.xxl * 3)],
        },
      ],
    );
  }
}
