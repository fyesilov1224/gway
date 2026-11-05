// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class EventsL10nEs extends EventsL10n {
  EventsL10nEs([String locale = 'es']) : super(locale);

  @override
  String get pollSingle => 'En esta encuesta solo puedes elegir una opción.';

  @override
  String get pollOptionGone => 'Esta opción ya no existe. Actualiza la página.';

  @override
  String get reviewWindow =>
      'Los asistentes pueden valorar el evento hasta 30 días después de que termine.';

  @override
  String get greeterNeedsAttendance =>
      'Para recibir a otros, debes haber asistido a un evento del grupo.';

  @override
  String get note80 => 'La nota puede tener hasta 80 caracteres.';

  @override
  String get pollClosed => 'Esta encuesta ha terminado o no puedes votar.';

  @override
  String get cover5mb => 'La imagen de portada puede tener hasta 5 MB.';

  @override
  String get imagesOnly => 'Solo se pueden subir imágenes JPEG, PNG o WebP.';

  @override
  String get claimNotAllowed =>
      'No puedes informar de esta tarea ahora: ha terminado o no estás en el grupo.';

  @override
  String get claimApprovedLocked => 'Un informe aprobado no se puede retirar.';

  @override
  String get claimDuplicate => 'Ya informaste de esta tarea.';

  @override
  String get repeatsWeekly => 'Se repite cada semana';

  @override
  String get repeatsBiweekly => 'Se repite cada dos semanas';

  @override
  String surprisePlace(String place) {
    return 'Lugar sorpresa · $place';
  }

  @override
  String get goalPersonal => 'Objetivo personal';

  @override
  String get goalPersonalHint => 'Cada miembro completa su propio número.';

  @override
  String get goalGroup => 'Objetivo de grupo';

  @override
  String get goalGroupHint =>
      'Las aportaciones de todos se suman en un solo contador.';

  @override
  String get goalTeam => 'Objetivo de equipo';

  @override
  String get goalTeamHint =>
      'Los administradores forman los equipos; cada equipo tiene un contador común.';

  @override
  String get goalTask => 'Tarea aprobada';

  @override
  String get goalTaskHint =>
      'Un miembro dice «Hecho» y un administrador lo aprueba.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'asistencias',
      one: 'asistencia',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'eventos organizados',
      one: 'evento organizado',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recuerdos',
      one: 'recuerdo',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'Pendiente de aprobación';

  @override
  String get claimApproved => 'Aprobado';

  @override
  String get claimRejected => 'No aprobado';

  @override
  String get notClaimedYet => 'Aún sin informar';

  @override
  String get whenAny => 'Cualquier momento';

  @override
  String get whenToday => 'Hoy';

  @override
  String get whenWeek => 'En 7 días';

  @override
  String get viewDay => 'Día';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewMonth => 'Mes';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asistencias',
      one: '1 asistencia',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos organizados',
      one: '1 evento organizado',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recuerdos',
      one: '1 recuerdo',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valoraciones',
      one: '1 valoración',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recién llegados recibidos',
      one: '1 recién llegado recibido',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apretones de manos',
      one: '1 apretón de manos',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valoraciones positivas',
      one: '1 valoración positiva',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: puesto $rank de $groups grupos, $points puntos.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asistentes',
      one: '1 asistente',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity asistentes';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Primer evento del año: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Primer evento del año: $title · $date';
  }

  @override
  String get myCalendar => 'Mi calendario';

  @override
  String get groupCalendar => 'Calendario del grupo';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get today => 'Hoy';

  @override
  String get groupsEvents => 'Eventos de mis grupos';

  @override
  String get showNotJoined => 'Mostrar también los que no te has apuntado';

  @override
  String get noJoinedInRange =>
      'No te has apuntado a eventos en estas fechas. También puedes ver los de tus grupos.';

  @override
  String get noEventsInRange => 'No hay eventos en estas fechas.';

  @override
  String get showGroupsEvents => 'Mostrar eventos de mis grupos';

  @override
  String get backToToday => 'Volver a hoy';

  @override
  String get noEventsDay => 'No hay eventos este día.';

  @override
  String get contributions => 'Aportación a la comunidad';

  @override
  String get howBadges => '¿Cómo se ganan las insignias?';

  @override
  String get badgesEmpty =>
      'Cuando asistas a un evento, tu aportación y tu primera insignia aparecerán aquí.';

  @override
  String get badgesRules =>
      'Las insignias salen solo de lo que haces de verdad: eventos a los que asistes y que organizas, recuerdos compartidos y valoraciones. Los me gusta y seguidores no cuentan. No cuentan las asistencias que el organizador marca como «no vino». No hay clasificaciones.';

  @override
  String get categoryFan => 'Fan de la categoría';

  @override
  String get pastEvents => 'Eventos pasados';

  @override
  String get noPastEvents => 'Este grupo aún no tiene eventos pasados.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get canceled => 'Cancelado';

  @override
  String get olderEvents => 'Eventos anteriores';

  @override
  String get completed => 'Completado';

  @override
  String get ended => 'Finalizado';

  @override
  String teamName(String name) {
    return 'Equipo: $name';
  }

  @override
  String get teamNotice =>
      'Cuando te añadan a un equipo, aquí verás tu progreso.';

  @override
  String get goals => 'Objetivos';

  @override
  String get createGoal => 'Crear objetivo';

  @override
  String get goalsEmpty =>
      'Por ejemplo «4 rutas este mes» o «50 asistencias entre todos»: crea el primer objetivo.';

  @override
  String get claimSent => 'Tu informe se ha enviado al administrador.';

  @override
  String get goal => 'Objetivo';

  @override
  String get goalCountsRule =>
      'Solo cuentan los eventos de este grupo en el periodo; no cuentan las asistencias marcadas como «no vino».';

  @override
  String get withdrawClaim => 'Retirar informe';

  @override
  String get claimWithdrawn => 'Tu informe se ha retirado.';

  @override
  String get done => 'Hecho';

  @override
  String get teams => 'Equipos';

  @override
  String get createTeam => 'Crear equipo';

  @override
  String get noTeams => 'Aún no hay equipos.';

  @override
  String deleteTeam(String name) {
    return 'Eliminar el equipo $name';
  }

  @override
  String get teamDeleted => 'Equipo eliminado.';

  @override
  String pendingClaims(int count) {
    return 'Informes pendientes ($count)';
  }

  @override
  String get claimRejectedToast => 'Informe no aprobado.';

  @override
  String get decline => 'Rechazar';

  @override
  String get approve => 'Aprobar';

  @override
  String taskDone(String name) {
    return '$name ha completado la tarea.';
  }

  @override
  String completions(int count) {
    return 'Completado por ($count)';
  }

  @override
  String get noCompletions =>
      'Nadie lo ha completado aún. Quien lo haga recibirá la insignia de este objetivo en su perfil.';

  @override
  String get goalCanceled => 'Objetivo cancelado.';

  @override
  String get cancelGoal => 'Cancelar objetivo';

  @override
  String teamCreated(String name) {
    return 'Equipo «$name» creado.';
  }

  @override
  String get teamNameLabel => 'Nombre del equipo';

  @override
  String get createTheTeam => 'Crear el equipo';

  @override
  String createTeamWith(int count) {
    return 'Crear el equipo ($count personas)';
  }

  @override
  String get goalCreated => 'Objetivo creado.';

  @override
  String get title => 'Título';

  @override
  String get goalTitleExample => 'Ej.: Rutas de octubre';

  @override
  String get taskTitleExample => 'Ej.: Explicar la ruta a un miembro nuevo';

  @override
  String get titleMin3 => 'El título debe tener al menos 3 caracteres.';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get targetNumber => 'Cifra objetivo';

  @override
  String get target1to1000 => 'Introduce un número entre 1 y 1000.';

  @override
  String get period => 'Periodo';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (máx. 92 días)';
  }

  @override
  String get createTheGoal => 'Crear el objetivo';

  @override
  String get iDidTask => 'He hecho la tarea';

  @override
  String get whatDidYouDo => '¿Qué hiciste? (opcional)';

  @override
  String get whatDidYouDoHint =>
      'El administrador aprueba tras leer esta nota.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get send => 'Enviar';

  @override
  String get handshake => 'Apretón de manos';

  @override
  String get handshakeHint =>
      'Escaneaos los códigos; los dos apareceréis en «Gente que conocí».';

  @override
  String get open => 'Abrir';

  @override
  String handshakeAt(String title) {
    return 'Apretón de manos · $title';
  }

  @override
  String get myCode => 'Mi código';

  @override
  String get scan => 'Escanear';

  @override
  String get yourHandshakeCode => 'Tu código de apretón de manos';

  @override
  String get codeHint =>
      'Que la otra persona escanee este código en «Escanear» o lo escriba. El código cambia cada pocos minutos; una foto no servirá después.';

  @override
  String get cameraFailed =>
      'No se pudo abrir la cámara. Permite el acceso en ajustes o escribe el código abajo.';

  @override
  String get scanHint =>
      'Apunta la cámara al código QR de la otra persona o escribe su código.';

  @override
  String get typeCodeHint =>
      'Escribe el código de 6 caracteres de la pantalla de la otra persona.';

  @override
  String get code => 'Código';

  @override
  String get alreadyMet => 'Ya os conocíais';

  @override
  String get metNow => '¡Os habéis conocido!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Vale';

  @override
  String get metPeople => 'Gente que conocí';

  @override
  String get metEmpty =>
      'Cuando te des la mano con alguien en un evento, aparecerá aquí. El apretón se abre en la página del evento.';

  @override
  String get goToCalendar => 'Ir a mi calendario';

  @override
  String get metPrivacy =>
      'Solo tú lo ves. Tu perfil muestra solo tu número de apretones de manos.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => '¿Cómo se calculan los puntos?';

  @override
  String get leagueIntro =>
      'Los grupos de la misma categoría y provincia compiten cada mes. Cuentan los eventos terminados ese mes.';

  @override
  String get ruleAttendance => 'Asistencia: 1 punto';

  @override
  String get ruleAttendanceHint => 'Cada persona que va; hasta 30 por evento.';

  @override
  String get ruleHeld => 'Evento: 5 puntos';

  @override
  String get ruleHeldHint =>
      'Cada evento al que fueron al menos 3 personas además del organizador.';

  @override
  String get ruleWelcome => 'Bienvenida: 3 puntos';

  @override
  String get ruleWelcomeHint => 'Recibir a alguien que viene por primera vez.';

  @override
  String get ruleReview => 'Valoración positiva: 1 punto';

  @override
  String get ruleReviewHint => 'Cada valoración de 4 o 5 estrellas.';

  @override
  String get leagueRulesNote =>
      'No cuentan quienes se marcan como «no vino». Los resultados son definitivos 8 días después de acabar el mes; se avisa a los miembros de los tres primeros grupos.';

  @override
  String get groupsLeague => 'Liga de grupos';

  @override
  String get category => 'Categoría';

  @override
  String get province => 'Provincia';

  @override
  String get month => 'Mes';

  @override
  String seasonClosed(String month) {
    return 'La temporada de $month ha terminado; la clasificación es definitiva.';
  }

  @override
  String get seasonRunning =>
      'La temporada está en marcha. Los puntos se actualizan al terminar los eventos; los resultados son definitivos 8 días después del fin de mes.';

  @override
  String leagueEmpty(String province) {
    return 'Ningún grupo de la liga de $province ha sumado puntos este mes.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rank.º';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Liga de $category';
  }

  @override
  String get noPointsYet =>
      'Aún no hay puntos este mes. Los eventos terminados, las asistencias y las bienvenidas suman.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © colaboradores de OpenStreetMap';

  @override
  String get map => 'Mapa';

  @override
  String get mapView => 'Vista de mapa';

  @override
  String get listView => 'Vista de lista';

  @override
  String get all => 'Todos';

  @override
  String get wholeArea => 'Toda la zona';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'No se pudieron cargar los datos del mapa.';

  @override
  String get retry => 'Reintentar';

  @override
  String get noFilterResults => 'No hay resultados con estos filtros.';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get noNearby => 'No hay eventos próximos ni grupos en esta zona.';

  @override
  String get zoomOut => 'Alejar';

  @override
  String get openEvent => 'Abrir evento';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get noVisible =>
      'No hay eventos próximos ni grupos en la zona visible.';

  @override
  String get backToMap => 'Volver al mapa';

  @override
  String upcomingCount(int count) {
    return 'Próximos eventos ($count)';
  }

  @override
  String get directions => 'Cómo llegar';

  @override
  String get meetingPointOptional => 'Punto de encuentro (opcional)';

  @override
  String get meetingPointHint =>
      'Elígelo en el mapa; el evento aparecerá en él.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Seleccionado · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Quitar punto de encuentro';

  @override
  String get meetingPoint => 'Punto de encuentro';

  @override
  String get pickHint => 'Acerca el mapa y toca el punto de encuentro.';

  @override
  String get pickAgainHint => 'Toca en otro lugar para mover el punto.';

  @override
  String get pickThisPoint => 'Elegir este punto';

  @override
  String get mapUnavailable => 'El mapa no está disponible ahora.';

  @override
  String get pollClosedShort => 'Cerrada';

  @override
  String closesAt(String date) {
    return 'Cierra: $date';
  }

  @override
  String get multipleAllowed => 'Varias opciones';

  @override
  String get anonymousVote => 'Votación anónima';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Opciones de la encuesta';

  @override
  String get pollClosedToast => 'Encuesta cerrada.';

  @override
  String get pollDeleted => 'Encuesta eliminada.';

  @override
  String get closePoll => 'Cerrar encuesta';

  @override
  String get deletePoll => 'Eliminar encuesta';

  @override
  String get vote => 'Votar';

  @override
  String get voteSaved => 'Tu voto se ha guardado.';

  @override
  String get voters => 'Votantes';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get polls => 'Encuestas';

  @override
  String get openPoll => 'Crear encuesta';

  @override
  String get pollsEmpty =>
      'Haz una pregunta a los miembros, por ejemplo, ¿qué día quedamos?';

  @override
  String get pollOpened => 'Encuesta creada.';

  @override
  String get question => 'Pregunta';

  @override
  String get questionExample => 'Ej.: ¿Qué día quedamos?';

  @override
  String get questionMin3 => 'La pregunta debe tener al menos 3 caracteres.';

  @override
  String optionN(int n) {
    return 'Opción $n';
  }

  @override
  String get removeOption => 'Quitar opción';

  @override
  String get optionRequired => 'Escribe la opción o quítala.';

  @override
  String get addOption => 'Añadir opción';

  @override
  String get allowMultiple => 'Permitir varias opciones';

  @override
  String get anonymousHint => 'Nadie ve quién votó qué.';

  @override
  String get noEndTime => 'Sin hora de cierre';

  @override
  String get add => 'Añadir';

  @override
  String get removeEndTime => 'Quitar hora de cierre';

  @override
  String get startPoll => 'Crear la encuesta';

  @override
  String get cardFooter => 'gway · encuentra tu comunidad';

  @override
  String myYear(int year) {
    return 'Mi $year';
  }

  @override
  String get statAttended => 'eventos a los que fui';

  @override
  String get statHours => 'horas juntos';

  @override
  String get statOneGroup => 'grupo con el que quedé';

  @override
  String get statGroups => 'grupos distintos';

  @override
  String get statProvinces => 'provincias distintas';

  @override
  String get statOrganized => 'eventos organizados';

  @override
  String get statWelcomed => 'recién llegados recibidos';

  @override
  String get statMemories => 'recuerdos compartidos';

  @override
  String get favorites => 'Mis favoritos';

  @override
  String get topGroup => 'El grupo con el que más estuve';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quedadas',
      one: '1 quedada',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'Yo estuve allí';

  @override
  String get firstWithGroup => 'Mi primer evento con este grupo.';

  @override
  String nthWithGroup(int n) {
    return 'Mi $n.º evento con este grupo.';
  }

  @override
  String get shareFailed =>
      'No se pudo compartir en este dispositivo. Haz una captura de la tarjeta y compártela.';

  @override
  String get share => 'Compartir';

  @override
  String yearSummaryTitle(int year) {
    return 'Mi resumen de $year';
  }

  @override
  String get yearEmpty =>
      'Este año aún no has ido a ningún evento. Tu resumen aparecerá aquí tras tu primera quedada.';

  @override
  String yearShareText(int year) {
    return 'Mi $year en GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Mapa de Turquía: $count provincias exploradas';
  }

  @override
  String get explorationMap => 'Mi mapa de exploración';

  @override
  String get statExplored => 'provincias exploradas';

  @override
  String get statMetAt => 'eventos donde quedamos';

  @override
  String get recentExplored => 'Últimos descubrimientos';

  @override
  String get explorationEmpty =>
      'Aquí se iluminan las provincias de tus eventos. Tu mapa se llenará de color tras tu primera quedada.';

  @override
  String get findOnMap => 'Buscar eventos en el mapa';

  @override
  String explorationShareText(int count) {
    return 'He explorado $count provincias en GWAY';
  }

  @override
  String get exploredProvinces => 'Provincias exploradas';

  @override
  String get explorationPrivacy =>
      'Solo tú lo ves. Cuentan los eventos a los que fuiste y no te marcaron como «no vino».';

  @override
  String get tonightVisible =>
      'Los miembros de tus grupos verán que estás libre esta noche. Se apaga solo a las 4:00.';

  @override
  String get joinedTable => 'Te has unido a la mesa.';

  @override
  String get declinedInvite => 'Has rechazado la invitación.';

  @override
  String get yourStatus => 'Tu estado';

  @override
  String get visibleUntil4 => 'Eres visible hasta las 4:00';

  @override
  String get notVisible => 'Ahora no eres visible';

  @override
  String get youreFree => 'Estás libre';

  @override
  String get tonightIntro =>
      'Si estás libre, que lo vean tus grupos; podréis montar una mesa pequeña juntos.';

  @override
  String get imFreeTonight => 'Estoy libre esta noche';

  @override
  String get noLongerFree => 'Ya no apareces como libre.';

  @override
  String get turnOffStatus => 'Desactivar estado';

  @override
  String get leftTable => 'Has dejado la mesa.';

  @override
  String get smallTable => 'Mesa pequeña';

  @override
  String get smallTableHint =>
      'Invita a algunas personas libres; el chat de la mesa se abre cuando sois tres.';

  @override
  String get setUpTable => 'Montar una mesa pequeña';

  @override
  String tableInvitesSent(int count) {
    return 'Invitaciones enviadas a $count personas. El chat se abre cuando sois tres.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Para una mesa pequeña hacen falta al menos $min personas libres más de tus grupos (ahora $now). Cuando alguien diga que está libre, podrás montarla aquí.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas de tus grupos están libres esta noche',
      one: '1 persona de tus grupos está libre esta noche',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Café';

  @override
  String get chipWalk => 'Paseo corto';

  @override
  String get chipFood => 'Comida';

  @override
  String get chipCinema => 'Cine';

  @override
  String get tonightSheetHint =>
      'Solo lo ven las personas de tus grupos. Tu estado se apaga solo a las 4:00.';

  @override
  String get whatToDo => '¿Qué te apetece hacer? (opcional)';

  @override
  String get whatToDoHint => 'p. ej. café, paseo corto';

  @override
  String get imFree => 'Estoy libre';

  @override
  String get yourTable => 'Tu mesa';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count se han unido',
      one: '1 se ha unido',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes',
      one: '1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'Preparándose';

  @override
  String get chatOpen => 'Chat abierto';

  @override
  String get tableChat => 'Chat de la mesa';

  @override
  String chatOpensWhen(int count) {
    return 'El chat se abre cuando se unan $count personas más. Allí elegís juntos el lugar y la hora.';
  }

  @override
  String get leaveTable => 'Dejar la mesa';

  @override
  String tableInviteTitle(String name) {
    return '$name ha montado una mesa pequeña y te invita.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined unidos · $pending pendientes. El chat se abre cuando sois tres.';
  }

  @override
  String get join => 'Unirme';

  @override
  String get notTonight => 'Esta noche no';

  @override
  String get tonight => 'Esta noche';

  @override
  String get freeTonight => 'Libres esta noche';

  @override
  String get sharedGroupsOnly => 'Solo personas de tus grupos';

  @override
  String get nobodyFree => 'Ahora no hay nadie libre de tus grupos.';

  @override
  String get howItWorks => '¿Cómo funciona?';

  @override
  String get howStep1 =>
      'Di «Estoy libre esta noche» y, si quieres, escribe qué te apetece.';

  @override
  String get howStep2 =>
      'Las personas de tus grupos te ven y tú ves quién está libre.';

  @override
  String get howStep3 =>
      'Monta una mesa pequeña; el chat se abre con tres personas y allí elegís lugar y hora.';

  @override
  String get upcoming => 'Próximos';

  @override
  String get calendar => 'Calendario';

  @override
  String get noUpcomingJoined => 'No te has apuntado a ningún evento próximo.';

  @override
  String get showAll => 'Mostrar todo';

  @override
  String get noUpcoming60 =>
      'Tus grupos no tienen eventos en los próximos 60 días.';

  @override
  String get findGroup => 'Buscar grupo';

  @override
  String filterAll(int count) {
    return 'Todos · $count';
  }

  @override
  String filterMine(int count) {
    return 'Me apunté · $count';
  }

  @override
  String get tomorrow => 'Mañana';

  @override
  String get going => 'Vas';

  @override
  String get waitlisted => 'En lista de espera';

  @override
  String get awaitingApproval => 'Pendiente de aprobación';

  @override
  String get full => 'Completo';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity asistentes';
  }

  @override
  String get startingSoon => 'Empieza pronto';

  @override
  String get next6Hours => 'Próximas 6 horas';

  @override
  String get wantWelcome => 'Quiero que me reciban';

  @override
  String get wantWelcomeHint =>
      'Un miembro voluntario del grupo te recibe en la entrada; no irás solo.';

  @override
  String get noteForGreeter => 'Una nota para que te reconozcan (opcional)';

  @override
  String get noteForGreeterHint => 'Ej.: Llevo chaqueta roja y mochila azul';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String get welcomeRequestSent =>
      'Tu solicitud se ha enviado a los anfitriones. Te avisaremos cuando alguien la acepte.';

  @override
  String get editMeetingNote => 'Editar nota de encuentro';

  @override
  String welcomePerson(String name) {
    return 'Recibir a $name';
  }

  @override
  String describedAs(String note) {
    return 'Se describió así: $note';
  }

  @override
  String get whereMeet => '¿Dónde os encontraréis?';

  @override
  String get whereMeetHint => 'Ej.: Delante del café de la entrada, 8:45';

  @override
  String get save => 'Guardar';

  @override
  String get iWillWelcome => 'Lo recibo yo';

  @override
  String get noteUpdated => 'Nota de encuentro actualizada.';

  @override
  String youWillWelcome(String name) {
    return 'Recibirás a $name; ha visto la nota de encuentro.';
  }

  @override
  String get stopWelcoming => 'Dejar de recibir';

  @override
  String stopWelcomingBody(String name) {
    return 'Buscaremos otro anfitrión para $name y se lo diremos.';
  }

  @override
  String get release => 'Dejar';

  @override
  String get releasedWelcome =>
      'Has dejado de recibir; buscamos otro anfitrión.';

  @override
  String get firstTime => '¿Vienes por primera vez?';

  @override
  String greetersAvailable(int count) {
    return 'Este grupo tiene $count anfitriones. Que uno te reciba en la entrada y te presente al grupo.';
  }

  @override
  String get youWelcomed => 'Personas que recibes';

  @override
  String meetingAt(String note) {
    return 'Encuentro: $note';
  }

  @override
  String get thankedYou => 'Te dio las gracias';

  @override
  String optionsFor(String name) {
    return 'Opciones para $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Esperando recibimiento ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas tienen anfitrión.',
      one: '1 persona tiene anfitrión.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Primera vez';

  @override
  String get max3Welcomes => 'Puedes recibir hasta 3 personas por evento.';

  @override
  String get greeterJoinHint =>
      'Eres anfitrión. Apúntate al evento para recibir a los nuevos.';

  @override
  String get lookingGreeter => 'Buscando anfitrión';

  @override
  String get lookingGreeterHint =>
      'Hemos avisado a los anfitriones. Recibirás una notificación cuando alguien acepte.';

  @override
  String yourNote(String note) {
    return 'Tu nota: $note';
  }

  @override
  String get welcomeWithdrawn => 'Tu solicitud se ha retirado.';

  @override
  String get withdrawRequest => 'Retirar solicitud';

  @override
  String get greetedBy => 'Te recibió';

  @override
  String get willGreet => 'Te recibirá';

  @override
  String get thank => 'Dar las gracias';

  @override
  String thankReceived(String name) {
    return '$name ha recibido tu agradecimiento.';
  }

  @override
  String get thanked => 'Has dado las gracias.';

  @override
  String get cancelWelcome => 'Cancelar recibimiento';

  @override
  String get nowGreeter =>
      'Ahora eres anfitrión. Te avisaremos cuando alguien nuevo pida que lo reciban.';

  @override
  String get noLongerGreeter => 'Ya no eres anfitrión.';

  @override
  String get welcomeSection => 'Bienvenida';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anfitriones',
      one: '1 anfitrión',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Los nuevos pueden pedir que los reciban desde la página del evento. Si eres anfitrión, te avisaremos; los recibes en la entrada y los presentas al grupo.';

  @override
  String greeterMemberHint(int count) {
    return 'Este grupo tiene $count anfitriones. En tu primer evento, toca «Quiero que me reciban».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Este grupo tiene $count anfitriones: no irás solo a tu primer evento, alguien te recibirá en la entrada.';
  }

  @override
  String get becomeGreeter => 'Hacerme anfitrión';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String seatsGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas van',
      one: '1 persona va',
    );
    return '$_temp0';
  }

  @override
  String seatsOf(int count, int capacity) {
    return '$count / $capacity personas';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return '$count / $capacity personas · $waiting en espera';
  }

  @override
  String summaryAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Asistieron $count personas',
      one: 'Asistió 1 persona',
    );
    return '$_temp0';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ ($count valoraciones)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Lista de espera · n.º $place';
  }

  @override
  String get eventCanceled => 'Este evento se ha cancelado.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Este evento se ha cancelado: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, $stars estrellas';
  }

  @override
  String get conflicting => 'Coincide';

  @override
  String get events => 'Eventos';

  @override
  String get create => 'Crear';

  @override
  String eventsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te quedan $count eventos este mes.',
      one: 'Te queda 1 evento este mes.',
    );
    return '$_temp0';
  }

  @override
  String get eventsLimitReached =>
      'Se ha alcanzado el límite de eventos de este mes. Mejora el plan para tener más.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · $count valoraciones de sus eventos';
  }

  @override
  String get howWasIt => '¿Qué tal fue?';

  @override
  String get howWasItHint =>
      'Valora el evento al que fuiste; todos ven solo la media.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty =>
      'Una ruta, un concierto o una quedada: crea el primer evento.';

  @override
  String get requestSent =>
      'Tu solicitud se ha enviado. Te avisaremos cuando el organizador decida.';

  @override
  String get attendanceSaved =>
      'Te has apuntado. Te lo recordaremos antes de empezar.';

  @override
  String waitlistJoined(int place) {
    return 'Estás en lista de espera (n.º $place). Te avisaremos si queda una plaza.';
  }

  @override
  String get conflictTitle => 'Tienes otro evento a la misma hora';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Si no puedes ir, desapúntate y deja tu plaza a otra persona.';

  @override
  String get conflictMany =>
      'Si no puedes ir, desapúntate y deja tus plazas a otras personas.';

  @override
  String get keepBoth => 'Mantener ambos';

  @override
  String get leaveOther => 'Dejar el otro';

  @override
  String get leaveOthers => 'Dejar los otros';

  @override
  String get leftOther => 'Has dejado el otro evento; tu plaza queda libre.';

  @override
  String get leftOthers => 'Has dejado los otros eventos.';

  @override
  String approvedPerson(String name) {
    return '$name ya está apuntado.';
  }

  @override
  String declinedPerson(String name) {
    return 'Solicitud rechazada; se ha avisado a $name.';
  }

  @override
  String get calendarFailed =>
      'No se pudo abrir el archivo de calendario. Inténtalo de nuevo.';

  @override
  String get stopSeriesTitle => '¿Detener la repetición?';

  @override
  String get stopSeriesBody =>
      'No se abrirán fechas nuevas. Las ya abiertas se mantienen; puedes cancelarlas una a una.';

  @override
  String get stop => 'Detener';

  @override
  String get seriesStopped => 'Repetición detenida.';

  @override
  String get eventCanceledToast => 'Evento cancelado.';

  @override
  String get eventNotFound => 'Este evento no existe o ya no está visible.';

  @override
  String get goBack => 'Volver';

  @override
  String joinGroupFirst(String name) {
    return 'Unirse a $name';
  }

  @override
  String get sendJoinRequest => 'Solicitar asistencia';

  @override
  String get joinWaitlist => 'Entrar en lista de espera';

  @override
  String get leaveEvent => 'Desapuntarme';

  @override
  String get leaveWaitlist => 'Salir de la lista de espera';

  @override
  String get requestWithdrawn => 'Tu solicitud se ha retirado.';

  @override
  String get attendanceRemoved => 'Te has desapuntado.';

  @override
  String eventShareText(String title) {
    return '$title · únete en GWAY:';
  }

  @override
  String get eventLinkCopied => 'Enlace del evento copiado.';

  @override
  String get report => 'Denunciar';

  @override
  String get eventOptions => 'Opciones del evento';

  @override
  String get edit => 'Editar';

  @override
  String get cancelThisDate => 'Cancelar esta fecha';

  @override
  String get stopRepeat => 'Detener la repetición';

  @override
  String get startedOrEnded => 'Empezado o terminado';

  @override
  String seriesUntil(String label, String date) {
    return '$label · hasta el $date';
  }

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String fee(String fee) {
    return 'Precio: $fee';
  }

  @override
  String get feeNotice => 'Se paga al organizador; GWAY no cobra pagos.';

  @override
  String get areYouComing => '¿Vienes?';

  @override
  String get areYouComingHint =>
      'Si no puedes ir, deja tu plaza a la lista de espera.';

  @override
  String get yesComing => 'Sí, voy';

  @override
  String get confirmThanks =>
      'Gracias, hemos avisado al organizador de que vas.';

  @override
  String get cantCome => 'No puedo ir';

  @override
  String get spotFreed => 'Te has desapuntado; tu plaza queda libre.';

  @override
  String get confirmedComing => 'Has confirmado que vas.';

  @override
  String get otherEventSameTime => 'Tienes otro evento a esta hora';

  @override
  String get needsApproval => 'Asistencia con aprobación';

  @override
  String get requirements => 'Requisitos';

  @override
  String get equipment => 'Equipo necesario';

  @override
  String joinRequestsCount(int count) {
    return 'Solicitudes ($count)';
  }

  @override
  String get attendees => 'Asistentes';

  @override
  String confirmedOf(int going, int confirmed) {
    return '$confirmed de $going asistentes han confirmado.';
  }

  @override
  String confirmedName(String name) {
    return '$name · confirmado';
  }

  @override
  String get shareWasThere => 'Compartir la tarjeta «Yo estuve allí»';

  @override
  String get howDidItGo => '¿Qué tal fue?';

  @override
  String reviewsCount(int count) {
    return 'Valoraciones ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Solo los organizadores ven las notas.';

  @override
  String get attendanceCheck => 'Asistencia';

  @override
  String get attendanceCheckHint =>
      'Marca a quienes no vinieron; solo los asistentes cuentan para aportaciones e insignias. Abierto 7 días tras el final.';

  @override
  String markedCame(String name) {
    return '$name marcado como asistente.';
  }

  @override
  String markedMissed(String name) {
    return '$name marcado como ausente.';
  }

  @override
  String get didntCome => 'No vino';

  @override
  String get came => 'Vino';

  @override
  String get memories => 'Recuerdos';

  @override
  String get shareMemory => 'Compartir un recuerdo';

  @override
  String get eventPolls => 'Encuestas del evento';

  @override
  String get noEditPermission => 'No tienes permiso para editar este evento.';

  @override
  String get editEvent => 'Editar evento';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get addCover => 'Añadir imagen de portada';

  @override
  String get titleExample => 'Ej.: Ruta por el bosque';

  @override
  String get starts => 'Inicio';

  @override
  String get endsOptional => 'Fin (opcional)';

  @override
  String get notSpecified => 'Sin especificar';

  @override
  String get removeEnd => 'Quitar fin';

  @override
  String get repeat => 'Repetir';

  @override
  String get noRepeat => 'No se repite';

  @override
  String get weekly => 'Cada semana';

  @override
  String get biweekly => 'Cada dos semanas';

  @override
  String get lastDateOptional => 'Última fecha (opcional)';

  @override
  String get untilYouStop => 'Hasta que lo detengas';

  @override
  String get removeLastDate => 'Quitar última fecha';

  @override
  String get repeatHint =>
      'Las siguientes fechas se abren solas con 4 semanas de antelación y cada una cuenta para el límite mensual.';

  @override
  String get surpriseVenue => 'Lugar sorpresa';

  @override
  String get surpriseHint =>
      'El lugar se revela solo a los asistentes, a la hora que elijas antes de empezar.';

  @override
  String get hintPublic => 'Pista (la ven todos)';

  @override
  String get place => 'Lugar';

  @override
  String get hintExample => 'Ej.: Junto al mar, en la orilla asiática';

  @override
  String get placeExample => 'Ej.: Entrada del parque u Online';

  @override
  String get writeHint => 'Escribe una pista.';

  @override
  String get writePlace => 'Escribe el lugar.';

  @override
  String get realVenue => 'Lugar real (solo asistentes)';

  @override
  String get realVenueExample => 'Ej.: Delante del teatro';

  @override
  String get writeRealVenue => 'Escribe el lugar real.';

  @override
  String get whenReveal => '¿Cuándo revelarlo?';

  @override
  String hoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas antes',
      one: '1 hora antes',
    );
    return '$_temp0';
  }

  @override
  String get linkOptional => 'Enlace de mapa u online (opcional)';

  @override
  String get httpsRequired => 'El enlace debe empezar por https://.';

  @override
  String get description => 'Descripción';

  @override
  String get capacity => 'Aforo (vacío = sin límite)';

  @override
  String get capacityHint =>
      'Al llenarse, los nuevos van a la lista de espera.';

  @override
  String get capacityRange => 'El aforo debe ser de 1 a 10.000.';

  @override
  String get requirementsOptional => 'Requisitos (opcional)';

  @override
  String get requirementsExample => 'Ej.: Experiencia de al menos 10 km';

  @override
  String get equipmentOptional => 'Equipo necesario (opcional)';

  @override
  String get equipmentExample => 'Ej.: Casco, Agua, Chubasquero';

  @override
  String get equipmentHint => 'Separa con comas; hasta 10 elementos.';

  @override
  String get equipmentLimit =>
      'Hasta 10 elementos, de 60 caracteres como máximo.';

  @override
  String get approvalRequired => 'Asistencia con aprobación';

  @override
  String get approvalHint =>
      'Quien quiera ir envía una solicitud; tú la apruebas.';

  @override
  String get feeOptional => 'Precio (opcional)';

  @override
  String get feeInfoOnly => 'Solo informativo; GWAY no cobra pagos.';

  @override
  String get amount => 'Importe';

  @override
  String get amountExample => 'Ej.: 150';

  @override
  String get validAmount => 'Introduce un importe válido.';

  @override
  String get paymentNote => 'Nota de pago';

  @override
  String get paymentNoteExample => 'Ej.: Se paga en efectivo allí';

  @override
  String get createEvent => 'Crear evento';

  @override
  String get rateEvent => 'Valorar el evento';

  @override
  String get yourReview => 'Tu valoración';

  @override
  String starsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String get noteToOrganizers => 'Nota para los organizadores (opcional)';

  @override
  String get noteToOrganizersHint =>
      'Solo los organizadores ven tu nota; los demás solo ven la media.';

  @override
  String get reviewDeleted => 'Tu valoración se ha eliminado.';

  @override
  String get delete => 'Eliminar';

  @override
  String get reviewSaved => 'Gracias, tu valoración se ha guardado.';

  @override
  String get groupNext => 'Próximos eventos del grupo';

  @override
  String sameDayOthers(int count) {
    return 'Hay $count eventos más de la misma categoría en tu provincia ese día. Elige otro día si no quieres que tus miembros tengan que escoger.';
  }

  @override
  String get cancelEvent => 'Cancelar evento';

  @override
  String get cancelEventBody =>
      'Se avisa a los asistentes y a la lista de espera. No se puede deshacer.';

  @override
  String get reason => 'Motivo';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String hint(String hint) {
    return 'Pista: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Pista: $hint · Se revelará a los asistentes el $when.';
  }

  @override
  String get venueRevealed =>
      'El lugar se ha revelado a los asistentes. Apúntate para verlo.';

  @override
  String venueRevealAt(String when) {
    return 'El lugar se revelará a los asistentes el $when.';
  }

  @override
  String get currencyTry => '₺ TRY';
}
