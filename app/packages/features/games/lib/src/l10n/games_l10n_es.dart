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
}
