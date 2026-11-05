// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LiveL10nFr extends LiveL10n {
  LiveL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get commentRate =>
      'Tu as beaucoup commenté en peu de temps. Patiente un peu et réessaie.';

  @override
  String get mutedListenOnly =>
      'Tu es en sourdine dans ce groupe : tu peux seulement écouter.';

  @override
  String get cannotComment =>
      'Tu ne peux pas commenter ce direct pour le moment.';

  @override
  String get roleHost => 'Animateur';

  @override
  String get roleSpeaker => 'Intervenant';

  @override
  String get roleListener => 'Auditeur';

  @override
  String get startLive => 'Lancer un direct';

  @override
  String hostedBy(String name) {
    return 'Animé par $name';
  }

  @override
  String get join => 'Rejoindre';

  @override
  String upcomingAt(String date) {
    return 'À venir · $date';
  }

  @override
  String get scheduledCanceled => 'Direct programmé annulé.';

  @override
  String get cancel => 'Annuler';

  @override
  String get start => 'Lancer';

  @override
  String get reminderRemoved => 'Rappel supprimé.';

  @override
  String get reminderSet => 'Nous te préviendrons au début du direct.';

  @override
  String get reminding => 'Rappel activé';

  @override
  String get remind => 'Me rappeler';

  @override
  String get schedule5min =>
      'Un direct programmé doit commencer dans au moins 5 minutes.';

  @override
  String get scheduled =>
      'Direct programmé. Les membres peuvent demander un rappel.';

  @override
  String get liveBroadcast => 'Direct';

  @override
  String get liveIntro =>
      'Les membres rejoignent le salon audio ; ceux que tu invites sur scène peuvent parler.';

  @override
  String get title => 'Titre';

  @override
  String get titleExample => 'Ex. : Préparer la rando de dimanche';

  @override
  String get titleMin3 => 'Le titre doit contenir au moins 3 caractères.';

  @override
  String get now => 'Maintenant';

  @override
  String get scheduleIt => 'Programmer';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il te reste $count minutes de direct ce mois-ci.',
      one: 'Il te reste 1 minute de direct ce mois-ci.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'Le temps de direct du mois est épuisé. Passe à une formule supérieure pour en avoir plus.';

  @override
  String get startTheLive => 'Lancer le direct';

  @override
  String get liveNow => 'En direct';

  @override
  String trayLabel(String group, String title) {
    return '$group est en direct : $title';
  }

  @override
  String youAreLive(String title) {
    return 'Tu es en direct : $title. Touche pour y revenir.';
  }

  @override
  String get connecting => 'Connexion au direct…';

  @override
  String get inBroadcast => 'En direct · touche pour revenir';

  @override
  String get micMutedByMod => 'Un responsable a coupé ton micro';

  @override
  String get micOff => 'Couper le micro';

  @override
  String get micOn => 'Activer le micro';

  @override
  String startsOn(String date) {
    return 'Ce direct commence le $date.';
  }

  @override
  String get ended => 'Ce direct est terminé.';

  @override
  String get notFound =>
      'Direct introuvable. Tu dois peut-être être membre du groupe.';

  @override
  String get goBack => 'Retour';

  @override
  String get onStageNow => 'Tu es sur scène. Active ton micro pour parler.';

  @override
  String get nowListener => 'Tu es maintenant auditeur.';

  @override
  String get leaveBroadcast => 'Quitter le direct';

  @override
  String get leaveHostBody =>
      'Tu peux y mettre fin pour tous. Si tu pars simplement, il se termine seul au bout de 2 minutes.';

  @override
  String get justLeave => 'Partir seulement';

  @override
  String get endBroadcast => 'Terminer le direct';

  @override
  String get inviteToStage => 'Inviter sur scène';

  @override
  String get removeFromStage => 'Retirer de la scène';

  @override
  String get muteMic => 'Couper son micro';

  @override
  String get unmuteMic => 'Réactiver son micro';

  @override
  String get kick => 'Retirer du direct';

  @override
  String kickBody(String name) {
    return '$name ne pourra plus rejoindre ce direct.';
  }

  @override
  String get cancelAction => 'Annuler';

  @override
  String get remove => 'Retirer';

  @override
  String get raisedHands => 'Mains levées';

  @override
  String get commentDeleted => 'Commentaire supprimé.';

  @override
  String get thanksForJoining =>
      'Le direct est terminé. Merci d’avoir participé.';

  @override
  String get youWereKicked => 'Tu as été retiré(e) de ce direct.';

  @override
  String get connectFailedShort => 'Connexion au direct impossible.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mains levées',
      one: '1 main levée',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'Sur scène';

  @override
  String listeners(int count) {
    return 'Auditeurs · $count';
  }

  @override
  String get noListeners => 'Pas encore d\'auditeurs.';

  @override
  String get minimize => 'Réduire et rester dans le direct';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get broadcastOptions => 'Options du direct';

  @override
  String get endForAll => 'Terminer pour tous';

  @override
  String get handRaised =>
      'Tu as levé la main. L’animateur peut t’inviter sur scène.';

  @override
  String get you => 'Toi';

  @override
  String get speaking => 'parle';

  @override
  String get micOffState => 'micro coupé';

  @override
  String get handUp => 'main levée';

  @override
  String get sendReaction => 'Envoyer une réaction';

  @override
  String get leave => 'Quitter';

  @override
  String get leaveStage => 'Quitter la scène';

  @override
  String get reactions => 'Réactions';

  @override
  String get comments => 'Commentaires';

  @override
  String get raiseHand => 'Lever la main';

  @override
  String get lowerHand => 'Baisser la main';

  @override
  String get report => 'Signaler';

  @override
  String get deleteComment => 'Supprimer le commentaire';

  @override
  String get firstComment => 'Sois le premier à commenter.';

  @override
  String get writeComment => 'Écris un commentaire…';

  @override
  String get send => 'Envoyer';

  @override
  String get connectFailed =>
      'Connexion au direct impossible. Vérifie ta connexion et réessaie.';

  @override
  String get participant => 'Participant';

  @override
  String get micNeedsManager =>
      'Seul un responsable du direct peut activer ton micro.';

  @override
  String get micFailed =>
      'Impossible d\'activer le micro. Vérifie l\'autorisation du micro.';

  @override
  String get connectionLost =>
      'Tu as perdu la connexion au direct. Touche pour te reconnecter.';

  @override
  String get micAfterEncryption =>
      'Connexion chiffrée en cours ; ton micro s’activera dans un instant.';

  @override
  String get encrypting => 'Connexion chiffrée en cours…';

  @override
  String get verifying => 'Vérification du chiffrement…';

  @override
  String get liveSecure => 'Direct sécurisé';

  @override
  String get liveSecureDetail =>
      'Chiffré de bout en bout. Tout le monde dans le salon utilise la même clé ; personne, pas même le serveur, ne peut écouter.';

  @override
  String get liveCheckFailed =>
      'Chiffrement non vérifié : tout le monde n’utilise pas la même clé. Quitte le direct et rejoins-le à nouveau.';

  @override
  String get liveUnconfirmed =>
      'Quelqu’un sur scène utilise une ancienne version de l’application ; son audio ne peut pas être chiffré et n’est pas lu.';

  @override
  String get peerUnencrypted =>
      'Un intervenant sur une ancienne version envoie un audio non chiffré, qui n’est pas lu. Il doit mettre l’application à jour.';

  @override
  String get e2ee => 'Chiffré de bout en bout';

  @override
  String get showSecurityCode => 'Afficher le code de sécurité';

  @override
  String get codeMatchHint =>
      'Ce code est identique sur l’écran de tous les participants.';

  @override
  String e2eeCode(String code) {
    return 'Chiffré de bout en bout. Code de sécurité $code';
  }

  @override
  String get liveOngoingTitle => 'Tu es en direct';

  @override
  String get liveOngoingText => 'Chiffré de bout en bout. Touche pour revenir.';
}
