import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'team_screens.dart';
import 'widgets.dart';

/// The people's leaderboard by Elo, one tab per time category, and the groups' by team-match Elo; the top three
/// stand on a podium with gold, silver and bronze (docs/ARCHITECTURE.md §3i, Elo).
class ChessLeaderboardScreen extends StatelessWidget {
  const ChessLeaderboardScreen({super.key, this.initial = ChessCategory.blitz, this.groups = false});

  final ChessCategory initial;

  /// Opens on the groups tab.
  final bool groups;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: ChessCategory.values.length + 1,
        initialIndex: groups ? ChessCategory.values.length : ChessCategory.values.indexOf(initial),
        child: Scaffold(
          appBar: AppBar(
            title: Text(gamesL10n.leaderboard),
            bottom: TabBar(
              tabs: [
                for (final c in ChessCategory.values) Tab(icon: Icon(chessCategoryIcon(c)), text: c.label),
                Tab(icon: const Icon(Icons.groups_outlined), text: gamesL10n.groupsTab),
              ],
            ),
          ),
          body: TabBarView(children: [for (final c in ChessCategory.values) _Board(category: c), const GroupLeaderboard()]),
        ),
      );
}

class _Board extends ConsumerWidget {
  const _Board({required this.category});

  final ChessCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider(category));
    final me = ref.watch(currentUserIdProvider);
    return switch (entries) {
      AsyncData(:final value) when value.isEmpty => Center(
          child: GwEmptyState(
            icon: Icons.emoji_events_outlined,
            message: gamesL10n.leaderboardEmpty(ChessRating.rankedAfter),
            actionLabel: gamesL10n.playNow,
            onAction: () => context.push(ChessRoutes.seek(TimeControl.catalog.firstWhere((t) => t.category == category))),
          ),
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(leaderboardProvider(category).future),
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              LeaderboardPodium(entries: value.take(3).toList(), playerPath: ChessRoutes.player),
              const SizedBox(height: GwSpacing.md),
              GwCard(
                child: Column(
                  children: [
                    for (final (i, e) in value.indexed)
                      if (i >= 3) ...[
                        if (i > 3) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                        LeaderboardRow(entry: e, isMe: e.player.userId == me, playerPath: ChessRoutes.player),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(leaderboardProvider(category))),
      _ => ListView(
          padding: const EdgeInsets.all(GwSpacing.page),
          children: [
            for (var i = 0; i < 8; i++)
              const Padding(padding: EdgeInsets.only(bottom: GwSpacing.sm), child: GwSkeleton(height: GwSpacing.xxl)),
          ],
        ),
    };
  }
}

/// Second, first, third side by side; first stands tallest. Shared by every game's leaderboard.
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({super.key, required this.entries, required this.playerPath});

  final List<LeaderboardEntry> entries;

  /// The player page of the game the board belongs to.
  final String Function(String userId) playerPath;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? at(int i) => i < entries.length ? entries[i] : null;
    return GwCard(
      padding: const EdgeInsets.fromLTRB(GwSpacing.sm, GwSpacing.lg, GwSpacing.sm, GwSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _Step(entry: at(1), rank: 2, lift: GwSpacing.xxl, playerPath: playerPath)),
          Expanded(child: _Step(entry: at(0), rank: 1, lift: GwSpacing.xxl + GwSpacing.md, playerPath: playerPath)),
          Expanded(child: _Step(entry: at(2), rank: 3, lift: GwSpacing.xl + GwSpacing.xs, playerPath: playerPath)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.entry, required this.rank, required this.lift, required this.playerPath});

  final LeaderboardEntry? entry;
  final int rank;
  final double lift;
  final String Function(String userId) playerPath;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final textTheme = Theme.of(context).textTheme;
    final medal = GwMedal.forRank(rank)!;
    if (e == null) return SizedBox(height: lift);
    return InkWell(
      borderRadius: GwRadius.lgAll,
      onTap: () => context.push(playerPath(e.player.userId)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Crowned(
                rank: rank,
                avatarSize: (rank == 1 ? GwAvatarSize.xl : GwAvatarSize.lg).dimension,
                child: Container(
                  padding: const EdgeInsets.all(GwBorders.ringWidth),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: medal.strong, width: GwBorders.ringWidth)),
                  child: GwAvatar(
                    name: e.player.displayName,
                    shape: GwAvatarShape.user,
                    imageUrl: e.player.avatarUrl,
                    size: rank == 1 ? GwAvatarSize.xl : GwAvatarSize.lg,
                  ),
                ),
              ),
              Positioned(bottom: -GwSpacing.xl, child: RankBadge(rank: rank, size: GwSpacing.xl + GwSpacing.xxs)),
            ],
          ),
          const SizedBox(height: GwSpacing.xl + GwSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChessFlag(e.player.country),
              if (e.player.country != null) const SizedBox(width: GwSpacing.xxs),
              Flexible(child: Text(e.player.displayName, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
            ],
          ),
          Text(atName(e.player.username), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary), overflow: TextOverflow.ellipsis),
          const SizedBox(height: GwSpacing.xs),
          Container(
            width: double.infinity,
            height: lift,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medal.soft, borderRadius: GwRadius.mdAll),
            child: Text('${e.rating}', style: textTheme.titleMedium?.copyWith(color: medal.strong, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// A place below the podium; the reader's own row is tinted.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.entry, required this.isMe, required this.playerPath});

  final LeaderboardEntry entry;
  final bool isMe;
  final String Function(String userId) playerPath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: isMe ? GwColors.primarySoft : null,
      child: InkWell(
        onTap: () => context.push(playerPath(entry.player.userId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
          child: Row(
            children: [
              RankBadge(rank: entry.rank),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: ChessPlayerLine(
                  player: entry.player,
                  subtitle: gamesL10n.record(entry.wins, entry.draws, entry.losses),
                ),
              ),
              Text('${entry.rating}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
