import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';

/// Keeps a live room's sound going while the app is in the background, the screen is locked or another app is open
/// (docs/ARCHITECTURE.md §8, Arka planda yayın). Android cuts a background app's microphone unless a microphone
/// foreground service runs; the app's service is shared with voice calls. iOS and the web need nothing.
/// Replaced in tests.
abstract interface class LiveKeepAlive {
  Future<void> start();

  Future<void> stop();
}

class PlatformLiveKeepAlive implements LiveKeepAlive {
  const PlatformLiveKeepAlive();

  static const _channel = MethodChannel('gway/call');
  static const _owner = 'live';

  bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> start() async {
    if (!_android) return;
    await _channel.invokeMethod<void>('keepAlive', {
      'owner': _owner,
      'title': liveL10n.liveOngoingTitle,
      'text': liveL10n.liveOngoingText,
    });
  }

  @override
  Future<void> stop() async {
    if (_android) await _channel.invokeMethod<void>('release', {'owner': _owner});
  }
}
