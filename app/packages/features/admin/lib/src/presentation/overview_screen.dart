import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_analytics.dart';
import 'admin_shell.dart';
import 'charts.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

const _ranges = [(7, '7 gün'), (30, '30 gün'), (90, '90 gün'), (365, '1 yıl')];

String _money(String currency) => switch (currency) { 'USD' => 'USD', _ => 'TRY' };

/// The panel's front page (docs/ARCHITECTURE.md §8b): what holds now, the range against the previous one, and
/// how each part of the platform moved.
class AdminOverviewScreen extends ConsumerStatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  ConsumerState<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends ConsumerState<AdminOverviewScreen> {
  int _days = 30;
  String _currency = 'TRY';

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(overviewProvider(_days));
    final rangeLabel = _ranges.firstWhere((r) => r.$1 == _days).$2;

    return AdminPage(
      title: 'Genel bakış',
      subtitle: 'Son $rangeLabel, bir önceki eşit dönemle karşılaştırmalı. Günler Türkiye saatine göredir.',
      actions: [
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [for (final (d, label) in _ranges) ButtonSegment(value: d, label: Text(label))],
          selected: {_days},
          onSelectionChanged: (s) => setState(() => _days = s.first),
        ),
        IconButton(tooltip: 'Yenile', icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(overviewProvider(_days))),
      ],
      children: switch (overview) {
        AsyncData(:final value) => _content(value),
        AsyncError(:final error) => [
            GwPanel(child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(overviewProvider(_days)))),
          ],
        _ => [
            const GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll),
            const SizedBox(height: GwSpacing.lg),
            const GwSkeleton(height: GwSpacing.xxl * 4, borderRadius: GwRadius.lgAll),
            const SizedBox(height: GwSpacing.lg),
            const GwSkeleton(height: GwSpacing.xxl * 6, borderRadius: GwRadius.lgAll),
          ],
      },
    );
  }

  List<Widget> _content(AdminOverview o) {
    final s = o.snapshot;
    AdminMetric m(String key) => o.metrics[key]!;
    ChartSeries series(String label, String key) => ChartSeries(label, m(key).points, total: m(key).current);
    final revenueKey = 'revenue_${_currency.toLowerCase()}';
    String money(int v) => formatMoney(v, _currency);

    final kpis = [
      KpiCard(label: 'Yeni kullanıcı', metric: m('new_users'), onTap: () => context.go(AdminRoutes.users)),
      KpiCard(label: 'Aktif kullanıcı', metric: m('active_users'), hint: 'Dönem içinde en az bir şey yazan tekil kişi'),
      KpiCard(label: 'Yeni grup', metric: m('new_groups'), onTap: () => context.go(AdminRoutes.groups)),
      KpiCard(label: 'Gönderi', metric: m('posts'), onTap: () => context.go(AdminRoutes.content)),
      KpiCard(label: 'Mesaj', metric: m('messages')),
      KpiCard(label: 'Eşleşme', metric: m('matches'), onTap: () => context.go(AdminRoutes.matching)),
      if (o.hasRevenue)
        KpiCard(
          label: 'Gelir (TRY)',
          metric: m('revenue_try'),
          format: (v) => formatMoney(v, 'TRY'),
          onTap: () => context.go(AdminRoutes.billing),
        ),
      KpiCard(label: 'Açılan şikayet', metric: m('reports_opened'), lowerIsBetter: true, onTap: () => context.go(AdminRoutes.reports)),
    ];

    Widget grid(List<Widget> panels) => LayoutBuilder(
          builder: (context, size) {
            final columns = size.maxWidth >= GwLayout.wideBreakpoint - GwLayout.sidebarWidth ? 2 : 1;
            final width = (size.maxWidth - GwSpacing.lg * (columns - 1)) / columns;
            return Wrap(
              spacing: GwSpacing.lg,
              runSpacing: GwSpacing.lg,
              children: [for (final p in panels) SizedBox(width: width, child: p)],
            );
          },
        );

    return [
      const _SectionTitle('Şu an'),
      StatCardRow(
        wideColumns: 3,
        cards: [
          StatCard(label: 'Toplam kullanıcı', value: s.users, icon: Icons.group_outlined, tone: GwBadgeTone.primary,
              onTap: () => context.go(AdminRoutes.users)),
          StatCard(label: 'Aktif grup', value: s.groups, icon: Icons.groups_2_outlined, tone: GwBadgeTone.info,
              onTap: () => context.go(AdminRoutes.groups)),
          StatCard(label: 'Açık şikayet', value: s.openReports, icon: Icons.flag_outlined,
              tone: s.openReports > 0 ? GwBadgeTone.danger : GwBadgeTone.neutral, onTap: () => context.go(AdminRoutes.reports)),
          StatCard(label: 'Bekleyen destek', value: s.openTickets, icon: Icons.support_agent_outlined,
              tone: s.openTickets > 0 ? GwBadgeTone.warning : GwBadgeTone.neutral, onTap: () => context.go(AdminRoutes.support)),
          StatCard(label: 'Şu an canlı', value: s.liveNow, icon: Icons.podcasts_outlined, tone: GwBadgeTone.neutral,
              onTap: () => context.go(AdminRoutes.live)),
          StatCard(label: 'Eşleşme profili', value: s.matchProfiles, icon: Icons.favorite_border_rounded, tone: GwBadgeTone.neutral,
              onTap: () => context.go(AdminRoutes.matching)),
        ],
      ),
      const SizedBox(height: GwSpacing.xl),
      const _SectionTitle('Dönem özeti'),
      KpiGrid(cards: kpis),
      const SizedBox(height: GwSpacing.xl),
      const _SectionTitle('Eğilimler'),
      grid([
        ChartPanel(
          title: 'Kullanıcı büyümesi',
          subtitle: o.weekly ? 'Haftalık; aktif kullanıcı haftanın günlük ortalamasıdır.' : 'Günlük yeni ve aktif kullanıcı.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [series('Yeni kullanıcı', 'new_users'), series(o.weekly ? 'Aktif (günlük ort.)' : 'Aktif kullanıcı', 'active_users')],
        ),
        ChartPanel(
          title: 'Etkileşim',
          subtitle: 'Paylaşılan gönderiler ve onlara gelen yorum, beğeni ve emoji tepkileri.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [series('Gönderi', 'posts'), series('Yorum', 'comments'), series('Beğeni', 'likes'), series('Tepki', 'reactions')],
        ),
        ChartPanel(
          title: 'Mesajlar',
          subtitle: 'Birebir ve grup sohbetlerinde gönderilen mesajlar; kesikli çizgi önceki dönem.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [series('Mesaj', 'messages')],
          previous: m('messages').previousPoints,
        ),
        ChartPanel(
          title: 'Eşleşme',
          subtitle: 'Eşleşme destesindeki beğeniler ve oluşan eşleşmeler.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [series('Beğeni', 'match_likes'), series('Süper beğeni', 'super_likes'), series('Eşleşme', 'matches')],
        ),
        if (o.hasRevenue)
          ChartPanel(
            title: 'Gelir',
            subtitle: 'Ödenen siparişler (iade edilenler hariç), $_currency. Bu dönem ${formatCount(m('paid_orders').current)} sipariş.',
            buckets: o.buckets,
            weekly: o.weekly,
            bars: true,
            series: [ChartSeries('Gelir', m(revenueKey).points)],
            format: money,
            axisFormat: (v) => '${formatCompact(v / 100)}${_currency == 'USD' ? r' $' : ' ₺'}',
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [for (final c in ['TRY', 'USD']) ButtonSegment(value: c, label: Text(_money(c)))],
              selected: {_currency},
              onSelectionChanged: (s) => setState(() => _currency = s.first),
            ),
          ),
        ChartPanel(
          title: 'Moderasyon',
          subtitle: 'Açılan şikayetler ve platform ya da grup ekiplerince incelenenler.',
          buckets: o.buckets,
          weekly: o.weekly,
          bars: true,
          series: [series('Açılan', 'reports_opened'), series('İncelenen', 'reports_reviewed')],
        ),
        ChartPanel(
          title: 'Gruplar ve canlı yayın',
          subtitle: 'Kurulan gruplar ve başlayan canlı yayınlar.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [series('Yeni grup', 'new_groups'), series('Canlı yayın', 'live_started')],
        ),
        ChartPanel(
          title: 'Karşılama ve tanışma',
          subtitle: 'İlk kez gelenlerin karşılanma istekleri, üstlenilenler, teşekkürler ve organizasyonlarda el sıkışanlar.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [
            series('İstek', 'welcome_requests'),
            series('Eşleşen', 'welcomes_matched'),
            series('Teşekkür', 'welcomes_thanked'),
            series('El sıkış', 'handshakes'),
          ],
        ),
        ChartPanel(
          title: 'Paylaşılan kartlar',
          subtitle: 'Yılın özeti, "Ben de oradaydım" ve keşif haritası kartlarının paylaşım sayfasının açılması.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [
            series('Yılın özeti', 'card_shares_year'),
            series('Ben de oradaydım', 'card_shares_event'),
            series('Keşif haritası', 'card_shares_map'),
          ],
        ),
        ChartPanel(
          title: 'Bu akşam',
          subtitle: '"Bu akşam boşum" diyenler, kurulan küçük masalar ve üç kişiye ulaşıp sohbeti açılan masalar.',
          buckets: o.buckets,
          weekly: o.weekly,
          series: [
            series('Boşum', 'tonight_free'),
            series('Kurulan masa', 'tonight_tables'),
            series('Sohbeti açılan', 'tonight_tables_set'),
          ],
        ),
      ]),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: GwSpacing.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// A range total with its change against the previous range and a small line of both.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.metric,
    this.format,
    this.lowerIsBetter = false,
    this.hint,
    this.onTap,
  });

  final String label;
  final AdminMetric metric;
  final String Function(int value)? format;

  /// For measures where a rise is bad news, such as reports.
  final bool lowerIsBetter;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = (format ?? formatCount)(metric.current);
    final change = metric.change;
    final (IconData? icon, String text, Color color) = switch (change) {
      null when metric.current == 0 => (null, 'Değişim yok', GwColors.textSecondary),
      null => (null, 'Önceki dönemde yoktu', GwColors.textSecondary),
      0 => (Icons.trending_flat_rounded, '%0', GwColors.textSecondary),
      final c => (
          c > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          '%${(c.abs() * 100).toStringAsFixed(c.abs() < 0.1 ? 1 : 0).replaceAll('.', ',')}',
          (c > 0) != lowerIsBetter ? GwColors.success : GwColors.error,
        ),
    };
    final direction = switch (change) {
      null => '',
      final c when c > 0 => 'artış',
      final c when c < 0 => 'düşüş',
      _ => '',
    };

    final card = Material(
      color: GwColors.background,
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll, side: GwBorders.hairline),
      child: InkWell(
        borderRadius: GwRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: GwSpacing.xxs),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: textTheme.headlineMedium)),
              const SizedBox(height: GwSpacing.xxs),
              Row(
                children: [
                  if (icon != null) ...[Icon(icon, size: GwSpacing.md, color: color), const SizedBox(width: GwSpacing.xxs)],
                  Text(text, style: textTheme.labelMedium?.copyWith(color: color)),
                  if (direction.isNotEmpty)
                    Flexible(
                      child: Text(' $direction', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
              const SizedBox(height: GwSpacing.xs),
              Sparkline(points: metric.points, previous: metric.previousPoints),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: '$label: $value, önceki döneme göre $text $direction${hint == null ? '' : '. $hint'}',
      excludeSemantics: true,
      child: hint == null ? card : Tooltip(message: hint, child: card),
    );
  }
}

/// KPI cards four to a row on a wide screen, two below.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.cards});

  final List<KpiCard> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, size) {
          final columns = size.maxWidth >= GwLayout.contentMaxWidth ? 4 : 2;
          final width = (size.maxWidth - GwSpacing.md * (columns - 1)) / columns;
          return Wrap(
            spacing: GwSpacing.md,
            runSpacing: GwSpacing.md,
            children: [for (final c in cards) SizedBox(width: width, child: c)],
          );
        },
      );
}
