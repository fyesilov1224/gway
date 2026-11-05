// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class BillingL10nDe extends BillingL10n {
  BillingL10nDe([String locale = 'de']) : super(locale);

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get perMonth => 'Monat';

  @override
  String get perYear => 'Jahr';

  @override
  String get notOnDevice => 'Auf diesem Gerät nicht verfügbar.';

  @override
  String get goBack => 'Zurück';

  @override
  String get payment => 'Zahlung';

  @override
  String get planUnavailable =>
      'Dieses Paket kann gerade nicht gekauft werden.';

  @override
  String get backToPlans => 'Zurück zu den Paketen';

  @override
  String get paymentPageFailed =>
      'Die Zahlungsseite konnte nicht geöffnet werden. Bitte versuche es erneut.';

  @override
  String get billingDetails => 'Rechnungsdaten';

  @override
  String get billingDetailsHint =>
      'Deine Rechnung wird mit diesen Daten ausgestellt.';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String fieldRequired(String field) {
    return '$field ist erforderlich.';
  }

  @override
  String get phone => 'Telefon';

  @override
  String get phoneInvalid => 'Gib eine gültige Telefonnummer ein.';

  @override
  String get address => 'Adresse';

  @override
  String get addressRequired => 'Gib deine Rechnungsadresse ein.';

  @override
  String get city => 'Stadt';

  @override
  String get cityRequired => 'Gib die Stadt ein.';

  @override
  String get country => 'Land';

  @override
  String get countryRequired => 'Gib das Land ein.';

  @override
  String get termsBefore => 'Ich habe die ';

  @override
  String get termsAfter => ' gelesen und akzeptiere sie.';

  @override
  String get acceptTerms => 'Akzeptiere den Vertrag, um fortzufahren.';

  @override
  String get billingDataUse =>
      'Deine Rechnungsdaten werden nur für die Zahlung, die Rechnung und gesetzliche Aufbewahrungspflichten verwendet.';

  @override
  String payAmount(String amount) {
    return 'Weiter zur Zahlung · $amount';
  }

  @override
  String get orderSummary => 'Bestellübersicht';

  @override
  String planPeriod(String plan, String period) {
    return 'Paket $plan · $period';
  }

  @override
  String get start => 'Beginn';

  @override
  String get whenConfirmed => 'Sobald die Zahlung bestätigt ist';

  @override
  String get endEstimated => 'Ende (voraussichtlich)';

  @override
  String get carriedOver => 'Übertragene Zeit';

  @override
  String about(String value) {
    return 'etwa $value';
  }

  @override
  String get total => 'Gesamt';

  @override
  String assuranceTry(String provider) {
    return 'Die Zahlung erfolgt sicher über $provider in türkischen Lira. Deine Kartendaten erreichen GWAY nie. Einmalzahlung ohne automatische Verlängerung.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Die Zahlung erfolgt sicher über $provider in US-Dollar. Deine Kartendaten erreichen GWAY nie. Einmalzahlung ohne automatische Verlängerung.';
  }

  @override
  String get overLimit =>
      'Die Mitgliederzahl liegt über dem Paketlimit. Bis sie darunter liegt, können keine neuen Mitglieder beitreten.';

  @override
  String get atLimit =>
      'Die Gruppe hat das Mitgliederlimit ihres Pakets erreicht. Keine neuen Mitglieder möglich.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max Mitglieder';
  }

  @override
  String get plan => 'Paket';

  @override
  String get getPlan => 'Paket holen';

  @override
  String get upgradePlan => 'Paket upgraden';

  @override
  String planEnds(String date) {
    return 'Dein Paket endet am $date. Danach wechselt die Gruppe zum kostenlosen Paket.';
  }

  @override
  String get paymentReceivedPersonal =>
      'Zahlung erhalten. Dein Paket ist aktiv.';

  @override
  String get planStatus => 'Paketstatus';

  @override
  String get notActive => 'Dieses Paket ist für dein Konto nicht aktiv.';

  @override
  String activeUntil(String date) {
    return 'Dein Paket ist bis $date aktiv.';
  }

  @override
  String get buy => 'Kaufen';

  @override
  String get extend => 'Verlängern';

  @override
  String get oneTime => 'Einmalzahlung; keine automatische Verlängerung.';

  @override
  String newPeriodAfter(String date) {
    return 'Der neue Zeitraum beginnt nach dem $date.';
  }

  @override
  String get salesClosed =>
      'Der Verkauf dieses Pakets ist gerade geschlossen. Bitte versuche es später erneut.';

  @override
  String continueAmount(String amount) {
    return 'Weiter · $amount';
  }

  @override
  String get personalOnly =>
      'Dieses Paket gilt nur für dich; das Paket deiner Gruppe bleibt unberührt.';

  @override
  String saving(int percent) {
    return '$percent % sparen';
  }

  @override
  String untilDate(String date) {
    return 'Bis $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable =>
      'Dieses Produkt kann gerade nicht gekauft werden.';

  @override
  String get personalProduct => 'Persönliches Produkt';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Deine Gruppe ist bereit';

  @override
  String get freeStartBuy =>
      'Deine Gruppe startet mit dem kostenlosen Paket. Brauchst du mehr Mitglieder, Events oder Live-Minuten, wähle unten ein Paket.';

  @override
  String get freeStartView =>
      'Deine Gruppe startet mit dem kostenlosen Paket. Die Limits der Pakete stehen unten.';

  @override
  String get continueFree => 'Kostenlos weiter';

  @override
  String get goToGroup => 'Zur Gruppe';

  @override
  String get paymentReceivedGroup => 'Zahlung erhalten. Dein Paket ist aktiv.';

  @override
  String get membersOnly => 'Nur Gruppenmitglieder sehen das Paket.';

  @override
  String get currentPlan => 'Aktuelles Paket';

  @override
  String get onFree => 'Die Gruppe nutzt das kostenlose Paket.';

  @override
  String periodEnds(String date) {
    return 'Dieser Zeitraum endet am $date.';
  }

  @override
  String get overLimitLong =>
      'Die Mitgliederzahl liegt über dem Paketlimit. Niemand wird entfernt, aber bis sie darunter liegt, können keine neuen Mitglieder beitreten.';

  @override
  String get atLimitLong =>
      'Die Gruppe hat ihr Mitgliederlimit erreicht. Wechsle zu einem größeren Paket für neue Mitglieder.';

  @override
  String get upcomingPeriods => 'Kommende Zeiträume';

  @override
  String get plans => 'Pakete';

  @override
  String get yearlyDeal => 'Jährlich · 2 Monate gratis';

  @override
  String paymentNoteTry(String provider) {
    return 'Die Zahlung erfolgt über $provider in türkischen Lira, je nach deinem Land. Keine automatische Verlängerung.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Die Zahlung erfolgt über $provider in US-Dollar, je nach deinem Land. Keine automatische Verlängerung.';
  }

  @override
  String get paymentsOff =>
      'Zahlungen sind gerade nicht möglich. Bitte versuche es später erneut.';

  @override
  String get notNow => 'Derzeit nicht verfügbar';

  @override
  String get choose => 'Wählen';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get renew => 'Verlängern';

  @override
  String get switchTo => 'Zu diesem Paket wechseln';

  @override
  String get paidOverYear =>
      'Dein Paket ist für mehr als ein Jahr bezahlt. Vorerst ist nur ein Upgrade möglich.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Beginnt sofort; etwa $credit deiner Restzeit werden angerechnet. Ende: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Beginnt sofort. Ende: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Beginnt am $date, nach dem aktuellen Zeitraum.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Beginnt am $date, wenn der aktuelle Zeitraum endet.';
  }

  @override
  String get confirmPending =>
      'Die Zahlungsbestätigung ist noch nicht da. Wurde abgebucht, wird dein Paket in wenigen Minuten aktiv; du kannst die Seite später aktualisieren.';

  @override
  String get confirming =>
      'Deine Zahlung wird bestätigt. Das kann einige Sekunden dauern.';

  @override
  String get paymentFailed =>
      'Die Zahlung konnte nicht abgeschlossen werden. Versuche es erneut oder nutze eine andere Karte.';

  @override
  String get refunded => 'Diese Zahlung wurde erstattet.';

  @override
  String get members => 'Mitglieder';

  @override
  String membersSemantics(int count, int max) {
    return '$count Mitglieder, Limit $max';
  }

  @override
  String limitMembers(String count) {
    return '$count Mitglieder';
  }

  @override
  String limitEvents(String count) {
    return '$count Events / Monat';
  }

  @override
  String limitLive(String count) {
    return '$count Live-Minuten / Monat';
  }

  @override
  String planName(String plan) {
    return 'Paket $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Paket $plan · bis $date';
  }

  @override
  String creditDays(String days) {
    return '$days Tage';
  }

  @override
  String get termsTranslationNote =>
      'Diese Übersetzung dient nur zur Information. Verbindlich ist der türkische Originalvertrag; ihm stimmst du zu.';

  @override
  String get showOriginal => 'Türkisches Original anzeigen';

  @override
  String get showTranslation => 'Übersetzung anzeigen';
}
