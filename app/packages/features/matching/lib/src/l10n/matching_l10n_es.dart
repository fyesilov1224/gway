// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MatchingL10nEs extends MatchingL10n {
  MatchingL10nEs([String locale = 'es']) : super(locale);

  @override
  String get unsupportedImage => 'Solo se pueden subir fotos JPEG, PNG o WebP.';

  @override
  String get modeFriend => 'Amistad';

  @override
  String get modeDating => 'Citas';

  @override
  String get genderWoman => 'Mujer';

  @override
  String get genderMan => 'Hombre';

  @override
  String get genderNonbinary => 'No binario';

  @override
  String get adultsOnly => 'Los matches son solo para mayores de 18 años.';

  @override
  String get pickMode => 'Elige al menos un modo: Amistad o Citas.';

  @override
  String get pickInterest => 'Elige a quién buscas en Citas.';

  @override
  String get ageRangeInvalid => 'El rango de edad no es válido.';

  @override
  String sharedGroup(String group) {
    return 'Grupo en común: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En común: $group y $count grupos más',
      one: 'En común: $group y 1 grupo más',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'Mis matches';

  @override
  String get pkgRevealText =>
      'Mira con quién hiciste match: nombre, fotos y perfil.';

  @override
  String get pkgChat => 'Chat de match';

  @override
  String get pkgChatText => 'Escribe a tus matches. Incluye ver tus matches.';

  @override
  String get pkgAdmirers => 'Quién te dio like';

  @override
  String get pkgAdmirersText =>
      'Mira quién te dio like y haz match al instante devolviéndolo.';

  @override
  String get pkgUnlimited => 'Likes ilimitados';

  @override
  String get pkgUnlimitedText =>
      'Sin límite diario de likes; incluye deshacer y filtros.';

  @override
  String get pkgSuper => 'Superlike';

  @override
  String get pkgSuperText =>
      '5 superlikes al día; esa persona te ve primero en su baraja.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Una vez al día, aparece primero en las barajas de tus grupos en común durante 30 minutos.';

  @override
  String get pkgTeammates => 'Compañero de equipo';

  @override
  String get pkgTeammatesText =>
      'Envía solicitudes de compañero y chatea con tus compañeros.';

  @override
  String get pkgAll => 'Todo en uno';

  @override
  String get pkgAllText =>
      'Todos los planes en uno, mucho más barato que por separado.';

  @override
  String get superLikedYou => 'Te dio un superlike';

  @override
  String get options => 'Opciones';

  @override
  String get fullProfile => 'Perfil completo';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NO';

  @override
  String get stampSuper => 'SÚPER';

  @override
  String photoOf(String name, int number) {
    return '$name, foto $number';
  }

  @override
  String get about => 'Sobre mí';

  @override
  String get interests => 'Intereses';

  @override
  String get sharedGroupsTitle => 'Grupos en común';

  @override
  String get createProfileTitle => 'Crear perfil de match';

  @override
  String get myProfile => 'Mi perfil de match';

  @override
  String get birthDateLabel => 'Tu fecha de nacimiento';

  @override
  String get pickBasics => 'Elige tu fecha de nacimiento, género y provincia.';

  @override
  String get confirmAgeConsent =>
      'Para continuar, confirma que tienes más de 18 años y da tu consentimiento expreso.';

  @override
  String profileReady(int min) {
    return 'Tu perfil está listo. Ahora añade al menos $min fotos.';
  }

  @override
  String get saved => 'Guardado.';

  @override
  String get pickBirthDate => 'Elegir fecha de nacimiento';

  @override
  String ageNote(int age) {
    return '$age años · tu tarjeta solo muestra tu edad';
  }

  @override
  String get gender => 'Género';

  @override
  String get province => 'Provincia';

  @override
  String get aboutHint => 'Cuéntanos sobre ti';

  @override
  String get jobOptional => 'Profesión (opcional)';

  @override
  String get educationOptional => 'Estudios (opcional)';

  @override
  String get interestsFromProfile =>
      'Tus intereses vienen de tu perfil social.';

  @override
  String get lookingFor => '¿Qué buscas?';

  @override
  String get friendHint => 'Gente con quien ir a eventos y charlar';

  @override
  String get datingHint => 'Una relación romántica';

  @override
  String get whoLookingFor => '¿A quién buscas?';

  @override
  String ageRange(int min, int max) {
    return 'Rango de edad: $min–$max';
  }

  @override
  String get consentTitle => 'Consentimiento';

  @override
  String get iam18 => 'Tengo más de 18 años.';

  @override
  String get consentText =>
      'Para los matches, doy mi consentimiento expreso al tratamiento de mi género, a quién busco, mi fecha de nacimiento, mi provincia y mis fotos, y a que se muestren a las personas de mis grupos en común que activaron los matches. Puedo retirar mi consentimiento en cualquier momento borrando mis datos de match.';

  @override
  String get createProfile => 'Crear mi perfil';

  @override
  String get save => 'Guardar';

  @override
  String get photos => 'Fotos';

  @override
  String photosMin(int min) {
    return 'Añade al menos $min fotos para que se vea tu tarjeta. La primera es la portada.';
  }

  @override
  String photosMax(int max) {
    return 'Hasta $max fotos. La primera es la portada; toca una foto para cambiarla.';
  }

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get cover => 'Portada';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get pauseProfile => 'Pausar mi perfil';

  @override
  String get pauseHint =>
      'Nadie te ve y no llegan tarjetas nuevas; tus matches y chats se mantienen.';

  @override
  String get deleteData => 'Borrar mis datos de match';

  @override
  String get deleteDataHint =>
      'Se borran el perfil, las fotos y los likes; tus matches terminan. Tu consentimiento queda retirado.';

  @override
  String get deleteDataTitle => 'Borrar datos de match';

  @override
  String get deleteDataBody =>
      'Tu perfil de match, tus fotos y likes se borran para siempre y todos tus matches terminan. No se puede deshacer.';

  @override
  String get delete => 'Borrar';

  @override
  String get dataDeleted => 'Tus datos de match se han borrado.';

  @override
  String get itsAMatch => '¡Es un match!';

  @override
  String bothLiked(String name) {
    return 'Tú y $name os habéis dado like.';
  }

  @override
  String get keepSwiping => 'Seguir deslizando';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get reportProfile => 'Denunciar perfil';

  @override
  String get reportPhoto => 'Denunciar esta foto';

  @override
  String get block => 'Bloquear';

  @override
  String get blockHint => 'No os veréis en ningún sitio.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get newMatch => '¡Hiciste match con alguien!';

  @override
  String tapToSee(String date) {
    return 'Toca para ver quién es · $date';
  }

  @override
  String get revealReason =>
      '¡Hiciste match! Consigue el plan Mis matches para ver quién es.';

  @override
  String get keepFriend => 'Quedarse solo como amigos';

  @override
  String get keepDating => 'Quedarse solo en citas';

  @override
  String keepFriendBody(String name) {
    return 'Vuestro match de citas con $name termina para ambos; el de amistad y el chat siguen.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Vuestro match de amistad con $name termina para ambos; el de citas y el chat siguen.';
  }

  @override
  String get keptFriend => 'Ahora solo tenéis match de amistad.';

  @override
  String get keptDating => 'Ahora solo tenéis match de citas.';

  @override
  String get continueAction => 'Continuar';

  @override
  String get endMatch => 'Terminar match';

  @override
  String endMatchBody(String name) {
    return 'Tu match con $name termina y el chat se cierra para ambos. No se puede deshacer.';
  }

  @override
  String get end => 'Terminar';

  @override
  String get matchEnded => 'El match ha terminado.';

  @override
  String get noMatches =>
      'Aún no tienes matches. Aquí aparecerán los likes mutuos.';

  @override
  String get backToDiscover => 'Volver a descubrir';

  @override
  String get report => 'Denunciar';

  @override
  String get matching => 'Match';

  @override
  String get admirers => 'Quién te dio like';

  @override
  String get packages => 'Planes';

  @override
  String get more => 'Más';

  @override
  String get filtersLocked =>
      'Filtrar por edad, provincia e interés viene con el plan Likes ilimitados.';

  @override
  String get filters => 'Filtros';

  @override
  String get suspended =>
      'El equipo de la plataforma cerró tu perfil de match. Escribe a Soporte para saber más.';

  @override
  String addPhotosToStart(int min) {
    return 'Añade al menos $min fotos para mostrar tu tarjeta y empezar a descubrir.';
  }

  @override
  String get paused =>
      'Tu perfil está en pausa; nadie te ve. Tus matches y chats siguen ahí.';

  @override
  String get likesOut =>
      'Se acabaron tus likes gratis de hoy. Da todos los que quieras con Likes ilimitados.';

  @override
  String get supersOut =>
      'Se acabaron tus superlikes de hoy. Mañana se renuevan.';

  @override
  String get superUsed =>
      'Ya usaste tu superlike de hoy. Consigue 5 al día con el plan Superlike.';

  @override
  String get rewindLocked =>
      'Recuperar a alguien que pasaste por error viene con Likes ilimitados.';

  @override
  String rewoundTo(String mode) {
    return 'La última persona que pasaste volvió a la baraja de $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Con un Boost apareces primero en las barajas durante $minutes minutos.';
  }

  @override
  String boosting(int minutes) {
    return 'Estás en Boost. Quedan $minutes minutos.';
  }

  @override
  String get boostUsed => 'Ya usaste tu Boost de hoy. Mañana se renueva.';

  @override
  String get boost => 'Boost';

  @override
  String boostBody(int minutes) {
    return 'Durante $minutes minutos apareces primero en las barajas de tus grupos en común. Una vez al día.';
  }

  @override
  String boosted(int minutes) {
    return '¡Boost activado! Estás arriba durante $minutes minutos.';
  }

  @override
  String get deckEmpty =>
      'Por ahora no queda nadie. Se llenará a medida que te unas a grupos y otros activen los matches.';

  @override
  String get deckEmptyFiltered =>
      'No queda nadie que encaje con tus filtros. Prueba a ampliarlos.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String allowanceUnlimited(int supers) {
    return 'Likes ilimitados · te quedan $supers superlikes.';
  }

  @override
  String get allowanceOut =>
      'Se acabaron tus likes de hoy; mañana se renuevan.';

  @override
  String allowance(int likes, int supers) {
    return 'Hoy te quedan $likes likes y $supers superlikes.';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get pass => 'Pasar';

  @override
  String get superLike => 'Superlike';

  @override
  String get like => 'Me gusta';

  @override
  String get introTitle => 'Conoce gente nueva de tus grupos en común';

  @override
  String get intro1 =>
      'Solo ves a personas que activaron los matches en grupos de los que eres miembro o que sigues.';

  @override
  String get intro2 =>
      'Desliza a la derecha para dar like, a la izquierda para pasar y hacia arriba para superlike.';

  @override
  String get intro3 =>
      'Si os dais like mutuamente, hacéis match. Escribes a tu match con el plan Chat de match.';

  @override
  String get intro4 =>
      'Amistad y Citas son modos distintos; elige uno o ambos.';

  @override
  String get intro5 =>
      'Tu perfil solo lo ven quienes activaron los matches. Páusalo o bórralo cuando quieras.';

  @override
  String get createMyProfile => 'Crear mi perfil de match';

  @override
  String seePackageOf(String package) {
    return 'Ver el plan $package';
  }

  @override
  String get allPackages => 'Todos los planes';

  @override
  String get packagesTitle => 'Planes de match';

  @override
  String get packagesIntro =>
      'Crear perfil y deslizar es gratis. Cada función es un plan aparte; elige solo lo que quieras.';

  @override
  String get adminAllOpen =>
      'Como administrador tienes todos los planes activos';

  @override
  String openUntil(String date) {
    return 'Activo hasta el $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Edad: $min – $max';
  }

  @override
  String get allProvinces => 'Todas las provincias';

  @override
  String get interest => 'Interés';

  @override
  String get all => 'Todos';

  @override
  String get apply => 'Aplicar';

  @override
  String get clear => 'Borrar';

  @override
  String get noAdmirers =>
      'Por ahora no hay likes pendientes. Sigue deslizando; aquí aparecerá quien te dé like.';

  @override
  String get backToSwiping => 'Volver a deslizar';

  @override
  String get likeAndMatch => 'Dar like y hacer match';

  @override
  String get noPendingLikes => 'Aún no hay likes pendientes';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas te dieron like',
      one: '1 persona te dio like',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Con el plan Quién te dio like ves quiénes son y haces match al instante.';

  @override
  String get seePackage => 'Ver el plan';
}
