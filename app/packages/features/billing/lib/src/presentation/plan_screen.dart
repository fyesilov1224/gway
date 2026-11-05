import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/billing.dart';
import '../l10n.dart';
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
    this.onContinue,
  });

  final String groupId;
  final String handle;
  final String groupName;

  /// Holds `billing.manage` (the owner).
  final bool canManage;

  /// Set when returning from the payment page.
  final String? orderId;

  /// Set right after the group is created: "Grubun hazır" with a way on to the group page.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final plan = ref.watch(groupPlanProvider(groupId));
    final purchases = canManage && ref.watch(purchasesOnThisPlatformProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Navigator.canPop(context) ? 0 : GwSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(billingL10n.plan, style: textTheme.titleMedium),
            Text(groupName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshGroupPlan(ref, groupId),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg, horizontal: GwSpacing.page),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: purchases ? GwLayout.dashboardMaxWidth : GwLayout.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onContinue case final go?) ...[
                      GwPanel(
                        title: billingL10n.groupReady,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              purchases
                                  ? billingL10n.freeStartBuy
                                  : billingL10n.freeStartView,
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: GwSpacing.md),
                            GwButton(
                              label: purchases ? billingL10n.continueFree : billingL10n.goToGroup,
                              variant: purchases ? GwButtonVariant.secondary : GwButtonVariant.primary,
                              expand: true,
                              onPressed: go,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: GwSpacing.md),
                    ],
                    if (orderId != null && canManage) ...[
                      OrderResult(orderId: orderId!, paidText: billingL10n.paymentReceivedGroup, onPaid: () => refreshGroupPlan(ref, groupId)),
                      const SizedBox(height: GwSpacing.md),
                    ],
                    switch (plan) {
                      AsyncData(value: final p?) => _CurrentPlan(plan: p, groupId: groupId, showTimeline: canManage),
                      AsyncData() => GwEmptyState(
                          icon: planIcon,
                          message: billingL10n.membersOnly,
                          actionLabel: billingL10n.goBack,
                          onAction: () => Navigator.of(context).maybePop(),
                        ),
                      AsyncError(:final error) => GwErrorState(
                          message: userMessageOf(error),
                          onRetry: () => ref.invalidate(groupPlanProvider(groupId)),
                        ),
                      _ => const GwSkeleton(height: GwSpacing.xxl * 4),
                    },
                    if (purchases && plan.value != null) ...[
                      const SizedBox(height: GwSpacing.xl),
                      _PlanChoices(groupId: groupId, handle: handle),
                    ] else if (canManage && plan.value != null) ...[
                      const SizedBox(height: GwSpacing.md),
                      _OtherPlans(current: plan.value!.plan.slug),
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

    return GwPanel(
      title: billingL10n.currentPlan,
      trailing: GwBadge(plan.plan.name, tone: plan.plan.isFree ? GwBadgeTone.neutral : GwBadgeTone.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            plan.plan.isFree || plan.currentPeriodEndsAt == null
                ? billingL10n.onFree
                : billingL10n.periodEnds(formatDate(plan.currentPeriodEndsAt!)),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: GwSpacing.md),
          MemberUsage(plan: plan),
          const SizedBox(height: GwSpacing.md),
          PlanLimits(plan: plan.plan),
          if (plan.isOverLimit || plan.isFull) ...[
            const SizedBox(height: GwSpacing.md),
            PlanNotice(
              icon: Icons.group_off_outlined,
              danger: true,
              text: plan.isOverLimit
                  ? billingL10n.overLimitLong
                  : billingL10n.atLimitLong,
            ),
          ] else if (showTimeline && plan.renewalDue(DateTime.now())) ...[
            const SizedBox(height: GwSpacing.md),
            PlanNotice(
              icon: Icons.schedule,
              text: billingL10n.planEnds(formatDate(plan.paidUntil!)),
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.md),
            const Divider(),
            const SizedBox(height: GwSpacing.xs),
            Text(billingL10n.upcomingPeriods, style: textTheme.titleSmall),
            for (final s in upcoming)
              Padding(
                padding: const EdgeInsets.only(top: GwSpacing.xs),
                child: Text(
                  '${names[s.planSlug] ?? s.planSlug} (${s.period?.label.toLowerCase() ?? 'GWAY tanımladı'}): '
                  '${formatDate(s.startsAt)} – ${formatDate(s.endsAt)}',
                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Where purchases are off (Android): the other plans' names and limits only; no price, no purchase, no way to the web
/// (docs/ARCHITECTURE.md §10, Ödeme).
class _OtherPlans extends ConsumerWidget {
  const _OtherPlans({required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final others = [for (final p in ref.watch(plansProvider).value ?? const <Plan>[]) if (p.slug != current) p];
    if (others.isEmpty) return const SizedBox.shrink();
    return GwPanel(
      title: billingL10n.plans,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, p) in others.indexed) ...[
            if (i > 0) const Divider(height: GwSpacing.lg),
            Text(p.name, style: textTheme.titleMedium),
            const SizedBox(height: GwSpacing.xs),
            PlanLimits(plan: p),
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
              spacing: GwSpacing.md,
              runSpacing: GwSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(billingL10n.plans, style: textTheme.headlineSmall),
                SegmentedButton<PlanPeriod>(
                  segments: [
                    ButtonSegment(value: PlanPeriod.month, label: Text(billingL10n.monthly)),
                    ButtonSegment(value: PlanPeriod.year, label: Text(billingL10n.yearlyDeal)),
                  ],
                  selected: {_period},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
              ],
            ),
            const SizedBox(height: GwSpacing.xs),
            Text(
              o.market.currency == 'TRY' ? billingL10n.paymentNoteTry(o.market.provider.label) : billingL10n.paymentNoteUsd(o.market.provider.label),
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
            if (!o.purchasesEnabled) ...[
              const SizedBox(height: GwSpacing.md),
              GwFormMessage(billingL10n.paymentsOff, kind: GwFormMessageKind.info),
            ],
            const SizedBox(height: GwSpacing.md),
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
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => GwErrorState(
          message: userMessageOf(error),
          onRetry: () => ref
            ..invalidate(offerProvider(widget.groupId))
            ..invalidate(plansProvider),
        ),
      _ => const GwSkeleton(height: GwSpacing.xxl * 6),
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
        if (constraints.maxWidth < GwLayout.wideBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: GwSpacing.md), child: c(false)),
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: GwSpacing.md),
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
      padding: const EdgeInsets.all(GwSpacing.lg),
      decoration: BoxDecoration(
        color: GwColors.background,
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(isCurrent ? const BorderSide(color: GwColors.primary) : GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.name, style: textTheme.titleLarge)),
              if (isCurrent) GwBadge(billingL10n.currentPlan, tone: GwBadgeTone.primary),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: formatMoney(o?.amountMinor ?? 0, currency), style: textTheme.headlineMedium),
              TextSpan(text: ' / ${(o?.period ?? PlanPeriod.month).unit}', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: GwSpacing.md),
          PlanLimits(plan: plan),
          if (o != null) ...[
            const SizedBox(height: GwSpacing.md),
            Text(_when(o), style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            if (fillHeight) const Spacer(),
            const SizedBox(height: GwSpacing.md),
            GwButton(
              label: o.available ? _action(o) : billingL10n.notNow,
              variant: o.change == PlanChange.upgrade ? GwButtonVariant.primary : GwButtonVariant.secondary,
              expand: true,
              onPressed: enabled && o.available ? onSelect : null,
            ),
          ],
        ],
      ),
    );
  }

  String _action(PlanOption o) => switch (o.change) {
        PlanChange.upgrade => onFreePlan ? billingL10n.choose : billingL10n.upgrade,
        PlanChange.renewal => billingL10n.renew,
        PlanChange.downgrade => billingL10n.switchTo,
      };

  String _when(PlanOption o) {
    if (!o.available) return billingL10n.paidOverYear;
    return switch (o.change) {
      PlanChange.upgrade => o.credit > Duration.zero
          ? billingL10n.startsNowCredit(creditLabel(o.credit), formatDate(o.endsAt))
          : billingL10n.startsNow(formatDate(o.endsAt)),
      PlanChange.renewal => billingL10n.startsAfterCurrent(formatDate(o.startsAt)),
      PlanChange.downgrade => billingL10n.startsWhenEnds(formatDate(o.startsAt)),
    };
  }
}

/// Waits for the provider's verified notification after the buyer returns.
class OrderResult extends ConsumerStatefulWidget {
  const OrderResult({super.key, required this.orderId, required this.paidText, required this.onPaid});

  final String orderId;
  final String paidText;

  /// Reloads whatever the payment unlocked.
  final VoidCallback onPaid;

  @override
  ConsumerState<OrderResult> createState() => _OrderResultState();
}

class _OrderResultState extends ConsumerState<OrderResult> {
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
        widget.onPaid();
      }
    });
    final order = ref.watch(orderProvider(widget.orderId)).value;
    if (order == null) return const SizedBox.shrink();
    final waitedLong = _polls >= _maxPolls;

    return switch (order.status) {
      OrderStatus.pending => GwFormMessage(
          waitedLong
              ? billingL10n.confirmPending
              : billingL10n.confirming,
          kind: GwFormMessageKind.info,
        ),
      OrderStatus.paid => PlanNotice(icon: Icons.check_circle_outline, text: widget.paidText),
      OrderStatus.failed => GwFormMessage(billingL10n.paymentFailed),
      OrderStatus.refunded => GwFormMessage(billingL10n.refunded, kind: GwFormMessageKind.info),
    };
  }
}
