import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/events.dart';
import '../domain/map.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this._client);

  final SupabaseClient _client;

  EventGroup _group(Map<String, dynamic> g) => EventGroup(
        id: g['id'] as String,
        handle: g['handle'] as String,
        name: g['name'] as String,
        logoUrl: g['logo_path'] is String ? _client.storage.from('group-images').getPublicUrl(g['logo_path'] as String) : null,
      );

  static LatLng _point(Map<String, dynamic> r) => LatLng((r['lat'] as num).toDouble(), (r['lng'] as num).toDouble());

  static String? _category(Map<String, dynamic> r) => (r['category'] as Map?)?['name'] as String?;

  @override
  Future<Result<MapItems>> items(MapArea area, {String? category}) async {
    try {
      final r = await _client.rpc<Map<String, dynamic>>('map_items', params: {
        'south': area.south,
        'west': area.west,
        'north': area.north,
        'east': area.east,
        'category': category,
      });
      List<Map<String, dynamic>> rows(String key) => (r[key] as List).cast<Map<String, dynamic>>();
      return Ok(MapItems(
        groups: [
          for (final g in rows('groups'))
            MappedGroup(
              group: _group(g),
              province: (g['province'] as num).toInt(),
              point: _point(g),
              memberCount: (g['member_count'] as num).toInt(),
              categoryName: _category(g),
            ),
        ],
        events: [
          for (final e in rows('events'))
            MappedEvent(
              id: e['id'] as String,
              title: e['title'] as String,
              startsAt: DateTime.parse(e['starts_at'] as String),
              location: e['location'] as String,
              point: _point(e),
              group: _group((e['group'] as Map).cast<String, dynamic>()),
              goingCount: (e['going_count'] as num).toInt(),
              capacity: (e['capacity'] as num?)?.toInt(),
              categoryName: _category(e),
            ),
        ],
      ));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
