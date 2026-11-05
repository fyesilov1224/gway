// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SupportL10nDe extends SupportL10n {
  SupportL10nDe([String locale = 'de']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Du hast heute zu viele Nachrichten eröffnet. Versuch es morgen oder antworte in deinen offenen Nachrichten.';

  @override
  String get ruleReplyRate =>
      'Du hast in kurzer Zeit zu viele Antworten geschrieben. Warte kurz und versuch es erneut.';

  @override
  String get ticketClosed =>
      'Diese Nachricht ist geschlossen. Eröffne eine neue, um weiterzumachen.';

  @override
  String get unsupportedImage =>
      'Dieser Dateityp wird nicht unterstützt. Wähle JPEG, PNG oder WebP.';

  @override
  String get kindProblem => 'Problem';

  @override
  String get kindProblemText => 'Etwas ist kaputt oder funktioniert nicht.';

  @override
  String get kindRequest => 'Anliegen';

  @override
  String get kindRequestText =>
      'Bitte um eine Aktion für dein Konto, deine Gruppe oder Zahlung.';

  @override
  String get kindSuggestion => 'Wunsch';

  @override
  String get kindSuggestionText => 'Teile eine Idee oder einen Vorschlag.';

  @override
  String get statusOpen => 'Neu';

  @override
  String get statusInProgress => 'In Bearbeitung';

  @override
  String get statusResolved => 'Gelöst';

  @override
  String get statusClosed => 'Geschlossen';

  @override
  String get guide => 'Anleitung';

  @override
  String get guideSearchHint =>
      'In der Anleitung suchen: z. B. Einladungslink, Passwort';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get guideIntro =>
      'Erklärt jeden Bereich von GWAY Schritt für Schritt. Wähle ein Kapitel oder suche oben.';

  @override
  String get noHits =>
      'Nichts gefunden. Versuch ein anderes Wort oder schreib dem Support-Team.';

  @override
  String get writeSupport => 'Support kontaktieren';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Themen gefunden',
      one: '1 Thema gefunden',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count Themen.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Themen',
      one: '1 Thema',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'Dieses Kapitel wurde nicht gefunden.';

  @override
  String get backToGuide => 'Zurück zur Anleitung';

  @override
  String get notSolved => 'Problem nicht gelöst?';

  @override
  String get notSolvedHint =>
      'Schreib dem Plattform-Team; die Antwort siehst du unter Einstellungen → Support und Feedback.';

  @override
  String get nextChapter => 'Nächstes Kapitel';

  @override
  String get sent => 'Deine Nachricht wurde an das Plattform-Team gesendet.';

  @override
  String get newMessage => 'Neue Nachricht';

  @override
  String get aboutWhat => 'Worum geht es?';

  @override
  String get pickKind => 'Wähle eine Art.';

  @override
  String get relatedGroup => 'Betroffene Gruppe (optional)';

  @override
  String get noGroup => 'Betrifft keine Gruppe';

  @override
  String get subject => 'Betreff';

  @override
  String get subjectRequired => 'Schreib einen kurzen Betreff.';

  @override
  String get description => 'Beschreibung';

  @override
  String get descriptionHint =>
      'Was ist passiert, was hast du erwartet? Je mehr Details, desto schneller die Hilfe.';

  @override
  String get descriptionRequired => 'Beschreib kurz, was passiert ist.';

  @override
  String get send => 'Senden';

  @override
  String get supportTitle => 'Support und Feedback';

  @override
  String get emptyIntro =>
      'Du kannst dem Plattform-Team zu Problemen, Anliegen oder Wünschen schreiben.';

  @override
  String get listIntro =>
      'Deine Nachrichten gehen an das Plattform-Team; Antworten und Status siehst du hier.';

  @override
  String get newReply => 'Neue Antwort';

  @override
  String get message => 'Nachricht';

  @override
  String get notFound => 'Diese Nachricht wurde nicht gefunden.';

  @override
  String get goBack => 'Zurück';

  @override
  String get team => 'GWAY-Team';

  @override
  String get you => 'Du';

  @override
  String get addScreenshot => 'Screenshot hinzufügen';

  @override
  String get writeReply => 'Antwort schreiben';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String screenshots(int count, int max) {
    return 'Screenshots ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Screenshot vergrößern';
}
