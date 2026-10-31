import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';

import 'events.dart';

/// The visible part of the map.
class MapArea {
  const MapArea({required this.south, required this.west, required this.north, required this.east});

  final double south;
  final double west;
  final double north;
  final double east;

  /// The box around a circle of [km] around [center] (docs/ARCHITECTURE.md §3d, Zaman ve mesafe filtresi).
  factory MapArea.around(LatLng center, int km) {
    const distance = Distance();
    final north = distance.offset(center, km * 1000, 0).latitude;
    final south = distance.offset(center, km * 1000, 180).latitude;
    final east = distance.offset(center, km * 1000, 90).longitude;
    final west = distance.offset(center, km * 1000, 270).longitude;
    return MapArea(south: south, west: west, north: north, east: east);
  }

  bool contains(LatLng p) => p.latitude >= south && p.latitude <= north && p.longitude >= west && p.longitude <= east;

  @override
  bool operator ==(Object other) =>
      other is MapArea && other.south == south && other.west == west && other.north == north && other.east == east;

  @override
  int get hashCode => Object.hash(south, west, north, east);
}

/// When events start, for "what is on soon"; groups have no time, so a time hides them.
enum MapWhen {
  any('Her zaman'),
  today('Bugün'),
  week('7 gün içinde');

  const MapWhen(this.label);

  final String label;

  /// Events start before this; null is any time.
  DateTime? startsBefore(DateTime now) => switch (this) {
        any => null,
        today => DateTime(now.year, now.month, now.day + 1),
        week => now.add(const Duration(days: 7)),
      };
}

/// Distances offered around the map's center, in km.
const mapRadii = [5, 10, 25, 50];

/// A group shown at its province center.
class MappedGroup {
  const MappedGroup({
    required this.group,
    required this.province,
    required this.point,
    required this.memberCount,
    this.categoryName,
  });

  final EventGroup group;
  final int province;
  final LatLng point;
  final int memberCount;
  final String? categoryName;

  String get provinceName => turkishProvinces[province - 1];
}

/// An upcoming event at its meeting point.
class MappedEvent {
  const MappedEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.location,
    required this.point,
    required this.group,
    this.goingCount = 0,
    this.capacity,
    this.categoryName,
    this.surprise = false,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String location;

  /// A surprise: [location] is the hint and [point] the province center (docs/ARCHITECTURE.md §3d, Sürpriz organizasyon).
  final bool surprise;
  final LatLng point;
  final EventGroup group;
  final int goingCount;
  final int? capacity;
  final String? categoryName;
}

class MapItems {
  const MapItems({this.groups = const [], this.events = const []});

  final List<MappedGroup> groups;
  final List<MappedEvent> events;

  bool get isEmpty => groups.isEmpty && events.isEmpty;

  /// Only what lies within [km] of [center], measured on the device.
  MapItems within(LatLng center, int km) {
    const distance = Distance();
    bool near(LatLng p) => distance.as(LengthUnit.Meter, center, p) <= km * 1000;
    return MapItems(groups: [for (final g in groups) if (near(g.point)) g], events: [for (final e in events) if (near(e.point)) e]);
  }

  /// Groups of the same province share one marker.
  Map<int, List<MappedGroup>> get groupsByProvince {
    final byProvince = <int, List<MappedGroup>>{};
    for (final g in groups) {
      byProvince.putIfAbsent(g.province, () => []).add(g);
    }
    return byProvince;
  }
}

/// Reads through Supabase (`public.map_items`; docs/ARCHITECTURE.md §3d, Harita ile keşif).
abstract interface class MapRepository {
  Future<Result<MapItems>> items(MapArea area, {String? category, DateTime? startsBefore});
}
