// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class GamesL10nEs extends GamesL10n {
  GamesL10nEs([String locale = 'es']) : super(locale);

  @override
  String get chess => 'Ajedrez';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rápidas';

  @override
  String get white => 'Blancas';

  @override
  String get black => 'Negras';

  @override
  String get colorRandom => 'Al azar';

  @override
  String get endCheckmate => 'Jaque mate';

  @override
  String get endResign => 'Abandono';

  @override
  String get endTimeout => 'Tiempo agotado';

  @override
  String get endTimeoutDraw => 'Tiempo agotado; el rival no puede dar mate';

  @override
  String get endStalemate => 'Ahogado';

  @override
  String get endInsufficient => 'Material insuficiente';

  @override
  String get endFiftyMoves => 'Regla de los 50 movimientos';

  @override
  String get endRepetition => 'Triple repetición';

  @override
  String get endAgreement => 'Tablas de mutuo acuerdo';

  @override
  String get endAborted => 'Cancelada';

  @override
  String get boardLabel => 'Tablero de ajedrez';

  @override
  String get promoteTo => 'Promocionar el peón a';

  @override
  String get queen => 'Dama';

  @override
  String get rook => 'Torre';

  @override
  String get bishop => 'Alfil';

  @override
  String get knight => 'Caballo';

  @override
  String get medalGold => 'Medalla de oro';

  @override
  String get medalSilver => 'Medalla de plata';

  @override
  String get medalBronze => 'Medalla de bronce';

  @override
  String get youWon => 'Ganaste';

  @override
  String get youLost => 'Perdiste';

  @override
  String get draw => 'Tablas';

  @override
  String get inProgress => 'En curso';

  @override
  String get whiteWon => 'Ganan las blancas';

  @override
  String get blackWon => 'Ganan las negras';

  @override
  String get rated => 'Clasificatoria';

  @override
  String get casual => 'Amistosa';

  @override
  String get ratedHint => 'El resultado cambia tu Elo.';

  @override
  String get flipBoard => 'Girar el tablero';

  @override
  String get cancel => 'Cancelar';

  @override
  String get resign => 'Rendirse';

  @override
  String get resignTitle => '¿Rendirse?';

  @override
  String get resignBody =>
      'Tu rival gana; en una partida clasificatoria baja tu Elo.';

  @override
  String get abort => 'Cancelar';

  @override
  String get offerDraw => '¿Tablas?';

  @override
  String get drawOffered => 'Ofrecidas';

  @override
  String get drawOfferReceived => 'Tu rival ofrece tablas.';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get rematch => 'Revancha';

  @override
  String get rematchSent => 'Revancha solicitada.';

  @override
  String get newGame => 'Nueva partida';

  @override
  String newRating(String category, int rating) {
    return 'Tu Elo de $category: $rating';
  }

  @override
  String get deletedPlayer => 'Cuenta eliminada';

  @override
  String get firstMove => 'Primera jugada: 30 s';

  @override
  String get noMovesYet => 'Aún no hay jugadas. Empiezan las blancas.';

  @override
  String get watching => 'Estás mirando';

  @override
  String get quickGame => 'Partida rápida';

  @override
  String get quickGameHint =>
      'Elige un tiempo y juega con alguien de tu nivel.';

  @override
  String get searching => 'Buscando rival…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esperando $count segundos',
      one: 'Esperando 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Perfil de ajedrez';

  @override
  String get recentGames => 'Partidas recientes';

  @override
  String get noGamesMine => 'Aún no tienes partidas. Juega la primera.';

  @override
  String get noGamesTheirs => 'Aún no tiene partidas. Invítalo a la primera.';

  @override
  String get playNow => 'Jugar ahora';

  @override
  String get challenge => 'Desafiar';

  @override
  String get noFlag => 'Sin bandera';

  @override
  String get chooseFlag => 'Elige tu bandera';

  @override
  String get chooseFlagHint => 'Aparece junto a tu nombre en la clasificación.';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get flagSaved => 'Bandera guardada.';

  @override
  String get pickFlagPrompt =>
      'Elige la bandera que se verá en la clasificación.';

  @override
  String get suspendedNotice =>
      'El ajedrez está cerrado para esta persona ahora.';

  @override
  String get notPlayed => 'Sin jugar';

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
    return 'Puesto $rank';
  }

  @override
  String get leaderboard => 'Clasificación';

  @override
  String leaderboardEmpty(int count) {
    return 'Juega $count partidas clasificatorias en esta categoría para entrar en la clasificación.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}G · ${draws}T · ${losses}P';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get invitations => 'Invitaciones';

  @override
  String invitesYou(String what) {
    return 'Te invita a una partida: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Quiere la revancha: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Esperando respuesta: $what';
  }

  @override
  String get withdraw => 'Retirar';

  @override
  String get gameInProgress => 'Tienes una partida en curso';

  @override
  String get resume => 'Continuar';

  @override
  String get challengeFriend => 'Desafiar a un amigo';

  @override
  String get challengeSent =>
      'Invitación enviada. La partida empieza cuando la acepte.';

  @override
  String get challengeTitle => 'Invitar a una partida';

  @override
  String get changePerson => 'Cambiar persona';

  @override
  String get searchPerson => 'Usuario o nombre';

  @override
  String get timeControl => 'Control de tiempo';

  @override
  String get yourColor => 'Tu color';

  @override
  String get sendChallenge => 'Enviar invitación';

  @override
  String get teamMatch => 'Encuentro por equipos';

  @override
  String get teamMatches => 'Encuentros por equipos';

  @override
  String get teamMatchesHint =>
      'Los encuentros de ajedrez de tus grupos; el resultado cambia el Elo del grupo.';

  @override
  String get noTeamMatches =>
      'Aún no hay encuentros. Invita a otro grupo en nombre del tuyo.';

  @override
  String get newTeamMatch => 'Organizar encuentro';

  @override
  String get newTeamMatchHint =>
      'Cuando el otro grupo acepte, ambos eligen a sus jugadores.';

  @override
  String get yourGroup => 'Tu grupo';

  @override
  String get opponentGroup => 'Grupo rival';

  @override
  String get searchGroup => 'Nombre o usuario del grupo';

  @override
  String get startsAt => 'Inicio';

  @override
  String get sendTeamInvite => 'Invitar al grupo';

  @override
  String get boards => 'Tableros';

  @override
  String get boardsShort => 'tableros';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tableros',
      one: '1 tablero',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Elo del grupo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Esperando respuesta';

  @override
  String get teamAccepted => 'Aceptado';

  @override
  String get teamDeclined => 'Rechazado';

  @override
  String get teamCanceled => 'Cancelado';

  @override
  String get teamLive => 'En juego';

  @override
  String get teamFinished => 'Terminado';

  @override
  String teamInviteReceived(String group) {
    return '$group invita a vuestro grupo a un encuentro por equipos.';
  }

  @override
  String get teamAcceptedDone =>
      'Encuentro aceptado. Ahora elegid a vuestros jugadores.';

  @override
  String get teamDeclinedDone => 'Invitación rechazada.';

  @override
  String get teamCanceledDone => 'Encuentro cancelado.';

  @override
  String get callOff => 'Cancelar encuentro';

  @override
  String get lineupHint =>
      'Un tablero vacío al empezar cuenta como punto para el rival.';

  @override
  String get lineupSheetHint =>
      'Toca a los miembros para colocarlos en orden; el tablero 1 es para el más fuerte.';

  @override
  String editLineup(String group) {
    return 'Alineación de $group';
  }

  @override
  String get saveLineup => 'Guardar alineación';

  @override
  String get emptyBoard => 'Vacío';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games partidas';
  }

  @override
  String get groupsTab => 'Grupos';

  @override
  String get groupLeaderboardEmpty =>
      'Ningún grupo ha jugado aún un encuentro. Que el tuyo sea el primero.';

  @override
  String get backToChess => 'Volver al ajedrez';

  @override
  String get arena => 'Torneo';

  @override
  String get tournaments => 'Torneos';

  @override
  String get tournamentsHint =>
      'Torneos arena semanales y mensuales; los tres primeros ganan medallas.';

  @override
  String get weeklyArena => 'Arena semanal';

  @override
  String get monthlyArena => 'Arena mensual';

  @override
  String get arenaRules =>
      'Arena: juega tantas partidas como quieras hasta el final. Victoria 2 puntos, tablas 1; tras dos victorias seguidas los puntos se duplican hasta que se corte la racha. Cuentan las partidas empezadas antes del final.';

  @override
  String get arenaLiveNow => 'En juego ahora';

  @override
  String get arenaUpcoming => 'Próximos';

  @override
  String get arenaFinished => 'Terminados';

  @override
  String get registered => 'Inscrito';

  @override
  String get arenaRegister => 'Inscribirse';

  @override
  String get arenaRegistered =>
      'Estás inscrito. Te avisaremos al empezar y te emparejaremos al abrirlo.';

  @override
  String get arenaJoin => 'Unirse';

  @override
  String get arenaResume => 'Seguir jugando';

  @override
  String get arenaPause => 'Pausar';

  @override
  String get arenaWaiting =>
      'Esperando rival; la partida se abre sola cuando alguien con puntos parecidos queda libre.';

  @override
  String get backToGame => 'Volver a la partida';

  @override
  String get backToArena => 'Volver al torneo';

  @override
  String get backToTeamMatch => 'Volver al encuentro';

  @override
  String arenaStartsIn(String time) {
    return 'Empieza en $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Quedan $time';
  }

  @override
  String get arenaLastGames =>
      'Se acabó el tiempo; terminan las últimas partidas';

  @override
  String arenaFinishedAt(String time) {
    return 'Terminado · $time';
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
      other: '$count jugadores',
      one: '1 jugador',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points puntos · $games partidas';
  }

  @override
  String get onFire => 'En racha: el próximo resultado vale doble';

  @override
  String get standings => 'Clasificación';

  @override
  String get arenaEmpty => 'Aún no se ha unido nadie. Sé el primero.';

  @override
  String performance(int value) {
    return 'Rendimiento $value';
  }

  @override
  String get playingNow => 'jugando';

  @override
  String get arenaMedals => 'Medallas de torneo';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Medallas: $gold oro, $silver plata, $bronze bronce';
  }

  @override
  String get firstMoveTeam => 'Primera jugada: 5 min';

  @override
  String get games => 'Juegos';

  @override
  String get gamesIntro =>
      'Juega con tu comunidad: partidas rápidas, torneos y encuentros entre grupos.';

  @override
  String get chessCardText =>
      'Elo, torneos semanales y mensuales, encuentros por equipos entre grupos y medallas.';

  @override
  String get playChess => 'Jugar al ajedrez';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Próximo torneo: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitaciones pendientes',
      one: '1 invitación pendiente',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Jugar en línea';

  @override
  String findOpponent(String tc) {
    return 'Buscar rival · $tc';
  }

  @override
  String get challengeFriendHint => 'Tú eliges tiempo y color';

  @override
  String get leaderboardHint => 'Clasificación Elo y medallas';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encuentros abiertos',
      one: '1 encuentro abierto',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Tablero y piezas';

  @override
  String get boardTheme => 'Tablero';

  @override
  String get pieceSet => 'Piezas';

  @override
  String get boardWood => 'Madera';

  @override
  String get boardGreen => 'Verde';

  @override
  String get boardBlue => 'Azul';

  @override
  String get boardSlate => 'Gris';

  @override
  String get boardLilac => 'Lila GWAY';

  @override
  String get piecesClassic => 'Clásicas';

  @override
  String get piecesCeltic => 'Celtas';

  @override
  String get piecesSpatial => 'Espacial';

  @override
  String get piecesFantasy => 'Fantasía';

  @override
  String get piecesModern => 'Modernas';

  @override
  String get piecesWarm => 'Cálidas';

  @override
  String get firstPosition => 'Inicio';

  @override
  String get previousMove => 'Jugada anterior';

  @override
  String get nextMove => 'Jugada siguiente';

  @override
  String get lastPosition => 'Posición actual';

  @override
  String get backToLive => 'Volver al directo';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'rojo',
      'red_f': 'roja',
      'red_n': 'rojo',
      'blue_m': 'azul',
      'blue_f': 'azul',
      'blue_n': 'azul',
      'green_m': 'verde',
      'green_f': 'verde',
      'green_n': 'verde',
      'yellow_m': 'amarillo',
      'yellow_f': 'amarilla',
      'yellow_n': 'amarillo',
      'purple_m': 'morado',
      'purple_f': 'morada',
      'purple_n': 'morado',
      'orange_m': 'naranja',
      'orange_f': 'naranja',
      'orange_n': 'naranja',
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
      'striped_m': 'rayado',
      'striped_f': 'rayada',
      'striped_n': 'rayado',
      'dotted_m': 'de lunares',
      'dotted_f': 'de lunares',
      'dotted_n': 'de lunares',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'círculo',
      'square': 'cuadrado',
      'triangle': 'triángulo',
      'star': 'estrella',
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
      'Un duelo en directo de cálculo, atención, memoria y reflejos. Elo, clasificaciones y medallas.';

  @override
  String get mindPlay => 'Empezar un duelo';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length preguntas';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas',
      one: '1 pregunta',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => '¿Cuántas preguntas?';

  @override
  String mindRatingAt(int count) {
    return 'Tu puntuación con $count preguntas';
  }

  @override
  String get mindFindOpponent => 'Buscar rival';

  @override
  String get mindSuspended => 'Ahora no puedes jugar.';

  @override
  String get mindActive => 'Tienes un duelo en curso';

  @override
  String get mindProfile => 'Perfil de duelo';

  @override
  String get mindHowTo => 'Cómo se juega';

  @override
  String get mindRecent => 'Duelos recientes';

  @override
  String get mindNoMatchesMine => 'Aún no hay duelos. Busca tu primer rival.';

  @override
  String get mindNoMatchesTheirs =>
      'Aún no hay duelos. Sé el primero en retarle.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Juega $count duelos puntuados de esta duración para entrar en la clasificación.';
  }

  @override
  String get mindChallengeTitle => 'Retar a un duelo';

  @override
  String get mindChallengeSent =>
      'Reto enviado. El duelo empieza cuando lo acepte.';

  @override
  String get mindKindMath => 'Cálculo';

  @override
  String get mindKindAttention => 'Atención';

  @override
  String get mindKindMemory => 'Memoria';

  @override
  String get mindKindReflex => 'Reflejos';

  @override
  String get mindKindMathHint =>
      'Cuatro operaciones, con prioridad. Elige el resultado correcto.';

  @override
  String get mindKindAttentionHint =>
      'Ignora el color del texto: elige la figura que describe.';

  @override
  String get mindKindMemoryHint =>
      'Recuerda las letras y cifras de colores, en orden y con su color.';

  @override
  String get mindKindReflexHint =>
      'Toca el objetivo en cuanto aparezca. Tocar antes o fallar resta puntos.';

  @override
  String get mindScoringHint =>
      'Las respuestas correctas y rápidas suman más. Gana el total más alto.';

  @override
  String get mindYou => 'Tú';

  @override
  String get mindOpponent => 'Rival';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total preguntas';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Prepárate';

  @override
  String get mindYouFinished => '¡Terminaste!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Tu rival va por $done/$total. El resultado llega cuando termine.';
  }

  @override
  String get mindMathPrompt => '¿Cuál es el resultado?';

  @override
  String get mindAttentionPrompt => 'Elige la figura descrita';

  @override
  String get mindMemoryLook => 'Recuerda el orden y los colores';

  @override
  String get mindMemoryPick => 'Elígelos en el mismo orden y color';

  @override
  String mindCharLabel(String char, String color) {
    return '$char $color';
  }

  @override
  String get mindUndo => 'Deshacer';

  @override
  String get mindReflexTarget => 'Objetivo';

  @override
  String get mindReflexWait => 'Espera…';

  @override
  String get mindReflexTap => '¡Toca ya!';

  @override
  String mindRight(int points) {
    return 'Correcto · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'En parte correcto · +$points';
  }

  @override
  String get mindWrong => 'Incorrecto';

  @override
  String mindWrongPenalty(int points) {
    return 'Incorrecto · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Demasiado pronto · −$points';
  }

  @override
  String get mindResignTitle => '¿Abandonar el duelo?';

  @override
  String get mindResignBody =>
      'Gana tu rival; en un duelo puntuado baja tu Elo.';

  @override
  String get mindFinished => 'Duelo terminado';

  @override
  String get mindEndCompleted => 'Todas las preguntas respondidas';

  @override
  String get mindEndTime => 'Tiempo agotado';

  @override
  String mindNewRating(int rating) {
    return 'Nueva puntuación $rating';
  }

  @override
  String get mindNewDuel => 'Nuevo duelo';

  @override
  String get mindBackHome => 'Volver a los duelos';
}
