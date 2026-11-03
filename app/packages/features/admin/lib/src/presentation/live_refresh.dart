import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How often a watched list or counter is fetched again (docs/ARCHITECTURE.md §8b, Canlı yenileme).
const adminRefreshInterval = Duration(seconds: 15);

extension AdminLiveRefresh on Ref {
  /// [cacheFor], and while a screen shows the value it is fetched again every [every], so new sign-ups, reports
  /// and tickets appear without pressing "Yenile". The old value stays on screen during the fetch; nothing is
  /// fetched while no screen listens.
  void liveFor({Duration every = adminRefreshInterval}) {
    cacheFor();
    Timer? timer;
    void schedule() {
      timer?.cancel();
      timer = Timer(every, () {
        if (mounted) invalidateSelf();
      });
    }

    schedule();
    onCancel(() => timer?.cancel());
    onResume(schedule);
    onDispose(() => timer?.cancel());
  }
}
