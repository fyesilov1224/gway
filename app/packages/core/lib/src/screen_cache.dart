import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session.dart';

/// How long a screen's data stays in memory after the screen is left (docs/ARCHITECTURE.md, Önbellek).
const screenCacheKeep = Duration(minutes: 5);

/// Data older than this is fetched again in the background when its screen comes back.
const screenCacheStaleAfter = Duration(seconds: 30);

extension ScreenCache on Ref {
  /// Call first in an `autoDispose` provider that loads a screen's data. Going back to the screen then shows the
  /// last value at once instead of a skeleton; if it is older than [staleAfter] it is fetched again while the old
  /// value stays on screen. The value is dropped [keep] after the last listener leaves, and on sign-in or sign-out
  /// so one account never sees another's data.
  void cacheFor({Duration keep = screenCacheKeep, Duration staleAfter = screenCacheStaleAfter}) {
    watch(currentUserIdProvider);
    final link = keepAlive();
    final builtAt = DateTime.now();
    Timer? release;
    onCancel(() {
      release?.cancel();
      release = Timer(keep, link.close);
    });
    onResume(() {
      release?.cancel();
      if (DateTime.now().difference(builtAt) <= staleAfter) return;
      // Not while a widget is subscribing (onResume runs during build).
      scheduleMicrotask(() {
        if (mounted) invalidateSelf();
      });
    });
    onDispose(() => release?.cancel());
  }
}
