import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:design_system/design_system.dart';

/// Frame choices when sharing (docs/DESIGN.md §7, Medya ölçüleri).
enum MediaAspect {
  original('Orijinal'),
  square('1:1'),
  portrait('4:5'),
  landscape('1.91:1');

  const MediaAspect(this.label);

  final String label;

  /// Width / height of the frame; the original is kept between 4:5 and 1.91:1.
  double ratioFor(Size source) => switch (this) {
        original => clampFeedRatio(source.width / source.height),
        square => GwMedia.square,
        portrait => GwMedia.portrait,
        landscape => GwMedia.landscape,
      };
}

double clampFeedRatio(double ratio) => ratio.clamp(GwMedia.portrait, GwMedia.landscape);

/// How a picture sits in its frame: [zoom] ≥ 1 over "cover", [center] in 0..1 of the picture.
class CropFrame {
  const CropFrame({this.zoom = 1, this.center = const Offset(0.5, 0.5)});

  final double zoom;
  final Offset center;

  /// The part of a [source] picture inside a frame of [ratio], in source pixels.
  Rect rectIn(Size source, double ratio) {
    final z = zoom.clamp(1.0, GwMedia.maxZoom);
    // Largest frame-shaped area that fits ("cover" at zoom 1), shrunk by zoom.
    final coverWidth = math.min(source.width, source.height * ratio);
    final width = coverWidth / z;
    final height = width / ratio;
    final cx = (center.dx * source.width).clamp(width / 2, source.width - width / 2);
    final cy = (center.dy * source.height).clamp(height / 2, source.height - height / 2);
    return Rect.fromCenter(center: Offset(cx, cy), width: width, height: height);
  }

  /// After dragging by [delta] on a frame [frameWidth] wide.
  CropFrame panned(Offset delta, Size source, double ratio, double frameWidth) {
    final rect = rectIn(source, ratio);
    final perPixel = rect.width / frameWidth;
    final moved = Offset(rect.center.dx - delta.dx * perPixel, rect.center.dy - delta.dy * perPixel);
    return _settled(source, ratio, zoom, Offset(moved.dx / source.width, moved.dy / source.height));
  }

  CropFrame zoomed(double factor, Size source, double ratio) =>
      _settled(source, ratio, (zoom * factor).clamp(1.0, GwMedia.maxZoom), center);

  /// Keeps the center where the frame still lies inside the picture.
  static CropFrame _settled(Size source, double ratio, double zoom, Offset center) {
    final rect = CropFrame(zoom: zoom, center: center).rectIn(source, ratio);
    return CropFrame(zoom: zoom, center: Offset(rect.center.dx / source.width, rect.center.dy / source.height));
  }
}

/// Output size for a crop: same ratio, longest side at most [maxSide], never upscaled.
Size outputSize(Size crop, int maxSide) {
  final scale = math.min(1.0, maxSide / math.max(crop.width, crop.height));
  return Size(math.max(1, (crop.width * scale).round()).toDouble(), math.max(1, (crop.height * scale).round()).toDouble());
}
