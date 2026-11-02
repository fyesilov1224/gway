import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/native_calls.dart';
import 'call_providers.dart';

/// Answers and declines on the phone's own incoming call screen (docs/ARCHITECTURE.md §8c, Gelen arama): an answer
/// opens the call screen, which answers at once; a decline goes to the server. An answer given before the app was
/// running is picked up once someone is signed in.
class NativeCallBridge extends ConsumerStatefulWidget {
  const NativeCallBridge({super.key, required this.openCall, required this.child});

  final void Function(String callId, {bool answer}) openCall;
  final Widget child;

  @override
  ConsumerState<NativeCallBridge> createState() => _NativeCallBridgeState();
}

class _NativeCallBridgeState extends ConsumerState<NativeCallBridge> {
  StreamSubscription<NativeCallAction>? _actions;
  bool _checkedStart = false;

  NativeCalls get _native => ref.read(nativeCallsProvider);

  @override
  void initState() {
    super.initState();
    _actions = _native.actions.listen((action) {
      switch (action.choice) {
        case NativeCallChoice.answer:
          widget.openCall(action.callId, answer: true);
        case NativeCallChoice.decline:
          // Already over or answered elsewhere: nothing to tell the person.
          unawaited(ref.read(callsRepositoryProvider).decline(action.callId));
      }
    });
    _checkStart(ref.read(currentUserIdProvider));
  }

  void _checkStart(String? me) {
    if (me == null || _checkedStart) return;
    _checkedStart = true;
    unawaited(_native.answeredBeforeStart().then((ids) {
      if (!mounted) return;
      for (final id in ids) {
        widget.openCall(id, answer: true);
      }
    }, onError: (Object _) {}));
  }

  @override
  void dispose() {
    unawaited(_actions?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserIdProvider, (_, me) => _checkStart(me));
    return widget.child;
  }
}
