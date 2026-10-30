import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

/// Serves one account state at a time; [change] plays the platform team acting.
class _FakeAccounts implements AccountRepository {
  _FakeAccounts(this.state);

  AccountState state;
  final _changes = StreamController<void>.broadcast();

  void change(AccountState next) {
    state = next;
    _changes.add(null);
  }

  @override
  Future<Result<AccountState>> get() async => Ok(state);

  @override
  Stream<void> changes(String userId) => _changes.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// What the gate shows: the locked screen while suspended, the app otherwise.
class _Gate extends ConsumerWidget {
  const _Gate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountStateProvider).value;
    return account != null && account.isSuspendedAt(DateTime.now()) ? const SuspendedScreen() : const Text('Uygulama');
  }
}

Future<_FakeAccounts> _pump(WidgetTester tester, AccountState state, {Widget child = const _Gate()}) async {
  final accounts = _FakeAccounts(state);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      accountRepositoryProvider.overrideWithValue(accounts),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: child),
  ));
  await tester.pumpAndSettle();
  return accounts;
}

void main() {
  testWidgets('a suspension reaches the open app at once, with its reason', (tester) async {
    final accounts = await _pump(tester, const AccountState(status: AccountStatus.active));
    expect(find.text('Uygulama'), findsOneWidget);

    accounts.change(AccountState(
      status: AccountStatus.suspended,
      suspendedUntil: DateTime.now().add(const Duration(days: 3)),
      suspensionReason: 'Spam paylaşımlar',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Hesabın askıya alındı'), findsOneWidget);
    expect(find.text('Askı gerekçesi: Spam paylaşımlar'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('a ban (no end date) says the account is closed for good', (tester) async {
    await _pump(tester, const AccountState(status: AccountStatus.suspended, suspensionReason: 'Taciz'));

    expect(find.text('Hesabın kalıcı olarak kapatıldı'), findsOneWidget);
    expect(find.text('Ban gerekçesi: Taciz'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsNothing);
    expect(find.text('Çıkış yap'), findsOneWidget);
  });
}
