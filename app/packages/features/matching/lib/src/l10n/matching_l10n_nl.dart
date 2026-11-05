// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class MatchingL10nNl extends MatchingL10n {
  MatchingL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get unsupportedImage =>
      'Alleen JPEG-, PNG- of WebP-foto\'s kunnen worden geüpload.';

  @override
  String get modeFriend => 'Vriendschap';

  @override
  String get modeDating => 'Daten';

  @override
  String get genderWoman => 'Vrouw';

  @override
  String get genderMan => 'Man';

  @override
  String get genderNonbinary => 'Non-binair';

  @override
  String get adultsOnly => 'Matchen is alleen voor mensen boven de 18.';

  @override
  String get pickMode => 'Kies minstens één modus: Vriendschap of Daten.';

  @override
  String get pickInterest => 'Kies voor Daten wie je zoekt.';

  @override
  String get ageRangeInvalid => 'Het leeftijdsbereik is ongeldig.';

  @override
  String sharedGroup(String group) {
    return 'Gedeelde groep: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gedeeld: $group en nog $count groepen',
      one: 'Gedeeld: $group en nog 1 groep',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'Mijn matches';

  @override
  String get pkgRevealText =>
      'Zie met wie je een match hebt: naam, foto\'s en profiel.';

  @override
  String get pkgChat => 'Matchchat';

  @override
  String get pkgChatText => 'Schrijf je matches. Inclusief je matches zien.';

  @override
  String get pkgAdmirers => 'Wie jou leuk vindt';

  @override
  String get pkgAdmirersText =>
      'Zie wie jou leuk vindt en match meteen door terug te liken.';

  @override
  String get pkgUnlimited => 'Onbeperkt liken';

  @override
  String get pkgUnlimitedText =>
      'Geen daglimiet; terugdraaien en filters inbegrepen.';

  @override
  String get pkgSuper => 'Superlike';

  @override
  String get pkgSuperText =>
      '5 superlikes per dag; diegene ziet jou als eerste in de stapel.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Eén keer per dag 30 minuten bovenaan de stapels in je gedeelde groepen.';

  @override
  String get pkgTeammates => 'Teamgenoot';

  @override
  String get pkgTeammatesText =>
      'Stuur teamverzoeken en chat met je teamgenoten.';

  @override
  String get pkgAll => 'Alles-in-één';

  @override
  String get pkgAllText => 'Alle pakketten in één, veel voordeliger dan los.';

  @override
  String get superLikedYou => 'Heeft je gesuperliked';

  @override
  String get options => 'Opties';

  @override
  String get fullProfile => 'Volledig profiel';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NEE';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, foto $number';
  }

  @override
  String get about => 'Over';

  @override
  String get interests => 'Interesses';

  @override
  String get sharedGroupsTitle => 'Gedeelde groepen';

  @override
  String get createProfileTitle => 'Matchprofiel maken';

  @override
  String get myProfile => 'Mijn matchprofiel';

  @override
  String get birthDateLabel => 'Je geboortedatum';

  @override
  String get pickBasics => 'Kies je geboortedatum, gender en provincie.';

  @override
  String get confirmAgeConsent =>
      'Bevestig om door te gaan dat je ouder bent dan 18 en geef uitdrukkelijk toestemming.';

  @override
  String profileReady(int min) {
    return 'Je profiel is klaar. Voeg nu minstens $min foto\'s toe.';
  }

  @override
  String get saved => 'Opgeslagen.';

  @override
  String get pickBirthDate => 'Geboortedatum kiezen';

  @override
  String ageNote(int age) {
    return '$age jaar · je kaart toont alleen je leeftijd';
  }

  @override
  String get gender => 'Gender';

  @override
  String get province => 'Provincie';

  @override
  String get aboutHint => 'Vertel iets over jezelf';

  @override
  String get jobOptional => 'Beroep (optioneel)';

  @override
  String get educationOptional => 'Opleiding (optioneel)';

  @override
  String get interestsFromProfile =>
      'Je interesses komen uit je sociale profiel.';

  @override
  String get lookingFor => 'Waar ben je naar op zoek?';

  @override
  String get friendHint => 'Mensen om mee naar events te gaan en te kletsen';

  @override
  String get datingHint => 'Een romantische relatie';

  @override
  String get whoLookingFor => 'Wie zoek je?';

  @override
  String ageRange(int min, int max) {
    return 'Leeftijd: $min–$max';
  }

  @override
  String get consentTitle => 'Toestemming';

  @override
  String get iam18 => 'Ik ben ouder dan 18.';

  @override
  String get consentText =>
      'Voor het matchen geef ik uitdrukkelijk toestemming voor het verwerken van mijn gender, wie ik zoek, mijn geboortedatum, mijn provincie en mijn foto\'s, en voor het tonen ervan aan mensen in mijn gedeelde groepen die matchen hebben aangezet. Ik kan mijn toestemming altijd intrekken door mijn matchgegevens te verwijderen.';

  @override
  String get createProfile => 'Mijn profiel maken';

  @override
  String get save => 'Opslaan';

  @override
  String get photos => 'Foto\'s';

  @override
  String photosMin(int min) {
    return 'Voeg minstens $min foto\'s toe zodat je kaart zichtbaar wordt. De eerste is de omslag.';
  }

  @override
  String photosMax(int max) {
    return 'Maximaal $max foto\'s. De eerste is de omslag; tik op een foto om te wisselen.';
  }

  @override
  String get addPhoto => 'Foto toevoegen';

  @override
  String get cover => 'Omslag';

  @override
  String get removePhoto => 'Foto verwijderen';

  @override
  String get pauseProfile => 'Profiel pauzeren';

  @override
  String get pauseHint =>
      'Niemand ziet je en er komen geen nieuwe kaarten; je matches en chats blijven.';

  @override
  String get deleteData => 'Mijn matchgegevens verwijderen';

  @override
  String get deleteDataHint =>
      'Profiel, foto\'s en likes worden verwijderd; je matches stoppen. Je toestemming is ingetrokken.';

  @override
  String get deleteDataTitle => 'Matchgegevens verwijderen';

  @override
  String get deleteDataBody =>
      'Je matchprofiel, foto\'s en likes worden definitief verwijderd; al je matches stoppen. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get delete => 'Verwijderen';

  @override
  String get dataDeleted => 'Je matchgegevens zijn verwijderd.';

  @override
  String get itsAMatch => 'Het is een match!';

  @override
  String bothLiked(String name) {
    return 'Jij en $name vinden elkaar leuk.';
  }

  @override
  String get keepSwiping => 'Blijf swipen';

  @override
  String get sendMessage => 'Bericht sturen';

  @override
  String get reportProfile => 'Profiel melden';

  @override
  String get reportPhoto => 'Deze foto melden';

  @override
  String get block => 'Blokkeren';

  @override
  String get blockHint => 'Jullie zien elkaar nergens meer.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get newMatch => 'Je hebt een match!';

  @override
  String tapToSee(String date) {
    return 'Tik om te zien wie het is · $date';
  }

  @override
  String get revealReason =>
      'Je hebt een match! Neem het pakket Mijn matches om te zien wie het is.';

  @override
  String get keepFriend => 'Alleen vrienden blijven';

  @override
  String get keepDating => 'Alleen daten';

  @override
  String keepFriendBody(String name) {
    return 'Je datingmatch met $name stopt voor jullie allebei; de vriendschapsmatch en chat blijven.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Je vriendschapsmatch met $name stopt voor jullie allebei; de datingmatch en chat blijven.';
  }

  @override
  String get keptFriend => 'Jullie zijn nu alleen als vrienden gematcht.';

  @override
  String get keptDating => 'Jullie zijn nu alleen voor daten gematcht.';

  @override
  String get continueAction => 'Doorgaan';

  @override
  String get endMatch => 'Match beëindigen';

  @override
  String endMatchBody(String name) {
    return 'Je match met $name stopt en de chat sluit voor jullie allebei. Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get end => 'Beëindigen';

  @override
  String get matchEnded => 'De match is beëindigd.';

  @override
  String get noMatches =>
      'Nog geen matches. Mensen die jullie allebei leuk vinden verschijnen hier.';

  @override
  String get backToDiscover => 'Terug naar ontdekken';

  @override
  String get report => 'Melden';

  @override
  String get matching => 'Matchen';

  @override
  String get admirers => 'Wie jou leuk vindt';

  @override
  String get packages => 'Pakketten';

  @override
  String get more => 'Meer';

  @override
  String get filtersLocked =>
      'Filteren op leeftijd, provincie en interesse zit in het pakket Onbeperkt liken.';

  @override
  String get filters => 'Filters';

  @override
  String get suspended =>
      'Je matchprofiel is gesloten door het platformteam. Schrijf Support voor details.';

  @override
  String addPhotosToStart(int min) {
    return 'Voeg minstens $min foto\'s toe om je kaart te tonen en te beginnen met ontdekken.';
  }

  @override
  String get paused =>
      'Je profiel is gepauzeerd; niemand ziet je. Je matches en chats blijven.';

  @override
  String get likesOut =>
      'Je gratis likes van vandaag zijn op. Like zoveel je wilt met Onbeperkt liken.';

  @override
  String get supersOut =>
      'Je superlikes van vandaag zijn op. Morgen komen er nieuwe.';

  @override
  String get superUsed =>
      'Je hebt je superlike van vandaag gebruikt. 5 per dag met het Superlike-pakket.';

  @override
  String get rewindLocked =>
      'Iemand terughalen die je per ongeluk oversloeg, zit in Onbeperkt liken.';

  @override
  String rewoundTo(String mode) {
    return 'De laatst overgeslagen persoon staat weer in de stapel $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Met een Boost sta je $minutes minuten bovenaan de stapels.';
  }

  @override
  String boosting(int minutes) {
    return 'Je bent geboost. Nog $minutes minuten.';
  }

  @override
  String get boostUsed =>
      'Je hebt je Boost van vandaag gebruikt. Morgen komt er een nieuwe.';

  @override
  String get boost => 'Boosten';

  @override
  String boostBody(int minutes) {
    return '$minutes minuten lang sta je als eerste in de stapels van mensen in je gedeelde groepen. Eén keer per dag.';
  }

  @override
  String boosted(int minutes) {
    return 'Geboost! Je staat $minutes minuten bovenaan.';
  }

  @override
  String get deckEmpty =>
      'Er is nu niemand meer. Dit vult zich als je lid wordt van groepen en anderen matchen aanzetten.';

  @override
  String get deckEmptyFiltered =>
      'Niemand past meer bij je filters. Probeer ze ruimer te maken.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get clearFilters => 'Filters wissen';

  @override
  String allowanceUnlimited(int supers) {
    return 'Onbeperkt liken · nog $supers superlikes.';
  }

  @override
  String get allowanceOut =>
      'Je likes van vandaag zijn op; morgen komen er nieuwe.';

  @override
  String allowance(int likes, int supers) {
    return 'Vandaag heb je nog $likes likes en $supers superlikes.';
  }

  @override
  String get undo => 'Ongedaan maken';

  @override
  String get pass => 'Overslaan';

  @override
  String get superLike => 'Superliken';

  @override
  String get like => 'Liken';

  @override
  String get introTitle => 'Leer nieuwe mensen uit je gedeelde groepen kennen';

  @override
  String get intro1 =>
      'Je ziet alleen mensen die matchen aanzetten in groepen waarvan je lid bent of die je volgt.';

  @override
  String get intro2 =>
      'Swipe naar rechts om te liken, naar links om over te slaan, omhoog voor een superlike.';

  @override
  String get intro3 =>
      'Als jullie elkaar leuk vinden, is het een match. Schrijven doe je met het pakket Matchchat.';

  @override
  String get intro4 =>
      'Vriendschap en Daten zijn aparte modi; kies er één of beide.';

  @override
  String get intro5 =>
      'Je profiel is alleen zichtbaar voor mensen die matchen aanzetten. Pauzeer of verwijder het wanneer je wilt.';

  @override
  String get createMyProfile => 'Mijn matchprofiel maken';

  @override
  String seePackageOf(String package) {
    return 'Pakket $package bekijken';
  }

  @override
  String get allPackages => 'Alle pakketten';

  @override
  String get packagesTitle => 'Matchpakketten';

  @override
  String get packagesIntro =>
      'Een profiel maken en swipen zijn gratis. Elke functie is een eigen pakket; neem alleen wat je wilt.';

  @override
  String get adminAllOpen => 'Als beheerder staan alle pakketten voor je aan';

  @override
  String openUntil(String date) {
    return 'Actief tot $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Leeftijd: $min – $max';
  }

  @override
  String get allProvinces => 'Alle provincies';

  @override
  String get interest => 'Interesse';

  @override
  String get all => 'Alle';

  @override
  String get apply => 'Toepassen';

  @override
  String get clear => 'Wissen';

  @override
  String get noAdmirers =>
      'Nu geen openstaande likes. Blijf swipen; wie jou leuk vindt, verschijnt hier.';

  @override
  String get backToSwiping => 'Terug naar swipen';

  @override
  String get likeAndMatch => 'Liken en matchen';

  @override
  String get noPendingLikes => 'Nog geen openstaande likes';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen vinden jou leuk',
      one: '1 persoon vindt jou leuk',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Met het pakket Wie jou leuk vindt zie je wie het zijn en match je meteen door terug te liken.';

  @override
  String get seePackage => 'Pakket bekijken';
}
