import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// A province on the person's exploration map (docs/ARCHITECTURE.md §3d, Keşif haritam).
class ExploredProvince {
  const ExploredProvince({required this.id, required this.name, required this.events, required this.firstAt, required this.lastAt});

  /// The plate number.
  final int id;
  final String name;
  final int events;
  final DateTime firstAt;
  final DateTime lastAt;
}

/// An attended event with a meeting point.
class ExploredPoint {
  const ExploredPoint({required this.eventId, required this.title, required this.startsAt, required this.point});

  final String eventId;
  final String title;
  final DateTime startsAt;
  final LatLng point;
}

/// The provinces of the events the person attended; only they see it.
class Exploration {
  const Exploration({required this.provinceTotal, required this.eventCount, required this.provinces, required this.points});

  final int provinceTotal;
  final int eventCount;

  /// Most recent first.
  final List<ExploredProvince> provinces;
  final List<ExploredPoint> points;

  bool get isEmpty => eventCount == 0;
  Set<int> get provinceIds => {for (final p in provinces) p.id};
}

/// Province outlines by plate number: polygons of [LatLng] (Natural Earth, public domain; the same data as the database).
typedef ProvinceShapes = Map<int, List<List<LatLng>>>;

/// Reads `assets/tr_provinces.json`: `{"34": [[[lng, lat], ...], ...]}`.
ProvinceShapes parseProvinceShapes(String json) => {
      for (final MapEntry(:key, :value) in (jsonDecode(json) as Map<String, dynamic>).entries)
        int.parse(key): [
          for (final polygon in value as List)
            [for (final p in ((polygon as List).first as List)) LatLng(((p as List)[1] as num).toDouble(), (p[0] as num).toDouble())],
        ],
    };
