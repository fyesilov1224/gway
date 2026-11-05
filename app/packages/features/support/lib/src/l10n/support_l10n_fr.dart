// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SupportL10nFr extends SupportL10n {
  SupportL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Tu as ouvert trop de messages aujourd\'hui. Réessaie demain ou réponds dans tes messages ouverts.';

  @override
  String get ruleReplyRate =>
      'Tu as écrit trop de réponses en peu de temps. Attends un peu et réessaie.';

  @override
  String get ticketClosed =>
      'Ce message est fermé. Ouvre un nouveau message pour continuer.';

  @override
  String get unsupportedImage =>
      'Ce type de fichier n\'est pas pris en charge. Choisis JPEG, PNG ou WebP.';

  @override
  String get kindProblem => 'Problème';

  @override
  String get kindProblemText => 'Quelque chose est cassé ou ne marche pas.';

  @override
  String get kindRequest => 'Demande';

  @override
  String get kindRequestText =>
      'Demande une action pour ton compte, ton groupe ou ton paiement.';

  @override
  String get kindSuggestion => 'Suggestion';

  @override
  String get kindSuggestionText =>
      'Partage une idée de fonction ou une suggestion.';

  @override
  String get statusOpen => 'Nouveau';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusResolved => 'Résolu';

  @override
  String get statusClosed => 'Fermé';

  @override
  String get guide => 'Guide d\'utilisation';

  @override
  String get guideSearchHint =>
      'Rechercher : ex. lien d\'invitation, mot de passe';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get guideIntro =>
      'Explique chaque partie de GWAY pas à pas. Choisis un chapitre ou cherche ci-dessus.';

  @override
  String get noHits =>
      'Rien trouvé. Essaie un autre mot ou écris à l\'équipe d\'assistance.';

  @override
  String get writeSupport => 'Écrire à l\'assistance';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sujets trouvés',
      one: '1 sujet trouvé',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count sujets.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sujets',
      one: '1 sujet',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'Chapitre introuvable.';

  @override
  String get backToGuide => 'Retour au guide';

  @override
  String get notSolved => 'Ton problème n\'est pas résolu ?';

  @override
  String get notSolvedHint =>
      'Écris à l\'équipe de la plateforme ; la réponse apparaîtra dans Paramètres → Assistance et commentaires.';

  @override
  String get nextChapter => 'Chapitre suivant';

  @override
  String get sent => 'Ton message a été transmis à l\'équipe de la plateforme.';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get aboutWhat => 'À quel sujet écris-tu ?';

  @override
  String get pickKind => 'Choisis un type.';

  @override
  String get relatedGroup => 'Groupe concerné (facultatif)';

  @override
  String get noGroup => 'Pas lié à un groupe';

  @override
  String get subject => 'Objet';

  @override
  String get subjectRequired => 'Écris un objet court.';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'Que s\'est-il passé, qu\'attendais-tu ? Plus de détails, aide plus rapide.';

  @override
  String get descriptionRequired => 'Décris brièvement ce qui s\'est passé.';

  @override
  String get send => 'Envoyer';

  @override
  String get supportTitle => 'Assistance et commentaires';

  @override
  String get emptyIntro =>
      'Tu peux écrire à l\'équipe de la plateforme pour un problème, une demande ou une suggestion.';

  @override
  String get listIntro =>
      'Tes messages vont à l\'équipe de la plateforme ; suis ici les réponses et leur état.';

  @override
  String get newReply => 'Nouvelle réponse';

  @override
  String get message => 'Message';

  @override
  String get notFound => 'Message introuvable.';

  @override
  String get goBack => 'Retour';

  @override
  String get team => 'Équipe GWAY';

  @override
  String get you => 'Toi';

  @override
  String get addScreenshot => 'Ajouter une capture d\'écran';

  @override
  String get writeReply => 'Écrire une réponse';

  @override
  String get removeImage => 'Retirer l\'image';

  @override
  String screenshots(int count, int max) {
    return 'Captures d\'écran ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Agrandir la capture d\'écran';
}
