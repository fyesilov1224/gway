import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../domain/team.dart';
import '../l10n.dart';
import 'appearance.dart';
import 'arena_screens.dart';
import 'chess_board.dart';
import 'player_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'sheets.dart';
import 'team_screens.dart';
import 'widgets.dart';

/// Chess home (docs/ARCHITECTURE.md §3i, Uygulama): a running game first, then the play panel (time control and
/// "find an opponent"), the four ways in (friend, tournaments, team matches, leaderboard), invitations, tournaments,
/// team matches; beside them (below on phones) the person's ratings and medals, the top of the leaderboard and recent games.
class ChessHomeScreen extends ConsumerStatefulWidget {
  const ChessHomeScreen({super.key});

  @override
  ConsumerState<ChessHomeScreen> createState() => _ChessHomeScreenState();
}

class _ChessHomeScreenState extends ConsumerState<ChessHomeScreen> {
  TimeControl _tc = const TimeControl(180, 2);

  Future<void> _refresh(String me) async {
    ref
      ..invalidate(activeGameProvider)
      ..invalidate(challengesProvider)
      ..invalidate(recentGamesProvider(me))
      ..invalidate(leaderboardProvider(ChessCategory.blitz))
      ..invalidate(myTeamMatchesProvider)
      ..invalidate(captainGroupsProvider)
      ..invalidate(arenasProvider)
      ..invalidate(chessProfileProvider(me));
    await ref.read(chessProfileProvider(me).future);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserIdProvider);
    if (me == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(chessProfileProvider(me));
    final active = ref.watch(activeGameProvider).value;
    final challenges = ref.watch(challengesProvider).value ?? const <ChessChallenge>[];
    final games = ref.watch(recentGamesProvider(me));
    final top = ref.watch(leaderboardProvider(ChessCategory.blitz));
    final teamMatches = ref.watch(myTeamMatchesProvider).value ?? const <TeamMatch>[];
    final captainOf = ref.watch(captainGroupsProvider).value ?? const <ChessGroup>[];
    final arenas = ref.watch(arenasProvider).value;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;

    final liveArena = arenas?.live.firstOrNull;
    final nextArena = arenas?.upcoming.firstOrNull;
    final openTeam = teamMatches.where((m) => m.status.isOpen || m.status == TeamMatchStatus.live).length;
    final blitzRank = profile.value?.ranks[ChessCategory.blitz];

    final tiles = [
      _Way(
        icon: Icons.person_add_alt_1_rounded,
        tone: GwTone.lilac,
        title: gamesL10n.challengeFriend,
        subtitle: gamesL10n.challengeFriendHint,
        onTap: () async {
          if (await showChallengeSheet(context) && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gamesL10n.challengeSent)));
          }
        },
      ),
      _Way(
        icon: Icons.emoji_events_rounded,
        tone: GwTone.sky,
        title: gamesL10n.tournaments,
        subtitle: liveArena != null
            ? gamesL10n.arenaLiveNow
            : nextArena != null
                ? formatDateTime(nextArena.startsAt)
                : gamesL10n.tournamentsHint,
        live: liveArena != null,
        onTap: () => context.push(ChessRoutes.arenas),
      ),
      _Way(
        icon: Icons.groups_rounded,
        tone: GwTone.sky,
        title: gamesL10n.teamMatches,
        subtitle: openTeam > 0 ? gamesL10n.openTeamMatches(openTeam) : gamesL10n.teamMatchesHint,
        onTap: () => captainOf.isNotEmpty && teamMatches.isEmpty
            ? showCreateTeamMatchSheet(context, mine: captainOf)
            : context.push(ChessRoutes.leaderboardGroups),
      ),
      _Way(
        icon: Icons.leaderboard_rounded,
        tone: GwTone.lilac,
        title: gamesL10n.leaderboard,
        subtitle: blitzRank != null ? gamesL10n.rankShort(blitzRank) : gamesL10n.leaderboardHint,
        onTap: () => context.push(ChessRoutes.leaderboard),
      ),
    ];

    final main = <Widget>[
      if (active != null) ...[_ResumeBanner(game: active), const SizedBox(height: GwSpacing.md)],
      _PlayPanel(selected: _tc, onSelect: (tc) => setState(() => _tc = tc)),
      const SizedBox(height: GwSpacing.md),
      LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth >= GwLayout.formMaxWidth ? 4 : 2;
          return Wrap(
            spacing: GwSpacing.sm,
            runSpacing: GwSpacing.sm,
            children: [
              for (final t in tiles) SizedBox(width: (c.maxWidth - GwSpacing.sm * (columns - 1)) / columns, child: t),
            ],
          );
        },
      ),
      if (challenges.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.lg),
        GwSectionHeader(title: gamesL10n.invitations),
        const SizedBox(height: GwSpacing.xs),
        for (final c in challenges) Padding(padding: const EdgeInsets.only(bottom: GwSpacing.xs), child: _ChallengeCard(challenge: c, me: me)),
      ],
      if (arenas != null && (arenas.live.isNotEmpty || arenas.upcoming.isNotEmpty)) ...[
        const SizedBox(height: GwSpacing.lg),
        GwSectionHeader(
          title: gamesL10n.tournaments,
          subtitle: gamesL10n.tournamentsHint,
          actionLabel: gamesL10n.seeAll,
          onAction: () => context.push(ChessRoutes.arenas),
        ),
        const SizedBox(height: GwSpacing.xs),
        SizedBox(
          height: ArenaEventCard.height,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final a in [...arenas.live, ...arenas.upcoming.take(4)])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: GwSpacing.sm),
                  child: SizedBox(
                    width: ArenaEventCard.width,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: ArenaEventCard(arena: a, joined: arenas.joined.contains(a.id)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      if (teamMatches.isNotEmpty || captainOf.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.lg),
        GwSectionHeader(
          title: gamesL10n.teamMatches,
          subtitle: gamesL10n.teamMatchesHint,
          actionLabel: captainOf.isEmpty ? null : gamesL10n.newTeamMatch,
          onAction: captainOf.isEmpty ? null : () => showCreateTeamMatchSheet(context, mine: captainOf),
        ),
        const SizedBox(height: GwSpacing.xs),
        for (final m in teamMatches.take(4)) Padding(padding: const EdgeInsets.only(bottom: GwSpacing.xs), child: TeamMatchTile(match: m)),
        if (teamMatches.isEmpty) Text(gamesL10n.noTeamMatches, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
      ],
    ];

    final side = <Widget>[
      switch (profile) {
        AsyncData(:final value) => _FirstFlag(profile: value, child: ChessIdentityCard(profile: value, isMe: true)),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(chessProfileProvider(me))),
        _ => const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.xlAll),
      },
      const SizedBox(height: GwSpacing.lg),
      GwSectionHeader(
        title: gamesL10n.leaderboard,
        subtitle: ChessCategory.blitz.label,
        actionLabel: gamesL10n.seeAll,
        onAction: () => context.push(ChessRoutes.leaderboard),
      ),
      const SizedBox(height: GwSpacing.xs),
      switch (top) {
        AsyncData(:final value) when value.isEmpty => Text(
            gamesL10n.leaderboardEmpty(ChessRating.rankedAfter),
            style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
        AsyncData(:final value) => GwCard(
            child: Column(
              children: [
                for (final (i, e) in value.take(5).indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                  InkWell(
                    onTap: () => context.push(ChessRoutes.player(e.player.userId)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
                      child: Row(
                        children: [
                          RankBadge(rank: e.rank, size: GwSpacing.lg + GwSpacing.xxs),
                          const SizedBox(width: GwSpacing.sm),
                          Expanded(child: ChessPlayerLine(player: e.player, size: GwAvatarSize.sm)),
                          Text('${e.rating}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        _ => const GwSkeleton(height: GwSpacing.xxl * 2),
      },
      const SizedBox(height: GwSpacing.lg),
      GwSectionHeader(title: gamesL10n.recentGames),
      const SizedBox(height: GwSpacing.xs),
      switch (games) {
        AsyncData(:final value) when value.isEmpty => GwEmptyState(
            icon: Icons.sports_esports_outlined,
            message: gamesL10n.noGamesMine,
            actionLabel: gamesL10n.playNow,
            onAction: () => context.push(ChessRoutes.seek(_tc)),
          ),
        AsyncData(:final value) => GameHistory(games: value.take(8).toList()),
        _ => const GwSkeleton(height: GwSpacing.xxl * 2),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(gamesL10n.chess),
        actions: [
          IconButton(tooltip: gamesL10n.appearance, icon: const Icon(Icons.palette_outlined), onPressed: () => showAppearanceSheet(context)),
          IconButton(
            tooltip: gamesL10n.leaderboard,
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push(ChessRoutes.leaderboard),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(me),
        child: wide
            ? ListView(
                padding: const EdgeInsets.all(GwSpacing.page),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: main)),
                      const SizedBox(width: GwSpacing.lg),
                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side)),
                    ],
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(GwSpacing.page),
                children: [...main, const SizedBox(height: GwSpacing.lg), ...side],
              ),
      ),
    );
  }
}

/// The play panel: a board picture, the time controls by category, and "find an opponent".
class _PlayPanel extends ConsumerWidget {
  const _PlayPanel({required this.selected, required this.onSelect});

  final TimeControl selected;
  final ValueChanged<TimeControl> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final pieces = ref.watch(currentPieceSetProvider).value;
    final theme = ref.watch(chessAppearanceProvider).board;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: GwAvatarSize.xl.dimension,
                child: pieces == null
                    ? const GwSkeleton(height: double.infinity)
                    : IgnorePointer(
                        child: ChessBoard(
                          fen: 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
                          pieces: pieces,
                          theme: theme,
                          orientation: ChessColor.white,
                          lastMove: const ('g1', 'f3'),
                        ),
                      ),
              ),
              const SizedBox(width: GwSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gamesL10n.playOnline, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: GwSpacing.xxs),
                    Text(gamesL10n.quickGameHint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GwSpacing.md),
          for (final c in ChessCategory.values) ...[
            Row(
              children: [
                Icon(chessCategoryIcon(c), size: GwSpacing.md, color: GwColors.textSecondary),
                const SizedBox(width: GwSpacing.xxs),
                Text(c.label, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
            const SizedBox(height: GwSpacing.xxs),
            Row(
              children: [
                for (final (i, tc) in TimeControl.catalog.where((t) => t.category == c).indexed) ...[
                  if (i > 0) const SizedBox(width: GwSpacing.xs),
                  Expanded(child: _TimeChip(tc: tc, selected: tc == selected, onTap: () => onSelect(tc))),
                ],
                // Bullet has two controls: keep the chips as wide as in the rows below.
                for (var k = TimeControl.catalog.where((t) => t.category == c).length; k < 4; k++) ...[
                  const SizedBox(width: GwSpacing.xs),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
            const SizedBox(height: GwSpacing.sm),
          ],
          GwButton(
            label: gamesL10n.findOpponent(selected.label),
            icon: Icons.play_arrow_rounded,
            expand: true,
            onPressed: () => context.push(ChessRoutes.seek(selected)),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.tc, required this.selected, required this.onTap});

  final TimeControl tc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: GwRadius.mdAll,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? GwColors.primary : GwColors.surface,
              borderRadius: GwRadius.mdAll,
              border: Border.all(color: selected ? GwColors.primary : GwColors.border),
            ),
            child: Text(
              tc.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? GwColors.onPrimary : GwColors.textPrimary,
                  ),
            ),
          ),
        ),
      );
}

/// One of the four ways in.
class _Way extends StatelessWidget {
  const _Way({required this.icon, required this.tone, required this.title, required this.subtitle, required this.onTap, this.live = false});

  final IconData icon;
  final GwTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      radius: GwRadius.lgAll,
      onTap: onTap,
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(GwSpacing.xs),
                decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
                child: Icon(icon, color: tone.strong),
              ),
              const Spacer(),
              if (live) const GwLiveBadge(),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// On the first visit, asks once for the flag the leaderboard shows.
class _FirstFlag extends ConsumerWidget {
  const _FirstFlag({required this.profile, required this.child});

  final ChessProfile profile;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile.player.country != null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: GwSpacing.sm),
        GwCard(
          onTap: () => showCountryPicker(context, ref),
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: GwColors.primary),
              const SizedBox(width: GwSpacing.sm),
              Expanded(child: Text(gamesL10n.pickFlagPrompt)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.game});

  final ChessGame game;

  @override
  Widget build(BuildContext context) => Material(
        color: GwColors.primary,
        borderRadius: GwRadius.xlAll,
        child: InkWell(
          borderRadius: GwRadius.xlAll,
          onTap: () => context.push(ChessRoutes.game(game.id)),
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill_rounded, color: GwColors.onPrimary, size: GwSpacing.xl),
                const SizedBox(width: GwSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gamesL10n.gameInProgress, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: GwColors.onPrimary)),
                      Text('${game.timeControl.label} · ${game.timeControl.category.label}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.onPrimary)),
                    ],
                  ),
                ),
                Text(gamesL10n.resume, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: GwColors.onPrimary)),
              ],
            ),
          ),
        ),
      );
}

class _ChallengeCard extends ConsumerStatefulWidget {
  const _ChallengeCard({required this.challenge, required this.me});

  final ChessChallenge challenge;
  final String me;

  @override
  ConsumerState<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<_ChallengeCard> {
  bool _busy = false;

  Future<void> _run(Future<Result<Object?>> Function() action, {bool open = false}) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value) when open && value is String:
        ref.invalidate(activeGameProvider);
        unawaited(context.push(ChessRoutes.game(value)));
      case Ok():
        break;
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref.invalidate(challengesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final repo = ref.read(chessRepositoryProvider);
    final incoming = c.isIncomingFor(widget.me);
    final other = c.other;
    final what = '${c.timeControl.label} · ${c.timeControl.category.label} · ${c.rated ? gamesL10n.rated : gamesL10n.casual}';
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (other != null)
            ChessPlayerLine(
              player: other,
              subtitle: incoming ? (c.rematchOf != null ? gamesL10n.wantsRematch(what) : gamesL10n.invitesYou(what)) : gamesL10n.waitingFor(what),
            ),
          const SizedBox(height: GwSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: incoming
                ? [
                    TextButton(onPressed: _busy ? null : () => _run(() => repo.decline(c.id)), child: Text(gamesL10n.decline)),
                    const SizedBox(width: GwSpacing.xs),
                    FilledButton(onPressed: _busy ? null : () => _run(() => repo.accept(c.id), open: true), child: Text(gamesL10n.accept)),
                  ]
                : [TextButton(onPressed: _busy ? null : () => _run(() => repo.cancelChallenge(c.id)), child: Text(gamesL10n.withdraw))],
          ),
        ],
      ),
    );
  }
}
