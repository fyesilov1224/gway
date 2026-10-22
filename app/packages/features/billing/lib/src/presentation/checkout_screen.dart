import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/billing.dart';
import 'providers.dart';
import 'widgets.dart';

/// Opens a payment page in the current tab; replaceable in tests.
typedef OpenPaymentPage = Future<bool> Function(Uri url);

Future<bool> _openInThisTab(Uri url) => launchUrl(url, webOnlyWindowName: '_self');

/// Order summary, invoice details and the sales contract, then the provider's
/// payment page. Web only (docs/ARCHITECTURE.md §7).
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.planSlug,
    required this.period,
    this.openPaymentPage = _openInThisTab,
  });

  final String groupId;
  final String groupName;
  final String planSlug;
  final PlanPeriod period;
  final OpenPaymentPage openPaymentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(offerProvider(groupId));
    final plans = ref.watch(plansProvider);
    final terms = ref.watch(salesTermsProvider);
    final details = ref.watch(lastBillingDetailsProvider);

    Widget body;
    if (!ref.watch(purchasesOnThisPlatformProvider)) {
      body = GxEmptyState(
        icon: planIcon,
        message: 'Bu işlem bu cihazda kullanılamıyor.',
        actionLabel: 'Geri dön',
        onAction: () => Navigator.of(context).maybePop(),
      );
    } else {
      body = switch ((offer, plans, terms, details)) {
        (AsyncData(value: final o), AsyncData(value: final p), AsyncData(value: final t), AsyncData(value: final d)) =>
          _checkout(context, o, p, t, d),
        (AsyncError(:final error), _, _, _) ||
        (_, AsyncError(:final error), _, _) ||
        (_, _, AsyncError(:final error), _) ||
        (_, _, _, AsyncError(:final error)) =>
          GxErrorState(
            message: userMessageOf(error),
            onRetry: () => ref
              ..invalidate(offerProvider(groupId))
              ..invalidate(plansProvider)
              ..invalidate(salesTermsProvider)
              ..invalidate(lastBillingDetailsProvider),
          ),
        _ => const Padding(
            padding: EdgeInsets.all(GxSpacing.page),
            child: Column(children: [GxSkeleton(height: GxSpacing.xxl * 3), SizedBox(height: GxSpacing.md), GxSkeleton(height: GxSpacing.xxl * 5)]),
          ),
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: body,
    );
  }

  Widget _checkout(BuildContext context, Offer offer, List<Plan> plans, SalesTerms terms, BillingDetails? last) {
    final option = offer.option(planSlug, period);
    final plan = plans.where((p) => p.slug == planSlug).firstOrNull;
    if (option == null || plan == null || !option.available || !offer.purchasesEnabled) {
      return GxEmptyState(
        icon: planIcon,
        message: 'Bu paket şu anda satın alınamıyor.',
        actionLabel: 'Paketlere dön',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }
    return _CheckoutForm(
      groupId: groupId,
      groupName: groupName,
      plan: plan,
      option: option,
      market: offer.market,
      terms: terms,
      initial: last ?? BillingDetails(country: offer.market.country == 'TR' ? 'Türkiye' : ''),
      openPaymentPage: openPaymentPage,
    );
  }
}

class _CheckoutForm extends ConsumerStatefulWidget {
  const _CheckoutForm({
    required this.groupId,
    required this.groupName,
    required this.plan,
    required this.option,
    required this.market,
    required this.terms,
    required this.initial,
    required this.openPaymentPage,
  });

  final String groupId;
  final String groupName;
  final Plan plan;
  final PlanOption option;
  final Market market;
  final SalesTerms terms;
  final BillingDetails initial;
  final OpenPaymentPage openPaymentPage;

  @override
  ConsumerState<_CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends ConsumerState<_CheckoutForm> {
  static final _phone = RegExp(r'^\+?[0-9 ()\-]{7,20}$');

  final _form = GlobalKey<FormState>();
  late final _firstName = TextEditingController(text: widget.initial.firstName);
  late final _lastName = TextEditingController(text: widget.initial.lastName);
  late final _phoneNumber = TextEditingController(text: widget.initial.phone);
  late final _address = TextEditingController(text: widget.initial.address);
  late final _city = TextEditingController(text: widget.initial.city);
  late final _country = TextEditingController(text: widget.initial.country);
  late final _termsLink = TapGestureRecognizer()..onTap = _readTerms;
  bool _accepted = false;
  bool _termsMissing = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _phoneNumber, _address, _city, _country]) {
      c.dispose();
    }
    _termsLink.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final valid = _form.currentState!.validate();
    setState(() => _termsMissing = !_accepted);
    if (!valid || !_accepted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(billingRepositoryProvider).checkout(
          widget.groupId,
          CheckoutRequest(
            planSlug: widget.plan.slug,
            period: widget.option.period,
            currency: widget.market.currency,
            // The version the buyer read; the server rejects it if a newer one exists.
            salesTermsVersion: widget.terms.version,
            details: BillingDetails(
              firstName: _firstName.text.trim(),
              lastName: _lastName.text.trim(),
              phone: _phoneNumber.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              country: _country.text.trim(),
            ),
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        if (await widget.openPaymentPage(value)) return;
        if (mounted) setState(() => _error = 'Ödeme sayfası açılamadı. Lütfen tekrar dene.');
      case Err(failure: RuleFailure(code: 'billing.market_changed' || 'billing.terms_outdated') && final failure):
        // Prices or the contract changed: show the new ones before trying again.
        ref
          ..invalidate(offerProvider(widget.groupId))
          ..invalidate(salesTermsProvider);
        setState(() => _error = failure.userMessage);
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
    if (mounted) setState(() => _busy = false);
  }

  String? _required(String? v, String message, {int min = 1}) => (v?.trim().length ?? 0) < min ? message : null;

  void _readTerms() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(GxSpacing.lg, 0, GxSpacing.lg, GxSpacing.xl),
            children: [
              Text(widget.terms.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: GxSpacing.md),
              Text(widget.terms.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    final summary = _Summary(groupName: widget.groupName, plan: widget.plan, option: widget.option, market: widget.market);
    final form = _detailsPanel(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: GxSpacing.lg, horizontal: GxSpacing.page),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GxLayout.dashboardMaxWidth),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: GxSpacing.lg),
                    Expanded(flex: 2, child: summary),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: GxSpacing.md), form],
                ),
        ),
      ),
    );
  }

  Widget _detailsPanel(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gap = SizedBox(height: GxSpacing.md);
    return GxPanel(
      title: 'Fatura bilgileri',
      subtitle: 'Faturan bu bilgilerle düzenlenir.',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: GxSpacing.md,
                runSpacing: GxSpacing.md,
                children: [
                  for (final (controller, label, hint) in [
                    (_firstName, 'Ad', AutofillHints.givenName),
                    (_lastName, 'Soyad', AutofillHints.familyName),
                  ])
                    LayoutBuilder(
                      builder: (context, c) => SizedBox(
                        width: c.maxWidth >= GxLayout.formMaxWidth ? (c.maxWidth - GxSpacing.md) / 2 : c.maxWidth,
                        child: TextFormField(
                          controller: controller,
                          maxLength: 50,
                          autofillHints: [hint],
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(labelText: label, counterText: ''),
                          validator: (v) => _required(v, '$label gerekli.'),
                        ),
                      ),
                    ),
                ],
              ),
              gap,
              TextFormField(
                controller: _phoneNumber,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: const InputDecoration(labelText: 'Telefon', hintText: '+90 5xx xxx xx xx'),
                validator: (v) => _phone.hasMatch(v?.trim() ?? '') ? null : 'Geçerli bir telefon numarası gir.',
              ),
              gap,
              TextFormField(
                controller: _address,
                maxLength: 200,
                minLines: 2,
                maxLines: 4,
                autofillHints: const [AutofillHints.fullStreetAddress],
                decoration: const InputDecoration(labelText: 'Adres', alignLabelWithHint: true, counterText: ''),
                validator: (v) => _required(v, 'Fatura adresini gir.', min: 5),
              ),
              gap,
              TextFormField(
                controller: _city,
                maxLength: 50,
                autofillHints: const [AutofillHints.addressCity],
                decoration: const InputDecoration(labelText: 'Şehir', counterText: ''),
                validator: (v) => _required(v, 'Şehri gir.', min: 2),
              ),
              gap,
              TextFormField(
                controller: _country,
                maxLength: 56,
                autofillHints: const [AutofillHints.countryName],
                decoration: const InputDecoration(labelText: 'Ülke', counterText: ''),
                validator: (v) => _required(v, 'Ülkeyi gir.', min: 2),
              ),
              gap,
              CheckboxListTile(
                value: _accepted,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(() {
                  _accepted = v ?? false;
                  if (_accepted) _termsMissing = false;
                }),
                title: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: widget.terms.title,
                      style: textTheme.bodyMedium?.copyWith(color: GxColors.secondary, fontWeight: FontWeight.w600),
                      recognizer: _termsLink,
                    ),
                    TextSpan(text: "'ni okudum ve kabul ediyorum.", style: textTheme.bodyMedium),
                  ]),
                ),
                subtitle: _termsMissing
                    ? Text('Devam etmek için sözleşmeyi onaylamalısın.', style: textTheme.bodySmall?.copyWith(color: GxColors.error))
                    : null,
              ),
              Text(
                'Fatura bilgilerin yalnızca ödemenin alınması, faturalandırma ve yasal saklama yükümlülükleri için kullanılır.',
                style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
              ),
              if (_error != null) ...[gap, GxFormMessage(_error!)],
              const SizedBox(height: GxSpacing.lg),
              GxButton(
                label: 'Ödemeye geç · ${formatMoney(widget.option.amountMinor, widget.market.currency)}',
                icon: Icons.lock_outline,
                expand: true,
                isLoading: _busy,
                onPressed: _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.groupName, required this.plan, required this.option, required this.market});

  final String groupName;
  final Plan plan;
  final PlanOption option;
  final Market market;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: secondary)),
              const SizedBox(width: GxSpacing.sm),
              Flexible(child: Text(value, textAlign: TextAlign.end, style: textTheme.bodyMedium)),
            ],
          ),
        );

    return GxPanel(
      title: 'Sipariş özeti',
      subtitle: groupName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${plan.name} paketi · ${option.period.label}', style: textTheme.titleMedium),
          const SizedBox(height: GxSpacing.sm),
          PlanLimits(plan: plan),
          const SizedBox(height: GxSpacing.sm),
          const Divider(),
          const SizedBox(height: GxSpacing.xs),
          row('Başlangıç', option.change == PlanChange.upgrade ? 'Ödeme onaylanınca' : formatDateTr(option.startsAt)),
          row('Bitiş (tahmini)', formatDateTr(option.endsAt)),
          if (option.credit > Duration.zero) row('Aktarılan süre', 'yaklaşık ${creditLabel(option.credit)}'),
          const SizedBox(height: GxSpacing.xs),
          const Divider(),
          const SizedBox(height: GxSpacing.sm),
          Row(
            children: [
              Expanded(child: Text('Toplam', style: textTheme.titleMedium)),
              Text(formatMoney(option.amountMinor, market.currency), style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: GxSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.secondary),
              const SizedBox(width: GxSpacing.xs),
              Expanded(
                child: Text(
                  'Ödeme ${market.provider.label} güvencesiyle ${market.currency == 'TRY' ? 'Türk lirası' : 'ABD doları'} olarak alınır. '
                  "Kart bilgilerin GrupX'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.",
                  style: secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
