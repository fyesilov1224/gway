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

Future<bool> openInThisTab(Uri url) => launchUrl(url, webOnlyWindowName: '_self');

/// Order summary, invoice details and the sales contract, then the provider's
/// payment page. Web only (docs/ARCHITECTURE.md §7).
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.planSlug,
    required this.period,
    this.openPaymentPage = openInThisTab,
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
      body = GwEmptyState(
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
          GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref
              ..invalidate(offerProvider(groupId))
              ..invalidate(plansProvider)
              ..invalidate(salesTermsProvider)
              ..invalidate(lastBillingDetailsProvider),
          ),
        _ => const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: Column(children: [GwSkeleton(height: GwSpacing.xxl * 3), SizedBox(height: GwSpacing.md), GwSkeleton(height: GwSpacing.xxl * 5)]),
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
      return GwEmptyState(
        icon: planIcon,
        message: 'Bu paket şu anda satın alınamıyor.',
        actionLabel: 'Paketlere dön',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }
    return CheckoutForm(
      summary: _Summary(groupName: groupName, plan: plan, option: option, market: offer.market),
      amountMinor: option.amountMinor,
      market: offer.market,
      terms: terms,
      initial: last ?? BillingDetails(country: offer.market.country == 'TR' ? 'Türkiye' : ''),
      openPaymentPage: openPaymentPage,
      submit: (repo, details, termsVersion) => repo.checkout(
        groupId,
        CheckoutRequest(planSlug: planSlug, period: period, currency: offer.market.currency, salesTermsVersion: termsVersion, details: details),
      ),
      onStale: (ref) => ref.invalidate(offerProvider(groupId)),
    );
  }
}

/// Opens the order with the buyer's details and the contract version they read.
typedef SubmitOrder = Future<Result<Uri>> Function(BillingRepository repo, BillingDetails details, int salesTermsVersion);

/// Invoice details and the sales contract, then the provider's payment page; [summary] shows what is bought.
class CheckoutForm extends ConsumerStatefulWidget {
  const CheckoutForm({
    super.key,
    required this.summary,
    required this.amountMinor,
    required this.market,
    required this.terms,
    required this.initial,
    required this.openPaymentPage,
    required this.submit,
    required this.onStale,
  });

  final Widget summary;
  final int amountMinor;
  final Market market;
  final SalesTerms terms;
  final BillingDetails initial;
  final OpenPaymentPage openPaymentPage;
  final SubmitOrder submit;

  /// Reloads the prices after the server said they changed.
  final void Function(WidgetRef ref) onStale;

  @override
  ConsumerState<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends ConsumerState<CheckoutForm> {
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
    final result = await widget.submit(
      ref.read(billingRepositoryProvider),
      BillingDetails(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phoneNumber.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        country: _country.text.trim(),
      ),
      // The version the buyer read; the server rejects it if a newer one exists.
      widget.terms.version,
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        if (await widget.openPaymentPage(value)) return;
        if (mounted) setState(() => _error = 'Ödeme sayfası açılamadı. Lütfen tekrar dene.');
      case Err(failure: RuleFailure(code: 'billing.market_changed' || 'billing.terms_outdated') && final failure):
        // Prices or the contract changed: show the new ones before trying again.
        widget.onStale(ref);
        ref.invalidate(salesTermsProvider);
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
            padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.xl),
            children: [
              Text(widget.terms.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: GwSpacing.md),
              Text(widget.terms.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final summary = widget.summary;
    final form = _detailsPanel(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg, horizontal: GwSpacing.page),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.dashboardMaxWidth),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: GwSpacing.lg),
                    Expanded(flex: 2, child: summary),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: GwSpacing.md), form],
                ),
        ),
      ),
    );
  }

  Widget _detailsPanel(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gap = SizedBox(height: GwSpacing.md);
    return GwPanel(
      title: 'Fatura bilgileri',
      subtitle: 'Faturan bu bilgilerle düzenlenir.',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: GwSpacing.md,
                runSpacing: GwSpacing.md,
                children: [
                  for (final (controller, label, hint) in [
                    (_firstName, 'Ad', AutofillHints.givenName),
                    (_lastName, 'Soyad', AutofillHints.familyName),
                  ])
                    LayoutBuilder(
                      builder: (context, c) => SizedBox(
                        width: c.maxWidth >= GwLayout.formMaxWidth ? (c.maxWidth - GwSpacing.md) / 2 : c.maxWidth,
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
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.secondary, fontWeight: FontWeight.w600),
                      recognizer: _termsLink,
                    ),
                    TextSpan(text: "'ni okudum ve kabul ediyorum.", style: textTheme.bodyMedium),
                  ]),
                ),
                subtitle: _termsMissing
                    ? Text('Devam etmek için sözleşmeyi onaylamalısın.', style: textTheme.bodySmall?.copyWith(color: GwColors.error))
                    : null,
              ),
              Text(
                'Fatura bilgilerin yalnızca ödemenin alınması, faturalandırma ve yasal saklama yükümlülükleri için kullanılır.',
                style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
              ),
              if (_error != null) ...[gap, GwFormMessage(_error!)],
              const SizedBox(height: GwSpacing.lg),
              GwButton(
                label: 'Ödemeye geç · ${formatMoney(widget.amountMinor, widget.market.currency)}',
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
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: secondary)),
              const SizedBox(width: GwSpacing.sm),
              Flexible(child: Text(value, textAlign: TextAlign.end, style: textTheme.bodyMedium)),
            ],
          ),
        );

    return GwPanel(
      title: 'Sipariş özeti',
      subtitle: groupName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${plan.name} paketi · ${option.period.label}', style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.sm),
          PlanLimits(plan: plan),
          const SizedBox(height: GwSpacing.sm),
          const Divider(),
          const SizedBox(height: GwSpacing.xs),
          row('Başlangıç', option.change == PlanChange.upgrade ? 'Ödeme onaylanınca' : formatDate(option.startsAt)),
          row('Bitiş (tahmini)', formatDate(option.endsAt)),
          if (option.credit > Duration.zero) row('Aktarılan süre', 'yaklaşık ${creditLabel(option.credit)}'),
          const SizedBox(height: GwSpacing.xs),
          const Divider(),
          const SizedBox(height: GwSpacing.sm),
          Row(
            children: [
              Expanded(child: Text('Toplam', style: textTheme.titleMedium)),
              Text(formatMoney(option.amountMinor, market.currency), style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: GwSpacing.md),
          PaymentAssurance(market: market),
        ],
      ),
    );
  }
}

/// Who takes the payment, in which currency, and that it does not renew.
class PaymentAssurance extends StatelessWidget {
  const PaymentAssurance({super.key, required this.market});

  final Market market;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.secondary),
          const SizedBox(width: GwSpacing.xs),
          Expanded(
            child: Text(
              'Ödeme ${market.provider.label} güvencesiyle ${market.currency == 'TRY' ? 'Türk lirası' : 'ABD doları'} olarak alınır. '
              "Kart bilgilerin GWAY'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
          ),
        ],
      );
}
