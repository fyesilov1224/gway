import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps a call's audio running while the app is in the background (docs/ARCHITECTURE.md §8c, Arka planda görüşme).
/// Android needs a microphone foreground service for it; iOS (background audio) and the web need nothing.
/// Replaced in tests.
abstract interface class CallKeepAlive {
  Future<void> start();

  Future<void> stop();

  /// Sends the app to the background with the call still on; false where there is no such thing (web, iOS).
  Future<bool> toBackground();
}

class PlatformCallKeepAlive implements CallKeepAlive {
  const PlatformCallKeepAlive();

  static const _channel = MethodChannel('gway/call');

  bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> start() async {
    if (_android) await _channel.invokeMethod<void>('keepAlive');
  }

  @override
  Future<void> stop() async {
    if (_android) await _channel.invokeMethod<void>('release');
  }

  @override
  Future<bool> toBackground() async => _android && (await _channel.invokeMethod<bool>('toBackground') ?? false);
}
