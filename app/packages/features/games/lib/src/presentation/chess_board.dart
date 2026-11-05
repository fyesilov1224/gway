import 'dart:async';

import 'package:chess/chess.dart' as rules;
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../domain/chess.dart';
import '../l10n.dart';

/// The twelve piece drawings (Chessnut, Apache 2.0), keyed `wK`, `bP`, ….
typedef PieceSet = Map<String, ScalableImage>;

const _pieceKinds = ['K', 'Q', 'R', 'B', 'N', 'P'];

Future<PieceSet> loadPieceSet(AssetBundle bundle) async => {
      for (final color in ['w', 'b'])
        for (final kind in _pieceKinds)
          '$color$kind': await ScalableImage.fromSvgAsset(bundle, 'packages/games/assets/pieces/$color$kind.svg'),
    };

/// A square as file 0–7 (a–h) and rank 0–7 (1–8).
typedef _Square = ({int file, int rank});

String _name(_Square s) => '${String.fromCharCode(97 + s.file)}${s.rank + 1}';

_Square _parse(String name) => (file: name.codeUnitAt(0) - 97, rank: int.parse(name[1]) - 1);

/// GWAY's chess board: drag or tap to move, legal targets, last move and check, coordinates, promotion and
/// a short slide for the opponent's move (docs/ARCHITECTURE.md §3i, Uygulama). It only proposes moves;
/// the game screen sends them to the server.
class ChessBoard extends StatefulWidget {
  const ChessBoard({
    super.key,
    required this.fen,
    required this.pieces,
    required this.orientation,
    this.movable,
    this.lastMove,
    this.premove,
    this.onMove,
    this.onPremove,
  });

  final String fen;
  final PieceSet pieces;

  /// The side at the bottom.
  final ChessColor orientation;

  /// The color the person may move; null makes the board view-only.
  final ChessColor? movable;
  final (String, String)? lastMove;

  /// A queued move for when the turn comes.
  final (String, String)? premove;

  /// A legal move in UCI (`e2e4`, `e7e8q`) when it is [movable]'s turn.
  final ValueChanged<String>? onMove;

  /// A move queued while the opponent thinks; null clears it.
  final ValueChanged<String?>? onPremove;

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with SingleTickerProviderStateMixin {
  late rules.Chess _position = rules.Chess.fromFEN(widget.fen);
  _Square? _selected;
  _Square? _dragFrom;
  Offset? _dragAt;

  /// A move the person dropped by hand; it lands without sliding.
  String? _placedByHand;
  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 160), value: 1);
  }

  @override
  void didUpdateWidget(ChessBoard old) {
    super.didUpdateWidget(old);
    if (old.fen != widget.fen) {
      _position = rules.Chess.fromFEN(widget.fen);
      final move = widget.lastMove;
      final byHand = move != null && _placedByHand == '${move.$1}${move.$2}';
      _placedByHand = null;
      if (move != null && move != old.lastMove && !byHand) _slide.forward(from: 0);
      if (_selected case final s? when _pieceAt(s) == null) _selected = null;
    }
    if (old.movable != widget.movable && widget.movable == null) _selected = null;
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  bool get _myTurn => widget.movable != null && _position.turn == (widget.movable == ChessColor.white ? rules.Color.WHITE : rules.Color.BLACK);

  rules.Piece? _pieceAt(_Square s) => _position.get(_name(s));

  bool _isMine(_Square s) {
    final piece = _pieceAt(s);
    final mine = widget.movable;
    return piece != null && mine != null && piece.color == (mine == ChessColor.white ? rules.Color.WHITE : rules.Color.BLACK);
  }

  /// Legal targets now, or (opponent to move) the targets the piece would have if it were its turn: a premove
  /// the server checks again when it is played.
  List<rules.Move> _movesFrom(_Square from) {
    if (_myTurn) {
      return [for (final m in _position.generate_moves({'legal': true})) if (m.fromAlgebraic == _name(from)) m];
    }
    if (widget.onPremove == null) return const [];
    final parts = widget.fen.split(' ');
    parts[1] = widget.movable == ChessColor.white ? 'w' : 'b';
    parts[3] = '-';
    final ghost = rules.Chess.fromFEN(parts.join(' '));
    return [for (final m in ghost.generate_moves({'legal': false})) if (m.fromAlgebraic == _name(from)) m];
  }

  _Square _squareAt(Offset local, double size) {
    final col = (local.dx / size).floor().clamp(0, 7);
    final row = (local.dy / size).floor().clamp(0, 7);
    return widget.orientation == ChessColor.white ? (file: col, rank: 7 - row) : (file: 7 - col, rank: row);
  }

  Offset _topLeft(_Square s, double size) => widget.orientation == ChessColor.white
      ? Offset(s.file * size, (7 - s.rank) * size)
      : Offset((7 - s.file) * size, s.rank * size);

  Future<void> _tryMove(_Square from, _Square to, {required bool byHand}) async {
    final candidates = [for (final m in _movesFrom(from)) if (m.toAlgebraic == _name(to)) m];
    setState(() => _selected = null);
    if (candidates.isEmpty) return;
    var uci = '${_name(from)}${_name(to)}';
    if (candidates.any((m) => m.promotion != null)) {
      final white = (widget.movable ?? ChessColor.white) == ChessColor.white;
      final piece = await showDialog<String>(context: context, builder: (_) => _PromotionPicker(pieces: widget.pieces, white: white));
      if (piece == null) return;
      uci += piece;
    }
    if (_myTurn) {
      if (byHand) _placedByHand = uci.substring(0, 4);
      unawaited(HapticFeedback.selectionClick());
      widget.onMove?.call(uci);
    } else {
      widget.onPremove?.call(uci);
    }
  }

  void _onTap(_Square square) {
    if (widget.movable == null) return;
    final selected = _selected;
    if (selected != null && selected != square && _movesFrom(selected).any((m) => m.toAlgebraic == _name(square))) {
      _tryMove(selected, square, byHand: false);
      return;
    }
    if (widget.premove != null) widget.onPremove?.call(null);
    setState(() => _selected = _isMine(square) && selected != square ? square : null);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: gamesL10n.boardLabel,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, constraints) {
          final size = constraints.maxWidth / 8;
          final selected = _selected;
          final targets = selected == null ? const <rules.Move>[] : _movesFrom(selected);
          final check = _position.in_check ? _kingSquare(_position.turn) : null;
          final pieces = <Widget>[];
          for (var rank = 0; rank < 8; rank++) {
            for (var file = 0; file < 8; file++) {
              final square = (file: file, rank: rank);
              final piece = _pieceAt(square);
              if (piece == null || square == _dragFrom) continue;
              final key = '${piece.color == rules.Color.WHITE ? 'w' : 'b'}${piece.type.name.toUpperCase()}';
              final at = _topLeft(square, size);
              final move = widget.lastMove;
              final sliding = move != null && _name(square) == move.$2;
              pieces.add(sliding
                  ? AnimatedBuilder(
                      key: ValueKey('piece-${_name(square)}'),
                      animation: _slide,
                      builder: (_, child) {
                        final from = _topLeft(_parse(move.$1), size);
                        final p = Offset.lerp(from, at, Curves.easeOutCubic.transform(_slide.value))!;
                        return Positioned(left: p.dx, top: p.dy, width: size, height: size, child: child!);
                      },
                      child: _Piece(image: widget.pieces[key]!),
                    )
                  : Positioned(
                      key: ValueKey('piece-${_name(square)}'),
                      left: at.dx,
                      top: at.dy,
                      width: size,
                      height: size,
                      child: _Piece(image: widget.pieces[key]!),
                    ));
            }
          }
          final dragging = _dragFrom;
          final dragAt = _dragAt;
          final dragPiece = dragging == null ? null : _pieceAt(dragging);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _onTap(_squareAt(d.localPosition, size)),
            onPanStart: (d) {
              final from = _squareAt(d.localPosition, size);
              if (!_isMine(from)) return;
              if (widget.premove != null) widget.onPremove?.call(null);
              setState(() {
                _selected = from;
                _dragFrom = from;
                _dragAt = d.localPosition;
              });
            },
            onPanUpdate: (d) {
              if (_dragFrom != null) setState(() => _dragAt = d.localPosition);
            },
            onPanEnd: (_) {
              final from = _dragFrom;
              final at = _dragAt;
              setState(() {
                _dragFrom = null;
                _dragAt = null;
              });
              if (from == null || at == null) return;
              final to = _squareAt(at, size);
              if (to != from) _tryMove(from, to, byHand: true);
            },
            onPanCancel: () => setState(() {
              _dragFrom = null;
              _dragAt = null;
            }),
            child: ClipRRect(
              borderRadius: GwRadius.mdAll,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BoardPainter(
                        orientation: widget.orientation,
                        lastMove: widget.lastMove,
                        premove: widget.premove,
                        selected: selected,
                        check: check,
                        hover: dragAt == null ? null : _squareAt(dragAt, size),
                        targets: {for (final m in targets) _name(_parse(m.toAlgebraic)): m.captured != null},
                        textStyle: Theme.of(context).textTheme.labelSmall!,
                      ),
                    ),
                  ),
                  ...pieces,
                  if (dragPiece != null && dragAt != null)
                    Positioned(
                      left: dragAt.dx - size * 0.6,
                      top: dragAt.dy - size * 0.9,
                      width: size * 1.2,
                      height: size * 1.2,
                      child: IgnorePointer(
                        child: _Piece(image: widget.pieces['${dragPiece.color == rules.Color.WHITE ? 'w' : 'b'}${dragPiece.type.name.toUpperCase()}']!),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _Square? _kingSquare(rules.Color color) {
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final p = _pieceAt((file: file, rank: rank));
        if (p != null && p.type == rules.PieceType.KING && p.color == color) return (file: file, rank: rank);
      }
    }
    return null;
  }
}

class _Piece extends StatelessWidget {
  const _Piece({required this.image});

  final ScalableImage image;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(GwSpacing.xxs / 2),
        child: ScalableImageWidget(si: image, fit: BoxFit.contain),
      );
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.orientation,
    required this.lastMove,
    required this.premove,
    required this.selected,
    required this.check,
    required this.hover,
    required this.targets,
    required this.textStyle,
  });

  final ChessColor orientation;
  final (String, String)? lastMove;
  final (String, String)? premove;
  final _Square? selected;
  final _Square? check;
  final _Square? hover;

  /// Target squares; true when the move captures.
  final Map<String, bool> targets;
  final TextStyle textStyle;

  Rect _rect(_Square s, double size) {
    final col = orientation == ChessColor.white ? s.file : 7 - s.file;
    final row = orientation == ChessColor.white ? 7 - s.rank : s.rank;
    return Rect.fromLTWH(col * size, row * size, size, size);
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final size = canvasSize.width / 8;
    final light = Paint()..color = GwChessColors.lightSquare;
    final dark = Paint()..color = GwChessColors.darkSquare;
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        canvas.drawRect(_rect((file: file, rank: rank), size), (file + rank).isOdd ? light : dark);
      }
    }
    void fill(_Square? s, Color color) {
      if (s != null) canvas.drawRect(_rect(s, size), Paint()..color = color);
    }

    if (lastMove case (final from, final to)) {
      fill(_parse(from), GwChessColors.lastMove);
      fill(_parse(to), GwChessColors.lastMove);
    }
    if (premove case (final from, final to)) {
      fill(_parse(from), GwChessColors.premove);
      fill(_parse(to), GwChessColors.premove);
    }
    fill(selected, GwChessColors.selected);
    if (check case final king?) {
      final r = _rect(king, size);
      canvas.drawRect(
        r,
        Paint()
          ..shader = RadialGradient(colors: [GwChessColors.check, GwChessColors.check.withValues(alpha: 0)])
              .createShader(r),
      );
    }
    if (hover != null && targets.containsKey(_name(hover!))) fill(hover, GwChessColors.selected);

    final hint = Paint()..color = GwChessColors.hint;
    final ring = Paint()
      ..color = GwChessColors.hint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08;
    for (final MapEntry(key: square, value: capture) in targets.entries) {
      final r = _rect(_parse(square), size);
      if (capture) {
        canvas.drawCircle(r.center, size * 0.44, ring);
      } else {
        canvas.drawCircle(r.center, size * 0.16, hint);
      }
    }

    // Coordinates inside the edge squares, in the other square color.
    for (var i = 0; i < 8; i++) {
      final file = orientation == ChessColor.white ? i : 7 - i;
      final rank = orientation == ChessColor.white ? i : 7 - i;
      _label(canvas, String.fromCharCode(97 + file), _rect((file: file, rank: orientation == ChessColor.white ? 0 : 7), size),
          (file + (orientation == ChessColor.white ? 0 : 7)).isOdd, bottomRight: true);
      _label(canvas, '${rank + 1}', _rect((file: orientation == ChessColor.white ? 0 : 7, rank: rank), size),
          ((orientation == ChessColor.white ? 0 : 7) + rank).isOdd, bottomRight: false);
    }
  }

  void _label(Canvas canvas, String text, Rect square, bool onLight, {required bool bottomRight}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: onLight ? GwChessColors.darkSquare : GwChessColors.lightSquare,
          fontWeight: FontWeight.w700,
          fontSize: square.width * 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pad = square.width * 0.06;
    final offset = bottomRight
        ? Offset(square.right - painter.width - pad, square.bottom - painter.height - pad / 2)
        : Offset(square.left + pad, square.top + pad / 2);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.orientation != orientation ||
      old.lastMove != lastMove ||
      old.premove != premove ||
      old.selected != selected ||
      old.check != check ||
      old.hover != hover ||
      old.targets.length != targets.length ||
      !old.targets.keys.every(targets.containsKey);
}

class _PromotionPicker extends StatelessWidget {
  const _PromotionPicker({required this.pieces, required this.white});

  final PieceSet pieces;
  final bool white;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(gamesL10n.promoteTo),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final (kind, uci, label) in [
              ('Q', 'q', gamesL10n.queen),
              ('R', 'r', gamesL10n.rook),
              ('B', 'b', gamesL10n.bishop),
              ('N', 'n', gamesL10n.knight),
            ])
              Tooltip(
                message: label,
                child: InkWell(
                  borderRadius: GwRadius.mdAll,
                  onTap: () => Navigator.of(context).pop(uci),
                  child: SizedBox.square(
                    dimension: GwSpacing.xxl,
                    child: Semantics(
                      button: true,
                      label: label,
                      child: ScalableImageWidget(si: pieces['${white ? 'w' : 'b'}$kind']!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
