// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class GamesL10nIt extends GamesL10n {
  GamesL10nIt([String locale = 'it']) : super(locale);

  @override
  String get chess => 'Scacchi';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rapid';

  @override
  String get white => 'Bianco';

  @override
  String get black => 'Nero';

  @override
  String get colorRandom => 'Casuale';

  @override
  String get endCheckmate => 'Scacco matto';

  @override
  String get endResign => 'Abbandono';

  @override
  String get endTimeout => 'Tempo scaduto';

  @override
  String get endTimeoutDraw =>
      'Tempo scaduto, l\'avversario non può dare matto';

  @override
  String get endStalemate => 'Stallo';

  @override
  String get endInsufficient => 'Materiale insufficiente';

  @override
  String get endFiftyMoves => 'Regola delle 50 mosse';

  @override
  String get endRepetition => 'Triplice ripetizione';

  @override
  String get endAgreement => 'Patta concordata';

  @override
  String get endAborted => 'Annullata';

  @override
  String get boardLabel => 'Scacchiera';

  @override
  String get promoteTo => 'Promuovi il pedone a';

  @override
  String get queen => 'Donna';

  @override
  String get rook => 'Torre';

  @override
  String get bishop => 'Alfiere';

  @override
  String get knight => 'Cavallo';

  @override
  String get medalGold => 'Medaglia d\'oro';

  @override
  String get medalSilver => 'Medaglia d\'argento';

  @override
  String get medalBronze => 'Medaglia di bronzo';

  @override
  String get youWon => 'Hai vinto';

  @override
  String get youLost => 'Hai perso';

  @override
  String get draw => 'Patta';

  @override
  String get inProgress => 'In corso';

  @override
  String get whiteWon => 'Vince il bianco';

  @override
  String get blackWon => 'Vince il nero';

  @override
  String get rated => 'Classificata';

  @override
  String get casual => 'Amichevole';

  @override
  String get ratedHint => 'Il risultato cambia il tuo Elo.';

  @override
  String get flipBoard => 'Ruota la scacchiera';

  @override
  String get cancel => 'Annulla';

  @override
  String get resign => 'Abbandona';

  @override
  String get resignTitle => 'Abbandonare la partita?';

  @override
  String get resignBody =>
      'L\'avversario vince; in una partita classificata il tuo Elo scende.';

  @override
  String get abort => 'Annulla';

  @override
  String get offerDraw => 'Patta?';

  @override
  String get drawOffered => 'Proposta';

  @override
  String get drawOfferReceived => 'Il tuo avversario propone la patta.';

  @override
  String get accept => 'Accetta';

  @override
  String get decline => 'Rifiuta';

  @override
  String get rematch => 'Rivincita';

  @override
  String get rematchSent => 'Rivincita richiesta.';

  @override
  String get newGame => 'Nuova partita';

  @override
  String newRating(String category, int rating) {
    return 'Il tuo Elo $category: $rating';
  }

  @override
  String get deletedPlayer => 'Account eliminato';

  @override
  String get firstMove => 'Prima mossa: 30 s';

  @override
  String get noMovesYet => 'Ancora nessuna mossa. Inizia il bianco.';

  @override
  String get watching => 'Stai guardando';

  @override
  String get quickGame => 'Partita veloce';

  @override
  String get quickGameHint =>
      'Scegli una cadenza e gioca con qualcuno del tuo livello.';

  @override
  String get searching => 'Ricerca avversario…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In attesa da $count secondi',
      one: 'In attesa da 1 secondo',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Profilo scacchistico';

  @override
  String get recentGames => 'Partite recenti';

  @override
  String get noGamesMine => 'Ancora nessuna partita. Gioca la prima.';

  @override
  String get noGamesTheirs => 'Ancora nessuna partita. Sfidalo per la prima.';

  @override
  String get playNow => 'Gioca ora';

  @override
  String get challenge => 'Sfida';

  @override
  String get noFlag => 'Nessuna bandiera';

  @override
  String get chooseFlag => 'Scegli la tua bandiera';

  @override
  String get chooseFlagHint => 'Appare accanto al tuo nome in classifica.';

  @override
  String get searchCountry => 'Cerca paese';

  @override
  String get flagSaved => 'Bandiera salvata.';

  @override
  String get pickFlagPrompt => 'Scegli la bandiera da mostrare in classifica.';

  @override
  String get suspendedNotice =>
      'Gli scacchi sono chiusi per questa persona al momento.';

  @override
  String get notPlayed => 'Non giocato';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '1 partita',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return '$rankº posto';
  }

  @override
  String get leaderboard => 'Classifica';

  @override
  String leaderboardEmpty(int count) {
    return 'Gioca $count partite classificate in questa categoria per entrare in classifica.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}V · ${draws}P · ${losses}S';
  }

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get invitations => 'Inviti';

  @override
  String invitesYou(String what) {
    return 'Ti invita a una partita: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Vuole la rivincita: $what';
  }

  @override
  String waitingFor(String what) {
    return 'In attesa di risposta: $what';
  }

  @override
  String get withdraw => 'Ritira';

  @override
  String get gameInProgress => 'Hai una partita in corso';

  @override
  String get resume => 'Riprendi';

  @override
  String get challengeFriend => 'Sfida un amico';

  @override
  String get challengeSent =>
      'Invito inviato. La partita inizia quando viene accettato.';

  @override
  String get challengeTitle => 'Invita a una partita';

  @override
  String get changePerson => 'Cambia persona';

  @override
  String get searchPerson => 'Nome utente o nome';

  @override
  String get timeControl => 'Cadenza';

  @override
  String get yourColor => 'Il tuo colore';

  @override
  String get sendChallenge => 'Invia invito';

  @override
  String get teamMatch => 'Incontro a squadre';

  @override
  String get teamMatches => 'Incontri a squadre';

  @override
  String get teamMatchesHint =>
      'Gli incontri di scacchi dei tuoi gruppi; il risultato cambia l\'Elo del gruppo.';

  @override
  String get noTeamMatches =>
      'Ancora nessun incontro. Sfida un altro gruppo a nome del tuo.';

  @override
  String get newTeamMatch => 'Organizza incontro';

  @override
  String get newTeamMatchHint =>
      'Quando l\'altro gruppo accetta, entrambi schierano i giocatori.';

  @override
  String get yourGroup => 'Il tuo gruppo';

  @override
  String get opponentGroup => 'Gruppo avversario';

  @override
  String get searchGroup => 'Nome o handle del gruppo';

  @override
  String get startsAt => 'Inizio';

  @override
  String get sendTeamInvite => 'Invita il gruppo';

  @override
  String get boards => 'Scacchiere';

  @override
  String get boardsShort => 'scacchiere';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scacchiere',
      one: '1 scacchiera',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Elo del gruppo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'In attesa di risposta';

  @override
  String get teamAccepted => 'Accettato';

  @override
  String get teamDeclined => 'Rifiutato';

  @override
  String get teamCanceled => 'Annullato';

  @override
  String get teamLive => 'In corso';

  @override
  String get teamFinished => 'Concluso';

  @override
  String teamInviteReceived(String group) {
    return '$group sfida il vostro gruppo a un incontro a squadre.';
  }

  @override
  String get teamAcceptedDone =>
      'Incontro accettato. Ora schierate i giocatori.';

  @override
  String get teamDeclinedDone => 'Invito rifiutato.';

  @override
  String get teamCanceledDone => 'Incontro annullato.';

  @override
  String get callOff => 'Annulla l\'incontro';

  @override
  String get lineupHint =>
      'Una scacchiera vuota all\'inizio vale un punto per l\'avversario.';

  @override
  String get lineupSheetHint =>
      'Tocca i membri per metterli in ordine; la scacchiera 1 è del più forte.';

  @override
  String editLineup(String group) {
    return 'Formazione $group';
  }

  @override
  String get saveLineup => 'Salva formazione';

  @override
  String get emptyBoard => 'Vuoto';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games partite';
  }

  @override
  String get groupsTab => 'Gruppi';

  @override
  String get groupLeaderboardEmpty =>
      'Nessun gruppo ha ancora giocato un incontro a squadre. Sii il primo.';

  @override
  String get backToChess => 'Torna agli scacchi';

  @override
  String get arena => 'Torneo';

  @override
  String get tournaments => 'Tornei';

  @override
  String get tournamentsHint =>
      'Tornei arena settimanali e mensili; i primi tre vincono una medaglia.';

  @override
  String get weeklyArena => 'Arena settimanale';

  @override
  String get monthlyArena => 'Arena mensile';

  @override
  String get arenaRules =>
      'Arena: gioca quante partite vuoi fino alla fine. Vittoria 2 punti, patta 1; dopo due vittorie di fila i punti raddoppiano finché la serie dura. Contano le partite iniziate prima della fine.';

  @override
  String get arenaLiveNow => 'In corso ora';

  @override
  String get arenaUpcoming => 'In arrivo';

  @override
  String get arenaFinished => 'Conclusi';

  @override
  String get registered => 'Iscritto';

  @override
  String get arenaRegister => 'Iscriviti';

  @override
  String get arenaRegistered =>
      'Sei iscritto. Ti avviseremo all\'inizio e verrai abbinato appena apri il torneo.';

  @override
  String get arenaJoin => 'Partecipa';

  @override
  String get arenaResume => 'Continua a giocare';

  @override
  String get arenaPause => 'Fai una pausa';

  @override
  String get arenaWaiting =>
      'In attesa di un avversario; la partita si apre da sola quando qualcuno con un punteggio vicino è libero.';

  @override
  String get backToGame => 'Torna alla partita';

  @override
  String get backToArena => 'Torna al torneo';

  @override
  String get backToTeamMatch => 'Torna all\'incontro';

  @override
  String arenaStartsIn(String time) {
    return 'Inizia tra $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Mancano $time';
  }

  @override
  String get arenaLastGames =>
      'Tempo scaduto; le ultime partite stanno finendo';

  @override
  String arenaFinishedAt(String time) {
    return 'Concluso · $time';
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
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocatori',
      one: '1 giocatore',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points punti · $games partite';
  }

  @override
  String get onFire => 'In serie: il prossimo risultato vale doppio';

  @override
  String get standings => 'Classifica';

  @override
  String get arenaEmpty => 'Ancora nessuno. Sii il primo.';

  @override
  String performance(int value) {
    return 'Performance $value';
  }

  @override
  String get playingNow => 'in partita';

  @override
  String get arenaMedals => 'Medaglie dei tornei';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Medaglie: $gold oro, $silver argento, $bronze bronzo';
  }

  @override
  String get firstMoveTeam => 'Prima mossa: 5 min';

  @override
  String get games => 'Giochi';

  @override
  String get gamesIntro =>
      'Gioca con la tua community: partite veloci, tornei e incontri tra gruppi.';

  @override
  String get chessCardText =>
      'Elo, tornei settimanali e mensili, incontri a squadre tra gruppi e medaglie.';

  @override
  String get playChess => 'Gioca a scacchi';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Prossimo torneo: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inviti in attesa',
      one: '1 invito in attesa',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Gioca online';

  @override
  String findOpponent(String tc) {
    return 'Trova avversario · $tc';
  }

  @override
  String get challengeFriendHint => 'Scegli tu tempo e colore';

  @override
  String get leaderboardHint => 'Classifiche Elo e medaglie';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incontri aperti',
      one: '1 incontro aperto',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Scacchiera e pezzi';

  @override
  String get boardTheme => 'Scacchiera';

  @override
  String get pieceSet => 'Pezzi';

  @override
  String get boardWood => 'Legno';

  @override
  String get boardGreen => 'Verde';

  @override
  String get boardBlue => 'Blu';

  @override
  String get boardSlate => 'Grigio';

  @override
  String get boardLilac => 'Lilla GWAY';

  @override
  String get piecesClassic => 'Classici';

  @override
  String get piecesCeltic => 'Celtici';

  @override
  String get piecesSpatial => 'Spaziale';

  @override
  String get piecesFantasy => 'Fantasy';

  @override
  String get piecesModern => 'Moderni';

  @override
  String get piecesWarm => 'Caldi';

  @override
  String get firstPosition => 'Inizio';

  @override
  String get previousMove => 'Mossa precedente';

  @override
  String get nextMove => 'Mossa successiva';

  @override
  String get lastPosition => 'Posizione attuale';

  @override
  String get backToLive => 'Torna alla diretta';

  @override
  String pointsShort(int points) {
    return '$points pt';
  }
}
