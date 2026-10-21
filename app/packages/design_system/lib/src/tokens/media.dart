/// Media sizes and ratios. See docs/DESIGN.md §7, Medya ölçüleri.
abstract final class GxMedia {
  static const double square = 1;
  static const double portrait = 4 / 5;
  static const double landscape = 1.91;
  static const double story = 9 / 16;

  /// Profile, group and explore grids: portrait tiles, center-cropped.
  static const double gridTile = 4 / 5;
  static const int gridColumns = 3;

  /// The one spacing that is not a multiple of 4: grid tiles sit almost edge to edge.
  static const double gridGap = 2;

  static const int uploadMaxSide = 1440;
  static const int storyMaxSide = 1920;
  static const int thumbMaxSide = 480;
  static const int jpegQuality = 85;

  /// Picker limit, so on-device processing stays quick.
  static const double pickMaxSide = 2880;

  /// A story this close to 9:16 fills the screen; others are fitted over a blurred copy.
  static const double storyFitTolerance = 0.1;
  static const double backdropBlur = 24;
  static const double maxZoom = 5;
}

/// Pixels to decode an image shown [logicalWidth] wide (`cacheWidth`), so a grid
/// tile never decodes a full-size photo; null when the width is unbounded.
int? gxCacheWidth(double logicalWidth, double devicePixelRatio) =>
    logicalWidth.isFinite && logicalWidth > 0 ? (logicalWidth * devicePixelRatio).round() : null;
