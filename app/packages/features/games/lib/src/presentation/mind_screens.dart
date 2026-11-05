import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../domain/mind.dart';
import '../domain/team.dart';
import '../l10n.dart';
import 'arena_screens.dart';
import 'leaderboard_screen.dart';
import 'mind_figure.dart';
import 'mind_match_screen.dart' show mindKindIcon;
import 'mind_providers.dart';
import 'player_screen.dart' show MedalsRow;
import 'providers.dart';
import 'routes.dart';
import 'sheets.dart';
import 'team_screens.dart';
import 'widgets.dart';

// ---------------------------------------------------------------------------
// Home
// ---------------------------------------------------------------------------

/// Zihin Düellosu home (docs/ARCHITECTURE.md §3j, Uygulama): length and rating, find an opponent or invite a friend,
/// invitations, the running duel, the four kinds, the leaderboard's top three and recent duels.
class MindHomeScreen extends ConsumerWidget {
  const MindHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final length = ref.watch(mindLengthProvider);
    final active = ref.watch(mindActiveProvider).value;
    final challenges = ref.watch(mindChallengesProvider).value ?? const <MindChallenge>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(gamesL10n.mindDuel),
        actions: [
          IconButton(
            tooltip: gamesL10n.leaderboard,
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push(MindRoutes.leaderboard(length)),
          ),
          if (me != null)
            IconButton(
              tooltip: gamesL10n.mindProfile,
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () => context.push(MindRoutes.player(me)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(mindActiveProvider)
            ..invalidate(mindChallengesProvider)
            ..invalidate(mindLeaderboardProvider(length))
            ..invalidate(myTeamMatchesProvider(TeamGame.mind))
            ..invalidate(arenasProvider(TeamGame.mind));
          if (me != null) {
            ref
              ..invalidate(mindProfileProvider(me))
              ..invalidate(mindRecentProvider(me));
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(GwSpacing.page),
              children: [
                if (active != null) ...[
                  _ActiveStrip(match: active),
                  const SizedBox(height: GwSpacing.md),
                ],
                const _PlayPanel(),
                if (challenges.isNotEmpty) ...[
                  GwSectionHeader(title: gamesL10n.invitations, padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs)),
                  GwCard(
                    child: Column(
                      children: [
                        for (final (i, c) in challenges.indexed) ...[
                          if (i > 0) const Divider(height: 1),
                          _ChallengeRow(challenge: c, incoming: c.isIncomingFor(me)),
                        ],
                      ],
                    ),
                  ),
                ],
                const _Arenas(),
                const _GroupDuels(),
                GwSectionHeader(
                  title: gamesL10n.leaderboard,
                  subtitle: gamesL10n.mindQuestions(length),
                  actionLabel: gamesL10n.seeAll,
                  onAction: () => context.push(MindRoutes.leaderboard(length)),
                  padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs),
                ),
                _TopThree(length: length),
                GwSectionHeader(title: gamesL10n.mindHowTo, padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs)),
                const _HowTo(),
                if (me != null) ...[
                  GwSectionHeader(title: gamesL10n.mindRecent, padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs)),
                  _Recent(userId: me, isMe: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Duel tournaments: live and upcoming as a row of cards, all of them a tap away.
class _Arenas extends ConsumerWidget {
  const _Arenas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(arenasProvider(TeamGame.mind)).value;
    if (lists == null) return const SizedBox.shrink();
    final shown = [...lists.live, ...lists.upcoming].take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GwSectionHeader(
          title: gamesL10n.mindTournaments,
          subtitle: gamesL10n.mindTournamentsHint,
          actionLabel: gamesL10n.seeAll,
          onAction: () => context.push(MindRoutes.arenas),
          padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs),
        ),
        if (shown.isEmpty)
          Text(gamesL10n.mindNoTournaments, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary))
        else
          SizedBox(
            height: ArenaEventCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(width: GwSpacing.sm),
              itemBuilder: (_, i) => SizedBox(
                width: ArenaEventCard.width,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ArenaEventCard(arena: shown[i], joined: lists.joined.contains(shown[i].id)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The reader's groups' duels against other groups; captains arrange new ones.
class _GroupDuels extends ConsumerWidget {
  const _GroupDuels();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(myTeamMatchesProvider(TeamGame.mind)).value ?? const <TeamMatch>[];
    final captainOf = ref.watch(captainGroupsProvider).value ?? const <ChessGroup>[];
    if (matches.isEmpty && captainOf.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GwSectionHeader(
          title: gamesL10n.mindTeamMatches,
          subtitle: gamesL10n.mindTeamMatchesHint,
          actionLabel: captainOf.isEmpty ? null : gamesL10n.mindNewTeamMatch,
          onAction: captainOf.isEmpty ? null : () => showCreateTeamMatchSheet(context, mine: captainOf, game: TeamGame.mind),
          padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs),
        ),
        for (final m in matches.take(4)) Padding(padding: const EdgeInsets.only(bottom: GwSpacing.xs), child: TeamMatchTile(match: m)),
        if (matches.isEmpty)
          Text(gamesL10n.mindNoTeamMatches, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
      ],
    );
  }
}

class _ActiveStrip extends StatelessWidget {
  const _ActiveStrip({required this.match});

  final MindMatch match;

  @override
  Widget build(BuildContext context) => GwCard(
        onTap: () => context.push(MindRoutes.match(match.id)),
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: GwColors.primary),
            const SizedBox(width: GwSpacing.sm),
            Expanded(child: Text(gamesL10n.mindActive, style: Theme.of(context).textTheme.titleSmall)),
            GwButton(label: gamesL10n.resume, onPressed: () => context.push(MindRoutes.match(match.id))),
          ],
        ),
      );
}

/// The length, the person's rating at it and the two ways to play.
class _PlayPanel extends ConsumerWidget {
  const _PlayPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final me = ref.watch(currentUserIdProvider);
    final length = ref.watch(mindLengthProvider);
    final profile = me == null ? null : ref.watch(mindProfileProvider(me)).value;
    final rating = profile?.ratingOf(length);
    final rank = profile?.ranks[length];
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(gamesL10n.mindHowMany, style: textTheme.titleSmall),
          const SizedBox(height: GwSpacing.xs),
          SegmentedButton<int>(
            segments: [for (final n in mindLengths) ButtonSegment(value: n, label: Text('$n'))],
            selected: {length},
            showSelectedIcon: false,
            onSelectionChanged: (s) => ref.read(mindLengthProvider.notifier).set(s.first),
          ),
          const SizedBox(height: GwSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gamesL10n.mindRatingAt(length), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                    Text('${rating?.rating ?? ChessRating.startRating}',
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ),
              ),
              if (rank != null) GwTag(label: gamesL10n.rankShort(rank), icon: Icons.emoji_events_outlined, tone: GwTone.lilac)
              else if (rating != null && rating.games > 0) Text(gamesL10n.record(rating.wins, rating.draws, rating.losses), style: textTheme.bodySmall),
            ],
          ),
          if (profile?.suspended ?? false) ...[
            const SizedBox(height: GwSpacing.sm),
            GwFormMessage(gamesL10n.mindSuspended),
          ],
          const SizedBox(height: GwSpacing.md),
          GwButton(
            label: gamesL10n.mindFindOpponent,
            icon: Icons.bolt_rounded,
            expand: true,
            onPressed: profile?.suspended ?? false ? null : () => context.push(MindRoutes.seek(length)),
          ),
          const SizedBox(height: GwSpacing.xs),
          GwButton(
            label: gamesL10n.challengeFriend,
            icon: Icons.person_add_alt_1_outlined,
            variant: GwButtonVariant.secondary,
            expand: true,
            onPressed: profile?.suspended ?? false ? null : () => showMindChallengeSheet(context),
          ),
        ],
      ),
    );
  }
}

class _ChallengeRow extends ConsumerStatefulWidget {
  const _ChallengeRow({required this.challenge, required this.incoming});

  final MindChallenge challenge;
  final bool incoming;

  @override
  ConsumerState<_ChallengeRow> createState() => _ChallengeRowState();
}

class _ChallengeRowState extends ConsumerState<_ChallengeRow> {
  bool _busy = false;

  Future<void> _act(Future<Result<Object?>> Function(MindRepository repo) action) async {
    setState(() => _busy = true);
    final result = await action(ref.read(mindRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(mindChallengesProvider);
    switch (result) {
      case Ok(value: final String match):
        await context.push(MindRoutes.match(match));
      case Ok():
        break;
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final what = '${gamesL10n.mindQuestions(c.length)} · ${c.rated ? gamesL10n.rated : gamesL10n.casual}';
    final other = c.other;
    return Padding(
      padding: const EdgeInsets.all(GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (other != null)
            ChessPlayerLine(
              player: other,
              subtitle: widget.incoming
                  ? (c.rematchOf != null ? gamesL10n.wantsRematch(what) : gamesL10n.invitesYou(what))
                  : gamesL10n.waitingFor(what),
            ),
          const SizedBox(height: GwSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.incoming
                ? [
                    GwButton(label: gamesL10n.decline, variant: GwButtonVariant.text, onPressed: _busy ? null : () => _act((r) => r.decline(c.id))),
                    const SizedBox(width: GwSpacing.xs),
                    GwButton(label: gamesL10n.accept, isLoading: _busy, onPressed: () => _act((r) => r.accept(c.id))),
                  ]
                : [GwButton(label: gamesL10n.withdraw, variant: GwButtonVariant.text, onPressed: _busy ? null : () => _act((r) => r.cancelChallenge(c.id)))],
          ),
        ],
      ),
    );
  }
}

class _TopThree extends ConsumerWidget {
  const _TopThree({required this.length});

  final int length;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(mindLeaderboardProvider(length))) {
        AsyncData(:final value) when value.isEmpty => GwCard(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: GwEmptyState(
              icon: Icons.emoji_events_outlined,
              message: gamesL10n.mindLeaderboardEmpty(mindRankedAfter),
              actionLabel: gamesL10n.mindFindOpponent,
              onAction: () => context.push(MindRoutes.seek(length)),
            ),
          ),
        AsyncData(:final value) => LeaderboardPodium(entries: value.take(3).toList(), playerPath: MindRoutes.player),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(mindLeaderboardProvider(length))),
        _ => const GwSkeleton(height: GwSpacing.xxl * 3),
      };
}

/// The four kinds, each with a small drawing and one sentence.
class _HowTo extends StatelessWidget {
  const _HowTo();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final k in MindKind.values) ...[
            Row(
              children: [
                Container(
                  width: GwSpacing.xl + GwSpacing.xs,
                  height: GwSpacing.xl + GwSpacing.xs,
                  decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
                  child: Icon(mindKindIcon(k), color: GwColors.primary, size: GwSpacing.md + GwSpacing.xxs),
                ),
                const SizedBox(width: GwSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.label, style: textTheme.titleSmall),
                      Text(k.hint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GwSpacing.sm),
          ],
          Text(gamesL10n.mindScoringHint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.userId, required this.isMe, this.player});

  final String userId;
  final bool isMe;
  final ChessPlayer? player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final length = ref.watch(mindLengthProvider);
    return switch (ref.watch(mindRecentProvider(userId))) {
      AsyncData(:final value) when value.isEmpty => GwCard(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: GwEmptyState(
            icon: Icons.psychology_outlined,
            message: isMe ? gamesL10n.mindNoMatchesMine : gamesL10n.mindNoMatchesTheirs,
            actionLabel: isMe ? gamesL10n.mindFindOpponent : gamesL10n.challenge,
            onAction: () => isMe ? context.push(MindRoutes.seek(length)) : showMindChallengeSheet(context, opponent: player),
          ),
        ),
      AsyncData(:final value) => GwCard(
          child: Column(
            children: [
              for (final (i, s) in value.indexed) ...[
                if (i > 0) const Divider(height: 1),
                InkWell(
                  onTap: () => context.push(MindRoutes.match(s.match.id)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
                    child: ChessPlayerLine(
                      player: s.opponent ??
                          ChessPlayer(userId: '', username: '', displayName: gamesL10n.deletedPlayer),
                      subtitle: '${gamesL10n.mindQuestions(s.match.length)} · ${s.match.scoreOf(s.side)} – ${s.match.scoreOf(s.side.other)}',
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_resultLabel(s), style: textTheme.labelLarge),
                          if (s.match.deltaOf(s.side) case final d?) RatingDelta(d, style: textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(mindRecentProvider(userId))),
      _ => const GwSkeleton(height: GwSpacing.xxl * 3),
    };
  }

  static String _resultLabel(MindMatchSummary s) => switch (s.match.scoreFor(s.side)) {
        1.0 => gamesL10n.youWon,
        0.0 => gamesL10n.youLost,
        0.5 => gamesL10n.draw,
        _ => gamesL10n.inProgress,
      };
}

// ---------------------------------------------------------------------------
// Quick match
// ---------------------------------------------------------------------------

/// Looking for an opponent at one length; refreshed every 5 seconds (which widens the rating range). Leaving drops it.
class MindSeekScreen extends ConsumerStatefulWidget {
  const MindSeekScreen({super.key, required this.length});

  final int length;

  @override
  ConsumerState<MindSeekScreen> createState() => _MindSeekScreenState();
}

class _MindSeekScreenState extends ConsumerState<MindSeekScreen> with SingleTickerProviderStateMixin {
  late final MindRepository _repo = ref.read(mindRepositoryProvider);
  late final AnimationController _pulse;
  final _started = DateTime.now();
  StreamSubscription<String>? _matches;
  Timer? _beat;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _matches = _repo.seekMatches().listen(_open);
    unawaited(_start());
  }

  Future<void> _start() async {
    switch (await _repo.seek(widget.length)) {
      case Ok(value: final match?):
        _open(match);
      case Ok():
        _beat = Timer.periodic(const Duration(seconds: 5), (_) async {
          if (await _repo.heartbeat() case Ok(value: final match?)) _open(match);
          if (mounted) setState(() {});
        });
      case Err(:final failure):
        if (mounted) setState(() => _error = failure.userMessage);
    }
  }

  void _open(String match) {
    if (_done || !mounted) return;
    _done = true;
    _beat?.cancel();
    context.pushReplacement(MindRoutes.match(match));
  }

  @override
  void dispose() {
    _beat?.cancel();
    _matches?.cancel();
    _pulse.dispose();
    if (!_done) unawaited(_repo.cancelSeek());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final waited = DateTime.now().difference(_started).inSeconds;
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.mindDuel)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.lg),
          child: error != null
              ? GwErrorState(message: error, onRetry: () {
                  setState(() => _error = null);
                  unawaited(_start());
                })
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => Container(
                        width: GwSpacing.xxl * 2,
                        height: GwSpacing.xxl * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GwColors.primarySoft,
                          border: Border.all(
                            color: GwColors.primary.withValues(alpha: 1 - _pulse.value),
                            width: GwBorders.ringWidth + GwSpacing.sm * _pulse.value,
                          ),
                        ),
                        child: const Icon(Icons.psychology_outlined, size: GwSpacing.xl, color: GwColors.primary),
                      ),
                    ),
                    const SizedBox(height: GwSpacing.lg),
                    Text(gamesL10n.searching, style: textTheme.titleLarge),
                    const SizedBox(height: GwSpacing.xs),
                    Text('${gamesL10n.mindQuestions(widget.length)} · ${gamesL10n.rated}',
                        style: textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary)),
                    const SizedBox(height: GwSpacing.xxs),
                    Text(gamesL10n.waitedSeconds(waited), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                    const SizedBox(height: GwSpacing.lg),
                    GwButton(label: gamesL10n.cancel, variant: GwButtonVariant.secondary, onPressed: () => context.pop()),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaderboard
// ---------------------------------------------------------------------------

/// One tab per length and one for the groups; the top three on the podium with crowns and medals.
class MindLeaderboardScreen extends StatelessWidget {
  const MindLeaderboardScreen({super.key, this.initial = mindDefaultLength, this.groups = false});

  final int initial;

  /// Opens on the groups tab.
  final bool groups;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: mindLengths.length + 1,
        initialIndex: groups ? mindLengths.length : mindLengths.indexOf(initial).clamp(0, mindLengths.length - 1),
        child: Scaffold(
          appBar: AppBar(
            title: Text('${gamesL10n.mindDuel} · ${gamesL10n.leaderboard}'),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final n in mindLengths) Tab(text: gamesL10n.mindQuestions(n)),
                Tab(icon: const Icon(Icons.groups_outlined), text: gamesL10n.groupsTab),
              ],
            ),
          ),
          body: TabBarView(children: [for (final n in mindLengths) _Board(length: n), const GroupLeaderboard(game: TeamGame.mind)]),
        ),
      );
}

class _Board extends ConsumerWidget {
  const _Board({required this.length});

  final int length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    return switch (ref.watch(mindLeaderboardProvider(length))) {
      AsyncData(:final value) when value.isEmpty => Center(
          child: GwEmptyState(
            icon: Icons.emoji_events_outlined,
            message: gamesL10n.mindLeaderboardEmpty(mindRankedAfter),
            actionLabel: gamesL10n.mindFindOpponent,
            onAction: () => context.push(MindRoutes.seek(length)),
          ),
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(mindLeaderboardProvider(length).future),
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              LeaderboardPodium(entries: value.take(3).toList(), playerPath: MindRoutes.player),
              if (value.length > 3) ...[
                const SizedBox(height: GwSpacing.md),
                GwCard(
                  child: Column(
                    children: [
                      for (final (i, e) in value.indexed)
                        if (i >= 3) ...[
                          if (i > 3) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                          LeaderboardRow(entry: e, isMe: e.player.userId == me, playerPath: MindRoutes.player),
                        ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(mindLeaderboardProvider(length))),
      _ => ListView(
          padding: const EdgeInsets.all(GwSpacing.page),
          children: [
            for (var i = 0; i < 8; i++) const Padding(padding: EdgeInsets.only(bottom: GwSpacing.sm), child: GwSkeleton(height: GwSpacing.xxl)),
          ],
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Player page
// ---------------------------------------------------------------------------

/// The person with their flag, a rating tile for each length with its place, and recent duels.
class MindPlayerScreen extends ConsumerWidget {
  const MindPlayerScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final me = ref.watch(currentUserIdProvider);
    final isMe = me == userId;
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.mindProfile)),
      body: switch (ref.watch(mindProfileProvider(userId))) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              GwCard(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GwAvatar(name: value.player.displayName, shape: GwAvatarShape.user, imageUrl: value.player.avatarUrl, size: GwAvatarSize.lg),
                        const SizedBox(width: GwSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value.player.displayName, style: textTheme.titleLarge),
                              Text(atName(value.player.username), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                              const SizedBox(height: GwSpacing.xxs),
                              if (value.player.country case final c?)
                                Row(children: [
                                  ChessFlag(c, height: GwSpacing.md),
                                  const SizedBox(width: GwSpacing.xs),
                                  Flexible(child: Text(countryName(c), style: textTheme.bodySmall)),
                                ])
                              else
                                Text(gamesL10n.noFlag, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (isMe)
                          IconButton(
                            tooltip: gamesL10n.chooseFlag,
                            icon: const Icon(Icons.flag_outlined),
                            onPressed: () async {
                              await showCountryPicker(context, ref, current: value.player.country);
                              ref.invalidate(mindProfileProvider(userId));
                            },
                          )
                        else
                          IconButton.filledTonal(
                            tooltip: gamesL10n.challenge,
                            icon: const Icon(Icons.psychology_outlined),
                            onPressed: value.suspended ? null : () => showMindChallengeSheet(context, opponent: value.player),
                          ),
                      ],
                    ),
                    MedalsRow(userId: userId, game: TeamGame.mind),
                    if (value.suspended) ...[
                      const SizedBox(height: GwSpacing.sm),
                      GwFormMessage(gamesL10n.mindSuspended),
                    ],
                    const SizedBox(height: GwSpacing.md),
                    Row(
                      children: [
                        for (final (i, n) in mindLengths.indexed) ...[
                          if (i > 0) const SizedBox(width: GwSpacing.xs),
                          Expanded(child: _LengthTile(rating: value.ratingOf(n), rank: value.ranks[n])),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GwSectionHeader(title: gamesL10n.mindRecent, padding: const EdgeInsets.only(top: GwSpacing.lg, bottom: GwSpacing.xs)),
              _Recent(userId: userId, isMe: isMe, player: value.player),
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(mindProfileProvider(userId))),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
      },
    );
  }
}

class _LengthTile extends StatelessWidget {
  const _LengthTile({required this.rating, required this.rank});

  final MindRating rating;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final r = rank;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.sm, horizontal: GwSpacing.xxs),
      decoration: BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.all(color: GwColors.border)),
      child: Column(
        children: [
          Text(gamesL10n.mindQuestions(rating.length), style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: GwSpacing.xxs),
          Text(rating.games == 0 ? '–' : '${rating.rating}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: GwSpacing.xxs),
          if (r != null && r <= 3)
            RankBadge(rank: r, size: GwSpacing.lg)
          else
            Text(r != null ? gamesL10n.rankShort(r) : gamesL10n.gamesCount(rating.games),
                style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invitation
// ---------------------------------------------------------------------------

/// Invites someone to a duel: who (unless given), how many questions and rated or casual. True once sent.
Future<bool> showMindChallengeSheet(BuildContext context, {ChessPlayer? opponent}) async {
  final sent = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _ChallengeSheet(opponent: opponent),
      ) ??
      false;
  if (sent && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gamesL10n.mindChallengeSent)));
  return sent;
}

class _ChallengeSheet extends ConsumerStatefulWidget {
  const _ChallengeSheet({this.opponent});

  final ChessPlayer? opponent;

  @override
  ConsumerState<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends ConsumerState<_ChallengeSheet> {
  late ChessPlayer? _opponent = widget.opponent;
  late int _length = ref.read(mindLengthProvider);
  bool _rated = true;
  bool _sending = false;
  String? _error;
  List<ChessPlayer> _results = const [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await ref.read(chessRepositoryProvider).searchPlayers(q);
      if (!mounted) return;
      setState(() => _results = switch (result) {
            Ok(:final value) => value,
            Err() => const [],
          });
    });
  }

  Future<void> _send() async {
    final opponent = _opponent;
    if (opponent == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(mindRepositoryProvider).challenge(opponent.userId, _length, rated: _rated);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(mindChallengesProvider);
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(() {
          _sending = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final opponent = _opponent;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gamesL10n.mindChallengeTitle, style: textTheme.titleLarge),
              const SizedBox(height: GwSpacing.md),
              if (opponent != null)
                ChessPlayerLine(
                  player: opponent,
                  trailing: widget.opponent == null
                      ? IconButton(tooltip: gamesL10n.changePerson, icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _opponent = null))
                      : null,
                )
              else ...[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: gamesL10n.searchPerson),
                  onChanged: _search,
                ),
                for (final p in _results)
                  Padding(
                    padding: const EdgeInsets.only(top: GwSpacing.xs),
                    child: ChessPlayerLine(player: p, onTap: () => setState(() => _opponent = p)),
                  ),
              ],
              const SizedBox(height: GwSpacing.lg),
              Text(gamesL10n.mindHowMany, style: textTheme.titleSmall),
              const SizedBox(height: GwSpacing.xs),
              SegmentedButton<int>(
                segments: [for (final n in mindLengths) ButtonSegment(value: n, label: Text('$n'))],
                selected: {_length},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _length = s.first),
              ),
              const SizedBox(height: GwSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gamesL10n.rated),
                subtitle: Text(gamesL10n.ratedHint),
                value: _rated,
                onChanged: (v) => setState(() => _rated = v),
              ),
              if (_error case final error?) ...[
                const SizedBox(height: GwSpacing.md),
                GwFormMessage(error),
              ],
              const SizedBox(height: GwSpacing.lg),
              GwButton(
                label: gamesL10n.sendChallenge,
                icon: Icons.send_rounded,
                expand: true,
                isLoading: _sending,
                onPressed: opponent == null ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The hub card's picture: one small sample of each kind, side by side.
class MindSampleStrip extends StatelessWidget {
  const MindSampleStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget cell(Widget child) => Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: GwColors.background, borderRadius: GwRadius.lgAll, border: Border.all(color: GwColors.border)),
              child: child,
            ),
          ),
        );
    const gap = SizedBox(width: GwSpacing.xs);
    return ExcludeSemantics(
      child: Row(
        children: [
          cell(FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(GwSpacing.xs),
              child: Text('7 × 8', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
          )),
          gap,
          cell(const MindFigureView(figure: MindFigure(color: 'red', pattern: MindPattern.striped, shape: MindShape.circle), size: GwSpacing.xxl)),
          gap,
          cell(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('A', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: GwMindColor.blue.color)),
              Text('7', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: GwMindColor.orange.color)),
              Text('?', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: GwColors.textSecondary)),
            ],
          )),
          gap,
          cell(const MindFigureView(figure: MindFigure(color: 'green', shape: MindShape.star), size: GwSpacing.xxl)),
        ],
      ),
    );
  }
}
