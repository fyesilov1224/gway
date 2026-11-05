// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LiveL10nEs extends LiveL10n {
  LiveL10nEs([String locale = 'es']) : super(locale);

  @override
  String get commentRate =>
      'Has comentado mucho en poco tiempo. Espera un poco e inténtalo de nuevo.';

  @override
  String get mutedListenOnly =>
      'Estás silenciado en este grupo, así que solo puedes escuchar.';

  @override
  String get cannotComment => 'Ahora no puedes comentar en este directo.';

  @override
  String get roleHost => 'Anfitrión';

  @override
  String get roleSpeaker => 'Ponente';

  @override
  String get roleListener => 'Oyente';

  @override
  String get startLive => 'Iniciar directo';

  @override
  String hostedBy(String name) {
    return 'Presenta $name';
  }

  @override
  String get join => 'Unirme';

  @override
  String upcomingAt(String date) {
    return 'Próximo · $date';
  }

  @override
  String get scheduledCanceled => 'Directo programado cancelado.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get start => 'Iniciar';

  @override
  String get reminderRemoved => 'Recordatorio eliminado.';

  @override
  String get reminderSet => 'Te avisaremos cuando empiece.';

  @override
  String get reminding => 'Recordatorio activado';

  @override
  String get remind => 'Recordarme';

  @override
  String get schedule5min =>
      'Un directo programado debe ser al menos dentro de 5 minutos.';

  @override
  String get scheduled =>
      'Directo programado. Los miembros pueden pedir un recordatorio.';

  @override
  String get liveBroadcast => 'Directo';

  @override
  String get liveIntro =>
      'Los miembros entran en la sala de audio; hablan quienes subas al escenario.';

  @override
  String get title => 'Título';

  @override
  String get titleExample => 'Ej.: Planificar la ruta del domingo';

  @override
  String get titleMin3 => 'El título debe tener al menos 3 caracteres.';

  @override
  String get now => 'Ahora';

  @override
  String get scheduleIt => 'Programar';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te quedan $count minutos de directo este mes.',
      one: 'Te queda 1 minuto de directo este mes.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'Se ha agotado el tiempo de directo de este mes. Mejora tu plan para tener más.';

  @override
  String get startTheLive => 'Iniciar el directo';

  @override
  String get liveNow => 'En directo';

  @override
  String trayLabel(String group, String title) {
    return '$group está en directo: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Estás en un directo: $title. Toca para volver.';
  }

  @override
  String get connecting => 'Conectando con el directo…';

  @override
  String get inBroadcast => 'Estás en directo · toca para volver';

  @override
  String get micMutedByMod => 'Un responsable ha apagado tu micrófono';

  @override
  String get micOff => 'Apagar micrófono';

  @override
  String get micOn => 'Encender micrófono';

  @override
  String startsOn(String date) {
    return 'Este directo empieza el $date.';
  }

  @override
  String get ended => 'Este directo ha terminado.';

  @override
  String get notFound =>
      'No se encontró el directo. Puede que tengas que ser miembro del grupo.';

  @override
  String get goBack => 'Volver';

  @override
  String get onStageNow =>
      'Estás en el escenario. Enciende el micrófono para hablar.';

  @override
  String get nowListener => 'Ahora eres oyente.';

  @override
  String get leaveBroadcast => 'Salir del directo';

  @override
  String get leaveHostBody =>
      'Puedes terminarlo para todos. Si solo sales, termina solo a los 2 minutos.';

  @override
  String get justLeave => 'Solo salir';

  @override
  String get endBroadcast => 'Terminar el directo';

  @override
  String get inviteToStage => 'Subir al escenario';

  @override
  String get removeFromStage => 'Bajar del escenario';

  @override
  String get muteMic => 'Apagar su micrófono';

  @override
  String get unmuteMic => 'Encender su micrófono';

  @override
  String get kick => 'Expulsar del directo';

  @override
  String kickBody(String name) {
    return '$name no podrá volver a entrar en este directo.';
  }

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get remove => 'Expulsar';

  @override
  String get raisedHands => 'Manos levantadas';

  @override
  String get commentDeleted => 'Comentario eliminado.';

  @override
  String get thanksForJoining =>
      'El directo ha terminado. Gracias por participar.';

  @override
  String get youWereKicked => 'Te han expulsado de este directo.';

  @override
  String get connectFailedShort => 'No se pudo conectar con el directo.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count manos levantadas',
      one: '1 mano levantada',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'En el escenario';

  @override
  String listeners(int count) {
    return 'Oyentes · $count';
  }

  @override
  String get noListeners => 'Aún no hay oyentes.';

  @override
  String get minimize => 'Minimizar y seguir en el directo';

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
  String get broadcastOptions => 'Opciones del directo';

  @override
  String get endForAll => 'Terminar para todos';

  @override
  String get handRaised =>
      'Has levantado la mano. El anfitrión puede subirte al escenario.';

  @override
  String get you => 'Tú';

  @override
  String get speaking => 'hablando';

  @override
  String get micOffState => 'micrófono apagado';

  @override
  String get handUp => 'mano levantada';

  @override
  String get sendReaction => 'Enviar reacción';

  @override
  String get leave => 'Salir';

  @override
  String get leaveStage => 'Bajar del escenario';

  @override
  String get reactions => 'Reacciones';

  @override
  String get comments => 'Comentarios';

  @override
  String get raiseHand => 'Levantar la mano';

  @override
  String get lowerHand => 'Bajar la mano';

  @override
  String get report => 'Denunciar';

  @override
  String get deleteComment => 'Eliminar comentario';

  @override
  String get firstComment => 'Sé el primero en comentar.';

  @override
  String get writeComment => 'Escribe un comentario…';

  @override
  String get send => 'Enviar';

  @override
  String get connectFailed =>
      'No se pudo conectar con el directo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get participant => 'Participante';

  @override
  String get micNeedsManager =>
      'Solo un responsable del directo puede encender tu micrófono.';

  @override
  String get micFailed =>
      'No se pudo encender el micrófono. Revisa el permiso del micrófono.';

  @override
  String get connectionLost =>
      'Se perdió la conexión con la emisión. Toca para volver a conectar.';

  @override
  String get micAfterEncryption =>
      'Estableciendo la conexión cifrada; tu micrófono se activará en un momento.';

  @override
  String get encrypting => 'Estableciendo la conexión cifrada…';

  @override
  String get verifying => 'Verificando el cifrado…';

  @override
  String get liveSecure => 'Emisión segura';

  @override
  String get liveSecureDetail =>
      'Cifrado de extremo a extremo. Todos en la sala usan la misma clave; nadie, ni siquiera el servidor, puede escuchar.';

  @override
  String get liveCheckFailed =>
      'No se pudo verificar el cifrado: no todos en la sala usan la misma clave. Sal de la emisión y vuelve a entrar.';

  @override
  String get liveUnconfirmed =>
      'Alguien en el escenario usa una versión antigua de la app; su audio no puede cifrarse y no se reproduce.';

  @override
  String get peerUnencrypted =>
      'Un orador con una versión antigua envía audio sin cifrar y no se reproduce. Debe actualizar la app.';

  @override
  String get e2ee => 'Cifrado de extremo a extremo';

  @override
  String get showSecurityCode => 'Mostrar código de seguridad';

  @override
  String get codeMatchHint =>
      'Este código es el mismo en la pantalla de todos en la sala.';

  @override
  String e2eeCode(String code) {
    return 'Cifrado de extremo a extremo. Código de seguridad $code';
  }

  @override
  String get liveOngoingTitle => 'Estás en una emisión en directo';

  @override
  String get liveOngoingText =>
      'Cifrado de extremo a extremo. Toca para volver.';
}
