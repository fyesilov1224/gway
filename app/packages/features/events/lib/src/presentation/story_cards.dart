import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../domain/events.dart';
import '../domain/exploration.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';

/// A 9:16 story card (docs/ARCHITECTURE.md §3d, Yılın özeti): the page backdrop with a white card on it.
/// Only the person's own numbers and public event and group details go in.
class _StoryFrame extends StatelessWidget {
  const _StoryFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: GwRadius.xlAll,
          child: GwBackdrop(
            child: Padding(
              padding: const EdgeInsets.all(GwSpacing.lg),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerLeft, child: GwLogo(size: GwSpacing.xl, wordmark: true)),
                  // A long year or a large text size shrinks the card instead of cutting it off.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, size) => Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: size.maxWidth,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: GwColors.background,
                                borderRadius: GwRadius.xlAll,
                                border: Border.fromBorderSide(GwBorders.hairline),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(GwSpacing.lg),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(eventsL10n.cardFooter, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: GwSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: textTheme.headlineMedium?.copyWith(color: GwColors.primary)),
          const SizedBox(width: GwSpacing.xs),
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// The year card's lines; empty numbers are left out.
class YearSummaryCard extends StatelessWidget {
  const YearSummaryCard({super.key, required this.summary});

  final YearSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final textTheme = Theme.of(context).textTheme;
    return _StoryFrame(children: [
      Text(eventsL10n.myYear(s.year), style: textTheme.headlineSmall),
      const SizedBox(height: GwSpacing.md),
      _Stat('${s.attended}', eventsL10n.statAttended),
      if (s.hours > 0) _Stat('${s.hours}', eventsL10n.statHours),
      if (s.groups > 0) _Stat('${s.groups}', s.groups == 1 ? eventsL10n.statOneGroup : eventsL10n.statGroups),
      if (s.provinces > 1) _Stat('${s.provinces}', eventsL10n.statProvinces),
      if (s.organized > 0) _Stat('${s.organized}', eventsL10n.statOrganized),
      if (s.welcomed > 0) _Stat('${s.welcomed}', eventsL10n.statWelcomed),
      if (s.memories > 0) _Stat('${s.memories}', eventsL10n.statMemories),
      if (s.categories.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.xs),
        Text(eventsL10n.favorites, style: textTheme.titleSmall),
        Text(s.categories.map((c) => c.$1).join(' · '), style: textTheme.bodyLarge),
      ],
      if (s.topGroup case final group?) ...[
        const SizedBox(height: GwSpacing.sm),
        Text(eventsL10n.topGroup, style: textTheme.titleSmall),
        Text(eventsL10n.topGroupLine(group, s.topGroupCount), style: textTheme.bodyLarge),
      ],
    ]);
  }
}

/// "Ben de oradaydım": the event, its group, when and where, and which time with this group it was.
class WasThereCard extends StatelessWidget {
  const WasThereCard({super.key, required this.event, required this.countInGroup});

  final GroupEvent event;
  final int countInGroup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = event;
    return _StoryFrame(children: [
      Text(eventsL10n.iWasThere, style: textTheme.labelLarge?.copyWith(color: GwColors.primary)),
      const SizedBox(height: GwSpacing.xs),
      Text(e.title, style: textTheme.headlineSmall),
      const SizedBox(height: GwSpacing.sm),
      Text(e.group.name, style: textTheme.titleMedium),
      const SizedBox(height: GwSpacing.md),
      Row(children: [
        const Icon(Icons.event_outlined, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
        const SizedBox(width: GwSpacing.xs),
        Expanded(child: Text(formatDate(e.startsAt.toLocal()), style: textTheme.bodyLarge)),
      ]),
      const SizedBox(height: GwSpacing.xxs),
      Row(children: [
        const Icon(Icons.place_outlined, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
        const SizedBox(width: GwSpacing.xs),
        Expanded(child: Text(e.location, style: textTheme.bodyLarge)),
      ]),
      const SizedBox(height: GwSpacing.md),
      Text(
        countInGroup == 1 ? eventsL10n.firstWithGroup : eventsL10n.nthWithGroup(countInGroup),
        style: textTheme.titleSmall?.copyWith(color: GwColors.primary),
      ),
    ]);
  }
}

/// A card preview with its share button: the card is turned into a picture on the device.
class _SharePreview extends ConsumerStatefulWidget {
  const _SharePreview({required this.card, required this.kind, required this.fileName, required this.text});

  final Widget card;
  final String kind;
  final String fileName;
  final String text;

  @override
  ConsumerState<_SharePreview> createState() => _SharePreviewState();
}

class _SharePreviewState extends ConsumerState<_SharePreview> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final shared = bytes != null && await shareImage(bytes.buffer.asUint8List(), name: widget.fileName, text: widget.text);
    if (shared) await ref.read(eventsRepositoryProvider).recordCardShare(widget.kind);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!shared) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(eventsL10n.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.storyCardWidth),
              child: RepaintBoundary(key: _boundary, child: widget.card),
            ),
          ),
          const SizedBox(height: GwSpacing.md),
          GwButton(label: eventsL10n.share, icon: Icons.ios_share, isLoading: _busy, onPressed: _share),
        ],
      );
}

/// Opens the "Ben de oradaydım" card for an event the viewer was at.
Future<void> showWasThereCard(BuildContext context, GroupEvent event, int countInGroup) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.md),
          child: _SharePreview(
            card: WasThereCard(event: event, countInGroup: countInGroup),
            kind: 'event',
            fileName: 'gway-ben-de-oradaydim.png',
            text: '${event.title} · ${event.group.name}',
          ),
        ),
      ),
    );

/// The year in review (`/year`): the person's own numbers as a story card.
class YearSummaryScreen extends ConsumerWidget {
  const YearSummaryScreen({super.key, this.year});

  /// Defaults to this year.
  final int? year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final y = year ?? DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(eventsL10n.yearSummaryTitle(y))),
      body: switch (ref.watch(yearSummaryProvider(y))) {
        AsyncData(:final value) when value == null || value.isEmpty => GwEmptyState(
            icon: Icons.auto_awesome_outlined,
            message: eventsL10n.yearEmpty,
            actionLabel: eventsL10n.goToCalendar,
            onAction: () => context.go(EventRoutes.calendar),
          ),
        AsyncData(value: final summary?) => ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              _SharePreview(
                card: YearSummaryCard(summary: summary),
                kind: 'year',
                fileName: 'gway-$y-ozetim.png',
                text: eventsL10n.yearShareText(y),
              ),
              if (summary.firstEvent case final first?) ...[
                const SizedBox(height: GwSpacing.lg),
                Text(
                  summary.firstEventAt == null
                      ? eventsL10n.firstEventOfYear(first)
                      : eventsL10n.firstEventOfYearOn(first, formatDate(summary.firstEventAt!.toLocal())),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                ),
              ],
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(yearSummaryProvider(y))),
        _ => const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: GwSkeleton(height: GwSpacing.xxl * 8, borderRadius: GwRadius.xlAll),
          ),
      },
    );
  }
}

/// Turkey with the explored provinces filled in and the meeting points marked; it does not move.
class ExplorationMap extends StatelessWidget {
  const ExplorationMap({super.key, required this.shapes, required this.explored, this.points = const []});

  static final _turkey = LatLngBounds(const LatLng(35.8, 25.6), const LatLng(42.2, 44.9));

  final ProvinceShapes shapes;
  final Set<int> explored;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 2.2,
        child: Semantics(
          label: eventsL10n.mapSemantics(explored.length),
          child: IgnorePointer(
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(bounds: _turkey, padding: const EdgeInsets.all(GwSpacing.xxs)),
                backgroundColor: GwColors.background,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                PolygonLayer(polygons: [
                  for (final MapEntry(key: id, value: polygons) in shapes.entries)
                    for (final ring in polygons)
                      Polygon(
                        points: ring,
                        color: explored.contains(id) ? GwColors.primary : GwColors.surfaceMuted,
                        borderColor: explored.contains(id) ? GwColors.primary : GwColors.border,
                        borderStrokeWidth: GwBorders.hairline.width,
                      ),
                ]),
                CircleLayer(circles: [
                  for (final p in points)
                    CircleMarker(
                      point: p,
                      radius: GwSpacing.xxs,
                      color: GwColors.secondary,
                      borderColor: GwColors.background,
                      borderStrokeWidth: GwBorders.hairline.width,
                    ),
                ]),
              ],
            ),
          ),
        ),
      );
}

/// The exploration card: the map, how many provinces and events, and the latest provinces.
class ExplorationCard extends StatelessWidget {
  const ExplorationCard({super.key, required this.exploration, required this.shapes});

  final Exploration exploration;
  final ProvinceShapes shapes;

  @override
  Widget build(BuildContext context) {
    final e = exploration;
    final textTheme = Theme.of(context).textTheme;
    return _StoryFrame(children: [
      Text(eventsL10n.explorationMap, style: textTheme.headlineSmall),
      const SizedBox(height: GwSpacing.md),
      ExplorationMap(shapes: shapes, explored: e.provinceIds, points: [for (final p in e.points) p.point]),
      const SizedBox(height: GwSpacing.md),
      _Stat('${e.provinces.length} / ${e.provinceTotal}', eventsL10n.statExplored),
      _Stat('${e.eventCount}', e.eventCount == 1 ? eventsL10n.statAttended : eventsL10n.statMetAt),
      if (e.provinces.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.xs),
        Text(eventsL10n.recentExplored, style: textTheme.titleSmall),
        Text(e.provinces.take(3).map((p) => p.name).join(' · '), style: textTheme.bodyLarge),
      ],
    ]);
  }
}

/// "Keşif haritam" (`/exploration`): the provinces of the events the person attended; only they see it, they may share it.
class ExplorationScreen extends ConsumerWidget {
  const ExplorationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final exploration = ref.watch(explorationProvider);
    final shapes = ref.watch(provinceShapesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(eventsL10n.explorationMap)),
      body: switch ((exploration, shapes)) {
        (AsyncData(value: final e), AsyncData(value: final s)) when e.isEmpty => ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              ExplorationMap(shapes: s, explored: const {}),
              const SizedBox(height: GwSpacing.lg),
              GwEmptyState(
                icon: Icons.travel_explore,
                message: eventsL10n.explorationEmpty,
                actionLabel: eventsL10n.findOnMap,
                onAction: () => context.go(EventRoutes.map),
              ),
            ],
          ),
        (AsyncData(value: final e), AsyncData(value: final s)) => ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              _SharePreview(
                card: ExplorationCard(exploration: e, shapes: s),
                kind: 'map',
                fileName: 'gway-kesif-haritam.png',
                text: eventsL10n.explorationShareText(e.provinces.length),
              ),
              const SizedBox(height: GwSpacing.lg),
              Text(eventsL10n.exploredProvinces, style: textTheme.titleMedium),
              Text(eventsL10n.explorationPrivacy, style: secondary),
              const SizedBox(height: GwSpacing.xs),
              GwPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (i, p) in e.provinces.indexed) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        leading: const Icon(Icons.place_outlined, color: GwColors.primary),
                        title: Text(p.name),
                        subtitle: Text(
                          p.events == 1
                              ? formatDate(p.lastAt.toLocal())
                              : '${p.events} organizasyon · son ${formatDate(p.lastAt.toLocal())}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref
              ..invalidate(explorationProvider)
              ..invalidate(provinceShapesProvider),
          ),
        _ => const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: GwSkeleton(height: GwSpacing.xxl * 8, borderRadius: GwRadius.xlAll),
          ),
      },
    );
  }
}
