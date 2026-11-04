// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SocialAppL10nEs extends SocialAppL10n {
  SocialAppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get posts => 'Publicaciones';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get noOwnPosts =>
      'Aún no has compartido publicaciones. Comparte tu primera foto o vídeo.';

  @override
  String get noPosts => 'Aún no hay publicaciones.';

  @override
  String get shareFirstOwn => 'Comparte tu primera publicación';

  @override
  String get groupFirstPost =>
      'Sé el primero en publicar en el muro del grupo.';

  @override
  String get groupNoPosts => 'Aún no hay publicaciones en este grupo.';

  @override
  String get shareFirstGroup => 'Compartir la primera publicación';

  @override
  String get groupNotFound => 'Grupo no encontrado.';

  @override
  String get memoriesEmpty =>
      'Aún no se han compartido recuerdos. Los asistentes pueden añadir aquí sus fotos.';

  @override
  String get plan => 'Plan';

  @override
  String get payment => 'Pago';

  @override
  String get onlyOwnerBilling =>
      'Solo el propietario del grupo puede gestionar los planes.';

  @override
  String get backToGroup => 'Volver al grupo';

  @override
  String get writeSupportAboutGroup =>
      'Escribir al equipo de la plataforma sobre este grupo';

  @override
  String get search => 'Buscar';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get goodNight => 'Buenas noches';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas tardes';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Hoy';

  @override
  String get tabGroups => 'Grupos';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get tabMe => 'Yo';

  @override
  String get tonightSay => '¿Libre? Dilo y arma una mesa';

  @override
  String get tonightTableSet => 'Tu mesa está lista';

  @override
  String get tonightInvited => 'Te han invitado a una mesa';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas están libres como tú',
      one: '1 persona está libre como tú',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Estás libre · hasta las 4:00';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas están libres esta noche',
      one: '1 persona está libre esta noche',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Planes de tus grupos';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes',
      one: '1 plan',
    );
    return '$_temp0 · $mine asistencias';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes',
      one: '1 plan',
    );
    return '$_temp0, 60 días';
  }

  @override
  String get forToday => 'Para hoy';

  @override
  String get tonight => 'Esta noche';

  @override
  String get upcoming => 'Próximos';

  @override
  String get share => 'Compartir';

  @override
  String get post => 'Publicación';

  @override
  String get postHint => 'Hasta 10 fotos o vídeos';

  @override
  String get story => 'Historia';

  @override
  String get storyHint => 'Visible 24 horas';

  @override
  String get group => 'Grupo';

  @override
  String get groupHint => 'Crea tu propia comunidad';

  @override
  String get create => 'Crear';

  @override
  String get messages => 'Mensajes';

  @override
  String get matching => 'Matches';

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get pageNotFound =>
      'No encontramos esa página. El enlace puede ser antiguo o incorrecto.';

  @override
  String get backHome => 'Volver al inicio';

  @override
  String get groupsLeague => 'Liga de grupos';

  @override
  String get exploreOnMap => 'Explorar en el mapa';

  @override
  String get yearMenu =>
      'Resumen del año, mi mapa de exploración y gente que conocí';

  @override
  String get yearSummary => 'Resumen del año';

  @override
  String get yearSummaryHint =>
      'Tus quedadas de este año, en una tarjeta para compartir';

  @override
  String get explorationMap => 'Mi mapa de exploración';

  @override
  String get explorationMapHint =>
      'Provincias de los eventos a los que asististe';

  @override
  String get metPeople => 'Gente que conocí';

  @override
  String get metPeopleHint =>
      'Personas con las que te diste la mano en eventos';

  @override
  String get findTeammates => 'Buscar compañeros de equipo';

  @override
  String get saved => 'Guardados';

  @override
  String get gateError =>
      'No se pudieron cargar tus datos. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get searchPeople => 'Buscar personas';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get settings => 'Ajustes';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get teammatePrefs => 'Preferencias de compañeros de equipo';

  @override
  String get matchProfile => 'Perfil de matches';

  @override
  String get voiceCalls => 'Llamadas de voz';

  @override
  String get blockedAccounts => 'Cuentas bloqueadas';

  @override
  String get storyArchive => 'Archivo de historias';

  @override
  String get notificationPrefs => 'Preferencias de notificaciones';

  @override
  String get mySanctions => 'Mis sanciones de grupo';

  @override
  String get userGuide => 'Guía de uso';

  @override
  String get supportFeedback => 'Soporte y comentarios';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas nuevas',
      one: '1 respuesta nueva',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Verificación en dos pasos';

  @override
  String get legalDocuments => 'Documentos legales';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get nowPrivate => 'Tu cuenta ahora es privada.';

  @override
  String get nowPublic =>
      'Tu cuenta ahora es pública; las solicitudes pendientes se han aprobado.';

  @override
  String get privateAccount => 'Cuenta privada';

  @override
  String get privateAccountHint =>
      'Si está activado, solo los seguidores que apruebes ven tus publicaciones e historias.';

  @override
  String get groupsNowPublic =>
      'Ahora todos pueden ver tus grupos en tu perfil.';

  @override
  String get groupsNowMembers =>
      'Ahora tus grupos solo los ven los miembros del mismo grupo.';

  @override
  String get showGroups => 'Mostrar mis grupos en mi perfil';

  @override
  String get showGroupsHint =>
      'Si está desactivado, solo los miembros de un grupo ven que perteneces a él; los administradores de otros grupos no.';

  @override
  String get language => 'Idioma';
}
