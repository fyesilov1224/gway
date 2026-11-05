// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class BillingL10nFr extends BillingL10n {
  BillingL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get perMonth => 'mois';

  @override
  String get perYear => 'an';

  @override
  String get notOnDevice => 'Indisponible sur cet appareil.';

  @override
  String get goBack => 'Retour';

  @override
  String get payment => 'Paiement';

  @override
  String get planUnavailable =>
      'Cette formule n\'est pas disponible à l\'achat pour l\'instant.';

  @override
  String get backToPlans => 'Retour aux formules';

  @override
  String get paymentPageFailed =>
      'Impossible d\'ouvrir la page de paiement. Réessaie.';

  @override
  String get billingDetails => 'Informations de facturation';

  @override
  String get billingDetailsHint =>
      'Ta facture est établie avec ces informations.';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String fieldRequired(String field) {
    return '$field est requis.';
  }

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneInvalid => 'Saisis un numéro de téléphone valide.';

  @override
  String get address => 'Adresse';

  @override
  String get addressRequired => 'Saisis ton adresse de facturation.';

  @override
  String get city => 'Ville';

  @override
  String get cityRequired => 'Saisis la ville.';

  @override
  String get country => 'Pays';

  @override
  String get countryRequired => 'Saisis le pays.';

  @override
  String get termsBefore => 'J\'ai lu et j\'accepte le ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Accepte le contrat pour continuer.';

  @override
  String get billingDataUse =>
      'Tes informations de facturation servent uniquement au paiement, à la facturation et aux obligations légales de conservation.';

  @override
  String payAmount(String amount) {
    return 'Passer au paiement · $amount';
  }

  @override
  String get orderSummary => 'Récapitulatif';

  @override
  String planPeriod(String plan, String period) {
    return 'Formule $plan · $period';
  }

  @override
  String get start => 'Début';

  @override
  String get whenConfirmed => 'À la confirmation du paiement';

  @override
  String get endEstimated => 'Fin (estimée)';

  @override
  String get carriedOver => 'Temps reporté';

  @override
  String about(String value) {
    return 'environ $value';
  }

  @override
  String get total => 'Total';

  @override
  String assuranceTry(String provider) {
    return 'Le paiement est encaissé en toute sécurité par $provider en livres turques. Tes données de carte ne sont jamais transmises à GWAY. Paiement unique, sans renouvellement automatique.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Le paiement est encaissé en toute sécurité par $provider en dollars américains. Tes données de carte ne sont jamais transmises à GWAY. Paiement unique, sans renouvellement automatique.';
  }

  @override
  String get overLimit =>
      'Le nombre de membres dépasse la limite de la formule. Aucun nouveau membre tant qu’on n’est pas repassé en dessous.';

  @override
  String get atLimit =>
      'Le groupe a atteint la limite de membres de sa formule. Aucun nouveau membre possible.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max membres';
  }

  @override
  String get plan => 'Formule';

  @override
  String get getPlan => 'Prendre une formule';

  @override
  String get upgradePlan => 'Passer à une formule supérieure';

  @override
  String planEnds(String date) {
    return 'Ta formule prend fin le $date. Le groupe repassera ensuite à la formule gratuite.';
  }

  @override
  String get paymentReceivedPersonal => 'Paiement reçu. Ta formule est active.';

  @override
  String get planStatus => 'État de la formule';

  @override
  String get notActive => 'Cette formule n\'est pas active sur ton compte.';

  @override
  String activeUntil(String date) {
    return 'Ta formule est active jusqu\'au $date.';
  }

  @override
  String get buy => 'Acheter';

  @override
  String get extend => 'Prolonger';

  @override
  String get oneTime => 'Paiement unique ; pas de renouvellement automatique.';

  @override
  String newPeriodAfter(String date) {
    return 'La nouvelle période commence après le $date.';
  }

  @override
  String get salesClosed =>
      'La vente de cette formule est fermée pour l\'instant. Réessaie plus tard.';

  @override
  String continueAmount(String amount) {
    return 'Continuer · $amount';
  }

  @override
  String get personalOnly =>
      'Cette formule ne concerne que toi ; elle n\'affecte pas celle de ton groupe.';

  @override
  String saving(int percent) {
    return 'Économise $percent %';
  }

  @override
  String untilDate(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable =>
      'Ce produit n\'est pas disponible à l\'achat pour l\'instant.';

  @override
  String get personalProduct => 'Produit personnel';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Ton groupe est prêt';

  @override
  String get freeStartBuy =>
      'Ton groupe démarre avec la formule gratuite. Pour plus de membres, d’événements ou de minutes de direct, choisis une formule ci-dessous.';

  @override
  String get freeStartView =>
      'Ton groupe démarre avec la formule gratuite. Les limites des formules sont ci-dessous.';

  @override
  String get continueFree => 'Continuer gratuitement';

  @override
  String get goToGroup => 'Aller au groupe';

  @override
  String get paymentReceivedGroup => 'Paiement reçu. Ta formule est active.';

  @override
  String get membersOnly => 'Seuls les membres du groupe voient sa formule.';

  @override
  String get currentPlan => 'Formule actuelle';

  @override
  String get onFree => 'Le groupe utilise la formule gratuite.';

  @override
  String periodEnds(String date) {
    return 'Cette période se termine le $date.';
  }

  @override
  String get overLimitLong =>
      'Le nombre de membres dépasse la limite. Personne n’est exclu, mais aucun nouveau membre tant qu’on n’est pas repassé en dessous.';

  @override
  String get atLimitLong =>
      'Le groupe a atteint sa limite de membres. Passe à une formule plus grande pour en accueillir.';

  @override
  String get upcomingPeriods => 'Périodes à venir';

  @override
  String get plans => 'Formules';

  @override
  String get yearlyDeal => 'Annuel · 2 mois offerts';

  @override
  String paymentNoteTry(String provider) {
    return 'Le paiement est encaissé par $provider en livres turques, selon ton pays. Pas de renouvellement automatique.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Le paiement est encaissé par $provider en dollars américains, selon ton pays. Pas de renouvellement automatique.';
  }

  @override
  String get paymentsOff =>
      'Les paiements sont indisponibles pour l\'instant. Réessaie plus tard.';

  @override
  String get notNow => 'Indisponible pour l\'instant';

  @override
  String get choose => 'Choisir';

  @override
  String get upgrade => 'Améliorer';

  @override
  String get renew => 'Prolonger';

  @override
  String get switchTo => 'Passer à cette formule';

  @override
  String get paidOverYear =>
      'Ta formule est payée pour plus d\'un an. Pour l\'instant, tu peux seulement passer à une formule supérieure.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Commence tout de suite ; environ $credit de ton temps restant est ajouté. Fin : $date.';
  }

  @override
  String startsNow(String date) {
    return 'Commence tout de suite. Fin : $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Commence le $date, après la période en cours.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Commence le $date, à la fin de la période en cours.';
  }

  @override
  String get confirmPending =>
      'La confirmation du paiement n\'est pas encore arrivée. Si tu as été débité, ta formule s\'active d\'ici quelques minutes ; tu peux actualiser la page plus tard.';

  @override
  String get confirming =>
      'Confirmation du paiement en cours. Cela peut prendre quelques secondes.';

  @override
  String get paymentFailed =>
      'Le paiement n\'a pas abouti. Réessaie ou utilise une autre carte.';

  @override
  String get refunded => 'Ce paiement a été remboursé.';

  @override
  String get members => 'Membres';

  @override
  String membersSemantics(int count, int max) {
    return '$count membres, limite $max';
  }

  @override
  String limitMembers(String count) {
    return '$count membres';
  }

  @override
  String limitEvents(String count) {
    return '$count événements / mois';
  }

  @override
  String limitLive(String count) {
    return '$count min de direct / mois';
  }

  @override
  String planName(String plan) {
    return 'Formule $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Formule $plan · jusqu\'au $date';
  }

  @override
  String creditDays(String days) {
    return '$days jours';
  }

  @override
  String get termsTranslationNote =>
      'Cette traduction est fournie à titre d\'information. Le contrat qui fait foi, et que tu acceptes, est l\'original turc.';

  @override
  String get showOriginal => 'Afficher l\'original turc';

  @override
  String get showTranslation => 'Afficher la traduction';
}
