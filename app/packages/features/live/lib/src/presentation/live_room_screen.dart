import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/live.dart';
import '../l10n.dart';
import 'live_session.dart';
import 'providers.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));

String _elapsed(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  return h > 0 ? '$h:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}' : '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}

/// A live audio room (docs/ARCHITECTURE.md §8): stage, listeners, hands, reactions and comments.
class LiveRoomScreen extends ConsumerWidget {
  const LiveRoomScreen({super.key, required this.broadcastId});

  final String broadcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcast = ref.watch(liveBroadcastProvider(broadcastId));
    return switch (broadcast) {
      AsyncData(:final value) when value.isLive => _Room(broadcast: value),
      AsyncData(:final value) => _Closed(
          message: value.status == LiveStatus.scheduled
              ? liveL10n.startsOn(formatDateTime(value.scheduledAt!))
              : liveL10n.ended,
        ),
      AsyncError(error: NotFoundFailure()) => _Closed(message: liveL10n.notFound),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(liveBroadcastProvider(broadcastId))),
        ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Closed extends StatelessWidget {
  const _Closed({required this.message, this.icon = Icons.podcasts_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: GwEmptyState(
          icon: icon,
          message: message,
          actionLabel: liveL10n.goBack,
          onAction: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      );
}

class _Room extends ConsumerStatefulWidget {
  const _Room({required this.broadcast});

  final LiveBroadcast broadcast;

  @override
  ConsumerState<_Room> createState() => _RoomState();
}

class _RoomState extends ConsumerState<_Room> {
  late final ActiveLive _active;
  late final LiveSession _session;
  final _comments = ValueNotifier<List<LiveComment>>(const []);
  StreamSubscription<LiveCommentChange>? _commentChanges;
  LiveRole? _lastRole;
  bool _showEmojis = false;

  LiveRepository get _repo => ref.read(liveRepositoryProvider);
  String get _id => widget.broadcast.id;

  @override
  void initState() {
    super.initState();
    // The connection outlives this screen: going back keeps the user in the room.
    _active = ref.read(activeLiveProvider.notifier);
    _session = _active.join(_id)..addListener(_onSession);
    _lastRole = _session.me?.role;
    unawaited(_loadComments());
  }

  Future<void> _loadComments() async {
    if (await _repo.comments(_id) case Ok(:final value) when mounted) _comments.value = value;
    _commentChanges = _repo.commentChanges(_id).listen((change) {
      _comments.value = switch (change) {
        LiveCommentAdded(:final comment) => [
            for (final c in _comments.value) if (c.id != comment.id) c,
            comment,
          ],
        LiveCommentRemoved(:final id) => [for (final c in _comments.value) if (c.id != id) c],
      };
    });
  }

  /// Tells people when the server moved them on or off the stage.
  void _onSession() {
    final role = _session.me?.role;
    if (role != null && _lastRole != null && role != _lastRole && mounted) {
      _snack(context, role.onStage ? liveL10n.onStageNow : liveL10n.nowListener);
    }
    _lastRole = role ?? _lastRole;
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _active.releaseIfInactive(_session);
    unawaited(_commentChanges?.cancel());
    _comments.dispose();
    super.dispose();
  }

  Future<void> _result(Future<Result<void>> action, {String? done}) async {
    final result = await action;
    if (!mounted) return;
    switch (result) {
      case Ok():
        if (done != null) _snack(context, done);
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
  }

  void _close() {
    ref
      ..invalidate(groupLiveProvider(widget.broadcast.group.id))
      ..invalidate(myLiveProvider);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _leave({required bool isHost}) async {
    if (isHost) {
      final end = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
          title: Text(liveL10n.leaveBroadcast),
          content: Text(liveL10n.leaveHostBody),
          actions: [
            GwButton(label: liveL10n.justLeave, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
            GwButton(label: liveL10n.endBroadcast, onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      );
      if (end == null) return;
      if (end) await _result(_repo.end(_id));
    }
    await _active.leave();
    if (mounted) _close();
  }

  Future<void> _openSeat(LiveSeat seat, {required bool manager, required int myRank}) async {
    final actions = liveActionsFor(manager: manager, myRank: myRank, target: seat.asTarget);
    if (actions.isEmpty) return;
    final action = await showModalBottomSheet<LiveAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(seat.name, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(seat.role.label)),
            for (final a in actions)
              ListTile(
                leading: Icon(switch (a) {
                  LiveAction.inviteToStage => Icons.record_voice_over_outlined,
                  LiveAction.removeFromStage => Icons.voice_over_off_outlined,
                  LiveAction.mute => Icons.mic_off_outlined,
                  LiveAction.unmute => Icons.mic_none_outlined,
                  LiveAction.kick => Icons.person_remove_outlined,
                }, color: a == LiveAction.kick ? GwColors.error : null),
                title: Text(
                  switch (a) {
                    LiveAction.inviteToStage => liveL10n.inviteToStage,
                    LiveAction.removeFromStage => liveL10n.removeFromStage,
                    LiveAction.mute => liveL10n.muteMic,
                    LiveAction.unmute => liveL10n.unmuteMic,
                    LiveAction.kick => liveL10n.kick,
                  },
                  style: a == LiveAction.kick ? const TextStyle(color: GwColors.error) : null,
                ),
                onTap: () => Navigator.of(context).pop(a),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == LiveAction.kick) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
          title: Text(liveL10n.kick),
          content: Text(liveL10n.kickBody(seat.name)),
          actions: [
            GwButton(label: liveL10n.cancelAction, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
            GwButton(label: liveL10n.remove, onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      );
      if (sure != true) return;
    }
    await _result(switch (action) {
      LiveAction.inviteToStage => _repo.inviteToStage(_id, seat.id),
      LiveAction.removeFromStage => _repo.removeFromStage(_id, seat.id),
      LiveAction.mute => _repo.setMuted(_id, seat.id, muted: true),
      LiveAction.unmute => _repo.setMuted(_id, seat.id, muted: false),
      LiveAction.kick => _repo.kick(_id, seat.id),
    });
  }

  Future<void> _showHands(List<LiveSeat> hands) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(liveL10n.raisedHands, style: Theme.of(context).textTheme.titleMedium)),
              for (final s in hands)
                ListTile(
                  leading: GwAvatar(name: s.name, imageUrl: s.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
                  title: Text(s.name),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      unawaited(_result(_repo.inviteToStage(_id, s.id)));
                    },
                    child: Text(liveL10n.inviteToStage),
                  ),
                ),
            ],
          ),
        ),
      );

  void _openComments(bool manager) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.7,
          child: _CommentsPanel(comments: _comments, manager: manager, onSend: _send, onDelete: _deleteComment),
        ),
      );

  Future<bool> _send(String body) async {
    final result = await _repo.comment(_id, body);
    if (result case Err(:final failure) when mounted) _snack(context, failure.userMessage);
    return result is Ok;
  }

  void _deleteComment(LiveComment c) => unawaited(_result(_repo.deleteComment(_id, c), done: liveL10n.commentDeleted));

  @override
  Widget build(BuildContext context) {
    final b = widget.broadcast;
    final manager = ref.watch(isLiveManagerProvider(b)).value ?? false;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        switch (_session.state) {
          case LiveSessionState.ended:
            return _Closed(message: liveL10n.thanksForJoining);
          case LiveSessionState.kicked:
            return _Closed(message: liveL10n.youWereKicked, icon: Icons.block);
          case LiveSessionState.failed:
            return Scaffold(
              appBar: AppBar(),
              body: GwErrorState(message: _session.errorMessage ?? liveL10n.connectFailedShort, onRetry: _session.connect),
            );
          case LiveSessionState.connecting:
            return Scaffold(
              appBar: AppBar(title: Text(b.title)),
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: GwSpacing.md),
                  Text(liveL10n.connecting, style: textTheme.bodyLarge),
                ]),
              ),
            );
          case LiveSessionState.connected:
        }

        final seats = _session.seats;
        final me = _session.me;
        final isHost = me?.role == LiveRole.host;
        final stage = [for (final s in seats) if (s.role.onStage) s]..sort((a, b) => a.role.index.compareTo(b.role.index));
        final listeners = [for (final s in seats) if (!s.role.onStage) s];
        final hands = _session.raisedHands;
        final myRank = me?.rank ?? 0;

        final room = ListView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, GwSpacing.xl),
          children: [
            if (manager && hands.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: GwSpacing.md),
                child: Material(
                  color: GwColors.secondarySoft,
                  borderRadius: GwRadius.lgAll,
                  child: ListTile(
                    shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll),
                    leading: const Text('✋', style: TextStyle(fontSize: GwSpacing.lg)),
                    title: Text(liveL10n.handsRaised(hands.length), style: textTheme.labelLarge),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHands(hands),
                  ),
                ),
              ),
            Text(liveL10n.onStage, style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.sm),
            Wrap(
              spacing: GwSpacing.md,
              runSpacing: GwSpacing.md,
              children: [
                for (final s in stage)
                  _SeatTile(seat: s, large: true, onTap: () => _openSeat(s, manager: manager, myRank: myRank)),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            Text(liveL10n.listeners(listeners.length), style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.sm),
            if (listeners.isEmpty)
              Text(liveL10n.noListeners, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
            else
              Wrap(
                spacing: GwSpacing.sm,
                runSpacing: GwSpacing.sm,
                children: [
                  for (final s in listeners) _SeatTile(seat: s, onTap: () => _openSeat(s, manager: manager, myRank: myRank)),
                ],
              ),
          ],
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(tooltip: liveL10n.minimize, icon: const Icon(Icons.keyboard_arrow_down_rounded), onPressed: _close),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.group.name, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
              ],
            ),
            actions: [
              const GwLiveBadge(),
              const SizedBox(width: GwSpacing.xs),
              _Elapsed(since: b.startedAt ?? DateTime.now()),
              const SizedBox(width: GwSpacing.sm),
              Icon(Icons.headphones_rounded, size: GwSpacing.md, color: GwColors.textSecondary, semanticLabel: liveL10n.peopleCount(seats.length)),
              const SizedBox(width: GwSpacing.xxs),
              Text(formatCount(seats.length), style: textTheme.labelMedium),
              if (manager)
                PopupMenuButton<void>(
                  tooltip: liveL10n.broadcastOptions,
                  itemBuilder: (_) => [
                    PopupMenuItem(onTap: () => _result(_repo.end(_id)), child: Text(liveL10n.endForAll)),
                  ],
                )
              else
                const SizedBox(width: GwSpacing.sm),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    room,
                    PositionedDirectional(end: GwSpacing.md, bottom: 0, top: 0, width: GwSpacing.xxl, child: _Reactions(stream: _session.reactions)),
                  ],
                ),
              ),
              if (wide)
                Container(
                  width: GwLayout.formMaxWidth - GwSpacing.xxl * 2,
                  decoration: const BoxDecoration(border: Border(left: GwBorders.hairline)),
                  child: _CommentsPanel(comments: _comments, manager: manager, onSend: _send, onDelete: _deleteComment),
                ),
            ],
          ),
          bottomNavigationBar: _ControlBar(
            me: me,
            showEmojis: _showEmojis,
            onToggleEmojis: () => setState(() => _showEmojis = !_showEmojis),
            onReaction: (e) => unawaited(_session.sendReaction(e)),
            onMic: (on) async {
              final error = await _session.setMicrophone(on);
              if (error != null && context.mounted) _snack(context, error);
            },
            onHand: (raise) => _result(_repo.setHand(_id, raised: raise), done: raise ? liveL10n.handRaised : null),
            onLeaveStage: () => _result(_repo.removeFromStage(_id, me!.id)),
            onComments: wide ? null : () => _openComments(manager),
            onLeave: () => _leave(isHost: isHost),
          ),
        );
      },
    );
  }
}

class _Elapsed extends StatelessWidget {
  const _Elapsed({required this.since});

  final DateTime since;

  @override
  Widget build(BuildContext context) => StreamBuilder<void>(
        stream: Stream<void>.periodic(const Duration(seconds: 1)),
        builder: (context, _) => Text(
          _elapsed(DateTime.now().difference(since)),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      );
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({required this.seat, required this.onTap, this.large = false});

  final LiveSeat seat;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = large ? GwAvatarSize.lg : GwAvatarSize.md;
    final width = size.dimension + GwSpacing.lg;
    final micOff = seat.role.onStage && (!seat.micOn || seat.mutedByModerator);
    final status = [
      if (seat.isMe) liveL10n.you else seat.name,
      seat.role.label,
      if (seat.speaking) liveL10n.speaking,
      if (micOff) liveL10n.micOffState,
      if (seat.handRaisedAt != null) liveL10n.handUp,
    ].join(', ');

    return Semantics(
      button: true,
      label: status,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: GwRadius.mdAll,
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(GwSpacing.xxs / 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: seat.speaking ? GwColors.primary : GwColors.background,
                        width: GwSpacing.xxs / 2,
                      ),
                    ),
                    child: GwAvatar(name: seat.name, imageUrl: seat.avatarUrl, shape: GwAvatarShape.user, size: size),
                  ),
                  if (micOff || seat.handRaisedAt != null)
                    PositionedDirectional(
                      end: -GwSpacing.xxs,
                      bottom: -GwSpacing.xxs,
                      child: Container(
                        padding: const EdgeInsets.all(GwSpacing.xxs),
                        decoration: const BoxDecoration(
                          color: GwColors.background,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(GwBorders.hairline),
                        ),
                        child: seat.handRaisedAt != null
                            ? const Text('✋', style: TextStyle(fontSize: GwSpacing.sm))
                            : Icon(Icons.mic_off_rounded,
                                size: GwSpacing.sm + GwSpacing.xxs,
                                color: seat.mutedByModerator ? GwColors.error : GwColors.textSecondary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: GwSpacing.xxs),
              Text(seat.isMe ? liveL10n.you : seat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelMedium),
              if (seat.role != LiveRole.listener)
                Text(seat.role.label, style: textTheme.labelSmall?.copyWith(color: seat.role == LiveRole.host ? GwColors.primary : GwColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.me,
    required this.showEmojis,
    required this.onToggleEmojis,
    required this.onReaction,
    required this.onMic,
    required this.onHand,
    required this.onLeaveStage,
    required this.onComments,
    required this.onLeave,
  });

  final LiveSeat? me;
  final bool showEmojis;
  final VoidCallback onToggleEmojis;
  final ValueChanged<String> onReaction;
  final ValueChanged<bool> onMic;
  final ValueChanged<bool> onHand;
  final VoidCallback onLeaveStage;
  final VoidCallback? onComments;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    final onStage = me?.role.onStage ?? false;
    return DecoratedBox(
      decoration: const BoxDecoration(color: GwColors.background, border: Border(top: GwBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showEmojis)
                Padding(
                  padding: const EdgeInsets.only(bottom: GwSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final e in LiveReactions.emojis)
                        IconButton(
                          tooltip: liveL10n.sendReaction,
                          onPressed: () => onReaction(e),
                          icon: Text(e, style: const TextStyle(fontSize: GwSpacing.lg)),
                        ),
                    ],
                  ),
                ),
              Row(
                children: [
                  GwButton(label: liveL10n.leave, variant: GwButtonVariant.secondary, onPressed: onLeave),
                  const Spacer(),
                  if (onStage && me!.role == LiveRole.speaker)
                    IconButton(tooltip: liveL10n.leaveStage, icon: const Icon(Icons.voice_over_off_outlined), onPressed: onLeaveStage),
                  IconButton(
                    tooltip: liveL10n.reactions,
                    isSelected: showEmojis,
                    icon: const Icon(Icons.add_reaction_outlined),
                    selectedIcon: const Icon(Icons.add_reaction),
                    onPressed: onToggleEmojis,
                  ),
                  if (onComments != null)
                    IconButton(tooltip: liveL10n.comments, icon: const Icon(Icons.chat_bubble_outline_rounded), onPressed: onComments),
                  const SizedBox(width: GwSpacing.xs),
                  if (onStage)
                    IconButton.filled(
                      tooltip: me!.mutedByModerator
                          ? liveL10n.micMutedByMod
                          : me.micOn
                              ? liveL10n.micOff
                              : liveL10n.micOn,
                      style: IconButton.styleFrom(
                        backgroundColor: me.micOn ? GwColors.primary : GwColors.surfaceMuted,
                        foregroundColor: me.micOn ? GwColors.onPrimary : GwColors.textPrimary,
                        minimumSize: const Size.square(GwSpacing.buttonHeight),
                      ),
                      onPressed: me.mutedByModerator ? null : () => onMic(!me.micOn),
                      icon: Icon(me.micOn ? Icons.mic_rounded : Icons.mic_off_rounded),
                    )
                  else
                    IconButton.filledTonal(
                      tooltip: me?.handRaisedAt == null ? liveL10n.raiseHand : liveL10n.lowerHand,
                      style: IconButton.styleFrom(minimumSize: const Size.square(GwSpacing.buttonHeight)),
                      onPressed: me == null ? null : () => onHand(me.handRaisedAt == null),
                      icon: Text(me?.handRaisedAt == null ? '✋' : '👇', style: const TextStyle(fontSize: GwSpacing.lg)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Emojis float up and fade out.
class _Reactions extends StatefulWidget {
  const _Reactions({required this.stream});

  final Stream<String> stream;

  @override
  State<_Reactions> createState() => _ReactionsState();
}

class _ReactionsState extends State<_Reactions> {
  final _floating = <(int, String, double)>[];
  final _random = Random();
  late final StreamSubscription<String> _sub;
  int _next = 0;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((emoji) {
      if (_floating.length > 30) return;
      final key = _next++;
      setState(() => _floating.add((key, emoji, _random.nextDouble())));
      Future<void>.delayed(const Duration(milliseconds: 2400), () {
        if (mounted) setState(() => _floating.removeWhere((f) => f.$1 == key));
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              for (final (key, emoji, drift) in _floating)
                TweenAnimationBuilder<double>(
                  key: ValueKey(key),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 2400),
                  curve: Curves.easeOut,
                  builder: (context, t, child) => Positioned(
                    bottom: t * box.maxHeight * 0.7,
                    left: drift * (box.maxWidth - GwSpacing.xl) + sin(t * pi * 3) * GwSpacing.xs,
                    child: Opacity(opacity: (1 - t).clamp(0, 1), child: child),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: GwSpacing.xl)),
                ),
            ],
          ),
        ),
      );
}

class _CommentsPanel extends ConsumerStatefulWidget {
  const _CommentsPanel({required this.comments, required this.manager, required this.onSend, required this.onDelete});

  final ValueNotifier<List<LiveComment>> comments;
  final bool manager;
  final Future<bool> Function(String body) onSend;
  final ValueChanged<LiveComment> onDelete;

  @override
  ConsumerState<_CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<_CommentsPanel> {
  final _input = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    if (await widget.onSend(body)) _input.clear();
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _menu(LiveComment c) async {
    final mine = c.author.id == ref.read(currentUserIdProvider);
    final delete = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(liveL10n.report),
                onTap: () => Navigator.of(context).pop(false),
              ),
            if (mine || widget.manager)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: GwColors.error),
                title: Text(liveL10n.deleteComment, style: const TextStyle(color: GwColors.error)),
                onTap: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (delete == true) widget.onDelete(c);
    if (delete == false) await ref.read(reportLauncherProvider)(context, ReportTarget.liveComment(c.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.sm, GwSpacing.md, GwSpacing.xs),
          child: Row(children: [Text(liveL10n.comments, style: textTheme.titleSmall)]),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget.comments,
            builder: (context, comments, _) => comments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(GwSpacing.lg),
                      child: Text(liveL10n.firstComment, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
                    itemCount: comments.length,
                    itemBuilder: (context, i) {
                      final c = comments[comments.length - 1 - i];
                      return InkWell(
                        onLongPress: () => _menu(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GwAvatar(name: c.author.displayName, imageUrl: c.author.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
                              const SizedBox(width: GwSpacing.xs),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: '${c.author.username} ', style: textTheme.labelLarge),
                                    TextSpan(text: c.body),
                                  ]),
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(GwSpacing.md, GwSpacing.xs, GwSpacing.xs, GwSpacing.xs + MediaQuery.viewInsetsOf(context).bottom),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  maxLength: 300,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(hintText: liveL10n.writeComment, counterText: ''),
                ),
              ),
              IconButton(tooltip: liveL10n.send, onPressed: _sending ? null : _send, icon: const Icon(Icons.send_rounded, color: GwColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
