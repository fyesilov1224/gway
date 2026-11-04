import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import 'providers.dart';
import 'routes.dart';

const _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

/// "Yaklaşanlar" (from the create sheet): the next 60 days of the user's groups, day by day,
/// with a filter for the ones the user joined.
class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({super.key, required this.onFindGroups});

  /// The empty state's action (the groups feature lives in the app).
  final VoidCallback onFindGroups;

  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  bool _mineOnly = false;

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(calendarProvider(upcomingQuery()));
    final now = DateTime.now();
    final all = [
      for (final e in events.value ?? const <GroupEvent>[])
        if (!e.isCanceled && (e.endsAt ?? e.startsAt).isAfter(now)) e,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final mine = all.where((e) => e.isMine).length;
    final shown = _mineOnly ? [for (final e in all) if (e.isMine) e] : all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yaklaşanlar'),
        actions: [
          IconButton(
            tooltip: 'Takvim',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.go(EventRoutes.calendar),
          ),
        ],
      ),
      body: GwReadingColumn(
        child: switch (events) {
          AsyncError(:final error) when !events.hasValue =>
            GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(calendarProvider)),
          _ when !events.hasValue => const _UpcomingSkeleton(),
          _ => RefreshIndicator(
              onRefresh: () async => ref.invalidate(calendarProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, GwSpacing.xl),
                children: [
                  _Filters(all: all.length, mine: mine, mineOnly: _mineOnly, onChanged: (v) => setState(() => _mineOnly = v)),
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: GwSpacing.xl),
                      child: _mineOnly
                          ? GwEmptyState(
                              icon: Icons.event_available_outlined,
                              message: 'Katıldığın yaklaşan bir organizasyon yok.',
                              actionLabel: 'Tümünü göster',
                              onAction: () => setState(() => _mineOnly = false),
                            )
                          : GwEmptyState(
                              icon: Icons.event_available_outlined,
                              message: 'Önümüzdeki 60 günde gruplarının organizasyonu yok.',
                              actionLabel: 'Grup bul',
                              onAction: widget.onFindGroups,
                            ),
                    )
                  else
                    for (final day in _byDay(shown)) _DayGroup(day: day.day, events: day.events, today: now),
                ],
              ),
            ),
        },
      ),
    );
  }

  static List<({DateTime day, List<GroupEvent> events})> _byDay(List<GroupEvent> events) {
    final days = <({DateTime day, List<GroupEvent> events})>[];
    for (final e in events) {
      final day = DateUtils.dateOnly(e.startsAt.toLocal());
      if (days.isNotEmpty && days.last.day == day) {
        days.last.events.add(e);
      } else {
        days.add((day: day, events: [e]));
      }
    }
    return days;
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.all, required this.mine, required this.mineOnly, required this.onChanged});

  final int all;
  final int mine;
  final bool mineOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: GwSpacing.xs),
        child: Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          children: [
            ChoiceChip(label: Text('Tümü · ${formatCount(all)}'), selected: !mineOnly, onSelected: (_) => onChanged(false)),
            ChoiceChip(label: Text('Katıldıklarım · ${formatCount(mine)}'), selected: mineOnly, onSelected: (_) => onChanged(true)),
          ],
        ),
      );
}

/// One day: "Yarın  2 Kasım" over a card of its events.
class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.events, required this.today});

  final DateTime day;
  final List<GroupEvent> events;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = formatDate(day);
    final label = switch (day.difference(DateUtils.dateOnly(today)).inDays) {
      0 => 'Bugün',
      1 => 'Yarın',
      _ => _weekdays[day.weekday - 1],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.xxs, GwSpacing.md, GwSpacing.xxs, GwSpacing.xs),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: label, style: textTheme.titleSmall),
              TextSpan(
                text: '  ${date.substring(0, date.lastIndexOf(' '))}',
                style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary),
              ),
            ]),
          ),
        ),
        GwCard(
          radius: GwRadius.lgAll,
          child: Column(
            children: [
              for (final (i, e) in events.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                _UpcomingTile(event: e),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Time, title, group, place, the user's status and the head count.
class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.event});

  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final tone = GwTone.of(event.group.id);
    final status = switch (event.myStatus) {
      AttendanceStatus.going => const GwTag(label: 'Katılıyorsun', icon: Icons.check_rounded),
      AttendanceStatus.waitlisted => const GwTag(label: 'Yedek listede', icon: Icons.hourglass_empty_rounded, tone: GwTone.mist),
      AttendanceStatus.requested => const GwTag(label: 'Onay bekliyor', icon: Icons.schedule_rounded, tone: GwTone.mist),
      null when event.isFull => const GwTag(label: 'Dolu', tone: GwTone.mist),
      null => null,
    };
    final capacity = event.capacity;
    return InkWell(
      onTap: () => context.push(EventRoutes.event(event.id)),
      child: Padding(
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: GwDateTile.size,
              padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
              decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
              child: Text(
                _time(event.startsAt.toLocal()),
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                style: textTheme.labelLarge?.copyWith(color: tone.strong, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                  const SizedBox(height: GwSpacing.xxs),
                  Text(
                    event.group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(color: GwColors.primary),
                  ),
                  if (event.place.isNotEmpty) Text(event.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
                  const SizedBox(height: GwSpacing.xs),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ?status,
                      Text(
                        capacity == null
                            ? '${formatCount(event.goingCount)} katılımcı'
                            : '${formatCount(event.goingCount)}/${formatCount(capacity)} katılımcı',
                        style: secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: GwColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSkeleton extends StatelessWidget {
  const _UpcomingSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(GwSpacing.page),
        child: Column(children: [
          GwSkeleton(height: GwSpacing.xl, borderRadius: GwRadius.xlAll),
          SizedBox(height: GwSpacing.md),
          GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll),
          SizedBox(height: GwSpacing.md),
          GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll),
        ]),
      );
}

/// "Yakında başlıyor": events starting in the next 6 hours, the user's groups first, then nearby groups
/// (docs/ARCHITECTURE.md §3d). Nothing is shown when nothing starts soon.
class StartingSoonSection extends ConsumerWidget {
  const StartingSoonSection({super.key});

  static const double _cardWidth = GwSpacing.xxl * 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soon = ref.watch(startingSoonProvider).value ?? const <GroupEvent>[];
    if (soon.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GwSectionHeader(title: 'Yakında başlıyor', subtitle: 'Önümüzdeki 6 saat'),
        SizedBox(
          height: GwDateTile.size + GwSpacing.lg,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
            itemCount: soon.length,
            separatorBuilder: (_, _) => const SizedBox(width: GwSpacing.sm),
            itemBuilder: (context, i) => SizedBox(width: _cardWidth, child: _EventCard(event: soon[i], showTime: true)),
          ),
        ),
      ],
    );
  }
}

String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.showTime = false});

  final GroupEvent event;

  /// "19:30 · group" instead of the day, for what starts within hours.
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      radius: GwRadius.lgAll,
      padding: const EdgeInsets.all(GwSpacing.sm),
      onTap: () => context.push(EventRoutes.event(event.id)),
      child: Row(
        children: [
          GwDateTile(date: event.startsAt, tone: GwTone.of(event.group.id)),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                Text(
                  [
                    if (showTime) _time(event.startsAt.toLocal()),
                    if (event.isMine) 'Katılıyorsun',
                    event.group.name,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(color: event.isMine ? GwColors.primary : GwColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
