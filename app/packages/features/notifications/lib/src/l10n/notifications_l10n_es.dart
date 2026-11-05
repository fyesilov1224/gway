// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class NotificationsL10nEs extends NotificationsL10n {
  NotificationsL10nEs([String locale = 'es']) : super(locale);

  @override
  String get actLike => 'le ha gustado tu publicación.';

  @override
  String actComment(String text) {
    return 'ha comentado: $text';
  }

  @override
  String actReply(String text) {
    return 'ha respondido a tu comentario: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'le ha gustado tu comentario: $text';
  }

  @override
  String get actMentionPost => 'te ha mencionado en una publicación.';

  @override
  String actMentionComment(String text) {
    return 'te ha mencionado en un comentario: $text';
  }

  @override
  String get actFollow => 'ha empezado a seguirte.';

  @override
  String get actFollowRequest => 'quiere seguirte.';

  @override
  String get actFollowAccepted => 'ha aceptado tu solicitud de seguimiento.';

  @override
  String actLiveScheduled(String title) {
    return 'ha programado un directo: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'ha programado un directo para el $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'está en directo: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Se ha liberado una plaza en «$title»: ya vas.';
  }

  @override
  String actEventUpdated(String title) {
    return 'ha cambiado la hora o el lugar de «$title».';
  }

  @override
  String actEventCanceled(String title) {
    return 'ha cancelado «$title».';
  }

  @override
  String actReminderTomorrow(String title) {
    return '«$title» empieza mañana. ¿Vienes? Confírmalo.';
  }

  @override
  String actReminderHour(String title) {
    return '«$title» empieza en menos de una hora.';
  }

  @override
  String actCaseVote(String group) {
    return 'ha abierto un expediente disciplinario en $group; se necesita tu voto.';
  }

  @override
  String get actMuted => 'te ha silenciado. Toca para ver detalles o apelar.';

  @override
  String get actKicked =>
      'te ha expulsado del grupo. Toca para ver detalles o apelar.';

  @override
  String get actBanned =>
      'te ha bloqueado en el grupo. Toca para ver detalles o apelar.';

  @override
  String get actWarned =>
      'te ha dado un aviso. Toca para ver detalles o apelar.';

  @override
  String actAppealSubmitted(String group) {
    return 'ha apelado una sanción en $group.';
  }

  @override
  String get actAppealDecided => 'ha resuelto tu apelación.';

  @override
  String actEventApproved(String title) {
    return 'ha aprobado tu solicitud para «$title».';
  }

  @override
  String actEventDeclined(String title) {
    return 'no ha podido aceptar tu solicitud para «$title».';
  }

  @override
  String actEventReview(String title) {
    return '¿Qué tal fue «$title»? Valóralo y comparte recuerdos.';
  }

  @override
  String actGoalCompleted(String title) {
    return '¡Has completado «$title»! Tu insignia está en tu perfil.';
  }

  @override
  String get actTeammateRequest => 'quiere ser tu compañero de equipo.';

  @override
  String get actTeammateAccepted => 'ha aceptado tu solicitud de equipo.';

  @override
  String get actMatchCreated => 'Mira quién es en Mis matches.';

  @override
  String get actSuperLiked =>
      'te ha dado un superlike. Aparece primero en tu baraja.';

  @override
  String actWelcomeRequested(String title) {
    return 'va por primera vez a «$title» y quiere que lo reciban.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'te recibirá en «$title». Mira la nota de encuentro.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'ya no podrá recibirte en «$title»; buscamos a otra persona.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'ha retirado su solicitud de recibimiento para «$title».';
  }

  @override
  String get actLeagueResult =>
      '¡quedó entre los tres primeros de la liga el mes pasado! Mira la clasificación en la página del grupo.';

  @override
  String actWelcomeThanked(String title) {
    return 'te ha dado las gracias por recibirlo en «$title».';
  }

  @override
  String get actTableInvite =>
      'ha montado una mesa pequeña esta noche y te invita.';

  @override
  String get actTableReady =>
      'se ha unido a la mesa; ya está lista. Acordad lugar y hora en el chat.';

  @override
  String actVenueRevealed(String title) {
    return '«$title»: toca para ver adónde ir.';
  }

  @override
  String actHandshake(String title) {
    return 'te ha dado la mano en «$title».';
  }

  @override
  String get actCallMissed => 'te ha llamado; no contestaste.';

  @override
  String get actCallGranted =>
      '— ya tienes permiso. Puedes llamar a tus matches desde el chat.';

  @override
  String get actCallDeclined =>
      '— por ahora tu solicitud no se ha aprobado. Toca para ver detalles.';

  @override
  String get actCallRevoked =>
      '— se ha retirado tu permiso. Toca para ver detalles.';

  @override
  String actSeriesLimit(String title) {
    return '— no se pudo abrir la siguiente fecha de «$title»: el grupo alcanzó su límite mensual. Se abrirá al empezar el mes o al mejorar el plan.';
  }

  @override
  String get leadNewMatch => '¡Tienes un nuevo match!';

  @override
  String get leadSeries => 'Evento periódico';

  @override
  String get leadVenue => 'Lugar sorpresa revelado';

  @override
  String get leadCalls => 'Llamadas de voz';

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodWeek => 'Esta semana';

  @override
  String get periodEarlier => 'Antes';

  @override
  String get agoNow => 'ahora';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n h';
  }

  @override
  String agoDays(int n) {
    return '$n d';
  }

  @override
  String get join => 'Unirme';

  @override
  String get see => 'Ver';

  @override
  String get prefsTitle => 'Preferencias de notificaciones';

  @override
  String get messages => 'Mensajes';

  @override
  String get directMessages => 'Mensajes directos';

  @override
  String get directMessagesHint =>
      'Cuando llega un mensaje directo, con sonido aunque la app esté cerrada';

  @override
  String get groupMessages => 'Mensajes de grupo';

  @override
  String get groupMessagesHint =>
      'Cuando llegan mensajes a chats de grupo y a la mesa de esta noche, con sonido aunque la app esté cerrada';

  @override
  String get events => 'Eventos';

  @override
  String get remindDay => 'Recordar 1 día antes';

  @override
  String get remindDayHint => 'Si un evento al que vas empieza mañana';

  @override
  String get remindHour => 'Recordar 1 hora antes';

  @override
  String get remindHourHint =>
      'Si un evento al que vas empieza en menos de una hora';

  @override
  String get changes => 'Cambios y cancelaciones';

  @override
  String get changesHint =>
      'Cuando cambia la hora o el lugar, o se cancela un evento';

  @override
  String get reviewRequests => 'Solicitudes de valoración';

  @override
  String get reviewRequestsHint =>
      'Preguntar «¿Qué tal fue?» al terminar un evento';

  @override
  String get live => 'Directos';

  @override
  String get liveAlerts => 'Directos programados e iniciados';

  @override
  String get liveAlertsHint =>
      'Cuando tu grupo programa o inicia un directo, con aviso sonoro si la app está abierta';

  @override
  String get matching => 'Matches';

  @override
  String get newMatches => 'Nuevos matches';

  @override
  String get newMatchesHint => 'Cuando os gustáis mutuamente';

  @override
  String get alwaysSent =>
      'El resultado de tus solicitudes, subir desde la lista de espera y las sanciones del grupo te afectan directamente, así que siempre se notifican.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get empty =>
      'Aquí aparecen los me gusta, comentarios y nuevos seguidores.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get followRequests => 'Solicitudes de seguimiento';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count más',
      one: '1 persona más',
    );
    return '$name y $_temp0';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get actChessChallenge => 'te invitó a jugar al ajedrez.';

  @override
  String actChessTeamInvite(String group) {
    return 'invitó a tu grupo a un encuentro de ajedrez por equipos en nombre de $group.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return 'aceptó el encuentro por equipos en nombre de $group. Elige tu alineación.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return 'rechazó el encuentro por equipos en nombre de $group.';
  }

  @override
  String actChessTeamStart(String group) {
    return '¡Empezó el encuentro por equipos contra $group! Ve a tu tablero.';
  }

  @override
  String get leadTeamMatch => 'Encuentro por equipos';
}
