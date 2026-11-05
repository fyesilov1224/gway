// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class LiveL10nNl extends LiveL10n {
  LiveL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get commentRate =>
      'Je hebt in korte tijd veel gereageerd. Wacht even en probeer het opnieuw.';

  @override
  String get mutedListenOnly =>
      'Je bent gedempt in deze groep en kunt alleen luisteren.';

  @override
  String get cannotComment => 'Je kunt nu niet reageren op deze livestream.';

  @override
  String get roleHost => 'Host';

  @override
  String get roleSpeaker => 'Spreker';

  @override
  String get roleListener => 'Luisteraar';

  @override
  String get startLive => 'Live gaan';

  @override
  String hostedBy(String name) {
    return 'Gepresenteerd door $name';
  }

  @override
  String get join => 'Meedoen';

  @override
  String upcomingAt(String date) {
    return 'Binnenkort · $date';
  }

  @override
  String get scheduledCanceled => 'Geplande livestream geannuleerd.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get start => 'Starten';

  @override
  String get reminderRemoved => 'Herinnering verwijderd.';

  @override
  String get reminderSet => 'We laten het weten als het begint.';

  @override
  String get reminding => 'Herinnering aan';

  @override
  String get remind => 'Herinner me';

  @override
  String get schedule5min =>
      'Een geplande livestream moet minstens 5 minuten vanaf nu zijn.';

  @override
  String get scheduled =>
      'Livestream gepland. Leden kunnen een herinnering vragen.';

  @override
  String get liveBroadcast => 'Livestream';

  @override
  String get liveIntro =>
      'Groepsleden komen in de audioruimte; wie je op het podium haalt, kan spreken.';

  @override
  String get title => 'Titel';

  @override
  String get titleExample => 'Bijv. Planning zondagswandeling';

  @override
  String get titleMin3 => 'De titel moet minstens 3 tekens hebben.';

  @override
  String get now => 'Nu';

  @override
  String get scheduleIt => 'Plannen';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count minuten livetijd deze maand.',
      one: 'Nog 1 minuut livetijd deze maand.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'De livetijd van deze maand is op. Upgrade je pakket voor meer.';

  @override
  String get startTheLive => 'Livestream starten';

  @override
  String get liveNow => 'Nu live';

  @override
  String trayLabel(String group, String title) {
    return '$group is live: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Je bent in een livestream: $title. Tik om terug te gaan.';
  }

  @override
  String get connecting => 'Verbinden met livestream…';

  @override
  String get inBroadcast => 'Je bent live · tik om terug te gaan';

  @override
  String get micMutedByMod => 'Een beheerder heeft je microfoon uitgezet';

  @override
  String get micOff => 'Microfoon uit';

  @override
  String get micOn => 'Microfoon aan';

  @override
  String startsOn(String date) {
    return 'Deze livestream begint op $date.';
  }

  @override
  String get ended => 'Deze livestream is afgelopen.';

  @override
  String get notFound =>
      'Deze livestream is niet gevonden. Misschien moet je lid van de groep zijn.';

  @override
  String get goBack => 'Terug';

  @override
  String get onStageNow =>
      'Je staat op het podium. Zet je microfoon aan om te spreken.';

  @override
  String get nowListener => 'Je bent nu luisteraar.';

  @override
  String get leaveBroadcast => 'Livestream verlaten';

  @override
  String get leaveHostBody =>
      'Je kunt hem voor iedereen beëindigen. Als je alleen weggaat, stopt hij na 2 minuten vanzelf.';

  @override
  String get justLeave => 'Alleen weggaan';

  @override
  String get endBroadcast => 'Livestream beëindigen';

  @override
  String get inviteToStage => 'Op het podium halen';

  @override
  String get removeFromStage => 'Van het podium halen';

  @override
  String get muteMic => 'Microfoon uitzetten';

  @override
  String get unmuteMic => 'Microfoon aanzetten';

  @override
  String get kick => 'Uit livestream verwijderen';

  @override
  String kickBody(String name) {
    return '$name kan niet meer aan deze livestream deelnemen.';
  }

  @override
  String get cancelAction => 'Annuleren';

  @override
  String get remove => 'Verwijderen';

  @override
  String get raisedHands => 'Opgestoken handen';

  @override
  String get commentDeleted => 'Reactie verwijderd.';

  @override
  String get thanksForJoining =>
      'De livestream is afgelopen. Bedankt voor je deelname.';

  @override
  String get youWereKicked => 'Je bent uit deze livestream verwijderd.';

  @override
  String get connectFailedShort => 'Verbinden met de livestream mislukt.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count handen opgestoken',
      one: '1 hand opgestoken',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'Op het podium';

  @override
  String listeners(int count) {
    return 'Luisteraars · $count';
  }

  @override
  String get noListeners => 'Nog geen luisteraars.';

  @override
  String get minimize => 'Minimaliseren en in de livestream blijven';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen',
      one: '1 persoon',
    );
    return '$_temp0';
  }

  @override
  String get broadcastOptions => 'Livestreamopties';

  @override
  String get endForAll => 'Voor iedereen beëindigen';

  @override
  String get handRaised =>
      'Je hand is opgestoken. De host kan je op het podium halen.';

  @override
  String get you => 'Jij';

  @override
  String get speaking => 'spreekt';

  @override
  String get micOffState => 'microfoon uit';

  @override
  String get handUp => 'hand opgestoken';

  @override
  String get sendReaction => 'Reactie sturen';

  @override
  String get leave => 'Verlaten';

  @override
  String get leaveStage => 'Van het podium';

  @override
  String get reactions => 'Reacties';

  @override
  String get comments => 'Reacties';

  @override
  String get raiseHand => 'Hand opsteken';

  @override
  String get lowerHand => 'Hand laten zakken';

  @override
  String get report => 'Melden';

  @override
  String get deleteComment => 'Reactie verwijderen';

  @override
  String get firstComment => 'Schrijf de eerste reactie.';

  @override
  String get writeComment => 'Schrijf een reactie…';

  @override
  String get send => 'Versturen';

  @override
  String get connectFailed =>
      'Verbinden met de livestream mislukt. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get participant => 'Deelnemer';

  @override
  String get micNeedsManager =>
      'Alleen een beheerder van de livestream kan je microfoon aanzetten.';

  @override
  String get micFailed =>
      'Microfoon aanzetten mislukt. Controleer de microfoontoestemming.';

  @override
  String get connectionLost =>
      'De verbinding met de uitzending is verbroken. Tik om opnieuw te verbinden.';

  @override
  String get micAfterEncryption =>
      'De versleutelde verbinding wordt opgezet; je microfoon gaat zo aan.';

  @override
  String get encrypting => 'Versleutelde verbinding wordt opgezet…';

  @override
  String get verifying => 'Versleuteling wordt gecontroleerd…';

  @override
  String get liveSecure => 'Beveiligde uitzending';

  @override
  String get liveSecureDetail =>
      'End-to-end versleuteld. Iedereen in de ruimte gebruikt dezelfde sleutel; niemand, ook de server niet, kan meeluisteren.';

  @override
  String get liveCheckFailed =>
      'Versleuteling niet bevestigd: niet iedereen in de ruimte gebruikt dezelfde sleutel. Verlaat de uitzending en doe opnieuw mee.';

  @override
  String get liveUnconfirmed =>
      'Iemand op het podium gebruikt een oudere app-versie; het geluid kan niet worden versleuteld en wordt niet afgespeeld.';

  @override
  String get peerUnencrypted =>
      'Een spreker met een oudere versie stuurt onversleuteld geluid; het wordt niet afgespeeld. De app moet worden bijgewerkt.';

  @override
  String get e2ee => 'End-to-end versleuteld';

  @override
  String get showSecurityCode => 'Beveiligingscode tonen';

  @override
  String get codeMatchHint =>
      'Deze code is op ieders scherm in de ruimte gelijk.';

  @override
  String e2eeCode(String code) {
    return 'End-to-end versleuteld. Beveiligingscode $code';
  }

  @override
  String get liveOngoingTitle => 'Je bent in een live-uitzending';

  @override
  String get liveOngoingText => 'End-to-end versleuteld. Tik om terug te gaan.';
}
