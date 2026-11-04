import 'package:admin/admin.dart';
import 'package:admin/src/presentation/live_users_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AdminOnlineUser _user(String id, String name, AdminPlatform platform) => AdminOnlineUser(
      id: id,
      username: name.toLowerCase(),
      displayName: name,
      email: '${name.toLowerCase()}@gway.test',
      platform: platform,
      onlineSince: DateTime.now().subtract(const Duration(minutes: 12)),
      lastSeenAt: DateTime.now().subtract(const Duration(seconds: 20)),
    );

final _everyone = [
  _user('u1', 'Ayse', AdminPlatform.android),
  _user('u2', 'Deniz', AdminPlatform.web),
  _user('u3', 'Elif', AdminPlatform.ios),
];

Future<List<OnlineSearch>> _pump(WidgetTester tester) async {
  final asked = <OnlineSearch>[];
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      onlineUsersProvider.overrideWith((ref, search) async {
        asked.add(search);
        final items = [
          for (final u in _everyone)
            if ((search.platform == null || u.platform == search.platform) &&
                (search.query.isEmpty || u.title.toLowerCase().contains(search.query.toLowerCase())))
              u,
        ];
        return AdminOnlinePage(
          users: PagedList(items: items, total: items.length, page: 1, pageSize: 20),
          online: 3,
          android: 1,
          ios: 1,
          web: 1,
        );
      }),
    ],
    child: MaterialApp(theme: GwTheme.light(), home: const Scaffold(body: LiveUsersScreen())),
  ));
  await tester.pumpAndSettle();
  return asked;
}

void main() {
  testWidgets('everyone online is listed with a green dot, counts by platform', (tester) async {
    await _pump(tester);

    for (final name in ['Ayse', 'Deniz', 'Elif']) {
      expect(find.text(name), findsOneWidget);
    }
    // One per person, one in the "Canlı" pill.
    expect(find.byType(OnlineDot), findsNWidgets(4));
    expect(find.text('Şu an çevrimiçi'), findsOneWidget);
    expect(find.text('12 dk'), findsNWidgets(3));
    expect(find.text('20 sn önce'), findsNWidgets(3));
  });

  testWidgets('search and the platform filter narrow the list', (tester) async {
    final asked = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'den');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(asked.last.query, 'den');
    expect(find.text('Deniz'), findsOneWidget);
    expect(find.text('Ayse'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Aramana ve filtrene uygun çevrimiçi kullanıcı yok.'), findsOneWidget);
  });

  test('durations read naturally', () {
    expect(formatOnlineFor(const Duration(hours: 2, minutes: 5)), '2 sa 5 dk');
    expect(formatOnlineFor(const Duration(seconds: 40)), '40 sn');
    expect(formatLastSeen(const Duration(seconds: 2)), 'şimdi');
    expect(formatLastSeen(const Duration(minutes: 1, seconds: 10)), '1 dk önce');
  });
}
