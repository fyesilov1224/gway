import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/live.dart';
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
              ? 'Bu yayın ${formatDateTimeTr(value.scheduledAt!)} tarihinde başlayacak.'
              : 'Bu yayın sona erdi.',
        ),
      AsyncError(error: NotFoundFailure()) => const _Closed(message: 'Bu yayın bulunamadı. Grubun üyesi olman gerekiyor olabilir.'),
      AsyncError(:final error) => Scaffold(
          appBar: AppBar(),
          body: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(liveBroadcastProvider(broadcastId))),
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
        body: GxEmptyState(
          icon: icon,
          message: message,
          actionLabel: 'Geri dön',
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
    final storage = ref.read(supabaseClientProvider).storage;
    _session = LiveSession(
      repository: ref.read(liveRepositoryProvider),
      broadcastId: _id,
      avatarUrl: (path) => storage.from('avatars').getPublicUrl(path),
    )..addListener(_onSession);
    unawaited(_session.connect());
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
      _snack(context, role.onStage ? 'Sahneye alındın. Mikrofonunu açarak konuşabilirsin.' : 'Artık dinleyicisin.');
    }
    _lastRole = role ?? _lastRole;
  }

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
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
          shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
          title: const Text('Yayından çık'),
          content: const Text('Yayını herkes için bitirebilirsin. Yalnızca ayrılırsan yayın 2 dakika sonra kendiliğinden biter.'),
          actions: [
            GxButton(label: 'Yalnızca ayrıl', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
            GxButton(label: 'Yayını bitir', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      );
      if (end == null) return;
      if (end) await _result(_repo.end(_id));
    }
    await _session.leave();
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
                }, color: a == LiveAction.kick ? GxColors.error : null),
                title: Text(
                  switch (a) {
                    LiveAction.inviteToStage => 'Sahneye al',
                    LiveAction.removeFromStage => 'Sahneden indir',
                    LiveAction.mute => 'Mikrofonunu kapat',
                    LiveAction.unmute => 'Mikrofonunu aç',
                    LiveAction.kick => 'Yayından çıkar',
                  },
                  style: a == LiveAction.kick ? const TextStyle(color: GxColors.error) : null,
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
          shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
          title: const Text('Yayından çıkar'),
          content: Text('${seat.name} bu yayına bir daha giremez.'),
          actions: [
            GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
            GxButton(label: 'Çıkar', onPressed: () => Navigator.of(context).pop(true)),
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
              ListTile(title: Text('El kaldıranlar', style: Theme.of(context).textTheme.titleMedium)),
              for (final s in hands)
                ListTile(
                  leading: GxAvatar(name: s.name, imageUrl: s.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                  title: Text(s.name),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      unawaited(_result(_repo.inviteToStage(_id, s.id)));
                    },
                    child: const Text('Sahneye al'),
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

  void _deleteComment(LiveComment c) => unawaited(_result(_repo.deleteComment(_id, c), done: 'Yorum silindi.'));

  @override
  Widget build(BuildContext context) {
    final b = widget.broadcast;
    final manager = ref.watch(isLiveManagerProvider(b)).value ?? false;
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        switch (_session.state) {
          case LiveSessionState.ended:
            return const _Closed(message: 'Yayın sona erdi. Katıldığın için teşekkürler.');
          case LiveSessionState.kicked:
            return const _Closed(message: 'Bu yayından çıkarıldın.', icon: Icons.block);
          case LiveSessionState.failed:
            return Scaffold(
              appBar: AppBar(),
              body: GxErrorState(message: _session.errorMessage ?? 'Yayına bağlanılamadı.', onRetry: _session.connect),
            );
          case LiveSessionState.connecting:
            return Scaffold(
              appBar: AppBar(title: Text(b.title)),
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: GxSpacing.md),
                  Text('Yayına bağlanılıyor…', style: textTheme.bodyLarge),
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
          padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.sm, GxSpacing.page, GxSpacing.xl),
          children: [
            if (manager && hands.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: GxSpacing.md),
                child: Material(
                  color: GxColors.secondarySoft,
                  borderRadius: GxRadius.lgAll,
                  child: ListTile(
                    shape: const RoundedRectangleBorder(borderRadius: GxRadius.lgAll),
                    leading: const Text('✋', style: TextStyle(fontSize: GxSpacing.lg)),
                    title: Text('${hands.length} kişi el kaldırdı', style: textTheme.labelLarge),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHands(hands),
                  ),
                ),
              ),
            Text('Sahnede', style: textTheme.titleSmall),
            const SizedBox(height: GxSpacing.sm),
            Wrap(
              spacing: GxSpacing.md,
              runSpacing: GxSpacing.md,
              children: [
                for (final s in stage)
                  _SeatTile(seat: s, large: true, onTap: () => _openSeat(s, manager: manager, myRank: myRank)),
              ],
            ),
            const SizedBox(height: GxSpacing.lg),
            Text('Dinleyiciler · ${formatCount(listeners.length)}', style: textTheme.titleSmall),
            const SizedBox(height: GxSpacing.sm),
            if (listeners.isEmpty)
              Text('Henüz dinleyici yok.', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary))
            else
              Wrap(
                spacing: GxSpacing.sm,
                runSpacing: GxSpacing.sm,
                children: [
                  for (final s in listeners) _SeatTile(seat: s, onTap: () => _openSeat(s, manager: manager, myRank: myRank)),
                ],
              ),
          ],
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(tooltip: 'Yayından çık', icon: const Icon(Icons.keyboard_arrow_down_rounded), onPressed: () => _leave(isHost: isHost)),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.group.name, style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
              ],
            ),
            actions: [
              const GxLiveBadge(),
              const SizedBox(width: GxSpacing.xs),
              _Elapsed(since: b.startedAt ?? DateTime.now()),
              const SizedBox(width: GxSpacing.sm),
              Icon(Icons.headphones_rounded, size: GxSpacing.md, color: GxColors.textSecondary, semanticLabel: '${seats.length} kişi'),
              const SizedBox(width: GxSpacing.xxs),
              Text(formatCount(seats.length), style: textTheme.labelMedium),
              if (manager)
                PopupMenuButton<void>(
                  tooltip: 'Yayın seçenekleri',
                  itemBuilder: (_) => [
                    PopupMenuItem(onTap: () => _result(_repo.end(_id)), child: const Text('Yayını herkes için bitir')),
                  ],
                )
              else
                const SizedBox(width: GxSpacing.sm),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    room,
                    Positioned(right: GxSpacing.md, bottom: 0, top: 0, width: GxSpacing.xxl, child: _Reactions(stream: _session.reactions)),
                  ],
                ),
              ),
              if (wide)
                Container(
                  width: GxLayout.formMaxWidth - GxSpacing.xxl * 2,
                  decoration: const BoxDecoration(border: Border(left: GxBorders.hairline)),
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
            onHand: (raise) => _result(_repo.setHand(_id, raised: raise), done: raise ? 'Elini kaldırdın. Sunucu seni sahneye alabilir.' : null),
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
    final size = large ? GxAvatarSize.lg : GxAvatarSize.md;
    final width = size.dimension + GxSpacing.lg;
    final micOff = seat.role.onStage && (!seat.micOn || seat.mutedByModerator);
    final status = [
      if (seat.isMe) 'Sen' else seat.name,
      seat.role.label,
      if (seat.speaking) 'konuşuyor',
      if (micOff) 'mikrofon kapalı',
      if (seat.handRaisedAt != null) 'el kaldırdı',
    ].join(', ');

    return Semantics(
      button: true,
      label: status,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: GxRadius.mdAll,
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
                    padding: const EdgeInsets.all(GxSpacing.xxs / 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: seat.speaking ? GxColors.primary : GxColors.background,
                        width: GxSpacing.xxs / 2,
                      ),
                    ),
                    child: GxAvatar(name: seat.name, imageUrl: seat.avatarUrl, shape: GxAvatarShape.user, size: size),
                  ),
                  if (micOff || seat.handRaisedAt != null)
                    Positioned(
                      right: -GxSpacing.xxs,
                      bottom: -GxSpacing.xxs,
                      child: Container(
                        padding: const EdgeInsets.all(GxSpacing.xxs),
                        decoration: const BoxDecoration(
                          color: GxColors.background,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(GxBorders.hairline),
                        ),
                        child: seat.handRaisedAt != null
                            ? const Text('✋', style: TextStyle(fontSize: GxSpacing.sm))
                            : Icon(Icons.mic_off_rounded,
                                size: GxSpacing.sm + GxSpacing.xxs,
                                color: seat.mutedByModerator ? GxColors.error : GxColors.textSecondary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: GxSpacing.xxs),
              Text(seat.isMe ? 'Sen' : seat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelMedium),
              if (seat.role != LiveRole.listener)
                Text(seat.role.label, style: textTheme.labelSmall?.copyWith(color: seat.role == LiveRole.host ? GxColors.primary : GxColors.textSecondary)),
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
      decoration: const BoxDecoration(color: GxColors.background, border: Border(top: GxBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showEmojis)
                Padding(
                  padding: const EdgeInsets.only(bottom: GxSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final e in LiveReactions.emojis)
                        IconButton(
                          tooltip: 'Tepki gönder',
                          onPressed: () => onReaction(e),
                          icon: Text(e, style: const TextStyle(fontSize: GxSpacing.lg)),
                        ),
                    ],
                  ),
                ),
              Row(
                children: [
                  GxButton(label: 'Ayrıl', variant: GxButtonVariant.secondary, onPressed: onLeave),
                  const Spacer(),
                  if (onStage && me!.role == LiveRole.speaker)
                    IconButton(tooltip: 'Sahneden in', icon: const Icon(Icons.voice_over_off_outlined), onPressed: onLeaveStage),
                  IconButton(
                    tooltip: 'Tepkiler',
                    isSelected: showEmojis,
                    icon: const Icon(Icons.add_reaction_outlined),
                    selectedIcon: const Icon(Icons.add_reaction),
                    onPressed: onToggleEmojis,
                  ),
                  if (onComments != null)
                    IconButton(tooltip: 'Yorumlar', icon: const Icon(Icons.chat_bubble_outline_rounded), onPressed: onComments),
                  const SizedBox(width: GxSpacing.xs),
                  if (onStage)
                    IconButton.filled(
                      tooltip: me!.mutedByModerator
                          ? 'Mikrofonunu yönetici kapattı'
                          : me.micOn
                              ? 'Mikrofonu kapat'
                              : 'Mikrofonu aç',
                      style: IconButton.styleFrom(
                        backgroundColor: me.micOn ? GxColors.primary : GxColors.surfaceMuted,
                        foregroundColor: me.micOn ? GxColors.onPrimary : GxColors.textPrimary,
                        minimumSize: const Size.square(GxSpacing.buttonHeight),
                      ),
                      onPressed: me.mutedByModerator ? null : () => onMic(!me.micOn),
                      icon: Icon(me.micOn ? Icons.mic_rounded : Icons.mic_off_rounded),
                    )
                  else
                    IconButton.filledTonal(
                      tooltip: me?.handRaisedAt == null ? 'El kaldır' : 'Elini indir',
                      style: IconButton.styleFrom(minimumSize: const Size.square(GxSpacing.buttonHeight)),
                      onPressed: me == null ? null : () => onHand(me.handRaisedAt == null),
                      icon: Text(me?.handRaisedAt == null ? '✋' : '👇', style: const TextStyle(fontSize: GxSpacing.lg)),
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
                    left: drift * (box.maxWidth - GxSpacing.xl) + sin(t * pi * 3) * GxSpacing.xs,
                    child: Opacity(opacity: (1 - t).clamp(0, 1), child: child),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: GxSpacing.xl)),
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
                title: const Text('Şikayet et'),
                onTap: () => Navigator.of(context).pop(false),
              ),
            if (mine || widget.manager)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: GxColors.error),
                title: const Text('Yorumu sil', style: TextStyle(color: GxColors.error)),
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
          padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.md, GxSpacing.xs),
          child: Row(children: [Text('Yorumlar', style: textTheme.titleSmall)]),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget.comments,
            builder: (context, comments, _) => comments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(GxSpacing.lg),
                      child: Text('İlk yorumu sen yaz.', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
                    itemCount: comments.length,
                    itemBuilder: (context, i) {
                      final c = comments[comments.length - 1 - i];
                      return InkWell(
                        onLongPress: () => _menu(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GxAvatar(name: c.author.displayName, imageUrl: c.author.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                              const SizedBox(width: GxSpacing.xs),
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
          padding: EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.xs, GxSpacing.xs, GxSpacing.xs + MediaQuery.viewInsetsOf(context).bottom),
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
                  decoration: const InputDecoration(hintText: 'Yorum yaz…', counterText: ''),
                ),
              ),
              IconButton(tooltip: 'Gönder', onPressed: _sending ? null : _send, icon: const Icon(Icons.send_rounded, color: GxColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
