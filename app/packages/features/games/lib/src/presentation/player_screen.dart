import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'sheets.dart';
import 'widgets.dart';

/// A chess player page: identity card with flag, the three ratings with rank medals, the record and
/// recent games; others can be invited from here.
class ChessPlayerScreen extends ConsumerWidget {
  const ChessPlayerScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(chessProfileProvider(userId));
    final games = ref.watch(recentGamesProvider(userId));
    final me = ref.watch(currentUserIdProvider);
    final isMe = me == userId;
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.chessProfile)),
      body: switch (profile) {
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recentGamesProvider(userId));
              ref.invalidate(chessProfileProvider(userId));
              await ref.read(chessProfileProvider(userId).future);
            },
            child: ListView(
              padding: const EdgeInsets.all(GwSpacing.page),
              children: [
                ChessIdentityCard(profile: value, isMe: isMe),
                const SizedBox(height: GwSpacing.lg),
                GwSectionHeader(title: gamesL10n.recentGames),
                const SizedBox(height: GwSpacing.xs),
                switch (games) {
                  AsyncData(value: final list) when list.isEmpty => GwEmptyState(
                      icon: Icons.sports_esports_outlined,
                      message: isMe ? gamesL10n.noGamesMine : gamesL10n.noGamesTheirs,
                      actionLabel: isMe ? gamesL10n.playNow : gamesL10n.challenge,
                      onAction: () => isMe
                          ? context.push(ChessRoutes.seek(TimeControl.standard))
                          : showChallengeSheet(context, opponent: value.player),
                    ),
                  AsyncData(value: final list) => GameHistory(games: list),
                  AsyncError(:final error) =>
                    GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(recentGamesProvider(userId))),
                  _ => const GwSkeleton(height: GwSpacing.xxl * 3),
                },
              ],
            ),
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(chessProfileProvider(userId))),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
      },
    );
  }
}

/// The person, their flag and the three rating tiles.
class ChessIdentityCard extends ConsumerWidget {
  const ChessIdentityCard({super.key, required this.profile, required this.isMe});

  final ChessProfile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final p = profile.player;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GwAvatar(name: p.displayName, shape: GwAvatarShape.user, imageUrl: p.avatarUrl, size: GwAvatarSize.lg),
              const SizedBox(width: GwSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.displayName, style: textTheme.titleLarge),
                    Text(atName(p.username), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                    const SizedBox(height: GwSpacing.xxs),
                    Row(
                      children: [
                        if (p.country case final c?) ...[
                          ChessFlag(c, height: GwSpacing.md),
                          const SizedBox(width: GwSpacing.xs),
                          Flexible(child: Text(countryName(c), style: textTheme.bodySmall)),
                        ] else
                          Text(gamesL10n.noFlag, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isMe)
                IconButton(
                  tooltip: gamesL10n.chooseFlag,
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => showCountryPicker(context, ref, current: p.country),
                )
              else
                IconButton.filledTonal(
                  tooltip: gamesL10n.challenge,
                  icon: const Icon(Icons.sports_esports_outlined),
                  onPressed: profile.suspended ? null : () => showChallengeSheet(context, opponent: p),
                ),
            ],
          ),
          if (profile.suspended) ...[
            const SizedBox(height: GwSpacing.sm),
            GwFormMessage(gamesL10n.suspendedNotice),
          ],
          const SizedBox(height: GwSpacing.md),
          Row(
            children: [
              for (final (i, c) in ChessCategory.values.indexed) ...[
                if (i > 0) const SizedBox(width: GwSpacing.xs),
                Expanded(child: _RatingTile(rating: profile.ratingOf(c), rank: profile.ranks[c])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.rating, required this.rank});

  final ChessRating rating;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = rating.category;
    return InkWell(
      borderRadius: GwRadius.lgAll,
      onTap: () => context.push('${ChessRoutes.leaderboard}?c=${c.code}'),
      child: Container(
        padding: const EdgeInsets.all(GwSpacing.sm),
        decoration: const BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.fromBorderSide(GwBorders.hairline)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(chessCategoryIcon(c), size: GwSpacing.md, color: GwColors.primary),
                const SizedBox(width: GwSpacing.xxs),
                Flexible(child: Text(c.label, style: textTheme.labelMedium, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: GwSpacing.xxs),
            Text(rating.games == 0 ? '—' : '${rating.rating}', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(
              rating.games == 0 ? gamesL10n.notPlayed : gamesL10n.gamesCount(rating.games),
              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
            ),
            if (rank case final r?) ...[
              const SizedBox(height: GwSpacing.xxs),
              Row(
                children: [
                  if (r <= 3) ...[RankBadge(rank: r, size: GwSpacing.lg), const SizedBox(width: GwSpacing.xxs)],
                  Flexible(child: Text(gamesL10n.rankShort(r), style: textTheme.labelSmall)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Finished and running games, newest first, with the result and rating change for the list's owner.
class GameHistory extends StatelessWidget {
  const GameHistory({super.key, required this.games});

  final List<GameSummary> games;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      child: Column(
        children: [
          for (final (i, s) in games.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
            InkWell(
              onTap: () => context.push(ChessRoutes.game(s.game.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
                child: Row(
                  children: [
                    _ResultDot(score: s.game.scoreFor(s.color), active: s.game.isActive),
                    const SizedBox(width: GwSpacing.sm),
                    Expanded(
                      child: s.opponent == null
                          ? Text(gamesL10n.deletedPlayer, style: textTheme.titleSmall)
                          : ChessPlayerLine(
                              player: s.opponent!,
                              size: GwAvatarSize.sm,
                              subtitle: '${s.game.timeControl.label} · ${s.color.label} · ${resultFor(s.game, s.color)}',
                            ),
                    ),
                    if (s.game.deltaOf(s.color) case final d?) RatingDelta(d),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultDot extends StatelessWidget {
  const _ResultDot({required this.score, required this.active});

  final double? score;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (score) {
      1.0 => (GwColors.success, Icons.add_rounded),
      0.0 => (GwColors.error, Icons.remove_rounded),
      0.5 => (GwColors.textSecondary, Icons.drag_handle_rounded),
      _ => (GwColors.primary, active ? Icons.play_arrow_rounded : Icons.close_rounded),
    };
    return Container(
      width: GwSpacing.lg,
      height: GwSpacing.lg,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Icon(icon, size: GwSpacing.md, color: color),
    );
  }
}
