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
/// the current question with its time bar, a moment of right or wrong, then the next. Plain and calm on purpose.
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
        MindKind.reflex => {'cell': -1, 'reactionMs': 0},
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
// Header: both players, live scores and one mark per question
// ---------------------------------------------------------------------------

class _DuelHeader extends StatelessWidget {
  const _DuelHeader({required this.state, required this.mySide});

  final MindMatchState state;
  final MindSide mySide;

  @override
  Widget build(BuildContext context) {
    final m = state.match;
    ChessPlayer? player(MindSide side) => state.players[m.idOf(side)];
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Seat(player: player(mySide), rating: m.ratingOf(mySide), score: m.scoreOf(mySide))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
                child: Text(gamesL10n.versus, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
              ),
              Expanded(
                child: _Seat(player: player(mySide.other), rating: m.ratingOf(mySide.other), score: m.scoreOf(mySide.other), mirrored: true),
              ),
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
  const _Seat({required this.player, required this.rating, required this.score, this.mirrored = false});

  final ChessPlayer? player;
  final int rating;
  final int score;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = player;
    final name = Column(
      crossAxisAlignment: mirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(p?.displayName ?? gamesL10n.deletedPlayer, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
            if (p?.country != null) ...[const SizedBox(width: GwSpacing.xxs), ChessFlag(p!.country)],
          ],
        ),
        Text('$rating', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
      ],
    );
    final avatar = GwAvatar(name: p?.displayName ?? '?', shape: GwAvatarShape.user, imageUrl: p?.avatarUrl, size: GwAvatarSize.sm);
    final scoreText = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
      child: Text(
        '$score',
        key: ValueKey(score),
        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
    return Column(
      crossAxisAlignment: mirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: mirrored
              ? [Expanded(child: name), const SizedBox(width: GwSpacing.xs), avatar]
              : [avatar, const SizedBox(width: GwSpacing.xs), Expanded(child: name)],
        ),
        const SizedBox(height: GwSpacing.xxs),
        Semantics(label: gamesL10n.pointsShort(score), excludeSemantics: true, child: scoreText),
      ],
    );
  }
}

/// One thin mark per question: green right, amber partly right, red wrong or missed, empty still to come.
class _Marks extends StatelessWidget {
  const _Marks({required this.points, required this.length, required this.label});

  final List<int> points;
  final int length;
  final String label;

  static Color colorOf(int p) => p > 100
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
            for (var i = 0; i < length; i++) ...[
              if (i > 0) SizedBox(width: length > 20 ? 1 : GwSpacing.xxs / 2),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: GwSpacing.xxs + 2,
                  decoration: BoxDecoration(
                    color: i < points.length ? colorOf(points[i]) : GwColors.border,
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
          const SizedBox(height: GwSpacing.sm),
          Text('$seconds', style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, color: GwColors.primary)),
          const SizedBox(height: GwSpacing.sm),
          Text(gamesL10n.mindScoringHint, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        ],
      ),
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
          const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

/// The question with its kind, number and time bar; the kind's own view below.
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
              Icon(mindKindIcon(q.kind), size: GwSpacing.md + GwSpacing.xxs, color: GwColors.primary),
              const SizedBox(width: GwSpacing.xs),
              Text(q.kind.label, style: textTheme.labelLarge?.copyWith(color: GwColors.primary)),
              const Spacer(),
              Text(gamesL10n.mindQuestionOf(q.index + 1, state.match.length), style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
          const SizedBox(height: GwSpacing.xs),
          ClipRRect(
            borderRadius: GwRadius.smAll,
            child: LinearProgressIndicator(
              value: result == null ? remaining : 0,
              minHeight: GwSpacing.xxs,
              backgroundColor: GwColors.surfaceMuted,
              color: remaining < 0.25 ? GwColors.error : GwColors.primary,
            ),
          ),
          const SizedBox(height: GwSpacing.md),
          switch (q.kind) {
            MindKind.math => _MathView(question: q, result: result, given: state.given, onAnswer: answer),
            MindKind.attention => _AttentionView(question: q, result: result, given: state.given, onAnswer: answer),
            MindKind.memory => _MemoryView(question: q, result: result, given: state.given, elapsedMs: state.elapsedMs, onAnswer: answer),
            MindKind.reflex => _ReflexView(question: q, result: result, given: state.given, startedLocal: state.startedLocal, onAnswer: answer),
          },
          const SizedBox(height: GwSpacing.sm),
          SizedBox(
            height: GwSpacing.xl,
            child: Center(child: result == null ? null : _Verdict(result: result, kind: q.kind, given: state.given)),
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
      MindKind.reflex => Icons.ads_click_rounded,
    };

/// "+142", "Yanlış", "Erken dokundun · −50".
class _Verdict extends StatelessWidget {
  const _Verdict({required this.result, required this.kind, required this.given});

  final MindAnswered result;
  final MindKind kind;
  final Map<String, Object?>? given;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final early = kind == MindKind.reflex && result.points < 0 && given?['cell'] == result.cell;
    final (text, color, soft) = switch (result) {
      MindAnswered(correct: true) => (gamesL10n.mindRight(result.points), GwColors.success, GwColors.successSoft),
      MindAnswered(points: > 0) => (gamesL10n.mindPartly(result.points), GwColors.warning, GwColors.warningSoft),
      MindAnswered(points: < 0) when early => (gamesL10n.mindTooEarly(-result.points), GwColors.error, GwColors.errorSoft),
      MindAnswered(points: < 0) => (gamesL10n.mindWrongPenalty(-result.points), GwColors.error, GwColors.errorSoft),
      _ => (gamesL10n.mindWrong, GwColors.error, GwColors.errorSoft),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.xxs),
        decoration: BoxDecoration(color: soft, borderRadius: GwRadius.xlAll),
        child: Text(text, style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${question.expression} = ?',
            style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
        const SizedBox(height: GwSpacing.lg),
        _Grid(children: [
          for (final (i, n) in choices.indexed)
            _ChoiceTile(
              mark: _markFor(i, result?.choice, given?['choice'], result != null),
              onTap: () => onAnswer({'choice': i}),
              child: Text('$n', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.lg),
          decoration: BoxDecoration(color: GwColors.surface, borderRadius: GwRadius.lgAll, border: Border.all(color: GwColors.border)),
          child: Text(
            describeFigure(question.described),
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: GwMindColor.parse(question.ink).color),
          ),
        ),
        const SizedBox(height: GwSpacing.lg),
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

/// Shown, then hidden: pick the characters back in order and in their colors.
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
    final tile = (GwSpacing.xxl + GwSpacing.xxs).clamp(0.0, (MediaQuery.sizeOf(context).width - GwSpacing.xxl * 2) / items.length - GwSpacing.xs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(showing ? gamesL10n.mindMemoryLook : gamesL10n.mindMemoryPick,
            textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        const SizedBox(height: GwSpacing.sm),
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
                MindCharTile(char: i < _picks.length ? options[_picks[i]] : null, hidden: i >= _picks.length, size: tile),
          ],
        ),
        if (!showing) ...[
          const SizedBox(height: GwSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              for (final (i, o) in options.indexed)
                Opacity(
                  opacity: _picks.contains(i) ? 0.3 : 1,
                  child: Semantics(
                    button: true,
                    label: gamesL10n.mindCharLabel(o.char, gamesL10n.mindColorWord('${o.color}_m')),
                    child: InkWell(
                      borderRadius: GwRadius.mdAll,
                      onTap: result == null ? () => _pick(i) : null,
                      child: ExcludeSemantics(child: MindCharTile(char: o, size: GwSpacing.xxl)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
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

/// "Hedefe dokun": the target waits above the grid; it shows up in one cell for a moment.
class _ReflexView extends StatefulWidget {
  const _ReflexView({required this.question, required this.result, required this.given, required this.startedLocal, required this.onAnswer});

  final MindQuestion question;
  final MindAnswered? result;
  final Map<String, Object?>? given;
  final DateTime? startedLocal;
  final ValueChanged<Map<String, Object?>> onAnswer;

  @override
  State<_ReflexView> createState() => _ReflexViewState();
}

class _ReflexViewState extends State<_ReflexView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// The frame the target was first drawn on; the reaction counts from there.
  DateTime? _shownAt;
  bool _sent = false;

  int get _elapsed => widget.startedLocal == null ? 0 : DateTime.now().difference(widget.startedLocal!).inMilliseconds;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _frame())..start();
  }

  void _frame() {
    if (!mounted) return;
    final q = widget.question;
    final e = _elapsed;
    if (_shownAt == null && e >= q.delayMs && e < q.delayMs + q.visibleMs) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _shownAt ??= DateTime.now());
    }
    // The target came and went without a tap.
    if (!_sent && widget.result == null && e > q.delayMs + q.visibleMs + 200) _send(-1, 0);
    setState(() {});
    if (widget.result != null) _ticker.stop();
  }

  void _send(int cell, int reaction) {
    if (_sent) return;
    _sent = true;
    widget.onAnswer({'cell': cell, 'reactionMs': reaction});
  }

  void _tap(int cell) {
    unawaited(HapticFeedback.lightImpact());
    final shown = _shownAt;
    // Before the target was drawn the reaction is negative: an early tap.
    final reaction = shown == null ? -1 : DateTime.now().difference(shown).inMilliseconds;
    _send(cell, reaction);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = widget.question;
    final e = _elapsed;
    final result = widget.result;
    final showTarget = result != null || (e >= q.delayMs && e < q.delayMs + q.visibleMs);
    final decoys = q.decoys;
    final tapped = widget.given?['cell'] as int?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(gamesL10n.mindReflexTarget, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(width: GwSpacing.xs),
            MindFigureView(figure: q.target, size: GwSpacing.xl + GwSpacing.xs),
          ],
        ),
        const SizedBox(height: GwSpacing.xxs),
        Text(
          result != null ? '' : (e < q.delayMs ? gamesL10n.mindReflexWait : gamesL10n.mindReflexTap),
          textAlign: TextAlign.center,
          style: textTheme.titleSmall?.copyWith(color: e < q.delayMs ? GwColors.textSecondary : GwColors.primary),
        ),
        const SizedBox(height: GwSpacing.sm),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.count(
            crossAxisCount: q.grid,
            mainAxisSpacing: GwSpacing.xs,
            crossAxisSpacing: GwSpacing.xs,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < decoys.length; i++)
                _ChoiceTile(
                  mark: result == null
                      ? null
                      : i == result.cell
                          ? true
                          : i == tapped
                              ? false
                              : null,
                  onTap: result == null ? () => _tap(i) : null,
                  child: LayoutBuilder(
                    builder: (_, c) => MindFigureView(
                      figure: showTarget && i == q.targetCell ? q.target : decoys[i],
                      size: c.biggest.shortestSide,
                      label: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
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
    final (title, color) = switch (outcome) {
      1.0 => (gamesL10n.youWon, GwColors.success),
      0.0 => (gamesL10n.youLost, GwColors.error),
      0.5 => (gamesL10n.draw, GwColors.textPrimary),
      _ => (gamesL10n.endAborted, GwColors.textSecondary),
    };
    final delta = m.deltaOf(side);
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.lg),
      child: Column(
        children: [
          Text(widget.side == null ? gamesL10n.mindFinished : title, style: textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
          if (m.termination case final t?) ...[
            const SizedBox(height: GwSpacing.xxs),
            Text(t.label, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          ],
          const SizedBox(height: GwSpacing.md),
          Text(
            '${m.scoreOf(side)}  –  ${m.scoreOf(side.other)}',
            style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          if (delta != null) ...[
            const SizedBox(height: GwSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(gamesL10n.mindNewRating(m.ratingOf(side) + delta), style: textTheme.titleSmall),
                const SizedBox(width: GwSpacing.xs),
                RatingDelta(delta),
              ],
            ),
          ],
          if (widget.side != null) ...[
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
