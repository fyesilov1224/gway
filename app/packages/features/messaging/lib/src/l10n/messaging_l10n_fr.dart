// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class MessagingL10nFr extends MessagingL10n {
  MessagingL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get groupInvalid =>
      'Tu ne peux envoyer la demande qu\'à un groupe dont tu es membre.';

  @override
  String get permissionExists =>
      'Ta demande a déjà été reçue ou ton autorisation est active.';

  @override
  String get permissionCooldown =>
      'Tu pourras envoyer une nouvelle demande 7 jours après la dernière décision.';

  @override
  String noteTooLong(int max) {
    return 'La note peut contenir jusqu\'à $max caractères.';
  }

  @override
  String get requestForbidden =>
      'La demande ne peut pas être envoyée pour l\'instant.';

  @override
  String get unsupportedImage =>
      'Ce type de fichier n\'est pas pris en charge. Choisis JPEG, PNG ou WebP.';

  @override
  String get voiceCallHandle => 'Appel vocal GWAY';

  @override
  String get incomingCalls => 'Appels entrants';

  @override
  String get missedCalls => 'Appels manqués';

  @override
  String get answer => 'Répondre';

  @override
  String get decline => 'Refuser';

  @override
  String get noAnswer => 'Pas de réponse';

  @override
  String get missedCall => 'Appel manqué';

  @override
  String get callDeclined => 'Appel refusé';

  @override
  String get youDeclined => 'Tu as refusé l\'appel';

  @override
  String get callNotAllowed => 'L\'appel n\'est plus possible';

  @override
  String get callCanceled => 'Appel annulé';

  @override
  String get timeLimit => 'Les 60 minutes sont écoulées ; l\'appel est terminé';

  @override
  String get endedNotAllowed =>
      'Appel terminé : les appels vocaux ne sont plus possibles';

  @override
  String get callEnded => 'Appel terminé';

  @override
  String get messageDeleted => 'Message supprimé';

  @override
  String get photo => 'Photo';

  @override
  String get tonightTable => 'La table de ce soir';

  @override
  String get blockRequestPending =>
      'Accepte la demande de message avant de répondre.';

  @override
  String get blockDeclined =>
      'Cette personne n\'a pas accepté ta demande de message.';

  @override
  String get blockMuted =>
      'Tu es en sourdine dans ce groupe, tu ne peux pas écrire pour l\'instant.';

  @override
  String get blockAdminsOnly =>
      'Seuls les admins peuvent écrire dans cette discussion.';

  @override
  String get blockTableClosed =>
      'La table est fermée ; tu peux lire les messages mais pas en écrire.';

  @override
  String get blockBlocked =>
      'Un blocage empêche d’écrire dans cette discussion.';

  @override
  String get blockMatchEnded =>
      'Cette discussion est fermée car le match est terminé.';

  @override
  String get blockMatchLocked =>
      'Pour écrire à ton match, il faut la formule Discussion de match. La lecture est gratuite.';

  @override
  String get blockTeammateLocked =>
      'Pour écrire à ton coéquipier, il faut la formule Coéquipier. La lecture est gratuite.';

  @override
  String get blockNotAllowed =>
      'Les messages privés sont désormais réservés aux matchs et coéquipiers. Tu peux lire tes anciens messages.';

  @override
  String get blockOther =>
      'Tu ne peux pas écrire dans cette discussion pour l\'instant.';

  @override
  String get hiddenUser => 'Utilisateur GWAY';

  @override
  String get voiceCalls => 'Appels vocaux';

  @override
  String get voiceCallsHeadline =>
      'Parle de vive voix avec tes matchs et coéquipiers';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Les appels vocaux te permettent d\'appeler tes matchs et coéquipiers depuis la discussion privée. Ils ne sont pas ouverts à tous : tu en fais la demande à un de tes groupes, et le propriétaire ou un admin les active. Les appels ne sont jamais enregistrés ni écoutés ; un appel dure au plus $minutes minutes.';
  }

  @override
  String get status => 'Statut';

  @override
  String get notRequested => 'Non demandé';

  @override
  String get underReview => 'En cours';

  @override
  String get statusOn => 'Activé';

  @override
  String get statusOff => 'Désactivé';

  @override
  String get notRequestedYet => 'Tu n\'en as pas encore fait la demande.';

  @override
  String requestedFrom(String group) {
    return 'Ta demande est arrivée chez les admins de $group. Tu seras prévenu(e) de leur décision.';
  }

  @override
  String get requestedFromGroup =>
      'Ta demande est arrivée chez les admins du groupe. Tu seras prévenu(e) de leur décision.';

  @override
  String activeFrom(String group) {
    return 'Tes appels vocaux sont activés ($group). Appelle tes matchs et coéquipiers avec l’icône de téléphone en haut de la discussion ; ils doivent aussi être autorisés.';
  }

  @override
  String get active =>
      'Tes appels vocaux sont activés. Appelle tes matchs et coéquipiers avec l’icône de téléphone en haut de la discussion ; ils doivent aussi être autorisés.';

  @override
  String get declined => 'Ta demande n\'a pas été acceptée pour l\'instant.';

  @override
  String get revokedLeftGroup =>
      'Tes appels vocaux sont désactivés car tu as quitté le groupe qui les avait accordés. Tu peux refaire une demande dans un autre groupe.';

  @override
  String get revoked => 'Tes appels vocaux ont été désactivés.';

  @override
  String reasonLine(String reason) {
    return 'Motif : $reason';
  }

  @override
  String yourNote(String note) {
    return 'Ta note : $note';
  }

  @override
  String waitUntil(String date) {
    return 'Tu pourras refaire une demande après le $date.';
  }

  @override
  String get requestSent => 'Ta demande a été envoyée.';

  @override
  String get joinGroupFirst =>
      'Les propriétaires et admins de groupes activent les appels vocaux. Rejoins d’abord un groupe pour en faire la demande.';

  @override
  String get requestToGroup => 'Groupe destinataire de la demande';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String get noteHint =>
      'Tu peux expliquer brièvement pourquoi tu veux les appels vocaux.';

  @override
  String get request => 'Demander';

  @override
  String get lockScreenCalls => 'Appels sur l\'écran verrouillé';

  @override
  String get lockScreenHint =>
      'Autorise GWAY à sonner en plein écran quand ton téléphone est verrouillé.';

  @override
  String get allow => 'Autoriser';

  @override
  String get callInfoFailed =>
      'Impossible de charger l\'appel. Vérifie ta connexion.';

  @override
  String get tapEndToHangUp => 'Touche Terminer pour raccrocher.';

  @override
  String get callNotFound => 'Appel introuvable.';

  @override
  String get close => 'Fermer';

  @override
  String callLimitNote(int minutes) {
    return 'Un appel dure au plus $minutes minutes et n\'est jamais enregistré.';
  }

  @override
  String get audioFailed =>
      'Impossible de connecter l\'audio. Vérifie ta connexion et réessaie.';

  @override
  String get reconnect => 'Se reconnecter';

  @override
  String get incoming => 't\'appelle…';

  @override
  String get calling => 'Appel en cours…';

  @override
  String get connecting => 'Connexion…';

  @override
  String get answerCall => 'Répondre';

  @override
  String get mute => 'Couper le micro';

  @override
  String get unmute => 'Réactiver le micro';

  @override
  String get end => 'Terminer';

  @override
  String get speaker => 'Haut-parleur';

  @override
  String get peerUnencrypted =>
      'L\'application de ton interlocuteur est trop ancienne : son audio n\'est pas chiffré et n\'est pas lu. Demande-lui de la mettre à jour.';

  @override
  String get encrypting => 'Établissement d’une connexion chiffrée…';

  @override
  String e2eeCode(String code) {
    return 'Chiffré de bout en bout. Code de sécurité $code';
  }

  @override
  String get e2ee => 'Chiffré de bout en bout';

  @override
  String get codeMatchHint =>
      'Si ce code est identique à celui de ton interlocuteur, personne ne peut écouter.';

  @override
  String get micFailed =>
      'Impossible d\'activer le micro. Vérifie l\'autorisation du micro.';

  @override
  String get chatNotFound =>
      'Cette discussion est introuvable ou tu ne peux plus la voir.';

  @override
  String get backToMessages => 'Retour aux messages';

  @override
  String get cantCallNow => 'Impossible d\'appeler pour l\'instant.';

  @override
  String get voiceCall => 'Appel vocal';

  @override
  String get groupChatAdminsOnly =>
      'Discussion de groupe · seuls les admins écrivent';

  @override
  String get groupChat => 'Discussion de groupe';

  @override
  String smallTableMembers(int count) {
    return 'Petite table · $count personnes';
  }

  @override
  String get adminsOnlyOn =>
      'Désormais, seuls le propriétaire et les admins peuvent écrire ici.';

  @override
  String get adminsOnlyOff =>
      'Désormais, tous les membres du groupe peuvent écrire ici.';

  @override
  String get chatSettings => 'Paramètres de la discussion';

  @override
  String get adminsOnlyToggle => 'Seuls les admins écrivent';

  @override
  String get sendingPhoto => '📷 Envoi de la photo…';

  @override
  String get requestPendingNote =>
      'Ta demande de message a été envoyée. Tant qu\'elle n\'est pas acceptée, tu ne vois pas si elle a été lue.';

  @override
  String get groupChatEmpty =>
      'Pas encore de message dans la discussion de groupe. Écris le premier.';

  @override
  String get chatEmpty => 'Pas encore de message. Écris le premier.';

  @override
  String get startWriting => 'Commencer à écrire';

  @override
  String get sending => 'Envoi…';

  @override
  String get seen => 'Vu';

  @override
  String get sent => 'Envoyé';

  @override
  String get seePackage => 'Voir la formule';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get messageRemoved => 'Ce message a été retiré.';

  @override
  String get thisMessageDeleted => 'Ce message a été supprimé.';

  @override
  String get messageOptions => 'Options du message';

  @override
  String profileOf(String name) {
    return 'Profil de $name';
  }

  @override
  String get you => 'Toi';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Message copié.';

  @override
  String get deleteForAll => 'Supprimer pour tous';

  @override
  String get report => 'Signaler';

  @override
  String get deleteForAllTitle => 'Supprimer le message pour tous ?';

  @override
  String get deleteForAllBody =>
      'Tout le monde verra « Ce message a été supprimé ». C’est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get requestDeleted => 'Demande de message supprimée.';

  @override
  String wantsToMessage(String name) {
    return '$name souhaite t’écrire. Si tu acceptes, vous pourrez discuter et la personne verra quand tu as lu.';
  }

  @override
  String get accept => 'Accepter';

  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get writeMessage => 'Écrire un message';

  @override
  String get send => 'Envoyer';

  @override
  String get messages => 'Messages';

  @override
  String get chats => 'Discussions';

  @override
  String get requests => 'Demandes';

  @override
  String requestsCount(int count) {
    return 'Demandes ($count)';
  }

  @override
  String get noChats =>
      'Tu n\'as pas encore de discussion. Tu peux écrire à tes matchs et coéquipiers.';

  @override
  String get findPeople => 'Trouver des personnes';

  @override
  String get oldRequestsNote =>
      'Les anciennes demandes restent ici. Les messages privés sont désormais réservés aux matchs et coéquipiers ; aucune nouvelle demande n\'arrive.';

  @override
  String get noRequests => 'Aucune demande de message en attente.';

  @override
  String get backToChats => 'Retour aux discussions';

  @override
  String get callRequests => 'Demandes d\'appels vocaux';

  @override
  String noPendingWithActive(int count) {
    return 'Aucune demande en attente · $count actives';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes en attente',
      one: '1 demande en attente',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'En attente';

  @override
  String get activeTab => 'Actives';

  @override
  String get requestsOwnersOnly =>
      'Seuls le propriétaire et les admins voient les demandes d\'appels.';

  @override
  String get goBack => 'Retour';

  @override
  String noPendingFor(String group) {
    return 'Aucune demande en attente. Les demandes des membres de $group apparaîtront ici.';
  }

  @override
  String get noActive => 'Ce groupe n\'a accordé aucun appel vocal.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get grantHint =>
      'Avec l\'autorisation accordée, la personne peut appeler tous ses matchs et coéquipiers. Les appels ne sont jamais enregistrés ; l\'autorisation prend fin si elle quitte le groupe.';

  @override
  String get granted => 'Appels vocaux activés.';

  @override
  String get turnedOff => 'Appels vocaux désactivés.';

  @override
  String theirNote(String note) {
    return 'Note : $note';
  }

  @override
  String get turnOff => 'Désactiver';

  @override
  String get turnOn => 'Activer';

  @override
  String get rankOnlyGrant =>
      'Son rang est égal ou supérieur au tien : tu peux seulement accepter cette demande.';

  @override
  String get rankCannotRevoke =>
      'Son rang est égal ou supérieur au tien : tu ne peux pas retirer cette autorisation.';

  @override
  String get declineRequest => 'Refuser la demande';

  @override
  String get turnOffCalls => 'Désactiver les appels vocaux';

  @override
  String get declineHint =>
      'La personne verra le motif et pourra refaire une demande après 7 jours.';

  @override
  String get revokeHint =>
      'Un appel en cours se termine aussitôt. La personne verra le motif et pourra redemander après 7 jours.';

  @override
  String get reason => 'Motif';

  @override
  String get reasonMin3 => 'Le motif doit contenir au moins 3 caractères.';

  @override
  String get yesterday => 'Hier';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get groupChatMembersOnly =>
      'Seuls les membres du groupe voient la discussion.';

  @override
  String get callVerifying => 'Vérification du chiffrement…';

  @override
  String get callSecure => 'Appel sécurisé';

  @override
  String get callSecureDetail =>
      'Chiffré de bout en bout. Les codes de sécurité des deux téléphones correspondent, personne ne s’est interposé.';

  @override
  String get callCheckFailed =>
      'Chiffrement non vérifié : les codes de sécurité des deux téléphones ne correspondent pas. Raccroche et rappelle.';

  @override
  String get showSecurityCode => 'Afficher le code de sécurité';
}
