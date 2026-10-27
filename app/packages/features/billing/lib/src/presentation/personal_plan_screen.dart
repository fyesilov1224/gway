import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/billing.dart';
import 'checkout_screen.dart';
import 'plan_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Prices of a personal plan and the way to buy it: checkout on the web, a pointer to the web on mobile
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
            paidText: 'Ödeme alındı. Paketin açıldı.',
            onPaid: () {
              ref.invalidate(personalOfferProvider(widget.slug));
              widget.onPaid();
            },
          ),
          const SizedBox(height: GxSpacing.md),
        ],
        switch (offer) {
          AsyncData(:final value) => GxPanel(
              title: value.activeUntil == null ? 'Satın al' : 'Süreni uzat',
              subtitle: value.activeUntil == null
                  ? 'Tek seferlik ödeme; otomatik yenilenmez.'
                  : 'Yeni süre, ${formatDateTr(value.activeUntil!)} tarihinden sonra başlar.',
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
                    const SizedBox(height: GxSpacing.xs),
                  ],
                  const SizedBox(height: GxSpacing.xs),
                  if (!onWeb)
                    const PlanNotice(
                      icon: Icons.language_rounded,
                      text: 'Paketler GrupX web sitesinde Eşleşme > Paketler bölümünden satın alınır. '
                          'Mobil uygulama yalnızca durumunu gösterir.',
                    )
                  else if (!value.purchasesEnabled)
                    const PlanNotice(icon: Icons.schedule_rounded, text: 'Bu paketin satışı şu anda kapalı. Lütfen daha sonra tekrar dene.')
                  else ...[
                    GxButton(
                      label: 'Devam et · ${formatMoney(value.option(_period)?.amountMinor ?? 0, value.market.currency)}',
                      icon: Icons.lock_outline,
                      expand: true,
                      onPressed: () => context.push(BillingRoutes.personalCheckout(widget.slug, _period)),
                    ),
                    const SizedBox(height: GxSpacing.sm),
                    PaymentAssurance(market: value.market),
                  ],
                ],
              ),
            ),
          AsyncError(:final error) => GxErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(personalOfferProvider(widget.slug)),
            ),
          _ => const GxSkeleton(height: GxSpacing.xxl * 4),
        },
        const SizedBox(height: GxSpacing.sm),
        Text(
          'Bu paket yalnızca seni kapsar; grubunun paketini etkilemez.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
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
      color: selected ? GxColors.primarySoft : GxColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: GxRadius.lgAll,
        side: BorderSide(color: selected ? GxColors.primary : GxColors.border, width: selected ? GxBorders.ringWidth : 1),
      ),
      child: InkWell(
        borderRadius: GxRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GxSpacing.md),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: GxColors.primary),
              const SizedBox(width: GxSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(option.period.label, style: textTheme.titleMedium),
                        if (saving > 0) ...[
                          const SizedBox(width: GxSpacing.xs),
                          GxBadge('%$saving avantajlı', tone: GxBadgeTone.success),
                        ],
                      ],
                    ),
                    Text(
                      '${formatDateTr(option.endsAt)} tarihine kadar',
                      style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text('${formatMoney(option.amountMinor, currency)} / ${option.period.unit}', style: textTheme.titleMedium),
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
      body = GxEmptyState(
        icon: planIcon,
        message: 'Bu işlem bu cihazda kullanılamıyor.',
        actionLabel: 'Geri dön',
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
            _ => GxEmptyState(
                icon: planIcon,
                message: 'Bu ürün şu anda satın alınamıyor.',
                actionLabel: 'Geri dön',
                onAction: () => Navigator.of(context).maybePop(),
              ),
          },
        (AsyncError(:final error), _, _) || (_, AsyncError(:final error), _) || (_, _, AsyncError(:final error)) => GxErrorState(
            message: userMessageOf(error),
            onRetry: () => ref
              ..invalidate(personalOfferProvider(slug))
              ..invalidate(salesTermsProvider)
              ..invalidate(lastBillingDetailsProvider),
          ),
        _ => const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 5)),
      };
    }
    return Scaffold(appBar: AppBar(title: const Text('Ödeme')), body: body);
  }
}

class _PersonalSummary extends StatelessWidget {
  const _PersonalSummary({required this.offer, required this.option});

  final PersonalOffer offer;
  final PersonalOption option;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
          child: Row(children: [Expanded(child: Text(label, style: secondary)), Text(value, style: textTheme.bodyMedium)]),
        );
    return GxPanel(
      title: 'Sipariş özeti',
      subtitle: 'Kişisel ürün',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${offer.planName} · ${option.period.label}', style: textTheme.titleMedium),
          const SizedBox(height: GxSpacing.sm),
          const Divider(),
          row('Başlangıç', offer.activeUntil == null ? 'Ödeme onaylanınca' : formatDateTr(option.startsAt)),
          row('Bitiş (tahmini)', formatDateTr(option.endsAt)),
          const Divider(),
          const SizedBox(height: GxSpacing.sm),
          Row(
            children: [
              Expanded(child: Text('Toplam', style: textTheme.titleMedium)),
              Text(formatMoney(option.amountMinor, offer.market.currency), style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: GxSpacing.md),
          PaymentAssurance(market: offer.market),
        ],
      ),
    );
  }
}
