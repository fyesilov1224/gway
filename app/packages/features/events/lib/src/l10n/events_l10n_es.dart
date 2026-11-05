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
}
