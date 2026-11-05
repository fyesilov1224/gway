// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class NotificationsL10nIt extends NotificationsL10n {
  NotificationsL10nIt([String locale = 'it']) : super(locale);

  @override
  String get actLike => 'ha messo mi piace al tuo post.';

  @override
  String actComment(String text) {
    return 'ha commentato: $text';
  }

  @override
  String actReply(String text) {
    return 'ha risposto al tuo commento: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'ha messo mi piace al tuo commento: $text';
  }

  @override
  String get actMentionPost => 'ti ha menzionato in un post.';

  @override
  String actMentionComment(String text) {
    return 'ti ha menzionato in un commento: $text';
  }

  @override
  String get actFollow => 'ha iniziato a seguirti.';

  @override
  String get actFollowRequest => 'vuole seguirti.';

  @override
  String get actFollowAccepted => 'ha accettato la tua richiesta di follow.';

  @override
  String actLiveScheduled(String title) {
    return 'ha programmato una diretta: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'ha programmato una diretta per il $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'è in diretta: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Si è liberato un posto per «$title»: ora partecipi.';
  }

  @override
  String actEventUpdated(String title) {
    return 'ha cambiato l’orario o il luogo di «$title».';
  }

  @override
  String actEventCanceled(String title) {
    return 'ha annullato «$title».';
  }

  @override
  String actReminderTomorrow(String title) {
    return '«$title» inizia domani. Vieni? Conferma.';
  }

  @override
  String actReminderHour(String title) {
    return '«$title» inizia entro un’ora.';
  }

  @override
  String actCaseVote(String group) {
    return 'ha aperto un caso disciplinare in $group; serve il tuo voto.';
  }

  @override
  String get actMuted =>
      'ti ha silenziato. Tocca per i dettagli o per fare ricorso.';

  @override
  String get actKicked =>
      'ti ha rimosso dal gruppo. Tocca per i dettagli o per fare ricorso.';

  @override
  String get actBanned =>
      'ti ha bandito dal gruppo. Tocca per i dettagli o per fare ricorso.';

  @override
  String get actWarned =>
      'ti ha dato un avvertimento. Tocca per i dettagli o per fare ricorso.';

  @override
  String actAppealSubmitted(String group) {
    return 'ha fatto ricorso contro una sanzione in $group.';
  }

  @override
  String get actAppealDecided => 'ha deciso sul tuo ricorso.';

  @override
  String actEventApproved(String title) {
    return 'ha approvato la tua richiesta per «$title».';
  }

  @override
  String actEventDeclined(String title) {
    return 'non ha potuto accettare la tua richiesta per «$title».';
  }

  @override
  String actEventReview(String title) {
    return 'Com’è andato «$title»? Valutalo e condividi i ricordi.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Hai completato «$title»! Il badge è sul tuo profilo.';
  }

  @override
  String get actTeammateRequest => 'vuole essere tuo compagno di squadra.';

  @override
  String get actTeammateAccepted => 'ha accettato la tua richiesta di squadra.';

  @override
  String get actMatchCreated => 'Scopri chi è nei Miei match.';

  @override
  String get actSuperLiked =>
      'ti ha mandato un super like! Compare per primo nel tuo mazzo.';

  @override
  String actWelcomeRequested(String title) {
    return 'viene per la prima volta a «$title» e vorrebbe essere accolto.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'ti accoglierà a «$title». Guarda la nota di ritrovo.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'non potrà più accoglierti a «$title»; cerchiamo qualcun altro.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'ha ritirato la richiesta di accoglienza per «$title».';
  }

  @override
  String get actLeagueResult =>
      'è entrato tra i primi tre della lega il mese scorso! Guarda la classifica nella pagina del gruppo.';

  @override
  String actWelcomeThanked(String title) {
    return 'ti ha ringraziato per averlo accolto a «$title».';
  }

  @override
  String get actTableInvite =>
      'ha creato un piccolo tavolo stasera e ti invita.';

  @override
  String get actTableReady =>
      'si è unito al tavolo; è pronto. Decidete luogo e ora nella chat.';

  @override
  String actVenueRevealed(String title) {
    return '«$title»: tocca per vedere dove andare.';
  }

  @override
  String actHandshake(String title) {
    return 'ti ha stretto la mano a «$title».';
  }

  @override
  String get actCallMissed => 'ti ha chiamato; non hai risposto.';

  @override
  String get actCallGranted =>
      '— ora hai il permesso. Puoi chiamare i tuoi match dalla chat.';

  @override
  String get actCallDeclined =>
      '— per ora la tua richiesta non è stata approvata. Tocca per i dettagli.';

  @override
  String get actCallRevoked =>
      '— il tuo permesso è stato revocato. Tocca per i dettagli.';

  @override
  String actSeriesLimit(String title) {
    return '— non è stato possibile aprire la data successiva di «$title»: il gruppo ha raggiunto il limite mensile. Si aprirà a inizio mese o con un piano superiore.';
  }

  @override
  String get leadNewMatch => 'Hai un nuovo match!';

  @override
  String get leadSeries => 'Evento ricorrente';

  @override
  String get leadVenue => 'Luogo a sorpresa svelato';

  @override
  String get leadCalls => 'Chiamate vocali';

  @override
  String get periodToday => 'Oggi';

  @override
  String get periodWeek => 'Questa settimana';

  @override
  String get periodEarlier => 'In precedenza';

  @override
  String get agoNow => 'ora';

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
    return '$n g';
  }

  @override
  String get join => 'Partecipa';

  @override
  String get see => 'Vedi';

  @override
  String get prefsTitle => 'Preferenze di notifica';

  @override
  String get messages => 'Messaggi';

  @override
  String get directMessages => 'Messaggi diretti';

  @override
  String get directMessagesHint =>
      'Quando arriva un messaggio diretto, con suono anche ad app chiusa';

  @override
  String get groupMessages => 'Messaggi di gruppo';

  @override
  String get groupMessagesHint =>
      'Quando arrivano messaggi nelle chat di gruppo e al tavolo di stasera, con suono anche ad app chiusa';

  @override
  String get events => 'Eventi';

  @override
  String get remindDay => 'Ricorda 1 giorno prima';

  @override
  String get remindDayHint => 'Se un evento a cui partecipi inizia domani';

  @override
  String get remindHour => 'Ricorda 1 ora prima';

  @override
  String get remindHourHint =>
      'Se un evento a cui partecipi inizia entro un\'ora';

  @override
  String get changes => 'Modifiche e annullamenti';

  @override
  String get changesHint =>
      'Quando cambiano orario o luogo, o un evento viene annullato';

  @override
  String get reviewRequests => 'Richieste di recensione';

  @override
  String get reviewRequestsHint =>
      'Chiedere «Com\'è andata?» alla fine di un evento';

  @override
  String get live => 'Dirette';

  @override
  String get liveAlerts => 'Dirette programmate e iniziate';

  @override
  String get liveAlertsHint =>
      'Quando il tuo gruppo programma o avvia una diretta, con avviso sonoro se l\'app è aperta';

  @override
  String get matching => 'Match';

  @override
  String get newMatches => 'Nuovi match';

  @override
  String get newMatchesHint => 'Quando vi piacete a vicenda';

  @override
  String get alwaysSent =>
      'L\'esito delle richieste, l\'uscita dalla lista d\'attesa e le sanzioni di gruppo ti riguardano direttamente, quindi vengono sempre notificati.';

  @override
  String get notifications => 'Notifiche';

  @override
  String get empty => 'Qui compaiono mi piace, commenti e nuovi follower.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get followRequests => 'Richieste di follow';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'altre $count',
      one: '1 altra persona',
    );
    return '$name e $_temp0';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get actChessChallenge => 'ti ha sfidato a scacchi.';

  @override
  String actChessTeamInvite(String group) {
    return 'ha sfidato il tuo gruppo a un incontro di scacchi a squadre per $group.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return 'ha accettato l’incontro a squadre per $group. Schiera i tuoi giocatori.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return 'ha rifiutato l’incontro a squadre per $group.';
  }

  @override
  String actChessTeamStart(String group) {
    return 'L\'incontro a squadre contro $group è iniziato. Alla tua scacchiera!';
  }

  @override
  String get leadTeamMatch => 'Incontro a squadre';
}
