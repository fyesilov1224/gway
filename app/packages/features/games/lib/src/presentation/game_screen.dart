import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../domain/chess.dart';
import '../domain/position.dart';
import '../l10n.dart';
import 'appearance.dart';
import 'chess_board.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// One game: the opponent on top, the board, the person below, the moves and the game actions
/// (docs/ARCHITECTURE.md §3i, Uygulama). Spectators see the same screen without the controls.
class ChessGameScreen extends ConsumerStatefulWidget {
  const ChessGameScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends ConsumerState<ChessGameScreen> {
  bool _flipped = false;

  /// The half-move being looked at; null follows the game live.
  int? _viewPly;
  StreamSubscription<String>? _errors;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    // Errors come once from the controller; listening after it is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenErrors());
  }

  Future<void> _listenErrors() async {
    try {
      await ref.read(gameControllerProvider(widget.gameId).future);
    } on Object {
      return;
    }
    if (!mounted) return;
    _errors = ref.read(gameControllerProvider(widget.gameId).notifier).errors.listen((message) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  void dispose() {
    _errors?.cancel();
    super.dispose();
  }

  GameController get _controller => ref.read(gameControllerProvider(widget.gameId).notifier);

  Future<void> _confirm(String title, String message, String action, Future<void> Function() run) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(gamesL10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(dialog).pop(true), child: Text(action)),
        ],
      ),
    );
    if (sure ?? false) await run();
  }

  Future<void> _rematch() async {
    final messenger = ScaffoldMessenger.of(context);
    switch (await _controller.rematch()) {
      case Ok(value: (gameId: final game?, challengeId: _)):
        if (mounted) context.pushReplacement(ChessRoutes.game(game));
      case Ok():
        messenger.showSnackBar(SnackBar(content: Text(gamesL10n.rematchSent)));
      case Err(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  void _showResult(GameState s, ChessColor? mine) {
    if (_resultShown) return;
    _resultShown = true;
    final game = s.game;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => _ResultSheet(
          game: game,
          mine: mine,
          players: s.players,
          onRematch: game.whiteId != null && game.blackId != null && mine != null && game.tournamentId == null
              ? () {
                  Navigator.of(sheet).pop();
                  _rematch();
                }
              : null,
          onNewGame: () {
            Navigator.of(sheet).pop();
            context.pushReplacement(_next(game));
          },
        ),
      );
    });
  }

  /// After the game: the arena or team match it belongs to, otherwise a new quick game.
  static String _next(ChessGame game) => switch (game) {
        ChessGame(:final tournamentId?) => ChessRoutes.arena(tournamentId),
        ChessGame(:final teamMatchId?) => ChessRoutes.team(teamMatchId),
        _ => ChessRoutes.seek(game.timeControl),
      };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameControllerProvider(widget.gameId));
    final pieces = ref.watch(currentPieceSetProvider);
    final me = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (async.value?.game) {
          final g? => '${g.timeControl.label} · ${g.timeControl.category.label} · ${g.rated ? gamesL10n.rated : gamesL10n.casual}',
          null => gamesL10n.chess,
        }),
        actions: [
          IconButton(
            tooltip: gamesL10n.appearance,
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => showAppearanceSheet(context),
          ),
          IconButton(
            tooltip: gamesL10n.flipBoard,
            icon: const Icon(Icons.swap_vert_rounded),
            onPressed: () => setState(() => _flipped = !_flipped),
          ),
        ],
      ),
      body: switch ((async, pieces)) {
        (AsyncData(value: final s), AsyncData(value: final set)) => _body(s, set, me),
        (AsyncError(), _) || (_, AsyncError()) => GwErrorState(
            message: userMessageOf(async.error ?? pieces.error),
            onRetry: () {
              ref.invalidate(gameControllerProvider(widget.gameId));
              ref.invalidate(currentPieceSetProvider);
            },
          ),
        _ => const _GameSkeleton(),
      },
    );
  }

  Widget _body(GameState s, PieceSet pieces, String? me) {
    final game = s.game;
    final mine = game.colorOf(me);
    if (!game.isActive && mine != null) _showResult(s, mine);
    final own = mine ?? ChessColor.white;
    final bottom = _flipped ? own.opposite : own;
    final top = bottom.opposite;
    final premove = s.premove;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final theme = ref.watch(chessAppearanceProvider).board;

    // Looking back: the board shows an earlier position and takes no moves.
    final viewPly = _viewPly != null && _viewPly! < game.ply ? _viewPly : null;
    final fen = viewPly == null ? game.fen : fenAt(game.moves, viewPly);
    final shownLast = switch (viewPly) {
      null => game.lastMove,
      0 => null,
      final n => (game.moves[n - 1].substring(0, 2), game.moves[n - 1].substring(2, 4)),
    };
    final taken = captures(fen);

    final board = ChessBoard(
      fen: fen,
      pieces: pieces,
      theme: theme,
      orientation: bottom,
      movable: game.isActive && viewPly == null ? mine : null,
      lastMove: shownLast,
      premove: premove == null || viewPly != null ? null : (premove.substring(0, 2), premove.substring(2, 4)),
      onMove: _controller.move,
      onPremove: _controller.setPremove,
    );
    Widget side(ChessColor color) => _PlayerBar(
          game: game,
          color: color,
          player: s.players[game.idOf(color)],
          state: s,
          onFlag: _controller.flag,
          captured: color == ChessColor.white ? taken.white : taken.black,
          pieces: pieces,
        );
    final navigator = _MoveNavigator(
      ply: viewPly ?? game.ply,
      total: game.ply,
      onGo: (p) => setState(() => _viewPly = p >= game.ply ? null : p),
    );

    final controls = _Controls(
      game: game,
      mine: mine,
      onAbort: () => _controller.abort(),
      onResign: () => _confirm(gamesL10n.resignTitle, gamesL10n.resignBody, gamesL10n.resign, _controller.resign),
      onOfferDraw: () => _controller.offerDraw(),
      onAcceptDraw: () => _controller.acceptDraw(),
      onDeclineDraw: () => _controller.declineDraw(),
      onRematch: _rematch,
      onNewGame: () => context.pushReplacement(_next(game)),
    );

    final column = <Widget>[
      side(top),
      const SizedBox(height: GwSpacing.xs),
      board,
      const SizedBox(height: GwSpacing.xs),
      side(bottom),
      const SizedBox(height: GwSpacing.xs),
      navigator,
    ];
    if (wide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.dashboardMaxWidth),
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(mainAxisSize: MainAxisSize.min, children: column)),
                const SizedBox(width: GwSpacing.lg),
                Expanded(
                  flex: 2,
                  child: GwCard(
                    padding: const EdgeInsets.all(GwSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        controls,
                        const Divider(height: GwSpacing.lg),
                        _MoveList(san: game.san, vertical: true, current: viewPly ?? game.ply, onTap: (p) => setState(() => _viewPly = p)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xs),
        children: [
          ...column,
          const SizedBox(height: GwSpacing.xs),
          _MoveList(san: game.san, vertical: false, current: viewPly ?? game.ply, onTap: (p) => setState(() => _viewPly = p)),
          const SizedBox(height: GwSpacing.sm),
          Padding(padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs), child: controls),
        ],
      ),
    );
  }
}

/// A player above or below the board: picture, name, flag, rating and the running clock.
class _PlayerBar extends StatefulWidget {
  const _PlayerBar({
    required this.game,
    required this.color,
    required this.player,
    required this.state,
    required this.onFlag,
    required this.captured,
    required this.pieces,
  });

  final ChessGame game;

  /// What this side has taken and its material lead.
  final Captures captured;
  final PieceSet pieces;
  final ChessColor color;
  final ChessPlayer? player;
  final GameState state;
  final VoidCallback onFlag;

  @override
  State<_PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<_PlayerBar> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final g = widget.game;
      if (!g.clockRunning || g.toMove != widget.color) return;
      setState(() {});
      final left = g.remainingMs(widget.color, widget.state.serverNow);
      if (left <= 0) widget.onFlag();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final textTheme = Theme.of(context).textTheme;
    final left = g.remainingMs(widget.color, widget.state.serverNow);
    final running = g.clockRunning && g.toMove == widget.color;
    final low = left < 20000;
    final player = widget.player;
    final delta = g.deltaOf(widget.color);
    final firstMoveCountdown = g.isActive && g.ply < 2 && g.toMove == widget.color;
    return GwCard(
      radius: GwRadius.lgAll,
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: player == null
                ? Text(gamesL10n.deletedPlayer, style: textTheme.titleSmall)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChessPlayerLine(
                        player: player,
                        size: GwAvatarSize.sm,
                        subtitle: '${g.ratingOf(widget.color)}',
                        trailing: delta == null ? null : RatingDelta(delta),
                      ),
                      if (widget.captured.taken.isNotEmpty) _Captured(captures: widget.captured, pieces: widget.pieces),
                    ],
                  ),
          ),
          if (g.drawOffer == widget.color && g.isActive) ...[
            Tooltip(message: gamesL10n.drawOffered, child: const Icon(Icons.handshake_outlined, color: GwColors.primary)),
            const SizedBox(width: GwSpacing.xs),
          ],
          if (firstMoveCountdown)
            Padding(
              padding: const EdgeInsets.only(right: GwSpacing.xs),
              // A team board waits five minutes for its players (docs/ARCHITECTURE.md §3i).
              child: Text(g.teamMatchId != null ? gamesL10n.firstMoveTeam : gamesL10n.firstMove, style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary)),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
            decoration: BoxDecoration(
              color: running ? (low ? GwColors.errorSoft : GwColors.primary) : GwColors.surfaceMuted,
              borderRadius: GwRadius.smAll,
            ),
            child: Text(
              formatClock(left),
              style: textTheme.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w700,
                color: running ? (low ? GwColors.error : GwColors.onPrimary) : GwColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveList extends StatefulWidget {
  const _MoveList({required this.san, required this.vertical, required this.current, required this.onTap});

  final List<String> san;
  final bool vertical;

  /// Half-moves played in the shown position: the move at index current − 1 is highlighted.
  final int current;

  /// Shows the position after the tapped move (its index + 1).
  final ValueChanged<int> onTap;

  @override
  State<_MoveList> createState() => _MoveListState();
}

class _MoveListState extends State<_MoveList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Opening a running game shows its latest moves.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void didUpdateWidget(_MoveList old) {
    super.didUpdateWidget(old);
    if (old.san.length != widget.san.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pairs = [for (var i = 0; i < widget.san.length; i += 2) (i ~/ 2 + 1, widget.san[i], i + 1 < widget.san.length ? widget.san[i + 1] : null)];
    if (pairs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(GwSpacing.sm),
        child: Text(gamesL10n.noMovesYet, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
      );
    }
    final last = widget.current - 1;
    Widget move(String text, int index) => InkWell(
          borderRadius: GwRadius.smAll,
          onTap: () => widget.onTap(index + 1),
          child: Container(
            constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget - GwSpacing.sm),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs),
            decoration: index == last ? const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.smAll) : null,
            child: Text(text, style: textTheme.bodyMedium?.copyWith(fontWeight: index == last ? FontWeight.w700 : null)),
          ),
        );
    if (widget.vertical) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: GwLayout.formMaxWidth),
        child: ListView.builder(
          controller: _scroll,
          shrinkWrap: true,
          itemCount: pairs.length,
          itemBuilder: (_, i) {
            final (n, w, b) = pairs[i];
            return Row(
              children: [
                SizedBox(width: GwSpacing.xl, child: Text('$n.', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary))),
                Expanded(child: move(w, i * 2)),
                Expanded(child: b == null ? const SizedBox.shrink() : move(b, i * 2 + 1)),
              ],
            );
          },
        ),
      );
    }
    return SizedBox(
      height: GwSpacing.xl,
      child: ListView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
        children: [
          for (final (n, w, b) in pairs) ...[
            Center(child: Text('$n.', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary))),
            Center(child: move(w, (n - 1) * 2)),
            if (b != null) Center(child: move(b, (n - 1) * 2 + 1)),
            const SizedBox(width: GwSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.game,
    required this.mine,
    required this.onAbort,
    required this.onResign,
    required this.onOfferDraw,
    required this.onAcceptDraw,
    required this.onDeclineDraw,
    required this.onRematch,
    required this.onNewGame,
  });

  final ChessGame game;
  final ChessColor? mine;
  final VoidCallback onAbort;
  final VoidCallback onResign;
  final VoidCallback onOfferDraw;
  final VoidCallback onAcceptDraw;
  final VoidCallback onDeclineDraw;
  final VoidCallback onRematch;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final me = mine;
    if (me == null) {
      return Text(game.isActive ? gamesL10n.watching : _outcome(game), style: Theme.of(context).textTheme.titleSmall);
    }
    if (!game.isActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_outcome(game), style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: GwSpacing.sm),
          Row(
            children: [
              if (game.whiteId != null && game.blackId != null && game.tournamentId == null) ...[
                Expanded(child: GwButton(label: gamesL10n.rematch, icon: Icons.replay_rounded, onPressed: onRematch)),
                const SizedBox(width: GwSpacing.sm),
              ],
              Expanded(
                child: GwButton(
                  label: _nextLabel(game),
                  icon: game.tournamentId != null || game.teamMatchId != null ? Icons.emoji_events_outlined : Icons.add_rounded,
                  variant: GwButtonVariant.secondary,
                  onPressed: onNewGame,
                ),
              ),
            ],
          ),
        ],
      );
    }
    final incomingOffer = game.drawOffer == me.opposite;
    if (incomingOffer) {
      return GwCard(
        radius: GwRadius.lgAll,
        padding: const EdgeInsets.all(GwSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.handshake_outlined, color: GwColors.primary),
            const SizedBox(width: GwSpacing.sm),
            Expanded(child: Text(gamesL10n.drawOfferReceived)),
            TextButton(onPressed: onDeclineDraw, child: Text(gamesL10n.decline)),
            FilledButton(onPressed: onAcceptDraw, child: Text(gamesL10n.accept)),
          ],
        ),
      );
    }
    final early = game.ply < 2;
    return Row(
      children: [
        Expanded(
          // Arena and team games are never aborted: leaving before the first moves is a resignation.
          child: early && game.tournamentId == null && game.teamMatchId == null
              ? GwButton(label: gamesL10n.abort, icon: Icons.close_rounded, variant: GwButtonVariant.secondary, onPressed: onAbort)
              : GwButton(label: gamesL10n.resign, icon: Icons.flag_outlined, variant: GwButtonVariant.secondary, onPressed: onResign),
        ),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: GwButton(
            label: game.drawOffer == me ? gamesL10n.drawOffered : gamesL10n.offerDraw,
            icon: Icons.handshake_outlined,
            variant: GwButtonVariant.secondary,
            onPressed: early || game.drawOffer == me ? null : onOfferDraw,
          ),
        ),
      ],
    );
  }
}

String _nextLabel(ChessGame game) => game.tournamentId != null
    ? gamesL10n.backToArena
    : game.teamMatchId != null
        ? gamesL10n.backToTeamMatch
        : gamesL10n.newGame;

/// "Beyaz kazandı · Mat", "Berabere · Pat", "İptal edildi".
String _outcome(ChessGame game) {
  final how = game.termination?.label ?? '';
  if (game.status == GameStatus.aborted) return gamesL10n.endAborted;
  if (game.isDraw) return '${gamesL10n.draw} · $how';
  return '${game.winner == ChessColor.white ? gamesL10n.whiteWon : gamesL10n.blackWon} · $how';
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({required this.game, required this.mine, required this.players, required this.onRematch, required this.onNewGame});

  final ChessGame game;
  final ChessColor? mine;
  final Map<String, ChessPlayer> players;
  final VoidCallback? onRematch;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final me = mine;
    final score = me == null ? null : game.scoreFor(me);
    final (icon, tone) = switch (score) {
      1.0 => (Icons.emoji_events_rounded, GwMedal.gold.strong),
      0.5 => (Icons.handshake_rounded, GwColors.secondary),
      0.0 => (Icons.sentiment_neutral_rounded, GwColors.textSecondary),
      _ => (Icons.do_not_disturb_on_outlined, GwColors.textSecondary),
    };
    final delta = me == null ? null : game.deltaOf(me);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: GwSpacing.xxl, color: tone),
            const SizedBox(height: GwSpacing.sm),
            Text(me == null ? _outcome(game) : resultFor(game, me), style: textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: GwSpacing.xxs),
            Text(game.termination?.label ?? '', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary), textAlign: TextAlign.center),
            if (delta != null && me != null) ...[
              const SizedBox(height: GwSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(gamesL10n.newRating(game.timeControl.category.label, game.ratingOf(me) + delta), style: textTheme.titleMedium),
                  const SizedBox(width: GwSpacing.xs),
                  RatingDelta(delta),
                ],
              ),
            ],
            const SizedBox(height: GwSpacing.lg),
            if (onRematch != null) ...[
              GwButton(label: gamesL10n.rematch, icon: Icons.replay_rounded, expand: true, onPressed: onRematch),
              const SizedBox(height: GwSpacing.sm),
            ],
            GwButton(label: _nextLabel(game), icon: Icons.add_rounded, expand: true, variant: GwButtonVariant.secondary, onPressed: onNewGame),
          ],
        ),
      ),
    );
  }
}

class _GameSkeleton extends StatelessWidget {
  const _GameSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(GwSpacing.page),
        child: Column(
          children: [
            GwSkeleton(height: GwSpacing.xxl),
            SizedBox(height: GwSpacing.xs),
            AspectRatio(aspectRatio: 1, child: GwSkeleton(height: double.infinity, borderRadius: GwRadius.mdAll)),
            SizedBox(height: GwSpacing.xs),
            GwSkeleton(height: GwSpacing.xxl),
          ],
        ),
      );
}


/// Small images of the pieces a side has taken, and "+3" when it leads in material.
class _Captured extends StatelessWidget {
  const _Captured({required this.captures, required this.pieces});

  final Captures captures;
  final PieceSet pieces;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: GwSpacing.xxl - GwSpacing.xs),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final p in captures.taken)
              SizedBox.square(dimension: GwSpacing.md + GwSpacing.xxs, child: ScalableImageWidget(si: pieces[p]!)),
            if (captures.lead > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: GwSpacing.xxs),
                child: Text('+${captures.lead}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GwColors.textSecondary)),
              ),
          ],
        ),
      );
}

/// First, back, forward and latest: looking through the game while it goes on.
class _MoveNavigator extends StatelessWidget {
  const _MoveNavigator({required this.ply, required this.total, required this.onGo});

  final int ply;
  final int total;
  final ValueChanged<int> onGo;

  @override
  Widget build(BuildContext context) {
    final behind = ply < total;
    return Row(
      children: [
        IconButton(tooltip: gamesL10n.firstPosition, icon: const Icon(Icons.first_page_rounded), onPressed: ply > 0 ? () => onGo(0) : null),
        IconButton(tooltip: gamesL10n.previousMove, icon: const Icon(Icons.chevron_left_rounded), onPressed: ply > 0 ? () => onGo(ply - 1) : null),
        Expanded(
          child: behind
              ? TextButton.icon(
                  onPressed: () => onGo(total),
                  icon: const Icon(Icons.sensors_rounded),
                  label: Text(gamesL10n.backToLive),
                )
              : const SizedBox.shrink(),
        ),
        IconButton(tooltip: gamesL10n.nextMove, icon: const Icon(Icons.chevron_right_rounded), onPressed: behind ? () => onGo(ply + 1) : null),
        IconButton(tooltip: gamesL10n.lastPosition, icon: const Icon(Icons.last_page_rounded), onPressed: behind ? () => onGo(total) : null),
      ],
    );
  }
}
