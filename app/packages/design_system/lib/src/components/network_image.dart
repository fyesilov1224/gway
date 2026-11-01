import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Tests have no disk cache (no plugins), so they load straight from the network as before.
final bool _diskCache = kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST');

/// A public image (avatar, cover, post media) that is kept on disk on phones, so it is not downloaded again on
/// every launch; on the web the browser cache does this. Decoded [cacheWidth] pixels wide when given
/// (`gwCacheWidth`). Signed URLs change on every request, so they use `Image.network` instead
/// (docs/ARCHITECTURE.md §4, Kurallar).
ImageProvider gwNetworkImage(String url, {int? cacheWidth}) => ResizeImage.resizeIfNeeded(
      cacheWidth,
      null,
      _diskCache ? CachedNetworkImageProvider(url) : NetworkImage(url),
    );
