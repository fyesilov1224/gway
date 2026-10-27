import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
import 'match_card_view.dart';
import 'match_sheets.dart';
import 'matching_screen.dart';
import 'providers.dart';
import 'routes.dart';

IconData packageIcon(MatchPackage p) => switch (p) {
      MatchPackage.reveal => Icons.visibility_outlined,
      MatchPackage.chat => Icons.chat_bubble_outline_rounded,
      MatchPackage.admirers => Icons.favorite_rounded,
      MatchPackage.unlimited => Icons.all_inclusive_rounded,
      MatchPackage.superLike => Icons.star_rounded,
      MatchPackage.boost => Icons.bolt_rounded,
      MatchPackage.teammates => Icons.groups_2_outlined,
      MatchPackage.all => Icons.workspace_premium_rounded,
    };

/// Offers the package that opens [feature] (and Hepsi Bir Arada); [reason] says what the user just tried.
Future<void> showPackageSheet(BuildContext context, {required MatchFeature feature, required String reason}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        final textTheme = Theme.of(sheet).textTheme;
        void open(MatchPackage p) {
          Navigator.of(sheet).pop();
          context.push(MatchingRoutes.package(p));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(GxSpacing.lg, 0, GxSpacing.lg, GxSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(packageIcon(feature.package), size: GxSpacing.xxl, color: GxColors.primary),
                const SizedBox(height: GxSpacing.sm),
                Text(feature.package.title, textAlign: TextAlign.center, style: textTheme.headlineSmall),
                const SizedBox(height: GxSpacing.xs),
                Text(reason, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                const SizedBox(height: GxSpacing.lg),
                GxButton(label: '${feature.package.title} paketini incele', expand: true, onPressed: () => open(feature.package)),
                const SizedBox(height: GxSpacing.xs),
                GxButton(
                  label: 'Hepsi Bir Arada',
                  icon: Icons.workspace_premium_outlined,
                  variant: GxButtonVariant.secondary,
                  expand: true,
                  onPressed: () => open(MatchPackage.all),
                ),
                const SizedBox(height: GxSpacing.xs),
                GxButton(
                  label: 'Tüm paketler',
                  variant: GxButtonVariant.text,
                  expand: true,
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    context.push(MatchingRoutes.packages);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

/// Every package with what it opens and whether the user has it.
class MatchPackagesScreen extends ConsumerWidget {
  const MatchPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(matchStatusProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Eşleşme paketleri')),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(matchStatusProvider),
          child: ListView(
            padding: const EdgeInsets.all(GxSpacing.page),
            children: [
              Text(
                'Profil açmak ve kaydırmak ücretsiz. Her özellik ayrı bir pakettir; yalnızca istediğini al.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
              ),
              if (status?.fullAccess ?? false) ...[
                const SizedBox(height: GxSpacing.sm),
                const GxBadge('Yönetici olarak tüm paketler açık', tone: GxBadgeTone.success),
              ],
              const SizedBox(height: GxSpacing.md),
              for (final p in [MatchPackage.all, ...MatchPackage.values.where((p) => p != MatchPackage.all)]) ...[
                _PackageTile(package: p, until: status?.packages[p]),
                const SizedBox(height: GxSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, this.until});

  final MatchPackage package;
  final DateTime? until;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highlight = package == MatchPackage.all;
    return GxCard(
      onTap: () => context.push(MatchingRoutes.package(package)),
      padding: const EdgeInsets.all(GxSpacing.md),
      child: Row(
        children: [
          Container(
            width: GxSpacing.xxl,
            height: GxSpacing.xxl,
            decoration: BoxDecoration(color: highlight ? GxColors.primary : GxColors.primarySoft, shape: BoxShape.circle),
            child: Icon(packageIcon(package), color: highlight ? GxColors.onPrimary : GxColors.primary),
          ),
          const SizedBox(width: GxSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.title, style: textTheme.titleMedium),
                Text(package.description, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                if (until != null) ...[
                  const SizedBox(height: GxSpacing.xxs),
                  GxBadge('${formatDateTr(until!)} tarihine kadar açık', tone: GxBadgeTone.success),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: GxColors.textSecondary),
        ],
      ),
    );
  }
}

/// The purchase part of a package screen, from billing (web checkout, or where to buy on mobile).
/// [orderId] is the order the buyer came back from, if any.
typedef PackagePurchaseBuilder = Widget Function(BuildContext context, String slug, String? orderId);

/// One package: what it opens, until when the user has it, and how to get it.
class MatchPackageScreen extends ConsumerWidget {
  const MatchPackageScreen({super.key, required this.package, required this.purchase, this.orderId});

  final MatchPackage package;
  final PackagePurchaseBuilder purchase;
  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final until = ref.watch(matchStatusProvider).value?.packages[package];
    final textTheme = Theme.of(context).textTheme;
    final included = package == MatchPackage.all ? MatchPackage.values.where((p) => p != MatchPackage.all).toList() : [package];

    return Scaffold(
      appBar: AppBar(title: Text(package.title)),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: ListView(
          padding: const EdgeInsets.all(GxSpacing.page),
          children: [
            GxCard(
              padding: const EdgeInsets.all(GxSpacing.lg),
              child: Column(
                children: [
                  Icon(packageIcon(package), size: GxSpacing.xxl, color: GxColors.primary),
                  const SizedBox(height: GxSpacing.sm),
                  Text(package.title, textAlign: TextAlign.center, style: textTheme.headlineSmall),
                  const SizedBox(height: GxSpacing.xs),
                  Text(package.description, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                  if (until != null) ...[
                    const SizedBox(height: GxSpacing.sm),
                    GxBadge('${formatDateTr(until)} tarihine kadar açık', tone: GxBadgeTone.success),
                  ],
                ],
              ),
            ),
            if (included.length > 1) ...[
              const SizedBox(height: GxSpacing.md),
              GxCard(
                padding: const EdgeInsets.all(GxSpacing.md),
                child: Column(
                  children: [
                    for (final p in included)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(packageIcon(p), color: GxColors.primary),
                        title: Text(p.title),
                        subtitle: Text(p.description),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: GxSpacing.md),
            purchase(context, package.slug, orderId),
          ],
        ),
      ),
    );
  }
}

/// Deck filters in a sheet (Sınırsız Beğeni).
Future<void> showDeckFilters(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FiltersSheet(),
    );

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late final MatchFilters _start = ref.read(deckFiltersProvider);
  late RangeValues _ages = RangeValues((_start.minAge ?? matchMinAge).toDouble(), (_start.maxAge ?? matchMaxAge).toDouble());
  late int? _province = _start.province;
  late String? _interest = _start.interest;

  void _apply(MatchFilters filters) {
    ref.read(deckFiltersProvider.notifier).set(filters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final (min, max) = (_ages.start.round(), _ages.end.round());

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(GxSpacing.lg, 0, GxSpacing.lg, GxSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtreler', style: textTheme.titleLarge),
            const SizedBox(height: GxSpacing.md),
            Text('Yaş: $min – $max', style: textTheme.titleSmall),
            RangeSlider(
              values: _ages,
              min: matchMinAge.toDouble(),
              max: matchMaxAge.toDouble(),
              divisions: matchMaxAge - matchMinAge,
              labels: RangeLabels('$min', '$max'),
              onChanged: (v) => setState(() => _ages = v),
            ),
            const SizedBox(height: GxSpacing.sm),
            DropdownButtonFormField<int?>(
              initialValue: _province,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'İl'),
              items: [
                const DropdownMenuItem(child: Text('Tüm iller')),
                for (final (i, name) in turkishProvinces.indexed) DropdownMenuItem(value: i + 1, child: Text(name)),
              ],
              onChanged: (v) => setState(() => _province = v),
            ),
            const SizedBox(height: GxSpacing.md),
            DropdownButtonFormField<String?>(
              initialValue: _interest,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'İlgi alanı'),
              items: [
                const DropdownMenuItem(child: Text('Hepsi')),
                for (final c in categories) DropdownMenuItem(value: c.slug, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _interest = v),
            ),
            const SizedBox(height: GxSpacing.lg),
            GxButton(
              label: 'Uygula',
              expand: true,
              onPressed: () => _apply(MatchFilters(
                minAge: min == matchMinAge ? null : min,
                maxAge: max == matchMaxAge ? null : max,
                province: _province,
                interest: _interest,
              )),
            ),
            const SizedBox(height: GxSpacing.xs),
            GxButton(label: 'Temizle', variant: GxButtonVariant.text, expand: true, onPressed: () => _apply(const MatchFilters())),
          ],
        ),
      ),
    );
  }
}

/// The people who liked the user: a list with Seni Beğenenler, the count and blurred tiles without.
class MatchLikesScreen extends ConsumerStatefulWidget {
  const MatchLikesScreen({super.key, required this.openChat});

  final OpenChat openChat;

  @override
  ConsumerState<MatchLikesScreen> createState() => _MatchLikesScreenState();
}

class _MatchLikesScreenState extends ConsumerState<MatchLikesScreen> {
  MatchMode? _mode;

  Future<void> _answer(MatchCard card, MatchMode mode, SwipeKind kind) async {
    Navigator.of(context).pop();
    final result = await ref.read(matchingRepositoryProvider).swipe(card.userId, mode, kind);
    if (!mounted) return;
    ref
      ..invalidate(admirersProvider(mode))
      ..invalidate(matchStatusProvider);
    switch (result) {
      case Ok(value: SwipeOutcome(matched: true)):
        ref.invalidate(matchListProvider);
        await showMatchDialog(context, card: card, onMessage: () async {
          final chat = await ref.read(matchingRepositoryProvider).openChat(card.userId);
          if (!mounted) return;
          switch (chat) {
            case Ok(:final value):
              widget.openChat(context, value);
            case Err(:final failure):
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
          }
        });
      case Ok():
        break;
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myMatchProfileProvider).value;
    final status = ref.watch(matchStatusProvider);
    final modes = profile?.modes ?? {MatchMode.friend};
    final mode = _mode != null && modes.contains(_mode) ? _mode! : modes.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Seni beğenenler')),
      body: GxReadingColumn(
        child: switch (status) {
          AsyncData(:final value) => Column(
              children: [
                if (modes.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: GxSpacing.sm),
                    child: SegmentedButton<MatchMode>(
                      segments: [
                        for (final m in MatchMode.values) ButtonSegment(value: m, label: Text('${m.label} (${value.admirers[m] ?? 0})')),
                      ],
                      selected: {mode},
                      onSelectionChanged: (s) => setState(() => _mode = s.first),
                    ),
                  ),
                Expanded(child: value.has(MatchFeature.admirers) ? _list(mode) : _locked(value.admirers[mode] ?? 0)),
              ],
            ),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(matchStatusProvider)),
          _ => const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 6)),
        },
      ),
    );
  }

  Widget _grid(int count, Widget Function(int i) tile) => GridView.builder(
        padding: const EdgeInsets.all(GxSpacing.page),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: GxLayout.formMaxWidth / 2,
          childAspectRatio: GxMedia.gridTile,
          crossAxisSpacing: GxSpacing.xs,
          mainAxisSpacing: GxSpacing.xs,
        ),
        itemCount: count,
        itemBuilder: (_, i) => tile(i),
      );

  Widget _list(MatchMode mode) => switch (ref.watch(admirersProvider(mode))) {
        AsyncData(:final value) when value.isEmpty => Center(
            child: GxEmptyState(
              icon: Icons.favorite_border_rounded,
              message: 'Şimdilik bekleyen beğeni yok. Kaydırmaya devam et; seni beğenenler burada görünür.',
              actionLabel: 'Kaydırmaya dön',
              onAction: () => context.pop(),
            ),
          ),
        AsyncData(:final value) => _grid(
            value.length,
            (i) => GestureDetector(
              onTap: () => showMatchDetails(context, value[i], actions: [
                RoundAction(
                  icon: Icons.close_rounded,
                  color: swipeColor(SwipeKind.pass),
                  tooltip: 'Geç',
                  large: true,
                  onPressed: () => _answer(value[i], mode, SwipeKind.pass),
                ),
                RoundAction(
                  icon: Icons.favorite_rounded,
                  color: swipeColor(SwipeKind.like),
                  tooltip: 'Beğen ve eşleş',
                  large: true,
                  onPressed: () => _answer(value[i], mode, SwipeKind.like),
                ),
              ]),
              child: _Tile(card: value[i]),
            ),
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(admirersProvider(mode))),
        _ => const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 6)),
      };

  Widget _locked(int count) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(GxSpacing.page),
      children: [
        GxCard(
          padding: const EdgeInsets.all(GxSpacing.lg),
          child: Column(
            children: [
              Text(count == 0 ? 'Henüz bekleyen beğeni yok' : '$count kişi seni beğendi', style: textTheme.headlineSmall),
              const SizedBox(height: GxSpacing.xs),
              Text(
                'Seni Beğenenler paketiyle kim olduklarını gör, beğenerek anında eşleş.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
              ),
              const SizedBox(height: GxSpacing.md),
              GxButton(
                label: 'Paketi incele',
                icon: Icons.workspace_premium_outlined,
                onPressed: () => context.push(MatchingRoutes.package(MatchPackage.admirers)),
              ),
            ],
          ),
        ),
        if (count > 0) ...[
          const SizedBox(height: GxSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: GxMedia.gridTile,
            crossAxisSpacing: GxSpacing.xs,
            mainAxisSpacing: GxSpacing.xs,
            children: [
              // No photo reaches the phone without the package; the tiles only hint at the count.
              for (var i = 0; i < count.clamp(0, 6); i++)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: GxRadius.lgAll,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [GxColors.backdropLilac, GxColors.backdropPink],
                    ),
                  ),
                  child: Center(child: Icon(Icons.lock_outline_rounded, color: GxColors.primary)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.card});

  final MatchCard card;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: GxRadius.lgAll,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (card.photoUrls.isEmpty)
              const ColoredBox(color: GxColors.surfaceMuted)
            else
              Image.network(card.photoUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, GxColors.mediaScrim],
                ),
              ),
            ),
            if (card.superLikedMe)
              const Positioned(
                top: GxSpacing.xs,
                right: GxSpacing.xs,
                child: Icon(Icons.star_rounded, color: GxColors.onMedia),
              ),
            Positioned(
              left: GxSpacing.sm,
              right: GxSpacing.sm,
              bottom: GxSpacing.sm,
              child: Text(
                '${card.displayName}, ${card.age}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: GxColors.onMedia),
              ),
            ),
          ],
        ),
      );
}
