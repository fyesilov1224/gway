// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LiveL10nDe extends LiveL10n {
  LiveL10nDe([String locale = 'de']) : super(locale);

  @override
  String get commentRate =>
      'Du hast in kurzer Zeit sehr viel kommentiert. Warte etwas und versuche es erneut.';

  @override
  String get mutedListenOnly =>
      'Du bist in dieser Gruppe stummgeschaltet und kannst nur zuhören.';

  @override
  String get cannotComment =>
      'Du kannst diesen Livestream gerade nicht kommentieren.';

  @override
  String get roleHost => 'Moderation';

  @override
  String get roleSpeaker => 'Sprecher:in';

  @override
  String get roleListener => 'Zuhörer:in';

  @override
  String get startLive => 'Live gehen';

  @override
  String hostedBy(String name) {
    return 'Moderiert von $name';
  }

  @override
  String get join => 'Beitreten';

  @override
  String upcomingAt(String date) {
    return 'Demnächst · $date';
  }

  @override
  String get scheduledCanceled => 'Geplanter Livestream abgesagt.';

  @override
  String get cancel => 'Absagen';

  @override
  String get start => 'Starten';

  @override
  String get reminderRemoved => 'Erinnerung entfernt.';

  @override
  String get reminderSet => 'Wir melden uns, wenn es losgeht.';

  @override
  String get reminding => 'Erinnerung an';

  @override
  String get remind => 'Erinnern';

  @override
  String get schedule5min =>
      'Ein geplanter Livestream muss mindestens 5 Minuten in der Zukunft liegen.';

  @override
  String get scheduled =>
      'Livestream geplant. Mitglieder können sich erinnern lassen.';

  @override
  String get liveBroadcast => 'Livestream';

  @override
  String get liveIntro =>
      'Gruppenmitglieder treten dem Audioraum bei; wer auf der Bühne ist, kann sprechen.';

  @override
  String get title => 'Titel';

  @override
  String get titleExample => 'Z. B. Planung der Sonntagswanderung';

  @override
  String get titleMin3 => 'Der Titel muss mindestens 3 Zeichen lang sein.';

  @override
  String get now => 'Jetzt';

  @override
  String get scheduleIt => 'Planen';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Livestream-Minuten diesen Monat.',
      one: 'Noch 1 Livestream-Minute diesen Monat.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'Die Livestream-Zeit für diesen Monat ist aufgebraucht. Mit einem größeren Paket bekommst du mehr.';

  @override
  String get startTheLive => 'Livestream starten';

  @override
  String get liveNow => 'Jetzt live';

  @override
  String trayLabel(String group, String title) {
    return '$group ist live: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Du bist im Livestream: $title. Tippe, um zurückzukehren.';
  }

  @override
  String get connecting => 'Verbindung zum Livestream…';

  @override
  String get inBroadcast => 'Du bist live · zum Zurückkehren tippen';

  @override
  String get micMutedByMod =>
      'Dein Mikro wurde von der Moderation ausgeschaltet';

  @override
  String get micOff => 'Mikro aus';

  @override
  String get micOn => 'Mikro an';

  @override
  String startsOn(String date) {
    return 'Dieser Livestream beginnt am $date.';
  }

  @override
  String get ended => 'Dieser Livestream ist beendet.';

  @override
  String get notFound =>
      'Dieser Livestream wurde nicht gefunden. Vielleicht musst du Mitglied der Gruppe sein.';

  @override
  String get goBack => 'Zurück';

  @override
  String get onStageNow =>
      'Du bist auf der Bühne. Schalte dein Mikro ein, um zu sprechen.';

  @override
  String get nowListener => 'Du bist jetzt Zuhörer:in.';

  @override
  String get leaveBroadcast => 'Livestream verlassen';

  @override
  String get leaveHostBody =>
      'Du kannst ihn für alle beenden. Wenn du nur gehst, endet er nach 2 Minuten von selbst.';

  @override
  String get justLeave => 'Nur verlassen';

  @override
  String get endBroadcast => 'Livestream beenden';

  @override
  String get inviteToStage => 'Auf die Bühne holen';

  @override
  String get removeFromStage => 'Von der Bühne holen';

  @override
  String get muteMic => 'Mikro ausschalten';

  @override
  String get unmuteMic => 'Mikro einschalten';

  @override
  String get kick => 'Aus dem Livestream entfernen';

  @override
  String kickBody(String name) {
    return '$name kann diesem Livestream nicht mehr beitreten.';
  }

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get raisedHands => 'Gemeldet';

  @override
  String get commentDeleted => 'Kommentar gelöscht.';

  @override
  String get thanksForJoining =>
      'Der Livestream ist beendet. Danke fürs Dabeisein.';

  @override
  String get youWereKicked => 'Du wurdest aus diesem Livestream entfernt.';

  @override
  String get connectFailedShort => 'Keine Verbindung zum Livestream.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meldungen',
      one: '1 Meldung',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'Auf der Bühne';

  @override
  String listeners(int count) {
    return 'Zuhörende · $count';
  }

  @override
  String get noListeners => 'Noch keine Zuhörenden.';

  @override
  String get minimize => 'Minimieren, im Livestream bleiben';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get broadcastOptions => 'Livestream-Optionen';

  @override
  String get endForAll => 'Für alle beenden';

  @override
  String get handRaised =>
      'Du hast dich gemeldet. Die Moderation kann dich auf die Bühne holen.';

  @override
  String get you => 'Du';

  @override
  String get speaking => 'spricht';

  @override
  String get micOffState => 'Mikro aus';

  @override
  String get handUp => 'gemeldet';

  @override
  String get sendReaction => 'Reaktion senden';

  @override
  String get leave => 'Verlassen';

  @override
  String get leaveStage => 'Bühne verlassen';

  @override
  String get reactions => 'Reaktionen';

  @override
  String get comments => 'Kommentare';

  @override
  String get raiseHand => 'Melden';

  @override
  String get lowerHand => 'Meldung zurücknehmen';

  @override
  String get report => 'Melden';

  @override
  String get deleteComment => 'Kommentar löschen';

  @override
  String get firstComment => 'Schreib den ersten Kommentar.';

  @override
  String get writeComment => 'Kommentar schreiben…';

  @override
  String get send => 'Senden';

  @override
  String get connectFailed =>
      'Keine Verbindung zum Livestream. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get participant => 'Teilnehmer:in';

  @override
  String get micNeedsManager =>
      'Nur die Moderation kann dein Mikro einschalten.';

  @override
  String get micFailed =>
      'Das Mikro konnte nicht eingeschaltet werden. Prüfe die Mikrofon-Berechtigung.';

  @override
  String get connectionLost =>
      'Die Verbindung zur Übertragung ist abgebrochen. Tippe, um dich neu zu verbinden.';

  @override
  String get micAfterEncryption =>
      'Die verschlüsselte Verbindung wird aufgebaut; dein Mikrofon schaltet sich gleich ein.';

  @override
  String get encrypting => 'Verschlüsselte Verbindung wird aufgebaut …';

  @override
  String get verifying => 'Verschlüsselung wird geprüft …';

  @override
  String get liveSecure => 'Sichere Übertragung';

  @override
  String get liveSecureDetail =>
      'Ende-zu-Ende-verschlüsselt. Alle im Raum nutzen denselben Schlüssel; niemand, auch nicht der Server, kann mithören.';

  @override
  String get liveCheckFailed =>
      'Verschlüsselung nicht bestätigt: Nicht alle im Raum nutzen denselben Schlüssel. Verlasse die Übertragung und tritt erneut bei.';

  @override
  String get liveUnconfirmed =>
      'Jemand auf der Bühne nutzt eine ältere App-Version; der Ton kann nicht verschlüsselt werden und wird nicht abgespielt.';

  @override
  String get peerUnencrypted =>
      'Ein Sprecher mit einer älteren Version sendet unverschlüsselten Ton; er wird nicht abgespielt. Die App muss aktualisiert werden.';

  @override
  String get e2ee => 'Ende-zu-Ende-verschlüsselt';

  @override
  String get showSecurityCode => 'Sicherheitscode anzeigen';

  @override
  String get codeMatchHint =>
      'Dieser Code ist auf allen Bildschirmen im Raum gleich.';

  @override
  String e2eeCode(String code) {
    return 'Ende-zu-Ende-verschlüsselt. Sicherheitscode $code';
  }

  @override
  String get liveOngoingTitle => 'Du bist in einer Live-Übertragung';

  @override
  String get liveOngoingText =>
      'Ende-zu-Ende-verschlüsselt. Tippe, um zurückzukehren.';
}
