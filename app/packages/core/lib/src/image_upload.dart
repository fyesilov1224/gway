import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// An image picked by the user, ready to upload to a Storage bucket.
class ImageUpload {
  const ImageUpload({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  static const _types = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  String get extension => fileName.split('.').last.toLowerCase();

  /// Null for formats the storage buckets do not accept.
  String? get contentType => _types[extension];
}

/// Picks a gallery image scaled down to [maxWidth]. Null when the user cancels.
Future<ImageUpload?> pickGalleryImage({required double maxWidth}) async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: maxWidth, imageQuality: 85);
  if (file == null) return null;
  return ImageUpload(bytes: await file.readAsBytes(), fileName: file.name);
}
