// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class NotificationsL10nFr extends NotificationsL10n {
  NotificationsL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get actLike => 'a aimé ta publication.';

  @override
  String actComment(String text) {
    return 'a commenté : $text';
  }

  @override
  String actReply(String text) {
    return 'a répondu à ton commentaire : $text';
  }

  @override
  String actCommentLike(String text) {
    return 'a aimé ton commentaire : $text';
  }

  @override
  String get actMentionPost => 't\'a mentionné(e) dans une publication.';

  @override
  String actMentionComment(String text) {
    return 't\'a mentionné(e) dans un commentaire : $text';
  }

  @override
  String get actFollow => 's\'est abonné(e) à toi.';

  @override
  String get actFollowRequest => 'souhaite s’abonner à toi.';

  @override
  String get actFollowAccepted => 'a accepté ta demande d\'abonnement.';

  @override
  String actLiveScheduled(String title) {
    return 'a programmé un direct : $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'a programmé un direct le $date : $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'est en direct : $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Une place s’est libérée pour « $title » : tu participes maintenant.';
  }

  @override
  String actEventUpdated(String title) {
    return 'a modifié l’heure ou le lieu de « $title ».';
  }

  @override
  String actEventCanceled(String title) {
    return 'a annulé « $title ».';
  }

  @override
  String actReminderTomorrow(String title) {
    return '« $title » commence demain. Tu viens ? Confirme.';
  }

  @override
  String actReminderHour(String title) {
    return '« $title » commence dans moins d’une heure.';
  }

  @override
  String actCaseVote(String group) {
    return 'a ouvert un dossier disciplinaire dans $group ; ton vote est attendu.';
  }

  @override
  String get actMuted =>
      't\'a mis(e) en sourdine. Touche pour les détails ou pour faire appel.';

  @override
  String get actKicked =>
      't\'a retiré(e) du groupe. Touche pour les détails ou pour faire appel.';

  @override
  String get actBanned =>
      't\'a banni(e) du groupe. Touche pour les détails ou pour faire appel.';

  @override
  String get actWarned =>
      't\'a donné un avertissement. Touche pour les détails ou pour faire appel.';

  @override
  String actAppealSubmitted(String group) {
    return 'a fait appel d’une sanction dans $group.';
  }

  @override
  String get actAppealDecided => 'a statué sur ton appel.';

  @override
  String actEventApproved(String title) {
    return 'a validé ta demande pour « $title ».';
  }

  @override
  String actEventDeclined(String title) {
    return 'n\'a pas pu accepter ta demande pour « $title ».';
  }

  @override
  String actEventReview(String title) {
    return 'Comment était « $title » ? Note-le et partage tes souvenirs.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Tu as atteint « $title » ! Ton badge est sur ton profil.';
  }

  @override
  String get actTeammateRequest => 'veut être ton coéquipier.';

  @override
  String get actTeammateAccepted => 'a accepté ta demande de coéquipier.';

  @override
  String get actMatchCreated => 'Découvre qui c’est dans Mes matchs.';

  @override
  String get actSuperLiked =>
      't\'a envoyé un super like ! Cette personne apparaît en premier.';

  @override
  String actWelcomeRequested(String title) {
    return 'vient pour la première fois à « $title » et aimerait être accueilli(e).';
  }

  @override
  String actWelcomeMatched(String title) {
    return 't’accueillera à « $title ». Consulte la note de rendez-vous.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'ne peut plus t’accueillir à « $title » ; nous cherchons quelqu’un d’autre.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'a retiré sa demande d’accueil pour « $title ».';
  }

  @override
  String get actLeagueResult =>
      'a fini dans le top 3 de la ligue le mois dernier ! Consulte le classement sur la page du groupe.';

  @override
  String actWelcomeThanked(String title) {
    return 't’a remercié(e) de l’avoir accueilli(e) à « $title ».';
  }

  @override
  String get actTableInvite => 'a monté une petite table ce soir et t’invite.';

  @override
  String get actTableReady =>
      'a rejoint la table ; elle est prête. Convenez du lieu et de l’heure dans la discussion.';

  @override
  String actVenueRevealed(String title) {
    return '« $title » : touche pour voir où aller.';
  }

  @override
  String actHandshake(String title) {
    return 'a échangé une poignée de main avec toi à « $title ».';
  }

  @override
  String get actCallMissed => 't\'a appelé(e) ; tu n\'as pas répondu.';

  @override
  String get actCallGranted =>
      '— tu as maintenant l’autorisation. Tu peux appeler tes matchs depuis la discussion.';

  @override
  String get actCallDeclined =>
      '— ta demande n’a pas été acceptée pour l’instant. Touche pour les détails.';

  @override
  String get actCallRevoked =>
      '— ton autorisation a été retirée. Touche pour les détails.';

  @override
  String actSeriesLimit(String title) {
    return '— la prochaine date de « $title » n’a pas pu s’ouvrir : le quota mensuel du groupe est atteint. Elle s’ouvrira au début du mois ou avec une formule supérieure.';
  }

  @override
  String get leadNewMatch => 'Tu as un nouveau match !';

  @override
  String get leadSeries => 'Événement récurrent';

  @override
  String get leadVenue => 'Lieu surprise révélé';

  @override
  String get leadCalls => 'Appels vocaux';

  @override
  String get periodToday => 'Aujourd\'hui';

  @override
  String get periodWeek => 'Cette semaine';

  @override
  String get periodEarlier => 'Plus tôt';

  @override
  String get agoNow => 'à l\'instant';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n h';
  }

  @override
  String agoDays(int n) {
    return '$n j';
  }

  @override
  String get join => 'Rejoindre';

  @override
  String get see => 'Voir';

  @override
  String get prefsTitle => 'Préférences de notification';

  @override
  String get messages => 'Messages';

  @override
  String get directMessages => 'Messages privés';

  @override
  String get directMessagesHint =>
      'À chaque message privé, avec son même quand l\'app est fermée';

  @override
  String get groupMessages => 'Messages de groupe';

  @override
  String get groupMessagesHint =>
      'À chaque message de groupe ou de la table du soir, avec son même quand l\'app est fermée';

  @override
  String get events => 'Événements';

  @override
  String get remindDay => 'Me rappeler la veille';

  @override
  String get remindDayHint =>
      'Si un événement auquel tu participes commence demain';

  @override
  String get remindHour => 'Me rappeler 1 heure avant';

  @override
  String get remindHourHint =>
      'Si un événement auquel tu participes commence dans l\'heure';

  @override
  String get changes => 'Modifications et annulations';

  @override
  String get changesHint =>
      'Quand l\'heure ou le lieu change, ou qu\'un événement est annulé';

  @override
  String get reviewRequests => 'Demandes d\'avis';

  @override
  String get reviewRequestsHint =>
      'Demander « C\'était comment ? » après un événement';

  @override
  String get live => 'Directs';

  @override
  String get liveAlerts => 'Directs programmés et lancés';

  @override
  String get liveAlertsHint =>
      'Quand ton groupe programme ou lance un direct, avec alerte sonore si l\'app est ouverte';

  @override
  String get matching => 'Rencontres';

  @override
  String get newMatches => 'Nouveaux matchs';

  @override
  String get newMatchesHint => 'Quand vous vous aimez mutuellement';

  @override
  String get alwaysSent =>
      'Le résultat de tes demandes, ta montée depuis une liste d\'attente et les sanctions de groupe te concernent directement ; ils sont toujours notifiés.';

  @override
  String get notifications => 'Notifications';

  @override
  String get empty =>
      'Les j\'aime, commentaires et nouveaux abonnés apparaissent ici.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get followRequests => 'Demandes d\'abonnement';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres',
      one: '1 autre personne',
    );
    return '$name et $_temp0';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get actChessChallenge => 't\'a défié aux échecs.';

  @override
  String actChessTeamInvite(String group) {
    return 'a invité ton groupe à un match d’échecs par équipes au nom de $group.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return 'a accepté le match par équipes pour $group. Compose ton équipe.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return 'a refusé le match par équipes pour $group.';
  }

  @override
  String actChessTeamStart(String group) {
    return 'Le match par équipes contre $group a commencé. À ton échiquier !';
  }

  @override
  String get leadTeamMatch => 'Match par équipes';
}
