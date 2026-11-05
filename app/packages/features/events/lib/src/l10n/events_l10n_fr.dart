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
    return '$name (@$username)';
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
    return '@$username · $event · $date';
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
}
