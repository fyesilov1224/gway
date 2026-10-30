import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/account.dart';

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api, this._client);

  final ApiClient _api;

  /// Realtime only: the account state itself is read through the API.
  final SupabaseClient _client;

  static AccountState _decode(Object? json) =>
      AccountState.fromJson((json! as Map).cast<String, Object?>());

  @override
  Future<Result<AccountState>> get() => _api.get('/account', decode: _decode);

  @override
  Future<Result<AccountState>> requestDeletion() =>
      _api.post('/account/deletion', decode: _decode);

  @override
  Future<Result<AccountState>> cancelDeletion() =>
      _api.delete('/account/deletion', decode: _decode);

  @override
  Stream<void> changes(String userId) {
    late final RealtimeChannel channel;
    final controller = StreamController<void>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('account:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'account_status',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (_) => controller.add(null),
        )
        .subscribe();
    return controller.stream;
  }
}
