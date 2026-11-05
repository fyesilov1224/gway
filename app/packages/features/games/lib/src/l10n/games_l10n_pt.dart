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

  @override
  String get teamMatch => 'Confronto por equipes';

  @override
  String get teamMatches => 'Confrontos por equipes';

  @override
  String get teamMatchesHint =>
      'Os confrontos de xadrez dos seus grupos; o resultado altera o Elo do grupo.';

  @override
  String get noTeamMatches =>
      'Ainda não há confrontos. Convide outro grupo em nome do seu.';

  @override
  String get newTeamMatch => 'Organizar confronto';

  @override
  String get newTeamMatchHint =>
      'Quando o outro grupo aceitar, os dois escalam seus jogadores.';

  @override
  String get yourGroup => 'Seu grupo';

  @override
  String get opponentGroup => 'Grupo adversário';

  @override
  String get searchGroup => 'Nome ou usuário do grupo';

  @override
  String get startsAt => 'Início';

  @override
  String get sendTeamInvite => 'Convidar o grupo';

  @override
  String get boards => 'Tabuleiros';

  @override
  String get boardsShort => 'tabuleiros';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabuleiros',
      one: '1 tabuleiro',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Elo do grupo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Aguardando resposta';

  @override
  String get teamAccepted => 'Aceito';

  @override
  String get teamDeclined => 'Recusado';

  @override
  String get teamCanceled => 'Cancelado';

  @override
  String get teamLive => 'Em jogo';

  @override
  String get teamFinished => 'Encerrado';

  @override
  String teamInviteReceived(String group) {
    return '$group convida seu grupo para um confronto por equipes.';
  }

  @override
  String get teamAcceptedDone =>
      'Confronto aceito. Agora escalem seus jogadores.';

  @override
  String get teamDeclinedDone => 'Convite recusado.';

  @override
  String get teamCanceledDone => 'Confronto cancelado.';

  @override
  String get callOff => 'Cancelar confronto';

  @override
  String get lineupHint =>
      'Um tabuleiro vazio no início conta como ponto para o adversário.';

  @override
  String get lineupSheetHint =>
      'Toque nos membros para colocá-los em ordem; o tabuleiro 1 é do mais forte.';

  @override
  String editLineup(String group) {
    return 'Escalação de $group';
  }

  @override
  String get saveLineup => 'Salvar escalação';

  @override
  String get emptyBoard => 'Vazio';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games partidas';
  }

  @override
  String get groupsTab => 'Grupos';

  @override
  String get groupLeaderboardEmpty =>
      'Nenhum grupo jogou um confronto ainda. Que o seu seja o primeiro.';

  @override
  String get backToChess => 'Voltar ao xadrez';
}
