import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../domain/notification.dart';

// The backend sends to FCM registration tokens over HTTP v1; the newer register()/onRegistered
// installation IDs are not a send target there yet, so the token API stays.
// ignore_for_file: deprecated_member_use

/// FCM; the app initializes Firebase first (docs/ARCHITECTURE.md §3c, Push).
class FirebasePushMessaging implements PushMessaging {
  FirebasePushMessaging(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  String get platform => defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  @override
  Future<String?> token() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return _messaging.getToken();
  }

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<Map<String, Object?>> get taps async* {
    if (await _messaging.getInitialMessage() case final opened?) yield opened.data;
    yield* FirebaseMessaging.onMessageOpenedApp.map((m) => m.data);
  }

  @override
  Stream<Map<String, Object?>> get arrivals => FirebaseMessaging.onMessage.map((m) => m.data);
}
