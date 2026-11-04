// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class GroupsL10nEs extends GroupsL10n {
  GroupsL10nEs([String locale = 'es']) : super(locale);

  @override
  String get unsupportedImage =>
      'Este tipo de archivo no es compatible. Elige JPEG, PNG o WebP.';

  @override
  String get joinOpen => 'Abierto a todos';

  @override
  String get joinOpenHint => 'Cualquiera puede unirse directamente.';

  @override
  String get joinRequest => 'Unirse con solicitud';

  @override
  String get joinRequestHint => 'Los administradores aprueban las solicitudes.';

  @override
  String get joinInvite => 'Solo con invitación';

  @override
  String get joinInviteHint => 'Solo pueden unirse las personas invitadas.';

  @override
  String get roleOwner => 'Propietario del grupo';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleDiscipline => 'Comité disciplinario';

  @override
  String get roleModerator => 'Moderador';

  @override
  String get roleMember => 'Miembro';

  @override
  String get handleMin =>
      'La dirección del grupo debe tener al menos 3 caracteres.';

  @override
  String get handleChars =>
      'Usa solo minúsculas, números, guiones bajos y puntos.';

  @override
  String get handleDots =>
      'No puede empezar ni terminar con un punto ni tener dos seguidos.';

  @override
  String get nameMin => 'El nombre del grupo debe tener al menos 3 caracteres.';

  @override
  String nameMax(int max) {
    return 'El nombre del grupo puede tener como máximo $max caracteres.';
  }

  @override
  String get httpsOnly => 'Introduce una dirección que empiece por https://.';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get groupInfo => 'Datos del grupo';

  @override
  String get groupInfoHint =>
      'Podrás añadir logotipo, portada, normas y enlaces después de crear el grupo.';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get about => 'Descripción';

  @override
  String get aboutHint => '¿Qué hace vuestro grupo y quién puede unirse?';

  @override
  String get joining => 'Acceso';

  @override
  String get changeLater => 'Podrás cambiarlo más tarde.';

  @override
  String get createTheGroup => 'Crear el grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get noEditPermission => 'No tienes permiso para editar este grupo.';

  @override
  String get backToGroup => 'Volver al grupo';

  @override
  String get save => 'Guardar';

  @override
  String get logoAndCover => 'Logotipo y portada';

  @override
  String get imageHint => 'JPEG, PNG o WebP · hasta 5 MB';

  @override
  String get logo => 'Logotipo';

  @override
  String get cover => 'Portada';

  @override
  String groupHandle(String handle) {
    return 'Dirección del grupo: @$handle';
  }

  @override
  String get rules => 'Normas';

  @override
  String get rulesHint =>
      'Lo que esperas de los miembros, una norma por línea.';

  @override
  String get links => 'Enlaces';

  @override
  String linksHint(int max) {
    return 'Sitio web y redes sociales. Hasta $max.';
  }

  @override
  String get enterLabel => 'Introduce una etiqueta.';

  @override
  String get label => 'Etiqueta';

  @override
  String get address => 'Dirección';

  @override
  String get removeLink => 'Quitar enlace';

  @override
  String get addLink => 'Añadir enlace';

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get deleteGroup => 'Eliminar grupo';

  @override
  String get deleteGroupBody =>
      'El grupo, las membresías, roles, solicitudes e invitaciones se eliminan definitivamente. El tiempo restante del plan no se reembolsa.';

  @override
  String deleteGroupNamed(String name) {
    return 'Eliminar $name';
  }

  @override
  String changeImage(String label) {
    return 'Cambiar $label';
  }

  @override
  String addImage(String label) {
    return 'Añadir $label';
  }

  @override
  String get remove => 'Quitar';

  @override
  String get deleteForever => 'Eliminar el grupo definitivamente';

  @override
  String deleteConfirm(String handle) {
    return 'No se puede deshacer. Para confirmar, escribe la dirección del grupo: $handle';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get group => 'Grupo';

  @override
  String get share => 'Compartir';

  @override
  String shareText(String name) {
    return 'Echa un vistazo a $name en GWAY:';
  }

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get leaveGroup => 'Salir del grupo';

  @override
  String get groupNotFound => 'Este grupo no existe o ya no está visible.';

  @override
  String get backToGroups => 'Volver a grupos';

  @override
  String leaveConfirm(String name) {
    return '¿Salir de $name? Si tienes un rol en el grupo, también se quitará.';
  }

  @override
  String get leave => 'Salir';

  @override
  String leftGroup(String name) {
    return 'Has salido de $name.';
  }

  @override
  String get suspendedNotice =>
      'El equipo de la plataforma ha suspendido este grupo. Mientras dure, solo lo ven sus miembros.';

  @override
  String founded(String date) {
    return 'Creado en $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes esperan aprobación.',
      one: '1 solicitud espera aprobación.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Revisar';

  @override
  String get requestSent => 'Tu solicitud se ha enviado.';

  @override
  String get youAreMember => 'Eres miembro';

  @override
  String get join => 'Unirse';

  @override
  String joined(String name) {
    return 'Te has unido a $name.';
  }

  @override
  String get sendJoinRequest => 'Solicitar unirse';

  @override
  String get requestSentShort => 'Solicitado';

  @override
  String get withdrawRequest => 'Retirar solicitud';

  @override
  String get withdrawConfirm => '¿Retirar tu solicitud?';

  @override
  String get undo => 'Retirar';

  @override
  String get requestWithdrawn => 'Tu solicitud se ha retirado.';

  @override
  String get decline => 'Rechazar';

  @override
  String get inviteDeclined => 'Invitación rechazada.';

  @override
  String get acceptInvite => 'Aceptar invitación';

  @override
  String followOn(String name) {
    return 'Las publicaciones de $name aparecerán en tu muro.';
  }

  @override
  String get followOff => 'Has dejado de seguir el grupo.';

  @override
  String get following => 'Siguiendo';

  @override
  String get follow => 'Seguir';

  @override
  String get managementTeam => 'Equipo de gestión';

  @override
  String allMembers(int count) {
    return 'Todos los miembros ($count)';
  }

  @override
  String get groups => 'Grupos';

  @override
  String get discover => 'Descubrir';

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get plans => 'Planes';

  @override
  String get searchHint => 'Buscar por nombre o dirección del grupo';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get all => 'Todos';

  @override
  String get noMatch => 'Ningún grupo coincide con tu búsqueda.';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get noGroupsYet => 'Aún no hay grupos. Crea el primero.';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get notJoinedYet => 'Aún no te has unido a ningún grupo.';

  @override
  String get discoverGroups => 'Descubrir grupos';

  @override
  String get plansHint =>
      'Los planes los compran los propietarios. Crea tu grupo y elige un plan.';

  @override
  String get yourInvitations => 'Tus invitaciones';

  @override
  String get invitationsHint => 'Estos grupos te han invitado a unirte.';

  @override
  String invitedBy(String name) {
    return 'Invitación de $name';
  }

  @override
  String get linkCopied => 'Enlace copiado.';

  @override
  String inviteShareText(String name) {
    return 'Únete a $name en GWAY:';
  }

  @override
  String get revokeLinkTitle => '¿Revocar el enlace?';

  @override
  String get revokeLinkBody =>
      'Nadie más podrá unirse con este enlace. Quienes ya se unieron siguen siendo miembros.';

  @override
  String get revoke => 'Revocar';

  @override
  String get inviteLink => 'Enlace de invitación';

  @override
  String get inviteLinkHint =>
      'Compártelo en WhatsApp o Instagram. Quien abra el enlace se une directamente, sea cual sea el tipo de acceso.';

  @override
  String get createLink => 'Crear enlace';

  @override
  String validUntil(String date) {
    return 'Hasta el $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas se han unido',
      one: '1 persona se ha unido',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max unidos';
  }

  @override
  String get newInviteLink => 'Nuevo enlace de invitación';

  @override
  String get validity => 'Validez';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get howMany => '¿Cuántas personas pueden unirse?';

  @override
  String get unlimited => 'Sin límite';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Crear y compartir';

  @override
  String get invitation => 'Invitación';

  @override
  String get linkInvalid =>
      'Este enlace de invitación ya no es válido. Puedes pedir uno nuevo al administrador del grupo.';

  @override
  String get seeGroup => 'Ver grupo';

  @override
  String get invitedToGroup => 'Te han invitado a este grupo.';

  @override
  String get joinGroup => 'Unirse al grupo';

  @override
  String get members => 'Miembros';

  @override
  String get requests => 'Solicitudes';

  @override
  String get invitations => 'Invitaciones';

  @override
  String get roles => 'Roles';

  @override
  String get openCase => 'Abrir expediente disciplinario';

  @override
  String get report => 'Denunciar';

  @override
  String membersVisibility(int shown, int total) {
    return 'Solo los miembros ven la lista completa. Aquí: el equipo de gestión y $shown personas que muestran sus grupos; el grupo tiene $total miembros en total.';
  }

  @override
  String optionsFor(String name) {
    return 'Opciones para $name';
  }

  @override
  String get transferOwnership => 'Transferir la propiedad';

  @override
  String transferBody(String group, String person) {
    return 'La propiedad de $group pasará a $person. Seguirás como miembro y no podrás deshacerlo.';
  }

  @override
  String get transfer => 'Transferir';

  @override
  String transferred(String name) {
    return 'Propiedad transferida a $name.';
  }

  @override
  String get hintAdmin =>
      'Edita el grupo y gestiona solicitudes e invitaciones.';

  @override
  String get hintDiscipline =>
      'Revisa los expedientes de denuncia y decide las sanciones.';

  @override
  String get hintModerator => 'Revisa contenidos y comentarios.';

  @override
  String personJoined(String name) {
    return '$name se ha unido al grupo.';
  }

  @override
  String get requestDeclined => 'Solicitud rechazada.';

  @override
  String get noPendingRequests => 'No hay solicitudes pendientes.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get approve => 'Aprobar';

  @override
  String get inviteSent => 'Invitación enviada.';

  @override
  String get inviteByUsername => 'Invitar por nombre de usuario';

  @override
  String get invite => 'Invitar';

  @override
  String get noPendingInvites => 'No hay invitaciones pendientes.';

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
  String get suspended => 'Suspendido';

  @override
  String get groupsSection => 'Grupos';

  @override
  String get groupsOwnHint =>
      'Solo los miembros del mismo grupo ven tus grupos. Puedes hacerlos públicos en Ajustes.';

  @override
  String get groupsOtherHint =>
      'Solo se muestran los grupos en común y los que ayuda a gestionar.';

  @override
  String get noGroupsToShow => 'No hay grupos que mostrar.';

  @override
  String get handleTaken => 'Esta dirección ya está en uso. Prueba otra.';

  @override
  String get groupAddress => 'Dirección del grupo';

  @override
  String get groupAddressHint =>
      'La dirección de la página del grupo. No se podrá cambiar.';

  @override
  String get available => 'Disponible';

  @override
  String get taken => 'En uso';

  @override
  String get notSpecified => 'Sin especificar';

  @override
  String get provinceOptional => 'Provincia (opcional)';

  @override
  String get provinceHint => 'El grupo aparece en esta provincia en el mapa.';

  @override
  String get chooseCategory => 'Elige una categoría.';

  @override
  String get category => 'Categoría';
}
