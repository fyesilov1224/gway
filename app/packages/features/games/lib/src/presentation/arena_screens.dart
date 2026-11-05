import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/arena.dart';
import '../domain/chess.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// "45:12" left, or "2 sa 10 dk" for longer waits.
String _countdown(Duration d) {
  if (d.isNegative) return '0:00';
  if (d.inHours >= 1) return gamesL10n.hoursMinutes(d.inHours, d.inMinutes % 60);
  return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

/// Rebuilds every second while shown, for countdowns.
class _Ticker extends StatefulWidget {
  const _Ticker({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  late final Timer _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// The color of an arena by kind: weekly lilac, monthly gold, extra ones sky.
({Color soft, Color strong}) _arenaColors(ArenaKind kind) => switch (kind) {
  ArenaKind.weekly => (soft: GwColors.primarySoft, strong: GwColors.primary),
  ArenaKind.monthly => (soft: GwMedal.gold.soft, strong: GwMedal.gold.strong),
  ArenaKind.custom => (soft: GwColors.secondarySoft, strong: GwColors.secondary),
};

/// An arena as an event card: a colored banner with the trophy and the time control, the name, when (or the
/// countdown while live) and whether the reader joined.
class ArenaEventCard extends StatelessWidget {
  const ArenaEventCard({super.key, required this.arena, this.joined = false});

  static const double width = GwLayout.storyCardWidth * 0.72;

  /// The height in a horizontal row of cards (the card itself sizes to its content).
  static const double height = GwSpacing.xxl * 3 + GwSpacing.lg;

  final Arena arena;
  final bool joined;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final a = arena;
    final colors = _arenaColors(a.kind);
    final live = a.status == ArenaStatus.live;
    return GwCard(
      onTap: () => context.push(ChessRoutes.arena(a.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: GwSpacing.xxl + GwSpacing.md,
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
            decoration: BoxDecoration(
              color: colors.soft,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(GwRadius.xl)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: colors.strong, size: GwSpacing.xl),
                const SizedBox(width: GwSpacing.xs),
                Text(
                  a.timeControl.label,
                  style: textTheme.titleLarge?.copyWith(color: colors.strong, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (live) const GwLiveBadge(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${a.timeControl.category.label} · ${gamesL10n.minutesLong(a.length.inMinutes)}',
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
                const SizedBox(height: GwSpacing.sm),
                Row(
                  children: [
                    Icon(live ? Icons.timer_outlined : Icons.event_outlined, size: GwSpacing.md, color: GwColors.textSecondary),
                    const SizedBox(width: GwSpacing.xxs),
                    Expanded(
                      child: live
                          ? _Ticker(
                              builder: (_) => Text(
                                gamesL10n.arenaEndsIn(_countdown(a.endsAt.difference(DateTime.now()))),
                                style: textTheme.labelLarge?.copyWith(color: colors.strong),
                              ),
                            )
                          : Text(formatDateTime(a.startsAt), style: textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                    ),
                    if (joined) const Icon(Icons.check_circle_rounded, color: GwColors.success, size: GwSpacing.lg),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A finished arena in a list, with its podium.
class ArenaTile extends StatelessWidget {
  const ArenaTile({super.key, required this.arena, this.joined = false, this.podium = const []});

  final Arena arena;
  final bool joined;
  final List<ChessPlayer> podium;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final a = arena;
    final live = a.status == ArenaStatus.live;
    return GwCard(
      onTap: () => context.push(ChessRoutes.arena(a.id)),
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Row(
        children: [
          Container(
            width: GwAvatarSize.md.dimension,
            height: GwAvatarSize.md.dimension,
            decoration: BoxDecoration(color: live ? GwColors.primary : GwColors.primarySoft, borderRadius: GwRadius.mdAll),
            child: Icon(Icons.emoji_events_rounded, color: live ? GwColors.onPrimary : GwColors.primary),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name, style: textTheme.titleSmall),
                Text(
                  '${a.timeControl.label} · ${a.timeControl.category.label} · ${gamesL10n.minutesLong(a.length.inMinutes)}',
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
                if (podium.isNotEmpty) ...[
                  const SizedBox(height: GwSpacing.xxs),
                  Wrap(
                    spacing: GwSpacing.xs,
                    children: [
                      for (final (i, p) in podium.indexed)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RankBadge(rank: i + 1, size: GwSpacing.md + GwSpacing.xxs),
                            const SizedBox(width: GwSpacing.xxs),
                            Text(p.displayName, style: textTheme.labelSmall),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: GwSpacing.xs),
          if (live)
            _Ticker(
              builder: (_) => Text(_countdown(a.endsAt.difference(DateTime.now())), style: textTheme.titleSmall?.copyWith(color: GwColors.primary)),
            )
          else if (a.status == ArenaStatus.scheduled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatDateTime(a.startsAt), style: textTheme.labelMedium),
                if (joined) GwBadge(gamesL10n.registered, tone: GwBadgeTone.success),
              ],
            ),
        ],
      ),
    );
  }
}

/// Live, upcoming and finished arenas with their winners.
class ArenasScreen extends ConsumerWidget {
  const ArenasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(arenasProvider);
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.tournaments)),
      body: switch (lists) {
        AsyncData(value: final l) => RefreshIndicator(
          onRefresh: () => ref.refresh(arenasProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              Text(gamesL10n.arenaRules, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              if (l.live.isNotEmpty) ...[
                const SizedBox(height: GwSpacing.lg),
                GwSectionHeader(title: gamesL10n.arenaLiveNow),
                const SizedBox(height: GwSpacing.xs),
                for (final a in l.live)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GwSpacing.sm),
                    child: ArenaEventCard(arena: a, joined: l.joined.contains(a.id)),
                  ),
              ],
              const SizedBox(height: GwSpacing.lg),
              GwSectionHeader(title: gamesL10n.arenaUpcoming),
              const SizedBox(height: GwSpacing.xs),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth >= GwLayout.contentMaxWidth ? 3 : (c.maxWidth >= GwLayout.formMaxWidth ? 2 : 1);
                  return Wrap(
                    spacing: GwSpacing.sm,
                    runSpacing: GwSpacing.sm,
                    children: [
                      for (final a in l.upcoming)
                        SizedBox(
                          width: (c.maxWidth - GwSpacing.sm * (columns - 1)) / columns,
                          child: ArenaEventCard(arena: a, joined: l.joined.contains(a.id)),
                        ),
                    ],
                  );
                },
              ),
              if (l.finished.isNotEmpty) ...[
                const SizedBox(height: GwSpacing.lg),
                GwSectionHeader(title: gamesL10n.arenaFinished),
                const SizedBox(height: GwSpacing.xs),
                for (final r in l.finished)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GwSpacing.xs),
                    child: ArenaTile(arena: r.arena, podium: r.podium),
                  ),
              ],
            ],
          ),
        ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(arenasProvider)),
        _ => const Padding(
          padding: EdgeInsets.all(GwSpacing.page),
          child: GwSkeleton(height: GwSpacing.xxl * 4),
        ),
      },
    );
  }
}

/// One arena: the window and countdown, the reader's score and buttons, and the standings. While it is open and the
/// reader is paired, their game opens by itself.
class ArenaScreen extends ConsumerStatefulWidget {
  const ArenaScreen({super.key, required this.arenaId});

  final String arenaId;

  @override
  ConsumerState<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends ConsumerState<ArenaScreen> {
  String? _opened;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(arenaProvider(widget.arenaId), (_, next) {
      final game = next.value?.myGameId;
      // A new pairing opens the board; coming back from it does not reopen it.
      if (game != null && game != _opened && mounted) {
        _opened = game;
        unawaited(context.push(ChessRoutes.game(game)));
      }
    });
  }

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref
      ..invalidate(arenaProvider(widget.arenaId))
      ..invalidate(arenasProvider);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(arenaProvider(widget.arenaId));
    final me = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.arena.name ?? gamesL10n.arena)),
      body: switch (detail) {
        AsyncData(:final value) => _body(value, me),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(arenaProvider(widget.arenaId))),
        _ => const Padding(
          padding: EdgeInsets.all(GwSpacing.page),
          child: GwSkeleton(height: GwSpacing.xxl * 4),
        ),
      },
    );
  }

  Widget _body(ArenaDetail d, String? me) {
    final textTheme = Theme.of(context).textTheme;
    final a = d.arena;
    final repo = ref.read(arenaRepositoryProvider);
    final mine = d.standingOf(me);
    final live = a.status == ArenaStatus.live && a.endsAt.isAfter(DateTime.now());
    final scheduled = a.status == ArenaStatus.scheduled;

    final List<Widget> actions = switch ((scheduled, live, d.joined)) {
      (true, _, false) => [
        GwButton(label: gamesL10n.arenaRegister, icon: Icons.how_to_reg_outlined, expand: true, isLoading: _busy, onPressed: () => _run(() => repo.join(a.id))),
      ],
      (true, _, true) => [
        GwFormMessage(gamesL10n.arenaRegistered, kind: GwFormMessageKind.info),
        const SizedBox(height: GwSpacing.xs),
        GwButton(label: gamesL10n.withdraw, variant: GwButtonVariant.text, onPressed: _busy ? null : () => _run(() => repo.leave(a.id))),
      ],
      (_, true, _) when d.myGameId != null => [
        GwButton(label: gamesL10n.backToGame, icon: Icons.play_arrow_rounded, expand: true, onPressed: () => context.push(ChessRoutes.game(d.myGameId!))),
      ],
      (_, true, _) when mine?.waiting ?? false => [
        GwFormMessage(gamesL10n.arenaWaiting, kind: GwFormMessageKind.info),
        const SizedBox(height: GwSpacing.xs),
        GwButton(
          label: gamesL10n.arenaPause,
          icon: Icons.pause_rounded,
          variant: GwButtonVariant.secondary,
          expand: true,
          isLoading: _busy,
          onPressed: () => _run(() => repo.pause(a.id)),
        ),
      ],
      (_, true, _) => [
        GwButton(
          label: d.joined ? gamesL10n.arenaResume : gamesL10n.arenaJoin,
          icon: Icons.play_arrow_rounded,
          expand: true,
          isLoading: _busy,
          onPressed: () => _run(() => repo.join(a.id)),
        ),
      ],
      _ => const <Widget>[],
    };

    return RefreshIndicator(
      onRefresh: () => ref.refresh(arenaProvider(widget.arenaId).future),
      child: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          GwCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(GwSpacing.md),
                  decoration: BoxDecoration(
                    color: _arenaColors(a.kind).soft,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(GwRadius.xl)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, size: GwSpacing.xxl, color: _arenaColors(a.kind).strong),
                      const SizedBox(width: GwSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                            Text(formatDateTime(a.startsAt), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (a.status == ArenaStatus.live) const GwLiveBadge(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(GwSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: GwSpacing.xs,
                        runSpacing: GwSpacing.xs,
                        children: [
                          GwTag(
                            label: '${a.timeControl.label} · ${a.timeControl.category.label}',
                            icon: chessCategoryIcon(a.timeControl.category),
                            tone: GwTone.sky,
                          ),
                          GwTag(label: gamesL10n.minutesLong(a.length.inMinutes), icon: Icons.timer_outlined, tone: GwTone.mist),
                          GwTag(label: gamesL10n.playersCount(d.standings.length), icon: Icons.people_outline, tone: GwTone.mist),
                        ],
                      ),
                      const SizedBox(height: GwSpacing.md),
                      _Ticker(
                        builder: (_) => Text(switch (a.status) {
                          ArenaStatus.scheduled => gamesL10n.arenaStartsIn(_countdown(a.startsAt.difference(DateTime.now()))),
                          ArenaStatus.live =>
                            a.endsAt.isAfter(DateTime.now())
                                ? gamesL10n.arenaEndsIn(_countdown(a.endsAt.difference(DateTime.now())))
                                : gamesL10n.arenaLastGames,
                          ArenaStatus.finished => gamesL10n.arenaFinishedAt(formatDateTime(a.endsAt)),
                          ArenaStatus.canceled => gamesL10n.teamCanceled,
                        }, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                      if (mine != null && mine.games > 0) ...[
                        const SizedBox(height: GwSpacing.md),
                        Row(
                          children: [
                            RankBadge(rank: mine.rank),
                            const SizedBox(width: GwSpacing.sm),
                            Expanded(child: Text(gamesL10n.myArenaScore(mine.points, mine.games), style: textTheme.titleSmall)),
                            if (mine.onFire)
                              Tooltip(
                                message: gamesL10n.onFire,
                                child: const Icon(Icons.local_fire_department_rounded, color: GwColors.error),
                              ),
                          ],
                        ),
                      ],
                      if (actions.isNotEmpty) ...[const SizedBox(height: GwSpacing.md), ...actions],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (a.status == ArenaStatus.finished && d.standings.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.md),
            _ArenaPodium(standings: d.standings.take(3).toList()),
          ],
          const SizedBox(height: GwSpacing.sm),
          Text(gamesL10n.arenaRules, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
          const SizedBox(height: GwSpacing.lg),
          GwSectionHeader(title: gamesL10n.standings),
          const SizedBox(height: GwSpacing.xs),
          if (d.standings.isEmpty)
            Text(gamesL10n.arenaEmpty, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary))
          else
            GwCard(
              child: Column(
                children: [
                  for (final (i, s) in d.standings.indexed) ...[
                    if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                    _StandingRow(standing: s, isMe: s.player.userId == me),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, required this.isMe});

  final ArenaStanding standing;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final s = standing;
    return InkWell(
      onTap: () => context.push(ChessRoutes.player(s.player.userId)),
      child: Container(
        color: isMe ? GwColors.primarySoft : null,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
        child: Row(
          children: [
            RankBadge(rank: s.rank),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: ChessPlayerLine(
                player: s.player,
                size: GwAvatarSize.sm,
                subtitle: [
                  gamesL10n.record(s.wins, s.draws, s.losses),
                  if (s.performance != null) gamesL10n.performance(s.performance!),
                  if (s.playing) gamesL10n.playingNow,
                ].join(' · '),
              ),
            ),
            if (s.onFire)
              Padding(
                padding: const EdgeInsets.only(right: GwSpacing.xxs),
                child: Tooltip(
                  message: gamesL10n.onFire,
                  child: const Icon(Icons.local_fire_department_rounded, color: GwColors.error, size: GwSpacing.lg),
                ),
              ),
            Text('${s.points}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

/// The winners of a finished arena: second, first, third.
class _ArenaPodium extends StatelessWidget {
  const _ArenaPodium({required this.standings});

  final List<ArenaStanding> standings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    ArenaStanding? at(int i) => i < standings.length ? standings[i] : null;
    Widget step(ArenaStanding? s, double lift) {
      if (s == null) return SizedBox(height: lift);
      final medal = GwMedal.forRank(s.rank) ?? GwMedal.bronze;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwAvatar(name: s.player.displayName, shape: GwAvatarShape.user, imageUrl: s.player.avatarUrl, size: GwAvatarSize.lg),
          const SizedBox(height: GwSpacing.xxs),
          Text(s.player.displayName, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const SizedBox(height: GwSpacing.xs),
          Container(
            width: double.infinity,
            height: lift,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medal.soft, borderRadius: GwRadius.mdAll),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RankBadge(rank: s.rank, size: GwSpacing.lg),
                Text(
                  gamesL10n.pointsShort(s.points),
                  style: textTheme.labelLarge?.copyWith(color: medal.strong, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GwCard(
      padding: const EdgeInsets.fromLTRB(GwSpacing.sm, GwSpacing.lg, GwSpacing.sm, GwSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: step(at(1), GwSpacing.xxl + GwSpacing.md)),
          const SizedBox(width: GwSpacing.xs),
          Expanded(child: step(at(0), GwSpacing.xxl * 2)),
          const SizedBox(width: GwSpacing.xs),
          Expanded(child: step(at(2), GwSpacing.xxl + GwSpacing.xs)),
        ],
      ),
    );
  }
}
