// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class ModerationL10nFr extends ModerationL10n {
  ModerationL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Tu as envoyé trop de signalements aujourd\'hui. Réessaie demain.';

  @override
  String get ruleTargetInvalid =>
      'Ce contenu n\'existe plus ou tu ne peux pas le voir.';

  @override
  String get ruleSelf =>
      'Tu ne peux pas te signaler toi-même ni ton propre contenu.';

  @override
  String get ruleAppealNotAllowed =>
      'Cette sanction ne peut plus faire l\'objet d\'un recours.';

  @override
  String get ruleDuplicate =>
      'Tu l\'as déjà signalé ; c\'est en cours d\'examen.';

  @override
  String get deletedAccount => 'Compte supprimé';

  @override
  String get reasonSpam => 'Spam ou trompeur';

  @override
  String get reasonHarassment => 'Harcèlement ou intimidation';

  @override
  String get reasonHate => 'Discours haineux';

  @override
  String get reasonViolence => 'Violence ou menace';

  @override
  String get reasonSexual => 'Contenu sexuel';

  @override
  String get reasonMisinformation => 'Fausse information';

  @override
  String get reasonOther => 'Autre';

  @override
  String get sanctionWarning => 'Avertissement';

  @override
  String get sanctionMute => 'Mise en sourdine';

  @override
  String get sanctionKick => 'Exclusion du groupe';

  @override
  String get sanctionBan => 'Bannissement';

  @override
  String get illegalViolence => 'Violence';

  @override
  String get illegalThreat => 'Menace';

  @override
  String get illegalInsult => 'Injure';

  @override
  String get illegalHate => 'Discours haineux';

  @override
  String get illegalSexual => 'Abus sexuel';

  @override
  String get illegalFraud => 'Escroquerie';

  @override
  String get illegalDrugs => 'Drogue';

  @override
  String get illegalTerror => 'Terrorisme';

  @override
  String get illegalOther => 'Autre infraction';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sourdine $days jours',
      one: 'Sourdine 1 jour',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Bannissement $days jours',
      one: 'Bannissement 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Bannissement définitif';

  @override
  String get thresholdMajority => 'Majorité simple';

  @override
  String get thresholdMajorityText => 'Plus de la moitié des votes';

  @override
  String get thresholdTwoThirds => 'Deux tiers';

  @override
  String get thresholdTwoThirdsText => 'Au moins deux tiers des votes';

  @override
  String get thresholdUnanimous => 'Unanimité';

  @override
  String get thresholdUnanimousText => 'Tous les votes';

  @override
  String get targetPost => 'Publication';

  @override
  String get targetComment => 'Commentaire';

  @override
  String get targetEvent => 'Événement';

  @override
  String get targetLiveComment => 'Commentaire en direct';

  @override
  String get targetMessage => 'Message de groupe';

  @override
  String get targetMember => 'Membre';

  @override
  String get appealPending => 'En attente de décision';

  @override
  String get appealUpheld => 'Sanction maintenue';

  @override
  String get appealOverturned => 'Sanction levée';

  @override
  String get banApplied => 'Bannissement appliqué.';

  @override
  String get banAppliedSuspended =>
      'Bannissement appliqué. Le compte de la personne est suspendu jusqu’à l’examen de la plateforme.';

  @override
  String get caseOpened => 'Dossier ouvert. Le conseil votera sous 72 heures.';

  @override
  String get openCaseTitle => 'Ouvrir un dossier disciplinaire';

  @override
  String caseAboutNow(String name) {
    return 'Concernant $name. Le bannissement s’applique tout de suite, sans vote du conseil.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Concernant $name. Le conseil de discipline vote ta proposition sous 72 heures.';
  }

  @override
  String get proposedSanction => 'Sanction proposée';

  @override
  String get duration => 'Durée';

  @override
  String get permanent => 'Définitif';

  @override
  String get permanentLower => 'définitif';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Appliquer tout de suite, sans vote';

  @override
  String get applyNowHint =>
      'Bannit sans attendre le conseil. La personne peut faire appel sous 7 jours.';

  @override
  String get illegalActivity => 'Activité illégale';

  @override
  String get illegalHintNow =>
      'Dès le bannissement, le dossier part à l\'équipe de la plateforme et le compte est suspendu jusqu\'à l\'examen. Ce marquage ne peut plus être modifié.';

  @override
  String get illegalHintVote =>
      'Si le conseil approuve, le dossier part à l\'équipe de la plateforme et le compte est suspendu jusqu\'à l\'examen. Ce marquage ne peut plus être modifié.';

  @override
  String get reason => 'Motif';

  @override
  String get reasonHintNow =>
      'Que s\'est-il passé ? La personne et qui examine l\'appel verront ce texte.';

  @override
  String get reasonHintVote =>
      'Que s\'est-il passé ? Le conseil votera sur la base de ce texte.';

  @override
  String get reasonMin10 => 'Le motif doit contenir au moins 10 caractères.';

  @override
  String get muteNow => 'Mettre en sourdine maintenant (24 heures)';

  @override
  String get muteNowHint =>
      'Jusqu’à la décision du conseil, la personne ne peut ni commenter ni parler en direct.';

  @override
  String get ban => 'Bannir';

  @override
  String get openCase => 'Ouvrir le dossier';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days j $hours h';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'quelques minutes';

  @override
  String minChars(int min) {
    return 'Écris au moins $min caractères.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get threshold => 'Seuil de décision du conseil';

  @override
  String thresholdChanged(String threshold) {
    return 'Le seuil est désormais « $threshold ». Il s’applique aux nouveaux dossiers.';
  }

  @override
  String moderationOf(String group) {
    return 'Modération · $group';
  }

  @override
  String get reports => 'Signalements';

  @override
  String reportsCount(int count) {
    return 'Signalements ($count)';
  }

  @override
  String get cases => 'Dossiers';

  @override
  String casesCount(int count) {
    return 'Dossiers ($count)';
  }

  @override
  String get sanctions => 'Sanctions';

  @override
  String sanctionsCount(int count) {
    return 'Sanctions ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Seuls le propriétaire et l’équipe de modération voient la modération de ce groupe.';

  @override
  String get goBack => 'Retour';

  @override
  String get noReports =>
      'Aucun signalement ouvert. Les signalements des membres arrivent ici.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get removeContent => 'Retirer le contenu';

  @override
  String get remove => 'Retirer';

  @override
  String get contentRemoved => 'Contenu retiré.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '1 signalement',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Voir';

  @override
  String get reportDismissed => 'Signalement rejeté.';

  @override
  String get dismiss => 'Rejeter';

  @override
  String get openCaseShort => 'Ouvrir un dossier';

  @override
  String get rankOnlyDismiss =>
      'Le rang de cette personne n\'est pas inférieur au tien : tu peux seulement rejeter.';

  @override
  String get noCases =>
      'Aucun dossier disciplinaire. Ils s’ouvrent depuis un signalement ou la page des membres.';

  @override
  String get voteApproved =>
      'Ton vote est enregistré. Le conseil a approuvé la sanction ; elle est appliquée.';

  @override
  String get voteRejected =>
      'Ton vote est enregistré. Le conseil a rejeté la sanction.';

  @override
  String get voteSaved =>
      'Ton vote est enregistré. Tu peux le modifier jusqu’à la décision.';

  @override
  String get statusVoting => 'Vote en cours';

  @override
  String get statusApproved => 'Approuvé';

  @override
  String get statusRejected => 'Rejeté';

  @override
  String proposed(String sanction) {
    return 'Proposé : $sanction';
  }

  @override
  String get directBan => 'Bannissement sans vote';

  @override
  String illegalLabel(String category) {
    return 'Activité illégale : $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals pour · $rejections contre · $voters votants';
  }

  @override
  String votingEndsIn(String time) {
    return 'Le vote se termine dans $time';
  }

  @override
  String bannedBy(String name) {
    return 'Banni par : $name';
  }

  @override
  String openedBy(String name) {
    return 'Ouvert par : $name';
  }

  @override
  String get approve => 'Approuver';

  @override
  String get reject => 'Rejeter';

  @override
  String get noSanctions =>
      'Aucune sanction. Les sanctions approuvées et les appels apparaissent ici.';

  @override
  String get liftSanction => 'Lever la sanction';

  @override
  String get keepSanction => 'Maintenir la sanction';

  @override
  String get noteToPerson => 'Note pour la personne (facultatif)';

  @override
  String get liftedNotified => 'Sanction levée ; la personne a été prévenue.';

  @override
  String get appealRejectedNotified =>
      'Appel rejeté ; la personne a été prévenue.';

  @override
  String get lifted => 'Levée';

  @override
  String get interimMute => 'Sourdine d\'urgence';

  @override
  String get running => 'En cours';

  @override
  String get applied => 'Appliquée';

  @override
  String get interimUntilDecision =>
      'Sourdine d\'urgence · jusqu\'à la décision du conseil';

  @override
  String until(String date) {
    return 'jusqu\'au $date';
  }

  @override
  String appealLine(String status) {
    return 'Appel · $status';
  }

  @override
  String noteLine(String note) {
    return 'Note : $note';
  }

  @override
  String get ownerParty =>
      'Le propriétaire étant partie au dossier, l’équipe de la plateforme examine l’appel.';

  @override
  String get keep => 'Maintenir';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers attendent ton vote',
      one: '1 dossier attend ton vote',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appels',
      one: '1 appel',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Modération';

  @override
  String get noWork => 'Rien en attente';

  @override
  String get mySanctions => 'Mes sanctions';

  @override
  String get noMySanctions =>
      'Aucune sanction dans aucun groupe. Merci de respecter les règles de la communauté.';

  @override
  String get interimEnded => 'Sourdine d\'urgence terminée';

  @override
  String interimLatest(String date) {
    return 'Sourdine d\'urgence · jusqu\'à la décision du conseil, au plus tard le $date';
  }

  @override
  String untilCap(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String get ended => 'Terminée';

  @override
  String get appeal => 'Faire appel';

  @override
  String get appealHint => 'Pourquoi penses-tu que c’est injuste ?';

  @override
  String get send => 'Envoyer';

  @override
  String get appealSent =>
      'Ton appel a été envoyé. Tu seras prévenu(e) de la décision.';

  @override
  String reasonLine(String reason) {
    return 'Motif : $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Ton appel · $status';
  }

  @override
  String get appealOnce => 'Tu peux faire appel une fois sous 7 jours.';

  @override
  String get reportPost => 'Signaler la publication';

  @override
  String get reportComment => 'Signaler le commentaire';

  @override
  String get reportEvent => 'Signaler l\'événement';

  @override
  String get reportMessage => 'Signaler le message';

  @override
  String get reportMatchProfile => 'Signaler le profil de rencontre';

  @override
  String get reportPhoto => 'Signaler la photo';

  @override
  String get reportUser => 'Signaler l\'utilisateur';

  @override
  String get reportReceived =>
      'Ton signalement a bien été reçu. Nous allons l’examiner et agir ; ton identité n’est pas montrée à la personne signalée.';

  @override
  String get whyReport => 'Pourquoi signales-tu ceci ?';

  @override
  String get detailsOptional => 'Détails (facultatif)';

  @override
  String get detailsHint => 'Décris brièvement ce qui s\'est passé.';

  @override
  String get report => 'Signaler';
}
