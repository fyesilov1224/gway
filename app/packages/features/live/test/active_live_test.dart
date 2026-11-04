import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live/live.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Joining never finishes, so a session stays "connecting" and never touches LiveKit.
class _PendingLive implements LiveRepository {
  final joins = <String>[];

  @override
  Future<Result<LiveJoin>> join(String id) {
    joins.add(id);
    return Completer<Result<LiveJoin>>().future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _PendingLive repo;
  late ProviderContainer container;

  setUp(() {
    repo = _PendingLive();
    container = ProviderContainer(overrides: [
      liveRepositoryProvider.overrideWithValue(repo),
      supabaseClientProvider.overrideWithValue(SupabaseClient('http://localhost', 'anon')),
      currentUserIdProvider.overrideWithValue('me'),
    ]);
    addTearDown(container.dispose);
  });

  test('reopening the room keeps the same connection', () {
    final active = container.read(activeLiveProvider.notifier);
    final first = active.join('a');
    expect(active.join('a'), same(first));
    expect(container.read(activeLiveProvider), same(first));
    expect(repo.joins, ['a']);
  });

  test('another room replaces the current one, leaving clears it', () async {
    final active = container.read(activeLiveProvider.notifier);
    final first = active.join('a');
    final second = active.join('b');
    expect(second, isNot(same(first)));
    expect(container.read(activeLiveProvider)?.broadcastId, 'b');

    await active.leave();
    expect(container.read(activeLiveProvider), isNull);
  });

  test('a closed screen keeps a connecting session', () {
    final active = container.read(activeLiveProvider.notifier);
    final session = active.join('a');
    active.releaseIfInactive(session);
    expect(container.read(activeLiveProvider), same(session));
  });
}
