import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/live.dart';
import 'providers.dart';
import 'routes.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));

/// The live card on a group page: join the live room, remind or manage upcoming broadcasts, start one.
class GroupLiveSection extends ConsumerWidget {
  const GroupLiveSection({super.key, required this.groupId, required this.canStart});

  final String groupId;

  /// The member holds live.start (owner, Yönetici).
  final bool canStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing while loading or on error: the card is secondary to the group page.
    final data = ref.watch(groupLiveProvider(groupId)).value;
    if (data == null || (data.live == null && data.scheduled.isEmpty && !canStart)) return const SizedBox.shrink();
    final me = ref.watch(currentUserIdProvider);

    return Padding(
      padding: const EdgeInsets.only(top: GxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.live case final live?) _LiveNowCard(broadcast: live),
          for (final b in data.scheduled) ...[
            const SizedBox(height: GxSpacing.xs),
            _ScheduledTile(broadcast: b, isHost: b.host?.id == me, groupId: groupId),
          ],
          if (canStart && data.live == null) ...[
            const SizedBox(height: GxSpacing.sm),
            GxLiveButton(
              label: 'Yayın başlat',
              expand: true,
              onPressed: () => showStartLiveSheet(context, groupId: groupId, minutesLeft: data.minutesLeft),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveNowCard extends StatelessWidget {
  const _LiveNowCard({required this.broadcast});

  final LiveBroadcast broadcast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final host = broadcast.host;
    return Material(
      color: GxColors.primarySoft,
      borderRadius: GxRadius.lgAll,
      child: InkWell(
        borderRadius: GxRadius.lgAll,
        onTap: () => context.push(LiveRoutes.room(broadcast.id)),
        child: Padding(
          padding: const EdgeInsets.all(GxSpacing.md),
          child: Row(
            children: [
              GxAvatar(name: host?.displayName ?? '?', imageUrl: host?.avatarUrl, shape: GxAvatarShape.user),
              const SizedBox(width: GxSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GxLiveBadge(),
                    const SizedBox(height: GxSpacing.xxs),
                    Text(broadcast.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                    if (host != null)
                      Text('${host.displayName} sunuyor', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: GxSpacing.sm),
              GxButton(label: 'Katıl', icon: Icons.headphones_rounded, onPressed: () => context.push(LiveRoutes.room(broadcast.id))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduledTile extends ConsumerStatefulWidget {
  const _ScheduledTile({required this.broadcast, required this.isHost, required this.groupId});

  final LiveBroadcast broadcast;
  final bool isHost;
  final String groupId;

  @override
  ConsumerState<_ScheduledTile> createState() => _ScheduledTileState();
}

class _ScheduledTileState extends ConsumerState<_ScheduledTile> {
  bool _busy = false;
  late bool _reminded = widget.broadcast.reminded;

  Future<void> _run(Future<Result<void>> Function(LiveRepository repo) action, {String? done, VoidCallback? onDone}) async {
    setState(() => _busy = true);
    final result = await action(ref.read(liveRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        onDone?.call();
        if (done != null) _snack(context, done);
        ref.invalidate(groupLiveProvider(widget.groupId));
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.broadcast;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(GxSpacing.sm),
      decoration: const BoxDecoration(
        color: GxColors.surface,
        borderRadius: GxRadius.lgAll,
        border: Border.fromBorderSide(GxBorders.hairline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(GxSpacing.xs),
            decoration: const BoxDecoration(color: GxColors.secondarySoft, borderRadius: GxRadius.mdAll),
            child: const Icon(Icons.event_outlined, color: GxColors.secondary),
          ),
          const SizedBox(width: GxSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                Text('Yaklaşan · ${formatDateTimeTr(b.scheduledAt!)}',
                    style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
              ],
            ),
          ),
          if (widget.isHost) ...[
            TextButton(
              onPressed: _busy ? null : () => _run((r) => r.cancel(b.id), done: 'Planlı yayın iptal edildi.'),
              child: const Text('İptal'),
            ),
            if (b.canStartAt(DateTime.now()))
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _run((r) => r.startScheduled(b.id), onDone: () => context.push(LiveRoutes.room(b.id))),
                child: const Text('Başlat'),
              ),
          ] else
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(
                        (r) => r.setReminder(b.id, on: !_reminded),
                        done: _reminded ? 'Hatırlatma kaldırıldı.' : 'Yayın başlayınca haber vereceğiz.',
                        onDone: () => setState(() => _reminded = !_reminded),
                      ),
              icon: Icon(_reminded ? Icons.notifications_active : Icons.notifications_none),
              label: Text(_reminded ? 'Hatırlatılacak' : 'Hatırlat'),
            ),
        ],
      ),
    );
  }
}

/// Title, now or later; shows this month's minutes left.
Future<void> showStartLiveSheet(BuildContext context, {required String groupId, int? minutesLeft}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _StartLiveSheet(groupId: groupId, minutesLeft: minutesLeft),
    );

class _StartLiveSheet extends ConsumerStatefulWidget {
  const _StartLiveSheet({required this.groupId, required this.minutesLeft});

  final String groupId;
  final int? minutesLeft;

  @override
  ConsumerState<_StartLiveSheet> createState() => _StartLiveSheetState();
}

class _StartLiveSheetState extends ConsumerState<_StartLiveSheet> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  bool _later = false;
  DateTime _at = DateTime.now().add(const Duration(hours: 1));
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (time == null) return;
    setState(() => _at = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_later && _at.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      setState(() => _error = 'Planlı yayın en az 5 dakika sonraya olmalı.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(liveRepositoryProvider)
        .start(widget.groupId, title: _title.text, scheduledAt: _later ? _at : null);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.invalidate(groupLiveProvider(widget.groupId));
        Navigator.of(context).pop();
        if (_later) {
          _snack(context, 'Yayın planlandı. Üyeler hatırlatma isteyebilir.');
        } else {
          unawaited(context.push(LiveRoutes.room(value)));
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
    final minutes = widget.minutesLeft;
    final noMinutes = minutes != null && minutes <= 0 && !_later;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Canlı yayın', style: textTheme.titleLarge),
            const SizedBox(height: GxSpacing.xxs),
            Text('Grup üyeleri sesli odaya katılır; sahneye aldıkların konuşur.',
                style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
            const SizedBox(height: GxSpacing.md),
            TextFormField(
              controller: _title,
              maxLength: 80,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Başlık', hintText: 'Ör. Pazar yürüyüşü planı'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Başlık en az 3 karakter olmalı.' : null,
            ),
            const SizedBox(height: GxSpacing.xs),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Şimdi'), icon: Icon(Icons.podcasts)),
                ButtonSegment(value: true, label: Text('Planla'), icon: Icon(Icons.event_outlined)),
              ],
              selected: {_later},
              onSelectionChanged: (s) => setState(() => _later = s.first),
            ),
            if (_later) ...[
              const SizedBox(height: GxSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(formatDateTimeTr(_at)),
              ),
            ],
            if (minutes != null) ...[
              const SizedBox(height: GxSpacing.sm),
              Text(
                minutes > 0
                    ? 'Bu ay kalan canlı yayın süren: ${formatCount(minutes)} dakika.'
                    : 'Bu ayın canlı yayın süresi doldu. Daha fazlası için paketini yükseltebilirsin.',
                style: textTheme.bodyMedium?.copyWith(color: minutes > 0 ? GxColors.textSecondary : GxColors.error),
              ),
            ],
            if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
            const SizedBox(height: GxSpacing.md),
            if (_later)
              GxButton(label: 'Planla', icon: Icons.event_available_outlined, isLoading: _busy, expand: true, onPressed: _submit)
            else
              GxLiveButton(label: 'Yayını başlat', expand: true, onPressed: _busy || noMinutes ? null : _submit),
          ],
        ),
      ),
    );
  }
}
