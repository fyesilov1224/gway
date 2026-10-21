import 'dart:io' show File;
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../domain/post.dart';

/// Picks photos and videos from the gallery and measures them on the device
/// (size, and video length, which the server cannot check). Photos are prepared
/// (cropped, resized) later with `renderPhoto`. Empty when cancelled.
Future<List<NewMedia>> pickMedia({required bool multiple}) async {
  final picker = ImagePicker();
  final files = multiple
      ? await picker.pickMultipleMedia(maxWidth: GxMedia.pickMaxSide, maxHeight: GxMedia.pickMaxSide, limit: NewPost.maxMedia)
      : [?await picker.pickMedia(maxWidth: GxMedia.pickMaxSide, maxHeight: GxMedia.pickMaxSide)];
  return [for (final f in files.take(NewPost.maxMedia)) await _measure(f)];
}

bool _isVideo(XFile file) {
  final type = file.mimeType;
  if (type != null) return type.startsWith('video/');
  return NewMedia.videoTypes.containsKey(file.name.split('.').last.toLowerCase());
}

Future<NewMedia> _measure(XFile file) async {
  final bytes = await file.readAsBytes();
  if (!_isVideo(file)) {
    final image = await _decode(bytes);
    final media = NewMedia(
      kind: MediaKind.image,
      bytes: bytes,
      fileName: file.name,
      width: image.width,
      height: image.height,
    );
    image.dispose();
    return media;
  }
  final controller = kIsWeb ? VideoPlayerController.networkUrl(Uri.parse(file.path)) : VideoPlayerController.file(File(file.path));
  try {
    await controller.initialize();
    final size = controller.value.size;
    return NewMedia(
      kind: MediaKind.video,
      bytes: bytes,
      fileName: file.name,
      width: size.width.round().clamp(1, 10000),
      height: size.height.round().clamp(1, 10000),
      duration: controller.value.duration,
      previewPath: file.path,
    );
  } finally {
    await controller.dispose();
  }
}

/// Decodes just enough to read the dimensions.
Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}
