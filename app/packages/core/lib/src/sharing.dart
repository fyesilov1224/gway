import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'session.dart';

/// Share links: small preview pages the API serves, which send people on to the app (docs/ARCHITECTURE.md §3b).
class ShareLinks {
  const ShareLinks(this.baseUrl);

  final String baseUrl;

  String _link(String path) => '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/s/$path';

  String group(String handle) => _link('g/$handle');

  String event(String id) => _link('e/$id');

  String invite(String code) => _link('i/$code');
}

final shareLinksProvider = Provider<ShareLinks>((ref) => ShareLinks(ref.watch(appConfigProvider).shareUrl));

/// Opens the share sheet (WhatsApp and the rest). Where there is none, copies the link and returns false
/// so the caller can say so.
Future<bool> shareLink(String url, {String? text}) async {
  try {
    final result = await SharePlus.instance.share(ShareParams(text: text == null ? url : '$text\n$url'));
    if (result.status != ShareResultStatus.unavailable) return true;
  } on Object {
    // No share sheet here; fall back to the clipboard.
  }
  await Clipboard.setData(ClipboardData(text: url));
  return false;
}

/// Shares a picture (a story card) through the share sheet; false where the device cannot.
Future<bool> shareImage(Uint8List png, {required String name, String? text}) async {
  try {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile.fromData(png, mimeType: 'image/png', name: name)], fileNameOverrides: [name], text: text),
    );
    return result.status != ShareResultStatus.unavailable;
  } on Object {
    return false;
  }
}
