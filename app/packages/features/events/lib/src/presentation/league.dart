import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import 'providers.dart';
import 'routes.dart';

/// "4 katılım · 1 organizasyon · 2 karşılama · 3 memnuniyet".
String leagueBreakdown(LeagueRow r) => [
      '${formatCount(r.attended)} katılım',
      '${formatCount(r.held)} organizasyon',
      if (r.welcomes > 0) '${formatCount(r.welcomes)} karşılama',
      if (r.goodReviews > 0) '${formatCount(r.goodReviews)} memnuniyet',
    ].join(' · ');

String _province(int province) => province >= 1 && province <= turkishProvinces.length ? turkishProvinces[province - 1] : '';

/// How the points are counted (docs/ARCHITECTURE.md §3d, Gruplar Ligi).
Future<void> showLeagueRules(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        Widget rule(IconData icon, String title, String text) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: GwColors.primary),
              title: Text(title, style: textTheme.labelLarge),
              subtitle: Text(text),
            );
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puanlar nasıl hesaplanır?', style: textTheme.titleLarge),
                const SizedBox(height: GwSpacing.xs),
                Text(
                  'Aynı ildeki aynı kategoriden gruplar her ay yarışır. Ayın biten organizasyonları sayılır.',
                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                ),
                rule(Icons.groups_outlined, 'Katılım: 1 puan', 'Gelen her kişi; bir organizasyonda en fazla 30.'),
                rule(Icons.event_available_outlined, 'Organizasyon: 5 puan', 'Düzenleyen dışında en az 3 kişinin geldiği her organizasyon.'),
                rule(Icons.waving_hand_outlined, 'Karşılama: 3 puan', 'İlk kez gelen birinin karşılanması.'),
                rule(Icons.star_outline_rounded, 'Memnuniyet: 1 puan', '4 ya da 5 yıldızlı her değerlendirme.'),
                Text(
                  'Gelmedi işaretlenenler sayılmaz. Sonuçlar ay bittikten 8 gün sonra kesinleşir; ilk üçe giren grupların üyelerine haber verilir.',
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );

/// A league table with its category, province and month pickers.
class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key, required this.openGroup, this.category, this.province, this.month});

  final void Function(BuildContext context, String handle) openGroup;
  final String? category;
  final int? province;
  final DateTime? month;

  /// Parses `?category=hiking&province=6&month=2026-10`.
  static DateTime? parseMonth(String? value) {
    final parts = value?.split('-');
    if (parts == null || parts.length != 2) return null;
    final (year, month) = (int.tryParse(parts[0]), int.tryParse(parts[1]));
    return year == null || month == null || month < 1 || month > 12 ? null : DateTime(year, month);
  }

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> {
  static final _thisMonth = DateTime(DateTime.now().year, DateTime.now().month);

  late String? _category = widget.category;
  late int _province = widget.province ?? 34;
  late DateTime _month = widget.month ?? _thisMonth;

  List<DateTime> get _months => [for (var i = 0; i < 12; i++) DateTime(_thisMonth.year, _thisMonth.month - i)];

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(leagueCategoriesProvider).value ?? const <LeagueCategory>[];
    final category = _category ?? categories.firstOrNull?.slug;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruplar Ligi'),
        actions: [
          IconButton(tooltip: 'Puanlar nasıl hesaplanır?', icon: const Icon(Icons.help_outline), onPressed: () => showLeagueRules(context)),
        ],
      ),
      body: GwReadingColumn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, GwSpacing.xl),
          children: [
            GwCard(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Wrap(
                spacing: GwSpacing.sm,
                runSpacing: GwSpacing.sm,
                children: [
                  SizedBox(
                    width: GwSpacing.xxl * 5,
                    child: DropdownButtonFormField<String>(
                      initialValue: category,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: [for (final c in categories) DropdownMenuItem(value: c.slug, child: Text(c.name))],
                      onChanged: (v) => setState(() => _category = v),
                    ),
                  ),
                  SizedBox(
                    width: GwSpacing.xxl * 4,
                    child: DropdownButtonFormField<int>(
                      initialValue: _province,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'İl'),
                      items: [
                        for (var i = 0; i < turkishProvinces.length; i++) DropdownMenuItem(value: i + 1, child: Text(turkishProvinces[i])),
                      ],
                      onChanged: (v) => setState(() => _province = v ?? _province),
                    ),
                  ),
                  SizedBox(
                    width: GwSpacing.xxl * 4,
                    child: DropdownButtonFormField<DateTime>(
                      initialValue: _months.contains(_month) ? _month : _thisMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Ay'),
                      items: [for (final m in _months) DropdownMenuItem(value: m, child: Text(formatMonthYearTr(m)))],
                      onChanged: (v) => setState(() => _month = v ?? _month),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GwSpacing.md),
            if (category == null)
              const GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll)
            else
              switch (ref.watch(leagueTableProvider((category: category, province: _province, month: _month)))) {
                AsyncData(:final value) => _Table(table: value, openGroup: widget.openGroup, textTheme: textTheme),
                AsyncError(:final error) => GwErrorState(
                    message: userMessageOf(error),
                    onRetry: () => ref.invalidate(leagueTableProvider((category: category, province: _province, month: _month))),
                  ),
                _ => const Column(children: [
                    GwSkeleton(height: GwSpacing.xxl + GwSpacing.md, borderRadius: GwRadius.lgAll),
                    SizedBox(height: GwSpacing.xs),
                    GwSkeleton(height: GwSpacing.xxl + GwSpacing.md, borderRadius: GwRadius.lgAll),
                  ]),
              },
          ],
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.table, required this.openGroup, required this.textTheme});

  final LeagueTable table;
  final void Function(BuildContext context, String handle) openGroup;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.sm),
          child: Text(
            table.finalized
                ? '${formatMonthYearTr(table.month)} sezonu kapandı; sıralama kesin.'
                : 'Sezon sürüyor. Puanlar organizasyonlar bittikçe güncellenir; sonuçlar ay bittikten 8 gün sonra kesinleşir.',
            style: secondary,
          ),
        ),
        if (table.rows.isEmpty)
          GwEmptyState(
            icon: Icons.emoji_events_outlined,
            message: '${_province(table.province)} ligine bu ay henüz puan alan grup yok.',
            actionLabel: 'Puanlar nasıl hesaplanır?',
            onAction: () => showLeagueRules(context),
          )
        else
          GwCard(
            child: Column(
              children: [
                for (final (i, r) in table.rows.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  InkWell(
                    onTap: () => openGroup(context, r.group.handle),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(width: GwSpacing.xl, child: _Rank(rank: r.rank, textTheme: textTheme)),
                          GwAvatar(name: r.group.name, imageUrl: r.group.logoUrl, shape: GwAvatarShape.group, size: GwAvatarSize.sm),
                          const SizedBox(width: GwSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.group.name, style: textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(leagueBreakdown(r), style: secondary),
                              ],
                            ),
                          ),
                          const SizedBox(width: GwSpacing.sm),
                          Text('${formatCount(r.points)} puan', style: textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Rank extends StatelessWidget {
  const _Rank({required this.rank, required this.textTheme});

  final int rank;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) => rank <= 3
      ? Icon(
          Icons.emoji_events_rounded,
          semanticLabel: '$rank.',
          color: switch (rank) { 1 => GwColors.primary, 2 => GwColors.secondary, _ => GwColors.textSecondary },
        )
      : Text('$rank.', style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary));
}

/// The group page's league card: this month's place and the top-three finishes.
class GroupLeagueSection extends ConsumerWidget {
  const GroupLeagueSection({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(groupLeagueProvider(groupId)).value;
    if (l == null) return const SizedBox.shrink();
    final categories = ref.watch(leagueCategoriesProvider).value ?? const <LeagueCategory>[];
    final categoryName = categories.where((c) => c.slug == l.category).firstOrNull?.name ?? '';
    final textTheme = Theme.of(context).textTheme;
    final league = '${_province(l.province)} · $categoryName ligi';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
      child: GwCard(
        onTap: () => context.push(EventRoutes.league(category: l.category, province: l.province)),
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: GwColors.primary),
                const SizedBox(width: GwSpacing.sm),
                Expanded(child: Text(league, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                const Icon(Icons.chevron_right_rounded, color: GwColors.textSecondary),
              ],
            ),
            const SizedBox(height: GwSpacing.xs),
            Text(
              switch (l.rank) {
                final rank? => '${formatMonthYearTr(l.month)}: ${formatCount(l.groups)} grup arasında $rank. sırada, '
                    '${formatCount(l.points)} puan.',
                null => 'Bu ay henüz puan yok. Biten organizasyonlar, gelenler ve karşılamalar puan getirir.',
              },
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
            if (l.titles.isNotEmpty) ...[
              const SizedBox(height: GwSpacing.xs),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final t in l.titles)
                    GwBadge(
                      '${formatMonthYearTr(t.month)} · ${t.rank == 1 ? 'Şampiyon' : '${t.rank}.'}',
                      tone: GwBadgeTone.primary,
                      dot: true,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
