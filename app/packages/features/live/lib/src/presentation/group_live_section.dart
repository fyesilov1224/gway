import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/live.dart';
import '../l10n.dart';
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
      padding: const EdgeInsets.only(top: GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.live case final live?) _LiveNowCard(broadcast: live),
          for (final b in data.scheduled) ...[
            const SizedBox(height: GwSpacing.xs),
            _ScheduledTile(broadcast: b, isHost: b.host?.id == me, groupId: groupId),
          ],
          if (canStart && data.live == null) ...[
            const SizedBox(height: GwSpacing.sm),
            GwLiveButton(
              label: liveL10n.startLive,
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
      color: GwColors.primarySoft,
      borderRadius: GwRadius.lgAll,
      child: InkWell(
        borderRadius: GwRadius.lgAll,
        onTap: () => context.push(LiveRoutes.room(broadcast.id)),
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Row(
            children: [
              GwAvatar(name: host?.displayName ?? '?', imageUrl: host?.avatarUrl, shape: GwAvatarShape.user),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GwLiveBadge(),
                    const SizedBox(height: GwSpacing.xxs),
                    Text(broadcast.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                    if (host != null)
                      Text(liveL10n.hostedBy(host.displayName), style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: GwSpacing.sm),
              GwButton(label: liveL10n.join, icon: Icons.headphones_rounded, onPressed: () => context.push(LiveRoutes.room(broadcast.id))),
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
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: const BoxDecoration(
        color: GwColors.surface,
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(GwSpacing.xs),
            decoration: const BoxDecoration(color: GwColors.secondarySoft, borderRadius: GwRadius.mdAll),
            child: const Icon(Icons.event_outlined, color: GwColors.secondary),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                Text(liveL10n.upcomingAt(formatDateTime(b.scheduledAt!)),
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          ),
          if (widget.isHost) ...[
            TextButton(
              onPressed: _busy ? null : () => _run((r) => r.cancel(b.id), done: liveL10n.scheduledCanceled),
              child: Text(liveL10n.cancel),
            ),
            if (b.canStartAt(DateTime.now()))
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _run((r) => r.startScheduled(b.id), onDone: () => context.push(LiveRoutes.room(b.id))),
                child: Text(liveL10n.start),
              ),
          ] else
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(
                        (r) => r.setReminder(b.id, on: !_reminded),
                        done: _reminded ? liveL10n.reminderRemoved : liveL10n.reminderSet,
                        onDone: () => setState(() => _reminded = !_reminded),
                      ),
              icon: Icon(_reminded ? Icons.notifications_active : Icons.notifications_none),
              label: Text(_reminded ? liveL10n.reminding : liveL10n.remind),
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
      setState(() => _error = liveL10n.schedule5min);
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
          _snack(context, liveL10n.scheduled);
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
          GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(liveL10n.liveBroadcast, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.xxs),
            Text(liveL10n.liveIntro,
                style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(height: GwSpacing.md),
            TextFormField(
              controller: _title,
              maxLength: 80,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: liveL10n.title, hintText: liveL10n.titleExample),
              validator: (v) => (v ?? '').trim().length < 3 ? liveL10n.titleMin3 : null,
            ),
            const SizedBox(height: GwSpacing.xs),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(liveL10n.now), icon: const Icon(Icons.podcasts)),
                ButtonSegment(value: true, label: Text(liveL10n.scheduleIt), icon: const Icon(Icons.event_outlined)),
              ],
              selected: {_later},
              onSelectionChanged: (s) => setState(() => _later = s.first),
            ),
            if (_later) ...[
              const SizedBox(height: GwSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(formatDateTime(_at)),
              ),
            ],
            if (minutes != null) ...[
              const SizedBox(height: GwSpacing.sm),
              Text(
                minutes > 0
                    ? liveL10n.minutesLeft(minutes)
                    : liveL10n.minutesUsedUp,
                style: textTheme.bodyMedium?.copyWith(color: minutes > 0 ? GwColors.textSecondary : GwColors.error),
              ),
            ],
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.md),
            if (_later)
              GwButton(label: liveL10n.scheduleIt, icon: Icons.event_available_outlined, isLoading: _busy, expand: true, onPressed: _submit)
            else
              GwLiveButton(label: liveL10n.startTheLive, expand: true, onPressed: _busy || noMinutes ? null : _submit),
          ],
        ),
      ),
    );
  }
}
