import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Registers this phone for push while someone is signed in, forgets it on sign-out,
/// and opens what a tapped notification is about (docs/ARCHITECTURE.md §3c, Push).
class PushNotifications extends ConsumerStatefulWidget {
  const PushNotifications({
    super.key,
    required this.openLive,
    required this.openCall,
    required this.openConversation,
    required this.openNotifications,
    required this.child,
  });

  final void Function(String liveId) openLive;

  /// The ringing push opens the incoming call screen (docs/ARCHITECTURE.md §8c).
  final void Function(String callId) openCall;

  /// A chat message notification opens its chat (docs/ARCHITECTURE.md §3c, Mesaj bildirimi).
  final void Function(String conversationId) openConversation;
  final void Function() openNotifications;
  final Widget child;

  @override
  ConsumerState<PushNotifications> createState() => _PushNotificationsState();
}

class _PushNotificationsState extends ConsumerState<PushNotifications> {
  final _subscriptions = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushMessagingProvider);
    if (push == null) return;
    _subscriptions
      ..add(push.tokenRefreshes.listen(_register))
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
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
