import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/billing.dart';
import '../l10n.dart';
import 'checkout_screen.dart';
import 'plan_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Prices of a personal plan and checkout on the web; on mobile only whether the user has it (Google Play rule,
/// docs/ARCHITECTURE.md §10: no prices, no purchase and no pointer to another way to pay)
/// (docs/ARCHITECTURE.md §7). [orderId] is the order the buyer came back from; [onPaid] reloads what it unlocked.
class PersonalPlanPurchase extends ConsumerStatefulWidget {
  const PersonalPlanPurchase({super.key, required this.slug, this.orderId, required this.onPaid});

  final String slug;
  final String? orderId;
  final VoidCallback onPaid;

  @override
  ConsumerState<PersonalPlanPurchase> createState() => _PersonalPlanPurchaseState();
}

class _PersonalPlanPurchaseState extends ConsumerState<PersonalPlanPurchase> {
  PlanPeriod _period = PlanPeriod.year;

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(personalOfferProvider(widget.slug));
    final onWeb = ref.watch(purchasesOnThisPlatformProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.orderId != null) ...[
          OrderResult(
            orderId: widget.orderId!,
            paidText: billingL10n.paymentReceivedPersonal,
            onPaid: () {
              ref.invalidate(personalOfferProvider(widget.slug));
              widget.onPaid();
            },
          ),
          const SizedBox(height: GwSpacing.md),
        ],
        switch (offer) {
          AsyncData(:final value) when !onWeb => GwPanel(
              title: billingL10n.planStatus,
              child: Text(
                value.activeUntil == null
                    ? billingL10n.notActive
                    : billingL10n.activeUntil(formatDate(value.activeUntil!)),
                style: textTheme.bodyLarge,
              ),
            ),
          AsyncData(:final value) => GwPanel(
              title: value.activeUntil == null ? billingL10n.buy : billingL10n.extend,
              subtitle: value.activeUntil == null
                  ? billingL10n.oneTime
                  : billingL10n.newPeriodAfter(formatDate(value.activeUntil!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final o in value.options) ...[
                    _PeriodOption(
                      option: o,
                      currency: value.market.currency,
                      monthly: value.option(PlanPeriod.month),
                      selected: o.period == _period,
                      onTap: () => setState(() => _period = o.period),
                    ),
                    const SizedBox(height: GwSpacing.xs),
                  ],
                  const SizedBox(height: GwSpacing.xs),
                  if (!value.purchasesEnabled)
                    PlanNotice(icon: Icons.schedule_rounded, text: billingL10n.salesClosed)
                  else ...[
                    GwButton(
                      label: billingL10n.continueAmount(formatMoney(value.option(_period)?.amountMinor ?? 0, value.market.currency)),
                      icon: Icons.lock_outline,
                      expand: true,
                      onPressed: () => context.push(BillingRoutes.personalCheckout(widget.slug, _period)),
                    ),
                    const SizedBox(height: GwSpacing.sm),
                    PaymentAssurance(market: value.market),
                  ],
                ],
              ),
            ),
          AsyncError(:final error) => GwErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(personalOfferProvider(widget.slug)),
            ),
          _ => const GwSkeleton(height: GwSpacing.xxl * 4),
        },
        const SizedBox(height: GwSpacing.sm),
        Text(
          billingL10n.personalOnly,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
        ),
      ],
    );
  }
}

class _PeriodOption extends StatelessWidget {
  const _PeriodOption({required this.option, required this.currency, required this.monthly, required this.selected, required this.onTap});

  final PersonalOption option;
  final String currency;
  final PersonalOption? monthly;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final yearly = option.period == PlanPeriod.year;
    // Yearly against twelve months, in whole percent.
    final saving = yearly && monthly != null ? 100 - (option.amountMinor * 100 / (monthly!.amountMinor * 12)).round() : 0;
    return Material(
      color: selected ? GwColors.primarySoft : GwColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: GwRadius.lgAll,
        side: BorderSide(color: selected ? GwColors.primary : GwColors.border, width: selected ? GwBorders.ringWidth : 1),
      ),
      child: InkWell(
        borderRadius: GwRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: GwColors.primary),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(option.period.label, style: textTheme.titleMedium),
                        if (saving > 0) ...[
                          const SizedBox(width: GwSpacing.xs),
                          GwBadge(billingL10n.saving(saving), tone: GwBadgeTone.success),
                        ],
                      ],
                    ),
                    Text(
                      billingL10n.untilDate(formatDate(option.endsAt)),
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(billingL10n.pricePer(formatMoney(option.amountMinor, currency), option.period.unit), style: textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Invoice details and the contract for a personal plan, then the provider's payment page. Web only.
class PersonalCheckoutScreen extends ConsumerWidget {
  const PersonalCheckoutScreen({super.key, required this.slug, required this.period, this.openPaymentPage});

  final String slug;
  final PlanPeriod period;
  final OpenPaymentPage? openPaymentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(personalOfferProvider(slug));
    final terms = ref.watch(salesTermsProvider);
    final details = ref.watch(lastBillingDetailsProvider);

    final Widget body;
    if (!ref.watch(purchasesOnThisPlatformProvider)) {
      body = GwEmptyState(
        icon: planIcon,
        message: billingL10n.notOnDevice,
        actionLabel: billingL10n.goBack,
        onAction: () => Navigator.of(context).maybePop(),
      );
    } else {
      body = switch ((offer, terms, details)) {
        (AsyncData(value: final o), AsyncData(value: final t), AsyncData(value: final d)) => switch (o.option(period)) {
            final option? when o.purchasesEnabled => CheckoutForm(
                summary: _PersonalSummary(offer: o, option: option),
                amountMinor: option.amountMinor,
                market: o.market,
                terms: t,
                initial: d ?? BillingDetails(country: o.market.country == 'TR' ? 'Türkiye' : ''),
                openPaymentPage: openPaymentPage ?? openInThisTab,
                submit: (repo, billing, termsVersion) => repo.personalCheckout(
                  slug,
                  CheckoutRequest(planSlug: slug, period: period, currency: o.market.currency, salesTermsVersion: termsVersion, details: billing),
                ),
                onStale: (ref) => ref.invalidate(personalOfferProvider(slug)),
              ),
            _ => GwEmptyState(
                icon: planIcon,
                message: billingL10n.productUnavailable,
                actionLabel: billingL10n.goBack,
                onAction: () => Navigator.of(context).maybePop(),
              ),
          },
        (AsyncError(:final error), _, _) || (_, AsyncError(:final error), _) || (_, _, AsyncError(:final error)) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref
              ..invalidate(personalOfferProvider(slug))
              ..invalidate(salesTermsProvider)
              ..invalidate(lastBillingDetailsProvider),
          ),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 5)),
      };
    }
    return Scaffold(appBar: AppBar(title: Text(billingL10n.payment)), body: body);
  }
}

class _PersonalSummary extends StatelessWidget {
  const _PersonalSummary({required this.offer, required this.option});

  final PersonalOffer offer;
  final PersonalOption option;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
          child: Row(children: [Expanded(child: Text(label, style: secondary)), Text(value, style: textTheme.bodyMedium)]),
        );
    return GwPanel(
      title: billingL10n.orderSummary,
      subtitle: billingL10n.personalProduct,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(billingL10n.offerPeriod(offer.planName, option.period.label), style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.sm),
          const Divider(),
          row(billingL10n.start, offer.activeUntil == null ? billingL10n.whenConfirmed : formatDate(option.startsAt)),
          row(billingL10n.endEstimated, formatDate(option.endsAt)),
          const Divider(),
          const SizedBox(height: GwSpacing.sm),
          Row(
            children: [
              Expanded(child: Text(billingL10n.total, style: textTheme.titleMedium)),
              Text(formatMoney(option.amountMinor, offer.market.currency), style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: GwSpacing.md),
          PaymentAssurance(market: offer.market),
        ],
      ),
    );
  }
}
