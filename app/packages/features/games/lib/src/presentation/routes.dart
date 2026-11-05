import '../domain/chess.dart';

abstract final class ChessRoutes {
  static const home = '/games/chess';
  static const leaderboard = '/games/chess/leaderboard';
  static const seekPath = '/games/chess/seek';

  static String game(String id) => '/games/chess/g/$id';

  static String player(String userId) => '/games/chess/p/$userId';

  static String team(String id) => '/games/chess/team/$id';

  static const arenas = '/games/chess/arenas';

  static String arena(String id) => '/games/chess/arena/$id';

  /// Quick game for a time control, e.g. `/games/chess/seek?tc=180+2`.
  static String seek(TimeControl tc) => '$seekPath?tc=${tc.baseSeconds}-${tc.incrementSeconds}';

  static TimeControl parseSeek(String? tc) {
    final parts = tc?.split('-');
    if (parts == null || parts.length != 2) return TimeControl.standard;
    final parsed = TimeControl(int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
    return TimeControl.catalog.contains(parsed) ? parsed : TimeControl.standard;
  }
}
