import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/presence.dart';
import 'providers.dart';

/// Tells the admin panel's live users list that this person has the app open (docs/ARCHITECTURE.md §8b, Canlı
/// kullanıcılar): a beat on start, when the app comes to the front and every [beat] while it stays there; leaving
/// the front (another app, a locked screen, a hidden tab) takes them off the list at once. Only verified sessions
/// beat; a failed beat changes nothing for the person.
class PresenceBeacon extends ConsumerStatefulWidget {
  const PresenceBeacon({super.key, required this.child});

  final Widget child;

  static const beat = Duration(seconds: 45);

  @override
  ConsumerState<PresenceBeacon> createState() => _PresenceBeaconState();
}

class _PresenceBeaconState extends ConsumerState<PresenceBeacon> with WidgetsBindingObserver {
  Timer? _timer;
  bool _online = false;

  static PresencePlatform get _platform => switch (defaultTargetPlatform) {
        _ when kIsWeb => PresencePlatform.web,
        TargetPlatform.android => PresencePlatform.android,
        TargetPlatform.iOS => PresencePlatform.ios,
        _ => PresencePlatform.web,
      };

  PresenceRepository get _repo => ref.read(presenceRepositoryProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(sessionRoleProvider, (_, _) => _sync(), fireImmediately: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _sync();

  void _sync() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final inFront = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    final wanted = inFront && ref.read(sessionRoleProvider) == 'authenticated';
    if (wanted == _online) return;
    _online = wanted;
    _timer?.cancel();
    if (wanted) {
      unawaited(_repo.touch(_platform));
      _timer = Timer.periodic(PresenceBeacon.beat, (_) => unawaited(_repo.touch(_platform)));
    } else if (ref.read(currentUserIdProvider) != null) {
      unawaited(_repo.leave());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
