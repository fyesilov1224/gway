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

  @override
  String get arena => 'Torneio';

  @override
  String get tournaments => 'Torneios';

  @override
  String get tournamentsHint =>
      'Torneios arena semanais e mensais; os três primeiros ganham medalhas.';

  @override
  String get weeklyArena => 'Arena semanal';

  @override
  String get monthlyArena => 'Arena mensal';

  @override
  String get arenaRules =>
      'Arena: jogue quantas partidas quiser até o fim. Vitória 2 pontos, empate 1; depois de duas vitórias seguidas os pontos dobram até a sequência acabar. Partidas iniciadas antes do fim contam.';

  @override
  String get arenaLiveNow => 'Acontecendo agora';

  @override
  String get arenaUpcoming => 'Próximos';

  @override
  String get arenaFinished => 'Encerrados';

  @override
  String get registered => 'Inscrito';

  @override
  String get arenaRegister => 'Inscrever-se';

  @override
  String get arenaRegistered =>
      'Você está inscrito. Avisaremos no início e você será pareado ao abrir.';

  @override
  String get arenaJoin => 'Entrar';

  @override
  String get arenaResume => 'Continuar jogando';

  @override
  String get arenaPause => 'Pausar';

  @override
  String get arenaWaiting =>
      'Aguardando adversário; a partida abre sozinha quando alguém com pontuação próxima ficar livre.';

  @override
  String get backToGame => 'Voltar à partida';

  @override
  String get backToArena => 'Voltar ao torneio';

  @override
  String get backToTeamMatch => 'Voltar ao confronto';

  @override
  String arenaStartsIn(String time) {
    return 'Começa em $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Faltam $time';
  }

  @override
  String get arenaLastGames =>
      'O tempo acabou; as últimas partidas estão terminando';

  @override
  String arenaFinishedAt(String time) {
    return 'Encerrado · $time';
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
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadores',
      one: '1 jogador',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points pontos · $games partidas';
  }

  @override
  String get onFire => 'Em sequência: o próximo resultado vale dobrado';

  @override
  String get standings => 'Classificação';

  @override
  String get arenaEmpty => 'Ninguém entrou ainda. Seja o primeiro.';

  @override
  String performance(int value) {
    return 'Desempenho $value';
  }

  @override
  String get playingNow => 'jogando';

  @override
  String get arenaMedals => 'Medalhas de torneio';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Medalhas: $gold ouro, $silver prata, $bronze bronze';
  }

  @override
  String get firstMoveTeam => 'Primeiro lance: 5 min';

  @override
  String get games => 'Jogos';

  @override
  String get gamesIntro =>
      'Jogue com sua comunidade: partidas rápidas, torneios e confrontos entre grupos.';

  @override
  String get chessCardText =>
      'Elo, torneios semanais e mensais, confrontos por equipes entre grupos e medalhas.';

  @override
  String get playChess => 'Jogar xadrez';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Próximo torneio: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convites esperando',
      one: '1 convite esperando',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Jogar online';

  @override
  String findOpponent(String tc) {
    return 'Encontrar adversário · $tc';
  }

  @override
  String get challengeFriendHint => 'Você escolhe tempo e cor';

  @override
  String get leaderboardHint => 'Ranking Elo e medalhas';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count confrontos abertos',
      one: '1 confronto aberto',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Tabuleiro e peças';

  @override
  String get boardTheme => 'Tabuleiro';

  @override
  String get pieceSet => 'Peças';

  @override
  String get boardWood => 'Madeira';

  @override
  String get boardGreen => 'Verde';

  @override
  String get boardBlue => 'Azul';

  @override
  String get boardSlate => 'Cinza';

  @override
  String get boardLilac => 'Lilás GWAY';

  @override
  String get piecesClassic => 'Clássicas';

  @override
  String get piecesCeltic => 'Celtas';

  @override
  String get piecesSpatial => 'Espacial';

  @override
  String get piecesFantasy => 'Fantasia';

  @override
  String get piecesModern => 'Modernas';

  @override
  String get piecesWarm => 'Quentes';

  @override
  String get firstPosition => 'Início';

  @override
  String get previousMove => 'Lance anterior';

  @override
  String get nextMove => 'Próximo lance';

  @override
  String get lastPosition => 'Posição atual';

  @override
  String get backToLive => 'Voltar ao vivo';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'vermelho',
      'red_f': 'vermelha',
      'red_n': 'vermelho',
      'blue_m': 'azul',
      'blue_f': 'azul',
      'blue_n': 'azul',
      'green_m': 'verde',
      'green_f': 'verde',
      'green_n': 'verde',
      'yellow_m': 'amarelo',
      'yellow_f': 'amarela',
      'yellow_n': 'amarelo',
      'purple_m': 'roxo',
      'purple_f': 'roxa',
      'purple_n': 'roxo',
      'orange_m': 'laranja',
      'orange_f': 'laranja',
      'orange_n': 'laranja',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'liso',
      'solid_f': 'lisa',
      'solid_n': 'liso',
      'striped_m': 'listrado',
      'striped_f': 'listrada',
      'striped_n': 'listrado',
      'dotted_m': 'de bolinhas',
      'dotted_f': 'de bolinhas',
      'dotted_n': 'de bolinhas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'círculo',
      'square': 'quadrado',
      'triangle': 'triângulo',
      'star': 'estrela',
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
  String get mindDuel => 'Duelo mental';

  @override
  String get mindCardText =>
      'Um duelo ao vivo de cálculo, atenção, memória e reflexos. Elo, rankings e medalhas.';

  @override
  String get mindPlay => 'Começar um duelo';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length perguntas';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perguntas',
      one: '1 pergunta',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Quantas perguntas?';

  @override
  String mindRatingAt(int count) {
    return 'Sua pontuação com $count perguntas';
  }

  @override
  String get mindFindOpponent => 'Encontrar adversário';

  @override
  String get mindSuspended => 'Você não pode jogar agora.';

  @override
  String get mindActive => 'Você tem um duelo em andamento';

  @override
  String get mindProfile => 'Perfil de duelo';

  @override
  String get mindHowTo => 'Como jogar';

  @override
  String get mindRecent => 'Duelos recentes';

  @override
  String get mindNoMatchesMine =>
      'Nenhum duelo ainda. Encontre seu primeiro adversário.';

  @override
  String get mindNoMatchesTheirs =>
      'Nenhum duelo ainda. Seja o primeiro a desafiar.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Jogue $count duelos ranqueados desse tamanho para entrar no ranking.';
  }

  @override
  String get mindChallengeTitle => 'Desafiar para um duelo';

  @override
  String get mindChallengeSent =>
      'Desafio enviado. O duelo começa quando for aceito.';

  @override
  String get mindKindMath => 'Cálculo';

  @override
  String get mindKindAttention => 'Atenção';

  @override
  String get mindKindMemory => 'Memória';

  @override
  String get mindKindReflex => 'Reflexos';

  @override
  String get mindKindMathHint =>
      'Quatro operações, com precedência. Escolha o resultado certo.';

  @override
  String get mindKindAttentionHint =>
      'Ignore a cor do texto: escolha a figura descrita.';

  @override
  String get mindKindMemoryHint =>
      'Lembre as letras e números coloridos, na ordem e com a cor.';

  @override
  String get mindKindReflexHint =>
      'Toque o alvo assim que aparecer. Tocar antes ou errar tira pontos.';

  @override
  String get mindScoringHint =>
      'Respostas certas e rápidas valem mais. Vence o maior total.';

  @override
  String get mindYou => 'Você';

  @override
  String get mindOpponent => 'Adversário';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total perguntas';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Prepare-se';

  @override
  String get mindYouFinished => 'Você terminou!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Seu adversário está em $done/$total. O resultado sai quando ele terminar.';
  }

  @override
  String get mindMathPrompt => 'Qual é o resultado?';

  @override
  String get mindAttentionPrompt => 'Escolha a figura descrita';

  @override
  String get mindMemoryLook => 'Lembre a ordem e as cores';

  @override
  String get mindMemoryPick => 'Escolha na mesma ordem e cores';

  @override
  String mindCharLabel(String char, String color) {
    return '$char $color';
  }

  @override
  String get mindUndo => 'Desfazer';

  @override
  String get mindReflexTarget => 'Alvo';

  @override
  String get mindReflexWait => 'Espere…';

  @override
  String get mindReflexTap => 'Toque agora!';

  @override
  String mindRight(int points) {
    return 'Certo · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Parcialmente certo · +$points';
  }

  @override
  String get mindWrong => 'Errado';

  @override
  String mindWrongPenalty(int points) {
    return 'Errado · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Cedo demais · −$points';
  }

  @override
  String get mindResignTitle => 'Desistir do duelo?';

  @override
  String get mindResignBody =>
      'Seu adversário vence; em duelo ranqueado seu Elo cai.';

  @override
  String get mindFinished => 'Duelo encerrado';

  @override
  String get mindEndCompleted => 'Todas as perguntas respondidas';

  @override
  String get mindEndTime => 'Tempo esgotado';

  @override
  String mindNewRating(int rating) {
    return 'Nova pontuação $rating';
  }

  @override
  String get mindNewDuel => 'Novo duelo';

  @override
  String get mindBackHome => 'Voltar aos duelos';

  @override
  String get mindTeamMatches => 'Duelos de grupos';

  @override
  String get mindTeamMatchesHint =>
      'Duelos dos seus grupos contra outros; o resultado muda o Elo de duelo do grupo.';

  @override
  String get mindNoTeamMatches =>
      'Nenhum duelo de grupos ainda. Desafie outro grupo em nome do seu.';

  @override
  String get mindNewTeamMatch => 'Marcar duelo de grupos';

  @override
  String get mindNewTeamHint =>
      'Quando o outro grupo aceitar, ambos escalam jogadores. No início, os dois jogadores de cada posição duelam ao mesmo tempo.';

  @override
  String get mindTeamMatch => 'Duelo de grupos';

  @override
  String get mindSeats => 'Posições';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posições',
      one: '1 posição',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Uma posição vazia no início conta para o adversário. A primeira pergunta espera 5 minutos.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Nenhum grupo jogou um duelo ainda. Que o seu marque o primeiro.';
}
