// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NotificationsL10nDe extends NotificationsL10n {
  NotificationsL10nDe([String locale = 'de']) : super(locale);

  @override
  String get actLike => 'gefällt dein Beitrag.';

  @override
  String actComment(String text) {
    return 'hat kommentiert: $text';
  }

  @override
  String actReply(String text) {
    return 'hat auf deinen Kommentar geantwortet: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'gefällt dein Kommentar: $text';
  }

  @override
  String get actMentionPost => 'hat dich in einem Beitrag erwähnt.';

  @override
  String actMentionComment(String text) {
    return 'hat dich in einem Kommentar erwähnt: $text';
  }

  @override
  String get actFollow => 'folgt dir jetzt.';

  @override
  String get actFollowRequest => 'möchte dir folgen.';

  @override
  String get actFollowAccepted => 'hat deine Follower-Anfrage angenommen.';

  @override
  String actLiveScheduled(String title) {
    return 'hat einen Livestream geplant: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'hat für $date einen Livestream geplant: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'ist jetzt live: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Für „$title“ ist ein Platz frei geworden – du bist jetzt dabei.';
  }

  @override
  String actEventUpdated(String title) {
    return 'hat Zeit oder Ort von „$title“ geändert.';
  }

  @override
  String actEventCanceled(String title) {
    return 'hat „$title“ abgesagt.';
  }

  @override
  String actReminderTomorrow(String title) {
    return '„$title“ beginnt morgen. Kommst du? Bestätige.';
  }

  @override
  String actReminderHour(String title) {
    return '„$title“ beginnt in weniger als einer Stunde.';
  }

  @override
  String actCaseVote(String group) {
    return 'hat in $group ein Disziplinarverfahren eröffnet; deine Stimme wird gebraucht.';
  }

  @override
  String get actMuted =>
      'hat dich stummgeschaltet. Tippe für Details oder Einspruch.';

  @override
  String get actKicked =>
      'hat dich aus der Gruppe entfernt. Tippe für Details oder Einspruch.';

  @override
  String get actBanned =>
      'hat dich aus der Gruppe gesperrt. Tippe für Details oder Einspruch.';

  @override
  String get actWarned =>
      'hat dich verwarnt. Tippe für Details oder Einspruch.';

  @override
  String actAppealSubmitted(String group) {
    return 'hat gegen eine Sanktion in $group Einspruch erhoben.';
  }

  @override
  String get actAppealDecided => 'hat über deinen Einspruch entschieden.';

  @override
  String actEventApproved(String title) {
    return 'hat deine Teilnahme an „$title“ bestätigt.';
  }

  @override
  String actEventDeclined(String title) {
    return 'konnte deine Anfrage für „$title“ nicht annehmen.';
  }

  @override
  String actEventReview(String title) {
    return 'Wie war „$title“? Bewerte es und teile Erinnerungen.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Du hast „$title“ geschafft! Dein Abzeichen ist im Profil.';
  }

  @override
  String get actTeammateRequest => 'möchte dein Teammitglied werden.';

  @override
  String get actTeammateAccepted => 'hat deine Teamanfrage angenommen.';

  @override
  String get actMatchCreated => 'Sieh in Meine Matches, wer es ist.';

  @override
  String get actSuperLiked =>
      'hat dir ein Super-Like gegeben! Die Person steht zuerst in deinem Stapel.';

  @override
  String actWelcomeRequested(String title) {
    return 'kommt zum ersten Mal zu „$title“ und möchte begrüßt werden.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'begrüßt dich bei „$title“. Sieh dir die Notiz an.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'kann dich bei „$title“ nicht mehr begrüßen; wir suchen jemand anderen.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'hat die Begrüßungsanfrage für „$title“ zurückgezogen.';
  }

  @override
  String get actLeagueResult =>
      'war letzten Monat unter den Top 3 der Liga! Sieh dir die Tabelle auf der Gruppenseite an.';

  @override
  String actWelcomeThanked(String title) {
    return 'hat sich bedankt, dass du sie bei „$title“ begrüßt hast.';
  }

  @override
  String get actTableInvite =>
      'hat heute Abend einen kleinen Tisch gebildet und lädt dich ein.';

  @override
  String get actTableReady =>
      'ist am Tisch dabei; er steht. Klärt Ort und Zeit im Chat.';

  @override
  String actVenueRevealed(String title) {
    return '„$title“: Tippe, um zu sehen, wohin es geht.';
  }

  @override
  String actHandshake(String title) {
    return 'hat dir bei „$title“ die Hand gegeben.';
  }

  @override
  String get actCallMissed => 'hat dich angerufen; du hast den Anruf verpasst.';

  @override
  String get actCallGranted =>
      '— du hast jetzt die Berechtigung. Du kannst deine Matches aus dem Chat anrufen.';

  @override
  String get actCallDeclined =>
      '— deine Anfrage wurde vorerst nicht angenommen. Tippe für Details.';

  @override
  String get actCallRevoked =>
      '— deine Berechtigung wurde entzogen. Tippe für Details.';

  @override
  String actSeriesLimit(String title) {
    return '— der nächste Termin für „$title“ konnte nicht geöffnet werden: Das Monatskontingent der Gruppe ist erschöpft. Er öffnet sich im neuen Monat oder mit einem größeren Paket.';
  }

  @override
  String get leadNewMatch => 'Du hast ein neues Match!';

  @override
  String get leadSeries => 'Wiederkehrendes Event';

  @override
  String get leadVenue => 'Überraschungsort verraten';

  @override
  String get leadCalls => 'Sprachanrufe';

  @override
  String get periodToday => 'Heute';

  @override
  String get periodWeek => 'Diese Woche';

  @override
  String get periodEarlier => 'Früher';

  @override
  String get agoNow => 'jetzt';

  @override
  String agoMinutes(int n) {
    return '$n Min.';
  }

  @override
  String agoHours(int n) {
    return '$n Std.';
  }

  @override
  String agoDays(int n) {
    return '$n T.';
  }

  @override
  String get join => 'Beitreten';

  @override
  String get see => 'Ansehen';

  @override
  String get prefsTitle => 'Benachrichtigungseinstellungen';

  @override
  String get messages => 'Nachrichten';

  @override
  String get directMessages => 'Direktnachrichten';

  @override
  String get directMessagesHint =>
      'Bei neuen Direktnachrichten, mit Ton auch bei geschlossener App';

  @override
  String get groupMessages => 'Gruppennachrichten';

  @override
  String get groupMessagesHint =>
      'Bei Nachrichten in Gruppenchats und am Tisch heute Abend, mit Ton auch bei geschlossener App';

  @override
  String get events => 'Events';

  @override
  String get remindDay => '1 Tag vorher erinnern';

  @override
  String get remindDayHint =>
      'Wenn ein Event, an dem du teilnimmst, morgen beginnt';

  @override
  String get remindHour => '1 Stunde vorher erinnern';

  @override
  String get remindHourHint =>
      'Wenn ein Event, an dem du teilnimmst, in einer Stunde beginnt';

  @override
  String get changes => 'Änderungen und Absagen';

  @override
  String get changesHint =>
      'Wenn sich Zeit oder Ort ändern oder ein Event abgesagt wird';

  @override
  String get reviewRequests => 'Bewertungsanfragen';

  @override
  String get reviewRequestsHint =>
      'Nach dem Ende eines Events „Wie war es?“ fragen';

  @override
  String get live => 'Livestreams';

  @override
  String get liveAlerts => 'Geplante und gestartete Livestreams';

  @override
  String get liveAlertsHint =>
      'Wenn deine Gruppe einen Livestream plant oder startet, mit Ton bei geöffneter App';

  @override
  String get matching => 'Matching';

  @override
  String get newMatches => 'Neue Matches';

  @override
  String get newMatchesHint => 'Wenn ihr euch gegenseitig liked';

  @override
  String get alwaysSent =>
      'Ergebnisse deiner Anfragen, das Nachrücken von der Warteliste und Gruppensanktionen betreffen dich direkt und werden immer gemeldet.';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get empty => 'Likes, Kommentare und neue Follower erscheinen hier.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get followRequests => 'Follower-Anfragen';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere',
      one: '1 weitere Person',
    );
    return '$name und $_temp0';
  }

  @override
  String get delete => 'Löschen';
}
