import 'package:flutter/painting.dart';

import 'colors.dart';

/// Hairline borders replace shadows. See docs/DESIGN.md §5.
abstract final class GwBorders {
  static const BorderSide hairline = BorderSide(color: GwColors.border);

  /// Story rings and the selected media in the composer.
  static const double ringWidth = 2;
}
