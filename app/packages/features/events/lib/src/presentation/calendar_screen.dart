import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import '../l10n.dart';
import 'event_screens.dart';
import 'providers.dart';

enum CalendarView {
  day,
  week,
  month;

  String get label => switch (this) {
        day => eventsL10n.viewDay,
        week => eventsL10n.viewWeek,
        month => eventsL10n.viewMonth,
      };
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// The Monday of [d]'s week.
DateTime _monday(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// The local [from, to) a view of [focus] shows; a month shows whole weeks (at most 42 days).
({DateTime from, DateTime to}) calendarRange(CalendarView view, DateTime focus) => switch (view) {
      CalendarView.day => (from: _day(focus), to: DateTime(focus.year, focus.month, focus.day + 1)),
      CalendarView.week => (from: _monday(focus), to: DateTime(_monday(focus).year, _monday(focus).month, _monday(focus).day + 7)),
      CalendarView.month => () {
          final first = _monday(DateTime(focus.year, focus.month));
          final last = DateTime(focus.year, focus.month + 1, 0);
          return (from: first, to: DateTime(last.year, last.month, last.day + 8 - last.weekday));
        }(),
    };

/// The focus one step back or forward.
DateTime shiftFocus(CalendarView view, DateTime focus, int step) => switch (view) {
      CalendarView.day => DateTime(focus.year, focus.month, focus.day + step),
      CalendarView.week => DateTime(focus.year, focus.month, focus.day + 7 * step),
      CalendarView.month => DateTime(focus.year, focus.month + step),
    };

/// "Salı, 21 Ekim 2026", "20 – 26 Ekim 2026", "Ekim 2026".
String calendarTitle(CalendarView view, DateTime focus) {
  switch (view) {
    case CalendarView.day:
      return formatWeekdayDateYear(focus);
    case CalendarView.week:
      final from = _monday(focus);
      final to = DateTime(from.year, from.month, from.day + 6);
      return from.month == to.month ? '${from.day} – ${formatDate(to)}' : '${formatDate(from)} – ${formatDate(to)}';
    case CalendarView.month:
      return formatMonthYear(focus);
  }
}

/// "Takvimim" (no [groupId]) or a group's calendar (docs/ARCHITECTURE.md §3d, Takvim).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.groupId});

  final String? groupId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarView _view = CalendarView.month;
  DateTime _focus = _day(DateTime.now());
  bool _includeGroups = false;

  bool get _mine => widget.groupId == null;

  CalendarQuery get _query {
    final range = calendarRange(_view, _focus);
    return (from: range.from, to: range.to, groupId: widget.groupId, includeGroups: _mine && _includeGroups);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final query = _query;
    final events = ref.watch(calendarProvider(query));
    return Scaffold(
      appBar: AppBar(title: Text(_mine ? eventsL10n.myCalendar : eventsL10n.groupCalendar)),
      body: GwReadingColumn(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(calendarProvider(query).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, GwSpacing.xl),
            children: [
              Row(
                children: [
                  IconButton(tooltip: eventsL10n.previous, icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _focus = shiftFocus(_view, _focus, -1))),
                  Expanded(child: Text(calendarTitle(_view, _focus), textAlign: TextAlign.center, style: textTheme.titleMedium)),
                  IconButton(tooltip: eventsL10n.next, icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _focus = shiftFocus(_view, _focus, 1))),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<CalendarView>(
                      segments: [for (final v in CalendarView.values) ButtonSegment(value: v, label: Text(v.label))],
                      selected: {_view},
                      showSelectedIcon: false,
                      onSelectionChanged: (v) => setState(() => _view = v.single),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.xs),
                  TextButton(onPressed: () => setState(() => _focus = _day(DateTime.now())), child: Text(eventsL10n.today)),
                ],
              ),
              if (_mine)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _includeGroups,
                  onChanged: (v) => setState(() => _includeGroups = v),
                  title: Text(eventsL10n.groupsEvents),
                  subtitle: Text(eventsL10n.showNotJoined),
                ),
              const SizedBox(height: GwSpacing.xs),
              ...switch (events) {
                AsyncData(:final value) => _content(value),
                AsyncError(:final error) => [
                    GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(calendarProvider(query))),
                  ],
                _ => const [
                    GwSkeleton(height: GwSpacing.xxl * 5, borderRadius: GwRadius.lgAll),
                    SizedBox(height: GwSpacing.md),
                    GwSkeleton(height: GwSpacing.xxl * 1.5, borderRadius: GwRadius.lgAll),
                  ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(List<GroupEvent> events) {
    final conflicts = conflictingIds(events);
    final local = [for (final e in events) (day: _day(e.startsAt.toLocal()), event: e)];
    List<GroupEvent> on(DateTime day) => [for (final x in local) if (_sameDay(x.day, day)) x.event];

    Widget cards(List<GroupEvent> list) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final e in list) ...[EventCard(event: e, conflict: conflicts.contains(e.id)), const SizedBox(height: GwSpacing.xs)],
          ],
        );

    final empty = GwEmptyState(
      icon: Icons.event_busy_outlined,
      message: _mine && !_includeGroups
          ? eventsL10n.noJoinedInRange
          : eventsL10n.noEventsInRange,
      actionLabel: _mine && !_includeGroups ? eventsL10n.showGroupsEvents : eventsL10n.backToToday,
      onAction: () => setState(() => _mine && !_includeGroups ? _includeGroups = true : _focus = _day(DateTime.now())),
    );

    switch (_view) {
      case CalendarView.month:
        final selected = on(_focus);
        return [
          _MonthGrid(
            focus: _focus,
            marks: {for (final x in local) x.day: (local.where((y) => y.day == x.day).any((y) => y.event.isMine))},
            onSelect: (d) => setState(() => _focus = d),
          ),
          const SizedBox(height: GwSpacing.md),
          Text(formatWeekdayDateYear(_focus), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: GwSpacing.xs),
          if (selected.isEmpty)
            Text(eventsL10n.noEventsDay, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          else
            cards(selected),
        ];
      case CalendarView.week:
        if (events.isEmpty) return [empty];
        final monday = _monday(_focus);
        return [
          for (var i = 0; i < 7; i++)
            if (on(DateTime(monday.year, monday.month, monday.day + i)) case final list when list.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: GwSpacing.sm, bottom: GwSpacing.xs),
                child: Text(formatWeekdayDateYear(DateTime(monday.year, monday.month, monday.day + i)),
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              cards(list),
            ],
        ];
      case CalendarView.day:
        return events.isEmpty ? [empty] : [cards(events)];
    }
  }
}

/// A month of whole weeks; days with events carry a dot (filled for the user's own).
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.focus, required this.marks, required this.onSelect});

  final DateTime focus;

  /// Days with events; true when one of them is the user's own.
  final Map<DateTime, bool> marks;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final range = calendarRange(CalendarView.month, focus);
    final today = _day(DateTime.now());
    final days = [
      for (var d = range.from; d.isBefore(range.to); d = DateTime(d.year, d.month, d.day + 1)) d,
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final name in weekdayShortNames())
              Expanded(child: Text(name, textAlign: TextAlign.center, style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary))),
          ],
        ),
        const SizedBox(height: GwSpacing.xxs),
        for (var w = 0; w < days.length; w += 7)
          Row(
            children: [
              for (final d in days.sublist(w, w + 7))
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: _sameDay(d, focus),
                    label: formatDate(d),
                    child: InkWell(
                      borderRadius: GwRadius.mdAll,
                      onTap: () => onSelect(d),
                      child: Container(
                        height: GwSpacing.minTouchTarget + GwSpacing.xs,
                        decoration: BoxDecoration(
                          color: _sameDay(d, focus) ? GwColors.primarySoft : null,
                          borderRadius: GwRadius.mdAll,
                          border: _sameDay(d, today) ? Border.all(color: GwColors.primary) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${d.day}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: d.month == focus.month ? GwColors.textPrimary : GwColors.textSecondary,
                                fontWeight: _sameDay(d, focus) ? FontWeight.w700 : null,
                              ),
                            ),
                            const SizedBox(height: GwSpacing.xxs),
                            SizedBox(
                              height: GwSpacing.xs,
                              width: GwSpacing.xs,
                              child: switch (marks[d]) {
                                true => const DecoratedBox(decoration: BoxDecoration(color: GwColors.primary, shape: BoxShape.circle)),
                                false => DecoratedBox(
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: GwColors.secondary)),
                                  ),
                                null => null,
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
