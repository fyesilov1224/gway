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

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'rosso',
      'red_f': 'rossa',
      'red_n': 'rosso',
      'blue_m': 'blu',
      'blue_f': 'blu',
      'blue_n': 'blu',
      'green_m': 'verde',
      'green_f': 'verde',
      'green_n': 'verde',
      'yellow_m': 'giallo',
      'yellow_f': 'gialla',
      'yellow_n': 'giallo',
      'purple_m': 'viola',
      'purple_f': 'viola',
      'purple_n': 'viola',
      'orange_m': 'arancione',
      'orange_f': 'arancione',
      'orange_n': 'arancione',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'in tinta unita',
      'solid_f': 'in tinta unita',
      'solid_n': 'in tinta unita',
      'striped_m': 'a righe',
      'striped_f': 'a righe',
      'striped_n': 'a righe',
      'dotted_m': 'a pois',
      'dotted_f': 'a pois',
      'dotted_n': 'a pois',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'cerchio',
      'square': 'quadrato',
      'triangle': 'triangolo',
      'star': 'stella',
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
  String get mindDuel => 'Duello mentale';

  @override
  String get mindCardText =>
      'Un duello dal vivo tra calcolo, attenzione, memoria e riflessi. Elo, classifiche e medaglie.';

  @override
  String get mindPlay => 'Inizia un duello';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length domande';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domande',
      one: '1 domanda',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Quante domande?';

  @override
  String mindRatingAt(int count) {
    return 'Il tuo punteggio con $count domande';
  }

  @override
  String get mindFindOpponent => 'Trova un avversario';

  @override
  String get mindSuspended => 'Al momento non puoi giocare.';

  @override
  String get mindActive => 'Hai un duello in corso';

  @override
  String get mindProfile => 'Profilo duello';

  @override
  String get mindHowTo => 'Come si gioca';

  @override
  String get mindRecent => 'Duelli recenti';

  @override
  String get mindNoMatchesMine =>
      'Ancora nessun duello. Trova il tuo primo avversario.';

  @override
  String get mindNoMatchesTheirs => 'Ancora nessun duello. Sfidalo per primo.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Gioca $count duelli classificati di questa lunghezza per entrare in classifica.';
  }

  @override
  String get mindChallengeTitle => 'Sfida a duello';

  @override
  String get mindChallengeSent =>
      'Sfida inviata. Il duello inizia appena viene accettata.';

  @override
  String get mindKindMath => 'Calcolo';

  @override
  String get mindKindAttention => 'Attenzione';

  @override
  String get mindKindMemory => 'Memoria';

  @override
  String get mindKindReflex => 'Riflessi';

  @override
  String get mindKindMathHint =>
      'Quattro operazioni, con le precedenze. Scegli il risultato giusto.';

  @override
  String get mindKindAttentionHint =>
      'Ignora il colore del testo: scegli la figura descritta.';

  @override
  String get mindKindMemoryHint =>
      'Ricorda lettere e cifre colorate, nell\'ordine e con il loro colore.';

  @override
  String get mindKindReflexHint =>
      'Tocca il bersaglio appena compare. Troppo presto o fuori costa punti.';

  @override
  String get mindScoringHint =>
      'Le risposte giuste e veloci valgono di più. Vince il totale più alto.';

  @override
  String get mindYou => 'Tu';

  @override
  String get mindOpponent => 'Avversario';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total domande';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Preparati';

  @override
  String get mindYouFinished => 'Hai finito!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Il tuo avversario è a $done/$total. Il risultato arriva quando finisce.';
  }

  @override
  String get mindMathPrompt => 'Qual è il risultato?';

  @override
  String get mindAttentionPrompt => 'Scegli la figura descritta';

  @override
  String get mindMemoryLook => 'Ricorda l\'ordine e i colori';

  @override
  String get mindMemoryPick => 'Sceglili nello stesso ordine e colore';

  @override
  String mindCharLabel(String char, String color) {
    return '$char $color';
  }

  @override
  String get mindUndo => 'Annulla';

  @override
  String get mindReflexTarget => 'Bersaglio';

  @override
  String get mindReflexWait => 'Aspetta…';

  @override
  String get mindReflexTap => 'Tocca ora!';

  @override
  String mindRight(int points) {
    return 'Giusto · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'In parte giusto · +$points';
  }

  @override
  String get mindWrong => 'Sbagliato';

  @override
  String mindWrongPenalty(int points) {
    return 'Sbagliato · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Troppo presto · −$points';
  }

  @override
  String get mindResignTitle => 'Abbandonare il duello?';

  @override
  String get mindResignBody =>
      'Vince il tuo avversario; in un duello classificato il tuo Elo scende.';

  @override
  String get mindFinished => 'Duello finito';

  @override
  String get mindEndCompleted => 'Tutte le domande risposte';

  @override
  String get mindEndTime => 'Tempo scaduto';

  @override
  String mindNewRating(int rating) {
    return 'Nuovo punteggio $rating';
  }

  @override
  String get mindNewDuel => 'Nuovo duello';

  @override
  String get mindBackHome => 'Torna ai duelli';

  @override
  String get mindTeamMatches => 'Duelli di gruppo';

  @override
  String get mindTeamMatchesHint =>
      'Duelli dei tuoi gruppi contro altri; il risultato cambia l\'Elo di duello del gruppo.';

  @override
  String get mindNoTeamMatches =>
      'Ancora nessun duello di gruppo. Sfida un altro gruppo a nome del tuo.';

  @override
  String get mindNewTeamMatch => 'Organizza un duello di gruppo';

  @override
  String get mindNewTeamHint =>
      'Quando l\'altro gruppo accetta, entrambi schierano i giocatori. All\'inizio i due giocatori di ogni posto si sfidano insieme.';

  @override
  String get mindTeamMatch => 'Duello di gruppo';

  @override
  String get mindSeats => 'Posti';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posti',
      one: '1 posto',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Un posto vuoto all\'inizio conta per l\'avversario. La prima domanda attende 5 minuti.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Nessun gruppo ha ancora giocato un duello. Organizza il primo con il tuo.';

  @override
  String get mindTournaments => 'Tornei';

  @override
  String get mindTournamentsHint =>
      'Settimanale ogni sabato alle 21:00 (10 domande), mensile l’ultimo sabato alle 19:00 (20 domande); i primi tre vincono una medaglia.';

  @override
  String get mindNoTournaments => 'Nessun torneo in arrivo.';
}
