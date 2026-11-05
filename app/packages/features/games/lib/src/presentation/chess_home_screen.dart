import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../l10n.dart';
import 'player_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'sheets.dart';
import 'widgets.dart';

/// Chess home (docs/ARCHITECTURE.md §3i, Uygulama): the person's card, a running game to return to, open
/// invitations, the quick-game grid, the top three and recent games.
class ChessHomeScreen extends ConsumerWidget {
  const ChessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    if (me == null) return const SizedBox.shrink();
    final profile = ref.watch(chessProfileProvider(me));
    final active = ref.watch(activeGameProvider).value;
    final challenges = ref.watch(challengesProvider).value ?? const <ChessChallenge>[];
    final games = ref.watch(recentGamesProvider(me));
    final top = ref.watch(leaderboardProvider(ChessCategory.blitz));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(gamesL10n.chess),
        actions: [
          IconButton(
            tooltip: gamesL10n.leaderboard,
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push(ChessRoutes.leaderboard),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(activeGameProvider)
            ..invalidate(challengesProvider)
            ..invalidate(recentGamesProvider(me))
            ..invalidate(leaderboardProvider(ChessCategory.blitz));
          await ref.read(chessProfileProvider(me).future);
        },
        child: ListView(
          padding: const EdgeInsets.all(GwSpacing.page),
          children: [
            switch (profile) {
              AsyncData(:final value) => _FirstFlag(profile: value, child: ChessIdentityCard(profile: value, isMe: true)),
              AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(chessProfileProvider(me))),
              _ => const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.xlAll),
            },
            if (active != null) ...[
              const SizedBox(height: GwSpacing.md),
              _ResumeBanner(game: active),
            ],
            if (challenges.isNotEmpty) ...[
              const SizedBox(height: GwSpacing.lg),
              GwSectionHeader(title: gamesL10n.invitations),
              const SizedBox(height: GwSpacing.xs),
              for (final c in challenges)
                Padding(padding: const EdgeInsets.only(bottom: GwSpacing.xs), child: _ChallengeCard(challenge: c, me: me)),
            ],
            const SizedBox(height: GwSpacing.lg),
            GwSectionHeader(title: gamesL10n.quickGame, subtitle: gamesL10n.quickGameHint),
            const SizedBox(height: GwSpacing.xs),
            const _QuickGrid(),
            const SizedBox(height: GwSpacing.sm),
            GwButton(
              label: gamesL10n.challengeFriend,
              icon: Icons.person_add_alt_1_outlined,
              variant: GwButtonVariant.secondary,
              expand: true,
              onPressed: () async {
                if (await showChallengeSheet(context) && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gamesL10n.challengeSent)));
                }
              },
            ),
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
                      for (final e in value.take(3))
                        ListTile(
                          leading: RankBadge(rank: e.rank),
                          title: ChessPlayerLine(player: e.player, size: GwAvatarSize.sm),
                          trailing: Text('${e.rating}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          onTap: () => context.push(ChessRoutes.player(e.player.userId)),
                        ),
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
                  onAction: () => context.push(ChessRoutes.seek(TimeControl.standard)),
                ),
              AsyncData(:final value) => GameHistory(games: value),
              _ => const GwSkeleton(height: GwSpacing.xxl * 2),
            },
          ],
        ),
      ),
    );
  }
}

/// On the first visit, asks once for the flag the leaderboard shows.
class _FirstFlag extends ConsumerStatefulWidget {
  const _FirstFlag({required this.profile, required this.child});

  final ChessProfile profile;
  final Widget child;

  @override
  ConsumerState<_FirstFlag> createState() => _FirstFlagState();
}

class _FirstFlagState extends ConsumerState<_FirstFlag> {
  @override
  Widget build(BuildContext context) {
    if (widget.profile.player.country != null) return widget.child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.child,
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
  Widget build(BuildContext context) => GwCard(
        onTap: () => context.push(ChessRoutes.game(game.id)),
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(GwSpacing.xs),
              decoration: const BoxDecoration(color: GwColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: GwColors.onPrimary),
            ),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gamesL10n.gameInProgress, style: Theme.of(context).textTheme.titleSmall),
                  Text('${game.timeControl.label} · ${game.timeControl.category.label}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text(gamesL10n.resume, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: GwColors.primary)),
          ],
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

/// The nine time controls as a 3 × 3 grid, by category.
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = [
      for (final c in ChessCategory.values) [for (final tc in TimeControl.catalog) if (tc.category == c) tc],
    ];
    return Column(
      children: [
        for (final (i, row) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: GwSpacing.xs),
          Row(
            children: [
              for (final (j, tc) in row.indexed) ...[
                if (j > 0) const SizedBox(width: GwSpacing.xs),
                Expanded(
                  child: GwCard(
                    radius: GwRadius.lgAll,
                    onTap: () => context.push(ChessRoutes.seek(tc)),
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.md, horizontal: GwSpacing.xs),
                    child: Column(
                      children: [
                        Icon(chessCategoryIcon(tc.category), color: GwColors.primary),
                        const SizedBox(height: GwSpacing.xxs),
                        Text(tc.label, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        Text(tc.category.label, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
              // Bullet has two controls: keep the tiles the same width as the rows below.
              if (row.length < 4) ...[
                for (var k = row.length; k < 4; k++) ...[const SizedBox(width: GwSpacing.xs), const Expanded(child: SizedBox.shrink())],
              ],
            ],
          ),
        ],
      ],
    );
  }
}
