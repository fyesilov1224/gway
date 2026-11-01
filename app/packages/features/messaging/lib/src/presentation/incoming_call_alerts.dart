import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import 'call_providers.dart';

/// While the app is open, a call ringing for you opens the full-screen call (docs/ARCHITECTURE.md §8c, Akış).
/// With the app closed the ringing push does it.
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

  @override
  Widget build(BuildContext context) {
    ref.listen(incomingCallsProvider, (_, next) {
      for (final call in next.value ?? const <CallInfo>[]) {
        if (DateTime.now().difference(call.createdAt) > IncomingCallAlerts.staleAfter) continue;
        if (_opened.add(call.id)) widget.openCall(call.id);
      }
    });
    return widget.child;
  }
}
