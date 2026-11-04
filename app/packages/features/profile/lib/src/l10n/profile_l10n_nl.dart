// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class ProfileL10nNl extends ProfileL10n {
  ProfileL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get unsupportedImage =>
      'Dit bestandstype wordt niet ondersteund. Kies JPEG, PNG of WebP.';

  @override
  String get usernameTaken =>
      'Deze gebruikersnaam is al bezet. Probeer een andere.';

  @override
  String get checkInput => 'Controleer je gegevens.';

  @override
  String get usernameReserved =>
      'Deze gebruikersnaam kan niet worden gebruikt. Probeer een andere.';

  @override
  String get usernameCooldown =>
      'Je kunt je gebruikersnaam maar één keer per 30 dagen wijzigen.';

  @override
  String get maxInterests10 => 'Je kunt maximaal 10 interesses kiezen.';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelBeginnerHint => 'Ik begin net';

  @override
  String get levelIntermediate => 'Gemiddeld';

  @override
  String get levelIntermediateHint => 'Ik doe het regelmatig';

  @override
  String get levelAdvanced => 'Gevorderd';

  @override
  String get levelAdvancedHint => 'Ik heb ervaring';

  @override
  String get slotWeekdayMorning => 'Doordeweeks ’s ochtends';

  @override
  String get slotWeekdayNoon => 'Doordeweeks ’s middags';

  @override
  String get slotWeekdayEvening => 'Doordeweeks ’s avonds';

  @override
  String get slotWeekendMorning => 'In het weekend ’s ochtends';

  @override
  String get slotWeekendAfternoon => 'In het weekend ’s middags';

  @override
  String get slotWeekendEvening => 'In het weekend ’s avonds';

  @override
  String get partMorning => 'Ochtend';

  @override
  String get partNoon => 'Middag';

  @override
  String get partEvening => 'Avond';

  @override
  String get goalFun => 'Plezier maken';

  @override
  String get goalFitness => 'Fit blijven';

  @override
  String get goalCompetition => 'Trainen voor een wedstrijd';

  @override
  String get goalLearning => 'Nieuwe dingen leren';

  @override
  String get goalMentoring => 'Mijn ervaring delen';

  @override
  String get goalSocial => 'Nieuwe mensen ontmoeten';

  @override
  String get freqMonthly => 'Een paar keer per maand';

  @override
  String get freqWeekly => 'Eén keer per week';

  @override
  String get freqFewWeekly => '2–3 keer per week';

  @override
  String get freqDaily => 'Bijna elke dag';

  @override
  String get sizePair => 'Met z’n tweeën';

  @override
  String get sizeSmall => 'Kleine groep (3–6)';

  @override
  String get sizeLarge => 'Grote groep';

  @override
  String get looking => 'Zoekt een team';

  @override
  String lookingWithLevel(String level) {
    return 'Zoekt een team · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Zelfde activiteit: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Gedeelde interesses: $list';
  }

  @override
  String get reasonProvince => 'Jullie zitten in dezelfde provincie';

  @override
  String reasonGroup(String group) {
    return 'Gedeelde groep: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count gedeelde groepen';
  }

  @override
  String reasonLevel(String level) {
    return 'Zelfde niveau: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Beschikbaar: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Gedeelde doelen: $list';
  }

  @override
  String get reasonFrequency => 'Jullie willen even vaak afspreken';

  @override
  String get hasVehicle => 'Heeft vervoer';

  @override
  String get hasEquipment => 'Heeft eigen uitrusting';

  @override
  String get usernameRequired => 'Kies een gebruikersnaam.';

  @override
  String usernameMin(int min) {
    return 'Je gebruikersnaam moet minstens $min tekens hebben.';
  }

  @override
  String usernameMax(int max) {
    return 'Je gebruikersnaam mag maximaal $max tekens hebben.';
  }

  @override
  String get usernameChars =>
      'Gebruik alleen a–z, 0–9, underscore (_) en punt (.).';

  @override
  String get usernameDots =>
      'Je gebruikersnaam mag niet met een punt beginnen of eindigen.';

  @override
  String get usernameDoubleDot =>
      'Twee punten achter elkaar zijn niet toegestaan.';

  @override
  String get nameRequired => 'Voer je naam in.';

  @override
  String nameMax(int max) {
    return 'Je naam mag maximaal $max tekens hebben.';
  }

  @override
  String get editProfile => 'Profiel bewerken';

  @override
  String get save => 'Opslaan';

  @override
  String get profileInfo => 'Profielgegevens';

  @override
  String get profileInfoHint =>
      'Deze gegevens zijn voor iedereen zichtbaar op je profiel.';

  @override
  String get yourName => 'Je naam';

  @override
  String get usernameEvery30 =>
      'Je kunt je gebruikersnaam eens per 30 dagen wijzigen.';

  @override
  String usernameLockedUntil(String date) {
    return 'Je kunt hem na $date wijzigen.';
  }

  @override
  String get about => 'Over mij';

  @override
  String get aboutHint =>
      'Vertel over jezelf en de activiteiten waar je van houdt.';

  @override
  String get interests => 'Interesses';

  @override
  String interestsMax(int max) {
    return 'Je kunt er maximaal $max kiezen.';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get saveChanges => 'Wijzigingen opslaan';

  @override
  String get remove => 'Verwijderen';

  @override
  String get removeCover => 'Omslagfoto verwijderen';

  @override
  String get addCover => 'Omslag toevoegen';

  @override
  String get changeCover => 'Omslag wijzigen';

  @override
  String get changeAvatar => 'Profielfoto wijzigen';

  @override
  String get photos => 'Profiel- en omslagfoto';

  @override
  String get photosHint => 'JPEG, PNG of WebP · max. 5 MB';

  @override
  String get addAvatar => 'Profielfoto toevoegen';

  @override
  String get removeAvatar => 'Profielfoto verwijderen';

  @override
  String get followers => 'Volgers';

  @override
  String get following => 'Volgend';

  @override
  String get privateLists =>
      'Dit account is privé. Volg het om de lijsten te zien.';

  @override
  String get backToProfile => 'Terug naar profiel';

  @override
  String get noFollowers => 'Nog geen volgers.';

  @override
  String get noFollowing => 'Volgt nog niemand.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get removeFollower => 'Volger verwijderen';

  @override
  String removeFollowerBody(String username) {
    return '@$username uit je volgers verwijderen? Diegene krijgt geen melding.';
  }

  @override
  String get removeAction => 'Verwijderen';

  @override
  String get friends => 'Jullie zijn vrienden';

  @override
  String get followRequests => 'Volgverzoeken';

  @override
  String get noFollowRequests =>
      'Geen openstaande volgverzoeken. Privéaccounts keuren verzoeken hier goed.';

  @override
  String get approve => 'Goedkeuren';

  @override
  String get delete => 'Verwijderen';

  @override
  String get blockedAccounts => 'Geblokkeerde accounts';

  @override
  String get noBlocked =>
      'Je hebt niemand geblokkeerd. Je kunt blokkeren via het menu van een profiel.';

  @override
  String get unblock => 'Deblokkeren';

  @override
  String get onboardWho => 'Laten we kennismaken';

  @override
  String get onboardWhoHint =>
      'Kies de naam en gebruikersnaam die op je profiel staan.';

  @override
  String get onboardPhoto => 'Profielfoto';

  @override
  String get onboardPhotoHint =>
      'Zodat je groepen je herkennen. Je kunt er later ook een toevoegen.';

  @override
  String get onboardInterests => 'Je interesses';

  @override
  String onboardInterestsHint(int max) {
    return 'Kies er maximaal $max, zodat we passende groepen kunnen voorstellen.';
  }

  @override
  String get back => 'Terug';

  @override
  String stepOf(int step, int total) {
    return 'Stap $step van $total';
  }

  @override
  String get signOut => 'Uitloggen';

  @override
  String get skipForNow => 'Nu overslaan';

  @override
  String get continueAction => 'Doorgaan';

  @override
  String get finish => 'Afronden';

  @override
  String get usernameHelper => 'Gebruik kleine letters, cijfers, _ en .';

  @override
  String get avatarPreview => 'Voorbeeld van profielfoto';

  @override
  String get choosePhoto => 'Foto kiezen';

  @override
  String get chooseAnotherPhoto => 'Andere foto kiezen';

  @override
  String get profile => 'Profiel';

  @override
  String get settings => 'Instellingen';

  @override
  String get profileNotFound =>
      'Dit profiel is niet gevonden of niet meer zichtbaar.';

  @override
  String get backToMyProfile => 'Terug naar mijn profiel';

  @override
  String suspendedUntil(String date) {
    return 'Dit account is geschorst tot $date.';
  }

  @override
  String get followsYou => 'Volgt jou';

  @override
  String get yourTeammate => 'Je teamgenoot';

  @override
  String joined(String date) {
    return 'Lid sinds $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volgverzoeken wachten op goedkeuring.',
      one: '1 volgverzoek wacht op goedkeuring.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Bekijken';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teamverzoeken wachten op je.',
      one: '1 teamverzoek wacht op je.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Je hebt dit account geblokkeerd';

  @override
  String get youBlockedHint =>
      'Als je deblokkeert, zien jullie elkaars berichten weer.';

  @override
  String get privateAccount => 'Dit account is privé';

  @override
  String get privateAccountHint =>
      'Volg dit account om foto\'s, video\'s en verhalen te zien.';

  @override
  String get addInterestsNudge =>
      'Voeg je interesses toe, dan vinden we groepen en teamgenoten voor je.';

  @override
  String get add => 'Toevoegen';

  @override
  String blockTitle(String username) {
    return '@$username blokkeren?';
  }

  @override
  String get blockBody =>
      'Diegene ziet je profiel, berichten en verhalen niet meer, kan je niet vinden en je geen berichten sturen. Jullie volgen elkaar niet meer. Diegene hoort niet dat je hebt geblokkeerd.';

  @override
  String get block => 'Blokkeren';

  @override
  String get becomeTeammates => 'Teamgenoten worden';

  @override
  String nowTeammates(String name) {
    return 'Jij en $name zijn nu teamgenoten.';
  }

  @override
  String get acceptTeammate => 'Teamverzoek accepteren';

  @override
  String get requestWithdrawn => 'Verzoek ingetrokken.';

  @override
  String get withdrawTeammate => 'Teamverzoek intrekken';

  @override
  String get teammateEnded => 'Teamverbinding beëindigd.';

  @override
  String get endTeammate => 'Teamverbinding beëindigen';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get linkCopied => 'Profiellink gekopieerd.';

  @override
  String get copyLink => 'Profiellink kopiëren';

  @override
  String get removedFromFollowers => 'Uit je volgers verwijderd.';

  @override
  String get removeFromFollowers => 'Uit mijn volgers verwijderen';

  @override
  String get report => 'Melden';

  @override
  String get unblocked => 'Gedeblokkeerd.';

  @override
  String get statPosts => 'Berichten';

  @override
  String get statFollowers => 'Volgers';

  @override
  String get statFollowing => 'Volgend';

  @override
  String withdrawFollowBody(String username) {
    return 'Je volgverzoek aan @$username intrekken?';
  }

  @override
  String unfollowBody(String username) {
    return '@$username ontvolgen?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return '@$username ontvolgen? Het account is privé, dus je moet opnieuw een verzoek sturen om de berichten te zien.';
  }

  @override
  String get withdrawRequest => 'Verzoek intrekken';

  @override
  String get unfollow => 'Ontvolgen';

  @override
  String get followBack => 'Terugvolgen';

  @override
  String get follow => 'Volgen';

  @override
  String get requestSent => 'Aangevraagd';

  @override
  String get followingState => 'Volgend';

  @override
  String noAccountMatch(String query) {
    return 'Geen accounts gevonden voor ‘$query’.';
  }

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get searchHint => 'Begin te typen om mensen of tags te zoeken.';

  @override
  String get refreshSuggestions => 'Suggesties vernieuwen';

  @override
  String get suggestionsForYou => 'Voor jou voorgesteld';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gevolgd door $count mensen die jij volgt',
      one: 'Gevolgd door 1 persoon die jij volgt',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Populair account';

  @override
  String get seePackage => 'Pakket bekijken';

  @override
  String requestSentNotify(String name) {
    return 'Verzoek verstuurd. We laten het je weten zodra $name accepteert.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Teamgenoten worden met $name';
  }

  @override
  String get shortMessage => 'Een kort bericht (optioneel)';

  @override
  String get shortMessageHint => 'Zaterdagochtend in het park?';

  @override
  String get sendRequest => 'Verzoek sturen';

  @override
  String get findTeammates => 'Teamgenoten vinden';

  @override
  String get myTeammatePrefs => 'Mijn teamvoorkeuren';

  @override
  String get tabSuggestions => 'Suggesties';

  @override
  String get tabRequests => 'Verzoeken';

  @override
  String tabRequestsCount(int count) {
    return 'Verzoeken ($count)';
  }

  @override
  String get tabMyTeam => 'Mijn team';

  @override
  String get findYourTeammate => 'Vind je teamgenoot';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen willen je teamgenoot worden',
      one: '1 persoon wil je teamgenoot worden',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Suggesties zien, verzoeken sturen en accepteren en je teamgenoten berichten stuur je met het Teamgenoot-pakket.';

  @override
  String get beVisible => 'Word ook zichtbaar';

  @override
  String get beVisibleBody =>
      'Zet ‘Ik zoek een team’ aan, dan kunnen mensen met dezelfde interesses je verzoeken sturen.';

  @override
  String get setPrefs => 'Mijn voorkeuren instellen';

  @override
  String get nowPublicSuggest =>
      'Je account is nu openbaar; je kunt in suggesties verschijnen.';

  @override
  String get privateHidden =>
      'Je account is privé, je verschijnt niet in suggesties';

  @override
  String get privateHiddenBody =>
      'Privéaccounts verschijnen niet in teamsuggesties. Als je je account openbaar maakt, worden openstaande volgverzoeken ook goedgekeurd.';

  @override
  String get makePublic => 'Mijn account openbaar maken';

  @override
  String get noSuggestions =>
      'Voorlopig past er niemand. Vul je interesses en voorkeuren in voor meer suggesties.';

  @override
  String quoted(String text) {
    return '‘$text’';
  }

  @override
  String get whySuggested => 'Waarom voorgesteld';

  @override
  String get noPendingTeammate => 'Geen openstaande teamverzoeken.';

  @override
  String get seeSuggestions => 'Suggesties bekijken';

  @override
  String get incoming => 'Ontvangen';

  @override
  String get accept => 'Accepteren';

  @override
  String get decline => 'Weigeren';

  @override
  String get requestDeclined => 'Verzoek geweigerd.';

  @override
  String get outgoing => 'Verstuurd';

  @override
  String get awaitingReply => 'Wacht op antwoord';

  @override
  String get withdraw => 'Intrekken';

  @override
  String get noTeammates =>
      'Je hebt nog geen teamgenoten. Stuur eerst een verzoek naar iemand uit de suggesties.';

  @override
  String optionsFor(String name) {
    return 'Opties voor $name';
  }

  @override
  String get teammatePrefs => 'Teamvoorkeuren';

  @override
  String get prefsSavedVisible =>
      'Voorkeuren opgeslagen. Je verschijnt nu in suggesties.';

  @override
  String get prefsSaved => 'Voorkeuren opgeslagen.';

  @override
  String get whatToDo => 'Wat wil je doen?';

  @override
  String activitiesHint(int max) {
    return 'Activiteiten waarvoor je teamgenoten zoekt. Maximaal $max.';
  }

  @override
  String get yourLevel => 'Je niveau';

  @override
  String get yourGoals => 'Je doelen';

  @override
  String get multipleChoice => 'Je kunt er meerdere kiezen.';

  @override
  String get howOften => 'Hoe vaak wil je afspreken?';

  @override
  String get whenFree => 'Wanneer heb je tijd?';

  @override
  String get whenFreeHint => 'Tik op de momenten waarop je kunt.';

  @override
  String get whatTeam => 'Wat voor team wil je?';

  @override
  String get whichProvince => 'In welke provincie woon je?';

  @override
  String get provinceHint =>
      'Alleen gebruikt voor suggesties, niet zichtbaar op je profiel.';

  @override
  String get province => 'Provincie';

  @override
  String get ratherNotSay => 'Zeg ik liever niet';

  @override
  String get extras => 'Extra gegevens';

  @override
  String get iHaveVehicle => 'Ik heb vervoer';

  @override
  String get iHaveVehicleHint => 'Ik kan anderen meenemen.';

  @override
  String get iHaveEquipment => 'Ik heb eigen uitrusting';

  @override
  String get iHaveEquipmentHint =>
      'Fiets, tent, racket of ander materiaal heb ik.';

  @override
  String get describeYourself => 'Beschrijf jezelf';

  @override
  String get describeHint => 'Staat onder je naam in suggesties.';

  @override
  String get describeExample =>
      'Ik zoek iemand om in het weekend ’s ochtends te wandelen.';

  @override
  String get willAppear => 'Je verschijnt in suggesties.';

  @override
  String get notAppearing => 'Je verschijnt nu niet in suggesties.';

  @override
  String get lookingForTeam => 'Ik zoek een team';

  @override
  String get lookingOn =>
      'Je verschijnt in suggesties; anderen kunnen je teamverzoeken sturen.';

  @override
  String get lookingOff =>
      'Zet het aan, dan vinden mensen met dezelfde interesses je. Privéaccounts verschijnen niet in suggesties.';

  @override
  String prefsComplete(int percent) {
    return 'Voorkeuren $percent% compleet';
  }

  @override
  String get prefsCompleteHint =>
      'Hoe meer je invult, hoe beter de suggesties.';

  @override
  String get weekday => 'Doordeweeks';

  @override
  String get weekend => 'Weekend';

  @override
  String get username => 'Gebruikersnaam';

  @override
  String get available => 'Beschikbaar';

  @override
  String get taken => 'Bezet';
}
