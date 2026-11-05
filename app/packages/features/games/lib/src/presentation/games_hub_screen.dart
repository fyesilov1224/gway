import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../l10n.dart';
import 'appearance.dart';
import 'chess_board.dart';
import 'mind_providers.dart';
import 'mind_screens.dart';
import 'providers.dart';
import 'routes.dart';

/// Games (docs/ARCHITECTURE.md §3i, §3j): every game GWAY offers, one card each.
class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.games)),
      body: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          Text(gamesL10n.gamesIntro, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          const SizedBox(height: GwSpacing.lg),
          const _ChessCard(),
          const SizedBox(height: GwSpacing.md),
          const _MindCard(),
        ],
      ),
    );
  }
}

/// The chess card: a board, what is happening now and the way in.
class _ChessCard extends ConsumerWidget {
  const _ChessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final me = ref.watch(currentUserIdProvider);
    final pieces = ref.watch(currentPieceSetProvider).value;
    final theme = ref.watch(chessAppearanceProvider).board;
    final profile = me == null ? null : ref.watch(chessProfileProvider(me)).value;
    final arenas = ref.watch(arenasProvider).value;
    final invites = (ref.watch(challengesProvider).value ?? const <ChessChallenge>[]).where((c) => c.isIncomingFor(me)).length;
    final blitz = profile?.ratingOf(ChessCategory.blitz);

    final facts = [
      if (blitz != null && blitz.games > 0) (Icons.local_fire_department_outlined, gamesL10n.blitzRating(blitz.rating)),
      if (arenas != null && arenas.live.isNotEmpty) (Icons.emoji_events_rounded, gamesL10n.arenaLiveNow)
      else if (arenas != null && arenas.upcoming.isNotEmpty) (Icons.event_outlined, gamesL10n.nextArena(formatDateTime(arenas.upcoming.first.startsAt))),
      if (invites > 0) (Icons.mail_outline_rounded, gamesL10n.invitesWaiting(invites)),
    ];

    return GwCard(
      onTap: () => context.push(ChessRoutes.home),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A real board in the chosen colors and pieces, as the card's picture.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(GwRadius.xl)),
            child: Container(
              color: theme.dark.withValues(alpha: 0.18),
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: GwLayout.storyCardWidth * 0.6),
                  child: pieces == null
                      ? const AspectRatio(aspectRatio: 1, child: GwSkeleton(height: double.infinity))
                      : IgnorePointer(
                          child: ChessBoard(
                            fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4',
                            pieces: pieces,
                            theme: theme,
                            orientation: ChessColor.white,
                            lastMove: const ('g8', 'f6'),
                          ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gamesL10n.chess, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: GwSpacing.xxs),
                Text(gamesL10n.chessCardText, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: GwSpacing.sm),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xs,
                    children: [for (final (icon, text) in facts) GwTag(label: text, icon: icon, tone: GwTone.lilac)],
                  ),
                ],
                const SizedBox(height: GwSpacing.md),
                GwButton(label: gamesL10n.playChess, icon: Icons.play_arrow_rounded, expand: true, onPressed: () => context.push(ChessRoutes.home)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Zihin Düellosu card: one sample of each kind, the person's rating and the way in.
class _MindCard extends ConsumerWidget {
  const _MindCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final me = ref.watch(currentUserIdProvider);
    final profile = me == null ? null : ref.watch(mindProfileProvider(me)).value;
    final invites = (ref.watch(mindChallengesProvider).value ?? const []).where((c) => c.isIncomingFor(me)).length;
    final played = profile?.ratings.values.where((r) => r.games > 0).toList() ?? const [];
    final best = played.isEmpty ? null : played.reduce((a, b) => a.rating >= b.rating ? a : b);
    final facts = [
      if (best != null) (Icons.psychology_outlined, gamesL10n.mindBestRating(best.rating, best.length)),
      if (invites > 0) (Icons.mail_outline_rounded, gamesL10n.invitesWaiting(invites)),
    ];
    return GwCard(
      onTap: () => context.push(MindRoutes.home),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: GwColors.surfaceMuted,
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: GwLayout.storyCardWidth),
                child: const MindSampleStrip(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gamesL10n.mindDuel, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: GwSpacing.xxs),
                Text(gamesL10n.mindCardText, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: GwSpacing.sm),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xs,
                    children: [for (final (icon, text) in facts) GwTag(label: text, icon: icon, tone: GwTone.lilac)],
                  ),
                ],
                const SizedBox(height: GwSpacing.md),
                GwButton(label: gamesL10n.mindPlay, icon: Icons.play_arrow_rounded, expand: true, onPressed: () => context.push(MindRoutes.home)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
