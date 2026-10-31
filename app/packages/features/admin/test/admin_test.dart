import 'package:admin/admin.dart';
import 'package:admin/src/presentation/status_chip.dart';
import 'package:admin/src/presentation/suspend_dialog.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a user page from the API', () {
    final page = UserPage.fromJson({
      'items': [
        {
          'id': 'u1',
          'email': 'ayse@gway.app',
          'username': 'ayse.k',
          'displayName': 'Ayşe',
          'status': 'suspended',
          'suspendedUntil': '2026-10-25T00:00:00Z',
          'staffRole': null,
          'createdAt': '2026-10-01T00:00:00Z',
        },
      ],
      'total': 41,
      'page': 1,
      'pageSize': 20,
    }, AdminUserSummary.fromJson);

    expect(page.pageCount, 3);
    final u = page.items.single;
    expect(u.status, AdminAccountStatus.suspended);
    expect(u.suspendedUntil, DateTime.utc(2026, 10, 25));
    expect(u.staffRole, isNull);
  });

  test('users without a profile fall back to e-mail as title', () {
    final u = AdminUserSummary.fromJson({'id': 'u2', 'email': 'yeni@gway.app', 'status': 'active'});

    expect(u.title, 'yeni@gway.app');
  });

  test('only admins and moderators can suspend', () {
    expect(StaffRole.admin.canSuspend, isTrue);
    expect(StaffRole.moderator.canSuspend, isTrue);
    expect(StaffRole.support.canSuspend, isFalse);
  });

  testWidgets('suspend dialog requires a reason and returns the chosen duration', (tester) async {
    SuspendRequest? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: GwTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await showSuspendDialog(context),
              child: const Text('aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Askıya al'));
    await tester.pumpAndSettle();
    expect(find.text('Bir gerekçe yaz.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Spam paylaşımları  ');
    await tester.tap(find.text('Süresiz'));
    await tester.tap(find.widgetWithText(FilledButton, 'Askıya al'));
    await tester.pumpAndSettle();

    expect(result?.reason, 'Spam paylaşımları');
    expect(result?.until, isNull);
  });

  testWidgets('a user suspension always ends; a ban is its own action and shows as Banlı', (tester) async {
    SuspendRequest? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: GwTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(children: [
              TextButton(
                onPressed: () async => result = await showSuspendDialog(
                  context,
                  durations: const [SuspendDuration.day, SuspendDuration.week, SuspendDuration.month],
                ),
                child: const Text('aç'),
              ),
              const StatusBadge(AdminAccountStatus.suspended, banned: true),
            ]),
          ),
        ),
      ),
    );
    expect(find.text('Banlı'), findsOneWidget);

    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    expect(find.text('Süresiz'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'Spam');
    await tester.tap(find.widgetWithText(FilledButton, 'Askıya al'));
    await tester.pumpAndSettle();
    expect(result?.until, isNotNull);
  });
}
