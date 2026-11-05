// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class ModerationL10nNl extends ModerationL10n {
  ModerationL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Je hebt vandaag te veel meldingen gestuurd. Probeer het morgen opnieuw.';

  @override
  String get ruleTargetInvalid =>
      'Deze inhoud bestaat niet meer of je kunt hem niet zien.';

  @override
  String get ruleSelf => 'Je kunt jezelf of je eigen inhoud niet melden.';

  @override
  String get ruleAppealNotAllowed =>
      'Tegen deze sanctie is geen bezwaar meer mogelijk.';

  @override
  String get ruleDuplicate => 'Je hebt dit al gemeld; het wordt bekeken.';

  @override
  String get deletedAccount => 'Verwijderd account';

  @override
  String get reasonSpam => 'Spam of misleidend';

  @override
  String get reasonHarassment => 'Intimidatie of pesten';

  @override
  String get reasonHate => 'Haatzaaiende taal';

  @override
  String get reasonViolence => 'Geweld of bedreiging';

  @override
  String get reasonSexual => 'Seksuele inhoud';

  @override
  String get reasonMisinformation => 'Onjuiste informatie';

  @override
  String get reasonOther => 'Overig';

  @override
  String get sanctionWarning => 'Waarschuwing';

  @override
  String get sanctionMute => 'Dempen';

  @override
  String get sanctionKick => 'Verwijdering uit groep';

  @override
  String get sanctionBan => 'Ban';

  @override
  String get illegalViolence => 'Geweld';

  @override
  String get illegalThreat => 'Bedreiging';

  @override
  String get illegalInsult => 'Belediging';

  @override
  String get illegalHate => 'Haatzaaiende taal';

  @override
  String get illegalSexual => 'Seksueel misbruik';

  @override
  String get illegalFraud => 'Fraude';

  @override
  String get illegalDrugs => 'Drugs';

  @override
  String get illegalTerror => 'Terrorisme';

  @override
  String get illegalOther => 'Ander misdrijf';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen gedempt',
      one: '1 dag gedempt',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen ban',
      one: '1 dag ban',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Permanente ban';

  @override
  String get thresholdMajority => 'Gewone meerderheid';

  @override
  String get thresholdMajorityText => 'Meer dan de helft van de stemmen';

  @override
  String get thresholdTwoThirds => 'Tweederde';

  @override
  String get thresholdTwoThirdsText => 'Minstens tweederde van de stemmen';

  @override
  String get thresholdUnanimous => 'Unaniem';

  @override
  String get thresholdUnanimousText => 'Alle stemmen';

  @override
  String get targetPost => 'Bericht';

  @override
  String get targetComment => 'Reactie';

  @override
  String get targetEvent => 'Evenement';

  @override
  String get targetLiveComment => 'Livereactie';

  @override
  String get targetMessage => 'Groepschatbericht';

  @override
  String get targetMember => 'Lid';

  @override
  String get appealPending => 'Wacht op beslissing';

  @override
  String get appealUpheld => 'Sanctie blijft';

  @override
  String get appealOverturned => 'Sanctie opgeheven';

  @override
  String get banApplied => 'Ban toegepast.';

  @override
  String get banAppliedSuspended =>
      'Ban toegepast. Het account van de persoon is geschorst tot het platform het bekijkt.';

  @override
  String get caseOpened => 'Dossier geopend. De commissie stemt binnen 72 uur.';

  @override
  String get openCaseTitle => 'Tuchtdossier openen';

  @override
  String caseAboutNow(String name) {
    return 'Over $name. De ban geldt meteen, zonder stemming van de commissie.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Over $name. De tuchtcommissie stemt binnen 72 uur over je voorstel.';
  }

  @override
  String get proposedSanction => 'Voorgestelde sanctie';

  @override
  String get duration => 'Duur';

  @override
  String get permanent => 'Permanent';

  @override
  String get permanentLower => 'permanent';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Meteen toepassen, zonder stemming';

  @override
  String get applyNowHint =>
      'Bant zonder op de commissie te wachten. Diegene kan binnen 7 dagen bezwaar maken.';

  @override
  String get illegalActivity => 'Illegale activiteit';

  @override
  String get illegalHintNow =>
      'Zodra de ban geldt, gaat het dossier naar het platformteam en wordt het account geschorst tot de controle. Deze markering kan later niet worden gewijzigd.';

  @override
  String get illegalHintVote =>
      'Als de commissie instemt, gaat het dossier naar het platformteam en wordt het account geschorst tot de controle. Deze markering kan later niet worden gewijzigd.';

  @override
  String get reason => 'Reden';

  @override
  String get reasonHintNow =>
      'Wat is er gebeurd? De persoon en wie het bezwaar bekijkt, zien deze tekst.';

  @override
  String get reasonHintVote =>
      'Wat is er gebeurd? De commissie stemt op basis van deze tekst.';

  @override
  String get reasonMin10 => 'De reden moet minstens 10 tekens hebben.';

  @override
  String get muteNow => 'Nu dempen (24 uur)';

  @override
  String get muteNowHint =>
      'Tot de commissie beslist, kan diegene niet reageren of live spreken.';

  @override
  String get ban => 'Bannen';

  @override
  String get openCase => 'Dossier openen';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days d $hours u';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours uur',
      one: '1 uur',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'een paar minuten';

  @override
  String minChars(int min) {
    return 'Schrijf minstens $min tekens.';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get threshold => 'Beslissingsdrempel commissie';

  @override
  String thresholdChanged(String threshold) {
    return 'De drempel is nu ‘$threshold’. Dit geldt voor nieuwe dossiers.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderatie · $group';
  }

  @override
  String get reports => 'Meldingen';

  @override
  String reportsCount(int count) {
    return 'Meldingen ($count)';
  }

  @override
  String get cases => 'Dossiers';

  @override
  String casesCount(int count) {
    return 'Dossiers ($count)';
  }

  @override
  String get sanctions => 'Sancties';

  @override
  String sanctionsCount(int count) {
    return 'Sancties ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Alleen de eigenaar en het moderatieteam zien de moderatie van deze groep.';

  @override
  String get goBack => 'Terug';

  @override
  String get noReports =>
      'Geen open meldingen. Meldingen van leden komen hier.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get removeContent => 'Inhoud verwijderen';

  @override
  String get remove => 'Verwijderen';

  @override
  String get contentRemoved => 'Inhoud verwijderd.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meldingen',
      one: '1 melding',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Bekijken';

  @override
  String get reportDismissed => 'Melding afgewezen.';

  @override
  String get dismiss => 'Afwijzen';

  @override
  String get openCaseShort => 'Dossier openen';

  @override
  String get rankOnlyDismiss =>
      'De rang van deze persoon is niet lager dan die van jou; je kunt alleen afwijzen.';

  @override
  String get noCases =>
      'Nog geen tuchtdossiers. Dossiers open je vanuit een melding of de ledenpagina.';

  @override
  String get voteApproved =>
      'Je stem is opgeslagen. De commissie keurde de sanctie goed; die is toegepast.';

  @override
  String get voteRejected =>
      'Je stem is opgeslagen. De commissie wees de sanctie af.';

  @override
  String get voteSaved =>
      'Je stem is opgeslagen. Je kunt hem wijzigen tot er een beslissing is.';

  @override
  String get statusVoting => 'In stemming';

  @override
  String get statusApproved => 'Goedgekeurd';

  @override
  String get statusRejected => 'Afgewezen';

  @override
  String proposed(String sanction) {
    return 'Voorstel: $sanction';
  }

  @override
  String get directBan => 'Ban zonder stemming';

  @override
  String illegalLabel(String category) {
    return 'Illegale activiteit: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals voor · $rejections tegen · $voters stemgerechtigden';
  }

  @override
  String votingEndsIn(String time) {
    return 'Stemming eindigt over $time';
  }

  @override
  String bannedBy(String name) {
    return 'Geband door: $name';
  }

  @override
  String openedBy(String name) {
    return 'Geopend door: $name';
  }

  @override
  String get approve => 'Goedkeuren';

  @override
  String get reject => 'Afwijzen';

  @override
  String get noSanctions =>
      'Nog geen sancties. Door de commissie goedgekeurde sancties en bezwaren verschijnen hier.';

  @override
  String get liftSanction => 'Sanctie opheffen';

  @override
  String get keepSanction => 'Sanctie handhaven';

  @override
  String get noteToPerson => 'Notitie aan de persoon (optioneel)';

  @override
  String get liftedNotified =>
      'Sanctie opgeheven; de persoon is op de hoogte gebracht.';

  @override
  String get appealRejectedNotified =>
      'Bezwaar afgewezen; de persoon is op de hoogte gebracht.';

  @override
  String get lifted => 'Opgeheven';

  @override
  String get interimMute => 'Noodmute';

  @override
  String get running => 'Actief';

  @override
  String get applied => 'Toegepast';

  @override
  String get interimUntilDecision => 'Noodmute · tot de commissie beslist';

  @override
  String until(String date) {
    return 'tot $date';
  }

  @override
  String appealLine(String status) {
    return 'Bezwaar · $status';
  }

  @override
  String noteLine(String note) {
    return 'Notitie: $note';
  }

  @override
  String get ownerParty =>
      'De eigenaar is partij in dit dossier, dus het platformteam bekijkt het bezwaar.';

  @override
  String get keep => 'Handhaven';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers wachten op je stem',
      one: '1 dossier wacht op je stem',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bezwaren',
      one: '1 bezwaar',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderatie';

  @override
  String get noWork => 'Niets openstaand';

  @override
  String get mySanctions => 'Mijn sancties';

  @override
  String get noMySanctions =>
      'Je hebt in geen enkele groep sancties. Bedankt dat je je aan de communityregels houdt.';

  @override
  String get interimEnded => 'Noodmute beëindigd';

  @override
  String interimLatest(String date) {
    return 'Noodmute · tot de commissie beslist, uiterlijk $date';
  }

  @override
  String untilCap(String date) {
    return 'Tot $date';
  }

  @override
  String get ended => 'Afgelopen';

  @override
  String get appeal => 'Bezwaar maken';

  @override
  String get appealHint => 'Waarom vind je het onterecht?';

  @override
  String get send => 'Versturen';

  @override
  String get appealSent =>
      'Je bezwaar is verstuurd. Je krijgt bericht over de beslissing.';

  @override
  String reasonLine(String reason) {
    return 'Reden: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Je bezwaar · $status';
  }

  @override
  String get appealOnce => 'Je kunt binnen 7 dagen één keer bezwaar maken.';

  @override
  String get reportPost => 'Bericht melden';

  @override
  String get reportComment => 'Reactie melden';

  @override
  String get reportEvent => 'Evenement melden';

  @override
  String get reportMessage => 'Bericht melden';

  @override
  String get reportMatchProfile => 'Matchprofiel melden';

  @override
  String get reportPhoto => 'Foto melden';

  @override
  String get reportUser => 'Gebruiker melden';

  @override
  String get reportReceived =>
      'Je melding is ontvangen. We bekijken het en doen wat nodig is; je identiteit wordt niet aan de gemelde persoon getoond.';

  @override
  String get whyReport => 'Waarom meld je dit?';

  @override
  String get detailsOptional => 'Toelichting (optioneel)';

  @override
  String get detailsHint => 'Beschrijf kort wat er gebeurde.';

  @override
  String get report => 'Melden';
}
