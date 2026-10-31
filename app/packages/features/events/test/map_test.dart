import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

const _group = EventGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');
const _other = EventGroup(id: 'g2', handle: 'kosu', name: 'Koşu Kulübü');

final _items = MapItems(
  groups: const [
    MappedGroup(group: _group, province: 34, point: LatLng(41.0082, 28.9784), memberCount: 12, categoryName: 'Yürüyüş'),
    MappedGroup(group: _other, province: 34, point: LatLng(41.0082, 28.9784), memberCount: 30, categoryName: 'Koşu'),
  ],
  events: [
    MappedEvent(
      id: 'e1',
      title: 'Belgrad Ormanı yürüyüşü',
      startsAt: DateTime(2026, 11, 1, 9),
      location: 'Bahçeköy girişi',
      point: const LatLng(39.93, 32.86),
      group: _group,
      goingCount: 8,
      capacity: 20,
    ),
  ],
);

final _queries = <MapQuery>[];

Future<List<String>> _pumpMap(WidgetTester tester, {MapItems? items}) async {
  tester.view.physicalSize = const Size(1170, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final opened = <String>[];
  await tester.pumpWidget(ProviderScope(
    overrides: [
      mapTilesProvider.overrideWithValue(null),
      categoriesProvider.overrideWith((ref) async => const [Category(slug: 'hiking', name: 'Yürüyüş')]),
      mapItemsProvider.overrideWith((ref, q) async {
        _queries.add(q);
        return items ?? _items;
      }),
    ],
    child: MaterialApp(
      theme: GwTheme.light(),
      home: DiscoverMapScreen(onOpenGroup: (_, handle) => opened.add(handle)),
    ),
  ));
  // The map reports its area once it settles.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  test('groups of one province share a marker; the area knows what it holds', () {
    expect(_items.groupsByProvince.keys, [34]);
    expect(_items.groupsByProvince[34], hasLength(2));
    expect(_items.groups.first.provinceName, 'İstanbul');
    const area = MapArea(south: 40.5, west: 28.0, north: 41.5, east: 30.0);
    expect(area.contains(const LatLng(41.0, 29.0)), isTrue);
    expect(area.contains(const LatLng(39.9, 32.8)), isFalse);
  });

  test('a time keeps events starting before it; a distance keeps what is near the center', () {
    final now = DateTime(2026, 11, 3, 15);
    expect(MapWhen.any.startsBefore(now), isNull);
    expect(MapWhen.today.startsBefore(now), DateTime(2026, 11, 4));
    expect(MapWhen.week.startsBefore(now), DateTime(2026, 11, 10, 15));

    const istanbul = LatLng(41.0082, 28.9784);
    final near = _items.within(istanbul, 5);
    expect(near.groups, hasLength(2));
    expect(near.events, isEmpty, reason: 'the event is in Ankara');

    final box = MapArea.around(istanbul, 10);
    expect(box.contains(const LatLng(41.05, 28.98)), isTrue);
    expect(box.contains(const LatLng(41.2, 28.98)), isFalse);
  });

  testWidgets('time and distance filters; an empty result offers to clear them', (tester) async {
    _queries.clear();
    await _pumpMap(tester);

    await tester.tap(find.text('Bugün'));
    await tester.pumpAndSettle();
    expect(_queries.last.when, MapWhen.today);

    await tester.ensureVisible(find.text('5 km'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 km'));
    await tester.pumpAndSettle();
    expect(find.text('Bu filtrelerle bir şey bulunamadı.'), findsOneWidget, reason: 'nothing within 5 km of the middle of Turkey');

    await tester.tap(find.text('Filtreleri temizle'));
    await tester.pumpAndSettle();
    expect(_queries.last.when, MapWhen.any);
    expect(find.text('Bu filtrelerle bir şey bulunamadı.'), findsNothing);
  });

  testWidgets('markers open a card: an event or the province\'s groups', (tester) async {
    final opened = await _pumpMap(tester);

    await tester.tap(find.byIcon(Icons.event));
    await tester.pumpAndSettle();
    expect(find.text('Organizasyonu aç'), findsOneWidget);
    expect(find.textContaining('8 / 20 katılımcı'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.text('İstanbul · 2 grup'), findsOneWidget);
    await tester.tap(find.text('Koşu Kulübü'));
    expect(opened, ['kosu']);
  });

  testWidgets('the list shows what the map shows', (tester) async {
    await _pumpMap(tester);
    await tester.tap(find.byTooltip('Liste görünümü'));
    await tester.pumpAndSettle();
    expect(find.text('Yaklaşan organizasyonlar (1)'), findsOneWidget);
    expect(find.text('Gruplar (2)'), findsOneWidget);
  });

  testWidgets('an empty area says so and offers to zoom out', (tester) async {
    await _pumpMap(tester, items: const MapItems());
    expect(find.text('Bu bölgede yaklaşan organizasyon ya da grup yok.'), findsOneWidget);
    expect(find.text('Uzaklaştır'), findsOneWidget);
  });

  testWidgets('the meeting point is picked by tapping the map', (tester) async {
    LatLng? picked;
    await tester.pumpWidget(ProviderScope(
      overrides: [mapTilesProvider.overrideWithValue(null)],
      child: MaterialApp(
        theme: GwTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: MeetingPointField(value: picked, onChanged: (p) => picked = p),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Buluşma noktası (isteğe bağlı)'));
    await tester.pumpAndSettle();

    final choose = find.widgetWithText(GwButton, 'Bu noktayı seç');
    expect(tester.widget<GwButton>(choose).onPressed, isNull);
    await tester.tap(find.byType(FlutterMap));
    // A single tap is told apart from a double tap after a short wait.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(choose);
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
    expect(picked!.latitude, closeTo(turkeyCenter.latitude, 2));
  });
}
