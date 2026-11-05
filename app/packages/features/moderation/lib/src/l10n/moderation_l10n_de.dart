// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ModerationL10nDe extends ModerationL10n {
  ModerationL10nDe([String locale = 'de']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Du hast heute zu viele Meldungen gesendet. Versuch es morgen wieder.';

  @override
  String get ruleTargetInvalid =>
      'Dieser Inhalt existiert nicht mehr oder ist für dich nicht sichtbar.';

  @override
  String get ruleSelf =>
      'Du kannst dich selbst oder deine eigenen Inhalte nicht melden.';

  @override
  String get ruleAppealNotAllowed =>
      'Gegen diese Sanktion ist kein Einspruch mehr möglich.';

  @override
  String get ruleDuplicate => 'Du hast das bereits gemeldet; es wird geprüft.';

  @override
  String get deletedAccount => 'Gelöschtes Konto';

  @override
  String get reasonSpam => 'Spam oder irreführend';

  @override
  String get reasonHarassment => 'Belästigung oder Mobbing';

  @override
  String get reasonHate => 'Hassrede';

  @override
  String get reasonViolence => 'Gewalt oder Drohung';

  @override
  String get reasonSexual => 'Sexuelle Inhalte';

  @override
  String get reasonMisinformation => 'Falschinformation';

  @override
  String get reasonOther => 'Sonstiges';

  @override
  String get sanctionWarning => 'Verwarnung';

  @override
  String get sanctionMute => 'Stummschaltung';

  @override
  String get sanctionKick => 'Entfernung aus der Gruppe';

  @override
  String get sanctionBan => 'Sperre';

  @override
  String get illegalViolence => 'Gewalt';

  @override
  String get illegalThreat => 'Drohung';

  @override
  String get illegalInsult => 'Beleidigung';

  @override
  String get illegalHate => 'Hassrede';

  @override
  String get illegalSexual => 'Sexueller Missbrauch';

  @override
  String get illegalFraud => 'Betrug';

  @override
  String get illegalDrugs => 'Drogen';

  @override
  String get illegalTerror => 'Terrorismus';

  @override
  String get illegalOther => 'Andere Straftat';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage stumm',
      one: '1 Tag stumm',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage Sperre',
      one: '1 Tag Sperre',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Dauerhafte Sperre';

  @override
  String get thresholdMajority => 'Einfache Mehrheit';

  @override
  String get thresholdMajorityText => 'Mehr als die Hälfte der Stimmen';

  @override
  String get thresholdTwoThirds => 'Zwei Drittel';

  @override
  String get thresholdTwoThirdsText => 'Mindestens zwei Drittel der Stimmen';

  @override
  String get thresholdUnanimous => 'Einstimmig';

  @override
  String get thresholdUnanimousText => 'Alle Stimmen';

  @override
  String get targetPost => 'Beitrag';

  @override
  String get targetComment => 'Kommentar';

  @override
  String get targetEvent => 'Event';

  @override
  String get targetLiveComment => 'Live-Kommentar';

  @override
  String get targetMessage => 'Gruppenchat-Nachricht';

  @override
  String get targetMember => 'Mitglied';

  @override
  String get appealPending => 'Entscheidung ausstehend';

  @override
  String get appealUpheld => 'Sanktion bleibt';

  @override
  String get appealOverturned => 'Sanktion aufgehoben';

  @override
  String get banApplied => 'Sperre verhängt.';

  @override
  String get banAppliedSuspended =>
      'Sperre verhängt. Das Konto der Person ist bis zur Prüfung durch die Plattform gesperrt.';

  @override
  String get caseOpened =>
      'Fall eröffnet. Das Gremium stimmt innerhalb von 72 Stunden ab.';

  @override
  String get openCaseTitle => 'Disziplinarfall eröffnen';

  @override
  String caseAboutNow(String name) {
    return 'Betrifft $name. Die Sperre gilt sofort, ohne Abstimmung des Gremiums.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Betrifft $name. Das Disziplinargremium stimmt innerhalb von 72 Stunden über deinen Vorschlag ab.';
  }

  @override
  String get proposedSanction => 'Vorgeschlagene Sanktion';

  @override
  String get duration => 'Dauer';

  @override
  String get permanent => 'Dauerhaft';

  @override
  String get permanentLower => 'dauerhaft';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Sofort ohne Abstimmung';

  @override
  String get applyNowHint =>
      'Sperrt, ohne auf das Gremium zu warten. Die Person kann innerhalb von 7 Tagen Einspruch einlegen.';

  @override
  String get illegalActivity => 'Illegale Aktivität';

  @override
  String get illegalHintNow =>
      'Sobald die Sperre gilt, geht der Fall an das Plattform-Team und das Konto wird bis zur Prüfung gesperrt. Diese Markierung lässt sich später nicht ändern.';

  @override
  String get illegalHintVote =>
      'Stimmt das Gremium zu, geht der Fall an das Plattform-Team und das Konto wird bis zur Prüfung gesperrt. Diese Markierung lässt sich später nicht ändern.';

  @override
  String get reason => 'Begründung';

  @override
  String get reasonHintNow =>
      'Was ist passiert? Die Person und wer einen Einspruch prüft, sehen diesen Text.';

  @override
  String get reasonHintVote =>
      'Was ist passiert? Das Gremium stimmt anhand dieses Textes ab.';

  @override
  String get reasonMin10 => 'Die Begründung muss mindestens 10 Zeichen haben.';

  @override
  String get muteNow => 'Sofort stummschalten (24 Stunden)';

  @override
  String get muteNowHint =>
      'Bis das Gremium entscheidet, kann die Person nicht kommentieren und nicht live sprechen.';

  @override
  String get ban => 'Sperren';

  @override
  String get openCase => 'Fall eröffnen';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days T. $hours Std.';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'wenigen Minuten';

  @override
  String minChars(int min) {
    return 'Schreib mindestens $min Zeichen.';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get threshold => 'Entscheidungsschwelle des Gremiums';

  @override
  String thresholdChanged(String threshold) {
    return 'Die Schwelle ist jetzt „$threshold“. Sie gilt für neue Fälle.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderation · $group';
  }

  @override
  String get reports => 'Meldungen';

  @override
  String reportsCount(int count) {
    return 'Meldungen ($count)';
  }

  @override
  String get cases => 'Fälle';

  @override
  String casesCount(int count) {
    return 'Fälle ($count)';
  }

  @override
  String get sanctions => 'Sanktionen';

  @override
  String sanctionsCount(int count) {
    return 'Sanktionen ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Die Moderation dieser Gruppe sehen nur Inhaber:in und Moderationsteam.';

  @override
  String get goBack => 'Zurück';

  @override
  String get noReports =>
      'Keine offenen Meldungen. Meldungen der Mitglieder landen hier.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get removeContent => 'Inhalt entfernen';

  @override
  String get remove => 'Entfernen';

  @override
  String get contentRemoved => 'Inhalt entfernt.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meldungen',
      one: '1 Meldung',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Ansehen';

  @override
  String get reportDismissed => 'Meldung abgelehnt.';

  @override
  String get dismiss => 'Ablehnen';

  @override
  String get openCaseShort => 'Fall eröffnen';

  @override
  String get rankOnlyDismiss =>
      'Der Rang dieser Person ist nicht niedriger als deiner; du kannst nur ablehnen.';

  @override
  String get noCases =>
      'Noch keine Disziplinarfälle. Fälle werden aus einer Meldung oder der Mitgliederseite eröffnet.';

  @override
  String get voteApproved =>
      'Deine Stimme wurde gespeichert. Das Gremium hat die Sanktion bestätigt; sie wurde verhängt.';

  @override
  String get voteRejected =>
      'Deine Stimme wurde gespeichert. Das Gremium hat die Sanktion abgelehnt.';

  @override
  String get voteSaved =>
      'Deine Stimme wurde gespeichert. Bis zur Entscheidung kannst du sie ändern.';

  @override
  String get statusVoting => 'Abstimmung läuft';

  @override
  String get statusApproved => 'Bestätigt';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String proposed(String sanction) {
    return 'Vorschlag: $sanction';
  }

  @override
  String get directBan => 'Sperre ohne Abstimmung';

  @override
  String illegalLabel(String category) {
    return 'Illegale Aktivität: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals dafür · $rejections dagegen · $voters Stimmberechtigte';
  }

  @override
  String votingEndsIn(String time) {
    return 'Abstimmung endet in $time';
  }

  @override
  String bannedBy(String name) {
    return 'Gesperrt von: $name';
  }

  @override
  String openedBy(String name) {
    return 'Eröffnet von: $name';
  }

  @override
  String get approve => 'Bestätigen';

  @override
  String get reject => 'Ablehnen';

  @override
  String get noSanctions =>
      'Noch keine Sanktionen. Vom Gremium bestätigte Sanktionen und Einsprüche erscheinen hier.';

  @override
  String get liftSanction => 'Sanktion aufheben';

  @override
  String get keepSanction => 'Sanktion beibehalten';

  @override
  String get noteToPerson => 'Notiz an die Person (optional)';

  @override
  String get liftedNotified =>
      'Sanktion aufgehoben; die Person wurde benachrichtigt.';

  @override
  String get appealRejectedNotified =>
      'Einspruch abgelehnt; die Person wurde benachrichtigt.';

  @override
  String get lifted => 'Aufgehoben';

  @override
  String get interimMute => 'Sofort-Stummschaltung';

  @override
  String get running => 'Aktiv';

  @override
  String get applied => 'Verhängt';

  @override
  String get interimUntilDecision =>
      'Sofort-Stummschaltung · bis das Gremium entscheidet';

  @override
  String until(String date) {
    return 'bis $date';
  }

  @override
  String appealLine(String status) {
    return 'Einspruch · $status';
  }

  @override
  String noteLine(String note) {
    return 'Notiz: $note';
  }

  @override
  String get ownerParty =>
      'Inhaber:in ist an diesem Fall beteiligt; daher prüft das Plattform-Team den Einspruch.';

  @override
  String get keep => 'Beibehalten';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fälle warten auf deine Stimme',
      one: '1 Fall wartet auf deine Stimme',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einsprüche',
      one: '1 Einspruch',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderation';

  @override
  String get noWork => 'Nichts offen';

  @override
  String get mySanctions => 'Meine Sanktionen';

  @override
  String get noMySanctions =>
      'Du hast in keiner Gruppe Sanktionen. Danke, dass du die Community-Regeln einhältst.';

  @override
  String get interimEnded => 'Sofort-Stummschaltung beendet';

  @override
  String interimLatest(String date) {
    return 'Sofort-Stummschaltung · bis das Gremium entscheidet, spätestens $date';
  }

  @override
  String untilCap(String date) {
    return 'Bis $date';
  }

  @override
  String get ended => 'Beendet';

  @override
  String get appeal => 'Einspruch einlegen';

  @override
  String get appealHint => 'Warum hältst du es für ungerecht?';

  @override
  String get send => 'Senden';

  @override
  String get appealSent =>
      'Dein Einspruch wurde gesendet. Du wirst über die Entscheidung benachrichtigt.';

  @override
  String reasonLine(String reason) {
    return 'Begründung: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Dein Einspruch · $status';
  }

  @override
  String get appealOnce =>
      'Du kannst innerhalb von 7 Tagen einmal Einspruch einlegen.';

  @override
  String get reportPost => 'Beitrag melden';

  @override
  String get reportComment => 'Kommentar melden';

  @override
  String get reportEvent => 'Event melden';

  @override
  String get reportMessage => 'Nachricht melden';

  @override
  String get reportMatchProfile => 'Matching-Profil melden';

  @override
  String get reportPhoto => 'Foto melden';

  @override
  String get reportUser => 'Nutzer:in melden';

  @override
  String get reportReceived =>
      'Deine Meldung ist eingegangen. Wir prüfen sie und handeln; deine Identität wird der gemeldeten Person nicht gezeigt.';

  @override
  String get whyReport => 'Warum meldest du das?';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get detailsHint => 'Beschreib kurz, was passiert ist.';

  @override
  String get report => 'Melden';
}
