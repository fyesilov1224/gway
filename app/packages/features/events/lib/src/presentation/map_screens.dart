import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/map_repository_impl.dart';
import '../domain/map.dart';
import '../l10n.dart';
import 'routes.dart';

/// The middle of Turkey, and the box the map first fits (west of Edirne to east of Iğdır).
const turkeyCenter = LatLng(39.0, 35.2);
final turkeyBounds = LatLngBounds(const LatLng(35.8, 25.6), const LatLng(42.2, 44.9));

final mapRepositoryProvider = Provider<MapRepository>((ref) => MapRepositoryImpl(ref.watch(supabaseClientProvider)));

typedef MapQuery = ({MapArea area, String? category, MapWhen when});

final mapItemsProvider = FutureProvider.autoDispose.family<MapItems, MapQuery>(
  (ref, q) async => (await ref
          .watch(mapRepositoryProvider)
          .items(q.area, category: q.category, startsBefore: q.when.startsBefore(DateTime.now())))
      .getOrThrow(),
);

typedef MapTiles = ({String url, String? token});

/// Where tiles come from: the API's tile endpoint with the user's session (docs/ARCHITECTURE.md §3d,
/// Harita ile keşif). Null draws no tiles (tests).
final mapTilesProvider = Provider<MapTiles?>((ref) {
  ref.watch(authStateProvider);
  return (
    url: '${ref.watch(appConfigProvider).apiUrl}/map/tiles/{z}/{x}/{y}.png',
    token: ref.watch(supabaseClientProvider).auth.currentSession?.accessToken,
  );
});

/// The map with GWAY tiles and the required attribution; [children] go on top (markers).
class AppMap extends ConsumerStatefulWidget {
  /// The API answers 503 while no tile provider is set up (docs/ARCHITECTURE.md §3d, Harita ile keşif); the map then
  /// says so instead of staying an empty grey area. A single tile lost to the network does not count.
  static bool tilesUnavailable(Object error) => error is NetworkImageLoadException && error.statusCode == 503;

  const AppMap({
    super.key,
    this.controller,
    this.center,
    this.zoom = 14,
    this.interactive = true,
    this.onTap,
    this.onMoved,
    this.children = const [],
  });

  final MapController? controller;

  /// Without a center the map shows all of Turkey.
  final LatLng? center;
  final double zoom;
  final bool interactive;
  final void Function(LatLng point)? onTap;

  /// After the map settles, with the visible area.
  final void Function(MapArea area)? onMoved;
  final List<Widget> children;

  @override
  ConsumerState<AppMap> createState() => _AppMapState();
}

class _AppMapState extends ConsumerState<AppMap> {
  // The tile provider keeps this map; the token is refreshed in place.
  final _headers = <String, String>{};
  // Errors reach errorTileCallback, which only looks for an unavailable map; failed tiles stay blank as before.
  late final _tiles = NetworkTileProvider(headers: _headers);
  Timer? _settle;
  bool _unavailable = false;

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  void _moved(MapCamera camera) {
    final onMoved = widget.onMoved;
    if (onMoved == null) return;
    _settle?.cancel();
    _settle = Timer(const Duration(milliseconds: 350), () {
      final b = camera.visibleBounds;
      onMoved(MapArea(south: b.south, west: b.west, north: b.north, east: b.east));
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(mapTilesProvider);
    if (tiles?.token case final token?) _headers['Authorization'] = 'Bearer $token';

    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: widget.center ?? turkeyCenter,
        initialZoom: widget.zoom,
        initialCameraFit: widget.center == null ? CameraFit.bounds(bounds: turkeyBounds) : null,
        minZoom: 4,
        maxZoom: 18,
        backgroundColor: GwColors.surfaceMuted,
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
        onTap: widget.onTap == null ? null : (_, point) => widget.onTap!(point),
        onMapReady: () => widget.controller == null ? null : _moved(widget.controller!.camera),
        onPositionChanged: (camera, _) => _moved(camera),
      ),
      children: [
        if (tiles != null)
          TileLayer(
            urlTemplate: tiles.url,
            tileProvider: _tiles,
            userAgentPackageName: 'app.gway',
            errorTileCallback: (_, error, _) {
              if (!_unavailable && AppMap.tilesUnavailable(error) && mounted) setState(() => _unavailable = true);
            },
          ),
        ...widget.children,
        if (_unavailable) const _MapUnavailable(),
        // Required by the tile licence; wraps instead of overflowing on narrow screens.
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xxs, vertical: 2),
            color: GwColors.surface,
            child: Text(eventsL10n.mapAttribution,
                textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
      ],
    );
  }
}

class _EventPin extends StatelessWidget {
  const _EventPin({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: GwSpacing.xl,
          height: GwSpacing.xl,
          decoration: BoxDecoration(
            color: selected ? GwColors.secondary : GwColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: GwColors.background, width: 2),
          ),
          child: const Icon(Icons.event, size: GwSpacing.md, color: GwColors.onPrimary),
        ),
      );
}

class _GroupPin extends StatelessWidget {
  const _GroupPin({required this.groups, required this.selected});

  final List<MappedGroup> groups;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (groups.length == 1) {
      final g = groups.single.group;
      return Center(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected ? GwColors.secondary : GwColors.background,
            borderRadius: GwRadius.mdAll,
          ),
          child: GwAvatar(name: g.name, imageUrl: g.logoUrl, shape: GwAvatarShape.group, size: GwAvatarSize.sm),
        ),
      );
    }
    return Center(
      child: Container(
        width: GwSpacing.xxl - GwSpacing.xxs,
        height: GwSpacing.xxl - GwSpacing.xxs,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? GwColors.secondary : GwColors.secondarySoft,
          borderRadius: GwRadius.mdAll,
          border: Border.all(color: GwColors.background, width: 2),
        ),
        child: Text('${groups.length}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: selected ? GwColors.onPrimary : GwColors.secondary)),
      ),
    );
  }
}

/// eventsL10n.map: groups at their province and upcoming events at their meeting point.
class DiscoverMapScreen extends ConsumerStatefulWidget {
  const DiscoverMapScreen({super.key, required this.onOpenGroup});

  final void Function(BuildContext context, String handle) onOpenGroup;

  @override
  ConsumerState<DiscoverMapScreen> createState() => _DiscoverMapScreenState();
}

class _DiscoverMapScreenState extends ConsumerState<DiscoverMapScreen> {
  final _map = MapController();
  MapArea? _area;
  String? _category;
  MapWhen _when = MapWhen.any;

  /// Km around the map's center; null is the whole visible area.
  int? _radius;
  bool _list = false;

  bool get _filtered => _category != null || _when != MapWhen.any || _radius != null;

  void _clearFilters() => setState(() {
        _category = null;
        _when = MapWhen.any;
        _radius = null;
        _selected = null;
      });

  /// A [MappedEvent], or a province (plate number) whose groups are shown.
  Object? _selected;

  /// The selected event, or the selected province's groups, among the loaded items.
  Object? _selectedItem(MapItems? items) => switch (_selected) {
        final String id => items?.events.where((e) => e.id == id).firstOrNull,
        final int province => items?.groupsByProvince[province],
        _ => null,
      };

  void _zoomOut() {
    final camera = _map.camera;
    _map.move(camera.center, (camera.zoom - 2).clamp(4, 18));
  }

  @override
  Widget build(BuildContext context) {
    final area = _area;
    final center = area == null ? null : LatLng((area.south + area.north) / 2, (area.west + area.east) / 2);
    final radius = _radius;
    final query = area == null ? null : (radius == null || center == null ? area : MapArea.around(center, radius));
    final items = query == null ? null : ref.watch(mapItemsProvider((area: query, category: _category, when: _when)));
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final raw = items?.value;
    final loaded = raw == null || radius == null || center == null ? raw : raw.within(center, radius);

    Widget chip(String label, {required bool selected, required VoidCallback onSelected}) =>
        ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
    Widget row(List<Widget> chips) => SizedBox(
          height: GwSpacing.xxl + GwSpacing.xs,
          child: Center(child: GwChipRail(children: chips)),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(eventsL10n.map),
        actions: [
          IconButton(
            tooltip: _list ? eventsL10n.mapView : eventsL10n.listView,
            icon: Icon(_list ? Icons.map_outlined : Icons.view_list_outlined),
            onPressed: () => setState(() => _list = !_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight((GwSpacing.xxl + GwSpacing.xs) * 2),
          child: Column(
            children: [
              row([
                for (final (slug, name) in [(null, eventsL10n.all), for (final c in categories) (c.slug, c.name)])
                  chip(name, selected: _category == slug, onSelected: () => setState(() {
                        _category = slug;
                        _selected = null;
                      })),
              ]),
              row([
                for (final w in MapWhen.values)
                  chip(w.label, selected: _when == w, onSelected: () => setState(() {
                        _when = w;
                        _selected = null;
                      })),
                const SizedBox(width: GwSpacing.md),
                chip(eventsL10n.wholeArea, selected: _radius == null, onSelected: () => setState(() => _radius = null)),
                for (final km in mapRadii)
                  chip(eventsL10n.km(km), selected: _radius == km, onSelected: () => setState(() {
                        _radius = km;
                        _selected = null;
                      })),
              ]),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // The map stays laid out under the list, so the area is kept.
          Positioned.fill(
            child: AppMap(
              controller: _map,
              onMoved: (a) => setState(() => _area = a),
              onTap: (_) => setState(() => _selected = null),
              children: [
                if (radius != null && center != null)
                  CircleLayer(circles: [
                    CircleMarker(
                      point: center,
                      radius: radius * 1000,
                      useRadiusInMeter: true,
                      color: GwColors.primary.withValues(alpha: 0.06),
                      borderColor: GwColors.primary,
                      borderStrokeWidth: GwBorders.hairline.width,
                    ),
                  ]),
                if (loaded != null)
                  MarkerLayer(markers: [
                    for (final MapEntry(key: province, value: groups) in loaded.groupsByProvince.entries)
                      Marker(
                        point: groups.first.point,
                        width: GwSpacing.xxl,
                        height: GwSpacing.xxl,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = province),
                          child: Semantics(
                            button: true,
                            label: groups.length == 1
                                ? groups.single.group.name
                                : '${groups.first.provinceName}: ${groups.length} grup',
                            child: _GroupPin(groups: groups, selected: _selected == province),
                          ),
                        ),
                      ),
                    for (final e in loaded.events)
                      Marker(
                        point: e.point,
                        width: GwSpacing.xxl,
                        height: GwSpacing.xxl,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = e.id),
                          child: Semantics(button: true, label: e.title, child: _EventPin(selected: _selected == e.id)),
                        ),
                      ),
                  ]),
              ],
            ),
          ),
          if (_list)
            Positioned.fill(
              child: ColoredBox(
                color: GwColors.background,
                child: GwReadingColumn(
                  child: _MapList(
                    items: loaded,
                    failed: items?.hasError ?? false,
                    onRetry: () => ref.invalidate(mapItemsProvider),
                    onOpenGroup: widget.onOpenGroup,
                    onShowMap: () => setState(() => _list = false),
                  ),
                ),
              ),
            )
          else ...[
            if (items?.isLoading ?? true) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator()),
            if (items?.hasError ?? false)
              _MapNotice(
                icon: Icons.cloud_off_outlined,
                text: eventsL10n.mapLoadFailed,
                actionLabel: eventsL10n.retry,
                onAction: () => ref.invalidate(mapItemsProvider),
              )
            else if (loaded != null && loaded.isEmpty)
              _filtered
                  ? _MapNotice(
                      icon: Icons.filter_alt_off_outlined,
                      text: eventsL10n.noFilterResults,
                      actionLabel: eventsL10n.clearFilters,
                      onAction: _clearFilters,
                    )
                  : _MapNotice(
                      icon: Icons.travel_explore,
                      text: eventsL10n.noNearby,
                      actionLabel: eventsL10n.zoomOut,
                      onAction: _zoomOut,
                    ),
            if (_selectedItem(loaded) case final selected?)
              Positioned(
                left: GwSpacing.md,
                right: GwSpacing.md,
                bottom: GwSpacing.xl,
                child: _SelectedCard(selected: selected, onOpenGroup: widget.onOpenGroup),
              ),
          ],
        ],
      ),
    );
  }
}

/// A floating line over the map: what is (not) there and what to do.
class _MapNotice extends StatelessWidget {
  const _MapNotice({required this.icon, required this.text, required this.actionLabel, required this.onAction});

  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Positioned(
        top: GwSpacing.md,
        left: GwSpacing.md,
        right: GwSpacing.md,
        child: Container(
          padding: const EdgeInsets.only(left: GwSpacing.md),
          decoration: const BoxDecoration(
            color: GwColors.background,
            borderRadius: GwRadius.lgAll,
            border: Border.fromBorderSide(BorderSide(color: GwColors.border)),
          ),
          child: Row(
            children: [
              Icon(icon, color: GwColors.textSecondary),
              const SizedBox(width: GwSpacing.sm),
              Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
        ),
      );
}

String _seats(MappedEvent e) =>
    e.capacity == null ? eventsL10n.goingCount(e.goingCount) : eventsL10n.goingOfCapacity(e.goingCount, e.capacity!);

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({required this.selected, required this.onOpenGroup});

  final Object selected;
  final void Function(BuildContext context, String handle) onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final child = switch (selected) {
      final MappedEvent e => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.title, style: textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: GwSpacing.xxs),
            Text('${formatDateTime(e.startsAt.toLocal())} · ${e.surprise ? eventsL10n.surprisePlace(e.location) : e.location}',
                style: textTheme.bodyMedium, maxLines: 2),
            Text('${e.group.name} · ${_seats(e)}', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(height: GwSpacing.sm),
            GwButton(label: eventsL10n.openEvent, expand: true, onPressed: () => context.push(EventRoutes.event(e.id))),
          ],
        ),
      final List<MappedGroup> groups => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groups.length == 1 ? groups.first.provinceName : '${groups.first.provinceName} · ${groups.length} grup',
                style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: GwSpacing.xxl * 5),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [for (final g in groups) _GroupTile(group: g, onOpenGroup: onOpenGroup)],
              ),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
    return Container(
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: const BoxDecoration(
        color: GwColors.background,
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(BorderSide(color: GwColors.border)),
      ),
      child: child,
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onOpenGroup});

  final MappedGroup group;
  final void Function(BuildContext context, String handle) onOpenGroup;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: GwAvatar(name: group.group.name, imageUrl: group.group.logoUrl, shape: GwAvatarShape.group, size: GwAvatarSize.md),
        title: Text(group.group.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text([group.categoryName, eventsL10n.memberCount(group.memberCount), group.provinceName].nonNulls.join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpenGroup(context, group.group.handle),
      );
}

class _MapList extends StatelessWidget {
  const _MapList({
    required this.items,
    required this.failed,
    required this.onRetry,
    required this.onOpenGroup,
    required this.onShowMap,
  });

  final MapItems? items;
  final bool failed;
  final VoidCallback onRetry;
  final void Function(BuildContext context, String handle) onOpenGroup;
  final VoidCallback onShowMap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loaded = items;
    if (failed) return GwErrorState(message: eventsL10n.mapLoadFailed, onRetry: onRetry);
    if (loaded == null) {
      return const Padding(
        padding: EdgeInsets.all(GwSpacing.md),
        child: Column(children: [GwSkeleton(height: GwSpacing.xxl), SizedBox(height: GwSpacing.sm), GwSkeleton(height: GwSpacing.xxl)]),
      );
    }
    if (loaded.isEmpty) {
      return GwEmptyState(
        icon: Icons.travel_explore,
        message: eventsL10n.noVisible,
        actionLabel: eventsL10n.backToMap,
        onAction: onShowMap,
      );
    }
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.xs),
          child: Text(text, style: textTheme.titleSmall),
        );
    return ListView(
      children: [
        if (loaded.events.isNotEmpty) heading(eventsL10n.upcomingCount(loaded.events.length)),
        for (final e in loaded.events)
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: GwColors.primarySoft,
              child: Icon(Icons.event, color: GwColors.primary),
            ),
            title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${formatDateTime(e.startsAt.toLocal())} · ${e.surprise ? 'Sürpriz mekan · ' : ''}${e.location}\n${e.group.name} · ${_seats(e)}'),
            isThreeLine: true,
            onTap: () => context.push(EventRoutes.event(e.id)),
          ),
        if (loaded.groups.isNotEmpty) heading('Gruplar (${loaded.groups.length})'),
        for (final g in loaded.groups)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
            child: _GroupTile(group: g, onOpenGroup: onOpenGroup),
          ),
      ],
    );
  }
}

/// The meeting point on the event page, with directions in the device's map app.
class EventMeetingMap extends StatelessWidget {
  const EventMeetingMap({super.key, required this.point});

  final LatLng point;

  static Uri directionsUri(LatLng p) =>
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${p.latitude},${p.longitude}');

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: GwRadius.mdAll,
            child: SizedBox(
              height: GwSpacing.xxl * 4,
              child: AppMap(
                center: point,
                zoom: 14,
                interactive: false,
                children: [
                  MarkerLayer(markers: [
                    Marker(point: point, width: GwSpacing.xxl, height: GwSpacing.xxl, child: const _EventPin(selected: false)),
                  ]),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => launchUrl(directionsUri(point), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.directions_outlined),
            label: Text(eventsL10n.directions),
          ),
        ],
      );
}

/// eventsL10n.meetingPoint in the event form: picked on the map, optional.
class MeetingPointField extends StatelessWidget {
  const MeetingPointField({super.key, required this.value, required this.onChanged});

  final LatLng? value;
  final ValueChanged<LatLng?> onChanged;

  @override
  Widget build(BuildContext context) {
    final point = value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.pin_drop_outlined),
      title: Text(eventsL10n.meetingPointOptional),
      subtitle: Text(point == null
          ? eventsL10n.meetingPointHint
          : eventsL10n.pointPicked(point.latitude.toStringAsFixed(4), point.longitude.toStringAsFixed(4))),
      trailing: point == null
          ? const Icon(Icons.chevron_right)
          : IconButton(tooltip: eventsL10n.removeMeetingPoint, icon: const Icon(Icons.close), onPressed: () => onChanged(null)),
      onTap: () async {
        final picked = await Navigator.of(context).push<LatLng>(
          MaterialPageRoute(fullscreenDialog: true, builder: (_) => MeetingPointPicker(initial: point)),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Tap the map to drop the pin.
class MeetingPointPicker extends StatefulWidget {
  const MeetingPointPicker({super.key, this.initial});

  final LatLng? initial;

  @override
  State<MeetingPointPicker> createState() => _MeetingPointPickerState();
}

class _MeetingPointPickerState extends State<MeetingPointPicker> {
  late LatLng? _point = widget.initial;

  @override
  Widget build(BuildContext context) {
    final point = _point;
    return Scaffold(
      appBar: AppBar(title: Text(eventsL10n.meetingPoint)),
      body: AppMap(
        center: widget.initial,
        zoom: 15,
        onTap: (p) => setState(() => _point = p),
        children: [
          if (point != null)
            MarkerLayer(markers: [
              Marker(point: point, width: GwSpacing.xxl, height: GwSpacing.xxl, child: const _EventPin(selected: false)),
            ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                point == null ? eventsL10n.pickHint : eventsL10n.pickAgainHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: GwSpacing.sm),
              GwButton(
                label: eventsL10n.pickThisPoint,
                expand: true,
                onPressed: point == null ? null : () => Navigator.of(context).pop(point),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown over the map while the API has no tile provider.
class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(GwSpacing.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
          decoration: BoxDecoration(
            color: GwColors.background,
            borderRadius: GwRadius.mdAll,
            border: Border.all(color: GwColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, color: GwColors.textSecondary, size: GwSpacing.lg),
              const SizedBox(width: GwSpacing.xs),
              Flexible(
                child: Text(eventsL10n.mapUnavailable, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
