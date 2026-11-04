// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class ProfileL10nEs extends ProfileL10n {
  ProfileL10nEs([String locale = 'es']) : super(locale);

  @override
  String get unsupportedImage =>
      'Este tipo de archivo no es compatible. Elige JPEG, PNG o WebP.';

  @override
  String get usernameTaken =>
      'Este nombre de usuario ya está en uso. Prueba otro.';

  @override
  String get checkInput => 'Revisa los datos que has introducido.';

  @override
  String get usernameReserved =>
      'Este nombre de usuario no se puede usar. Prueba otro.';

  @override
  String get usernameCooldown =>
      'Solo puedes cambiar tu nombre de usuario una vez cada 30 días.';

  @override
  String get maxInterests10 => 'Puedes elegir hasta 10 intereses.';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelBeginnerHint => 'Estoy empezando';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelIntermediateHint => 'Lo hago con regularidad';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String get levelAdvancedHint => 'Tengo experiencia';

  @override
  String get slotWeekdayMorning => 'Mañanas entre semana';

  @override
  String get slotWeekdayNoon => 'Mediodías entre semana';

  @override
  String get slotWeekdayEvening => 'Tardes-noches entre semana';

  @override
  String get slotWeekendMorning => 'Mañanas de fin de semana';

  @override
  String get slotWeekendAfternoon => 'Tardes de fin de semana';

  @override
  String get slotWeekendEvening => 'Noches de fin de semana';

  @override
  String get partMorning => 'Mañana';

  @override
  String get partNoon => 'Mediodía';

  @override
  String get partEvening => 'Noche';

  @override
  String get goalFun => 'Divertirme';

  @override
  String get goalFitness => 'Mantenerme en forma';

  @override
  String get goalCompetition => 'Prepararme para competir';

  @override
  String get goalLearning => 'Aprender cosas nuevas';

  @override
  String get goalMentoring => 'Compartir mi experiencia';

  @override
  String get goalSocial => 'Conocer gente nueva';

  @override
  String get freqMonthly => 'Unas veces al mes';

  @override
  String get freqWeekly => 'Una vez por semana';

  @override
  String get freqFewWeekly => '2–3 veces por semana';

  @override
  String get freqDaily => 'Casi todos los días';

  @override
  String get sizePair => 'Uno a uno';

  @override
  String get sizeSmall => 'Grupo pequeño (3–6)';

  @override
  String get sizeLarge => 'Grupo grande';

  @override
  String get looking => 'Busca equipo';

  @override
  String lookingWithLevel(String level) {
    return 'Busca equipo · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Misma actividad: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Intereses en común: $list';
  }

  @override
  String get reasonProvince => 'Estáis en la misma provincia';

  @override
  String reasonGroup(String group) {
    return 'Grupo en común: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count grupos en común';
  }

  @override
  String reasonLevel(String level) {
    return 'Mismo nivel: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Horario en común: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Objetivos en común: $list';
  }

  @override
  String get reasonFrequency => 'Queréis quedar con la misma frecuencia';

  @override
  String get hasVehicle => 'Tiene vehículo';

  @override
  String get hasEquipment => 'Tiene su propio equipo';

  @override
  String get usernameRequired => 'Elige un nombre de usuario.';

  @override
  String usernameMin(int min) {
    return 'El nombre de usuario debe tener al menos $min caracteres.';
  }

  @override
  String usernameMax(int max) {
    return 'El nombre de usuario puede tener como máximo $max caracteres.';
  }

  @override
  String get usernameChars => 'Usa solo a–z, 0–9, guion bajo (_) y punto (.).';

  @override
  String get usernameDots =>
      'El nombre de usuario no puede empezar ni terminar con un punto.';

  @override
  String get usernameDoubleDot => 'No puedes usar dos puntos seguidos.';

  @override
  String get nameRequired => 'Introduce tu nombre.';

  @override
  String nameMax(int max) {
    return 'El nombre puede tener como máximo $max caracteres.';
  }

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get save => 'Guardar';

  @override
  String get profileInfo => 'Datos del perfil';

  @override
  String get profileInfoHint =>
      'Estos datos son visibles para todos en tu perfil.';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get usernameEvery30 =>
      'Puedes cambiar tu nombre de usuario una vez cada 30 días.';

  @override
  String usernameLockedUntil(String date) {
    return 'Podrás cambiarlo después del $date.';
  }

  @override
  String get about => 'Sobre mí';

  @override
  String get aboutHint => 'Habla de ti y de las actividades que te gustan.';

  @override
  String get interests => 'Intereses';

  @override
  String interestsMax(int max) {
    return 'Puedes elegir hasta $max.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get remove => 'Quitar';

  @override
  String get removeCover => 'Quitar foto de portada';

  @override
  String get addCover => 'Añadir portada';

  @override
  String get changeCover => 'Cambiar portada';

  @override
  String get changeAvatar => 'Cambiar foto de perfil';

  @override
  String get photos => 'Foto de perfil y portada';

  @override
  String get photosHint => 'JPEG, PNG o WebP · hasta 5 MB';

  @override
  String get addAvatar => 'Añadir foto de perfil';

  @override
  String get removeAvatar => 'Quitar foto de perfil';

  @override
  String get followers => 'Seguidores';

  @override
  String get following => 'Siguiendo';

  @override
  String get privateLists =>
      'Esta cuenta es privada. Síguela para ver sus listas.';

  @override
  String get backToProfile => 'Volver al perfil';

  @override
  String get noFollowers => 'Aún no hay seguidores.';

  @override
  String get noFollowing => 'Aún no sigue a nadie.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get removeFollower => 'Eliminar seguidor';

  @override
  String removeFollowerBody(String username) {
    return '¿Eliminar a @$username de tus seguidores? No se le notificará.';
  }

  @override
  String get removeAction => 'Eliminar';

  @override
  String get friends => 'Sois amigos';

  @override
  String get followRequests => 'Solicitudes de seguimiento';

  @override
  String get noFollowRequests =>
      'No tienes solicitudes pendientes. Las cuentas privadas las aprueban aquí.';

  @override
  String get approve => 'Aprobar';

  @override
  String get delete => 'Eliminar';

  @override
  String get blockedAccounts => 'Cuentas bloqueadas';

  @override
  String get noBlocked =>
      'No has bloqueado a nadie. Puedes bloquear desde el menú de un perfil.';

  @override
  String get unblock => 'Desbloquear';

  @override
  String get onboardWho => 'Vamos a conocerte';

  @override
  String get onboardWhoHint =>
      'Elige el nombre y el nombre de usuario que aparecerán en tu perfil.';

  @override
  String get onboardPhoto => 'Foto de perfil';

  @override
  String get onboardPhotoHint =>
      'Para que tus grupos te reconozcan. También puedes añadirla después.';

  @override
  String get onboardInterests => 'Tus intereses';

  @override
  String onboardInterestsHint(int max) {
    return 'Elige hasta $max para que te sugiramos grupos a tu medida.';
  }

  @override
  String get back => 'Atrás';

  @override
  String stepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get continueAction => 'Continuar';

  @override
  String get finish => 'Terminar';

  @override
  String get usernameHelper => 'Usa minúsculas, números, _ y .';

  @override
  String get avatarPreview => 'Vista previa de la foto de perfil';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get chooseAnotherPhoto => 'Elegir otra foto';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Ajustes';

  @override
  String get profileNotFound => 'Este perfil no existe o ya no está visible.';

  @override
  String get backToMyProfile => 'Volver a mi perfil';

  @override
  String suspendedUntil(String date) {
    return 'Esta cuenta está suspendida hasta el $date.';
  }

  @override
  String get followsYou => 'Te sigue';

  @override
  String get yourTeammate => 'Tu compañero de equipo';

  @override
  String joined(String date) {
    return 'Se unió en $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes de seguimiento esperan tu aprobación.',
      one: '1 solicitud de seguimiento espera tu aprobación.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Revisar';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes de equipo te esperan.',
      one: '1 solicitud de equipo te espera.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Has bloqueado esta cuenta';

  @override
  String get youBlockedHint =>
      'Si desbloqueas, volveréis a ver vuestras publicaciones.';

  @override
  String get privateAccount => 'Esta cuenta es privada';

  @override
  String get privateAccountHint =>
      'Sigue esta cuenta para ver sus fotos, vídeos e historias.';

  @override
  String get addInterestsNudge =>
      'Añade tus intereses y te encontraremos grupos y compañeros.';

  @override
  String get add => 'Añadir';

  @override
  String blockTitle(String username) {
    return '¿Bloquear a @$username?';
  }

  @override
  String get blockBody =>
      'No verá tu perfil, publicaciones ni historias, no podrá encontrarte ni escribirte. Dejaréis de seguiros. No se le avisará del bloqueo.';

  @override
  String get block => 'Bloquear';

  @override
  String get becomeTeammates => 'Ser compañeros de equipo';

  @override
  String nowTeammates(String name) {
    return '$name y tú ya sois compañeros de equipo.';
  }

  @override
  String get acceptTeammate => 'Aceptar solicitud de equipo';

  @override
  String get requestWithdrawn => 'Solicitud retirada.';

  @override
  String get withdrawTeammate => 'Retirar solicitud de equipo';

  @override
  String get teammateEnded => 'Ya no sois compañeros de equipo.';

  @override
  String get endTeammate => 'Dejar de ser compañeros';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get linkCopied => 'Enlace del perfil copiado.';

  @override
  String get copyLink => 'Copiar enlace del perfil';

  @override
  String get removedFromFollowers => 'Eliminado de tus seguidores.';

  @override
  String get removeFromFollowers => 'Eliminar de mis seguidores';

  @override
  String get report => 'Denunciar';

  @override
  String get unblocked => 'Desbloqueado.';

  @override
  String get statPosts => 'Publicaciones';

  @override
  String get statFollowers => 'Seguidores';

  @override
  String get statFollowing => 'Siguiendo';

  @override
  String withdrawFollowBody(String username) {
    return '¿Retirar tu solicitud de seguimiento a @$username?';
  }

  @override
  String unfollowBody(String username) {
    return '¿Dejar de seguir a @$username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return '¿Dejar de seguir a @$username? La cuenta es privada, así que tendrías que volver a pedirlo para ver sus publicaciones.';
  }

  @override
  String get withdrawRequest => 'Retirar solicitud';

  @override
  String get unfollow => 'Dejar de seguir';

  @override
  String get followBack => 'Seguir también';

  @override
  String get follow => 'Seguir';

  @override
  String get requestSent => 'Solicitado';

  @override
  String get followingState => 'Siguiendo';

  @override
  String noAccountMatch(String query) {
    return 'Ninguna cuenta coincide con «$query».';
  }

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get searchHint =>
      'Empieza a escribir para buscar personas o etiquetas.';

  @override
  String get refreshSuggestions => 'Actualizar sugerencias';

  @override
  String get suggestionsForYou => 'Sugerencias para ti';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lo siguen $count personas a las que sigues',
      one: 'Lo sigue 1 persona a la que sigues',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Cuenta popular';

  @override
  String get seePackage => 'Ver el plan';

  @override
  String requestSentNotify(String name) {
    return 'Solicitud enviada. Te avisaremos cuando $name acepte.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Ser compañero de equipo de $name';
  }

  @override
  String get shortMessage => 'Un mensaje corto (opcional)';

  @override
  String get shortMessageHint => '¿El sábado por la mañana en el parque?';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String get findTeammates => 'Buscar compañeros de equipo';

  @override
  String get myTeammatePrefs => 'Mis preferencias de equipo';

  @override
  String get tabSuggestions => 'Sugerencias';

  @override
  String get tabRequests => 'Solicitudes';

  @override
  String tabRequestsCount(int count) {
    return 'Solicitudes ($count)';
  }

  @override
  String get tabMyTeam => 'Mi equipo';

  @override
  String get findYourTeammate => 'Encuentra tu compañero de equipo';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas quieren ser tus compañeras de equipo',
      one: '1 persona quiere ser tu compañera de equipo',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Ver sugerencias, enviar y aceptar solicitudes y escribir a tus compañeros se desbloquea con el plan Compañero de equipo.';

  @override
  String get beVisible => 'Hazte visible tú también';

  @override
  String get beVisibleBody =>
      'Activa «Busco equipo» y quienes compartan tus gustos podrán enviarte solicitudes.';

  @override
  String get setPrefs => 'Configurar mis preferencias';

  @override
  String get nowPublicSuggest =>
      'Tu cuenta ahora es pública; puedes aparecer en las sugerencias.';

  @override
  String get privateHidden =>
      'Tu cuenta es privada; no apareces en las sugerencias';

  @override
  String get privateHiddenBody =>
      'Las cuentas privadas no aparecen en las sugerencias de equipo. Si haces pública tu cuenta, también se aprueban las solicitudes de seguimiento pendientes.';

  @override
  String get makePublic => 'Hacer pública mi cuenta';

  @override
  String get noSuggestions =>
      'Por ahora no hay coincidencias. Completa tus intereses y preferencias para recibir más sugerencias.';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String get whySuggested => 'Por qué se sugiere';

  @override
  String get noPendingTeammate => 'No hay solicitudes de equipo pendientes.';

  @override
  String get seeSuggestions => 'Ver sugerencias';

  @override
  String get incoming => 'Recibidas';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get requestDeclined => 'Solicitud rechazada.';

  @override
  String get outgoing => 'Enviadas';

  @override
  String get awaitingReply => 'Esperando respuesta';

  @override
  String get withdraw => 'Retirar';

  @override
  String get noTeammates =>
      'Aún no tienes compañeros. Empieza enviando una solicitud a alguien sugerido.';

  @override
  String optionsFor(String name) {
    return 'Opciones para $name';
  }

  @override
  String get teammatePrefs => 'Preferencias de equipo';

  @override
  String get prefsSavedVisible =>
      'Preferencias guardadas. Ahora aparecerás en las sugerencias.';

  @override
  String get prefsSaved => 'Preferencias guardadas.';

  @override
  String get whatToDo => '¿Qué quieres hacer?';

  @override
  String activitiesHint(int max) {
    return 'Actividades para las que buscas compañeros. Hasta $max.';
  }

  @override
  String get yourLevel => 'Tu nivel';

  @override
  String get yourGoals => 'Tus objetivos';

  @override
  String get multipleChoice => 'Puedes elegir más de uno.';

  @override
  String get howOften => '¿Con qué frecuencia quieres quedar?';

  @override
  String get whenFree => '¿Cuándo estás libre?';

  @override
  String get whenFreeHint => 'Toca los momentos en que estás libre.';

  @override
  String get whatTeam => '¿Qué tipo de equipo quieres?';

  @override
  String get whichProvince => '¿En qué provincia estás?';

  @override
  String get provinceHint =>
      'Solo se usa para las sugerencias; no aparece en tu perfil.';

  @override
  String get province => 'Provincia';

  @override
  String get ratherNotSay => 'Prefiero no decirlo';

  @override
  String get extras => 'Datos adicionales';

  @override
  String get iHaveVehicle => 'Tengo vehículo';

  @override
  String get iHaveVehicleHint => 'Puedo compartir coche.';

  @override
  String get iHaveEquipment => 'Tengo mi propio equipo';

  @override
  String get iHaveEquipmentHint =>
      'Tengo bici, tienda, raqueta u otro material.';

  @override
  String get describeYourself => 'Descríbete';

  @override
  String get describeHint => 'Aparece bajo tu nombre en las sugerencias.';

  @override
  String get describeExample =>
      'Busco compañía para caminar los fines de semana por la mañana.';

  @override
  String get willAppear => 'Aparecerás en las sugerencias.';

  @override
  String get notAppearing => 'Ahora no apareces en las sugerencias.';

  @override
  String get lookingForTeam => 'Busco equipo';

  @override
  String get lookingOn =>
      'Apareces en las sugerencias; pueden enviarte solicitudes de equipo.';

  @override
  String get lookingOff =>
      'Actívalo y te encontrarán quienes compartan tus gustos. Las cuentas privadas no aparecen en las sugerencias.';

  @override
  String prefsComplete(int percent) {
    return 'Preferencias completas al $percent %';
  }

  @override
  String get prefsCompleteHint =>
      'Cuanto más completes, mejores serán las sugerencias.';

  @override
  String get weekday => 'Entre semana';

  @override
  String get weekend => 'Fin de semana';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get available => 'Disponible';

  @override
  String get taken => 'En uso';
}
