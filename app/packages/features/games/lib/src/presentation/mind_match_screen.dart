import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../domain/mind.dart';
import '../l10n.dart';
import 'mind_figure.dart';
import 'mind_providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// A live duel (docs/ARCHITECTURE.md §3j, Uygulama): both players on top with their live scores and question marks,
/// the current question with its countdown ring, a moment of right or wrong, then the next; a result with the stats.
class MindMatchScreen extends ConsumerStatefulWidget {
  const MindMatchScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MindMatchScreen> createState() => _MindMatchScreenState();
}

class _MindMatchScreenState extends ConsumerState<MindMatchScreen> {
  StreamSubscription<String>? _errors;
  Timer? _tick;

  /// The question a timeout was already sent for.
  int? _timedOut;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) => _onTick());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _errors?.cancel();
    super.dispose();
  }

  MindMatchController get _controller => ref.read(mindMatchControllerProvider(widget.matchId).notifier);

  void _onTick() {
    if (!mounted) return;
    final s = ref.read(mindMatchControllerProvider(widget.matchId)).value;
    if (s == null || !s.match.isActive) return;
    setState(() {});
    final q = s.question;
    // Time is up: the empty answer lets the server count it (a memory answer keeps what was picked).
    if (q != null && s.result == null && !s.sending && s.elapsedMs > q.limitMs && _timedOut != q.index) {
      _timedOut = q.index;
      unawaited(_controller.answer(_emptyAnswer(q.kind)));
    }
  }

  static Map<String, Object?> _emptyAnswer(MindKind kind) => switch (kind) {
        MindKind.math || MindKind.attention => {'choice': -1},
        MindKind.memory => {'picks': <int>[]},
        MindKind.reflex => {'picks': <int>[]},
      };

  Future<void> _resign() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gamesL10n.mindResignTitle),
        content: Text(gamesL10n.mindResignBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(gamesL10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(gamesL10n.resign)),
        ],
      ),
    );
    if (ok ?? false) await _controller.resign();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(mindMatchControllerProvider(widget.matchId));
    _errors ??= async.hasValue
        ? _controller.errors.listen((m) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
          })
        : null;
    final me = ref.watch(currentUserIdProvider);
    final s = async.value;
    final active = s?.match.isActive ?? false;
    final side = s?.match.sideOf(me);
    return Scaffold(
      appBar: AppBar(
        title: Text(s == null ? gamesL10n.mindDuel : '${gamesL10n.mindDuel} · ${gamesL10n.mindQuestions(s.match.length)}'),
        actions: [
          if (active && side != null)
            IconButton(tooltip: gamesL10n.resign, icon: const Icon(Icons.flag_outlined), onPressed: _resign),
        ],
      ),
      body: switch (async) {
        AsyncData(:final value) => SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth + GwSpacing.xxl * 2),
                child: ListView(
                  padding: const EdgeInsets.all(GwSpacing.page),
                  children: [
                    _DuelHeader(state: value, mySide: side ?? MindSide.a),
                    const SizedBox(height: GwSpacing.md),
                    _Body(state: value, mySide: side, onAnswer: _controller.answer, matchId: widget.matchId),
                  ],
                ),
              ),
            ),
          ),
        AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(mindMatchControllerProvider(widget.matchId)),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header: a scoreboard with both players, the live score and one mark per question
// ---------------------------------------------------------------------------

class _DuelHeader extends StatelessWidget {
  const _DuelHeader({required this.state, required this.mySide});

  final MindMatchState state;
  final MindSide mySide;

  @override
  Widget build(BuildContext context) {
    final m = state.match;
    final textTheme = Theme.of(context).textTheme;
    ChessPlayer? player(MindSide side) => state.players[m.idOf(side)];
    final mine = m.scoreOf(mySide);
    final theirs = m.scoreOf(mySide.other);
    final current = (state.question?.index ?? m.answeredBy(mySide)).clamp(0, m.length - 1) + 1;
    Widget score(int value, bool leads) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
          child: Text(
            '$value',
            key: ValueKey(value),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: leads ? GwColors.primary : GwColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
    return GwCard(
      padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.sm),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Seat(player: player(mySide), rating: m.ratingOf(mySide), me: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
                child: Column(
                  children: [
                    Semantics(
                      label: '${gamesL10n.mindYou} ${gamesL10n.pointsShort(mine)}, ${gamesL10n.mindOpponent} ${gamesL10n.pointsShort(theirs)}',
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          score(mine, mine > theirs),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xxs),
                            child: Text(':', style: textTheme.headlineSmall?.copyWith(color: GwColors.textSecondary)),
                          ),
                          score(theirs, theirs > mine),
                        ],
                      ),
                    ),
                    if (m.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs / 2),
                        decoration: const BoxDecoration(color: GwColors.surfaceMuted, borderRadius: GwRadius.xlAll),
                        child: Text(gamesL10n.mindQuestionOf(current, m.length),
                            style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
              Expanded(child: _Seat(player: player(mySide.other), rating: m.ratingOf(mySide.other), mirrored: true)),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          _Marks(points: m.pointsOf(mySide), length: m.length, label: gamesL10n.mindYou),
          const SizedBox(height: GwSpacing.xxs),
          _Marks(points: m.pointsOf(mySide.other), length: m.length, label: gamesL10n.mindOpponent),
        ],
      ),
    );
  }
}

class _Seat extends StatelessWidget {
  const _Seat({required this.player, required this.rating, this.mirrored = false, this.me = false});

  final ChessPlayer? player;
  final int rating;
  final bool mirrored;

  /// The reader's own seat: a purple ring around the picture.
  final bool me;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = player;
    final align = mirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(GwBorders.ringWidth),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: me ? GwColors.primary : GwColors.border, width: GwBorders.ringWidth)),
          child: GwAvatar(name: p?.displayName ?? '?', shape: GwAvatarShape.user, imageUrl: p?.avatarUrl, size: GwAvatarSize.md),
        ),
        const SizedBox(height: GwSpacing.xxs),
        Row(
          mainAxisAlignment: mirrored ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (p?.country != null && mirrored) ...[ChessFlag(p!.country), const SizedBox(width: GwSpacing.xxs)],
            Flexible(child: Text(p?.displayName ?? gamesL10n.deletedPlayer, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
            if (p?.country != null && !mirrored) ...[const SizedBox(width: GwSpacing.xxs), ChessFlag(p!.country)],
          ],
        ),
        Text('$rating', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary, fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    );
  }
}

/// One mark per question: green right, amber partly right, red wrong or missed, empty still to come.
class _Marks extends StatelessWidget {
  const _Marks({required this.points, required this.length, required this.label});

  final List<int> points;
  final int length;
  final String label;

  static Color colorOf(int p) => p >= 100
      ? GwColors.success
      : p > 0
          ? GwColors.warning
          : GwColors.error;

  @override
  Widget build(BuildContext context) => Semantics(
        label: gamesL10n.mindProgress(label, points.length, length),
        excludeSemantics: true,
        child: Row(
          children: [
            SizedBox(
              width: GwSpacing.xxl,
              child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GwColors.textSecondary), overflow: TextOverflow.ellipsis),
            ),
            for (var i = 0; i < length; i++) ...[
              if (i > 0) SizedBox(width: length > 20 ? 1 : GwSpacing.xxs / 2),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: GwSpacing.xxs + 2,
                  decoration: BoxDecoration(
                    color: i < points.length ? colorOf(points[i]) : GwColors.surfaceMuted,
                    borderRadius: GwRadius.smAll,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Body: countdown, question, waiting or the result
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.mySide, required this.onAnswer, required this.matchId});

  final MindMatchState state;
  final MindSide? mySide;
  final ValueChanged<Map<String, Object?>> onAnswer;
  final String matchId;

  @override
  Widget build(BuildContext context) {
    final m = state.match;
    final side = mySide;
    if (!m.isActive || side == null) return _Result(match: m, side: side, players: state.players, matchId: matchId);
    final untilStart = m.startsAt.difference(state.serverNow);
    if (untilStart > Duration.zero) return _Countdown(seconds: (untilStart.inMilliseconds / 1000).ceil());
    if (m.doneBy(side) && state.result == null) return _Waiting(match: m, side: side);
    final q = state.question;
    if (q == null) return const Padding(padding: EdgeInsets.all(GwSpacing.xl), child: Center(child: CircularProgressIndicator()));
    return _QuestionCard(key: ValueKey('q${q.index}'), question: q, state: state, onAnswer: onAnswer);
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.xl),
      child: Column(
        children: [
          Text(gamesL10n.mindGetReady, style: textTheme.titleMedium?.copyWith(color: GwColors.textSecondary)),
          const SizedBox(height: GwSpacing.md),
          Container(
            width: GwAvatarSize.xl.dimension,
            height: GwAvatarSize.xl.dimension,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: GwColors.primarySoft, border: Border.all(color: GwColors.primary, width: GwBorders.ringWidth)),
            child: Text('$seconds', style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, color: GwColors.primary)),
          ),
          const SizedBox(height: GwSpacing.md),
          const _KindRow(),
          const SizedBox(height: GwSpacing.md),
          Text(gamesL10n.mindScoringHint, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        ],
      ),
    );
  }
}

/// The four kinds side by side, so the countdown says what is coming.
class _KindRow extends StatelessWidget {
  const _KindRow();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final k in MindKind.values)
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(GwSpacing.xs),
                  decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
                  child: Icon(mindKindIcon(k), color: GwColors.primary),
                ),
                const SizedBox(height: GwSpacing.xxs),
                Text(k.label, style: textTheme.labelSmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
      ],
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.match, required this.side});

  final MindMatch match;
  final MindSide side;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.lg),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: GwColors.success, size: GwSpacing.xl),
          const SizedBox(height: GwSpacing.sm),
          Text(gamesL10n.mindYouFinished, style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            gamesL10n.mindOpponentAt(match.answeredBy(side.other), match.length),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.md),
          ClipRRect(
            borderRadius: GwRadius.smAll,
            child: LinearProgressIndicator(
              value: match.answeredBy(side.other) / match.length,
              minHeight: GwSpacing.xxs,
              backgroundColor: GwColors.surfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// The question: its kind, level and a countdown ring on top, the kind's own view below.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({super.key, required this.question, required this.state, required this.onAnswer});

  final MindQuestion question;
  final MindMatchState state;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = question;
    final result = state.result;
    final locked = result != null || state.sending;
    final remaining = (1 - state.elapsedMs / q.limitMs).clamp(0.0, 1.0);
    final secondsLeft = ((q.limitMs - state.elapsedMs) / 1000).ceil().clamp(0, 999);
    void answer(Map<String, Object?> a) {
      if (!locked) onAnswer(a);
    }

    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xxs),
                decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.xlAll),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mindKindIcon(q.kind), size: GwSpacing.md, color: GwColors.primary),
                    const SizedBox(width: GwSpacing.xxs),
                    Text(q.kind.label, style: textTheme.labelLarge?.copyWith(color: GwColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: GwSpacing.sm),
              _LevelPips(level: q.level),
              const Spacer(),
              _TimerRing(value: result == null ? remaining : 0, seconds: result == null ? secondsLeft : 0),
            ],
          ),
          const SizedBox(height: GwSpacing.md),
          switch (q.kind) {
            MindKind.math => _MathView(question: q, result: result, given: state.given, onAnswer: answer),
            MindKind.attention => _AttentionView(question: q, result: result, given: state.given, onAnswer: answer),
            MindKind.memory => _MemoryView(question: q, result: result, given: state.given, elapsedMs: state.elapsedMs, onAnswer: answer),
            MindKind.reflex => _LightsView(question: q, result: result, startedLocal: state.startedLocal, elapsedMs: state.elapsedMs, onAnswer: answer),
          },
          const SizedBox(height: GwSpacing.sm),
          SizedBox(
            height: GwSpacing.xl,
            child: Center(child: result == null ? null : _Verdict(result: result)),
          ),
        ],
      ),
    );
  }
}

/// Four dots, as many filled as the question's level.
class _LevelPips extends StatelessWidget {
  const _LevelPips({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) => Semantics(
        label: gamesL10n.mindLevel(level),
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 4; i++) ...[
              if (i > 1) const SizedBox(width: GwSpacing.xxs / 2),
              Container(
                width: GwSpacing.xs - 2,
                height: GwSpacing.xs - 2,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i <= level ? GwColors.primary : GwColors.surfaceMuted),
              ),
            ],
          ],
        ),
      );
}

/// The time left as a ring with the seconds in it; red in the last quarter.
class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.value, required this.seconds});

  final double value;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final low = value < 0.25;
    return SizedBox.square(
      dimension: GwSpacing.minTouchTarget,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: GwSpacing.xxs,
            backgroundColor: GwColors.surfaceMuted,
            color: low ? GwColors.error : GwColors.primary,
          ),
          Center(
            child: Text(
              '$seconds',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: low ? GwColors.error : GwColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData mindKindIcon(MindKind kind) => switch (kind) {
      MindKind.math => Icons.calculate_outlined,
      MindKind.attention => Icons.visibility_outlined,
      MindKind.memory => Icons.psychology_outlined,
      MindKind.reflex => Icons.blur_on_rounded,
    };

/// "Doğru · +142", "Kısmen · +40", "Yanlış".
class _Verdict extends StatelessWidget {
  const _Verdict({required this.result});

  final MindAnswered result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (text, color, soft, icon) = switch (result) {
      MindAnswered(correct: true) => (gamesL10n.mindRight(result.points), GwColors.success, GwColors.successSoft, Icons.check_circle_rounded),
      MindAnswered(points: > 0) => (gamesL10n.mindPartly(result.points), GwColors.warning, GwColors.warningSoft, Icons.adjust_rounded),
      MindAnswered(points: < 0) => (gamesL10n.mindWrongPenalty(-result.points), GwColors.error, GwColors.errorSoft, Icons.cancel_rounded),
      _ => (gamesL10n.mindWrong, GwColors.error, GwColors.errorSoft, Icons.cancel_rounded),
    };
    return Semantics(
      liveRegion: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.xxs),
          decoration: BoxDecoration(color: soft, borderRadius: GwRadius.xlAll),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: GwSpacing.md, color: color),
              const SizedBox(width: GwSpacing.xxs),
              Text(text, style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tile that can be chosen; after the answer the right one turns green and a wrong pick red.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.child, required this.onTap, this.mark, this.semantics});

  final Widget child;
  final VoidCallback? onTap;

  /// null: plain; true: the right answer; false: the person's wrong pick.
  final bool? mark;
  final String? semantics;

  @override
  Widget build(BuildContext context) {
    final (border, fill) = switch (mark) {
      true => (GwColors.success, GwColors.successSoft),
      false => (GwColors.error, GwColors.errorSoft),
      null => (GwColors.border, GwColors.background),
    };
    return Semantics(
      button: true,
      label: semantics,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: GwRadius.lgAll,
          side: BorderSide(color: border, width: mark == null ? 1 : GwBorders.ringWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: GwSpacing.xxl + GwSpacing.md),
            child: Center(child: Padding(padding: const EdgeInsets.all(GwSpacing.sm), child: child)),
          ),
        ),
      ),
    );
  }
}

/// Four tiles in two rows.
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var row = 0; row < (children.length / 2).ceil(); row++) ...[
            if (row > 0) const SizedBox(height: GwSpacing.sm),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < 2; col++) ...[
                    if (col > 0) const SizedBox(width: GwSpacing.sm),
                    Expanded(child: row * 2 + col < children.length ? children[row * 2 + col] : const SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
}

bool? _markFor(int i, int? right, Object? picked, bool answered) {
  if (!answered) return null;
  if (i == right) return true;
  if (i == picked) return false;
  return null;
}

/// The prompt on a calm panel: what to look at sits apart from the choices.
class _Stage extends StatelessWidget {
  const _Stage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.lg),
        decoration: const BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.fromBorderSide(GwBorders.hairline)),
        child: child,
      );
}

class _MathView extends StatelessWidget {
  const _MathView({required this.question, required this.result, required this.given, required this.onAnswer});

  final MindQuestion question;
  final MindAnswered? result;
  final Map<String, Object?>? given;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final choices = question.numberChoices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(gamesL10n.mindMathPrompt, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        const SizedBox(height: GwSpacing.sm),
        _Stage(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${question.expression} = ?',
              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        _Grid(children: [
          for (final (i, n) in choices.indexed)
            _ChoiceTile(
              mark: _markFor(i, result?.choice, given?['choice'], result != null),
              onTap: () => onAnswer({'choice': i}),
              child: Text('$n', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
            ),
        ]),
      ],
    );
  }
}

class _AttentionView extends StatelessWidget {
  const _AttentionView({required this.question, required this.result, required this.given, required this.onAnswer});

  final MindQuestion question;
  final MindAnswered? result;
  final Map<String, Object?>? given;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(gamesL10n.mindAttentionPrompt, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        const SizedBox(height: GwSpacing.sm),
        _Stage(
          child: Text(
            describeFigure(question.described),
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: GwMindColor.parse(question.ink).color),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        _Grid(children: [
          for (final (i, f) in question.figureChoices.indexed)
            _ChoiceTile(
              mark: _markFor(i, result?.choice, given?['choice'], result != null),
              semantics: describeFigure(f),
              onTap: () => onAnswer({'choice': i}),
              child: MindFigureView(figure: f, size: GwSpacing.xxl + GwSpacing.sm, label: false),
            ),
        ]),
      ],
    );
  }
}

/// Shown, then hidden: pick the characters back in order and in their colors (each character is offered in three).
class _MemoryView extends StatefulWidget {
  const _MemoryView({required this.question, required this.result, required this.given, required this.elapsedMs, required this.onAnswer});

  final MindQuestion question;
  final MindAnswered? result;
  final Map<String, Object?>? given;
  final int elapsedMs;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  State<_MemoryView> createState() => _MemoryViewState();
}

class _MemoryViewState extends State<_MemoryView> {
  final _picks = <int>[];
  bool _sent = false;

  void _send() {
    if (_sent) return;
    _sent = true;
    widget.onAnswer({'picks': [..._picks]});
  }

  @override
  void didUpdateWidget(_MemoryView old) {
    super.didUpdateWidget(old);
    // Time is nearly up: what was picked so far still counts place by place.
    if (widget.result == null && !_sent && widget.elapsedMs > widget.question.limitMs - 300) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send();
      });
    }
  }

  void _pick(int option) {
    if (_picks.contains(option) || widget.result != null) return;
    setState(() => _picks.add(option));
    unawaited(HapticFeedback.selectionClick());
    if (_picks.length == widget.question.items.length) _send();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = widget.question;
    final items = q.items;
    final options = q.options;
    final showing = widget.elapsedMs < q.showMs && widget.result == null;
    final result = widget.result;
    final width = MediaQuery.sizeOf(context).width.clamp(0.0, GwLayout.formMaxWidth);
    final tile = (GwSpacing.xxl + GwSpacing.xxs).clamp(0.0, (width - GwSpacing.xxl * 2) / items.length - GwSpacing.xs);
    final option = (GwSpacing.xxl).clamp(0.0, (width - GwSpacing.xxl * 2) / 6 - GwSpacing.xs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(showing ? gamesL10n.mindMemoryLook : gamesL10n.mindMemoryPick,
            textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        const SizedBox(height: GwSpacing.sm),
        _Stage(
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (var i = 0; i < items.length; i++)
                    if (showing)
                      MindCharTile(char: items[i], size: tile)
                    else if (result != null)
                      // After the answer: the right sequence, framed by whether each place was picked right.
                      MindCharTile(
                        char: items[i],
                        size: tile,
                        outline: i < _picks.length && i < result.picks.length && _picks[i] == result.picks[i] ? GwColors.success : GwColors.error,
                      )
                    else
                      MindCharTile(
                        char: i < _picks.length ? options[_picks[i]] : null,
                        hidden: i >= _picks.length,
                        size: tile,
                        outline: i == _picks.length ? GwColors.primary : null,
                      ),
                ],
              ),
              if (showing) ...[
                const SizedBox(height: GwSpacing.sm),
                ClipRRect(
                  borderRadius: GwRadius.smAll,
                  child: LinearProgressIndicator(
                    value: (1 - widget.elapsedMs / q.showMs).clamp(0.0, 1.0),
                    minHeight: GwSpacing.xxs,
                    backgroundColor: GwColors.surfaceMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!showing) ...[
          const SizedBox(height: GwSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              for (final (i, o) in options.indexed)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _picks.contains(i) ? 0.25 : 1,
                  child: Semantics(
                    button: true,
                    label: gamesL10n.mindCharLabel(o.char, gamesL10n.mindColorWord('${o.color}_m')),
                    child: InkWell(
                      borderRadius: GwRadius.mdAll,
                      onTap: result == null ? () => _pick(i) : null,
                      child: ExcludeSemantics(child: MindCharTile(char: o, size: option)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GwSpacing.xs),
          Align(
            child: TextButton.icon(
              onPressed: _picks.isEmpty || result != null ? null : () => setState(_picks.removeLast),
              icon: const Icon(Icons.undo_rounded),
              label: Text(gamesL10n.mindUndo),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Işık sırası": sixteen red lights; some light up in turn (green, yellow, orange) within two seconds, then all are
/// red again and the same lights are tapped back in order, fast. A wrong light ends the try.
class _LightsView extends StatefulWidget {
  const _LightsView({required this.question, required this.result, required this.startedLocal, required this.elapsedMs, required this.onAnswer});

  final MindQuestion question;
  final MindAnswered? result;
  final DateTime? startedLocal;
  final int elapsedMs;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  State<_LightsView> createState() => _LightsViewState();
}

class _LightsViewState extends State<_LightsView> with SingleTickerProviderStateMixin {
  /// A short moment with every light red before the first one comes on.
  static const _leadMs = 400;

  late final Ticker _ticker;
  final _picks = <int>[];
  bool _sent = false;

  int get _elapsed => widget.startedLocal == null ? 0 : DateTime.now().difference(widget.startedLocal!).inMilliseconds;

  bool get _watching => _elapsed < _leadMs + widget.question.showMs;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (!mounted) return;
      setState(() {});
      if (!_watching || widget.result != null) _ticker.stop();
    })
      ..start();
  }

  @override
  void didUpdateWidget(_LightsView old) {
    super.didUpdateWidget(old);
    // Time is nearly up: the lights tapped so far still count place by place.
    if (widget.result == null && !_sent && widget.elapsedMs > widget.question.limitMs - 300) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send();
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _send() {
    if (_sent) return;
    _sent = true;
    widget.onAnswer({'picks': [..._picks]});
  }

  void _tap(int cell) {
    final sequence = widget.question.sequence;
    if (_sent || _watching || widget.result != null || _picks.contains(cell)) return;
    setState(() => _picks.add(cell));
    final right = sequence[_picks.length - 1] == cell;
    unawaited(right ? HapticFeedback.selectionClick() : HapticFeedback.heavyImpact());
    if (!right || _picks.length == sequence.length) _send();
  }

  /// The light shown now while watching, or null between flashes.
  int? _litStep() {
    final q = widget.question;
    final t = _elapsed - _leadMs;
    if (t < 0 || q.flashMs <= 0) return null;
    final step = t ~/ q.flashMs;
    if (step >= q.sequence.length) return null;
    return t % q.flashMs < q.flashMs * 0.75 ? step : null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = widget.question;
    final sequence = q.sequence;
    final colors = q.lightColors;
    final result = widget.result;
    final watching = _watching && result == null;
    final lit = watching ? _litStep() : null;
    Color colorAt(int step) => GwMindColor.parse(step < colors.length ? colors[step] : 'green').color;
    final off = GwMindColor.red.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              watching ? gamesL10n.mindLightsWatch : gamesL10n.mindLightsRepeat,
              style: textTheme.titleSmall?.copyWith(color: watching ? GwColors.textSecondary : GwColors.primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: GwSpacing.sm),
            // One dot per light in the sequence, filled as they are tapped.
            for (var i = 0; i < sequence.length; i++) ...[
              if (i > 0) const SizedBox(width: GwSpacing.xxs),
              Container(
                width: GwSpacing.xs,
                height: GwSpacing.xs,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _picks.length ? colorAt(i) : GwColors.surfaceMuted,
                  border: Border.all(color: GwColors.border),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: GwSpacing.sm),
        _Stage(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: q.grid,
              mainAxisSpacing: GwSpacing.sm,
              crossAxisSpacing: GwSpacing.sm,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var cell = 0; cell < q.grid * q.grid; cell++)
                  Builder(builder: (_) {
                    final order = sequence.indexOf(cell);
                    final picked = _picks.indexOf(cell);
                    final pickedRight = picked >= 0 && picked < sequence.length && sequence[picked] == cell;
                    final (Color color, bool on, Color? ring, String? label) = switch (true) {
                      // Watching: the current light in its color.
                      _ when watching => lit != null && sequence[lit] == cell ? (colorAt(lit), true, null, null) : (off, false, null, null),
                      // After the answer: the sequence with its numbers; a wrong tap gets a red ring.
                      _ when result != null => order >= 0
                          ? (colorAt(order), true, pickedRight ? GwColors.success : null, '${order + 1}')
                          : (off, false, picked >= 0 ? GwColors.textPrimary : null, null),
                      // Tapping: the right taps keep their color.
                      _ => pickedRight ? (colorAt(picked), true, null, '${picked + 1}') : (off, false, picked >= 0 ? GwColors.textPrimary : null, null),
                    };
                    return _Light(
                      color: color,
                      on: on,
                      ring: ring,
                      label: label,
                      semantics: gamesL10n.mindLightLabel(cell + 1),
                      onTap: watching || result != null ? null : () => _tap(cell),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One round light: red while off; lit lights grow a little and take their color.
class _Light extends StatelessWidget {
  const _Light({required this.color, required this.on, required this.semantics, this.ring, this.label, this.onTap});

  final Color color;
  final bool on;
  final Color? ring;
  final String? label;
  final String semantics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        label: semantics,
        child: AnimatedScale(
          scale: on ? 1 : 0.84,
          duration: const Duration(milliseconds: 90),
          child: Material(
            color: color,
            shape: CircleBorder(side: BorderSide(color: ring ?? GwColors.background, width: GwBorders.ringWidth + 1)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: label == null
                    ? null
                    : Text(label!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: GwColors.onPrimary, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// The result
// ---------------------------------------------------------------------------

class _Result extends ConsumerStatefulWidget {
  const _Result({required this.match, required this.side, required this.players, required this.matchId});

  final MindMatch match;
  final MindSide? side;
  final Map<String, ChessPlayer> players;
  final String matchId;

  @override
  ConsumerState<_Result> createState() => _ResultState();
}

class _ResultState extends ConsumerState<_Result> {
  bool _asking = false;

  Future<void> _rematch() async {
    setState(() => _asking = true);
    final result = await ref.read(mindMatchControllerProvider(widget.matchId).notifier).rematch();
    if (!mounted) return;
    setState(() => _asking = false);
    switch (result) {
      case Ok(value: (matchId: final match?, challengeId: _)):
        context.pushReplacement(MindRoutes.match(match));
      case Ok():
        ref.invalidate(mindChallengesProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gamesL10n.rematchSent)));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = widget.match;
    final side = widget.side ?? MindSide.a;
    final outcome = m.scoreFor(side);
    final (title, color, icon) = switch (outcome) {
      1.0 => (gamesL10n.youWon, GwColors.success, Icons.emoji_events_rounded),
      0.0 => (gamesL10n.youLost, GwColors.error, Icons.sentiment_neutral_rounded),
      0.5 => (gamesL10n.draw, GwColors.textPrimary, Icons.handshake_rounded),
      _ => (gamesL10n.endAborted, GwColors.textSecondary, Icons.do_not_disturb_on_outlined),
    };
    final delta = m.deltaOf(side);
    final points = m.pointsOf(side);
    final right = points.where((p) => p >= 100).length;
    final average = points.isEmpty ? 0 : (m.scoreOf(side) / points.length).round();
    ChessPlayer? player(MindSide s) => widget.players[m.idOf(s)];

    Widget stat(String label, Widget value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.sm, horizontal: GwSpacing.xxs),
            decoration: const BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.fromBorderSide(GwBorders.hairline)),
            child: Column(
              children: [
                value,
                const SizedBox(height: GwSpacing.xxs),
                Text(label, style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
    final valueStyle = textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]);

    Widget seat(MindSide s, {bool winner = false}) => Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(GwBorders.ringWidth),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: winner ? GwMedal.gold.strong : GwColors.border, width: GwBorders.ringWidth),
                ),
                child: GwAvatar(name: player(s)?.displayName ?? '?', shape: GwAvatarShape.user, imageUrl: player(s)?.avatarUrl, size: GwAvatarSize.lg),
              ),
              const SizedBox(height: GwSpacing.xxs),
              Text(player(s)?.displayName ?? gamesL10n.deletedPlayer, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
              Text('${m.scoreOf(s)}', style: valueStyle),
            ],
          ),
        );

    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: GwSpacing.xxl, color: outcome == 1.0 ? GwMedal.gold.strong : color),
          const SizedBox(height: GwSpacing.xs),
          Text(widget.side == null ? gamesL10n.mindFinished : title, style: textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
          if (m.termination case final t?) ...[
            const SizedBox(height: GwSpacing.xxs),
            Text(t.label, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          ],
          const SizedBox(height: GwSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              seat(side, winner: m.scoreFor(side) == 1.0),
              Padding(
                padding: const EdgeInsets.only(top: GwSpacing.lg),
                child: Text(gamesL10n.versus, style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
              ),
              seat(side.other, winner: m.scoreFor(side.other) == 1.0),
            ],
          ),
          if (widget.side != null) ...[
            const SizedBox(height: GwSpacing.md),
            Row(
              children: [
                stat(gamesL10n.mindStatCorrect, Text('$right/${m.length}', style: valueStyle)),
                const SizedBox(width: GwSpacing.xs),
                stat(gamesL10n.mindStatAverage, Text('$average', style: valueStyle)),
                const SizedBox(width: GwSpacing.xs),
                stat(
                  gamesL10n.mindStatRating,
                  delta == null
                      ? Text('${m.ratingOf(side)}', style: valueStyle)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: FittedBox(child: Text('${m.ratingOf(side) + delta}', style: valueStyle))),
                            const SizedBox(width: GwSpacing.xxs),
                            RatingDelta(delta),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            GwButton(label: gamesL10n.rematch, icon: Icons.replay_rounded, expand: true, isLoading: _asking, onPressed: m.idOf(side.other) == null ? null : _rematch),
            const SizedBox(height: GwSpacing.xs),
            GwButton(
              label: gamesL10n.mindNewDuel,
              variant: GwButtonVariant.secondary,
              expand: true,
              onPressed: () => context.pushReplacement(MindRoutes.seek(m.length)),
            ),
            const SizedBox(height: GwSpacing.xs),
            GwButton(label: gamesL10n.mindBackHome, variant: GwButtonVariant.text, onPressed: () => context.pop()),
          ],
        ],
      ),
    );
  }
}
