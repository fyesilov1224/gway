import 'package:flutter/painting.dart';

import 'colors.dart';

/// Soft identity tones from the brand palette. A group, person or category
/// keeps the same tone everywhere (avatar fallback, cover placeholder,
/// date tile, chips). See docs/DESIGN.md §1, Tonlar.
///
/// [strong] is for icons and large type (initials, day numbers); smaller
/// text on [soft] stays [GwColors.textPrimary].
enum GwTone {
  lilac(GwColors.primarySoft, GwColors.primary),
  sky(GwColors.secondarySoft, GwColors.secondary),
  mist(GwColors.surfaceMuted, GwColors.textPrimary);

  const GwTone(this.soft, this.strong);

  final Color soft;
  final Color strong;

  /// A stable lilac or sky tone for an id, handle or name (the same seed always
  /// gets the same tone); [mist] is only chosen on purpose.
  static GwTone of(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    // A middle bit: the lowest one only follows the parity of the letters' sum.
    return (hash >> 4).isEven ? lilac : sky;
  }
}
