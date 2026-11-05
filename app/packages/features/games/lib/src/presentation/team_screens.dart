import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../domain/team.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// "1½" style points.
String formatPoints(double p) => p == p.roundToDouble() ? '${p.toInt()}' : '${p.floor() == 0 ? '' : p.floor()}½';

class _GroupBadge extends StatelessWidget {
  const _GroupBadge({required this.group, this.size = GwAvatarSize.md});

  final ChessGroup group;
  final GwAvatarSize size;

  @override
  Widget build(BuildContext context) => GwAvatar(name: group.name, shape: GwAvatarShape.group, imageUrl: group.logoUrl, size: size);
}

/// A team match in a list: each group on its own line with its points, then the status, start and format.
class TeamMatchTile extends StatelessWidget {
  const TeamMatchTile({super.key, required this.match});

  final TeamMatch match;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = match;
    final scored = m.status == TeamMatchStatus.finished;
    final homeWon = scored && (m.homePoints ?? 0) > (m.awayPoints ?? 0);
    final awayWon = scored && (m.awayPoints ?? 0) > (m.homePoints ?? 0);
    Widget line(ChessGroup g, double? points, bool won) => Row(
          children: [
            _GroupBadge(group: g, size: GwAvatarSize.sm),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Text(
                g.name,
                style: textTheme.titleSmall?.copyWith(fontWeight: won ? FontWeight.w800 : FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (scored)
              Text(formatPoints(points ?? 0), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: won ? GwColors.primary : null)),
          ],
        );
    return GwCard(
      onTap: () => context.push(ChessRoutes.team(m.id)),
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(m.home, m.homePoints, homeWon),
          const SizedBox(height: GwSpacing.xs),
          line(m.away, m.awayPoints, awayWon),
          const SizedBox(height: GwSpacing.sm),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (m.status == TeamMatchStatus.live) const GwLiveBadge() else GwTag(label: m.status.label, tone: GwTone.mist),
              Text('${formatDateTime(m.startsAt)} · ${gamesL10n.boardsCount(m.boards)} · ${m.timeControl.label}',
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A team match: the two groups and their Elo, the score, the boards and, for captains, the match actions.
class TeamMatchScreen extends ConsumerWidget {
  const TeamMatchScreen({super.key, required this.matchId});

  final String matchId;

  Future<void> _run(BuildContext context, WidgetRef ref, Future<Result<void>> Function() action, String done) async {
    final result = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => done,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref
      ..invalidate(teamMatchProvider(matchId))
      ..invalidate(myTeamMatchesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(teamMatchProvider(matchId));
    final me = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.teamMatch)),
      body: switch (detail) {
        AsyncData(:final value) => _body(context, ref, value, me),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(teamMatchProvider(matchId))),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
      },
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, TeamMatchDetail d, String? me) {
    final textTheme = Theme.of(context).textTheme;
    final m = d.match;
    final repo = ref.read(teamRepositoryProvider);
    final open = m.status.isOpen && m.startsAt.isAfter(DateTime.now());
    final captainAway = d.captainOf.contains(m.away.id);
    final captainAny = d.captainOf.isNotEmpty;

    Widget side(ChessGroup g, int rating, int? delta, CrossAxisAlignment align) => Expanded(
          child: Column(
            crossAxisAlignment: align,
            children: [
              _GroupBadge(group: g, size: GwAvatarSize.lg),
              const SizedBox(height: GwSpacing.xs),
              Text(g.name, style: textTheme.titleMedium, textAlign: align == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start),
              // Wraps under the name on narrow phones and at large text sizes.
              Wrap(
                alignment: align == CrossAxisAlignment.end ? WrapAlignment.end : WrapAlignment.start,
                spacing: GwSpacing.xxs,
                children: [
                  Text(gamesL10n.groupElo(rating), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                  if (delta != null) RatingDelta(delta, style: textTheme.labelSmall),
                ],
              ),
            ],
          ),
        );

    return RefreshIndicator(
      onRefresh: () => ref.refresh(teamMatchProvider(matchId).future),
      child: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          GwCard(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    side(m.home, d.homeRating, m.homeDelta, CrossAxisAlignment.start),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.md),
                      child: Text(
                        m.status == TeamMatchStatus.finished || m.status == TeamMatchStatus.live
                            ? '${formatPoints(_sum(d.boards, home: true))} – ${formatPoints(_sum(d.boards, home: false))}'
                            : gamesL10n.versus,
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    side(m.away, d.awayRating, m.awayDelta, CrossAxisAlignment.end),
                  ],
                ),
                const SizedBox(height: GwSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    GwTag(label: m.status.label, tone: m.status == TeamMatchStatus.live ? GwTone.lilac : GwTone.mist),
                    GwTag(label: '${m.timeControl.label} · ${m.timeControl.category.label}', icon: chessCategoryIcon(m.timeControl.category), tone: GwTone.sky),
                    GwTag(label: gamesL10n.boardsCount(m.boards), tone: GwTone.mist),
                    GwTag(label: formatDateTime(m.startsAt), icon: Icons.schedule_rounded, tone: GwTone.mist),
                  ],
                ),
              ],
            ),
          ),
          if (m.status == TeamMatchStatus.invited && captainAway && open) ...[
            const SizedBox(height: GwSpacing.md),
            GwFormMessage(gamesL10n.teamInviteReceived(m.home.name), kind: GwFormMessageKind.info),
            const SizedBox(height: GwSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: GwButton(
                    label: gamesL10n.decline,
                    variant: GwButtonVariant.secondary,
                    onPressed: () => _run(context, ref, () => repo.respond(m.id, accept: false), gamesL10n.teamDeclinedDone),
                  ),
                ),
                const SizedBox(width: GwSpacing.sm),
                Expanded(
                  child: GwButton(
                    label: gamesL10n.accept,
                    onPressed: () => _run(context, ref, () => repo.respond(m.id, accept: true), gamesL10n.teamAcceptedDone),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: GwSpacing.lg),
          GwSectionHeader(
            title: gamesL10n.boards,
            subtitle: open ? gamesL10n.lineupHint : null,
          ),
          const SizedBox(height: GwSpacing.xs),
          if (open && captainAny)
            Padding(
              padding: const EdgeInsets.only(bottom: GwSpacing.sm),
              child: Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final g in [m.home, m.away])
                    if (d.captainOf.contains(g.id))
                      GwButton(
                        label: gamesL10n.editLineup(g.name),
                        icon: Icons.format_list_numbered_rounded,
                        variant: GwButtonVariant.secondary,
                        onPressed: () => showLineupSheet(context, detail: d, group: g),
                      ),
                ],
              ),
            ),
          GwCard(
            child: Column(
              children: [
                for (final (i, b) in d.boards.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                  _BoardRow(board: b, me: me),
                ],
              ],
            ),
          ),
          // The invited side answers with Reddet; after acceptance either captain may call it off.
          if (open && (d.captainOf.contains(m.home.id) || (captainAway && m.status == TeamMatchStatus.accepted))) ...[
            const SizedBox(height: GwSpacing.lg),
            GwButton(
              label: m.status == TeamMatchStatus.invited ? gamesL10n.withdraw : gamesL10n.callOff,
              icon: Icons.close_rounded,
              variant: GwButtonVariant.text,
              onPressed: () => _run(context, ref, () => repo.cancel(m.id), gamesL10n.teamCanceledDone),
            ),
          ],
        ],
      ),
    );
  }

  static double _sum(List<TeamBoard> boards, {required bool home}) =>
      boards.fold(0, (s, b) => s + ((home ? b.homePoints : b.awayPoints) ?? 0));
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.board, required this.me});

  final TeamBoard board;
  final String? me;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final b = board;
    final mine = me != null && (b.home?.userId == me || b.away?.userId == me);
    Widget seat(ChessPlayer? p, bool white, bool end) {
      final dot = Container(
        width: GwSpacing.sm,
        height: GwSpacing.sm,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white ? GwColors.background : GwColors.textPrimary,
          border: Border.all(color: GwColors.textSecondary),
        ),
      );
      final name = Flexible(
        child: Text(
          p?.displayName ?? gamesL10n.emptyBoard,
          style: textTheme.bodyMedium?.copyWith(color: p == null ? GwColors.textSecondary : null),
          overflow: TextOverflow.ellipsis,
        ),
      );
      return Expanded(
        child: Row(
          mainAxisAlignment: end ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: end
              ? [name, if (p?.country != null) ...[const SizedBox(width: GwSpacing.xxs), ChessFlag(p!.country)], const SizedBox(width: GwSpacing.xs), dot]
              : [dot, const SizedBox(width: GwSpacing.xs), if (p?.country != null) ...[ChessFlag(p!.country), const SizedBox(width: GwSpacing.xxs)], name],
        ),
      );
    }

    final result = b.homePoints == null ? null : '${formatPoints(b.homePoints!)} – ${formatPoints(b.awayPoints!)}';
    return InkWell(
      onTap: b.gameId == null ? null : () => context.push(ChessRoutes.game(b.gameId!)),
      child: Container(
        color: mine ? GwColors.primarySoft : null,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: GwSpacing.lg, child: Text('${b.board}', style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary))),
            seat(b.home, b.homeIsWhite, false),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
              child: result != null
                  ? Text(result, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))
                  : b.gameId != null
                      ? Icon(mine ? Icons.play_circle_fill_rounded : Icons.visibility_outlined, color: GwColors.primary)
                      : Text(gamesL10n.versusShort, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
            ),
            seat(b.away, !b.homeIsWhite, true),
          ],
        ),
      ),
    );
  }
}

/// A captain puts members on the boards, strongest first by default.
Future<void> showLineupSheet(BuildContext context, {required TeamMatchDetail detail, required ChessGroup group}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LineupSheet(detail: detail, group: group),
    );

class _LineupSheet extends ConsumerStatefulWidget {
  const _LineupSheet({required this.detail, required this.group});

  final TeamMatchDetail detail;
  final ChessGroup group;

  @override
  ConsumerState<_LineupSheet> createState() => _LineupSheetState();
}

class _LineupSheetState extends ConsumerState<_LineupSheet> {
  late final bool _home = widget.group.id == widget.detail.match.home.id;
  late final List<ChessPlayer?> _slots = [for (final b in widget.detail.boards) _home ? b.home : b.away];
  List<TeamCandidate>? _candidates;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final result = await ref.read(teamRepositoryProvider).candidates(widget.detail.match.id, widget.group.id);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _candidates = value;
        case Err(:final failure):
          _error = failure.userMessage;
      }
    });
  }

  void _toggle(ChessPlayer p) => setState(() {
        final at = _slots.indexWhere((s) => s?.userId == p.userId);
        if (at >= 0) {
          _slots[at] = null;
        } else {
          final free = _slots.indexOf(null);
          if (free >= 0) _slots[free] = p;
        }
      });

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(teamRepositoryProvider).setLineup(widget.detail.match.id, widget.group.id, [for (final s in _slots) s?.userId]);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(teamMatchProvider(widget.detail.match.id));
        Navigator.of(context).pop();
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final candidates = _candidates;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gamesL10n.editLineup(widget.group.name), style: textTheme.titleLarge),
                const SizedBox(height: GwSpacing.xxs),
                Text(gamesL10n.lineupSheetHint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                const SizedBox(height: GwSpacing.sm),
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final (i, s) in _slots.indexed)
                      InputChip(
                        avatar: CircleAvatar(child: Text('${i + 1}')),
                        label: Text(s?.displayName ?? gamesL10n.emptyBoard),
                        onDeleted: s == null ? null : () => _toggle(s),
                      ),
                  ],
                ),
                if (_error case final e?) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(e)],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: candidates == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      for (final c in candidates)
                        CheckboxListTile(
                          value: _slots.any((s) => s?.userId == c.player.userId),
                          onChanged: (_) => _toggle(c.player),
                          title: ChessPlayerLine(player: c.player, size: GwAvatarSize.sm, subtitle: gamesL10n.ratingGames(c.rating, c.games)),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: GwButton(label: gamesL10n.saveLineup, expand: true, isLoading: _saving, onPressed: _save),
            ),
          ),
        ],
      ),
    );
  }
}

/// A captain invites another group: which of their groups, the opponent, boards, time control and start.
Future<void> showCreateTeamMatchSheet(BuildContext context, {required List<ChessGroup> mine}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CreateTeamMatchSheet(mine: mine),
    );

class _CreateTeamMatchSheet extends ConsumerStatefulWidget {
  const _CreateTeamMatchSheet({required this.mine});

  final List<ChessGroup> mine;

  @override
  ConsumerState<_CreateTeamMatchSheet> createState() => _CreateTeamMatchSheetState();
}

class _CreateTeamMatchSheetState extends ConsumerState<_CreateTeamMatchSheet> {
  late ChessGroup _home = widget.mine.first;
  ChessGroup? _away;
  int _boards = 4;
  TimeControl _tc = const TimeControl(300, 3);
  late DateTime _starts = () {
    final t = DateTime.now().add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 20);
  }();
  List<ChessGroup> _results = const [];
  Timer? _debounce;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await ref.read(teamRepositoryProvider).searchGroups(q);
      if (!mounted) return;
      setState(() => _results = switch (result) {
            Ok(:final value) => [for (final g in value) if (g.id != _home.id) g],
            Err() => const [],
          });
    });
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: _starts, firstDate: now, lastDate: now.add(const Duration(days: 30)));
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_starts));
    if (time == null) return;
    setState(() => _starts = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  Future<void> _send() async {
    final away = _away;
    if (away == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(teamRepositoryProvider).create(
          homeGroupId: _home.id,
          awayGroupId: away.id,
          boards: _boards,
          timeControl: _tc,
          startsAt: _starts,
        );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.invalidate(myTeamMatchesProvider);
        Navigator.of(context).pop();
        unawaited(context.push(ChessRoutes.team(value)));
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
    final away = _away;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(gamesL10n.newTeamMatch, style: textTheme.titleLarge),
              const SizedBox(height: GwSpacing.xxs),
              Text(gamesL10n.newTeamMatchHint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              const SizedBox(height: GwSpacing.md),
              if (widget.mine.length > 1)
                DropdownButtonFormField<String>(
                  initialValue: _home.id,
                  decoration: InputDecoration(labelText: gamesL10n.yourGroup),
                  items: [for (final g in widget.mine) DropdownMenuItem(value: g.id, child: Text(g.name))],
                  onChanged: (id) => setState(() => _home = widget.mine.firstWhere((g) => g.id == id)),
                )
              else
                ListTile(contentPadding: EdgeInsets.zero, leading: _GroupBadge(group: _home), title: Text(_home.name), subtitle: Text(gamesL10n.yourGroup)),
              const SizedBox(height: GwSpacing.md),
              if (away != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _GroupBadge(group: away),
                  title: Text(away.name),
                  subtitle: Text(gamesL10n.opponentGroup),
                  trailing: IconButton(tooltip: gamesL10n.changePerson, icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _away = null)),
                )
              else ...[
                TextField(
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: gamesL10n.searchGroup),
                  onChanged: _search,
                ),
                for (final g in _results)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _GroupBadge(group: g, size: GwAvatarSize.sm),
                    title: Text(g.name),
                    subtitle: Text(atName(g.handle)),
                    onTap: () => setState(() => _away = g),
                  ),
              ],
              const SizedBox(height: GwSpacing.md),
              Text(gamesL10n.boardsCount(_boards), style: textTheme.titleSmall),
              Slider(value: _boards.toDouble(), min: 2, max: 10, divisions: 8, label: '$_boards', onChanged: (v) => setState(() => _boards = v.round())),
              Text(gamesL10n.timeControl, style: textTheme.titleSmall),
              const SizedBox(height: GwSpacing.xs),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final tc in teamTimeControls)
                    ChoiceChip(label: Text('${tc.label} · ${tc.category.label}'), selected: tc == _tc, onSelected: (_) => setState(() => _tc = tc)),
                ],
              ),
              const SizedBox(height: GwSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(gamesL10n.startsAt),
                subtitle: Text(formatDateTime(_starts)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: _pickStart,
              ),
              if (_error case final e?) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(e)],
              const SizedBox(height: GwSpacing.md),
              GwButton(label: gamesL10n.sendTeamInvite, icon: Icons.send_rounded, expand: true, isLoading: _sending, onPressed: away == null ? null : _send),
            ],
          ),
        ),
      ),
    );
  }
}

/// The group leaderboard by team-match Elo, with the same podium as the people's.
class GroupLeaderboard extends ConsumerWidget {
  const GroupLeaderboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(groupLeaderboardProvider);
    final textTheme = Theme.of(context).textTheme;
    return switch (entries) {
      AsyncData(:final value) when value.isEmpty => Center(
          child: GwEmptyState(
            icon: Icons.groups_outlined,
            message: gamesL10n.groupLeaderboardEmpty,
            actionLabel: gamesL10n.backToChess,
            onAction: () => context.canPop() ? context.pop() : context.go(ChessRoutes.home),
          ),
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(groupLeaderboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              GwCard(
                padding: const EdgeInsets.fromLTRB(GwSpacing.sm, GwSpacing.lg, GwSpacing.sm, GwSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (index, lift) in [(1, GwSpacing.xxl), (0, GwSpacing.xxl + GwSpacing.md), (2, GwSpacing.xl + GwSpacing.xs)])
                      Expanded(
                        child: index < value.length
                            ? _GroupStep(entry: value[index], lift: lift)
                            : SizedBox(height: lift),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GwSpacing.md),
              GwCard(
                child: Column(
                  children: [
                    for (final (i, e) in value.indexed)
                      if (i >= 3) ...[
                        if (i > 3) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                        ListTile(
                          leading: RankBadge(rank: e.rank),
                          title: Row(
                            children: [
                              _GroupBadge(group: e.group, size: GwAvatarSize.sm),
                              const SizedBox(width: GwSpacing.sm),
                              Expanded(child: Text(e.group.name, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          subtitle: Text(gamesL10n.record(e.wins, e.draws, e.losses)),
                          trailing: Text('${e.rating}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(groupLeaderboardProvider)),
      _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
    };
  }
}

class _GroupStep extends StatelessWidget {
  const _GroupStep({required this.entry, required this.lift});

  final GroupLeaderboardEntry entry;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final medal = GwMedal.forRank(entry.rank) ?? GwMedal.bronze;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Crowned(
              rank: entry.rank,
              avatarSize: (entry.rank == 1 ? GwAvatarSize.xl : GwAvatarSize.lg).dimension,
              child: Container(
                padding: const EdgeInsets.all(GwBorders.ringWidth),
                decoration: BoxDecoration(borderRadius: GwRadius.lgAll, border: Border.all(color: medal.strong, width: GwBorders.ringWidth)),
                child: _GroupBadge(group: entry.group, size: entry.rank == 1 ? GwAvatarSize.xl : GwAvatarSize.lg),
              ),
            ),
            Positioned(bottom: -GwSpacing.xl, child: RankBadge(rank: entry.rank, size: GwSpacing.xl + GwSpacing.xxs)),
          ],
        ),
        const SizedBox(height: GwSpacing.xl + GwSpacing.sm),
        Text(entry.group.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        Text(gamesL10n.record(entry.wins, entry.draws, entry.losses), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
        const SizedBox(height: GwSpacing.xs),
        Container(
          width: double.infinity,
          height: lift,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: medal.soft, borderRadius: GwRadius.mdAll),
          child: Text('${entry.rating}', style: textTheme.titleMedium?.copyWith(color: medal.strong, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
