// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class EventsL10nFr extends EventsL10n {
  EventsL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get pollSingle => 'Ce sondage n\'accepte qu\'une seule réponse.';

  @override
  String get pollOptionGone =>
      'Cette option n\'existe plus. Actualise la page.';

  @override
  String get reviewWindow =>
      'Les participants peuvent évaluer l\'événement pendant 30 jours après la fin.';

  @override
  String get greeterNeedsAttendance =>
      'Pour être accueillant(e), tu dois avoir participé à un événement du groupe.';

  @override
  String get note80 => 'La note peut contenir jusqu\'à 80 caractères.';

  @override
  String get pollClosed => 'Ce sondage est fermé ou tu ne peux pas voter.';

  @override
  String get cover5mb => 'L\'image de couverture peut faire jusqu\'à 5 Mo.';

  @override
  String get imagesOnly =>
      'Seules les images JPEG, PNG ou WebP peuvent être importées.';

  @override
  String get claimNotAllowed =>
      'Impossible de déclarer cette tâche : elle est terminée ou tu n\'es pas dans le groupe.';

  @override
  String get claimApprovedLocked =>
      'Une déclaration validée ne peut pas être retirée.';

  @override
  String get claimDuplicate => 'Tu as déjà déclaré cette tâche.';

  @override
  String get repeatsWeekly => 'Se répète chaque semaine';

  @override
  String get repeatsBiweekly => 'Se répète toutes les deux semaines';

  @override
  String surprisePlace(String place) {
    return 'Lieu surprise · $place';
  }

  @override
  String get goalPersonal => 'Objectif personnel';

  @override
  String get goalPersonalHint => 'Chaque membre atteint son propre nombre.';

  @override
  String get goalGroup => 'Objectif de groupe';

  @override
  String get goalGroupHint =>
      'Les contributions de chacun s’additionnent dans un seul compteur.';

  @override
  String get goalTeam => 'Objectif d\'équipe';

  @override
  String get goalTeamHint =>
      'Les admins forment les équipes ; chaque équipe a un compteur commun.';

  @override
  String get goalTask => 'Tâche validée';

  @override
  String get goalTaskHint => 'Un membre indique « Fait » et un admin valide.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'participations',
      one: 'participation',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'événements organisés',
      one: 'événement organisé',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'souvenirs',
      one: 'souvenir',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'En attente de validation';

  @override
  String get claimApproved => 'Validé';

  @override
  String get claimRejected => 'Non validé';

  @override
  String get notClaimedYet => 'Pas encore déclaré';

  @override
  String get whenAny => 'N\'importe quand';

  @override
  String get whenToday => 'Aujourd\'hui';

  @override
  String get whenWeek => 'Sous 7 jours';

  @override
  String get viewDay => 'Jour';

  @override
  String get viewWeek => 'Semaine';

  @override
  String get viewMonth => 'Mois';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participations',
      one: '1 participation',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements organisés',
      one: '1 événement organisé',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count souvenirs',
      one: '1 souvenir',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux accueillis',
      one: '1 nouveau accueilli',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count poignées de main',
      one: '1 poignée de main',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements',
      one: '1 événement',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis positifs',
      one: '1 avis positif',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month : ${rank}e sur $groups groupes, $points points.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity participants';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Premier événement de l\'année : $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Premier événement de l\'année : $title · $date';
  }

  @override
  String get myCalendar => 'Mon agenda';

  @override
  String get groupCalendar => 'Agenda du groupe';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get groupsEvents => 'Événements de mes groupes';

  @override
  String get showNotJoined =>
      'Afficher aussi ceux auxquels tu ne participes pas';

  @override
  String get noJoinedInRange =>
      'Tu ne participes à aucun événement à ces dates. Tu peux aussi voir ceux de tes groupes.';

  @override
  String get noEventsInRange => 'Aucun événement à ces dates.';

  @override
  String get showGroupsEvents => 'Afficher les événements de mes groupes';

  @override
  String get backToToday => 'Revenir à aujourd\'hui';

  @override
  String get noEventsDay => 'Aucun événement ce jour-là.';

  @override
  String get contributions => 'Contribution à la communauté';

  @override
  String get howBadges => 'Comment gagner des badges ?';

  @override
  String get badgesEmpty =>
      'Quand tu participes à un événement, ta contribution et ton premier badge apparaissent ici.';

  @override
  String get badgesRules =>
      'Les badges ne viennent que de ce que tu fais vraiment : événements suivis et organisés, souvenirs partagés et avis. Les j\'aime et abonnés ne comptent pas. Les participations marquées « absent » par l\'organisateur ne comptent pas. Personne n\'est classé.';

  @override
  String get categoryFan => 'Passionné de catégorie';

  @override
  String get pastEvents => 'Événements passés';

  @override
  String get noPastEvents => 'Ce groupe n\'a pas encore d\'événement passé.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get canceled => 'Annulé';

  @override
  String get olderEvents => 'Événements plus anciens';

  @override
  String get completed => 'Terminé';

  @override
  String get ended => 'Terminé';

  @override
  String teamName(String name) {
    return 'Équipe : $name';
  }

  @override
  String get teamNotice =>
      'Une fois ajouté(e) à une équipe, ta progression s\'affiche ici.';

  @override
  String get goals => 'Objectifs';

  @override
  String get createGoal => 'Créer un objectif';

  @override
  String get goalsEmpty =>
      'Par exemple « 4 randonnées ce mois-ci » ou « 50 participations ensemble » : crée le premier objectif.';

  @override
  String get claimSent => 'Ta déclaration a été transmise à l\'admin.';

  @override
  String get goal => 'Objectif';

  @override
  String get goalCountsRule =>
      'Seuls les événements de ce groupe pendant la période comptent ; les participations marquées « absent » ne comptent pas.';

  @override
  String get withdrawClaim => 'Retirer la déclaration';

  @override
  String get claimWithdrawn => 'Ta déclaration a été retirée.';

  @override
  String get done => 'Fait';

  @override
  String get teams => 'Équipes';

  @override
  String get createTeam => 'Créer une équipe';

  @override
  String get noTeams => 'Pas encore d\'équipe.';

  @override
  String deleteTeam(String name) {
    return 'Supprimer l\'équipe $name';
  }

  @override
  String get teamDeleted => 'Équipe supprimée.';

  @override
  String pendingClaims(int count) {
    return 'Déclarations en attente ($count)';
  }

  @override
  String get claimRejectedToast => 'Déclaration non validée.';

  @override
  String get decline => 'Refuser';

  @override
  String get approve => 'Valider';

  @override
  String taskDone(String name) {
    return '$name a terminé la tâche.';
  }

  @override
  String completions(int count) {
    return 'Terminé par ($count)';
  }

  @override
  String get noCompletions =>
      'Personne ne l\'a encore terminé. Chacun qui le fait reçoit le badge de cet objectif sur son profil.';

  @override
  String get goalCanceled => 'Objectif annulé.';

  @override
  String get cancelGoal => 'Annuler l\'objectif';

  @override
  String teamCreated(String name) {
    return 'Équipe « $name » créée.';
  }

  @override
  String get teamNameLabel => 'Nom de l\'équipe';

  @override
  String get createTheTeam => 'Créer l\'équipe';

  @override
  String createTeamWith(int count) {
    return 'Créer l\'équipe ($count personnes)';
  }

  @override
  String get goalCreated => 'Objectif créé.';

  @override
  String get title => 'Titre';

  @override
  String get goalTitleExample => 'Ex. : Randonnées d\'octobre';

  @override
  String get taskTitleExample =>
      'Ex. : Montrer le parcours à un nouveau membre';

  @override
  String get titleMin3 => 'Le titre doit contenir au moins 3 caractères.';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get targetNumber => 'Objectif chiffré';

  @override
  String get target1to1000 => 'Saisis un nombre entre 1 et 1000.';

  @override
  String get period => 'Période';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (92 jours maximum)';
  }

  @override
  String get createTheGoal => 'Créer l\'objectif';

  @override
  String get iDidTask => 'J\'ai fait la tâche';

  @override
  String get whatDidYouDo => 'Qu\'as-tu fait ? (facultatif)';

  @override
  String get whatDidYouDoHint => 'L\'admin valide après avoir lu cette note.';

  @override
  String get cancel => 'Annuler';

  @override
  String get send => 'Envoyer';

  @override
  String get handshake => 'Poignée de main';

  @override
  String get handshakeHint =>
      'Scannez vos codes l\'un l\'autre ; vous êtes ajoutés tous deux à « Mes rencontres ».';

  @override
  String get open => 'Ouvrir';

  @override
  String handshakeAt(String title) {
    return 'Poignée de main · $title';
  }

  @override
  String get myCode => 'Mon code';

  @override
  String get scan => 'Scanner';

  @override
  String get yourHandshakeCode => 'Ton code de poignée de main';

  @override
  String get codeHint =>
      'L\'autre personne scanne ce code dans l\'onglet « Scanner » ou le saisit. Le code change toutes les quelques minutes ; une photo ne servira pas plus tard.';

  @override
  String get cameraFailed =>
      'La caméra n\'a pas pu s\'ouvrir. Autorise-la dans les réglages ou saisis le code ci-dessous.';

  @override
  String get scanHint =>
      'Vise le QR code de l\'autre personne ou saisis son code.';

  @override
  String get typeCodeHint =>
      'Saisis le code à 6 caractères affiché sur l\'écran de l\'autre personne.';

  @override
  String get code => 'Code';

  @override
  String get alreadyMet => 'Vous vous connaissez déjà';

  @override
  String get metNow => 'Vous vous êtes rencontrés !';

  @override
  String personWithUsername(String name, String username) {
    return '$name ($username)';
  }

  @override
  String get ok => 'OK';

  @override
  String get metPeople => 'Mes rencontres';

  @override
  String get metEmpty =>
      'Quand tu serres la main de quelqu\'un lors d\'un événement, la personne apparaît ici. La poignée de main s\'ouvre sur la page de l\'événement.';

  @override
  String get goToCalendar => 'Aller à mon agenda';

  @override
  String get metPrivacy =>
      'Toi seul(e) le vois. Ton profil n’affiche que ton nombre de poignées de main.';

  @override
  String metRow(String username, String event, String date) {
    return '$username · $event · $date';
  }

  @override
  String get howPoints => 'Comment les points sont-ils calculés ?';

  @override
  String get leagueIntro =>
      'Les groupes de même catégorie dans la même province s’affrontent chaque mois. Les événements terminés dans le mois comptent.';

  @override
  String get ruleAttendance => 'Participation : 1 point';

  @override
  String get ruleAttendanceHint =>
      'Chaque personne présente ; 30 maximum par événement.';

  @override
  String get ruleHeld => 'Événement : 5 points';

  @override
  String get ruleHeldHint =>
      'Chaque événement avec au moins 3 participants en plus de l\'organisateur.';

  @override
  String get ruleWelcome => 'Accueil : 3 points';

  @override
  String get ruleWelcomeHint =>
      'Accueillir quelqu\'un qui vient pour la première fois.';

  @override
  String get ruleReview => 'Avis positif : 1 point';

  @override
  String get ruleReviewHint => 'Chaque avis 4 ou 5 étoiles.';

  @override
  String get leagueRulesNote =>
      'Les personnes marquées « absent » ne comptent pas. Les résultats sont définitifs 8 jours après la fin du mois ; les membres des trois premiers groupes sont prévenus.';

  @override
  String get groupsLeague => 'Ligue des groupes';

  @override
  String get category => 'Catégorie';

  @override
  String get province => 'Province';

  @override
  String get month => 'Mois';

  @override
  String seasonClosed(String month) {
    return 'La saison de $month est terminée ; le classement est définitif.';
  }

  @override
  String get seasonRunning =>
      'La saison est en cours. Les points se mettent à jour à la fin des événements ; résultats définitifs 8 jours après la fin du mois.';

  @override
  String leagueEmpty(String province) {
    return 'Aucun groupe de la ligue $province n\'a encore marqué de points ce mois-ci.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '${rank}e';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Ligue $category';
  }

  @override
  String get noPointsYet =>
      'Pas encore de points ce mois-ci. Les événements terminés, les présences et les accueils rapportent des points.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © contributeurs OpenStreetMap';

  @override
  String get map => 'Carte';

  @override
  String get mapView => 'Vue carte';

  @override
  String get listView => 'Vue liste';

  @override
  String get all => 'Tous';

  @override
  String get wholeArea => 'Toute la zone';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed =>
      'Impossible de charger les informations de la carte.';

  @override
  String get retry => 'Réessayer';

  @override
  String get noFilterResults => 'Rien ne correspond à ces filtres.';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get noNearby => 'Aucun événement à venir ni groupe dans cette zone.';

  @override
  String get zoomOut => 'Dézoomer';

  @override
  String get openEvent => 'Ouvrir l\'événement';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get noVisible =>
      'Aucun événement à venir ni groupe dans la zone visible.';

  @override
  String get backToMap => 'Retour à la carte';

  @override
  String upcomingCount(int count) {
    return 'Événements à venir ($count)';
  }

  @override
  String get directions => 'Itinéraire';

  @override
  String get meetingPointOptional => 'Point de rendez-vous (facultatif)';

  @override
  String get meetingPointHint =>
      'Choisis-le sur la carte ; l\'événement y apparaîtra.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Sélectionné · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Supprimer le point de rendez-vous';

  @override
  String get meetingPoint => 'Point de rendez-vous';

  @override
  String get pickHint => 'Zoome et touche le point de rendez-vous.';

  @override
  String get pickAgainHint => 'Touche ailleurs pour déplacer le point.';

  @override
  String get pickThisPoint => 'Choisir ce point';

  @override
  String get mapUnavailable => 'La carte n\'est pas disponible pour le moment.';

  @override
  String get pollClosedShort => 'Fermé';

  @override
  String closesAt(String date) {
    return 'Fermeture : $date';
  }

  @override
  String get multipleAllowed => 'Choix multiple';

  @override
  String get anonymousVote => 'Vote anonyme';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Options du sondage';

  @override
  String get pollClosedToast => 'Sondage fermé.';

  @override
  String get pollDeleted => 'Sondage supprimé.';

  @override
  String get closePoll => 'Fermer le sondage';

  @override
  String get deletePoll => 'Supprimer le sondage';

  @override
  String get vote => 'Voter';

  @override
  String get voteSaved => 'Ton vote a été enregistré.';

  @override
  String get voters => 'Votants';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get polls => 'Sondages';

  @override
  String get openPoll => 'Lancer un sondage';

  @override
  String get pollsEmpty =>
      'Pose une question aux membres, par exemple quel jour se retrouver ?';

  @override
  String get pollOpened => 'Sondage lancé.';

  @override
  String get question => 'Question';

  @override
  String get questionExample => 'Ex. : Quel jour se retrouve-t-on ?';

  @override
  String get questionMin3 => 'La question doit contenir au moins 3 caractères.';

  @override
  String optionN(int n) {
    return 'Option $n';
  }

  @override
  String get removeOption => 'Supprimer l\'option';

  @override
  String get optionRequired => 'Remplis l\'option ou supprime-la.';

  @override
  String get addOption => 'Ajouter une option';

  @override
  String get allowMultiple => 'Autoriser plusieurs réponses';

  @override
  String get anonymousHint => 'Personne ne voit qui a voté pour quoi.';

  @override
  String get noEndTime => 'Pas de date de fin';

  @override
  String get add => 'Ajouter';

  @override
  String get removeEndTime => 'Supprimer la date de fin';

  @override
  String get startPoll => 'Lancer le sondage';

  @override
  String get cardFooter => 'gway · trouve ta communauté';

  @override
  String myYear(int year) {
    return 'Mon année $year';
  }

  @override
  String get statAttended => 'événements suivis';

  @override
  String get statHours => 'heures ensemble';

  @override
  String get statOneGroup => 'groupe rencontré';

  @override
  String get statGroups => 'groupes différents rencontrés';

  @override
  String get statProvinces => 'provinces différentes';

  @override
  String get statOrganized => 'événements organisés';

  @override
  String get statWelcomed => 'nouveaux accueillis';

  @override
  String get statMemories => 'souvenirs partagés';

  @override
  String get favorites => 'Mes préférés';

  @override
  String get topGroup => 'Le groupe avec qui j’ai passé le plus de temps';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rencontres',
      one: '1 rencontre',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'J\'y étais';

  @override
  String get firstWithGroup => 'Mon premier événement avec ce groupe.';

  @override
  String nthWithGroup(int n) {
    return 'Mon ${n}e événement avec ce groupe.';
  }

  @override
  String get shareFailed =>
      'Partage impossible sur cet appareil. Fais une capture de la carte et partage-la.';

  @override
  String get share => 'Partager';

  @override
  String yearSummaryTitle(int year) {
    return 'Mon bilan $year';
  }

  @override
  String get yearEmpty =>
      'Tu n\'as encore participé à aucun événement cette année. Ton bilan apparaîtra ici après ta première rencontre.';

  @override
  String yearShareText(int year) {
    return 'Mon année $year sur GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Carte de la Turquie : $count provinces explorées';
  }

  @override
  String get explorationMap => 'Ma carte d\'exploration';

  @override
  String get statExplored => 'provinces explorées';

  @override
  String get statMetAt => 'événements où nous nous sommes retrouvés';

  @override
  String get recentExplored => 'Mes dernières découvertes';

  @override
  String get explorationEmpty =>
      'Les provinces de tes événements s\'allument ici. Ta carte se colore après ta première rencontre.';

  @override
  String get findOnMap => 'Trouver des événements sur la carte';

  @override
  String explorationShareText(int count) {
    return 'J\'ai exploré $count provinces sur GWAY';
  }

  @override
  String get exploredProvinces => 'Provinces explorées';

  @override
  String get explorationPrivacy =>
      'Toi seul(e) le vois. Comptent les événements suivis sans mention « absent ».';

  @override
  String get tonightVisible =>
      'Les membres de tes groupes verront que tu es libre ce soir. Cela se désactive tout seul à 4 h.';

  @override
  String get joinedTable => 'Tu as rejoint la table.';

  @override
  String get declinedInvite => 'Tu as décliné l\'invitation.';

  @override
  String get yourStatus => 'Ton statut';

  @override
  String get visibleUntil4 => 'Tu es visible jusqu\'à 4 h';

  @override
  String get notVisible => 'Tu n\'es pas visible pour l\'instant';

  @override
  String get youreFree => 'Tu es libre';

  @override
  String get tonightIntro =>
      'Si tu es libre, fais-le savoir à tes groupes ; vous pourrez monter une petite table ensemble.';

  @override
  String get imFreeTonight => 'Je suis libre ce soir';

  @override
  String get noLongerFree => 'Tu n\'apparais plus comme libre.';

  @override
  String get turnOffStatus => 'Désactiver le statut';

  @override
  String get leftTable => 'Tu as quitté la table.';

  @override
  String get smallTable => 'Petite table';

  @override
  String get smallTableHint =>
      'Invite quelques personnes libres ; la discussion de la table s’ouvre à trois.';

  @override
  String get setUpTable => 'Monter une petite table';

  @override
  String tableInvitesSent(int count) {
    return 'Invitations envoyées à $count personnes. La discussion s’ouvre à trois.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Il faut au moins $min autres personnes libres de tes groupes (actuellement $now). Dès que quelqu’un sera libre, tu pourras monter une table ici.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes de tes groupes sont libres ce soir',
      one: '1 personne de tes groupes est libre ce soir',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Café';

  @override
  String get chipWalk => 'Petite balade';

  @override
  String get chipFood => 'Dîner';

  @override
  String get chipCinema => 'Cinéma';

  @override
  String get tonightSheetHint =>
      'Seules les personnes de tes groupes le voient. Ton statut se désactive tout seul à 4 h.';

  @override
  String get whatToDo => 'Que veux-tu faire ? (facultatif)';

  @override
  String get whatToDoHint => 'ex. : café, petite balade';

  @override
  String get imFree => 'Je suis libre';

  @override
  String get yourTable => 'Ta table';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inscrits',
      one: '1 inscrit',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en attente',
      one: '1 en attente',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'En préparation';

  @override
  String get chatOpen => 'Discussion ouverte';

  @override
  String get tableChat => 'Discussion de la table';

  @override
  String chatOpensWhen(int count) {
    return 'La discussion s’ouvre quand $count personnes de plus rejoignent. Vous y choisirez le lieu et l’heure.';
  }

  @override
  String get leaveTable => 'Quitter la table';

  @override
  String tableInviteTitle(String name) {
    return '$name a monté une petite table et t’invite.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined inscrits · $pending en attente. La discussion s’ouvre à trois.';
  }

  @override
  String get join => 'Rejoindre';

  @override
  String get notTonight => 'Pas ce soir';

  @override
  String get tonight => 'Ce soir';

  @override
  String get freeTonight => 'Libres ce soir';

  @override
  String get sharedGroupsOnly => 'Uniquement les membres de tes groupes';

  @override
  String get nobodyFree =>
      'Personne de tes groupes n\'est libre pour le moment.';

  @override
  String get howItWorks => 'Comment ça marche ?';

  @override
  String get howStep1 =>
      'Dis « Je suis libre ce soir » et écris ce que tu aimerais faire.';

  @override
  String get howStep2 =>
      'Les membres de tes groupes te voient, et tu vois qui est libre.';

  @override
  String get howStep3 =>
      'Monte une petite table ; la discussion s’ouvre à trois et vous y choisissez le lieu et l’heure.';

  @override
  String get upcoming => 'À venir';

  @override
  String get calendar => 'Agenda';

  @override
  String get noUpcomingJoined => 'Tu ne participes à aucun événement à venir.';

  @override
  String get showAll => 'Tout afficher';

  @override
  String get noUpcoming60 =>
      'Tes groupes n\'ont aucun événement dans les 60 prochains jours.';

  @override
  String get findGroup => 'Trouver un groupe';

  @override
  String filterAll(int count) {
    return 'Tous · $count';
  }

  @override
  String filterMine(int count) {
    return 'Les miens · $count';
  }

  @override
  String get tomorrow => 'Demain';

  @override
  String get going => 'Tu participes';

  @override
  String get waitlisted => 'Sur liste d\'attente';

  @override
  String get awaitingApproval => 'En attente de validation';

  @override
  String get full => 'Complet';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity participants';
  }

  @override
  String get startingSoon => 'Bientôt';

  @override
  String get next6Hours => '6 prochaines heures';

  @override
  String get wantWelcome => 'J\'aimerais être accueilli(e)';

  @override
  String get wantWelcomeHint =>
      'Un membre bénévole du groupe t’accueille à l’entrée : tu n’y vas pas seul(e).';

  @override
  String get noteForGreeter =>
      'Une note pour qu’on te reconnaisse (facultatif)';

  @override
  String get noteForGreeterHint => 'Ex. : veste rouge, sac bleu';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get welcomeRequestSent =>
      'Ta demande a été transmise aux accueillants. Nous te préviendrons quand quelqu\'un la prendra.';

  @override
  String get editMeetingNote => 'Modifier la note de rendez-vous';

  @override
  String welcomePerson(String name) {
    return 'Accueillir $name';
  }

  @override
  String describedAs(String note) {
    return 'Sa description : $note';
  }

  @override
  String get whereMeet => 'Où vous retrouverez-vous ?';

  @override
  String get whereMeetHint => 'Ex. : devant le café à l\'entrée, 8 h 45';

  @override
  String get save => 'Enregistrer';

  @override
  String get iWillWelcome => 'Je l\'accueille';

  @override
  String get noteUpdated => 'Note de rendez-vous mise à jour.';

  @override
  String youWillWelcome(String name) {
    return 'Tu accueilleras $name ; la personne a vu la note de rendez-vous.';
  }

  @override
  String get stopWelcoming => 'Ne plus accueillir';

  @override
  String stopWelcomingBody(String name) {
    return 'Nous chercherons un autre accueillant pour $name et le préviendrons.';
  }

  @override
  String get release => 'Arrêter';

  @override
  String get releasedWelcome =>
      'Tu ne l’accueilles plus ; nous cherchons un nouvel accueillant.';

  @override
  String get firstTime => 'Tu viens pour la première fois ?';

  @override
  String greetersAvailable(int count) {
    return 'Ce groupe compte $count accueillants. L’un d’eux peut t’accueillir à l’entrée et te présenter au groupe.';
  }

  @override
  String get youWelcomed => 'Tes accueils';

  @override
  String meetingAt(String note) {
    return 'Rendez-vous : $note';
  }

  @override
  String get thankedYou => 'T\'a remercié(e)';

  @override
  String optionsFor(String name) {
    return 'Options pour $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'En attente d’accueil ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes ont un accueillant.',
      one: '1 personne a un accueillant.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Première fois';

  @override
  String get max3Welcomes =>
      'Tu peux accueillir jusqu\'à 3 personnes par événement.';

  @override
  String get greeterJoinHint =>
      'Tu es accueillant(e). Participe à l’événement pour accueillir les nouveaux.';

  @override
  String get lookingGreeter => 'Recherche d’un accueillant';

  @override
  String get lookingGreeterHint =>
      'Nous avons prévenu les accueillants. Tu seras notifié(e) quand quelqu\'un acceptera.';

  @override
  String yourNote(String note) {
    return 'Ta note : $note';
  }

  @override
  String get welcomeWithdrawn => 'Ta demande d\'accueil a été retirée.';

  @override
  String get withdrawRequest => 'Retirer la demande';

  @override
  String get greetedBy => 'Accueilli(e) par';

  @override
  String get willGreet => 'T\'accueillera';

  @override
  String get thank => 'Remercier';

  @override
  String thankReceived(String name) {
    return '$name a reçu tes remerciements.';
  }

  @override
  String get thanked => 'Tu as remercié.';

  @override
  String get cancelWelcome => 'Annuler l\'accueil';

  @override
  String get nowGreeter =>
      'Tu es maintenant accueillant(e). Nous te préviendrons quand un nouveau voudra être accueilli.';

  @override
  String get noLongerGreeter => 'Tu n\'es plus accueillant(e).';

  @override
  String get welcomeSection => 'Accueil';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accueillants',
      one: '1 accueillant',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Les nouveaux peuvent demander à être accueillis depuis la page de l\'événement. Si tu deviens accueillant(e), tu seras prévenu(e) ; tu les accueilles à l\'entrée et les présentes au groupe.';

  @override
  String greeterMemberHint(int count) {
    return 'Ce groupe compte $count accueillants. À ton premier événement, appuie sur « J\'aimerais être accueilli(e) ».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Ce groupe compte $count accueillants : tu n\'iras pas seul(e) à ton premier événement, quelqu\'un t\'accueillera à l\'entrée.';
  }

  @override
  String get becomeGreeter => 'Devenir accueillant(e)';

  @override
  String quoted(String text) {
    return '« $text »';
  }

  @override
  String seatsGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String seatsOf(int count, int capacity) {
    return '$count / $capacity personnes';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return '$count / $capacity personnes · $waiting en attente';
  }

  @override
  String summaryAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes présentes',
      one: '1 personne présente',
    );
    return '$_temp0';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ ($count avis)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Liste d\'attente · ${place}e';
  }

  @override
  String get eventCanceled => 'Cet événement a été annulé.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Cet événement a été annulé : $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, $stars étoiles';
  }

  @override
  String get conflicting => 'Chevauchement';

  @override
  String get events => 'Événements';

  @override
  String get create => 'Créer';

  @override
  String eventsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il te reste $count événements ce mois-ci.',
      one: 'Il te reste 1 événement ce mois-ci.',
    );
    return '$_temp0';
  }

  @override
  String get eventsLimitReached =>
      'Le quota d’événements du mois est atteint. Passe à une formule supérieure pour en avoir plus.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · $count avis sur ses événements';
  }

  @override
  String get howWasIt => 'C\'était comment ?';

  @override
  String get howWasItHint =>
      'Note l\'événement auquel tu as participé ; tout le monde ne voit que la moyenne.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty =>
      'Randonnée, concert ou rencontre : crée le premier événement.';

  @override
  String get requestSent =>
      'Ta demande a été envoyée. Nous te préviendrons dès que l\'organisateur décidera.';

  @override
  String get attendanceSaved =>
      'Ta participation est enregistrée. Nous te le rappellerons avant le début.';

  @override
  String waitlistJoined(int place) {
    return 'Tu es sur liste d\'attente (${place}e). Nous te préviendrons dès qu\'une place se libère.';
  }

  @override
  String get conflictTitle => 'Tu as un autre événement à la même heure';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Si tu ne peux pas y aller, désiste-toi pour laisser ta place à quelqu’un.';

  @override
  String get conflictMany =>
      'Si tu ne peux pas y aller, désiste-toi pour laisser tes places à d’autres.';

  @override
  String get keepBoth => 'Garder les deux';

  @override
  String get leaveOther => 'Quitter l\'autre';

  @override
  String get leaveOthers => 'Quitter les autres';

  @override
  String get leftOther =>
      'Tu as quitté l\'autre événement ; ta place est libérée.';

  @override
  String get leftOthers => 'Tu as quitté les autres événements.';

  @override
  String approvedPerson(String name) {
    return '$name participe maintenant.';
  }

  @override
  String declinedPerson(String name) {
    return 'Demande refusée ; $name a été prévenu(e).';
  }

  @override
  String get calendarFailed =>
      'Le fichier d\'agenda n\'a pas pu s\'ouvrir. Réessaie.';

  @override
  String get stopSeriesTitle => 'Arrêter la répétition ?';

  @override
  String get stopSeriesBody =>
      'Aucune nouvelle date ne s\'ouvre. Celles déjà ouvertes restent ; tu peux les annuler une par une.';

  @override
  String get stop => 'Arrêter';

  @override
  String get seriesStopped => 'Répétition arrêtée.';

  @override
  String get eventCanceledToast => 'Événement annulé.';

  @override
  String get eventNotFound =>
      'Cet événement est introuvable ou n\'est plus visible.';

  @override
  String get goBack => 'Retour';

  @override
  String joinGroupFirst(String name) {
    return 'Rejoindre $name';
  }

  @override
  String get sendJoinRequest => 'Demander à participer';

  @override
  String get joinWaitlist => 'Rejoindre la liste d\'attente';

  @override
  String get leaveEvent => 'Me désister';

  @override
  String get leaveWaitlist => 'Quitter la liste d\'attente';

  @override
  String get requestWithdrawn => 'Ta demande a été retirée.';

  @override
  String get attendanceRemoved => 'Ta participation est annulée.';

  @override
  String eventShareText(String title) {
    return '$title · rejoins sur GWAY :';
  }

  @override
  String get eventLinkCopied => 'Lien de l\'événement copié.';

  @override
  String get report => 'Signaler';

  @override
  String get eventOptions => 'Options de l\'événement';

  @override
  String get edit => 'Modifier';

  @override
  String get cancelThisDate => 'Annuler cette date';

  @override
  String get stopRepeat => 'Arrêter la répétition';

  @override
  String get startedOrEnded => 'Commencé ou terminé';

  @override
  String seriesUntil(String label, String date) {
    return '$label · jusqu\'au $date';
  }

  @override
  String get addToCalendar => 'Ajouter à l\'agenda';

  @override
  String fee(String fee) {
    return 'Participation : $fee';
  }

  @override
  String get feeNotice =>
      'Le montant est versé à l\'organisateur ; GWAY n\'encaisse aucun paiement.';

  @override
  String get areYouComing => 'Tu viens ?';

  @override
  String get areYouComingHint =>
      'Si tu ne peux pas venir, laisse ta place à la liste d\'attente.';

  @override
  String get yesComing => 'Oui, je viens';

  @override
  String get confirmThanks =>
      'Merci, nous avons prévenu l\'organisateur de ta venue.';

  @override
  String get cantCome => 'Je ne peux pas venir';

  @override
  String get spotFreed =>
      'Ta participation est annulée ; ta place est libérée.';

  @override
  String get confirmedComing => 'Tu as confirmé ta venue.';

  @override
  String get otherEventSameTime => 'Tu as un autre événement à cette heure';

  @override
  String get needsApproval => 'Participation sur validation';

  @override
  String get requirements => 'Conditions de participation';

  @override
  String get equipment => 'Équipement nécessaire';

  @override
  String joinRequestsCount(int count) {
    return 'Demandes de participation ($count)';
  }

  @override
  String get attendees => 'Participants';

  @override
  String confirmedOf(int going, int confirmed) {
    return '$confirmed participants sur $going ont confirmé.';
  }

  @override
  String confirmedName(String name) {
    return '$name · a confirmé';
  }

  @override
  String get shareWasThere => 'Partager la carte « J’y étais »';

  @override
  String get howDidItGo => 'Comment s\'est-il passé ?';

  @override
  String reviewsCount(int count) {
    return 'Avis ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Seuls les organisateurs voient les notes.';

  @override
  String get attendanceCheck => 'Présences';

  @override
  String get attendanceCheckHint =>
      'Indique les absents ; seuls les présents comptent pour les contributions et badges. Ouvert 7 jours après la fin.';

  @override
  String markedCame(String name) {
    return '$name indiqué(e) présent(e).';
  }

  @override
  String markedMissed(String name) {
    return '$name indiqué(e) absent(e).';
  }

  @override
  String get didntCome => 'Absent';

  @override
  String get came => 'Présent';

  @override
  String get memories => 'Souvenirs';

  @override
  String get shareMemory => 'Partager un souvenir';

  @override
  String get eventPolls => 'Sondages de l\'événement';

  @override
  String get noEditPermission =>
      'Tu n\'as pas le droit de modifier cet événement.';

  @override
  String get editEvent => 'Modifier l\'événement';

  @override
  String get newEvent => 'Nouvel événement';

  @override
  String get addCover => 'Ajouter une image de couverture';

  @override
  String get titleExample => 'Ex. : Randonnée en forêt';

  @override
  String get starts => 'Début';

  @override
  String get endsOptional => 'Fin (facultatif)';

  @override
  String get notSpecified => 'Non précisé';

  @override
  String get removeEnd => 'Supprimer la fin';

  @override
  String get repeat => 'Répétition';

  @override
  String get noRepeat => 'Pas de répétition';

  @override
  String get weekly => 'Chaque semaine';

  @override
  String get biweekly => 'Toutes les deux semaines';

  @override
  String get lastDateOptional => 'Dernière date (facultatif)';

  @override
  String get untilYouStop => 'Jusqu\'à ce que tu arrêtes';

  @override
  String get removeLastDate => 'Supprimer la dernière date';

  @override
  String get repeatHint =>
      'Les dates suivantes s\'ouvrent automatiquement 4 semaines à l\'avance, chacune comptant dans le quota mensuel.';

  @override
  String get surpriseVenue => 'Lieu surprise';

  @override
  String get surpriseHint =>
      'Le lieu n\'est révélé qu\'aux participants, à l\'heure choisie avant le début.';

  @override
  String get hintPublic => 'Indice (visible par tous)';

  @override
  String get place => 'Lieu';

  @override
  String get hintExample => 'Ex. : En bord de mer, côté asiatique';

  @override
  String get placeExample => 'Ex. : Entrée du parc ou En ligne';

  @override
  String get writeHint => 'Écris un indice.';

  @override
  String get writePlace => 'Saisis le lieu.';

  @override
  String get realVenue => 'Vrai lieu (participants uniquement)';

  @override
  String get realVenueExample => 'Ex. : Devant le théâtre';

  @override
  String get writeRealVenue => 'Saisis le vrai lieu.';

  @override
  String get whenReveal => 'Quand le révéler ?';

  @override
  String hoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures avant',
      one: '1 heure avant',
    );
    return '$_temp0';
  }

  @override
  String get linkOptional => 'Lien de carte ou en ligne (facultatif)';

  @override
  String get httpsRequired => 'Le lien doit commencer par https://.';

  @override
  String get description => 'Description';

  @override
  String get capacity => 'Capacité (vide = illimitée)';

  @override
  String get capacityHint =>
      'Une fois complet, les nouveaux vont sur liste d\'attente.';

  @override
  String get capacityRange => 'La capacité doit être entre 1 et 10 000.';

  @override
  String get requirementsOptional => 'Conditions de participation (facultatif)';

  @override
  String get requirementsExample =>
      'Ex. : Au moins 10 km d’expérience de randonnée';

  @override
  String get equipmentOptional => 'Équipement nécessaire (facultatif)';

  @override
  String get equipmentExample => 'Ex. : Casque, Eau, Imperméable';

  @override
  String get equipmentHint => 'Sépare par des virgules ; 10 éléments maximum.';

  @override
  String get equipmentLimit =>
      '10 éléments maximum, 60 caractères chacun au plus.';

  @override
  String get approvalRequired => 'Participation sur validation';

  @override
  String get approvalHint =>
      'Les personnes intéressées envoient une demande ; tu la valides.';

  @override
  String get feeOptional => 'Participation (facultatif)';

  @override
  String get feeInfoOnly =>
      'Affiché à titre informatif ; GWAY n\'encaisse aucun paiement.';

  @override
  String get amount => 'Montant';

  @override
  String get amountExample => 'Ex. : 150';

  @override
  String get validAmount => 'Saisis un montant valide.';

  @override
  String get paymentNote => 'Note de paiement';

  @override
  String get paymentNoteExample => 'Ex. : Payé en espèces sur place';

  @override
  String get createEvent => 'Créer l\'événement';

  @override
  String get rateEvent => 'Évaluer l\'événement';

  @override
  String get yourReview => 'Ton avis';

  @override
  String starsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get noteToOrganizers => 'Note aux organisateurs (facultatif)';

  @override
  String get noteToOrganizersHint =>
      'Seuls les organisateurs voient ta note ; les autres ne voient que la moyenne.';

  @override
  String get reviewDeleted => 'Ton avis a été supprimé.';

  @override
  String get delete => 'Supprimer';

  @override
  String get reviewSaved => 'Merci, ton avis a été enregistré.';

  @override
  String get groupNext => 'Prochains événements du groupe';

  @override
  String sameDayOthers(int count) {
    return 'Il y a $count autres événements de la même catégorie dans ta province à cette date. Choisis un autre jour pour éviter à tes membres de devoir choisir.';
  }

  @override
  String get cancelEvent => 'Annuler l\'événement';

  @override
  String get cancelEventBody =>
      'Les participants et la liste d\'attente sont prévenus. C\'est irréversible.';

  @override
  String get reason => 'Motif';

  @override
  String get cancelAction => 'Annuler';

  @override
  String hint(String hint) {
    return 'Indice : $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Indice : $hint · Révélé aux participants le $when.';
  }

  @override
  String get venueRevealed =>
      'Le lieu a été révélé aux participants. Participe pour le voir.';

  @override
  String venueRevealAt(String when) {
    return 'Le lieu sera révélé aux participants le $when.';
  }

  @override
  String get currencyTry => '₺ TRY';

  @override
  String get badgeFirstStep => 'Premier pas';

  @override
  String get badgeFirstStepText => 'Participe à ton premier événement.';

  @override
  String get badgeRegular => 'Habitué';

  @override
  String get badgeRegularText => 'Participe à 10 événements.';

  @override
  String get badgeCompanion => 'Compagnon de route';

  @override
  String get badgeCompanionText => 'Participe à 25 événements.';

  @override
  String get badgeExplorer => 'Explorateur';

  @override
  String get badgeExplorerText =>
      'Participe aux événements de 3 groupes différents.';

  @override
  String get badgeOrganizer => 'Organisateur';

  @override
  String get badgeOrganizerText =>
      'Organise un événement avec au moins 2 participants.';

  @override
  String get badgeMasterOrganizer => 'Organisateur chevronné';

  @override
  String get badgeMasterOrganizerText =>
      'Organise 10 événements avec au moins 2 participants.';

  @override
  String get badgeStoryteller => 'Gardien de souvenirs';

  @override
  String get badgeStorytellerText =>
      'Ajoute 5 souvenirs aux événements auxquels tu as participé.';

  @override
  String get badgeFeedback => 'Donneur d\'avis';

  @override
  String get badgeFeedbackText => 'Note 5 événements auxquels tu as participé.';

  @override
  String get badgeDoorOpener => 'Porte ouverte';

  @override
  String get badgeDoorOpenerText => 'Accueille un nouveau venu à un événement.';

  @override
  String get badgeHost => 'Hôte';

  @override
  String get badgeHostText => 'Accueille 5 nouveaux venus.';

  @override
  String get badgeCommunityHeart => 'Cœur de la communauté';

  @override
  String get badgeCommunityHeartText => 'Accueille 20 nouveaux venus.';

  @override
  String get badgeFriendly => 'Sociable';

  @override
  String get badgeFriendlyText => 'Fais 5 poignées de main lors d’événements.';

  @override
  String get badgeSocialButterfly => 'Papillon social';

  @override
  String get badgeSocialButterflyText =>
      'Fais 25 poignées de main lors d’événements.';

  @override
  String get badgeCategory => 'Fan de catégorie';

  @override
  String get badgeCategoryText =>
      'Participe à 5 événements d’une même catégorie.';

  @override
  String badgeCategoryOf(String category) {
    return 'Fan de $category';
  }

  @override
  String badgeCategoryOfText(String category) {
    return 'A participé à 5 événements en $category.';
  }

  @override
  String badgeGoal(String goal) {
    return 'Objectif : $goal';
  }

  @override
  String badgeGoalText(String group) {
    return 'A atteint un objectif de $group.';
  }
}
