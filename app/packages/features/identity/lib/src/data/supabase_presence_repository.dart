import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/presence.dart';

class SupabasePresenceRepository implements PresenceRepository {
  SupabasePresenceRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<void>> touch(PresencePlatform platform) =>
      _run(() => _client.rpc<void>('touch_presence', params: {'device_platform': platform.name}));

  @override
  Future<Result<void>> leave() => _run(() => _client.rpc<void>('leave_presence'));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Ok(null);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
