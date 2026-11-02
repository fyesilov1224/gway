import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// What the person did on the phone's own incoming call screen.
enum NativeCallChoice { answer, decline }

typedef NativeCallAction = ({String callId, NativeCallChoice choice});

/// The phone's own incoming call screen (Android; docs/ARCHITECTURE.md §8c): rings on the lock screen while the app is
/// closed or in the background. Elsewhere it does nothing. Replaced in tests.
abstract interface class NativeCalls {
  /// Whether this device has the screen (Android phones).
  bool get supported;

  Future<void> ring({required String callId, required String caller});

  /// Closes the ringing screen or the ongoing call notice; nothing if there is none.
  Future<void> end(String callId);

  /// Answers and declines while the app runs.
  Stream<NativeCallAction> get actions;

  /// Calls answered on the phone's screen before the app was running (opening the app follows the answer).
  Future<List<String>> answeredBeforeStart();

  /// Android 14+: whether calls may take over the lock screen.
  Future<bool> canRingOnLockScreen();

  /// Opens the system setting that allows it.
  Future<void> openLockScreenSetting();
}

class CallkitNativeCalls implements NativeCalls {
  const CallkitNativeCalls();

  /// How long the phone rings; the server marks the call missed after the same time (CallService.RingFor).
  static const ringFor = Duration(seconds: 30);

  static String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> ring({required String callId, required String caller}) async {
    if (!supported) return;
    await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      id: callId,
      nameCaller: caller,
      appName: 'GWAY',
      handle: 'GWAY sesli arama',
      type: 0,
      duration: ringFor.inMilliseconds,
      // The server's call_missed notice says it; the phone's own would be a second one.
      missedCallNotification: const NotificationParams(showNotification: false),
      callingNotification: const NotificationParams(showNotification: false),
      extra: {'call_id': callId},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: _hex(GwColors.primary),
        actionColor: _hex(GwColors.primary),
        textColor: _hex(GwColors.onPrimary),
        incomingCallNotificationChannelName: 'Gelen aramalar',
        missedCallNotificationChannelName: 'Cevapsız aramalar',
        isShowFullLockedScreen: true,
        isImportant: true,
        textAccept: 'Cevapla',
        textDecline: 'Reddet',
      ),
    ));
  }

  @override
  Future<void> end(String callId) async {
    if (!supported) return;
    await FlutterCallkitIncoming.endCall(callId);
  }

  @override
  Stream<NativeCallAction> get actions {
    if (!supported) return const Stream.empty();
    return FlutterCallkitIncoming.onEvent.expand((event) => switch (event) {
          CallEventActionCallAccept(:final callKitParams) => [(callId: callKitParams.id, choice: NativeCallChoice.answer)],
          CallEventActionCallDecline(:final callKitParams) => [(callId: callKitParams.id, choice: NativeCallChoice.decline)],
          _ => const <NativeCallAction>[],
        });
  }

  @override
  Future<List<String>> answeredBeforeStart() async {
    if (!supported) return const [];
    return [for (final c in await FlutterCallkitIncoming.activeCalls()) if (c.isAccepted) c.id];
  }

  @override
  Future<bool> canRingOnLockScreen() async => !supported || await FlutterCallkitIncoming.canUseFullScreenIntent();

  @override
  Future<void> openLockScreenSetting() async {
    if (supported) await FlutterCallkitIncoming.requestFullIntentPermission();
  }
}

/// A push the app handles itself, also from the background isolate: the ringing call opens the phone's call screen,
/// call_ended closes it (docs/ARCHITECTURE.md §8c, Akış).
@pragma('vm:entry-point')
Future<void> handleCallPush(Map<String, dynamic> data, {NativeCalls calls = const CallkitNativeCalls()}) async {
  switch (data) {
    case {'type': 'call_incoming', 'call_id': final String callId, 'title': final String caller}:
      await calls.ring(callId: callId, caller: caller);
    case {'type': 'call_ended', 'call_id': final String callId}:
      await calls.end(callId);
  }
}

/// Declines on the phone's screen while the app is not running reach the server from a background isolate.
Future<void> registerNativeDeclineInBackground() async {
  if (!const CallkitNativeCalls().supported) return;
  await FlutterCallkitIncoming.onBackgroundMessage(_onBackgroundCallEvent);
}

/// A fresh isolate: the session is read back from the device, as the app does at start.
@pragma('vm:entry-point')
Future<void> _onBackgroundCallEvent(CallEvent event) async {
  if (event is! CallEventActionCallDecline) return;
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);
  final auth = Supabase.instance.client.auth;
  final api = ApiClient(baseUrl: Uri.parse(config.apiUrl), accessToken: () async => (await auth.getSession())?.accessToken);
  // Already over or answered elsewhere: nothing to do; the server marks it missed otherwise.
  await api.post('/calls/${event.callKitParams.id}/decline', decode: (_) {});
}
