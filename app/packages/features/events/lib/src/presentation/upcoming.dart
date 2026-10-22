import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import 'providers.dart';
import 'routes.dart';

/// "Yaklaşanlar" on the home page: the next organizations of the user's
/// groups as date cards, with a link to the calendar.
class UpcomingEventsSection extends ConsumerWidget {
  const UpcomingEventsSection({super.key, required this.onFindGroups});

  /// The empty state's action (the groups feature lives in the app).
  final VoidCallback onFindGroups;

  static const int _limit = 8;
  static const double _cardWidth = GxSpacing.xxl * 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Day precision keeps the provider key stable while the page rebuilds.
    final today = DateUtils.dateOnly(DateTime.now());
    final events = ref.watch(calendarProvider((
      from: today,
      to: today.add(const Duration(days: 60)),
      groupId: null,
      includeGroups: true,
    )));
    final now = DateTime.now();
    final upcoming = [
      for (final e in events.value ?? const <GroupEvent>[])
        if (!e.isCanceled && (e.endsAt ?? e.startsAt).isAfter(now)) e,
    ].take(_limit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GxSectionHeader(title: 'Yaklaşanlar', actionLabel: 'Takvim', onAction: () => context.go(EventRoutes.calendar)),
        switch (events) {
          AsyncData() when upcoming.isEmpty => Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
              child: _EmptyCard(onFindGroups: onFindGroups),
            ),
          AsyncData() => SizedBox(
              height: GxDateTile.size + GxSpacing.lg,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
                itemCount: upcoming.length,
                separatorBuilder: (_, _) => const SizedBox(width: GxSpacing.sm),
                itemBuilder: (context, i) => SizedBox(width: _cardWidth, child: _EventCard(event: upcoming[i])),
              ),
            ),
          AsyncError(:final error) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
              child: GxFormMessage(userMessageOf(error)),
            ),
          _ => const SizedBox(height: GxDateTile.size + GxSpacing.lg),
        },
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GxCard(
      radius: GxRadius.lgAll,
      padding: const EdgeInsets.all(GxSpacing.sm),
      onTap: () => context.push(EventRoutes.event(event.id)),
      child: Row(
        children: [
          GxDateTile(date: event.startsAt, tone: GxTone.of(event.group.id)),
          const SizedBox(width: GxSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                Text(
                  event.isMine ? 'Katılıyorsun · ${event.group.name}' : event.group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(color: event.isMine ? GxColors.primary : GxColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onFindGroups});

  final VoidCallback onFindGroups;

  @override
  Widget build(BuildContext context) => GxCard(
        radius: GxRadius.lgAll,
        padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.xs, GxSpacing.sm),
        child: Row(
          children: [
            const GxTag(label: 'Plan yok', icon: Icons.event_available_outlined),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Text(
                'Gruplarının yaklaşan organizasyonları burada görünür.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
              ),
            ),
            TextButton(onPressed: onFindGroups, child: const Text('Grup bul')),
          ],
        ),
      );
}
