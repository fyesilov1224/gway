import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import 'call_providers.dart';

/// While the app is in front, a call ringing for you opens the full-screen call (docs/ARCHITECTURE.md §8c, Akış).
/// With the app closed or in the background the ringing push does it: on Android the phone's own call screen rings,
/// so the app's screen waits until the app comes to the front.
class IncomingCallAlerts extends ConsumerStatefulWidget {
  const IncomingCallAlerts({super.key, required this.openCall, required this.child});

  final void Function(String callId) openCall;
  final Widget child;

  /// A row older than this is a leftover the monitor has not closed yet (it closes ringing calls after 30 seconds).
  static const staleAfter = Duration(minutes: 1);

  @override
  ConsumerState<IncomingCallAlerts> createState() => _IncomingCallAlertsState();
}

class _IncomingCallAlertsState extends ConsumerState<IncomingCallAlerts> {
  final _opened = <String>{};
  late final AppLifecycleListener _lifecycle =
      AppLifecycleListener(onResume: () => _open(ref.read(incomingCallsProvider).value));

  bool get _inFront =>
      !ref.read(nativeCallsProvider).supported || WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  void _open(List<CallInfo>? calls) {
    if (!_inFront) return;
    for (final call in calls ?? const <CallInfo>[]) {
      if (DateTime.now().difference(call.createdAt) > IncomingCallAlerts.staleAfter) continue;
      if (_opened.add(call.id)) widget.openCall(call.id);
    }
  }

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(incomingCallsProvider, (_, next) => _open(next.value));
    return widget.child;
  }
}
