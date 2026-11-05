// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class BillingL10nIt extends BillingL10n {
  BillingL10nIt([String locale = 'it']) : super(locale);

  @override
  String get monthly => 'Mensile';

  @override
  String get yearly => 'Annuale';

  @override
  String get perMonth => 'mese';

  @override
  String get perYear => 'anno';

  @override
  String get notOnDevice => 'Non disponibile su questo dispositivo.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get payment => 'Pagamento';

  @override
  String get planUnavailable =>
      'Al momento non è possibile acquistare questo piano.';

  @override
  String get backToPlans => 'Torna ai piani';

  @override
  String get paymentPageFailed =>
      'Impossibile aprire la pagina di pagamento. Riprova.';

  @override
  String get billingDetails => 'Dati di fatturazione';

  @override
  String get billingDetailsHint => 'La fattura viene emessa con questi dati.';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String fieldRequired(String field) {
    return '$field è obbligatorio.';
  }

  @override
  String get phone => 'Telefono';

  @override
  String get phoneInvalid => 'Inserisci un numero di telefono valido.';

  @override
  String get address => 'Indirizzo';

  @override
  String get addressRequired => 'Inserisci l\'indirizzo di fatturazione.';

  @override
  String get city => 'Città';

  @override
  String get cityRequired => 'Inserisci la città.';

  @override
  String get country => 'Paese';

  @override
  String get countryRequired => 'Inserisci il paese.';

  @override
  String get termsBefore => 'Ho letto e accetto il ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Accetta il contratto per continuare.';

  @override
  String get billingDataUse =>
      'I dati di fatturazione servono solo per il pagamento, la fatturazione e gli obblighi legali di conservazione.';

  @override
  String payAmount(String amount) {
    return 'Vai al pagamento · $amount';
  }

  @override
  String get orderSummary => 'Riepilogo ordine';

  @override
  String planPeriod(String plan, String period) {
    return 'Piano $plan · $period';
  }

  @override
  String get start => 'Inizio';

  @override
  String get whenConfirmed => 'Alla conferma del pagamento';

  @override
  String get endEstimated => 'Fine (stimata)';

  @override
  String get carriedOver => 'Tempo trasferito';

  @override
  String about(String value) {
    return 'circa $value';
  }

  @override
  String get total => 'Totale';

  @override
  String assuranceTry(String provider) {
    return 'Il pagamento è gestito in sicurezza da $provider in lire turche. I dati della carta non arrivano mai a GWAY. Pagamento unico, senza rinnovo automatico.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Il pagamento è gestito in sicurezza da $provider in dollari USA. I dati della carta non arrivano mai a GWAY. Pagamento unico, senza rinnovo automatico.';
  }

  @override
  String get overLimit =>
      'I membri superano il limite del piano. Nessun nuovo membro finché non si scende sotto.';

  @override
  String get atLimit =>
      'Il gruppo ha raggiunto il limite di membri del piano. Non possono entrare nuovi membri.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max membri';
  }

  @override
  String get plan => 'Piano';

  @override
  String get getPlan => 'Prendi un piano';

  @override
  String get upgradePlan => 'Passa a un piano superiore';

  @override
  String planEnds(String date) {
    return 'Il piano termina il $date. Poi il gruppo torna al piano gratuito.';
  }

  @override
  String get paymentReceivedPersonal =>
      'Pagamento ricevuto. Il tuo piano è attivo.';

  @override
  String get planStatus => 'Stato del piano';

  @override
  String get notActive => 'Questo piano non è attivo sul tuo account.';

  @override
  String activeUntil(String date) {
    return 'Il tuo piano è attivo fino al $date.';
  }

  @override
  String get buy => 'Acquista';

  @override
  String get extend => 'Estendi';

  @override
  String get oneTime => 'Pagamento unico; nessun rinnovo automatico.';

  @override
  String newPeriodAfter(String date) {
    return 'Il nuovo periodo inizia dopo il $date.';
  }

  @override
  String get salesClosed =>
      'La vendita di questo piano è chiusa al momento. Riprova più tardi.';

  @override
  String continueAmount(String amount) {
    return 'Continua · $amount';
  }

  @override
  String get personalOnly =>
      'Questo piano riguarda solo te; non cambia il piano del gruppo.';

  @override
  String saving(int percent) {
    return 'Risparmi il $percent%';
  }

  @override
  String untilDate(String date) {
    return 'Fino al $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable =>
      'Al momento non è possibile acquistare questo prodotto.';

  @override
  String get personalProduct => 'Prodotto personale';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Il tuo gruppo è pronto';

  @override
  String get freeStartBuy =>
      'Il gruppo è partito con il piano gratuito. Se ti servono più membri, eventi o minuti in diretta, scegli un piano qui sotto.';

  @override
  String get freeStartView =>
      'Il gruppo è partito con il piano gratuito. I limiti dei piani sono qui sotto.';

  @override
  String get continueFree => 'Continua gratis';

  @override
  String get goToGroup => 'Vai al gruppo';

  @override
  String get paymentReceivedGroup => 'Pagamento ricevuto. Il piano è attivo.';

  @override
  String get membersOnly => 'Solo i membri del gruppo vedono il piano.';

  @override
  String get currentPlan => 'Piano attuale';

  @override
  String get onFree => 'Il gruppo usa il piano gratuito.';

  @override
  String periodEnds(String date) {
    return 'Questo periodo termina il $date.';
  }

  @override
  String get overLimitLong =>
      'I membri superano il limite. Nessuno viene rimosso, ma non entrano nuovi membri finché non si scende sotto.';

  @override
  String get atLimitLong =>
      'Il gruppo ha raggiunto il limite. Passa a un piano più grande per accettare nuovi membri.';

  @override
  String get upcomingPeriods => 'Periodi successivi';

  @override
  String get plans => 'Piani';

  @override
  String get yearlyDeal => 'Annuale · 2 mesi gratis';

  @override
  String paymentNoteTry(String provider) {
    return 'Il pagamento avviene tramite $provider in lire turche, in base al tuo paese. Nessun rinnovo automatico.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Il pagamento avviene tramite $provider in dollari USA, in base al tuo paese. Nessun rinnovo automatico.';
  }

  @override
  String get paymentsOff =>
      'Al momento non è possibile pagare. Riprova più tardi.';

  @override
  String get notNow => 'Non disponibile per ora';

  @override
  String get choose => 'Scegli';

  @override
  String get upgrade => 'Passa a superiore';

  @override
  String get renew => 'Estendi';

  @override
  String get switchTo => 'Passa a questo piano';

  @override
  String get paidOverYear =>
      'Il piano è pagato per più di un anno. Per ora puoi solo passare a uno superiore.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Inizia subito; si aggiungono circa $credit del tempo rimasto. Fine: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Inizia subito. Fine: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Inizia il $date, dopo il periodo in corso.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Inizia il $date, al termine del periodo in corso.';
  }

  @override
  String get confirmPending =>
      'La conferma del pagamento non è ancora arrivata. Se hai pagato, il piano si attiva entro pochi minuti; puoi aggiornare la pagina più tardi.';

  @override
  String get confirming =>
      'Conferma del pagamento in corso. Può richiedere qualche secondo.';

  @override
  String get paymentFailed =>
      'Il pagamento non è andato a buon fine. Riprova o usa un’altra carta.';

  @override
  String get refunded => 'Questo pagamento è stato rimborsato.';

  @override
  String get members => 'Membri';

  @override
  String membersSemantics(int count, int max) {
    return '$count membri, limite $max';
  }

  @override
  String limitMembers(String count) {
    return '$count membri';
  }

  @override
  String limitEvents(String count) {
    return '$count eventi / mese';
  }

  @override
  String limitLive(String count) {
    return '$count min di diretta / mese';
  }

  @override
  String planName(String plan) {
    return 'Piano $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Piano $plan · fino al $date';
  }

  @override
  String creditDays(String days) {
    return '$days giorni';
  }

  @override
  String get termsTranslationNote =>
      'Questa traduzione è informativa. Il contratto vincolante, e quello che accetti, è l\'originale in turco.';

  @override
  String get showOriginal => 'Mostra l\'originale in turco';

  @override
  String get showTranslation => 'Mostra la traduzione';
}
