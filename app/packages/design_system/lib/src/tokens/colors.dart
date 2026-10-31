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
