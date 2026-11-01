import 'dart:io';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeEvents implements EventsRepository {
  _FakeEvents(this.result);

  final Exploration result;

  @override
  Future<Result<Exploration>> exploration() async => Ok(result);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Two small squares stand in for the 81 outlines.
final ProvinceShapes _shapes = {
  34: [
    [const LatLng(41, 28), const LatLng(41, 29.5), const LatLng(40.8, 29.5), const LatLng(40.8, 28), const LatLng(41, 28)],
  ],
  6: [
    [const LatLng(40, 32), const LatLng(40, 33.5), const LatLng(39.5, 33.5), const LatLng(39.5, 32), const LatLng(40, 32)],
  ],
};

Future<void> _pump(WidgetTester tester, Exploration exploration) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      eventsRepositoryProvider.overrideWithValue(_FakeEvents(exploration)),
      provinceShapesProvider.overrideWith((ref) async => _shapes),
    ],
    child: MaterialApp(theme: GwTheme.light(), home: const ExplorationScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('the asset holds all 81 province outlines', () {
    final shapes = parseProvinceShapes(File('assets/tr_provinces.json').readAsStringSync());
    expect(shapes.keys.toSet(), {for (var i = 1; i <= 81; i++) i});
    expect(shapes.values.every((polygons) => polygons.isNotEmpty && polygons.every((ring) => ring.length >= 4)), isTrue);
  });

  testWidgets('the map card counts provinces and events and lists the provinces', (tester) async {
    await _pump(
      tester,
      Exploration(
        provinceTotal: 81,
        eventCount: 3,
        provinces: [
          ExploredProvince(id: 34, name: 'İstanbul', events: 2, firstAt: DateTime(2026, 9, 1), lastAt: DateTime(2026, 10, 20)),
          ExploredProvince(id: 6, name: 'Ankara', events: 1, firstAt: DateTime(2026, 8, 5), lastAt: DateTime(2026, 8, 5)),
        ],
        points: [ExploredPoint(eventId: 'e1', title: 'Gezi', startsAt: DateTime(2026, 10, 20), point: const LatLng(40.9, 29))],
      ),
    );
    expect(find.text('2 / 81'), findsOneWidget);
    expect(find.text('ili keşfettim'), findsOneWidget);
    expect(find.text('İstanbul · Ankara'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('2 organizasyon · son'), 300);
    expect(find.textContaining('2 organizasyon · son'), findsOneWidget);
    expect(find.text('Paylaş'), findsOneWidget);
  });

  testWidgets('before any event the map is empty with a way to find one', (tester) async {
    await _pump(tester, const Exploration(provinceTotal: 81, eventCount: 0, provinces: [], points: []));
    expect(find.textContaining('İlk buluşmandan sonra haritan renklenir'), findsOneWidget);
    expect(find.text('Haritada organizasyon bul'), findsOneWidget);
    expect(find.text('Paylaş'), findsNothing);
  });
}
