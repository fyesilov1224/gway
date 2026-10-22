import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/billing.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// A group's plan: status and limits for members, purchase options for the
/// owner on the web, and the result of a payment the owner returns from.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({
    super.key,
    required this.groupId,
    required this.handle,
    required this.groupName,
    required this.canManage,
    this.orderId,
  });

  final String groupId;
  final String handle;
  final String groupName;

  /// Holds `billing.manage` (the owner).
  final bool canManage;

  /// Set when returning from the payment page.
  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final plan = ref.watch(groupPlanProvider(groupId));
    final purchases = canManage && ref.watch(purchasesOnThisPlatformProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Navigator.canPop(context) ? 0 : GxSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paket', style: textTheme.titleMedium),
            Text(groupName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshGroupPlan(ref, groupId),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.lg, horizontal: GxSpacing.page),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: purchases ? GxLayout.dashboardMaxWidth : GxLayout.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (orderId != null && canManage) ...[
                      _OrderStatus(orderId: orderId!, groupId: groupId),
                      const SizedBox(height: GxSpacing.md),
                    ],
                    switch (plan) {
                      AsyncData(value: final p?) => _CurrentPlan(plan: p, groupId: groupId, showTimeline: canManage),
                      AsyncData() => GxEmptyState(
                          icon: planIcon,
                          message: 'Grubun paketini yalnızca grubun üyeleri görebilir.',
                          actionLabel: 'Geri dön',
                          onAction: () => Navigator.of(context).maybePop(),
                        ),
                      AsyncError(:final error) => GxErrorState(
                          message: userMessageOf(error),
                          onRetry: () => ref.invalidate(groupPlanProvider(groupId)),
                        ),
                      _ => const GxSkeleton(height: GxSpacing.xxl * 4),
                    },
                    if (purchases && plan.value != null) ...[
                      const SizedBox(height: GxSpacing.xl),
                      _PlanChoices(groupId: groupId, handle: handle),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlan extends ConsumerWidget {
  const _CurrentPlan({required this.plan, required this.groupId, required this.showTimeline});

  final GroupPlan plan;
  final String groupId;
  final bool showTimeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final timeline = showTimeline ? ref.watch(planTimelineProvider(groupId)).value ?? const [] : const <PlanSlice>[];
    final names = {for (final p in ref.watch(plansProvider).value ?? const <Plan>[]) p.slug: p.name};
    final upcoming = timeline.where((s) => s.startsAt.isAfter(DateTime.now())).toList();

    return GxPanel(
      title: 'Mevcut paket',
      trailing: GxBadge(plan.plan.name, tone: plan.plan.isFree ? GxBadgeTone.neutral : GxBadgeTone.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            plan.plan.isFree || plan.currentPeriodEndsAt == null
                ? 'Grup ücretsiz paketi kullanıyor.'
                : 'Bu dönem ${formatDateTr(plan.currentPeriodEndsAt!)} tarihinde bitiyor.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: GxSpacing.md),
          MemberUsage(plan: plan),
          const SizedBox(height: GxSpacing.md),
          PlanLimits(plan: plan.plan),
          if (plan.isOverLimit || plan.isFull) ...[
            const SizedBox(height: GxSpacing.md),
            PlanNotice(
              icon: Icons.group_off_outlined,
              danger: true,
              text: plan.isOverLimit
                  ? 'Üye sayısı paketin limitini aşıyor. Kimse gruptan çıkarılmaz, ama limitin altına inilene kadar yeni üye alınamaz.'
                  : 'Grup üye limitine ulaştı. Yeni üye almak için daha büyük bir pakete geçebilirsin.',
            ),
          ] else if (showTimeline && plan.renewalDue(DateTime.now())) ...[
            const SizedBox(height: GxSpacing.md),
            PlanNotice(
              icon: Icons.schedule,
              text: 'Paketin ${formatDateTr(plan.paidUntil!)} tarihinde bitiyor. Bitince grup Ücretsiz pakete döner.',
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: GxSpacing.md),
            const Divider(),
            const SizedBox(height: GxSpacing.xs),
            Text('Sıradaki dönemler', style: textTheme.titleSmall),
            for (final s in upcoming)
              Padding(
                padding: const EdgeInsets.only(top: GxSpacing.xs),
                child: Text(
                  '${names[s.planSlug] ?? s.planSlug} (${s.period.label.toLowerCase()}): '
                  '${formatDateTr(s.startsAt)} – ${formatDateTr(s.endsAt)}',
                  style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Plan cards with a monthly / yearly switch. Prices come from the server's market.
class _PlanChoices extends ConsumerStatefulWidget {
  const _PlanChoices({required this.groupId, required this.handle});

  final String groupId;
  final String handle;

  @override
  ConsumerState<_PlanChoices> createState() => _PlanChoicesState();
}

class _PlanChoicesState extends ConsumerState<_PlanChoices> {
  PlanPeriod _period = PlanPeriod.month;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final offer = ref.watch(offerProvider(widget.groupId));
    final plans = ref.watch(plansProvider);

    return switch ((offer, plans)) {
      (AsyncData(value: final o), AsyncData(value: final p)) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: GxSpacing.md,
              runSpacing: GxSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Paketler', style: textTheme.headlineSmall),
                SegmentedButton<PlanPeriod>(
                  segments: const [
                    ButtonSegment(value: PlanPeriod.month, label: Text('Aylık')),
                    ButtonSegment(value: PlanPeriod.year, label: Text('Yıllık · 2 ay bedava')),
                  ],
                  selected: {_period},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
              ],
            ),
            const SizedBox(height: GxSpacing.xs),
            Text(
              'Ödeme ${o.market.provider.label} ile ${o.market.currency == 'TRY' ? 'Türk lirası' : 'ABD doları'} olarak alınır; '
              'bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.',
              style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
            ),
            if (!o.purchasesEnabled) ...[
              const SizedBox(height: GxSpacing.md),
              const GxFormMessage('Ödeme şu anda alınamıyor. Lütfen daha sonra tekrar dene.', kind: GxFormMessageKind.info),
            ],
            const SizedBox(height: GxSpacing.md),
            _PlanGrid(
              cards: [
                for (final plan in p)
                  if (plan.isFree || o.option(plan.slug, _period) != null)
                    (fill) => _PlanCard(
                          plan: plan,
                          option: o.option(plan.slug, _period),
                          currency: o.market.currency,
                          isCurrent: plan.slug == o.currentPlanSlug,
                          onFreePlan: o.currentPlanSlug == Plan.freeSlug,
                          enabled: o.purchasesEnabled,
                          fillHeight: fill,
                          onSelect: () => context.push(BillingRoutes.checkout(widget.handle, plan.slug, _period)),
                        ),
              ],
            ),
          ],
        ),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => GxErrorState(
          message: userMessageOf(error),
          onRetry: () => ref
            ..invalidate(offerProvider(widget.groupId))
            ..invalidate(plansProvider),
        ),
      _ => const GxSkeleton(height: GxSpacing.xxl * 6),
    };
  }
}

/// Four equal-height columns on wide screens, a stack on phones.
class _PlanGrid extends StatelessWidget {
  const _PlanGrid({required this.cards});

  /// Builds a card; `true` when it fills a column's height.
  final List<Widget Function(bool fill)> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < GxLayout.wideBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: GxSpacing.md), child: c(false)),
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: GxSpacing.md),
                Expanded(child: cards[i](true)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.option,
    required this.currency,
    required this.isCurrent,
    required this.onFreePlan,
    required this.enabled,
    required this.fillHeight,
    required this.onSelect,
  });

  final Plan plan;
  final PlanOption? option;
  final String currency;
  final bool isCurrent;
  final bool onFreePlan;
  final bool enabled;

  /// Pushes the button to the bottom of an equal-height column.
  final bool fillHeight;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final o = option;

    return Container(
      padding: const EdgeInsets.all(GxSpacing.lg),
      decoration: BoxDecoration(
        color: GxColors.background,
        borderRadius: GxRadius.lgAll,
        border: Border.fromBorderSide(isCurrent ? const BorderSide(color: GxColors.primary) : GxBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.name, style: textTheme.titleLarge)),
              if (isCurrent) const GxBadge('Mevcut paket', tone: GxBadgeTone.primary),
            ],
          ),
          const SizedBox(height: GxSpacing.sm),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: formatMoney(o?.amountMinor ?? 0, currency), style: textTheme.headlineMedium),
              TextSpan(text: ' / ${(o?.period ?? PlanPeriod.month).unit}', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: GxSpacing.md),
          PlanLimits(plan: plan),
          if (o != null) ...[
            const SizedBox(height: GxSpacing.md),
            Text(_when(o), style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
            if (fillHeight) const Spacer(),
            const SizedBox(height: GxSpacing.md),
            GxButton(
              label: o.available ? _action(o) : 'Şimdilik alınamaz',
              variant: o.change == PlanChange.upgrade ? GxButtonVariant.primary : GxButtonVariant.secondary,
              expand: true,
              onPressed: enabled && o.available ? onSelect : null,
            ),
          ],
        ],
      ),
    );
  }

  String _action(PlanOption o) => switch (o.change) {
        PlanChange.upgrade => onFreePlan ? 'Seç' : 'Yükselt',
        PlanChange.renewal => 'Süreyi uzat',
        PlanChange.downgrade => 'Bu pakete geç',
      };

  String _when(PlanOption o) {
    if (!o.available) return 'Paketin bir yıldan uzun süre için ödenmiş. Şimdilik yalnızca üst pakete geçebilirsin.';
    return switch (o.change) {
      PlanChange.upgrade => o.credit > Duration.zero
          ? 'Hemen başlar; kalan sürenden yaklaşık ${creditLabel(o.credit)} eklenir. Bitiş: ${formatDateTr(o.endsAt)}.'
          : 'Hemen başlar. Bitiş: ${formatDateTr(o.endsAt)}.',
      PlanChange.renewal => 'Mevcut dönemin ardından ${formatDateTr(o.startsAt)} tarihinde başlar.',
      PlanChange.downgrade => 'Mevcut dönem bitince, ${formatDateTr(o.startsAt)} tarihinde başlar.',
    };
  }
}

/// Waits for the provider's verified notification after the buyer returns.
class _OrderStatus extends ConsumerStatefulWidget {
  const _OrderStatus({required this.orderId, required this.groupId});

  final String orderId;
  final String groupId;

  @override
  ConsumerState<_OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends ConsumerState<_OrderStatus> {
  static const _interval = Duration(seconds: 2);
  static const _maxPolls = 30;

  Timer? _timer;
  int _polls = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) {
      final status = ref.read(orderProvider(widget.orderId)).value?.status;
      if (status != null && status != OrderStatus.pending || ++_polls >= _maxPolls) {
        _timer?.cancel();
        setState(() {});
        return;
      }
      ref.invalidate(orderProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderProvider(widget.orderId), (previous, next) {
      if (next.value?.status == OrderStatus.paid && previous?.value?.status != OrderStatus.paid) {
        refreshGroupPlan(ref, widget.groupId);
      }
    });
    final order = ref.watch(orderProvider(widget.orderId)).value;
    if (order == null) return const SizedBox.shrink();
    final waitedLong = _polls >= _maxPolls;

    return switch (order.status) {
      OrderStatus.pending => GxFormMessage(
          waitedLong
              ? 'Ödeme onayı henüz gelmedi. Ödemen alındıysa paketin birkaç dakika içinde etkinleşir; bu sayfayı sonra yenileyebilirsin.'
              : 'Ödemen onaylanıyor. Bu birkaç saniye sürebilir.',
          kind: GxFormMessageKind.info,
        ),
      OrderStatus.paid => const PlanNotice(icon: Icons.check_circle_outline, text: 'Ödeme alındı. Paketin etkin.'),
      OrderStatus.failed => const GxFormMessage('Ödeme tamamlanamadı. Tekrar deneyebilir ya da başka bir kart kullanabilirsin.'),
      OrderStatus.refunded => const GxFormMessage('Bu ödeme iade edildi.', kind: GxFormMessageKind.info),
    };
  }
}
