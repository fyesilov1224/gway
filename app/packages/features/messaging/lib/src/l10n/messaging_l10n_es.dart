// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MessagingL10nEs extends MessagingL10n {
  MessagingL10nEs([String locale = 'es']) : super(locale);

  @override
  String get groupInvalid =>
      'Solo puedes enviar la solicitud a un grupo del que seas miembro.';

  @override
  String get permissionExists =>
      'Tu solicitud ya se recibió o tu permiso está activo.';

  @override
  String get permissionCooldown =>
      'Podrás enviar otra solicitud 7 días después de la última decisión.';

  @override
  String noteTooLong(int max) {
    return 'La nota puede tener hasta $max caracteres.';
  }

  @override
  String get requestForbidden => 'Ahora no se puede enviar la solicitud.';

  @override
  String get unsupportedImage =>
      'Este tipo de archivo no es compatible. Elige JPEG, PNG o WebP.';

  @override
  String get voiceCallHandle => 'Llamada de voz de GWAY';

  @override
  String get incomingCalls => 'Llamadas entrantes';

  @override
  String get missedCalls => 'Llamadas perdidas';

  @override
  String get answer => 'Responder';

  @override
  String get decline => 'Rechazar';

  @override
  String get noAnswer => 'Sin respuesta';

  @override
  String get missedCall => 'Llamada perdida';

  @override
  String get callDeclined => 'Llamada rechazada';

  @override
  String get youDeclined => 'Has rechazado la llamada';

  @override
  String get callNotAllowed => 'Ya no es posible llamar';

  @override
  String get callCanceled => 'Llamada cancelada';

  @override
  String get timeLimit => 'Se cumplieron los 60 minutos; la llamada terminó';

  @override
  String get endedNotAllowed => 'Llamada terminada: ya no es posible llamar';

  @override
  String get callEnded => 'Llamada terminada';

  @override
  String get messageDeleted => 'Mensaje eliminado';

  @override
  String get photo => 'Foto';

  @override
  String get tonightTable => 'La mesa de esta noche';

  @override
  String get blockRequestPending =>
      'Acepta la solicitud de mensaje antes de responder.';

  @override
  String get blockDeclined => 'Esta persona no aceptó tu solicitud de mensaje.';

  @override
  String get blockMuted =>
      'Estás silenciado en este grupo, así que ahora no puedes escribir.';

  @override
  String get blockAdminsOnly =>
      'Solo los administradores pueden escribir en este chat.';

  @override
  String get blockTableClosed =>
      'La mesa está cerrada; puedes leer pero no escribir mensajes nuevos.';

  @override
  String get blockBlocked => 'No se puede escribir aquí por un bloqueo.';

  @override
  String get blockMatchEnded => 'Este chat se cerró porque el match terminó.';

  @override
  String get blockMatchLocked =>
      'Para escribir a tu match necesitas el plan Chat de match. Leer los mensajes es gratis.';

  @override
  String get blockTeammateLocked =>
      'Para escribir a tu compañero necesitas el plan Compañero de equipo. Leer es gratis.';

  @override
  String get blockNotAllowed =>
      'Los mensajes directos ahora son solo para matches y compañeros. Puedes leer tus mensajes antiguos.';

  @override
  String get blockOther => 'Ahora no puedes escribir en este chat.';

  @override
  String get hiddenUser => 'Usuario de GWAY';

  @override
  String get voiceCalls => 'Llamadas de voz';

  @override
  String get voiceCallsHeadline => 'Habla por voz con tus matches y compañeros';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Las llamadas de voz te permiten llamar a tus matches y compañeros desde el chat privado. No están abiertas a todos: las pides a un grupo del que eres miembro y el propietario o un administrador las activa. Las llamadas no se graban ni se escuchan; duran como máximo $minutes minutos.';
  }

  @override
  String get status => 'Estado';

  @override
  String get notRequested => 'No solicitado';

  @override
  String get underReview => 'En revisión';

  @override
  String get statusOn => 'Activado';

  @override
  String get statusOff => 'Desactivado';

  @override
  String get notRequestedYet => 'Aún no lo has solicitado.';

  @override
  String requestedFrom(String group) {
    return 'Tu solicitud llegó a los administradores de $group. Te avisaremos cuando decidan.';
  }

  @override
  String get requestedFromGroup =>
      'Tu solicitud llegó a los administradores del grupo. Te avisaremos cuando decidan.';

  @override
  String activeFrom(String group) {
    return 'Tus llamadas de voz están activadas ($group). Llama a tus matches y compañeros con el icono de teléfono arriba del chat; ellos también necesitan permiso.';
  }

  @override
  String get active =>
      'Tus llamadas de voz están activadas. Llama a tus matches y compañeros con el icono de teléfono arriba del chat; ellos también necesitan permiso.';

  @override
  String get declined => 'Por ahora tu solicitud no se ha aprobado.';

  @override
  String get revokedLeftGroup =>
      'Tus llamadas de voz se desactivaron porque dejaste el grupo que las concedió. Puedes volver a pedirlas en otro grupo.';

  @override
  String get revoked => 'Tus llamadas de voz se han desactivado.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Tu nota: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Podrás volver a pedirlo después del $date.';
  }

  @override
  String get requestSent => 'Tu solicitud se ha enviado.';

  @override
  String get joinGroupFirst =>
      'Los propietarios y administradores de grupos activan las llamadas. Únete primero a un grupo para pedirlas.';

  @override
  String get requestToGroup => 'Grupo al que enviar la solicitud';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get noteHint =>
      'Puedes explicar brevemente por qué quieres las llamadas.';

  @override
  String get request => 'Solicitar';

  @override
  String get lockScreenCalls => 'Llamadas en la pantalla de bloqueo';

  @override
  String get lockScreenHint =>
      'Permite que GWAY suene a pantalla completa con el teléfono bloqueado.';

  @override
  String get allow => 'Permitir';

  @override
  String get callInfoFailed =>
      'No se pudo cargar la llamada. Revisa tu conexión.';

  @override
  String get tapEndToHangUp => 'Toca Colgar para terminar.';

  @override
  String get callNotFound => 'No se encontró la llamada.';

  @override
  String get close => 'Cerrar';

  @override
  String callLimitNote(int minutes) {
    return 'Una llamada dura como máximo $minutes minutos y no se graba.';
  }

  @override
  String get audioFailed =>
      'No se pudo conectar el audio. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get incoming => 'te está llamando…';

  @override
  String get calling => 'Llamando…';

  @override
  String get connecting => 'Conectando…';

  @override
  String get answerCall => 'Responder';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Activar sonido';

  @override
  String get end => 'Colgar';

  @override
  String get speaker => 'Altavoz';

  @override
  String get peerUnencrypted =>
      'La app de la otra persona está desactualizada; su audio no está cifrado y no se reproduce. Pídele que la actualice.';

  @override
  String get encrypting => 'Estableciendo una conexión cifrada…';

  @override
  String e2eeCode(String code) {
    return 'Cifrado de extremo a extremo. Código de seguridad $code';
  }

  @override
  String get e2ee => 'Cifrado de extremo a extremo';

  @override
  String get codeMatchHint =>
      'Si este código coincide con el de la otra pantalla, nadie puede escuchar.';

  @override
  String get micFailed =>
      'No se pudo encender el micrófono. Revisa el permiso del micrófono.';

  @override
  String get chatNotFound => 'No se encontró el chat o ya no puedes verlo.';

  @override
  String get backToMessages => 'Volver a mensajes';

  @override
  String get cantCallNow => 'Ahora no se puede llamar.';

  @override
  String get voiceCall => 'Llamada de voz';

  @override
  String get groupChatAdminsOnly =>
      'Chat de grupo · solo escriben los administradores';

  @override
  String get groupChat => 'Chat de grupo';

  @override
  String smallTableMembers(int count) {
    return 'Mesa pequeña · $count personas';
  }

  @override
  String get adminsOnlyOn =>
      'Ahora solo el propietario y los administradores pueden escribir aquí.';

  @override
  String get adminsOnlyOff =>
      'Ahora todos los miembros del grupo pueden escribir aquí.';

  @override
  String get chatSettings => 'Ajustes del chat';

  @override
  String get adminsOnlyToggle => 'Solo escriben los administradores';

  @override
  String get sendingPhoto => '📷 Enviando foto…';

  @override
  String get requestPendingNote =>
      'Tu solicitud de mensaje se ha enviado. Hasta que la acepten no verás si se ha leído.';

  @override
  String get groupChatEmpty =>
      'Aún no hay mensajes en el chat del grupo. Escribe el primero.';

  @override
  String get chatEmpty => 'Aún no hay mensajes. Escribe el primero.';

  @override
  String get startWriting => 'Empezar a escribir';

  @override
  String get sending => 'Enviando…';

  @override
  String get seen => 'Visto';

  @override
  String get sent => 'Enviado';

  @override
  String get seePackage => 'Ver el plan';

  @override
  String get today => 'Hoy';

  @override
  String get messageRemoved => 'Este mensaje se ha retirado.';

  @override
  String get thisMessageDeleted => 'Este mensaje se ha eliminado.';

  @override
  String get messageOptions => 'Opciones del mensaje';

  @override
  String profileOf(String name) {
    return 'Perfil de $name';
  }

  @override
  String get you => 'Tú';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Mensaje copiado.';

  @override
  String get deleteForAll => 'Eliminar para todos';

  @override
  String get report => 'Denunciar';

  @override
  String get deleteForAllTitle => '¿Eliminar el mensaje para todos?';

  @override
  String get deleteForAllBody =>
      'Todos verán «Este mensaje se ha eliminado». No se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get requestDeleted => 'Solicitud de mensaje eliminada.';

  @override
  String wantsToMessage(String name) {
    return '$name quiere escribirte. Si aceptas, podréis chatear y verá cuándo has leído.';
  }

  @override
  String get accept => 'Aceptar';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get writeMessage => 'Escribe un mensaje';

  @override
  String get send => 'Enviar';

  @override
  String get messages => 'Mensajes';

  @override
  String get chats => 'Chats';

  @override
  String get requests => 'Solicitudes';

  @override
  String requestsCount(int count) {
    return 'Solicitudes ($count)';
  }

  @override
  String get noChats =>
      'Aún no tienes chats. Puedes escribir a tus matches y compañeros.';

  @override
  String get findPeople => 'Buscar personas';

  @override
  String get oldRequestsNote =>
      'Las solicitudes antiguas se quedan aquí. Los mensajes directos ahora son solo para matches y compañeros; no llegan solicitudes nuevas.';

  @override
  String get noRequests => 'No hay solicitudes de mensaje pendientes.';

  @override
  String get backToChats => 'Volver a los chats';

  @override
  String get callRequests => 'Solicitudes de llamadas de voz';

  @override
  String noPendingWithActive(int count) {
    return 'Sin solicitudes pendientes · $count activas';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes pendientes',
      one: '1 solicitud pendiente',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'Pendientes';

  @override
  String get activeTab => 'Activas';

  @override
  String get requestsOwnersOnly =>
      'Solo el propietario y los administradores ven las solicitudes.';

  @override
  String get goBack => 'Volver';

  @override
  String noPendingFor(String group) {
    return 'No hay solicitudes. Las de los miembros de $group aparecerán aquí.';
  }

  @override
  String get noActive => 'Este grupo no ha concedido llamadas de voz.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get grantHint =>
      'Con el permiso que concedes, la persona puede llamar a todos sus matches y compañeros. No se graban; si deja el grupo, el permiso termina.';

  @override
  String get granted => 'Llamadas de voz activadas.';

  @override
  String get turnedOff => 'Llamadas de voz desactivadas.';

  @override
  String theirNote(String note) {
    return 'Nota: $note';
  }

  @override
  String get turnOff => 'Desactivar';

  @override
  String get turnOn => 'Activar';

  @override
  String get rankOnlyGrant =>
      'Su rango es igual o superior al tuyo; solo puedes aprobar esta solicitud.';

  @override
  String get rankCannotRevoke =>
      'Su rango es igual o superior al tuyo; no puedes desactivarlo.';

  @override
  String get declineRequest => 'Rechazar solicitud';

  @override
  String get turnOffCalls => 'Desactivar llamadas de voz';

  @override
  String get declineHint =>
      'Verá el motivo y podrá volver a pedirlo en 7 días.';

  @override
  String get revokeHint =>
      'Una llamada en curso termina al instante. Verá el motivo y podrá volver a pedirlo en 7 días.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonMin3 => 'El motivo debe tener al menos 3 caracteres.';

  @override
  String get yesterday => 'Ayer';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get groupChatMembersOnly => 'Solo los miembros del grupo ven el chat.';

  @override
  String get callVerifying => 'Verificando el cifrado…';

  @override
  String get callSecure => 'Llamada segura';

  @override
  String get callSecureDetail =>
      'Cifrado de extremo a extremo. Los códigos de seguridad de ambos teléfonos coinciden; nadie se ha interpuesto.';

  @override
  String get callCheckFailed =>
      'No se pudo verificar el cifrado: los códigos de seguridad no coinciden. Cuelga y vuelve a llamar.';

  @override
  String get showSecurityCode => 'Mostrar código de seguridad';
}
