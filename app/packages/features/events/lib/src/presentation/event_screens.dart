import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import 'polls.dart';
import 'providers.dart';
import 'routes.dart';

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

/// "12 / 20 kişi", "12 kişi katılıyor".
String eventSeats(GroupEvent e) => e.capacity == null
    ? '${formatCount(e.goingCount)} kişi katılıyor'
    : '${formatCount(e.goingCount)} / ${formatCount(e.capacity!)} kişi${e.waitlistCount > 0 ? ' · ${formatCount(e.waitlistCount)} bekliyor' : ''}';

/// Profiles and groups are other features; the app opens them.
class EventLinks {
  const EventLinks({required this.openGroup, required this.openProfile});

  final void Function(BuildContext context, String handle) openGroup;
  final void Function(BuildContext context, String username) openProfile;
}

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
      AttendanceStatus.going => const GxBadge('Katılıyorsun', dot: true, tone: GxBadgeTone.primary),
      AttendanceStatus.waitlisted => GxBadge('Bekleme listesi · ${e.myPlace ?? '-'}. sıra', tone: GxBadgeTone.info),
      null when e.isFull => const GxBadge('Dolu', tone: GxBadgeTone.neutral),
      null => const SizedBox.shrink(),
    };
  }
}

/// An upcoming event in a list.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final GroupEvent event;

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
              Expanded(child: Text('Organizasyonlar', style: textTheme.titleMedium)),
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

  Future<void> _attend(GroupEvent e) async {
    setState(() => _busy = true);
    final result = await ref.read(eventsRepositoryProvider).attend(e.id);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        _snack(
          context,
          value.status == AttendanceStatus.going
              ? 'Katılımın kaydedildi. Başlamadan önce hatırlatacağız.'
              : 'Bekleme listesine girdin (${value.place}. sıra). Yer açılınca haber vereceğiz.',
        );
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
    ref
      ..invalidate(eventDetailProvider(widget.eventId))
      ..invalidate(groupEventsProvider(e.group.id));
  }

  Future<void> _cancel(GroupEvent e) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: const Text('Organizasyonu iptal et'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Katılanlara ve bekleyenlere bildirim gider. İptal geri alınamaz.'),
            const SizedBox(height: GxSpacing.sm),
            TextField(controller: reason, maxLength: 500, decoration: const InputDecoration(labelText: 'Gerekçe')),
          ],
        ),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GxButton(label: 'İptal et', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    final text = reason.text;
    reason.dispose();
    if (confirmed != true) return;
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
      (true, true, null) => GxButton(
          label: e.isFull ? 'Bekleme listesine gir' : 'Katıl',
          icon: e.isFull ? Icons.hourglass_empty_rounded : Icons.event_available_outlined,
          expand: true,
          isLoading: _busy,
          onPressed: () => _attend(e),
        ),
      (true, true, _) => GxButton(
          label: e.myStatus == AttendanceStatus.going ? 'Katılmaktan vazgeç' : 'Bekleme listesinden çık',
          variant: GxButtonVariant.secondary,
          expand: true,
          isLoading: _busy,
          onPressed: () => _run((r) => r.leave(e.id), done: 'Katılımın kaldırıldı.'),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(e.group.name),
        actions: [
          IconButton(
            tooltip: 'Bağlantıyı kopyala',
            icon: const Icon(Icons.link),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '${Uri.base.origin}/#${EventRoutes.event(e.id)}'));
              if (mounted) _snack(context, 'Organizasyon bağlantısı kopyalandı.');
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
              onSelected: (a) => a == 'edit' ? context.push(EventRoutes.edit(e.id)) : _cancel(e),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                PopupMenuItem(value: 'cancel', child: Text('İptal et')),
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
                      child: Text(e.group.name, style: textTheme.labelLarge?.copyWith(color: GxColors.primary)),
                    ),
                    const SizedBox(height: GxSpacing.md),
                    row(Icons.schedule, Text(eventWhen(e), style: textTheme.bodyLarge)),
                    row(
                      Icons.place_outlined,
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.location, style: textTheme.bodyLarge),
                        if (e.linkUrl != null)
                          SelectableText(e.linkUrl!, style: textTheme.bodyMedium?.copyWith(color: GxColors.secondary)),
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
                    if (e.myStatus != null) ...[_StatusBadge(event: e), const SizedBox(height: GxSpacing.sm)],
                    if (e.description.isNotEmpty) ...[
                      const SizedBox(height: GxSpacing.xs),
                      SelectableText(e.description, style: textTheme.bodyLarge),
                    ],
                    if (d.attendees case final people? when people.isNotEmpty) ...[
                      const SizedBox(height: GxSpacing.lg),
                      Text('Katılanlar', style: textTheme.titleMedium),
                      const SizedBox(height: GxSpacing.xs),
                      Wrap(
                        spacing: GxSpacing.xs,
                        runSpacing: GxSpacing.xs,
                        children: [
                          for (final p in people)
                            Tooltip(
                              message: p.displayName,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => widget.links.openProfile(context, p.username),
                                child: GxAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GxAvatarShape.user),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
    for (final c in [_title, _description, _location, _link, _capacity, _fee, _feeNote]) {
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
