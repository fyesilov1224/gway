// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class SupportL10nNl extends SupportL10n {
  SupportL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Je hebt vandaag te veel berichten geopend. Probeer het morgen of reageer in je open berichten.';

  @override
  String get ruleReplyRate =>
      'Je hebt in korte tijd te veel antwoorden geschreven. Wacht even en probeer het opnieuw.';

  @override
  String get ticketClosed =>
      'Dit bericht is gesloten. Open een nieuw bericht om verder te gaan.';

  @override
  String get unsupportedImage =>
      'Dit bestandstype wordt niet ondersteund. Kies JPEG, PNG of WebP.';

  @override
  String get kindProblem => 'Probleem';

  @override
  String get kindProblemText => 'Iets is kapot of werkt niet.';

  @override
  String get kindRequest => 'Verzoek';

  @override
  String get kindRequestText =>
      'Vraag een actie voor je account, groep of betaling.';

  @override
  String get kindSuggestion => 'Suggestie';

  @override
  String get kindSuggestionText => 'Deel een idee of suggestie.';

  @override
  String get statusOpen => 'Nieuw';

  @override
  String get statusInProgress => 'In behandeling';

  @override
  String get statusResolved => 'Opgelost';

  @override
  String get statusClosed => 'Gesloten';

  @override
  String get guide => 'Handleiding';

  @override
  String get guideSearchHint =>
      'Zoek in de handleiding: bv. uitnodigingslink, wachtwoord';

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get guideIntro =>
      'Legt elk onderdeel van GWAY stap voor stap uit. Kies een hoofdstuk of zoek hierboven.';

  @override
  String get noHits =>
      'Niets gevonden. Probeer een ander woord of schrijf het supportteam.';

  @override
  String get writeSupport => 'Support schrijven';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderwerpen gevonden',
      one: '1 onderwerp gevonden',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count onderwerpen.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderwerpen',
      one: '1 onderwerp',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'Dit hoofdstuk is niet gevonden.';

  @override
  String get backToGuide => 'Terug naar de handleiding';

  @override
  String get notSolved => 'Probleem niet opgelost?';

  @override
  String get notSolvedHint =>
      'Schrijf het platformteam; het antwoord zie je in Instellingen → Ondersteuning en feedback.';

  @override
  String get nextChapter => 'Volgend hoofdstuk';

  @override
  String get sent => 'Je bericht is naar het platformteam gestuurd.';

  @override
  String get newMessage => 'Nieuw bericht';

  @override
  String get aboutWhat => 'Waarover schrijf je?';

  @override
  String get pickKind => 'Kies een type.';

  @override
  String get relatedGroup => 'Betreffende groep (optioneel)';

  @override
  String get noGroup => 'Gaat niet over een groep';

  @override
  String get subject => 'Onderwerp';

  @override
  String get subjectRequired => 'Schrijf een kort onderwerp.';

  @override
  String get description => 'Beschrijving';

  @override
  String get descriptionHint =>
      'Wat gebeurde er en wat verwachtte je? Hoe meer details, hoe sneller hulp.';

  @override
  String get descriptionRequired => 'Beschrijf kort wat er gebeurde.';

  @override
  String get send => 'Versturen';

  @override
  String get supportTitle => 'Ondersteuning en feedback';

  @override
  String get emptyIntro =>
      'Je kunt het platformteam schrijven over een probleem, verzoek of suggestie.';

  @override
  String get listIntro =>
      'Je berichten gaan naar het platformteam; volg hier de antwoorden en status.';

  @override
  String get newReply => 'Nieuw antwoord';

  @override
  String get message => 'Bericht';

  @override
  String get notFound => 'Dit bericht is niet gevonden.';

  @override
  String get goBack => 'Terug';

  @override
  String get team => 'GWAY-team';

  @override
  String get you => 'Jij';

  @override
  String get addScreenshot => 'Screenshot toevoegen';

  @override
  String get writeReply => 'Schrijf een antwoord';

  @override
  String get removeImage => 'Afbeelding verwijderen';

  @override
  String screenshots(int count, int max) {
    return 'Screenshots ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Screenshot vergroten';
}
