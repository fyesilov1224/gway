// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class MessagingL10nNl extends MessagingL10n {
  MessagingL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get groupInvalid =>
      'Je kunt het verzoek alleen naar een groep sturen waarvan je lid bent.';

  @override
  String get permissionExists =>
      'Je verzoek is al ontvangen of je toestemming staat aan.';

  @override
  String get permissionCooldown =>
      'Je kunt 7 dagen na de laatste beslissing een nieuw verzoek sturen.';

  @override
  String noteTooLong(int max) {
    return 'De notitie mag maximaal $max tekens hebben.';
  }

  @override
  String get requestForbidden => 'Het verzoek kan nu niet worden verstuurd.';

  @override
  String get unsupportedImage =>
      'Dit bestandstype wordt niet ondersteund. Kies JPEG, PNG of WebP.';

  @override
  String get voiceCallHandle => 'GWAY-spraakoproep';

  @override
  String get incomingCalls => 'Inkomende oproepen';

  @override
  String get missedCalls => 'Gemiste oproepen';

  @override
  String get answer => 'Opnemen';

  @override
  String get decline => 'Weigeren';

  @override
  String get noAnswer => 'Geen antwoord';

  @override
  String get missedCall => 'Gemiste oproep';

  @override
  String get callDeclined => 'Oproep geweigerd';

  @override
  String get youDeclined => 'Je hebt de oproep geweigerd';

  @override
  String get callNotAllowed => 'Bellen is niet meer mogelijk';

  @override
  String get callCanceled => 'Oproep geannuleerd';

  @override
  String get timeLimit => 'De 60 minuten zijn om; het gesprek is beëindigd';

  @override
  String get endedNotAllowed =>
      'Gesprek beëindigd: spraakoproepen zijn niet meer mogelijk';

  @override
  String get callEnded => 'Gesprek beëindigd';

  @override
  String get messageDeleted => 'Bericht verwijderd';

  @override
  String get photo => 'Foto';

  @override
  String get tonightTable => 'Tafel van vanavond';

  @override
  String get blockRequestPending =>
      'Accepteer het berichtverzoek voordat je antwoordt.';

  @override
  String get blockDeclined =>
      'Deze persoon heeft je berichtverzoek niet geaccepteerd.';

  @override
  String get blockMuted =>
      'Je bent gedempt in deze groep en kunt nu niet schrijven.';

  @override
  String get blockAdminsOnly =>
      'Alleen beheerders kunnen in deze chat schrijven.';

  @override
  String get blockTableClosed =>
      'De tafel is gesloten; je kunt berichten lezen maar geen nieuwe schrijven.';

  @override
  String get blockBlocked => 'Door een blokkade kun je hier niet schrijven.';

  @override
  String get blockMatchEnded =>
      'Deze chat is gesloten omdat de match is beëindigd.';

  @override
  String get blockMatchLocked =>
      'Om je match te schrijven heb je het pakket Matchchat nodig. Berichten lezen is gratis.';

  @override
  String get blockTeammateLocked =>
      'Om je teamgenoot te schrijven heb je het Teamgenoot-pakket nodig. Berichten lezen is gratis.';

  @override
  String get blockNotAllowed =>
      'Privéberichten zijn nu alleen voor matches en teamgenoten. Je oude berichten kun je nog lezen.';

  @override
  String get blockOther => 'Je kunt nu niet in deze chat schrijven.';

  @override
  String get hiddenUser => 'GWAY-gebruiker';

  @override
  String get voiceCalls => 'Spraakoproepen';

  @override
  String get voiceCallsHeadline => 'Praat met je matches en teamgenoten';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Met spraakoproepen bel je je matches en teamgenoten vanuit de privéchat. Ze zijn niet voor iedereen: je vraagt ze aan bij een van je groepen en de eigenaar of een beheerder zet ze aan. Gesprekken worden nooit opgenomen of afgeluisterd; een gesprek duurt maximaal $minutes minuten.';
  }

  @override
  String get status => 'Status';

  @override
  String get notRequested => 'Niet aangevraagd';

  @override
  String get underReview => 'In behandeling';

  @override
  String get statusOn => 'Aan';

  @override
  String get statusOff => 'Uit';

  @override
  String get notRequestedYet => 'Je hebt het nog niet aangevraagd.';

  @override
  String requestedFrom(String group) {
    return 'Je verzoek is bij de beheerders van $group. Je krijgt bericht zodra ze beslissen.';
  }

  @override
  String get requestedFromGroup =>
      'Je verzoek is bij de groepsbeheerders. Je krijgt bericht zodra ze beslissen.';

  @override
  String activeFrom(String group) {
    return 'Je spraakoproepen staan aan ($group). Bel je matches en teamgenoten met het telefoonicoon boven in de chat; zij hebben ook toestemming nodig.';
  }

  @override
  String get active =>
      'Je spraakoproepen staan aan. Bel je matches en teamgenoten met het telefoonicoon boven in de chat; zij hebben ook toestemming nodig.';

  @override
  String get declined => 'Je verzoek is voorlopig niet goedgekeurd.';

  @override
  String get revokedLeftGroup =>
      'Je spraakoproepen staan uit omdat je de groep hebt verlaten die ze gaf. Je kunt ze opnieuw aanvragen bij een andere groep.';

  @override
  String get revoked => 'Je spraakoproepen zijn uitgezet.';

  @override
  String reasonLine(String reason) {
    return 'Reden: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Je notitie: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Je kunt het na $date opnieuw aanvragen.';
  }

  @override
  String get requestSent => 'Je verzoek is verstuurd.';

  @override
  String get joinGroupFirst =>
      'Groepseigenaren en beheerders zetten spraakoproepen aan. Word eerst lid van een groep om ze aan te vragen.';

  @override
  String get requestToGroup => 'Groep voor het verzoek';

  @override
  String get noteOptional => 'Notitie (optioneel)';

  @override
  String get noteHint =>
      'Je kunt kort schrijven waarom je spraakoproepen wilt.';

  @override
  String get request => 'Aanvragen';

  @override
  String get lockScreenCalls => 'Oproepen op het vergrendelscherm';

  @override
  String get lockScreenHint =>
      'Geef GWAY toestemming om schermvullend te bellen als je telefoon vergrendeld is.';

  @override
  String get allow => 'Toestaan';

  @override
  String get callInfoFailed =>
      'Het gesprek kon niet worden geladen. Controleer je verbinding.';

  @override
  String get tapEndToHangUp => 'Tik op Ophangen om te stoppen.';

  @override
  String get callNotFound => 'Dit gesprek is niet gevonden.';

  @override
  String get close => 'Sluiten';

  @override
  String callLimitNote(int minutes) {
    return 'Een gesprek duurt maximaal $minutes minuten en wordt nooit opgenomen.';
  }

  @override
  String get audioFailed =>
      'Audio verbinden mislukt. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get reconnect => 'Opnieuw verbinden';

  @override
  String get incoming => 'belt je…';

  @override
  String get calling => 'Bellen…';

  @override
  String get connecting => 'Verbinden…';

  @override
  String get answerCall => 'Opnemen';

  @override
  String get mute => 'Dempen';

  @override
  String get unmute => 'Geluid aan';

  @override
  String get end => 'Ophangen';

  @override
  String get speaker => 'Luidspreker';

  @override
  String get peerUnencrypted =>
      'De app van de ander is verouderd; het geluid is niet versleuteld en wordt niet afgespeeld. Vraag om de app bij te werken.';

  @override
  String get encrypting => 'Versleutelde verbinding opzetten…';

  @override
  String e2eeCode(String code) {
    return 'End-to-end versleuteld. Beveiligingscode $code';
  }

  @override
  String get e2ee => 'End-to-end versleuteld';

  @override
  String get codeMatchHint =>
      'Als deze code gelijk is aan die op het scherm van de ander, kan niemand meeluisteren.';

  @override
  String get micFailed =>
      'Microfoon aanzetten mislukt. Controleer de microfoontoestemming.';

  @override
  String get chatNotFound =>
      'Deze chat is niet gevonden of je kunt hem niet meer zien.';

  @override
  String get backToMessages => 'Terug naar berichten';

  @override
  String get cantCallNow => 'Bellen kan nu niet.';

  @override
  String get voiceCall => 'Spraakoproep';

  @override
  String get groupChatAdminsOnly => 'Groepschat · alleen beheerders schrijven';

  @override
  String get groupChat => 'Groepschat';

  @override
  String smallTableMembers(int count) {
    return 'Kleine tafel · $count mensen';
  }

  @override
  String get adminsOnlyOn =>
      'Nu kunnen alleen de eigenaar en beheerders in deze chat schrijven.';

  @override
  String get adminsOnlyOff =>
      'Nu kunnen alle groepsleden in deze chat schrijven.';

  @override
  String get chatSettings => 'Chatinstellingen';

  @override
  String get adminsOnlyToggle => 'Alleen beheerders schrijven';

  @override
  String get sendingPhoto => '📷 Foto versturen…';

  @override
  String get requestPendingNote =>
      'Je berichtverzoek is verstuurd. Tot het is geaccepteerd, zie je niet of het is gelezen.';

  @override
  String get groupChatEmpty =>
      'Nog geen berichten in de groepschat. Schrijf de eerste.';

  @override
  String get chatEmpty => 'Nog geen berichten. Schrijf de eerste.';

  @override
  String get startWriting => 'Begin te schrijven';

  @override
  String get sending => 'Versturen…';

  @override
  String get seen => 'Gezien';

  @override
  String get sent => 'Verzonden';

  @override
  String get seePackage => 'Pakket bekijken';

  @override
  String get today => 'Vandaag';

  @override
  String get messageRemoved => 'Dit bericht is verwijderd.';

  @override
  String get thisMessageDeleted => 'Dit bericht is verwijderd.';

  @override
  String get messageOptions => 'Berichtopties';

  @override
  String profileOf(String name) {
    return 'Profiel van $name';
  }

  @override
  String get you => 'Jij';

  @override
  String get copy => 'Kopiëren';

  @override
  String get copied => 'Bericht gekopieerd.';

  @override
  String get deleteForAll => 'Voor iedereen verwijderen';

  @override
  String get report => 'Melden';

  @override
  String get deleteForAllTitle => 'Bericht voor iedereen verwijderen?';

  @override
  String get deleteForAllBody =>
      'Iedereen in de chat ziet ‘Dit bericht is verwijderd’. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get delete => 'Verwijderen';

  @override
  String get requestDeleted => 'Berichtverzoek verwijderd.';

  @override
  String wantsToMessage(String name) {
    return '$name wil je een bericht sturen. Als je accepteert, kunnen jullie chatten en ziet diegene wanneer je hebt gelezen.';
  }

  @override
  String get accept => 'Accepteren';

  @override
  String get removePhoto => 'Foto verwijderen';

  @override
  String get addPhoto => 'Foto toevoegen';

  @override
  String get writeMessage => 'Schrijf een bericht';

  @override
  String get send => 'Versturen';

  @override
  String get messages => 'Berichten';

  @override
  String get chats => 'Chats';

  @override
  String get requests => 'Verzoeken';

  @override
  String requestsCount(int count) {
    return 'Verzoeken ($count)';
  }

  @override
  String get noChats =>
      'Je hebt nog geen chats. Je kunt je matches en teamgenoten schrijven.';

  @override
  String get findPeople => 'Mensen vinden';

  @override
  String get oldRequestsNote =>
      'Oude berichtverzoeken blijven hier. Privéberichten zijn nu alleen voor matches en teamgenoten; er komen geen nieuwe verzoeken.';

  @override
  String get noRequests => 'Geen openstaande berichtverzoeken.';

  @override
  String get backToChats => 'Terug naar chats';

  @override
  String get callRequests => 'Verzoeken voor spraakoproepen';

  @override
  String noPendingWithActive(int count) {
    return 'Geen openstaande verzoeken · $count actief';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verzoeken wachten',
      one: '1 verzoek wacht',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'In afwachting';

  @override
  String get activeTab => 'Actief';

  @override
  String get requestsOwnersOnly =>
      'Alleen de eigenaar en beheerders zien verzoeken voor spraakoproepen.';

  @override
  String get goBack => 'Terug';

  @override
  String noPendingFor(String group) {
    return 'Geen openstaande verzoeken. Verzoeken van leden van $group verschijnen hier.';
  }

  @override
  String get noActive => 'Deze groep heeft geen spraakoproepen toegekend.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get grantHint =>
      'Met jouw toestemming kan diegene al zijn matches en teamgenoten bellen. Gesprekken worden nooit opgenomen; verlaat diegene de groep, dan vervalt de toestemming.';

  @override
  String get granted => 'Spraakoproepen aangezet.';

  @override
  String get turnedOff => 'Spraakoproepen uitgezet.';

  @override
  String theirNote(String note) {
    return 'Notitie: $note';
  }

  @override
  String get turnOff => 'Uitzetten';

  @override
  String get turnOn => 'Aanzetten';

  @override
  String get rankOnlyGrant =>
      'De rang is gelijk aan of hoger dan die van jou; je kunt dit verzoek alleen goedkeuren.';

  @override
  String get rankCannotRevoke =>
      'De rang is gelijk aan of hoger dan die van jou; je kunt dit niet uitzetten.';

  @override
  String get declineRequest => 'Verzoek weigeren';

  @override
  String get turnOffCalls => 'Spraakoproepen uitzetten';

  @override
  String get declineHint =>
      'Diegene ziet de reden en kan na 7 dagen opnieuw aanvragen.';

  @override
  String get revokeHint =>
      'Een lopend gesprek stopt meteen. Diegene ziet de reden en kan na 7 dagen opnieuw aanvragen.';

  @override
  String get reason => 'Reden';

  @override
  String get reasonMin3 => 'De reden moet minstens 3 tekens hebben.';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get sendMessage => 'Bericht sturen';

  @override
  String get groupChatMembersOnly => 'Alleen groepsleden zien de groepschat.';

  @override
  String get callVerifying => 'Versleuteling wordt gecontroleerd…';

  @override
  String get callSecure => 'Beveiligd gesprek';

  @override
  String get callSecureDetail =>
      'End-to-end versleuteld. De beveiligingscodes van beide telefoons komen overeen; niemand zit ertussen.';

  @override
  String get callCheckFailed =>
      'Versleuteling niet bevestigd: de beveiligingscodes van de telefoons komen niet overeen. Beëindig het gesprek en bel opnieuw.';

  @override
  String get showSecurityCode => 'Beveiligingscode tonen';
}
