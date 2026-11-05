// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class GamesL10nPt extends GamesL10n {
  GamesL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get chess => 'Xadrez';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rápida';

  @override
  String get white => 'Brancas';

  @override
  String get black => 'Pretas';

  @override
  String get colorRandom => 'Aleatória';

  @override
  String get endCheckmate => 'Xeque-mate';

  @override
  String get endResign => 'Desistência';

  @override
  String get endTimeout => 'Tempo esgotado';

  @override
  String get endTimeoutDraw => 'Tempo esgotado; o adversário não pode dar mate';

  @override
  String get endStalemate => 'Afogamento';

  @override
  String get endInsufficient => 'Material insuficiente';

  @override
  String get endFiftyMoves => 'Regra dos 50 lances';

  @override
  String get endRepetition => 'Repetição tripla';

  @override
  String get endAgreement => 'Empate em comum acordo';

  @override
  String get endAborted => 'Cancelada';

  @override
  String get boardLabel => 'Tabuleiro de xadrez';

  @override
  String get promoteTo => 'Promover o peão a';

  @override
  String get queen => 'Dama';

  @override
  String get rook => 'Torre';

  @override
  String get bishop => 'Bispo';

  @override
  String get knight => 'Cavalo';

  @override
  String get medalGold => 'Medalha de ouro';

  @override
  String get medalSilver => 'Medalha de prata';

  @override
  String get medalBronze => 'Medalha de bronze';

  @override
  String get youWon => 'Você venceu';

  @override
  String get youLost => 'Você perdeu';

  @override
  String get draw => 'Empate';

  @override
  String get inProgress => 'Em andamento';

  @override
  String get whiteWon => 'As brancas venceram';

  @override
  String get blackWon => 'As pretas venceram';

  @override
  String get rated => 'Ranqueada';

  @override
  String get casual => 'Casual';

  @override
  String get ratedHint => 'O resultado altera seu Elo.';

  @override
  String get flipBoard => 'Girar o tabuleiro';

  @override
  String get cancel => 'Cancelar';

  @override
  String get resign => 'Desistir';

  @override
  String get resignTitle => 'Desistir da partida?';

  @override
  String get resignBody =>
      'Seu adversário vence; numa partida ranqueada seu Elo cai.';

  @override
  String get abort => 'Cancelar';

  @override
  String get offerDraw => 'Empate?';

  @override
  String get drawOffered => 'Oferecido';

  @override
  String get drawOfferReceived => 'Seu adversário oferece empate.';

  @override
  String get accept => 'Aceitar';

  @override
  String get decline => 'Recusar';

  @override
  String get rematch => 'Revanche';

  @override
  String get rematchSent => 'Pedido de revanche enviado.';

  @override
  String get newGame => 'Nova partida';

  @override
  String newRating(String category, int rating) {
    return 'Seu Elo de $category: $rating';
  }

  @override
  String get deletedPlayer => 'Conta excluída';

  @override
  String get firstMove => 'Primeiro lance: 30 s';

  @override
  String get noMovesYet => 'Nenhum lance ainda. As brancas começam.';

  @override
  String get watching => 'Você está assistindo';

  @override
  String get quickGame => 'Partida rápida';

  @override
  String get quickGameHint =>
      'Escolha o tempo e jogue com alguém do seu nível.';

  @override
  String get searching => 'Procurando adversário…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esperando há $count segundos',
      one: 'Esperando há 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Perfil de xadrez';

  @override
  String get recentGames => 'Partidas recentes';

  @override
  String get noGamesMine => 'Ainda não há partidas. Jogue a primeira.';

  @override
  String get noGamesTheirs => 'Ainda sem partidas. Convide para a primeira.';

  @override
  String get playNow => 'Jogar agora';

  @override
  String get challenge => 'Desafiar';

  @override
  String get noFlag => 'Nenhuma bandeira';

  @override
  String get chooseFlag => 'Escolha sua bandeira';

  @override
  String get chooseFlagHint => 'Aparece ao lado do seu nome no ranking.';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get flagSaved => 'Bandeira salva.';

  @override
  String get pickFlagPrompt => 'Escolha a bandeira que aparece no ranking.';

  @override
  String get suspendedNotice => 'O xadrez está fechado para esta pessoa agora.';

  @override
  String get notPlayed => 'Não jogado';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return '$rankº lugar';
  }

  @override
  String get leaderboard => 'Ranking';

  @override
  String leaderboardEmpty(int count) {
    return 'Jogue $count partidas ranqueadas nesta categoria para entrar no ranking.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}V · ${draws}E · ${losses}D';
  }

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get invitations => 'Convites';

  @override
  String invitesYou(String what) {
    return 'Convida você para uma partida: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Quer revanche: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Aguardando resposta: $what';
  }

  @override
  String get withdraw => 'Retirar';

  @override
  String get gameInProgress => 'Você tem uma partida em andamento';

  @override
  String get resume => 'Continuar';

  @override
  String get challengeFriend => 'Desafiar um amigo';

  @override
  String get challengeSent =>
      'Convite enviado. A partida começa quando for aceito.';

  @override
  String get challengeTitle => 'Convidar para uma partida';

  @override
  String get changePerson => 'Trocar pessoa';

  @override
  String get searchPerson => 'Usuário ou nome';

  @override
  String get timeControl => 'Controle de tempo';

  @override
  String get yourColor => 'Sua cor';

  @override
  String get sendChallenge => 'Enviar convite';
}
