import '../domain/chess.dart';
import '../domain/mind.dart';

/// The games list (docs/ARCHITECTURE.md §3i): every game has its card there.
abstract final class GamesRoutes {
  static const hub = '/games';
}

abstract final class ChessRoutes {
  static const home = '/games/chess';
  static const leaderboard = '/games/chess/leaderboard';

  /// The leaderboard on its groups tab.
  static const leaderboardGroups = '/games/chess/leaderboard?c=groups';
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

/// Zihin Düellosu (docs/ARCHITECTURE.md §3j).
abstract final class MindRoutes {
  static const home = '/games/mind';
  static const seekPath = '/games/mind/seek';
  static const leaderboardPath = '/games/mind/leaderboard';

  static String match(String id) => '/games/mind/m/$id';

  static String player(String userId) => '/games/mind/p/$userId';

  /// A group duel (a team match in Zihin Düellosu).
  static String team(String id) => '/games/mind/team/$id';

  /// Quick match for a length, e.g. `/games/mind/seek?n=10`.
  static String seek(int length) => '$seekPath?n=$length';

  static String leaderboard(int length) => '$leaderboardPath?n=$length';

  /// The leaderboard on its groups tab.
  static const leaderboardGroups = '/games/mind/leaderboard?c=groups';

  /// A length from a link; the default when missing or unknown.
  static int parseLength(String? n) {
    final parsed = int.tryParse(n ?? '');
    return mindLengths.contains(parsed) ? parsed! : mindDefaultLength;
  }
}
