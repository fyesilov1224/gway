import 'package:chess/chess.dart' as rules;

const startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

/// The position after the first [ply] moves (UCI) of a game, for looking back through it.
String fenAt(List<String> moves, int ply) {
  final position = rules.Chess();
  for (final m in moves.take(ply)) {
    position.move({'from': m.substring(0, 2), 'to': m.substring(2, 4), if (m.length == 5) 'promotion': m[4]});
  }
  return position.fen;
}

/// Piece values for the material count: pawn 1, knight and bishop 3, rook 5, queen 9.
const _values = {'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9};
const _start = {'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1};

/// What one side has taken, strongest first (`bQ`, `bP`, …), and its material lead over the other (0 when behind or level).
typedef Captures = ({List<String> taken, int lead});

/// The pieces each side has captured in [fen] and who is ahead in material.
({Captures white, Captures black}) captures(String fen) {
  final placement = fen.split(' ').first;
  final count = {'w': <String, int>{}, 'b': <String, int>{}};
  for (final c in placement.split('')) {
    final lower = c.toLowerCase();
    if (!_values.containsKey(lower)) continue;
    final side = c == lower ? 'b' : 'w';
    count[side]![lower] = (count[side]![lower] ?? 0) + 1;
  }
  int material(String side) => [for (final e in count[side]!.entries) _values[e.key]! * e.value].fold(0, (a, b) => a + b);
  List<String> missing(String side) => [
        for (final kind in ['q', 'r', 'b', 'n', 'p'])
          for (var i = 0; i < (_start[kind]! - (count[side]![kind] ?? 0)).clamp(0, 8); i++) '$side${kind.toUpperCase()}',
      ];
  final diff = material('w') - material('b');
  return (
    white: (taken: missing('b'), lead: diff > 0 ? diff : 0),
    black: (taken: missing('w'), lead: diff < 0 ? -diff : 0),
  );
}
