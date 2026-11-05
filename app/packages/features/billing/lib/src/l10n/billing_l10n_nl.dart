// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class BillingL10nNl extends BillingL10n {
  BillingL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get monthly => 'Maandelijks';

  @override
  String get yearly => 'Jaarlijks';

  @override
  String get perMonth => 'maand';

  @override
  String get perYear => 'jaar';

  @override
  String get notOnDevice => 'Niet beschikbaar op dit apparaat.';

  @override
  String get goBack => 'Terug';

  @override
  String get payment => 'Betaling';

  @override
  String get planUnavailable => 'Dit pakket kan nu niet worden gekocht.';

  @override
  String get backToPlans => 'Terug naar pakketten';

  @override
  String get paymentPageFailed =>
      'De betaalpagina kon niet worden geopend. Probeer het opnieuw.';

  @override
  String get billingDetails => 'Factuurgegevens';

  @override
  String get billingDetailsHint =>
      'Je factuur wordt met deze gegevens opgesteld.';

  @override
  String get firstName => 'Voornaam';

  @override
  String get lastName => 'Achternaam';

  @override
  String fieldRequired(String field) {
    return '$field is verplicht.';
  }

  @override
  String get phone => 'Telefoon';

  @override
  String get phoneInvalid => 'Voer een geldig telefoonnummer in.';

  @override
  String get address => 'Adres';

  @override
  String get addressRequired => 'Voer je factuuradres in.';

  @override
  String get city => 'Plaats';

  @override
  String get cityRequired => 'Voer de plaats in.';

  @override
  String get country => 'Land';

  @override
  String get countryRequired => 'Voer het land in.';

  @override
  String get termsBefore => 'Ik heb de ';

  @override
  String get termsAfter => ' gelezen en ga ermee akkoord.';

  @override
  String get acceptTerms => 'Ga akkoord met de overeenkomst om door te gaan.';

  @override
  String get billingDataUse =>
      'Je factuurgegevens worden alleen gebruikt voor de betaling, facturatie en wettelijke bewaarplicht.';

  @override
  String payAmount(String amount) {
    return 'Verder naar betalen · $amount';
  }

  @override
  String get orderSummary => 'Overzicht';

  @override
  String planPeriod(String plan, String period) {
    return 'Pakket $plan · $period';
  }

  @override
  String get start => 'Begin';

  @override
  String get whenConfirmed => 'Zodra de betaling is bevestigd';

  @override
  String get endEstimated => 'Einde (geschat)';

  @override
  String get carriedOver => 'Overgezette tijd';

  @override
  String about(String value) {
    return 'ongeveer $value';
  }

  @override
  String get total => 'Totaal';

  @override
  String assuranceTry(String provider) {
    return 'De betaling verloopt veilig via $provider in Turkse lira. Je kaartgegevens komen nooit bij GWAY. Eenmalige betaling zonder automatische verlenging.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'De betaling verloopt veilig via $provider in Amerikaanse dollars. Je kaartgegevens komen nooit bij GWAY. Eenmalige betaling zonder automatische verlenging.';
  }

  @override
  String get overLimit =>
      'Het aantal leden is hoger dan de limiet. Tot het eronder zakt, kunnen er geen nieuwe leden bij.';

  @override
  String get atLimit =>
      'De groep heeft de ledenlimiet van het pakket bereikt. Er kunnen geen nieuwe leden bij.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max leden';
  }

  @override
  String get plan => 'Pakket';

  @override
  String get getPlan => 'Pakket nemen';

  @override
  String get upgradePlan => 'Pakket upgraden';

  @override
  String planEnds(String date) {
    return 'Je pakket eindigt op $date. Daarna gaat de groep terug naar het gratis pakket.';
  }

  @override
  String get paymentReceivedPersonal =>
      'Betaling ontvangen. Je pakket staat aan.';

  @override
  String get planStatus => 'Pakketstatus';

  @override
  String get notActive => 'Dit pakket staat niet aan voor je account.';

  @override
  String activeUntil(String date) {
    return 'Je pakket staat aan tot $date.';
  }

  @override
  String get buy => 'Kopen';

  @override
  String get extend => 'Verlengen';

  @override
  String get oneTime => 'Eenmalige betaling; geen automatische verlenging.';

  @override
  String newPeriodAfter(String date) {
    return 'De nieuwe periode begint na $date.';
  }

  @override
  String get salesClosed =>
      'De verkoop van dit pakket is nu gesloten. Probeer het later opnieuw.';

  @override
  String continueAmount(String amount) {
    return 'Doorgaan · $amount';
  }

  @override
  String get personalOnly =>
      'Dit pakket geldt alleen voor jou; het groepspakket verandert niet.';

  @override
  String saving(int percent) {
    return '$percent% voordeel';
  }

  @override
  String untilDate(String date) {
    return 'Tot $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Dit product kan nu niet worden gekocht.';

  @override
  String get personalProduct => 'Persoonlijk product';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Je groep is klaar';

  @override
  String get freeStartBuy =>
      'Je groep begint met het gratis pakket. Meer leden, evenementen of liveminuten nodig? Kies hieronder een pakket.';

  @override
  String get freeStartView =>
      'Je groep begint met het gratis pakket. De limieten staan hieronder.';

  @override
  String get continueFree => 'Gratis doorgaan';

  @override
  String get goToGroup => 'Naar de groep';

  @override
  String get paymentReceivedGroup => 'Betaling ontvangen. Je pakket is actief.';

  @override
  String get membersOnly => 'Alleen groepsleden zien het pakket.';

  @override
  String get currentPlan => 'Huidig pakket';

  @override
  String get onFree => 'De groep gebruikt het gratis pakket.';

  @override
  String periodEnds(String date) {
    return 'Deze periode eindigt op $date.';
  }

  @override
  String get overLimitLong =>
      'Het aantal leden is hoger dan de limiet. Niemand wordt verwijderd, maar tot het eronder zakt kunnen er geen nieuwe leden bij.';

  @override
  String get atLimitLong =>
      'De groep heeft de ledenlimiet bereikt. Kies een groter pakket om nieuwe leden toe te laten.';

  @override
  String get upcomingPeriods => 'Komende perioden';

  @override
  String get plans => 'Pakketten';

  @override
  String get yearlyDeal => 'Jaarlijks · 2 maanden gratis';

  @override
  String paymentNoteTry(String provider) {
    return 'De betaling verloopt via $provider in Turkse lira, op basis van je land. Geen automatische verlenging.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'De betaling verloopt via $provider in Amerikaanse dollars, op basis van je land. Geen automatische verlenging.';
  }

  @override
  String get paymentsOff => 'Betalen kan nu niet. Probeer het later opnieuw.';

  @override
  String get notNow => 'Nu niet beschikbaar';

  @override
  String get choose => 'Kiezen';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get renew => 'Verlengen';

  @override
  String get switchTo => 'Naar dit pakket overstappen';

  @override
  String get paidOverYear =>
      'Je pakket is voor meer dan een jaar betaald. Voorlopig kun je alleen upgraden.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Begint meteen; ongeveer $credit van je resterende tijd wordt toegevoegd. Einde: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Begint meteen. Einde: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Begint op $date, na de huidige periode.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Begint op $date, als de huidige periode eindigt.';
  }

  @override
  String get confirmPending =>
      'De betaalbevestiging is er nog niet. Als er is afgeschreven, wordt je pakket binnen enkele minuten actief; vernieuw de pagina later.';

  @override
  String get confirming =>
      'Je betaling wordt bevestigd. Dit kan een paar seconden duren.';

  @override
  String get paymentFailed =>
      'De betaling is niet gelukt. Probeer het opnieuw of gebruik een andere kaart.';

  @override
  String get refunded => 'Deze betaling is terugbetaald.';

  @override
  String get members => 'Leden';

  @override
  String membersSemantics(int count, int max) {
    return '$count leden, limiet $max';
  }

  @override
  String limitMembers(String count) {
    return '$count leden';
  }

  @override
  String limitEvents(String count) {
    return '$count evenementen / maand';
  }

  @override
  String limitLive(String count) {
    return '$count liveminuten / maand';
  }

  @override
  String planName(String plan) {
    return 'Pakket $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Pakket $plan · tot $date';
  }

  @override
  String creditDays(String days) {
    return '$days dagen';
  }

  @override
  String get termsTranslationNote =>
      'Deze vertaling is ter informatie. Bindend, en waarmee je akkoord gaat, is de Turkse originele overeenkomst.';

  @override
  String get showOriginal => 'Turks origineel tonen';

  @override
  String get showTranslation => 'Vertaling tonen';

  @override
  String get planNameFree => 'Gratis';

  @override
  String get planNameStarter => 'Starter';

  @override
  String get planNameCommunity => 'Community';
}
