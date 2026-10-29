import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
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
          borderRadius: GxRadius.xlAll,
          child: GxBackdrop(
            child: Padding(
              padding: const EdgeInsets.all(GxSpacing.lg),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerLeft, child: GxLogo(size: GxSpacing.xl, wordmark: true)),
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
                                color: GxColors.background,
                                borderRadius: GxRadius.xlAll,
                                border: Border.fromBorderSide(GxBorders.hairline),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(GxSpacing.lg),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('grupx · topluluğunu bul', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
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
      padding: const EdgeInsets.only(bottom: GxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: textTheme.headlineMedium?.copyWith(color: GxColors.primary)),
          const SizedBox(width: GxSpacing.xs),
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
      Text('${s.year} yılım', style: textTheme.headlineSmall),
      const SizedBox(height: GxSpacing.md),
      _Stat('${s.attended}', 'organizasyona katıldım'),
      if (s.hours > 0) _Stat('${s.hours}', 'saat birlikteydik'),
      if (s.groups > 0) _Stat('${s.groups}', s.groups == 1 ? 'grupla buluştum' : 'farklı grupla buluştum'),
      if (s.provinces > 1) _Stat('${s.provinces}', 'farklı ilde'),
      if (s.organized > 0) _Stat('${s.organized}', 'organizasyon düzenledim'),
      if (s.welcomed > 0) _Stat('${s.welcomed}', 'kişiyi ilk gelişinde karşıladım'),
      if (s.memories > 0) _Stat('${s.memories}', 'anı paylaştım'),
      if (s.categories.isNotEmpty) ...[
        const SizedBox(height: GxSpacing.xs),
        Text('En sevdiklerim', style: textTheme.titleSmall),
        Text(s.categories.map((c) => c.$1).join(' · '), style: textTheme.bodyLarge),
      ],
      if (s.topGroup case final group?) ...[
        const SizedBox(height: GxSpacing.sm),
        Text('En çok birlikte olduğum grup', style: textTheme.titleSmall),
        Text('$group · ${s.topGroupCount} buluşma', style: textTheme.bodyLarge),
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
      Text('Ben de oradaydım', style: textTheme.labelLarge?.copyWith(color: GxColors.primary)),
      const SizedBox(height: GxSpacing.xs),
      Text(e.title, style: textTheme.headlineSmall),
      const SizedBox(height: GxSpacing.sm),
      Text(e.group.name, style: textTheme.titleMedium),
      const SizedBox(height: GxSpacing.md),
      Row(children: [
        const Icon(Icons.event_outlined, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
        const SizedBox(width: GxSpacing.xs),
        Expanded(child: Text(formatDateTr(e.startsAt.toLocal()), style: textTheme.bodyLarge)),
      ]),
      const SizedBox(height: GxSpacing.xxs),
      Row(children: [
        const Icon(Icons.place_outlined, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
        const SizedBox(width: GxSpacing.xs),
        Expanded(child: Text(e.location, style: textTheme.bodyLarge)),
      ]),
      const SizedBox(height: GxSpacing.md),
      Text(
        countInGroup == 1 ? 'Bu grupla ilk organizasyonum.' : 'Bu grupla $countInGroup. organizasyonum.',
        style: textTheme.titleSmall?.copyWith(color: GxColors.primary),
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
        ..showSnackBar(const SnackBar(content: Text('Bu cihazda paylaşılamadı. Kartın ekran görüntüsünü alıp paylaşabilirsin.')));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GxLayout.storyCardWidth),
              child: RepaintBoundary(key: _boundary, child: widget.card),
            ),
          ),
          const SizedBox(height: GxSpacing.md),
          GxButton(label: 'Paylaş', icon: Icons.ios_share, isLoading: _busy, onPressed: _share),
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
          padding: const EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.md),
          child: _SharePreview(
            card: WasThereCard(event: event, countInGroup: countInGroup),
            kind: 'event',
            fileName: 'grupx-ben-de-oradaydim.png',
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
      appBar: AppBar(title: Text('$y özetim')),
      body: switch (ref.watch(yearSummaryProvider(y))) {
        AsyncData(:final value) when value == null || value.isEmpty => GxEmptyState(
            icon: Icons.auto_awesome_outlined,
            message: 'Bu yıl henüz bir organizasyona katılmadın. İlk buluşmandan sonra özetin burada oluşur.',
            actionLabel: 'Takvimime git',
            onAction: () => context.go(EventRoutes.calendar),
          ),
        AsyncData(value: final summary?) => ListView(
            padding: const EdgeInsets.all(GxSpacing.page),
            children: [
              _SharePreview(
                card: YearSummaryCard(summary: summary),
                kind: 'year',
                fileName: 'grupx-$y-ozetim.png',
                text: '$y yılım GrupX\'te',
              ),
              if (summary.firstEvent case final first?) ...[
                const SizedBox(height: GxSpacing.lg),
                Text(
                  'Yılın ilk organizasyonu: $first${summary.firstEventAt == null ? '' : ' · ${formatDateTr(summary.firstEventAt!.toLocal())}'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
              ],
            ],
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(yearSummaryProvider(y))),
        _ => const Padding(
            padding: EdgeInsets.all(GxSpacing.page),
            child: GxSkeleton(height: GxSpacing.xxl * 8, borderRadius: GxRadius.xlAll),
          ),
      },
    );
  }
}
