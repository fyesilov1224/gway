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

  bool contains(LatLng p) => p.latitude >= south && p.latitude <= north && p.longitude >= west && p.longitude <= east;

  @override
  bool operator ==(Object other) =>
      other is MapArea && other.south == south && other.west == west && other.north == north && other.east == east;

  @override
  int get hashCode => Object.hash(south, west, north, east);
}

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
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String location;
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
  Future<Result<MapItems>> items(MapArea area, {String? category});
}
