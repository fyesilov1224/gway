import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/events.dart';
import 'map_screens.dart';
import 'polls.dart';
import 'providers.dart';
import 'routes.dart';
import 'welcome.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));

const _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _shortMonths = ['OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ', 'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'];

String _two(int v) => v.toString().padLeft(2, '0');

/// `Cumartesi, 25 Ekim 2026 · 09:00–13:00`
String eventWhen(GroupEvent e) {
  final s = e.startsAt.toLocal();
  final end = e.endsAt?.toLocal();
  final sameDay = end != null && end.year == s.year && end.month == s.month && end.day == s.day;
  final until = end == null ? '' : sameDay ? '–${_two(end.hour)}:${_two(end.minute)}' : ' – ${formatDateTimeTr(end)}';
  return '${_weekdays[s.weekday - 1]}, ${formatDateTr(s)} · ${_two(s.hour)}:${_two(s.minute)}$until';
}

/// "Kask, Su ,, Mont" → ["Kask", "Su", "Mont"].
List<String> equipmentItems(String text) => [for (final i in text.split(',')) if (i.trim().isNotEmpty) i.trim()];

/// "12 / 20 kişi", "12 kişi katılıyor".
String eventSeats(GroupEvent e) => e.capacity == null
    ? '${formatCount(e.goingCount)} kişi katılıyor'
    : '${formatCount(e.goingCount)} / ${formatCount(e.capacity!)} kişi${e.waitlistCount > 0 ? ' · ${formatCount(e.waitlistCount)} bekliyor' : ''}';

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
      '${formatCount(e.goingCount)} kişi katıldı',
      if (e.ratingAvg case final avg?) '${ratingLabel(avg)} ★ (${formatCount(e.ratingCount)} değerlendirme)',
      if (e.postsCount > 0) '${formatCount(e.postsCount)} anı',
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
    final color = muted ? GxColors.textSecondary : GxColors.primary;
    return Container(
      width: GxSpacing.xxl + GxSpacing.xxs,
      padding: const EdgeInsets.symmetric(vertical: GxSpacing.xs),
      decoration: BoxDecoration(color: muted ? GxColors.surfaceMuted : GxColors.primarySoft, borderRadius: GxRadius.mdAll),
      child: Column(
        children: [
          Text(_shortMonths[d.month - 1], style: textTheme.labelSmall?.copyWith(color: color)),
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
    if (e.isCanceled) return const GxBadge('İptal edildi', tone: GxBadgeTone.danger);
    return switch (e.myStatus) {
      AttendanceStatus.requested => const GxBadge('Onay bekliyor', tone: GxBadgeTone.warning),
      AttendanceStatus.going => const GxBadge('Katılıyorsun', dot: true, tone: GxBadgeTone.primary),
      AttendanceStatus.waitlisted => GxBadge('Bekleme listesi · ${e.myPlace ?? '-'}. sıra', tone: GxBadgeTone.info),
      null when e.isFull && !e.hasStarted(DateTime.now()) => const GxBadge('Dolu', tone: GxBadgeTone.neutral),
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
      borderRadius: GxRadius.lgAll,
      onTap: () => context.push(EventRoutes.event(e.id)),
      child: Container(
        padding: const EdgeInsets.all(GxSpacing.sm),
        decoration: const BoxDecoration(
          color: GxColors.background,
          borderRadius: GxRadius.lgAll,
          border: Border.fromBorderSide(GxBorders.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateBlock(date: e.startsAt, muted: e.isCanceled),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(decoration: e.isCanceled ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: GxSpacing.xxs),
                  Text(eventWhen(e), style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                  Text(e.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                  const SizedBox(height: GxSpacing.xs),
                  Wrap(
                    spacing: GxSpacing.xs,
                    runSpacing: GxSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(eventSeats(e), style: textTheme.labelMedium),
                      if (e.fee != null) GxBadge(e.fee!.label),
                      _StatusBadge(event: e),
                      if (conflict) const GxBadge('Çakışıyor', tone: GxBadgeTone.warning),
                    ],
                  ),
                ],
              ),
            ),
            if (e.coverUrl != null) ...[
              const SizedBox(width: GxSpacing.sm),
              ClipRRect(
                borderRadius: GxRadius.mdAll,
                child: Image.network(
                  e.coverUrl!,
                  width: GxSpacing.xxl * 1.5,
                  height: GxSpacing.xxl * 1.5,
                  fit: BoxFit.cover,
                  cacheWidth: gxCacheWidth(GxSpacing.xxl * 1.5, MediaQuery.devicePixelRatioOf(context)),
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
    if (data == null || (data.events.isEmpty && !canManage)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final left = data.eventsLeft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page, vertical: GxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Organizasyonlar', maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleLarge)),
              IconButton(
                tooltip: 'Geçmiş organizasyonlar',
                onPressed: () => context.push(EventRoutes.history(groupId)),
                icon: const Icon(Icons.history_rounded),
              ),
              IconButton(
                tooltip: 'Grup takvimi',
                onPressed: () => context.push(EventRoutes.groupCalendar(groupId)),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: left == 0 ? null : () => context.push(EventRoutes.create(groupId)),
                  icon: const Icon(Icons.event_available_outlined, size: GxSpacing.md + GxSpacing.xxs),
                  label: const Text('Oluştur'),
                ),
            ],
          ),
          if (canManage && left != null)
            Text(
              left > 0 ? 'Bu ay ${formatCount(left)} organizasyon hakkın kaldı.' : 'Bu ayın organizasyon hakkı doldu. Paketi yükselterek artırabilirsin.',
              style: textTheme.bodySmall?.copyWith(color: left > 0 ? GxColors.textSecondary : GxColors.error),
            ),
          const SizedBox(height: GxSpacing.xs),
          if (data.events.isEmpty)
            Text('Yürüyüş, konser ya da buluşma; ilk organizasyonu oluştur.',
                style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary))
          else
            for (final e in data.events) ...[EventCard(event: e), const SizedBox(height: GxSpacing.xs)],
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
            AttendanceStatus.requested => 'Katılım isteğin gönderildi. Yönetici karar verince haber vereceğiz.',
            AttendanceStatus.going => 'Katılımın kaydedildi. Başlamadan önce hatırlatacağız.',
            AttendanceStatus.waitlisted => 'Bekleme listesine girdin (${value.place}. sıra). Yer açılınca haber vereceğiz.',
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
        title: const Text('Aynı saatte başka organizasyonun var'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final c in conflicts) Text('• ${c.title} · ${formatDateTimeTr(c.startsAt.toLocal())}'),
            const SizedBox(height: GxSpacing.sm),
            Text(
              conflicts.length == 1
                  ? 'Gidemeyeceksen ondan vazgeçip yerini başkasına bırakabilirsin.'
                  : 'Gidemeyeceksen onlardan vazgeçip yerini başkalarına bırakabilirsin.',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İkisinde de kalsın')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(conflicts.length == 1 ? 'Diğerinden vazgeç' : 'Diğerlerinden vazgeç'),
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
        _ => conflicts.length == 1 ? 'Diğer organizasyondan vazgeçtin; yerin boşaldı.' : 'Diğer organizasyonlardan vazgeçtin.',
      },
    );
  }

  Future<void> _decide(GroupEvent e, EventPerson person, {required bool approve}) async {
    await _run(
      (r) => r.decideRequest(e.id, person.id, approve: approve),
      done: approve ? '${person.displayName} katılımcı oldu.' : 'İstek reddedildi; ${person.displayName} bilgilendirildi.',
    );
    ref.invalidate(groupEventsProvider(e.group.id));
  }

  Future<void> _addToCalendar(GroupEvent e) async {
    final opened = await launchUrl(ref.read(eventsRepositoryProvider).calendarUrl(e.id), mode: LaunchMode.externalApplication);
    if (!opened && mounted) _snack(context, 'Takvim dosyası açılamadı. Tekrar dene.');
  }

  Future<void> _stopSeries(GroupEvent e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: const Text('Tekrar durdurulsun mu?'),
        content: const Text('Yeni tarih açılmaz. Açılmış tarihler kalır; istersen onları tek tek iptal edebilirsin.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GxButton(label: 'Durdur', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (ok != true) return;
    await _run((r) => r.stopSeries(e.series!.id), done: 'Tekrar durduruldu.');
  }

  Future<void> _cancel(GroupEvent e) async {
    final text = await showDialog<String>(context: context, builder: (_) => const _CancelDialog());
    if (text == null) return;
    await _run((r) => r.cancel(e.id, reason: text), done: 'Organizasyon iptal edildi.');
    ref.invalidate(groupEventsProvider(e.group.id));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(eventDetailProvider(widget.eventId));
    return switch (detail) {
      AsyncData(:final value) => _content(value),
      AsyncError(error: NotFoundFailure()) => Scaffold(
          appBar: AppBar(),
          body: GxEmptyState(
            icon: Icons.event_busy_outlined,
            message: 'Bu organizasyon bulunamadı ya da artık görünür değil.',
            actionLabel: 'Geri dön',
            onAction: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId))),
        ),
      _ => Scaffold(
          appBar: AppBar(),
          body: const Padding(
            padding: EdgeInsets.all(GxSpacing.page),
            child: Column(children: [
              GxSkeleton(height: GxSpacing.xxl * 4, borderRadius: GxRadius.lgAll),
              SizedBox(height: GxSpacing.md),
              GxSkeleton(height: GxSpacing.xl),
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
          padding: const EdgeInsets.only(bottom: GxSpacing.sm),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: GxColors.textSecondary, size: GxSpacing.lg - GxSpacing.xxs),
            const SizedBox(width: GxSpacing.sm),
            Expanded(child: child),
          ]),
        );

    final Widget? action = switch ((open, d.isMember, e.myStatus)) {
      (false, _, _) => null,
      (true, false, _) => GxButton(
          label: '${e.group.name} grubuna katıl',
          variant: GxButtonVariant.secondary,
          expand: true,
          onPressed: () => widget.links.openGroup(context, e.group.handle),
        ),
      (true, true, null) when e.approvalRequired && !d.canManage => GxButton(
          label: 'Katılım isteği gönder',
          icon: Icons.how_to_reg_outlined,
          expand: true,
          isLoading: _busy,
          onPressed: () => _attend(d),
        ),
      (true, true, null) => GxButton(
          label: e.isFull ? 'Bekleme listesine gir' : 'Katıl',
          icon: e.isFull ? Icons.hourglass_empty_rounded : Icons.event_available_outlined,
          expand: true,
          isLoading: _busy,
          onPressed: () => _attend(d),
        ),
      (true, true, _) => GxButton(
          label: switch (e.myStatus) {
            AttendanceStatus.requested => 'İsteği geri çek',
            AttendanceStatus.going => 'Katılmaktan vazgeç',
            _ => 'Bekleme listesinden çık',
          },
          variant: GxButtonVariant.secondary,
          expand: true,
          isLoading: _busy,
          onPressed: () => _run(
            (r) => r.leave(e.id),
            done: e.myStatus == AttendanceStatus.requested ? 'Katılım isteğin geri çekildi.' : 'Katılımın kaldırıldı.',
          ),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(e.group.name),
        actions: [
          IconButton(
            tooltip: 'Paylaş',
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final shared = await shareLink(ref.read(shareLinksProvider).event(e.id), text: '${e.title} · GrupX\'te katıl:');
              if (!shared && mounted) _snack(context, 'Organizasyon bağlantısı kopyalandı.');
            },
          ),
          if (!d.canManage && ref.watch(currentUserIdProvider) != null)
            IconButton(
              tooltip: 'Şikayet et',
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => ref.read(reportLauncherProvider)(context, ReportTarget.event(e.id)),
            ),
          if (d.canManage && open)
            PopupMenuButton<String>(
              tooltip: 'Organizasyon seçenekleri',
              onSelected: (a) => switch (a) {
                'edit' => context.push(EventRoutes.edit(e.id)),
                'stop' => _stopSeries(e),
                _ => _cancel(e),
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                const PopupMenuItem(value: 'cancel', child: Text('Bu tarihi iptal et')),
                if (e.series?.active ?? false) const PopupMenuItem(value: 'stop', child: Text('Tekrarı durdur')),
              ],
            ),
        ],
      ),
      bottomNavigationBar: action == null
          ? null
          : SafeArea(
              child: DecoratedBox(
                decoration: const BoxDecoration(border: Border(top: GxBorders.hairline)),
                child: Padding(padding: const EdgeInsets.all(GxSpacing.md), child: action),
              ),
            ),
      body: GxReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(eventDetailProvider(widget.eventId)),
          child: ListView(
            padding: const EdgeInsets.only(bottom: GxSpacing.xl),
            children: [
              if (e.coverUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(e.coverUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted)),
                ),
              Padding(
                padding: const EdgeInsets.all(GxSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.isCanceled) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GxSpacing.sm),
                        decoration: const BoxDecoration(color: GxColors.errorSoft, borderRadius: GxRadius.mdAll),
                        child: Text('Bu organizasyon iptal edildi${e.cancelReason == null ? '.' : ': ${e.cancelReason}'}',
                            style: textTheme.bodyMedium?.copyWith(color: GxColors.error)),
                      ),
                      const SizedBox(height: GxSpacing.md),
                    ] else if (!open) ...[
                      const GxBadge('Başladı ya da sona erdi'),
                      const SizedBox(height: GxSpacing.sm),
                    ],
                    Text(e.title, style: textTheme.headlineSmall),
                    const SizedBox(height: GxSpacing.xs),
                    InkWell(
                      onTap: () => widget.links.openGroup(context, e.group.handle),
                      child: Text(e.categoryName == null ? e.group.name : '${e.group.name} · ${e.categoryName}',
                          style: textTheme.labelLarge?.copyWith(color: GxColors.primary)),
                    ),
                    const SizedBox(height: GxSpacing.md),
                    row(
                      Icons.schedule,
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(eventWhen(e), style: textTheme.bodyLarge),
                        if (e.series case EventSeries(active: true) && final series)
                          Text(
                            series.until == null ? series.label : '${series.label} · ${formatDateTr(series.until!)} tarihine kadar',
                            style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                          ),
                        if (!e.isCanceled && open)
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () => _addToCalendar(e),
                            icon: const Icon(Icons.event_note_outlined, size: GxSpacing.md + GxSpacing.xxs),
                            label: const Text('Takvime ekle'),
                          ),
                      ]),
                    ),
                    row(
                      Icons.place_outlined,
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.location, style: textTheme.bodyLarge),
                        if (e.linkUrl != null)
                          SelectableText(e.linkUrl!, style: textTheme.bodyMedium?.copyWith(color: GxColors.secondary)),
                        if (e.meeting case final point?) ...[
                          const SizedBox(height: GxSpacing.xs),
                          EventMeetingMap(point: point),
                        ],
                      ]),
                    ),
                    row(Icons.groups_outlined, Text(eventSeats(e), style: textTheme.bodyLarge)),
                    if (e.capacity != null)
                      Padding(
                        padding: const EdgeInsets.only(left: GxSpacing.xl, bottom: GxSpacing.sm),
                        child: ClipRRect(
                          borderRadius: GxRadius.smAll,
                          child: LinearProgressIndicator(
                            value: (e.goingCount / e.capacity!).clamp(0, 1),
                            minHeight: GxSpacing.xs,
                            backgroundColor: GxColors.surfaceMuted,
                          ),
                        ),
                      ),
                    if (e.fee != null)
                      row(
                        Icons.payments_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Katılım ücreti: ${e.fee!.label}', style: textTheme.bodyLarge),
                          if (e.feeNote != null) Text(e.feeNote!, style: textTheme.bodyMedium),
                          Text('Ücret organizasyon sahibine ödenir; GrupX ödeme almaz.',
                              style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                        ]),
                      ),
                    if (d.asksConfirmation(now))
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: GxSpacing.sm),
                        padding: const EdgeInsets.all(GxSpacing.md),
                        decoration: const BoxDecoration(color: GxColors.primarySoft, borderRadius: GxRadius.mdAll),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Geliyor musun?', style: textTheme.titleMedium),
                          const SizedBox(height: GxSpacing.xxs),
                          Text('Gelemeyeceksen yerini bekleme listesindekilere bırak.', style: textTheme.bodyMedium),
                          const SizedBox(height: GxSpacing.sm),
                          Wrap(spacing: GxSpacing.xs, runSpacing: GxSpacing.xs, children: [
                            GxButton(
                              label: 'Evet, geliyorum',
                              icon: Icons.check,
                              isLoading: _busy,
                              onPressed: () => _run((r) => r.confirmAttendance(e.id), done: 'Teşekkürler, geleceğini organizatöre bildirdik.'),
                            ),
                            GxButton(
                              label: 'Gelemiyorum',
                              variant: GxButtonVariant.secondary,
                              onPressed: _busy ? null : () => _run((r) => r.leave(e.id), done: 'Katılımın kaldırıldı; yerin boşaldı.'),
                            ),
                          ]),
                        ]),
                      )
                    else if (d.myConfirmed == true && e.isOpen(now))
                      Padding(
                        padding: const EdgeInsets.only(bottom: GxSpacing.sm),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline, color: GxColors.success, size: GxSpacing.lg),
                          const SizedBox(width: GxSpacing.xs),
                          Expanded(child: Text('Geleceğini teyit ettin.', style: textTheme.bodyMedium)),
                        ]),
                      ),
                    if (d.conflicts.isNotEmpty && !e.isCanceled)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: GxSpacing.sm),
                        padding: const EdgeInsets.all(GxSpacing.sm),
                        decoration: const BoxDecoration(color: GxColors.warningSoft, borderRadius: GxRadius.mdAll),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Bu saatte başka bir organizasyonun var', style: textTheme.labelLarge?.copyWith(color: GxColors.warning)),
                          for (final c in d.conflicts)
                            InkWell(
                              onTap: () => context.push(EventRoutes.event(c.id)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
                                child: Text('${c.title} · ${formatDateTimeTr(c.startsAt.toLocal())}',
                                    style: textTheme.bodyMedium?.copyWith(color: GxColors.warning, decoration: TextDecoration.underline)),
                              ),
                            ),
                        ]),
                      ),
                    if (e.approvalRequired)
                      row(Icons.how_to_reg_outlined, Text('Katılım yönetici onayıyla', style: textTheme.bodyLarge)),
                    if (e.requirements.isNotEmpty)
                      row(
                        Icons.rule_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Katılım koşulları', style: textTheme.labelLarge),
                          Text(e.requirements, style: textTheme.bodyLarge),
                        ]),
                      ),
                    if (e.equipment.isNotEmpty)
                      row(
                        Icons.backpack_outlined,
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Gerekli ekipman', style: textTheme.labelLarge),
                          const SizedBox(height: GxSpacing.xxs),
                          Wrap(spacing: GxSpacing.xs, runSpacing: GxSpacing.xs, children: [for (final item in e.equipment) GxBadge(item)]),
                        ]),
                      ),
                    if (e.myStatus != null) ...[_StatusBadge(event: e), const SizedBox(height: GxSpacing.sm)],
                    if (e.description.isNotEmpty) ...[
                      const SizedBox(height: GxSpacing.xs),
                      SelectableText(e.description, style: textTheme.bodyLarge),
                    ],
                    if (d.isMember && !e.isCanceled) EventWelcomeSection(event: e, links: widget.links),
                    if (d.requests case final requests? when requests.isNotEmpty) ...[
                      const SizedBox(height: GxSpacing.lg),
                      Text('Katılım istekleri (${requests.length})', style: textTheme.titleMedium),
                      const SizedBox(height: GxSpacing.xs),
                      for (final p in requests)
                        Padding(
                          padding: const EdgeInsets.only(bottom: GxSpacing.xs),
                          child: Row(
                            children: [
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => widget.links.openProfile(context, p.username),
                                child: GxAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                              ),
                              const SizedBox(width: GxSpacing.sm),
                              Expanded(child: Text(p.displayName, style: textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
                              TextButton(onPressed: _busy || !open ? null : () => _decide(e, p, approve: false), child: const Text('Reddet')),
                              GxButton(label: 'Onayla', onPressed: _busy || !open ? null : () => _decide(e, p, approve: true)),
                            ],
                          ),
                        ),
                    ],
                    if (d.attendees case final people? when people.isNotEmpty) ...[
                      const SizedBox(height: GxSpacing.lg),
                      Text('Katılanlar', style: textTheme.titleMedium),
                      if (d.confirmedCount case final confirmed?)
                        Text('${e.goingCount} katılandan $confirmed kişi geleceğini teyit etti.',
                            style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                      const SizedBox(height: GxSpacing.xs),
                      Wrap(
                        spacing: GxSpacing.xs,
                        runSpacing: GxSpacing.xs,
                        children: [
                          for (final p in people)
                            Tooltip(
                              message: p.confirmed == true ? '${p.displayName} · teyit etti' : p.displayName,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => widget.links.openProfile(context, p.username),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  GxAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GxAvatarShape.user),
                                  if (p.confirmed == true)
                                    const Positioned(
                                      right: -GxSpacing.xxs,
                                      bottom: -GxSpacing.xxs,
                                      child: Icon(Icons.check_circle, color: GxColors.success, size: GxSpacing.md),
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
              if (e.hasEnded(now) && !e.isCanceled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nasıl geçti?', style: textTheme.titleMedium),
                      const SizedBox(height: GxSpacing.xxs),
                      Text(eventSummary(e), style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                      if (d.canReview) ...[
                        const SizedBox(height: GxSpacing.sm),
                        _ReviewBox(event: e, mine: d.myReview),
                      ],
                      if (d.reviews case final reviews? when reviews.isNotEmpty) ...[
                        const SizedBox(height: GxSpacing.md),
                        Text('Değerlendirmeler (${reviews.length})', style: textTheme.titleSmall),
                        Text('Notları yalnızca organizasyonu düzenleyenler görür.',
                            style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                        for (final r in reviews)
                          Padding(
                            padding: const EdgeInsets.only(top: GxSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GxAvatar(name: r.person!.displayName, imageUrl: r.person!.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                                const SizedBox(width: GxSpacing.sm),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('${r.person!.displayName} · ${'★' * r.rating}', style: textTheme.labelLarge),
                                    if (r.comment.isNotEmpty) Text(r.comment, style: textTheme.bodyMedium),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: GxSpacing.lg),
                    ],
                  ),
                ),
              if (d.roll case final roll? when roll.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yoklama', style: textTheme.titleMedium),
                      Text('Gelmeyenleri işaretle; katkıya ve rozetlere yalnızca gelenler sayılır. Bitişten sonra 7 gün açık.',
                          style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                      for (final entry in roll)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: !entry.noShow,
                          onChanged: _busy
                              ? null
                              : (came) => _run(
                                    (r) => r.setNoShow(e.id, entry.person.id, noShow: !came),
                                    done: came ? '${entry.person.displayName} geldi olarak işaretlendi.' : '${entry.person.displayName} gelmedi olarak işaretlendi.',
                                  ),
                          secondary: GxAvatar(name: entry.person.displayName, imageUrl: entry.person.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                          title: Text(entry.person.displayName),
                          subtitle: Text(entry.noShow ? 'Gelmedi' : 'Geldi'),
                        ),
                    ],
                  ),
                ),
              if (e.hasStarted(now) && !e.isCanceled && widget.links.memories != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.sm, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text('Anılar', style: textTheme.titleMedium)),
                      if (d.canPost && widget.links.shareMemory != null)
                        TextButton.icon(
                          onPressed: () => widget.links.shareMemory!(context, e.id),
                          icon: const Icon(Icons.add_a_photo_outlined, size: GxSpacing.md + GxSpacing.xxs),
                          label: const Text('Anı paylaş'),
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
                  title: 'Organizasyon anketleri',
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
          body: GxEmptyState(
            icon: Icons.lock_outline,
            message: 'Bu organizasyonu düzenleme yetkin yok.',
            actionLabel: 'Geri dön',
            onAction: () => context.pop(),
          ),
        ),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(eventDetailProvider(eventId!))),
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
  late LatLng? _meeting = widget.event?.meeting;
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
    for (final c in [_title, _description, _location, _link, _capacity, _fee, _feeNote, _requirements, _equipment]) {
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
      linkUrl: _link.text.trim().isEmpty ? null : _link.text.trim(),
      capacity: int.tryParse(_capacity.text.trim()),
      fee: fee == null || fee <= 0 ? null : EventFee(amountMinor: fee, currency: _currency),
      feeNote: _feeNote.text.trim().isEmpty ? null : _feeNote.text.trim(),
      coverPath: _coverPath,
      requirements: _requirements.text,
      equipment: equipmentItems(_equipment.text),
      approvalRequired: _approval,
      meeting: _meeting,
      repeat: _repeatWeeks == null ? null : EventRepeat(weeks: _repeatWeeks!, until: _repeatUntil),
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
      appBar: AppBar(title: Text(editing ? 'Organizasyonu düzenle' : 'Yeni organizasyon')),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(GxSpacing.page),
            children: [
              InkWell(
                borderRadius: GxRadius.lgAll,
                onTap: _busy ? null : _pickCover,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: GxColors.surfaceMuted,
                      borderRadius: GxRadius.lgAll,
                      border: Border.fromBorderSide(GxBorders.hairline),
                    ),
                    child: _coverUrl == null
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.add_photo_alternate_outlined, color: GxColors.textSecondary, size: GxSpacing.xl),
                            const SizedBox(height: GxSpacing.xs),
                            Text('Kapak görseli ekle', style: textTheme.labelLarge?.copyWith(color: GxColors.textSecondary)),
                          ])
                        : Image.network(_coverUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: GxSpacing.md),
              TextFormField(
                controller: _title,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Başlık', hintText: 'Ör. Belgrad Ormanı yürüyüşü'),
                validator: (v) => (v ?? '').trim().length < 3 ? 'Başlık en az 3 karakter olmalı.' : null,
              ),
              const SizedBox(height: GxSpacing.xs),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Başlangıç'),
                subtitle: Text(formatDateTimeTr(_startsAt)),
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
                title: const Text('Bitiş (isteğe bağlı)'),
                subtitle: Text(_endsAt == null ? 'Belirtilmedi' : formatDateTimeTr(_endsAt!)),
                trailing: _endsAt == null
                    ? const Icon(Icons.add)
                    : IconButton(tooltip: 'Bitişi kaldır', icon: const Icon(Icons.close), onPressed: () => setState(() => _endsAt = null)),
                onTap: () async {
                  final at = await _pick(_endsAt ?? _startsAt.add(const Duration(hours: 3)));
                  if (at != null) setState(() => _endsAt = at);
                },
              ),
              if (widget.event == null) ...[
                const SizedBox(height: GxSpacing.xs),
                Text('Tekrar', style: textTheme.titleSmall),
                const SizedBox(height: GxSpacing.xs),
                Wrap(
                  spacing: GxSpacing.xs,
                  runSpacing: GxSpacing.xs,
                  children: [
                    for (final (weeks, label) in const [(null, 'Tekrar yok'), (1, 'Her hafta'), (2, 'İki haftada bir')])
                      ChoiceChip(label: Text(label), selected: _repeatWeeks == weeks, onSelected: (_) => setState(() => _repeatWeeks = weeks)),
                  ],
                ),
                if (_repeatWeeks != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: const Text('Son tarih (isteğe bağlı)'),
                    subtitle: Text(_repeatUntil == null ? 'Sen durdurana kadar' : formatDateTr(_repeatUntil!)),
                    trailing: _repeatUntil == null
                        ? const Icon(Icons.add)
                        : IconButton(tooltip: 'Son tarihi kaldır', icon: const Icon(Icons.close), onPressed: () => setState(() => _repeatUntil = null)),
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
                    'Sonraki tarihler 4 hafta önceden kendiliğinden açılır ve her biri aylık organizasyon hakkından düşer.',
                    style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                  ),
                ],
              ],
              const SizedBox(height: GxSpacing.xs),
              TextFormField(
                controller: _location,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Yer', hintText: 'Ör. Bahçeköy girişi ya da Çevrim içi'),
                validator: (v) => (v ?? '').trim().length < 2 ? 'Yeri yaz.' : null,
              ),
              TextFormField(
                controller: _link,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Harita ya da çevrim içi bağlantı (isteğe bağlı)', hintText: 'https://'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  return t.isEmpty || t.startsWith('http://') || t.startsWith('https://') ? null : 'Bağlantı https:// ile başlamalı.';
                },
              ),
              MeetingPointField(value: _meeting, onChanged: (p) => setState(() => _meeting = p)),
              const SizedBox(height: GxSpacing.sm),
              TextFormField(
                controller: _description,
                maxLength: 2000,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Açıklama', alignLabelWithHint: true),
              ),
              TextFormField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Kapasite (boş = sınırsız)', helperText: 'Dolunca yeni katılanlar bekleme listesine girer.'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return (v ?? '').trim().isEmpty || (n != null && n >= 1 && n <= 10000) ? null : 'Kapasite 1–10.000 olmalı.';
                },
              ),
              TextFormField(
                controller: _requirements,
                maxLength: 500,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Katılım koşulları (isteğe bağlı)', hintText: 'Ör. En az 10 km yürüyüş deneyimi'),
              ),
              TextFormField(
                controller: _equipment,
                decoration: const InputDecoration(
                  labelText: 'Gerekli ekipman (isteğe bağlı)',
                  hintText: 'Ör. Kask, Su, Yağmurluk',
                  helperText: 'Virgülle ayır; en fazla 10 madde.',
                ),
                validator: (v) {
                  final items = equipmentItems(v ?? '');
                  return items.length <= 10 && items.every((i) => i.length <= 60) ? null : 'En fazla 10 madde, her biri en fazla 60 karakter.';
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _approval,
                onChanged: (v) => setState(() => _approval = v),
                title: const Text('Katılım onayla olsun'),
                subtitle: const Text('Katılmak isteyenler istek gönderir; sen onaylarsın.'),
              ),
              const SizedBox(height: GxSpacing.md),
              Text('Katılım ücreti (isteğe bağlı)', style: textTheme.titleSmall),
              Text('Yalnızca bilgi amaçlı gösterilir; GrupX ödeme almaz.',
                  style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
              const SizedBox(height: GxSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tutar', hintText: 'Ör. 150'),
                      validator: (v) => (v ?? '').trim().isEmpty || (_feeMinor() ?? 0) > 0 ? null : 'Geçerli bir tutar yaz.',
                    ),
                  ),
                  const SizedBox(width: GxSpacing.sm),
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
                decoration: const InputDecoration(labelText: 'Ödeme notu', hintText: 'Ör. Yerinde nakit ödenir'),
              ),
              if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
              const SizedBox(height: GxSpacing.md),
              GxButton(
                label: editing ? 'Kaydet' : 'Organizasyonu oluştur',
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
  const _ReviewBox({required this.event, required this.mine});

  final GroupEvent event;
  final EventReview? mine;

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
      padding: const EdgeInsets.all(GxSpacing.sm),
      decoration: const BoxDecoration(color: GxColors.surface, borderRadius: GxRadius.lgAll, border: Border.fromBorderSide(GxBorders.hairline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.mine == null ? 'Organizasyonu değerlendir' : 'Değerlendirmen', style: textTheme.labelLarge),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: '$star yıldız',
                  onPressed: _busy ? null : () => setState(() => _rating = star),
                  icon: Icon(star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: GxColors.primary),
                ),
            ],
          ),
          TextField(
            controller: _comment,
            maxLength: 500,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Düzenleyenlere notun (isteğe bağlı)',
              helperText: 'Notunu yalnızca organizasyonu düzenleyenler görür; herkes yalnızca ortalamayı görür.',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: GxSpacing.xs),
          Row(
            children: [
              if (widget.mine != null)
                TextButton(
                  onPressed: _busy ? null : () => _run((r) => r.deleteReview(widget.event.id), 'Değerlendirmen silindi.'),
                  child: const Text('Sil'),
                ),
              const Spacer(),
              GxButton(
                label: 'Kaydet',
                isLoading: _busy,
                onPressed: _rating == 0
                    ? null
                    : () => _run((r) => r.saveReview(widget.event.id, rating: _rating, comment: _comment.text), 'Teşekkürler, değerlendirmen kaydedildi.'),
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
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.md, GxSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Grubun sıradaki organizasyonları', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: GxSpacing.xs),
          for (final e in next) ...[EventCard(event: e), const SizedBox(height: GxSpacing.xs)],
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
      margin: const EdgeInsets.only(bottom: GxSpacing.xs),
      padding: const EdgeInsets.all(GxSpacing.sm),
      decoration: const BoxDecoration(color: GxColors.secondarySoft, borderRadius: GxRadius.mdAll),
      child: Text(
        'Bu tarihte ilinde aynı kategoride $n organizasyon daha var. Üyelerin seçim yapmak zorunda kalmasın '
        'istersen başka bir gün seçebilirsin.',
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
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: const Text('Organizasyonu iptal et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Katılanlara ve bekleyenlere bildirim gider. İptal geri alınamaz.'),
            const SizedBox(height: GxSpacing.sm),
            TextField(controller: _reason, maxLength: 500, decoration: const InputDecoration(labelText: 'Gerekçe')),
          ],
        ),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GxButton(label: 'İptal et', onPressed: () => Navigator.of(context).pop(_reason.text)),
        ],
      );
}
