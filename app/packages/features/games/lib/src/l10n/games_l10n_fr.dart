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
}
