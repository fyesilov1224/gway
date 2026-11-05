// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class NotificationsL10nNl extends NotificationsL10n {
  NotificationsL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get actLike => 'vindt je bericht leuk.';

  @override
  String actComment(String text) {
    return 'reageerde: $text';
  }

  @override
  String actReply(String text) {
    return 'antwoordde op je reactie: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'vindt je reactie leuk: $text';
  }

  @override
  String get actMentionPost => 'noemde je in een bericht.';

  @override
  String actMentionComment(String text) {
    return 'noemde je in een reactie: $text';
  }

  @override
  String get actFollow => 'volgt je nu.';

  @override
  String get actFollowRequest => 'wil je volgen.';

  @override
  String get actFollowAccepted => 'heeft je volgverzoek geaccepteerd.';

  @override
  String actLiveScheduled(String title) {
    return 'heeft een livestream gepland: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'heeft een livestream gepland op $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'is nu live: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Er kwam een plek vrij voor ‘$title’ — je doet nu mee.';
  }

  @override
  String actEventUpdated(String title) {
    return 'heeft de tijd of plaats van ‘$title’ gewijzigd.';
  }

  @override
  String actEventCanceled(String title) {
    return 'heeft ‘$title’ geannuleerd.';
  }

  @override
  String actReminderTomorrow(String title) {
    return '‘$title’ begint morgen. Kom je? Bevestig.';
  }

  @override
  String actReminderHour(String title) {
    return '‘$title’ begint binnen een uur.';
  }

  @override
  String actCaseVote(String group) {
    return 'heeft in $group een tuchtzaak geopend; je stem is nodig.';
  }

  @override
  String get actMuted => 'heeft je gedempt. Tik voor details of bezwaar.';

  @override
  String get actKicked =>
      'heeft je uit de groep verwijderd. Tik voor details of bezwaar.';

  @override
  String get actBanned =>
      'heeft je uit de groep verbannen. Tik voor details of bezwaar.';

  @override
  String get actWarned =>
      'heeft je een waarschuwing gegeven. Tik voor details of bezwaar.';

  @override
  String actAppealSubmitted(String group) {
    return 'maakte bezwaar tegen een sanctie in $group.';
  }

  @override
  String get actAppealDecided => 'heeft over je bezwaar beslist.';

  @override
  String actEventApproved(String title) {
    return 'heeft je aanvraag voor ‘$title’ goedgekeurd.';
  }

  @override
  String actEventDeclined(String title) {
    return 'kon je aanvraag voor ‘$title’ niet accepteren.';
  }

  @override
  String actEventReview(String title) {
    return 'Hoe was ‘$title’? Beoordeel het en deel je herinneringen.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Je hebt ‘$title’ gehaald! Je badge staat op je profiel.';
  }

  @override
  String get actTeammateRequest => 'wil je teamgenoot worden.';

  @override
  String get actTeammateAccepted => 'heeft je teamverzoek geaccepteerd.';

  @override
  String get actMatchCreated => 'Bekijk in Mijn matches wie het is.';

  @override
  String get actSuperLiked =>
      'gaf je een superlike! Diegene staat bovenaan je stapel.';

  @override
  String actWelcomeRequested(String title) {
    return 'komt voor het eerst naar ‘$title’ en wil verwelkomd worden.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'verwelkomt je bij ‘$title’. Bekijk de ontmoetingsnotitie.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'kan je bij ‘$title’ niet meer verwelkomen; we zoeken iemand anders.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'heeft het verzoek voor ‘$title’ ingetrokken.';
  }

  @override
  String get actLeagueResult =>
      'eindigde vorige maand in de top 3 van de competitie! Bekijk de stand op de groepspagina.';

  @override
  String actWelcomeThanked(String title) {
    return 'bedankte je voor de verwelkoming bij ‘$title’.';
  }

  @override
  String get actTableInvite =>
      'heeft vanavond een kleine tafel opgezet en nodigt je uit.';

  @override
  String get actTableReady =>
      'zit aan tafel; de tafel staat. Spreek plaats en tijd af in de chat.';

  @override
  String actVenueRevealed(String title) {
    return '‘$title’: tik om te zien waar je heen gaat.';
  }

  @override
  String actHandshake(String title) {
    return 'schudde je de hand bij ‘$title’.';
  }

  @override
  String get actCallMissed => 'belde je; je hebt het gemist.';

  @override
  String get actCallGranted =>
      '— je hebt nu toestemming. Je kunt je matches vanuit de chat bellen.';

  @override
  String get actCallDeclined =>
      '— je verzoek is voorlopig niet goedgekeurd. Tik voor details.';

  @override
  String get actCallRevoked =>
      '— je toestemming is ingetrokken. Tik voor details.';

  @override
  String actSeriesLimit(String title) {
    return '— de volgende datum van ‘$title’ kon niet openen: het maandmaximum van de groep is bereikt. Hij opent in de nieuwe maand of na een upgrade.';
  }

  @override
  String get leadNewMatch => 'Je hebt een nieuwe match!';

  @override
  String get leadSeries => 'Terugkerend evenement';

  @override
  String get leadVenue => 'Verrassingslocatie onthuld';

  @override
  String get leadCalls => 'Spraakoproepen';

  @override
  String get periodToday => 'Vandaag';

  @override
  String get periodWeek => 'Deze week';

  @override
  String get periodEarlier => 'Eerder';

  @override
  String get agoNow => 'nu';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n u';
  }

  @override
  String agoDays(int n) {
    return '$n d';
  }

  @override
  String get join => 'Meedoen';

  @override
  String get see => 'Bekijken';

  @override
  String get prefsTitle => 'Meldingsvoorkeuren';

  @override
  String get messages => 'Berichten';

  @override
  String get directMessages => 'Privéberichten';

  @override
  String get directMessagesHint =>
      'Bij een privébericht, met geluid ook als de app dicht is';

  @override
  String get groupMessages => 'Groepsberichten';

  @override
  String get groupMessagesHint =>
      'Bij berichten in groepschats en de tafel van vanavond, met geluid ook als de app dicht is';

  @override
  String get events => 'Evenementen';

  @override
  String get remindDay => '1 dag vooraf herinneren';

  @override
  String get remindDayHint =>
      'Als een evenement waaraan je meedoet morgen begint';

  @override
  String get remindHour => '1 uur vooraf herinneren';

  @override
  String get remindHourHint =>
      'Als een evenement waaraan je meedoet binnen een uur begint';

  @override
  String get changes => 'Wijzigingen en annuleringen';

  @override
  String get changesHint =>
      'Als de tijd of plaats verandert of een evenement wordt geannuleerd';

  @override
  String get reviewRequests => 'Beoordelingsverzoeken';

  @override
  String get reviewRequestsHint => 'Na afloop vragen ‘Hoe was het?’';

  @override
  String get live => 'Livestreams';

  @override
  String get liveAlerts => 'Geplande en gestarte livestreams';

  @override
  String get liveAlertsHint =>
      'Als je groep een livestream plant of start, met geluid als de app open is';

  @override
  String get matching => 'Matchen';

  @override
  String get newMatches => 'Nieuwe matches';

  @override
  String get newMatchesHint => 'Als jullie elkaar leuk vinden';

  @override
  String get alwaysSent =>
      'De uitkomst van je verzoeken, doorschuiven van de wachtlijst en groepssancties gaan je direct aan en worden altijd gemeld.';

  @override
  String get notifications => 'Meldingen';

  @override
  String get empty => 'Likes, reacties en nieuwe volgers verschijnen hier.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get followRequests => 'Volgverzoeken';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anderen',
      one: '1 ander',
    );
    return '$name en $_temp0';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String get actChessChallenge => 'heeft je uitgedaagd voor een partij schaak.';

  @override
  String actChessTeamInvite(String group) {
    return 'heeft je groep namens $group uitgedaagd voor een teamwedstrijd schaak.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return 'heeft de teamwedstrijd namens $group geaccepteerd. Stel je spelers op.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return 'heeft de teamwedstrijd namens $group geweigerd.';
  }

  @override
  String actChessTeamStart(String group) {
    return 'De teamwedstrijd tegen $group is begonnen. Naar je bord!';
  }

  @override
  String get leadTeamMatch => 'Teamwedstrijd';

  @override
  String get actChessArenaStart =>
      'Het toernooi waarvoor je je hebt aangemeld is begonnen. Open het en je wordt meteen gekoppeld.';

  @override
  String get actChessArenaMedal =>
      'Je eindigde bij de eerste drie! Je medaille staat in je schaakprofiel.';

  @override
  String get leadArena => 'Schaaktoernooi';

  @override
  String get actMindChallenge => 'heeft je uitgedaagd voor een Breinduel.';

  @override
  String actMindTeamInvite(String group) {
    return 'heeft je groep namens $group uitgedaagd voor een Breinduel.';
  }

  @override
  String actMindTeamAccepted(String group) {
    return 'heeft het groepsduel namens $group geaccepteerd. Stel je spelers op.';
  }

  @override
  String actMindTeamDeclined(String group) {
    return 'heeft het groepsduel namens $group afgewezen.';
  }

  @override
  String actMindTeamStart(String group) {
    return 'Het groepsduel tegen $group is begonnen. Naar je duel!';
  }

  @override
  String get leadGroupDuel => 'Groepsduel';
}
