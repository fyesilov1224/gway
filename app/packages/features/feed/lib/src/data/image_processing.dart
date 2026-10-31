import 'dart:ui' show Rect, Size;

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../domain/media_crop.dart';
import '../domain/post.dart';

typedef _Job = ({Uint8List bytes, Rect crop, int maxSide, int? thumbSide});
typedef _Result = ({Uint8List bytes, int width, int height, Uint8List? thumb});

/// Crops and resizes a picked photo on the device: EXIF rotation applied, other EXIF
/// (location) dropped, JPEG at [GwMedia.jpegQuality]. With [thumbSide] also a small copy.
Future<NewMedia> renderPhoto(NewMedia source, Rect crop, {required int maxSide, int? thumbSide}) async {
  final r = await compute(_render, (bytes: source.bytes, crop: crop, maxSide: maxSide, thumbSide: thumbSide));
  return NewMedia(
    kind: MediaKind.image,
    bytes: r.bytes,
    fileName: 'photo.jpg',
    width: r.width,
    height: r.height,
    thumb: r.thumb,
  );
}

_Result _render(_Job job) {
  final decoded = img.decodeImage(job.bytes) ?? (throw const FormatException('unreadable image'));
  final upright = img.bakeOrientation(decoded);
  final c = job.crop;
  final cropped = img.copyCrop(
    upright,
    x: c.left.round().clamp(0, upright.width - 1),
    y: c.top.round().clamp(0, upright.height - 1),
    width: c.width.round().clamp(1, upright.width),
    height: c.height.round().clamp(1, upright.height),
  );
  img.Image resized(int maxSide) {
    final size = outputSize(Size(cropped.width.toDouble(), cropped.height.toDouble()), maxSide);
    final out = size.width >= cropped.width
        ? img.Image.from(cropped)
        : img.copyResize(cropped, width: size.width.round(), height: size.height.round(), interpolation: img.Interpolation.average);
    return out..exif = img.ExifData();
  }

  final main = resized(job.maxSide);
  return (
    bytes: img.encodeJpg(main, quality: GwMedia.jpegQuality),
    width: main.width,
    height: main.height,
    thumb: job.thumbSide == null ? null : img.encodeJpg(resized(job.thumbSide!), quality: GwMedia.jpegQuality),
  );
}
