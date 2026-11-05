import 'package:flutter/painting.dart';

/// Color tokens. See docs/DESIGN.md §1.
abstract final class GwColors {
  static const primary = Color(0xFF6E56CF);
  static const primarySoft = Color(0xFFF3F0FF);

  static const secondary = Color(0xFF2F6FE0);
  static const secondarySoft = Color(0xFFEAF2FF);

  static const textPrimary = Color(0xFF1F2033);
  static const textSecondary = Color(0xFF5C5F77);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFAFAFD);
  static const surfaceMuted = Color(0xFFF4F4F8);
  static const border = Color(0xFFECECF2);

  static const onPrimary = Color(0xFFFFFFFF);

  /// The page backdrop only (`GwBackdrop`): white melts into these.
  static const backdropLilac = Color(0xFFEEE8FF);
  static const backdropPink = Color(0xFFFFE6F3);

  static const error = Color(0xFFC4314B);
  static const errorSoft = Color(0xFFFDECEF);

  /// Yellow and green are for statuses and support message kinds only
  /// (docs/DESIGN.md §1); text uses the dark tone on the soft background.
  static const warning = Color(0xFF8A5A00);
  static const warningSoft = Color(0xFFFFF4D6);

  static const success = Color(0xFF1D7A45);
  static const successSoft = Color(0xFFE6F6EC);

  /// The filled like heart only.
  static const like = Color(0xFFE0245E);

  /// Full-screen media (stories, video) only; the rest of the app is white.
  static const media = Color(0xFF111118);
  static const onMedia = Color(0xFFFFFFFF);

  /// Behind text laid over photos.
  static const mediaScrim = Color(0x73111118);

  /// Chart series, in this fixed order and never cycled (docs/DESIGN.md §1, Grafikler). Checked for color vision
  /// deficiency and contrast on white as adjacent pairs: purple and blue never sit side by side.
  static const chartSeries = [primary, Color(0xFFEB6834), secondary, Color(0xFF138A5F)];

  /// The previous range under the current one, and grid lines.
  static const chartCompare = Color(0xFFB4B6C8);
  static const chartGrid = border;

  /// Reserved for the live badge and the "start live" button only (`GwLiveBadge`, `GwLiveButton`).
  static const liveGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Chess board overlays (docs/DESIGN.md §1, Oyunlar), the same on every board theme: the last move in a soft yellow,
/// the selected piece in green, a king in check in red, move hints in translucent black.
abstract final class GwChessColors {
  static const lastMove = Color(0x80F6F669);
  static const selected = Color(0x8014551E);
  static const check = Color(0xCCE53935);

  /// Dots on empty target squares, rings on captures.
  static const hint = Color(0x33000000);

  /// A queued premove.
  static const premove = Color(0x803A6EA5);

  /// The thin frame around the board.
  static const frame = Color(0x26000000);
}

/// Board square colors the person can choose (docs/DESIGN.md §1, Oyunlar; user request 2026-11-05). Wood is the default:
/// the colors chess players know; the GWAY lilac stays as an option.
enum GwBoardTheme {
  wood(Color(0xFFF0D9B5), Color(0xFFB58863)),
  green(Color(0xFFEEEED2), Color(0xFF769656)),
  blue(Color(0xFFDEE3E6), Color(0xFF8CA2AD)),
  slate(Color(0xFFE6E6E6), Color(0xFF9B9B9B)),
  lilac(Color(0xFFF1EDFB), Color(0xFF9D8DDB));

  const GwBoardTheme(this.light, this.dark);

  final Color light;
  final Color dark;
}

/// Zihin Düellosu figure colors (docs/DESIGN.md §1, Oyunlar): six hues far enough apart to tell at a glance, each one
/// named in the attention questions. Dark enough to read as text ink on white; yellow is a deep mustard for that reason.
enum GwMindColor {
  red(Color(0xFFD7263D)),
  blue(Color(0xFF2F6FE0)),
  green(Color(0xFF1E8E4E)),
  yellow(Color(0xFFC79100)),
  purple(Color(0xFF7E3FC2)),
  orange(Color(0xFFE5600A));

  const GwMindColor(this.color);

  final Color color;

  static GwMindColor parse(Object? code) => values.firstWhere((c) => c.name == code, orElse: () => blue);
}

/// Leaderboard medals for the top three (docs/DESIGN.md §1, Madalyalar): [strong] for the medal, [soft] behind it.
enum GwMedal {
  gold(Color(0xFFC9971C), Color(0xFFFFF4D6), Color(0xFFFBE38A), Color(0xFF8F6508)),
  silver(Color(0xFF8C96A6), Color(0xFFF0F2F6), Color(0xFFF2F5F9), Color(0xFF5C6575)),
  bronze(Color(0xFFB06A35), Color(0xFFFBECE0), Color(0xFFEBB487), Color(0xFF6E3B17));

  const GwMedal(this.strong, this.soft, this.shine, this.deep);

  final Color strong;
  final Color soft;

  /// The light edge of the metal in the drawn medal and crown (`GwMedalBadge`, `GwCrown`).
  final Color shine;

  /// The shadowed edge and outline of the metal.
  final Color deep;

  /// The medal for a 1-based rank; null below third.
  static GwMedal? forRank(int rank) => rank >= 1 && rank <= 3 ? values[rank - 1] : null;
}
