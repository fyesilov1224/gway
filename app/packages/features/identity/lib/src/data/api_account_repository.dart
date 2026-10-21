import 'package:core/core.dart';

import '../domain/account.dart';

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api);

  final ApiClient _api;

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
}
