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
}
