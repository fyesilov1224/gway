import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a fixed calendar.
class _FakeEvents implements EventsRepository {
  _FakeEvents(this.events);

  final List<GroupEvent> events;

  @override
  Future<Result<List<GroupEvent>>> calendar(DateTime from, DateTime to, {String? groupId, bool includeGroups = false}) async =>
      Ok(events);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _group = EventGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşü');

GroupEvent _event(String id, String title, DateTime startsAt, {AttendanceStatus? status, int going = 0, int? capacity}) =>
    GroupEvent(
      id: id,
      group: _group,
      title: title,
      startsAt: startsAt,
      location: 'Belgrad Ormanı',
      myStatus: status,
      goingCount: going,
      capacity: capacity,
    );

Future<void> _pump(WidgetTester tester, List<GroupEvent> events, {VoidCallback? onFindGroups, double textScale = 1}) async {
  // A fresh ProviderScope each time, so overridden data is never reused.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(ProviderScope(
    overrides: [eventsRepositoryProvider.overrideWithValue(_FakeEvents(events))],
    child: MaterialApp(
      theme: GwTheme.light(),
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: UpcomingScreen(onFindGroups: onFindGroups ?? () {}),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  final today = DateUtils.dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  testWidgets('events are grouped by day, with time, place and the user\'s status', (tester) async {
    await _pump(tester, [
      _event('e1', 'Sabah yürüyüşü', tomorrow.add(const Duration(hours: 9)), status: AttendanceStatus.going, going: 8, capacity: 12),
      _event('e2', 'Akşam koşusu', tomorrow.add(const Duration(hours: 19, minutes: 30)), going: 3),
      _event('e3', 'Kamp', today.add(const Duration(days: 5, hours: 10))),
    ], textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text('Tümü · 3'), findsOneWidget);
    expect(find.text('Katıldıklarım · 1'), findsOneWidget);
    expect(find.textContaining('Yarın'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('19:30'), findsOneWidget);
    expect(find.text('Katılıyorsun'), findsOneWidget);
    expect(find.text('8/12 katılımcı'), findsOneWidget);
    expect(find.text('Belgrad Ormanı'), findsNWidgets(3));
  });

  testWidgets('the filter keeps the joined ones and offers the rest back when empty', (tester) async {
    await _pump(tester, [
      _event('e1', 'Sabah yürüyüşü', tomorrow.add(const Duration(hours: 9)), status: AttendanceStatus.going),
      _event('e2', 'Akşam koşusu', tomorrow.add(const Duration(hours: 19))),
    ]);

    await tester.tap(find.text('Katıldıklarım · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Sabah yürüyüşü'), findsOneWidget);
    expect(find.text('Akşam koşusu'), findsNothing);

    await _pump(tester, [_event('e2', 'Akşam koşusu', tomorrow.add(const Duration(hours: 19)))]);
    await tester.tap(find.text('Katıldıklarım · 0'));
    await tester.pumpAndSettle();
    expect(find.text('Katıldığın yaklaşan bir organizasyon yok.'), findsOneWidget);
    await tester.tap(find.text('Tümünü göster'));
    await tester.pumpAndSettle();
    expect(find.text('Akşam koşusu'), findsOneWidget);
  });

  testWidgets('without plans the page points to groups', (tester) async {
    var found = false;
    await _pump(tester, const [], onFindGroups: () => found = true);

    expect(find.text('Önümüzdeki 60 günde gruplarının organizasyonu yok.'), findsOneWidget);
    await tester.tap(find.text('Grup bul'));
    expect(found, isTrue);
  });
}
