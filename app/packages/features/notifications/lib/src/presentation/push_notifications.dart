import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Registers this phone for push while someone is signed in, forgets it on sign-out, opens what a tapped
/// notification is about, and rings a push that arrives while the app is open (docs/ARCHITECTURE.md §3c, Push).
class PushNotifications extends ConsumerStatefulWidget {
  const PushNotifications({
    super.key,
    required this.openLive,
    required this.openCall,
    required this.openConversation,
    required this.openNotifications,
    required this.isConversationOpen,
    required this.child,
  });

  final void Function(String liveId) openLive;

  /// The ringing push opens the incoming call screen (docs/ARCHITECTURE.md §8c).
  final void Function(String callId) openCall;

  /// A chat message notification opens its chat (docs/ARCHITECTURE.md §3c, Mesaj bildirimi).
  final void Function(String conversationId) openConversation;
  final void Function() openNotifications;

  /// Whether the person is looking at this chat now; its messages then arrive without a sound.
  final bool Function(String conversationId) isConversationOpen;

  final Widget child;

  /// At most one sound this often, however many pushes arrive together.
  static const soundGap = Duration(seconds: 2);

  /// Whether a push arriving while the app is open rings the notification sound (docs/ARCHITECTURE.md §3c,
  /// Uygulama açıkken bildirim sesi). Calls ring on their own screen, live notices play their own alert.
  static bool rings(Map<String, Object?> data, {required bool Function(String conversationId) isConversationOpen}) =>
      switch (data) {
        {'type': 'call_incoming' || 'call_ended' || 'live_scheduled' || 'live_started'} => false,
        {'type': 'message', 'conversation_id': final String id} => !isConversationOpen(id),
        _ => true,
      };

  @override
  ConsumerState<PushNotifications> createState() => _PushNotificationsState();
}

class _PushNotificationsState extends ConsumerState<PushNotifications> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _quiet;

  void _onArrival(Map<String, Object?> data) {
    if (!PushNotifications.rings(data, isConversationOpen: widget.isConversationOpen)) return;
    if (_quiet?.isActive ?? false) return;
    _quiet = Timer(PushNotifications.soundGap, () {});
    // A sound that cannot play changes nothing else.
    unawaited(ref.read(notificationSoundProvider)().catchError((Object _) {}));
  }

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushMessagingProvider);
    if (push == null) return;
    _subscriptions
      ..add(push.tokenRefreshes.listen(_register))
      ..add(push.arrivals.listen(_onArrival))
      ..add(push.taps.listen((data) {
        if (data case {'type': 'call_incoming', 'call_id': final String callId}) {
          widget.openCall(callId);
        } else if (data['live_id'] case final String liveId) {
          widget.openLive(liveId);
        } else if (data['conversation_id'] case final String conversationId) {
          widget.openConversation(conversationId);
        } else {
          widget.openNotifications();
        }
      }));
    // Registers once the session may write: a session still in security verification has role `unverified`
    // and becomes `authenticated` after it (docs/ARCHITECTURE.md §3h).
    ref.listenManual(sessionRoleProvider, fireImmediately: true, (before, now) async {
      try {
        if (now == 'authenticated' && before != 'authenticated') {
          if (await push.token() case final token?) await _register(token);
        } else if (now == null && before != null) {
          await push.deleteToken();
        }
      } on Object {
        // Without Google Play services or a network the phone simply gets no push; the next start tries again.
      }
    });
  }

  /// A failed registration only means no push on this phone; the next start tries again.
  Future<void> _register(String token) async {
    final push = ref.read(pushMessagingProvider);
    if (push == null || ref.read(sessionRoleProvider) != 'authenticated') return;
    await ref.read(notificationsRepositoryProvider).registerPushDevice(token, push.platform);
  }

  @override
  void dispose() {
    _quiet?.cancel();
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
