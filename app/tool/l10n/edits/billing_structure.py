"""Billing: period labels become getters; sentences built around currency and the terms link get their own keys."""
import pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
src = app / 'packages/features/billing/lib/src'
edit(str(src / 'domain/billing.dart'), [
    ("""  month('month', 'Aylık', 'ay'),
  year('year', 'Yıllık', 'yıl');

  const PlanPeriod(this.code, this.label, this.unit);

  final String code;
  final String label;

  /// Price suffix: "249 ₺ / ay".
  final String unit;""", """  month('month'),
  year('year');

  const PlanPeriod(this.code);

  final String code;

  String get label => switch (this) {
        month => billingL10n.monthly,
        year => billingL10n.yearly,
      };

  /// Price suffix: "249 ₺ / ay".
  String get unit => switch (this) {
        month => billingL10n.perMonth,
        year => billingL10n.perYear,
      };"""),
], ['../l10n.dart'])

p = src / 'presentation'
edit(str(p / 'widgets.dart'), [
    ("""  if (plan.plan.isFree || until == null) return '${plan.plan.name} paket';
  return '${plan.plan.name} paketi · ${formatDate(until)} tarihine kadar';""",
     """  if (plan.plan.isFree || until == null) return billingL10n.planName(plan.plan.name);
  return billingL10n.planUntil(plan.plan.name, formatDate(until));"""),
    ("""  final text = days >= 10 ? days.round().toString() : days.toStringAsFixed(1).replaceAll('.', ',');
  return '$text gün';""", """  final text = days >= 10 ? formatCount(days.round()) : NumberFormat('0.0', Intl.defaultLocale).format(days);
  return billingL10n.creditDays(text);"""),
], ['../l10n.dart', 'package:intl/intl.dart'])
edit(str(p / 'checkout_screen.dart'), [
    ("""                title: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: widget.terms.title,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.secondary, fontWeight: FontWeight.w600),
                      recognizer: _termsLink,
                    ),
                    TextSpan(text: "'ni okudum ve kabul ediyorum.", style: textTheme.bodyMedium),
                  ]),
                ),""", """                title: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: billingL10n.termsBefore, style: textTheme.bodyMedium),
                    TextSpan(
                      text: widget.terms.title,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.secondary, fontWeight: FontWeight.w600),
                      recognizer: _termsLink,
                    ),
                    TextSpan(text: billingL10n.termsAfter, style: textTheme.bodyMedium),
                  ]),
                ),"""),
    ("""              'Ödeme ${market.provider.label} güvencesiyle ${market.currency == 'TRY' ? 'Türk lirası' : 'ABD doları'} olarak alınır. '
              "Kart bilgilerin GWAY'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.",""",
     """              market.currency == 'TRY' ? billingL10n.assuranceTry(market.provider.label) : billingL10n.assuranceUsd(market.provider.label),"""),
], ['../l10n.dart'])
edit(str(p / 'plan_screen.dart'), [
    ("""              'Ödeme ${o.market.provider.label} ile ${o.market.currency == 'TRY' ? 'Türk lirası' : 'ABD doları'} olarak alınır; '
              'bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.',""",
     """              o.market.currency == 'TRY' ? billingL10n.paymentNoteTry(o.market.provider.label) : billingL10n.paymentNoteUsd(o.market.provider.label),"""),
], ['../l10n.dart'])
print('billing structure done')
