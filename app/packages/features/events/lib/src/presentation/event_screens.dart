import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/events.dart';
import '../domain/handshakes.dart';
import '../l10n.dart';
import 'handshake.dart';
import 'map_screens.dart';
import 'polls.dart';
import 'providers.dart';
import 'routes.dart';
import 'story_cards.dart';
import 'welcome.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));

/// `25 Ekim 2026 Cumartesi · 09:00–13:00` in the app language.
String eventWhen(GroupEvent e) {
  final s = e.startsAt.toLocal();
  final end = e.endsAt?.toLocal();
  final sameDay = end != null && end.year == s.year && end.month == s.month && end.day == s.day;
  final until = end == null ? '' : sameDay ? '–${formatTime(end)}' : ' – ${formatDateTime(end)}';
  return '${formatWeekdayDateYear(s)} · ${formatTime(s)}$until';
}

/// `EKİ` / `OCT`: the month on a calendar sheet.
String _shortMonth(DateTime d) => DateFormat.MMM(currentAppLanguage.code).format(d).replaceAll('.', '').toUpperCase();

/// "Kask, Su ,, Mont" → ["Kask", "Su", "Mont"].
List<String> equipmentItems(String text) => [for (final i in text.split(',')) if (i.trim().isNotEmpty) i.trim()];

/// "12 / 20 kişi", "12 kişi katılıyor".
String eventSeats(GroupEvent e) => e.capacity == null
    ? eventsL10n.seatsGoing(e.goingCount)
    : e.waitlistCount > 0
        ? eventsL10n.seatsOfWaiting(e.goingCount, e.capacity!, e.waitlistCount)
        : eventsL10n.seatsOf(e.goingCount, e.capacity!);

/// Profiles, groups and posts are other features; the app opens and shows them.
class EventLinks {
  const EventLinks({required this.openGroup, required this.openProfile, this.shareMemory, this.memories});

  final void Function(BuildContext context, String handle) openGroup;
  final void Function(BuildContext context, String username) openProfile;

  /// Opens the post composer for a memory of the event.
  final void Function(BuildContext context, String eventId)? shareMemory;

  /// The event's memories (posts), shown on the event page.
  final Widget Function(BuildContext context, String eventId)? memories;
}

/// "18 kişi katıldı · 4,6 ★ (8 değerlendirme) · 12 anı".
String eventSummary(GroupEvent e) => [
      eventsL10n.summaryAttended(e.goingCount),
      if (e.ratingAvg case final avg?) eventsL10n.summaryRating(ratingLabel(avg), e.ratingCount),
      if (e.postsCount > 0) eventsL10n.countMemories(e.postsCount),
    ].join(' · ');

/// Day and month block, like a calendar sheet.
class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date, this.muted = false});

  final DateTime date;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final d = date.toLocal();
    final textTheme = Theme.of(context).textTheme;
    final color = muted ? GwColors.textSecondary : GwColors.primary;
    return Container(
      width: GwSpacing.xxl + GwSpacing.xxs,
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
      decoration: BoxDecoration(color: muted ? GwColors.surfaceMuted : GwColors.primarySoft, borderRadius: GwRadius.mdAll),
      child: Column(
        children: [
          Text(_shortMonth(d), style: textTheme.labelSmall?.copyWith(color: color)),
          Text('${d.day}', style: textTheme.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.event});

  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final e = event;
    if (e.isCanceled) return GwBadge(eventsL10n.canceled, tone: GwBadgeTone.danger);
    return switch (e.myStatus) {
      AttendanceStatus.requested => GwBadge(eventsL10n.awaitingApproval, tone: GwBadgeTone.warning),
      AttendanceStatus.going => GwBadge(eventsL10n.going, dot: true, tone: GwBadgeTone.primary),
      AttendanceStatus.waitlisted => GwBadge(eventsL10n.waitlistPlace(e.myPlace ?? 0), tone: GwBadgeTone.info),
      null when e.isFull && !e.hasStarted(DateTime.now()) => GwBadge(eventsL10n.full, tone: GwBadgeTone.neutral),
      null => const SizedBox.shrink(),
    };
  }
}

/// An upcoming event in a list.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.conflict = false});

  final GroupEvent event;

  /// Overlaps another of the user's events (calendar).
  final bool conflict;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: GwRadius.lgAll,
      onTap: () => context.push(EventRoutes.event(e.id)),
      child: Container(
        padding: const EdgeInsets.all(GwSpacing.sm),
        decoration: const BoxDecoration(
          color: GwColors.background,
          borderRadius: GwRadius.lgAll,
          border: Border.fromBorderSide(GwBorders.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBlock(date: e.startsAt, muted: e.isCanceled),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(decoration: e.isCanceled ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: GwSpacing.xxs),
                  Text(eventWhen(e), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                  Text(e.place, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                  const SizedBox(height: GwSpacing.xs),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(eventSeats(e), style: textTheme.labelMedium),
                      if (e.fee != null) GwBadge(e.fee!.label),
                      _StatusBadge(event: e),
                      if (conflict) GwBadge(eventsL10n.conflicting, tone: GwBadgeTone.warning),
                    ],
                  ),
                ],
              ),
            ),
            if (e.coverUrl != null) ...[
              const SizedBox(width: GwSpacing.sm),
              ClipRRect(
                borderRadius: GwRadius.mdAll,
                child: Image(
                  image: gwNetworkImage(e.coverUrl!, cacheWidth: gwCacheWidth(GwSpacing.xxl * 1.5, MediaQuery.devicePixelRatioOf(context))),
                  width: GwSpacing.xxl * 1.5,
                  height: GwSpacing.xxl * 1.5,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Upcoming events on the group page, with "Organizasyon oluştur" for managers.
class GroupEventsSection extends ConsumerWidget {
  const GroupEventsSection({super.key, required this.groupId, required this.canManage});

  final String groupId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(groupEventsProvider(groupId)).value;
    if (data == null || (data.events.isEmpty && data.toReview.isEmpty && data.ratingAvg == null && !canManage)) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;
    final left = data.eventsLeft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(eventsL10n.events, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleLarge)),
              IconButton(
                tooltip: eventsL10n.pastEvents,
                onPressed: () => context.push(EventRoutes.history(groupId)),
                icon: const Icon(Icons.history_rounded),
              ),
              IconButton(
                tooltip: eventsL10n.groupCalendar,
                onPressed: () => context.push(EventRoutes.groupCalendar(groupId)),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: left == 0 ? null : () => context.push(EventRoutes.create(groupId)),
                  icon: const Icon(Icons.event_available_outlined, size: GwSpacing.md + GwSpacing.xxs),
                  label: Text(eventsL10n.create),
                ),
            ],
          ),
          if (canManage && left != null)
            Text(
              left > 0 ? eventsL10n.eventsLeft(left) : eventsL10n.eventsLimitReached,
              style: textTheme.bodySmall?.copyWith(color: left > 0 ? GwColors.textSecondary : GwColors.error),
            ),
          if (data.ratingAvg case final avg?)
            Row(
              children: [
                const Icon(Icons.star_rounded, color: GwColors.primary, size: GwSpacing.md + GwSpacing.xxs),
                const SizedBox(width: GwSpacing.xxs),
                Expanded(
                  child: Text(
                    eventsL10n.groupRating(ratingLabel(avg), data.ratingCount),
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                  ),
                ),
              ],
            ),
          if (data.toReview.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.sm),
            Text(eventsL10n.howWasIt, style: textTheme.titleSmall),
            Text(eventsL10n.howWasItHint,
                style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            for (final e in data.toReview) ...[
              const SizedBox(height: GwSpacing.xs),
              _ReviewBox(key: ValueKey(e.id), event: e, mine: null, title: eventsL10n.titleOnDate(e.title, formatDate(e.startsAt.toLocal()))),
            ],
            const SizedBox(height: GwSpacing.sm),
          ],
          const SizedBox(height: GwSpacing.xs),
          if (data.events.isEmpty)
            Text(eventsL10n.eventsEmpty,
                style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          else
            for (final e in data.events) ...[EventCard(event: e), const SizedBox(height: GwSpacing.xs)],
        ],
      ),
    );
  }
}

/// One event: details, fee information, seats, attendees, its polls; join or leave.
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key, required this.eventId, required this.links});

  final String eventId;
  final EventLinks links;

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  bool _busy = false;

  Future<void> _run(Future<Result<void>> Function(EventsRepository repo) action, {String? done}) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        if (done != null) _snack(context, done);
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
    ref.invalidate(eventDetailProvider(widget.eventId));
  }

  Future<void> _attend(EventDetail d) async {
    final e = d.event;
    setState(() => _busy = true);
    final result = await ref.read(eventsRepositoryProvider).attend(e.id);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        _snack(
          context,
          switch (value.status) {
            AttendanceStatus.requested => eventsL10n.requestSent,
            AttendanceStatus.going => eventsL10n.attendanceSaved,
            AttendanceStatus.waitlisted => eventsL10n.waitlistJoined(value.place ?? 0),
          },
        );
        if (d.conflicts.isNotEmpty) await _offerToFreeConflicts(d.conflicts);
        if (!mounted) return;
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
    ref
      ..invalidate(eventDetailProvider(widget.eventId))
      ..invalidate(groupEventsProvider(e.group.id));
  }

  /// The choice stays with the user; nothing is left automatically (docs/ARCHITECTURE.md §3b).
  Future<void> _offerToFreeConflicts(List<EventConflict> conflicts) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eventsL10n.conflictTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final c in conflicts) Text(eventsL10n.conflictLine(c.title, formatDateTime(c.startsAt.toLocal()))),
            const SizedBox(height: GwSpacing.sm),
            Text(
              conflicts.length == 1
                  ? eventsL10n.conflictOne
                  : eventsL10n.conflictMany,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(eventsL10n.keepBoth)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(conflicts.length == 1 ? eventsL10n.leaveOther : eventsL10n.leaveOthers),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    final repo = ref.read(eventsRepositoryProvider);
    final results = [for (final c in conflicts) await repo.leave(c.id)];
    if (!mounted) return;
    for (final c in conflicts) {
      ref.invalidate(eventDetailProvider(c.id));
    }
    ref.invalidate(eventDetailProvider(widget.eventId));
    _snack(
      context,
      switch (results.whereType<Err<void>>().firstOrNull) {
        Err(:final failure) => failure.userMessage,
        _ => conflicts.length == 1 ? eventsL10n.leftOther : eventsL10n.leftOthers,
      },
    );
  }

  Future<void> _decide(GroupEvent e, EventPerson person, {required bool approve}) async {
    await _run(
      (r) => r.decideRequest(e.id, person.id, approve: approve),
      done: approve ? eventsL10n.approvedPerson(person.displayName) : eventsL10n.declinedPerson(person.displayName),
    );
    ref.invalidate(groupEventsProvider(e.group.id));
  }

  Future<void> _addToCalendar(GroupEvent e) async {
    final opened = await launchUrl(ref.read(eventsRepositoryProvider).calendarUrl(e.id), mode: LaunchMode.externalApplication);
    if (!opened && mounted) _snack(context, eventsL10n.calendarFailed);
  }

  Future<void> _stopSeries(GroupEvent e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(eventsL10n.stopSeriesTitle),
        content: Text(eventsL10n.stopSeriesBody),
        actions: [
          GwButton(label: eventsL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: eventsL10n.stop, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (ok != true) return;
    await _run((r) => r.stopSeries(e.series!.id), done: eventsL10n.seriesStopped);
  }

  Future<void> _cancel(GroupEvent e) async {
    final text = await showDialog<String>(context: context, builder: (_) => const _CancelDialog());
    if (text == null) return;
    await _run((r) => r.cancel(e.id, reason: text), done: eventsL10n.eventCanceledToast);
    ref.invalidate(groupEventsProvider(e.group.id));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(eventDetailProvider(widget.eventId));
    return switch (detail) {
      AsyncData(:final value) => _content(value),
      AsyncError(error: NotFoundFailure()) => Scaffold(
          appBar: AppBar(),
          body: GwEmptyState(
            icon: Icons.event_busy_outlined,
            message: eventsL10n.eventNotFound,
            actionLabel: eventsL10n.goBack,
            onAction: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId))),
        ),
      _ => Scaffold(
          appBar: AppBar(),
          body: const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: Column(children: [
              GwSkeleton(height: GwSpacing.xxl * 4, borderRadius: GwRadius.lgAll),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xl),
            ]),
          ),
        ),
    };
  }

  Widget _content(EventDetail d) {
    final e = d.event;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final open = e.isOpen(now);

    Widget row(IconData icon, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.sm),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: GwColors.textSecondary, size: GwSpacing.lg - GwSpacing.xxs),
            const SizedBox(width: GwSpacing.sm),
            Expanded(child: child),
          ]),
        );

    final Widget? action = switch ((open, d.isMember, e.myStatus)) {
      (false, _, _) => null,
      (true, false, _) => GwButton(
          label: eventsL10n.joinGroupFirst(e.group.name),
          variant: GwButtonVariant.secondary,
          expand: true,
          onPressed: () => widget.links.openGroup(context, e.group.handle),
        ),
      (true, true, null) when e.approvalRequired && !d.canManage => GwButton(
          label: eventsL10n.sendJoinRequest,
          icon: Icons.how_to_reg_outlined,
          expand: true,
          isLoading: _busy,
          onPressed: () => _attend(d),
        ),
      (true, true, null) => GwButton(
          label: e.isFull ? eventsL10n.joinWaitlist : eventsL10n.join,
          icon: e.isFull ? Icons.hourglass_empty_rounded : Icons.event_available_outlined,
          expand: true,
          isLoading: _busy,
          onPressed: () => _attend(d),
        ),
      (true, true, _) => GwButton(
          label: switch (e.myStatus) {
            AttendanceStatus.requested => eventsL10n.withdrawRequest,
            AttendanceStatus.going => eventsL10n.leaveEvent,
            _ => eventsL10n.leaveWaitlist,
          },
          variant: GwButtonVariant.secondary,
          expand: true,
          isLoading: _busy,
          onPressed: () => _run(
            (r) => r.leave(e.id),
            done: e.myStatus == AttendanceStatus.requested ? eventsL10n.requestWithdrawn : eventsL10n.attendanceRemoved,
          ),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(e.group.name),
        actions: [
          IconButton(
            tooltip: eventsL10n.share,
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final shared = await shareLink(ref.read(shareLinksProvider).event(e.id), text: eventsL10n.eventShareText(e.title));
              if (!shared && mounted) _snack(context, eventsL10n.eventLinkCopied);
            },
          ),
          if (!d.canManage && ref.watch(currentUserIdProvider) != null)
            IconButton(
              tooltip: eventsL10n.report,
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => ref.read(reportLauncherProvider)(context, ReportTarget.event(e.id)),
            ),
          if (d.canManage && open)
            PopupMenuButton<String>(
              tooltip: eventsL10n.eventOptions,
              onSelected: (a) => switch (a) {
                'edit' => context.push(EventRoutes.edit(e.id)),
                'stop' => _stopSeries(e),
                _ => _cancel(e),
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(eventsL10n.edit)),
                PopupMenuItem(value: 'cancel', child: Text(eventsL10n.cancelThisDate)),
                if (e.series?.active ?? false) PopupMenuItem(value: 'stop', child: Text(eventsL10n.stopRepeat)),
              ],
            ),
        ],
      ),
      bottomNavigationBar: action == null
          ? null
          : SafeArea(
              child: DecoratedBox(
                decoration: const BoxDecoration(border: Border(top: GwBorders.hairline)),
                child: Padding(padding: const EdgeInsets.all(GwSpacing.md), child: action),
              ),
            ),
      body: GwReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(eventDetailProvider(widget.eventId)),
          child: ListView(
            padding: const EdgeInsets.only(bottom: GwSpacing.xl),
            children: [
              if (e.coverUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image(image: gwNetworkImage(e.coverUrl!), fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GwColors.surfaceMuted)),
                ),
              Padding(
                padding: const EdgeInsets.all(GwSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.isCanceled) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GwSpacing.sm),
                        decoration: const BoxDecoration(color: GwColors.errorSoft, borderRadius: GwRadius.mdAll),
                        child: Text(e.cancelReason == null ? eventsL10n.eventCanceled : eventsL10n.eventCanceledBecause(e.cancelReason!),
                            style: textTheme.bodyMedium?.copyWith(color: GwColors.error)),
                      ),
                      const SizedBox(height: GwSpacing.md),
                    ] else if (!open) ...[
                      GwBadge(eventsL10n.startedOrEnded),
                      const SizedBox(height: GwSpacing.sm),
                    ],
                    Text(e.title, style: textTheme.headlineSmall),
                    const SizedBox(height: GwSpacing.xs),
                    InkWell(
                      onTap: () => widget.links.openGroup(context, e.group.handle),
                      child: Text(e.categoryName == null ? e.group.name : '${e.group.name} · ${e.categoryName}',
                          style: textTheme.labelLarge?.copyWith(color: GwColors.primary)),
                    ),
                    const SizedBox(height: GwSpacing.md),
                    row(
                      Icons.schedule,
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(eventWhen(e), style: textTheme.bodyLarge),
                        if (e.series case EventSeries(active: true) && final series)
                          Text(
                            series.until == null ? series.label : eventsL10n.seriesUntil(series.label, formatDate(series.until!)),
                            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                          ),
                        if (!e.isCanceled && open)
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () => _addToCalendar(e),
                            icon: const Icon(Icons.event_note_outlined, size: GwSpacing.md + GwSpacing.xxs),
                            label: Text(eventsL10n.addToCalendar),
                          ),
                      ]),
                    ),
                    row(
                      Icons.place_outlined,
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (e.surprise case final surprise?)
                          SurprisePlace(event: e, surprise: surprise, now: now)
                        else
                          Text(e.location, style: textTheme.bodyLarge),
                        if (e.linkUrl != null)
                          SelectableText(e.linkUrl!, style: textTheme.bodyMedium?.copyWith(color: GwColors.secondary)),
                        if (e.meeting case final point?) ...[
                          const SizedBox(height: GwSpacing.xs),
                          EventMeetingMap(point: point),
                        ],
                      ]),
                    ),
                    row(Icons.groups_outlined, Text(eventSeats(e), style: textTheme.bodyLarge)),
                    if (e.capacity != null)
                      Padding(
                        padding: const EdgeInsets.only(left: GwSpacing.xl, bottom: GwSpacing.sm),
                        child: ClipRRect(
                          borderRadius: GwRadius.smAll,
                          child: LinearProgressIndicator(
                            value: (e.goingCount / e.capacity!).clamp(0, 1),
                            minHeight: GwSpacing.xs,
                            backgroundColor: GwColors.surfaceMuted,
                          ),
                        ),
                      ),
                    if (e.fee != null)
                      row(
                        Icons.payments_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(eventsL10n.fee(e.fee!.label), style: textTheme.bodyLarge),
                          if (e.feeNote != null) Text(e.feeNote!, style: textTheme.bodyMedium),
                          Text(eventsL10n.feeNotice,
                              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                        ]),
                      ),
                    if (handshakeOpen(e, now)) HandshakeEntry(event: e),
                    if (d.asksConfirmation(now))
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: GwSpacing.sm),
                        padding: const EdgeInsets.all(GwSpacing.md),
                        decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(eventsL10n.areYouComing, style: textTheme.titleMedium),
                          const SizedBox(height: GwSpacing.xxs),
                          Text(eventsL10n.areYouComingHint, style: textTheme.bodyMedium),
                          const SizedBox(height: GwSpacing.sm),
                          Wrap(spacing: GwSpacing.xs, runSpacing: GwSpacing.xs, children: [
                            GwButton(
                              label: eventsL10n.yesComing,
                              icon: Icons.check,
                              isLoading: _busy,
                              onPressed: () => _run((r) => r.confirmAttendance(e.id), done: eventsL10n.confirmThanks),
                            ),
                            GwButton(
                              label: eventsL10n.cantCome,
                              variant: GwButtonVariant.secondary,
                              onPressed: _busy ? null : () => _run((r) => r.leave(e.id), done: eventsL10n.spotFreed),
                            ),
                          ]),
                        ]),
                      )
                    else if (d.myConfirmed == true && e.isOpen(now))
                      Padding(
                        padding: const EdgeInsets.only(bottom: GwSpacing.sm),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline, color: GwColors.success, size: GwSpacing.lg),
                          const SizedBox(width: GwSpacing.xs),
                          Expanded(child: Text(eventsL10n.confirmedComing, style: textTheme.bodyMedium)),
                        ]),
                      ),
                    if (d.conflicts.isNotEmpty && !e.isCanceled)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: GwSpacing.sm),
                        padding: const EdgeInsets.all(GwSpacing.sm),
                        decoration: const BoxDecoration(color: GwColors.warningSoft, borderRadius: GwRadius.mdAll),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(eventsL10n.otherEventSameTime, style: textTheme.labelLarge?.copyWith(color: GwColors.warning)),
                          for (final c in d.conflicts)
                            InkWell(
                              onTap: () => context.push(EventRoutes.event(c.id)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
                                child: Text(eventsL10n.titleOnDate(c.title, formatDateTime(c.startsAt.toLocal())),
                                    style: textTheme.bodyMedium?.copyWith(color: GwColors.warning, decoration: TextDecoration.underline)),
                              ),
                            ),
                        ]),
                      ),
                    if (e.approvalRequired)
                      row(Icons.how_to_reg_outlined, Text(eventsL10n.needsApproval, style: textTheme.bodyLarge)),
                    if (e.requirements.isNotEmpty)
                      row(
                        Icons.rule_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(eventsL10n.requirements, style: textTheme.labelLarge),
                          Text(e.requirements, style: textTheme.bodyLarge),
                        ]),
                      ),
                    if (e.equipment.isNotEmpty)
                      row(
                        Icons.backpack_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(eventsL10n.equipment, style: textTheme.labelLarge),
                          const SizedBox(height: GwSpacing.xxs),
                          Wrap(spacing: GwSpacing.xs, runSpacing: GwSpacing.xs, children: [for (final item in e.equipment) GwBadge(item)]),
                        ]),
                      ),
                    if (e.myStatus != null) ...[_StatusBadge(event: e), const SizedBox(height: GwSpacing.sm)],
                    if (e.description.isNotEmpty) ...[
                      const SizedBox(height: GwSpacing.xs),
                      SelectableText(e.description, style: textTheme.bodyLarge),
                    ],
                    if (d.isMember && !e.isCanceled) EventWelcomeSection(event: e, links: widget.links),
                    if (d.requests case final requests? when requests.isNotEmpty) ...[
                      const SizedBox(height: GwSpacing.lg),
                      Text(eventsL10n.joinRequestsCount(requests.length), style: textTheme.titleMedium),
                      const SizedBox(height: GwSpacing.xs),
                      for (final p in requests)
                        Padding(
                          padding: const EdgeInsets.only(bottom: GwSpacing.xs),
                          child: Row(
                            children: [
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => widget.links.openProfile(context, p.username),
                                child: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
                              ),
                              const SizedBox(width: GwSpacing.sm),
                              Expanded(child: Text(p.displayName, style: textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
                              TextButton(onPressed: _busy || !open ? null : () => _decide(e, p, approve: false), child: Text(eventsL10n.decline)),
                              GwButton(label: eventsL10n.approve, onPressed: _busy || !open ? null : () => _decide(e, p, approve: true)),
                            ],
                          ),
                        ),
                    ],
                    if (d.attendees case final people? when people.isNotEmpty) ...[
                      const SizedBox(height: GwSpacing.lg),
                      Text(eventsL10n.attendees, style: textTheme.titleMedium),
                      if (d.confirmedCount case final confirmed?)
                        Text(eventsL10n.confirmedOf(e.goingCount, confirmed),
                            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                      const SizedBox(height: GwSpacing.xs),
                      Wrap(
                        spacing: GwSpacing.xs,
                        runSpacing: GwSpacing.xs,
                        children: [
                          for (final p in people)
                            Tooltip(
                              message: p.confirmed == true ? eventsL10n.confirmedName(p.displayName) : p.displayName,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => widget.links.openProfile(context, p.username),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user),
                                  if (p.confirmed == true)
                                    const Positioned(
                                      right: -GwSpacing.xxs,
                                      bottom: -GwSpacing.xxs,
                                      child: Icon(Icons.check_circle, color: GwColors.success, size: GwSpacing.md),
                                    ),
                                ]),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (d.wasThereCount case final count?)
                Padding(
                  padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.md),
                  child: GwButton(
                    label: eventsL10n.shareWasThere,
                    icon: Icons.auto_awesome_outlined,
                    variant: GwButtonVariant.secondary,
                    onPressed: () => showWasThereCard(context, e, count),
                  ),
                ),
              if (e.hasEnded(now) && !e.isCanceled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventsL10n.howDidItGo, style: textTheme.titleMedium),
                      const SizedBox(height: GwSpacing.xxs),
                      Text(eventSummary(e), style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                      if (d.canReview) ...[
                        const SizedBox(height: GwSpacing.sm),
                        _ReviewBox(event: e, mine: d.myReview),
                      ],
                      if (d.reviews case final reviews? when reviews.isNotEmpty) ...[
                        const SizedBox(height: GwSpacing.md),
                        Text(eventsL10n.reviewsCount(reviews.length), style: textTheme.titleSmall),
                        Text(eventsL10n.reviewNotesPrivate,
                            style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                        for (final r in reviews)
                          Padding(
                            padding: const EdgeInsets.only(top: GwSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GwAvatar(name: r.person!.displayName, imageUrl: r.person!.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
                                const SizedBox(width: GwSpacing.sm),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('${r.person!.displayName} · ${'★' * r.rating}', style: textTheme.labelLarge, semanticsLabel: eventsL10n.reviewBy(r.person!.displayName, r.rating)),
                                    if (r.comment.isNotEmpty) Text(r.comment, style: textTheme.bodyMedium),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: GwSpacing.lg),
                    ],
                  ),
                ),
              if (d.roll case final roll? when roll.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eventsL10n.attendanceCheck, style: textTheme.titleMedium),
                      Text(eventsL10n.attendanceCheckHint,
                          style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                      for (final entry in roll)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: !entry.noShow,
                          onChanged: _busy
                              ? null
                              : (came) => _run(
                                    (r) => r.setNoShow(e.id, entry.person.id, noShow: !came),
                                    done: came ? eventsL10n.markedCame(entry.person.displayName) : eventsL10n.markedMissed(entry.person.displayName),
                                  ),
                          secondary: GwAvatar(name: entry.person.displayName, imageUrl: entry.person.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
                          title: Text(entry.person.displayName),
                          subtitle: Text(entry.noShow ? eventsL10n.didntCome : eventsL10n.came),
                        ),
                    ],
                  ),
                ),
              if (e.hasStarted(now) && !e.isCanceled && widget.links.memories != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.sm, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text(eventsL10n.memories, style: textTheme.titleMedium)),
                      if (d.canPost && widget.links.shareMemory != null)
                        TextButton.icon(
                          onPressed: () => widget.links.shareMemory!(context, e.id),
                          icon: const Icon(Icons.add_a_photo_outlined, size: GwSpacing.md + GwSpacing.xxs),
                          label: Text(eventsL10n.shareMemory),
                        ),
                    ],
                  ),
                ),
                widget.links.memories!(context, e.id),
              ],
              if (e.hasEnded(now)) _NextEvents(groupId: e.group.id, except: e.id),
              if (d.isMember)
                PollsSection(
                  scope: (groupId: e.group.id, eventId: e.id),
                  canManage: d.canManage && open,
                  title: eventsL10n.eventPolls,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create (with [groupId]) or edit (with [eventId]) an event.
class EventEditorScreen extends ConsumerWidget {
  const EventEditorScreen({super.key, this.groupId, this.eventId}) : assert((groupId == null) != (eventId == null));

  final String? groupId;
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (eventId == null) return _Editor(groupId: groupId!);
    final detail = ref.watch(eventDetailProvider(eventId!));
    return switch (detail) {
      AsyncData(:final value) when value.canManage => _Editor(groupId: value.event.group.id, event: value.event),
      AsyncData() => Scaffold(
          appBar: AppBar(),
          body: GwEmptyState(
            icon: Icons.lock_outline,
            message: eventsL10n.noEditPermission,
            actionLabel: eventsL10n.goBack,
            onAction: () => context.pop(),
          ),
        ),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(eventDetailProvider(eventId!))),
        ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.groupId, this.event});

  final String groupId;
  final GroupEvent? event;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.event?.title);
  late final _description = TextEditingController(text: widget.event?.description);
  late final _location = TextEditingController(text: widget.event?.location);
  late final _link = TextEditingController(text: widget.event?.linkUrl);
  late final _capacity = TextEditingController(text: widget.event?.capacity?.toString());
  late final _fee = TextEditingController(
      text: widget.event?.fee == null ? '' : (widget.event!.fee!.amountMinor / 100).toStringAsFixed(2).replaceAll('.', ','));
  late final _feeNote = TextEditingController(text: widget.event?.feeNote);
  late final _requirements = TextEditingController(text: widget.event?.requirements);
  late final _equipment = TextEditingController(text: widget.event?.equipment.join(', '));
  late bool _approval = widget.event?.approvalRequired ?? false;
  int? _repeatWeeks;
  DateTime? _repeatUntil;
  late LatLng? _meeting = widget.event?.surprise?.venueMeeting ?? widget.event?.meeting;
  late bool _surprise = widget.event?.surprise != null;
  late int _revealHours = widget.event?.surprise?.revealHours ?? 3;
  late final _venue = TextEditingController(text: widget.event?.surprise?.venue);
  late String _currency = widget.event?.fee?.currency ?? 'TRY';
  late DateTime _startsAt = widget.event?.startsAt.toLocal() ?? _nextMorning();
  late DateTime? _endsAt = widget.event?.endsAt?.toLocal();
  late String? _coverPath = widget.event?.coverPath;
  late String? _coverUrl = widget.event?.coverUrl;
  bool _busy = false;
  String? _error;

  static DateTime _nextMorning() {
    final t = DateTime.now().add(const Duration(days: 7));
    return DateTime(t.year, t.month, t.day, 9);
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _location, _venue, _link, _capacity, _fee, _feeNote, _requirements, _equipment]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: initial.isBefore(now) ? now : initial, firstDate: now,
        lastDate: now.add(const Duration(days: 365)));
    if (day == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _pickCover() async {
    final image = await pickGalleryImage(maxWidth: 1600);
    if (image == null || !mounted) return;
    setState(() => _busy = true);
    final result = await ref.read(eventsRepositoryProvider).uploadCover(widget.groupId, image);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        setState(() {
          _coverPath = value;
          _coverUrl = ref.read(supabaseClientProvider).storage.from('event-images').getPublicUrl(value);
        });
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
  }

  /// "150", "150,50" → minor units.
  int? _feeMinor() {
    final text = _fee.text.trim().replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(text);
    return value == null ? null : (value * 100).round();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final fee = _feeMinor();
    final form = EventForm(
      title: _title.text,
      description: _description.text,
      startsAt: _startsAt,
      endsAt: _endsAt,
      location: _location.text,
      linkUrl: _surprise || _link.text.trim().isEmpty ? null : _link.text.trim(),
      capacity: int.tryParse(_capacity.text.trim()),
      fee: fee == null || fee <= 0 ? null : EventFee(amountMinor: fee, currency: _currency),
      feeNote: _feeNote.text.trim().isEmpty ? null : _feeNote.text.trim(),
      coverPath: _coverPath,
      requirements: _requirements.text,
      equipment: equipmentItems(_equipment.text),
      approvalRequired: _approval,
      meeting: _meeting,
      repeat: _surprise || _repeatWeeks == null ? null : EventRepeat(weeks: _repeatWeeks!, until: _repeatUntil),
      surprise: _surprise ? EventSurpriseForm(revealHours: _revealHours, venue: _venue.text) : null,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(eventsRepositoryProvider);
    final event = widget.event;
    final Result<String> result = event == null ? await repo.create(widget.groupId, form) : (await repo.update(event.id, form)).map((_) => event.id);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.invalidate(groupEventsProvider(widget.groupId));
        if (event == null) {
          context.pushReplacement(EventRoutes.event(value));
        } else {
          ref.invalidate(eventDetailProvider(event.id));
          context.pop();
        }
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final editing = widget.event != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? eventsL10n.editEvent : eventsL10n.newEvent)),
      body: GwReadingColumn(
        maxWidth: GwLayout.formMaxWidth,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              InkWell(
                borderRadius: GwRadius.lgAll,
                onTap: _busy ? null : _pickCover,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: GwColors.surfaceMuted,
                      borderRadius: GwRadius.lgAll,
                      border: Border.fromBorderSide(GwBorders.hairline),
                    ),
                    child: _coverUrl == null
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.add_photo_alternate_outlined, color: GwColors.textSecondary, size: GwSpacing.xl),
                            const SizedBox(height: GwSpacing.xs),
                            Text(eventsL10n.addCover, style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
                          ])
                        : Image(image: gwNetworkImage(_coverUrl!), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: GwSpacing.md),
              TextFormField(
                controller: _title,
                maxLength: 100,
                decoration: InputDecoration(labelText: eventsL10n.title, hintText: eventsL10n.titleExample),
                validator: (v) => (v ?? '').trim().length < 3 ? eventsL10n.titleMin3 : null,
              ),
              const SizedBox(height: GwSpacing.xs),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(eventsL10n.starts),
                subtitle: Text(formatDateTime(_startsAt)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final at = await _pick(_startsAt);
                  if (at != null) setState(() => _startsAt = at);
                },
              ),
              _SimilarEvents(groupId: widget.groupId, day: DateTime(_startsAt.year, _startsAt.month, _startsAt.day)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timelapse),
                title: Text(eventsL10n.endsOptional),
                subtitle: Text(_endsAt == null ? eventsL10n.notSpecified : formatDateTime(_endsAt!)),
                trailing: _endsAt == null
                    ? const Icon(Icons.add)
                    : IconButton(tooltip: eventsL10n.removeEnd, icon: const Icon(Icons.close), onPressed: () => setState(() => _endsAt = null)),
                onTap: () async {
                  final at = await _pick(_endsAt ?? _startsAt.add(const Duration(hours: 3)));
                  if (at != null) setState(() => _endsAt = at);
                },
              ),
              if (widget.event == null && !_surprise) ...[
                const SizedBox(height: GwSpacing.xs),
                Text(eventsL10n.repeat, style: textTheme.titleSmall),
                const SizedBox(height: GwSpacing.xs),
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final (weeks, label) in [(null, eventsL10n.noRepeat), (1, eventsL10n.weekly), (2, eventsL10n.biweekly)])
                      ChoiceChip(label: Text(label), selected: _repeatWeeks == weeks, onSelected: (_) => setState(() => _repeatWeeks = weeks)),
                  ],
                ),
                if (_repeatWeeks != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: Text(eventsL10n.lastDateOptional),
                    subtitle: Text(_repeatUntil == null ? eventsL10n.untilYouStop : formatDate(_repeatUntil!)),
                    trailing: _repeatUntil == null
                        ? const Icon(Icons.add)
                        : IconButton(tooltip: eventsL10n.removeLastDate, icon: const Icon(Icons.close), onPressed: () => setState(() => _repeatUntil = null)),
                    onTap: () async {
                      final now = DateTime.now();
                      final day = await showDatePicker(
                        context: context,
                        initialDate: _repeatUntil ?? _startsAt.add(const Duration(days: 56)),
                        firstDate: _startsAt.add(const Duration(days: 1)),
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (day != null) setState(() => _repeatUntil = day);
                    },
                  ),
                  Text(
                    eventsL10n.repeatHint,
                    style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                  ),
                ],
              ],
              const SizedBox(height: GwSpacing.xs),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _surprise,
                onChanged: (v) => setState(() => _surprise = v),
                title: Text(eventsL10n.surpriseVenue),
                subtitle: Text(eventsL10n.surpriseHint),
              ),
              TextFormField(
                controller: _location,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: _surprise ? eventsL10n.hintPublic : eventsL10n.place,
                  hintText: _surprise ? eventsL10n.hintExample : eventsL10n.placeExample,
                ),
                validator: (v) => (v ?? '').trim().length < 2 ? (_surprise ? eventsL10n.writeHint : eventsL10n.writePlace) : null,
              ),
              if (_surprise) ...[
                TextFormField(
                  controller: _venue,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: eventsL10n.realVenue,
                    hintText: eventsL10n.realVenueExample,
                  ),
                  validator: (v) => (v ?? '').trim().length < 2 ? eventsL10n.writeRealVenue : null,
                ),
                Text(eventsL10n.whenReveal, style: textTheme.titleSmall),
                const SizedBox(height: GwSpacing.xs),
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final hours in EventSurprise.hourChoices)
                      ChoiceChip(
                        label: Text(eventsL10n.hoursBefore(hours)),
                        selected: _revealHours == hours,
                        onSelected: (_) => setState(() => _revealHours = hours),
                      ),
                  ],
                ),
                const SizedBox(height: GwSpacing.sm),
              ] else
              TextFormField(
                controller: _link,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: eventsL10n.linkOptional, hintText: 'https://'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  return t.isEmpty || t.startsWith('http://') || t.startsWith('https://') ? null : eventsL10n.httpsRequired;
                },
              ),
              MeetingPointField(value: _meeting, onChanged: (p) => setState(() => _meeting = p)),
              const SizedBox(height: GwSpacing.sm),
              TextFormField(
                controller: _description,
                maxLength: 2000,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(labelText: eventsL10n.description, alignLabelWithHint: true),
              ),
              TextFormField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: eventsL10n.capacity, helperText: eventsL10n.capacityHint),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return (v ?? '').trim().isEmpty || (n != null && n >= 1 && n <= 10000) ? null : eventsL10n.capacityRange;
                },
              ),
              TextFormField(
                controller: _requirements,
                maxLength: 500,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(labelText: eventsL10n.requirementsOptional, hintText: eventsL10n.requirementsExample),
              ),
              TextFormField(
                controller: _equipment,
                decoration: InputDecoration(
                  labelText: eventsL10n.equipmentOptional,
                  hintText: eventsL10n.equipmentExample,
                  helperText: eventsL10n.equipmentHint,
                ),
                validator: (v) {
                  final items = equipmentItems(v ?? '');
                  return items.length <= 10 && items.every((i) => i.length <= 60) ? null : eventsL10n.equipmentLimit;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _approval,
                onChanged: (v) => setState(() => _approval = v),
                title: Text(eventsL10n.approvalRequired),
                subtitle: Text(eventsL10n.approvalHint),
              ),
              const SizedBox(height: GwSpacing.md),
              Text(eventsL10n.feeOptional, style: textTheme.titleSmall),
              Text(eventsL10n.feeInfoOnly,
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              const SizedBox(height: GwSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: eventsL10n.amount, hintText: eventsL10n.amountExample),
                      validator: (v) => (v ?? '').trim().isEmpty || (_feeMinor() ?? 0) > 0 ? null : eventsL10n.validAmount,
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  DropdownButton<String>(
                    value: _currency,
                    items: const [
                      DropdownMenuItem(value: 'TRY', child: Text('₺ TRY')),
                      DropdownMenuItem(value: 'USD', child: Text(r'$ USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? 'TRY'),
                  ),
                ],
              ),
              TextFormField(
                controller: _feeNote,
                maxLength: 200,
                decoration: InputDecoration(labelText: eventsL10n.paymentNote, hintText: eventsL10n.paymentNoteExample),
              ),
              if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
              const SizedBox(height: GwSpacing.md),
              GwButton(
                label: editing ? eventsL10n.save : eventsL10n.createEvent,
                icon: Icons.event_available_outlined,
                isLoading: _busy,
                expand: true,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The attendee's stars and a note for the organizers; saved straight to Supabase (own row).
class _ReviewBox extends ConsumerStatefulWidget {
  const _ReviewBox({super.key, required this.event, required this.mine, this.title});

  final GroupEvent event;
  final EventReview? mine;

  /// Replaces the heading where the event is not on screen (the group page).
  final String? title;

  @override
  ConsumerState<_ReviewBox> createState() => _ReviewBoxState();
}

class _ReviewBoxState extends ConsumerState<_ReviewBox> {
  late int _rating = widget.mine?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.mine?.comment);
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Result<void>> Function(EventsRepository r) action, String done) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(context, switch (result) {
      Ok() => done,
      Err(:final failure) => failure.userMessage,
    });
    ref
      ..invalidate(eventDetailProvider(widget.event.id))
      ..invalidate(groupEventsProvider(widget.event.group.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: const BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.fromBorderSide(GwBorders.hairline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title ?? (widget.mine == null ? eventsL10n.rateEvent : eventsL10n.yourReview), style: textTheme.labelLarge),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: eventsL10n.starsLabel(star),
                  onPressed: _busy ? null : () => setState(() => _rating = star),
                  icon: Icon(star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: GwColors.primary),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            maxLength: 500,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: eventsL10n.noteToOrganizers,
              helperText: eventsL10n.noteToOrganizersHint,
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: GwSpacing.xs),
          Row(
            children: [
              if (widget.mine != null)
                TextButton(
                  onPressed: _busy ? null : () => _run((r) => r.deleteReview(widget.event.id), eventsL10n.reviewDeleted),
                  child: Text(eventsL10n.delete),
                ),
              const Spacer(),
              GwButton(
                label: eventsL10n.save,
                isLoading: _busy,
                onPressed: _rating == 0
                    ? null
                    : () => _run((r) => r.saveReview(widget.event.id, rating: _rating, comment: _comment.text), eventsL10n.reviewSaved),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// After an event: what the group does next.
class _NextEvents extends ConsumerWidget {
  const _NextEvents({required this.groupId, required this.except});

  final String groupId;
  final String except;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = [
      for (final e in ref.watch(groupEventsProvider(groupId)).value?.events ?? const <GroupEvent>[])
        if (e.id != except && !e.isCanceled) e,
    ].take(3).toList();
    if (next.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.md, GwSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(eventsL10n.groupNext, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xs),
          for (final e in next) ...[EventCard(event: e), const SizedBox(height: GwSpacing.xs)],
        ],
      ),
    );
  }
}

/// The cancel reason; owns its controller so closing never touches a disposed one.
/// How many other groups of the same kind nearby meet that day; names are never shown (docs/ARCHITECTURE.md §3b).
class _SimilarEvents extends ConsumerWidget {
  const _SimilarEvents({required this.groupId, required this.day});

  final String groupId;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(similarEventsProvider((groupId: groupId, day: day))).value;
    if (n == null || n == 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: GwSpacing.xs),
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: const BoxDecoration(color: GwColors.secondarySoft, borderRadius: GwRadius.mdAll),
      child: Text(
        eventsL10n.sameDayOthers(n),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(eventsL10n.cancelEvent),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eventsL10n.cancelEventBody),
            const SizedBox(height: GwSpacing.sm),
            TextField(controller: _reason, maxLength: 500, decoration: InputDecoration(labelText: eventsL10n.reason)),
          ],
        ),
        actions: [
          GwButton(label: eventsL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: eventsL10n.cancelAction, onPressed: () => Navigator.of(context).pop(_reason.text)),
        ],
      );
}

/// The place of a surprise event: the venue for those who may see it, otherwise the province, the hint and when it opens.
class SurprisePlace extends StatelessWidget {
  const SurprisePlace({super.key, required this.event, required this.surprise, required this.now});

  final GroupEvent event;
  final EventSurprise surprise;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final revealed = surprise.isRevealed(now);
    final when = formatDateTime(surprise.revealAt.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GwBadge(eventsL10n.surpriseVenue, tone: GwBadgeTone.primary),
        const SizedBox(height: GwSpacing.xxs),
        if (surprise.venue case final venue?) ...[
          Text(venue, style: textTheme.bodyLarge),
          Text(revealed ? eventsL10n.hint(event.location) : eventsL10n.hintRevealAt(event.location, when), style: secondary),
          if (surprise.venueMeeting case final point?) ...[
            const SizedBox(height: GwSpacing.xs),
            EventMeetingMap(point: point),
          ],
        ] else ...[
          Text([?surprise.province, event.location].join(' · '), style: textTheme.bodyLarge),
          Text(
            revealed ? eventsL10n.venueRevealed : eventsL10n.venueRevealAt(when),
            style: secondary,
          ),
        ],
      ],
    );
  }
}
