// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class GamesL10nFr extends GamesL10n {
  GamesL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get chess => 'Échecs';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rapide';

  @override
  String get white => 'Blancs';

  @override
  String get black => 'Noirs';

  @override
  String get colorRandom => 'Au hasard';

  @override
  String get endCheckmate => 'Échec et mat';

  @override
  String get endResign => 'Abandon';

  @override
  String get endTimeout => 'Temps écoulé';

  @override
  String get endTimeoutDraw => 'Temps écoulé, l\'adversaire ne peut pas mater';

  @override
  String get endStalemate => 'Pat';

  @override
  String get endInsufficient => 'Matériel insuffisant';

  @override
  String get endFiftyMoves => 'Règle des 50 coups';

  @override
  String get endRepetition => 'Triple répétition';

  @override
  String get endAgreement => 'Nulle par accord';

  @override
  String get endAborted => 'Annulée';

  @override
  String get boardLabel => 'Plateau d\'échecs';

  @override
  String get promoteTo => 'Promouvoir le pion en';

  @override
  String get queen => 'Dame';

  @override
  String get rook => 'Tour';

  @override
  String get bishop => 'Fou';

  @override
  String get knight => 'Cavalier';

  @override
  String get medalGold => 'Médaille d\'or';

  @override
  String get medalSilver => 'Médaille d\'argent';

  @override
  String get medalBronze => 'Médaille de bronze';

  @override
  String get youWon => 'Tu as gagné';

  @override
  String get youLost => 'Tu as perdu';

  @override
  String get draw => 'Nulle';

  @override
  String get inProgress => 'En cours';

  @override
  String get whiteWon => 'Les blancs gagnent';

  @override
  String get blackWon => 'Les noirs gagnent';

  @override
  String get rated => 'Classée';

  @override
  String get casual => 'Amicale';

  @override
  String get ratedHint => 'Le résultat modifie ton classement Elo.';

  @override
  String get flipBoard => 'Retourner le plateau';

  @override
  String get cancel => 'Annuler';

  @override
  String get resign => 'Abandonner';

  @override
  String get resignTitle => 'Abandonner la partie ?';

  @override
  String get resignBody =>
      'Ton adversaire gagne ; dans une partie classée, ton Elo baisse.';

  @override
  String get abort => 'Annuler';

  @override
  String get offerDraw => 'Nulle ?';

  @override
  String get drawOffered => 'Proposée';

  @override
  String get drawOfferReceived => 'Ton adversaire propose la nulle.';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get rematch => 'Revanche';

  @override
  String get rematchSent => 'Revanche demandée.';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String newRating(String category, int rating) {
    return 'Ton classement $category : $rating';
  }

  @override
  String get deletedPlayer => 'Compte supprimé';

  @override
  String get firstMove => 'Premier coup : 30 s';

  @override
  String get noMovesYet => 'Aucun coup pour le moment. Les blancs commencent.';

  @override
  String get watching => 'Tu regardes';

  @override
  String get quickGame => 'Partie rapide';

  @override
  String get quickGameHint =>
      'Choisis une cadence et affronte quelqu\'un de ton niveau.';

  @override
  String get searching => 'Recherche d’un adversaire…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Depuis $count secondes',
      one: 'Depuis 1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Profil d\'échecs';

  @override
  String get recentGames => 'Parties récentes';

  @override
  String get noGamesMine => 'Aucune partie pour le moment. Joue la première.';

  @override
  String get noGamesTheirs => 'Aucune partie. Défie-le pour sa première.';

  @override
  String get playNow => 'Jouer maintenant';

  @override
  String get challenge => 'Défier';

  @override
  String get noFlag => 'Aucun drapeau choisi';

  @override
  String get chooseFlag => 'Choisis ton drapeau';

  @override
  String get chooseFlagHint =>
      'Il apparaît à côté de ton nom dans le classement.';

  @override
  String get searchCountry => 'Rechercher un pays';

  @override
  String get flagSaved => 'Drapeau enregistré.';

  @override
  String get pickFlagPrompt => 'Choisis le drapeau affiché au classement.';

  @override
  String get suspendedNotice =>
      'Les échecs sont fermés pour cette personne pour le moment.';

  @override
  String get notPlayed => 'Pas joué';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return '${rank}e au classement';
  }

  @override
  String get leaderboard => 'Classement';

  @override
  String leaderboardEmpty(int count) {
    return 'Joue $count parties classées dans cette catégorie pour entrer au classement.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}V · ${draws}N · ${losses}D';
  }

  @override
  String get seeAll => 'Tout voir';

  @override
  String get invitations => 'Défis';

  @override
  String invitesYou(String what) {
    return 'T\'invite à une partie : $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Veut une revanche : $what';
  }

  @override
  String waitingFor(String what) {
    return 'En attente de réponse : $what';
  }

  @override
  String get withdraw => 'Retirer';

  @override
  String get gameInProgress => 'Tu as une partie en cours';

  @override
  String get resume => 'Reprendre';

  @override
  String get challengeFriend => 'Défier un ami';

  @override
  String get challengeSent =>
      'Défi envoyé. La partie commence dès qu\'il est accepté.';

  @override
  String get challengeTitle => 'Inviter à une partie';

  @override
  String get changePerson => 'Changer de personne';

  @override
  String get searchPerson => 'Nom d\'utilisateur ou nom';

  @override
  String get timeControl => 'Cadence';

  @override
  String get yourColor => 'Ta couleur';

  @override
  String get sendChallenge => 'Envoyer le défi';

  @override
  String get teamMatch => 'Match par équipes';

  @override
  String get teamMatches => 'Matchs par équipes';

  @override
  String get teamMatchesHint =>
      'Les matchs d\'échecs de tes groupes ; le résultat change l\'Elo du groupe.';

  @override
  String get noTeamMatches =>
      'Aucun match par équipes. Invite un autre groupe au nom du tien.';

  @override
  String get newTeamMatch => 'Organiser un match';

  @override
  String get newTeamMatchHint =>
      'Dès que l\'autre groupe accepte, chaque groupe compose son équipe.';

  @override
  String get yourGroup => 'Ton groupe';

  @override
  String get opponentGroup => 'Groupe adverse';

  @override
  String get searchGroup => 'Nom ou identifiant du groupe';

  @override
  String get startsAt => 'Début';

  @override
  String get sendTeamInvite => 'Inviter le groupe';

  @override
  String get boards => 'Échiquiers';

  @override
  String get boardsShort => 'échiquiers';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count échiquiers',
      one: '1 échiquier',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Elo du groupe $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'En attente';

  @override
  String get teamAccepted => 'Accepté';

  @override
  String get teamDeclined => 'Refusé';

  @override
  String get teamCanceled => 'Annulé';

  @override
  String get teamLive => 'En cours';

  @override
  String get teamFinished => 'Terminé';

  @override
  String teamInviteReceived(String group) {
    return '$group invite votre groupe à un match par équipes.';
  }

  @override
  String get teamAcceptedDone =>
      'Match accepté. Composez maintenant votre équipe.';

  @override
  String get teamDeclinedDone => 'Invitation refusée.';

  @override
  String get teamCanceledDone => 'Match annulé.';

  @override
  String get callOff => 'Annuler le match';

  @override
  String get lineupHint =>
      'Un échiquier vide au début compte comme un point pour l\'adversaire.';

  @override
  String get lineupSheetHint =>
      'Touche les membres pour les placer dans l’ordre ; l’échiquier 1 revient au plus fort.';

  @override
  String editLineup(String group) {
    return 'Composition $group';
  }

  @override
  String get saveLineup => 'Enregistrer';

  @override
  String get emptyBoard => 'Vide';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games parties';
  }

  @override
  String get groupsTab => 'Groupes';

  @override
  String get groupLeaderboardEmpty =>
      'Aucun groupe n\'a encore joué de match par équipes. Sois le premier.';

  @override
  String get backToChess => 'Retour aux échecs';

  @override
  String get arena => 'Tournoi';

  @override
  String get tournaments => 'Tournois';

  @override
  String get tournamentsHint =>
      'Tournois arène hebdomadaires et mensuels ; le top 3 reçoit une médaille.';

  @override
  String get weeklyArena => 'Arène hebdomadaire';

  @override
  String get monthlyArena => 'Arène mensuelle';

  @override
  String get arenaRules =>
      'Arène : joue autant de parties que tu veux jusqu\'à la fin. Victoire 2 points, nulle 1 ; après deux victoires d\'affilée, les points sont doublés jusqu\'à la fin de la série. Les parties commencées avant la fin comptent.';

  @override
  String get arenaLiveNow => 'En cours';

  @override
  String get arenaUpcoming => 'À venir';

  @override
  String get arenaFinished => 'Terminés';

  @override
  String get registered => 'Inscrit';

  @override
  String get arenaRegister => 'S\'inscrire';

  @override
  String get arenaRegistered =>
      'Tu es inscrit. Tu seras prévenu au début et apparié dès que tu ouvres le tournoi.';

  @override
  String get arenaJoin => 'Rejoindre';

  @override
  String get arenaResume => 'Reprendre';

  @override
  String get arenaPause => 'Faire une pause';

  @override
  String get arenaWaiting =>
      'En attente d\'un adversaire ; la partie s\'ouvre dès qu\'un joueur proche de ton score est libre.';

  @override
  String get backToGame => 'Retour à la partie';

  @override
  String get backToArena => 'Retour au tournoi';

  @override
  String get backToTeamMatch => 'Retour au match par équipes';

  @override
  String arenaStartsIn(String time) {
    return 'Commence dans $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Encore $time';
  }

  @override
  String get arenaLastGames =>
      'Temps écoulé ; les dernières parties se terminent';

  @override
  String arenaFinishedAt(String time) {
    return 'Terminé · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs',
      one: '1 joueur',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points points · $games parties';
  }

  @override
  String get onFire => 'En série : le prochain résultat compte double';

  @override
  String get standings => 'Classement';

  @override
  String get arenaEmpty => 'Personne n\'a encore rejoint. Sois le premier.';

  @override
  String performance(int value) {
    return 'Performance $value';
  }

  @override
  String get playingNow => 'en partie';

  @override
  String get arenaMedals => 'Médailles de tournoi';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Médailles : $gold or, $silver argent, $bronze bronze';
  }

  @override
  String get firstMoveTeam => 'Premier coup : 5 min';

  @override
  String get games => 'Jeux';

  @override
  String get gamesIntro =>
      'Joue avec ta communauté : parties rapides, tournois et matchs entre groupes.';

  @override
  String get chessCardText =>
      'Classement Elo, tournois hebdomadaires et mensuels, matchs par équipes entre groupes et médailles.';

  @override
  String get playChess => 'Jouer aux échecs';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Prochain tournoi : $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count défis en attente',
      one: '1 défi en attente',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Jouer en ligne';

  @override
  String findOpponent(String tc) {
    return 'Trouver un adversaire · $tc';
  }

  @override
  String get challengeFriendHint => 'Choisis la cadence et la couleur';

  @override
  String get leaderboardHint => 'Classements Elo et médailles';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matchs ouverts',
      one: '1 match ouvert',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Plateau et pièces';

  @override
  String get boardTheme => 'Plateau';

  @override
  String get pieceSet => 'Pièces';

  @override
  String get boardWood => 'Bois';

  @override
  String get boardGreen => 'Vert';

  @override
  String get boardBlue => 'Bleu';

  @override
  String get boardSlate => 'Gris';

  @override
  String get boardLilac => 'Lilas GWAY';

  @override
  String get piecesClassic => 'Classique';

  @override
  String get piecesCeltic => 'Celtique';

  @override
  String get piecesSpatial => 'Spatial';

  @override
  String get piecesFantasy => 'Fantaisie';

  @override
  String get piecesModern => 'Moderne';

  @override
  String get piecesWarm => 'Chaleureux';

  @override
  String get firstPosition => 'Début';

  @override
  String get previousMove => 'Coup précédent';

  @override
  String get nextMove => 'Coup suivant';

  @override
  String get lastPosition => 'Position actuelle';

  @override
  String get backToLive => 'Retour au direct';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'rouge',
      'red_f': 'rouge',
      'red_n': 'rouge',
      'blue_m': 'bleu',
      'blue_f': 'bleue',
      'blue_n': 'bleu',
      'green_m': 'vert',
      'green_f': 'verte',
      'green_n': 'vert',
      'yellow_m': 'jaune',
      'yellow_f': 'jaune',
      'yellow_n': 'jaune',
      'purple_m': 'violet',
      'purple_f': 'violette',
      'purple_n': 'violet',
      'orange_m': 'orange',
      'orange_f': 'orange',
      'orange_n': 'orange',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'uni',
      'solid_f': 'unie',
      'solid_n': 'uni',
      'striped_m': 'rayé',
      'striped_f': 'rayée',
      'striped_n': 'rayé',
      'dotted_m': 'à pois',
      'dotted_f': 'à pois',
      'dotted_n': 'à pois',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'cercle',
      'square': 'carré',
      'triangle': 'triangle',
      'star': 'étoile',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
      'square': 'm',
      'triangle': 'm',
      'star': 'f',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindFigure(String color, String pattern, String shape) {
    return '$shape $color $pattern';
  }

  @override
  String get mindDuel => 'Duel mental';

  @override
  String get mindCardText =>
      'Un duel en direct : calcul, attention, mémoire et réflexes. Classement Elo, palmarès et médailles.';

  @override
  String get mindPlay => 'Lancer un duel';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length questions';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Combien de questions ?';

  @override
  String mindRatingAt(int count) {
    return 'Ton classement à $count questions';
  }

  @override
  String get mindFindOpponent => 'Trouver un adversaire';

  @override
  String get mindSuspended => 'Tu ne peux pas jouer pour le moment.';

  @override
  String get mindActive => 'Tu as un duel en cours';

  @override
  String get mindProfile => 'Profil de duel';

  @override
  String get mindHowTo => 'Comment jouer';

  @override
  String get mindRecent => 'Derniers duels';

  @override
  String get mindNoMatchesMine =>
      'Aucun duel pour le moment. Trouve ton premier adversaire.';

  @override
  String get mindNoMatchesTheirs =>
      'Aucun duel pour le moment. Sois le premier à le défier.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Joue $count duels classés de cette longueur pour entrer au classement.';
  }

  @override
  String get mindChallengeTitle => 'Défier en duel';

  @override
  String get mindChallengeSent =>
      'Défi envoyé. Le duel commence dès son acceptation.';

  @override
  String get mindKindMath => 'Calcul';

  @override
  String get mindKindAttention => 'Attention';

  @override
  String get mindKindMemory => 'Mémoire';

  @override
  String get mindKindReflex => 'Réflexes';

  @override
  String get mindKindMathHint =>
      'Les quatre opérations, avec les priorités. Choisis le bon résultat.';

  @override
  String get mindKindAttentionHint =>
      'Ignore la couleur du texte : choisis la figure décrite.';

  @override
  String get mindKindMemoryHint =>
      'Retiens les lettres et chiffres colorés, dans l\'ordre et en couleur.';

  @override
  String get mindKindReflexHint =>
      'Touche la cible dès qu\'elle apparaît. Trop tôt ou à côté coûte des points.';

  @override
  String get mindScoringHint =>
      'Les réponses justes et rapides rapportent plus. Le meilleur total gagne.';

  @override
  String get mindYou => 'Toi';

  @override
  String get mindOpponent => 'Adversaire';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who : $done/$total questions';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Prépare-toi';

  @override
  String get mindYouFinished => 'C\'est fini pour toi !';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Ton adversaire en est à $done/$total. Le résultat arrive à la fin.';
  }

  @override
  String get mindMathPrompt => 'Quel est le résultat ?';

  @override
  String get mindAttentionPrompt => 'Choisis la figure décrite';

  @override
  String get mindMemoryLook => 'Retiens l\'ordre et les couleurs';

  @override
  String get mindMemoryPick =>
      'Choisis-les dans le même ordre et les mêmes couleurs';

  @override
  String mindCharLabel(String char, String color) {
    return '$char $color';
  }

  @override
  String get mindUndo => 'Annuler';

  @override
  String get mindReflexTarget => 'Cible';

  @override
  String get mindReflexWait => 'Attends…';

  @override
  String get mindReflexTap => 'Touche maintenant !';

  @override
  String mindRight(int points) {
    return 'Juste · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'En partie juste · +$points';
  }

  @override
  String get mindWrong => 'Faux';

  @override
  String mindWrongPenalty(int points) {
    return 'Faux · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Trop tôt · −$points';
  }

  @override
  String get mindResignTitle => 'Abandonner le duel ?';

  @override
  String get mindResignBody =>
      'Ton adversaire gagne ; en duel classé, ton Elo baisse.';

  @override
  String get mindFinished => 'Duel terminé';

  @override
  String get mindEndCompleted => 'Toutes les questions répondues';

  @override
  String get mindEndTime => 'Temps écoulé';

  @override
  String mindNewRating(int rating) {
    return 'Nouveau classement $rating';
  }

  @override
  String get mindNewDuel => 'Nouveau duel';

  @override
  String get mindBackHome => 'Retour aux duels';

  @override
  String get mindTeamMatches => 'Duels de groupes';

  @override
  String get mindTeamMatchesHint =>
      'Les duels de tes groupes contre d\'autres ; le résultat change l\'Elo de duel du groupe.';

  @override
  String get mindNoTeamMatches =>
      'Aucun duel de groupes pour le moment. Défie un autre groupe au nom du tien.';

  @override
  String get mindNewTeamMatch => 'Organiser un duel de groupes';

  @override
  String get mindNewTeamHint =>
      'Une fois accepté, chaque groupe compose son équipe. Au départ, les deux joueurs de chaque place s\'affrontent en même temps.';

  @override
  String get mindTeamMatch => 'Duel de groupes';

  @override
  String get mindSeats => 'Places';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Une place vide au départ compte pour l\'adversaire. La première question attend 5 minutes.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Aucun groupe n\'a encore joué de duel. Que le tien organise le premier.';

  @override
  String get mindTournaments => 'Tournois';

  @override
  String get mindTournamentsHint =>
      'Chaque samedi à 21:00 (10 questions), et le dernier samedi du mois à 19:00 (20 questions) ; les trois premiers ont une médaille.';

  @override
  String get mindNoTournaments => 'Aucun tournoi à venir.';
}
