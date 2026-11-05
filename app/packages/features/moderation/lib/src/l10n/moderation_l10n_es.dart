// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class ModerationL10nEs extends ModerationL10n {
  ModerationL10nEs([String locale = 'es']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Hoy has enviado demasiadas denuncias. Inténtalo mañana.';

  @override
  String get ruleTargetInvalid =>
      'Este contenido ya no existe o no puedes verlo.';

  @override
  String get ruleSelf => 'No puedes denunciarte a ti mismo ni a tu contenido.';

  @override
  String get ruleAppealNotAllowed => 'Ya no se puede apelar esta sanción.';

  @override
  String get ruleDuplicate => 'Ya lo denunciaste; se está revisando.';

  @override
  String get deletedAccount => 'Cuenta eliminada';

  @override
  String get reasonSpam => 'Spam o engañoso';

  @override
  String get reasonHarassment => 'Acoso o intimidación';

  @override
  String get reasonHate => 'Discurso de odio';

  @override
  String get reasonViolence => 'Violencia o amenazas';

  @override
  String get reasonSexual => 'Contenido sexual';

  @override
  String get reasonMisinformation => 'Información falsa';

  @override
  String get reasonOther => 'Otro';

  @override
  String get sanctionWarning => 'Advertencia';

  @override
  String get sanctionMute => 'Silencio';

  @override
  String get sanctionKick => 'Expulsión del grupo';

  @override
  String get sanctionBan => 'Bloqueo';

  @override
  String get illegalViolence => 'Violencia';

  @override
  String get illegalThreat => 'Amenaza';

  @override
  String get illegalInsult => 'Injuria';

  @override
  String get illegalHate => 'Discurso de odio';

  @override
  String get illegalSexual => 'Abuso sexual';

  @override
  String get illegalFraud => 'Fraude';

  @override
  String get illegalDrugs => 'Drogas';

  @override
  String get illegalTerror => 'Terrorismo';

  @override
  String get illegalOther => 'Otro delito';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Silencio de $days días',
      one: 'Silencio de 1 día',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Bloqueo de $days días',
      one: 'Bloqueo de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Bloqueo permanente';

  @override
  String get thresholdMajority => 'Mayoría simple';

  @override
  String get thresholdMajorityText => 'Más de la mitad de los votos';

  @override
  String get thresholdTwoThirds => 'Dos tercios';

  @override
  String get thresholdTwoThirdsText => 'Al menos dos tercios de los votos';

  @override
  String get thresholdUnanimous => 'Unanimidad';

  @override
  String get thresholdUnanimousText => 'Todos los votos';

  @override
  String get targetPost => 'Publicación';

  @override
  String get targetComment => 'Comentario';

  @override
  String get targetEvent => 'Evento';

  @override
  String get targetLiveComment => 'Comentario en directo';

  @override
  String get targetMessage => 'Mensaje del chat de grupo';

  @override
  String get targetMember => 'Miembro';

  @override
  String get appealPending => 'Pendiente de decisión';

  @override
  String get appealUpheld => 'Sanción mantenida';

  @override
  String get appealOverturned => 'Sanción retirada';

  @override
  String get banApplied => 'Bloqueo aplicado.';

  @override
  String get banAppliedSuspended =>
      'Bloqueo aplicado. La cuenta de la persona queda suspendida hasta que la plataforma la revise.';

  @override
  String get caseOpened => 'Caso abierto. El comité votará en 72 horas.';

  @override
  String get openCaseTitle => 'Abrir un caso disciplinario';

  @override
  String caseAboutNow(String name) {
    return 'Sobre $name. El bloqueo se aplica al instante, sin votación del comité.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Sobre $name. El comité disciplinario vota tu propuesta en 72 horas.';
  }

  @override
  String get proposedSanction => 'Sanción propuesta';

  @override
  String get duration => 'Duración';

  @override
  String get permanent => 'Permanente';

  @override
  String get permanentLower => 'permanente';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Aplicar ya, sin votación';

  @override
  String get applyNowHint =>
      'Bloquea sin esperar al comité. La persona puede apelar en 7 días.';

  @override
  String get illegalActivity => 'Actividad ilegal';

  @override
  String get illegalHintNow =>
      'Al aplicar el bloqueo, el caso pasa al equipo de la plataforma y la cuenta queda suspendida hasta la revisión. Esta marca no se puede cambiar después.';

  @override
  String get illegalHintVote =>
      'Si el comité lo aprueba, el caso pasa al equipo de la plataforma y la cuenta queda suspendida hasta la revisión. Esta marca no se puede cambiar después.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonHintNow =>
      '¿Qué pasó? La persona y quien revise la apelación verán este texto.';

  @override
  String get reasonHintVote => '¿Qué pasó? El comité votará según este texto.';

  @override
  String get reasonMin10 => 'El motivo debe tener al menos 10 caracteres.';

  @override
  String get muteNow => 'Silenciar ya (24 horas)';

  @override
  String get muteNowHint =>
      'Hasta que decida el comité, no puede comentar ni hablar en directo.';

  @override
  String get ban => 'Bloquear';

  @override
  String get openCase => 'Abrir caso';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'unos minutos';

  @override
  String minChars(int min) {
    return 'Escribe al menos $min caracteres.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get threshold => 'Umbral de decisión del comité';

  @override
  String thresholdChanged(String threshold) {
    return 'El umbral ahora es «$threshold». Se aplica a los casos nuevos.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderación · $group';
  }

  @override
  String get reports => 'Denuncias';

  @override
  String reportsCount(int count) {
    return 'Denuncias ($count)';
  }

  @override
  String get cases => 'Casos';

  @override
  String casesCount(int count) {
    return 'Casos ($count)';
  }

  @override
  String get sanctions => 'Sanciones';

  @override
  String sanctionsCount(int count) {
    return 'Sanciones ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Solo el propietario y el equipo de moderación ven la moderación de este grupo.';

  @override
  String get goBack => 'Volver';

  @override
  String get noReports =>
      'No hay denuncias abiertas. Aquí se reúnen las de los miembros.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get removeContent => 'Retirar contenido';

  @override
  String get remove => 'Retirar';

  @override
  String get contentRemoved => 'Contenido retirado.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denuncias',
      one: '1 denuncia',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Ver';

  @override
  String get reportDismissed => 'Denuncia rechazada.';

  @override
  String get dismiss => 'Rechazar';

  @override
  String get openCaseShort => 'Abrir caso';

  @override
  String get rankOnlyDismiss =>
      'El rango de esta persona no es inferior al tuyo; solo puedes rechazar.';

  @override
  String get noCases =>
      'Aún no hay casos disciplinarios. Se abren desde una denuncia o la página de miembros.';

  @override
  String get voteApproved =>
      'Tu voto se guardó. El comité aprobó la sanción y se ha aplicado.';

  @override
  String get voteRejected => 'Tu voto se guardó. El comité rechazó la sanción.';

  @override
  String get voteSaved =>
      'Tu voto se guardó. Puedes cambiarlo hasta que haya decisión.';

  @override
  String get statusVoting => 'En votación';

  @override
  String get statusApproved => 'Aprobado';

  @override
  String get statusRejected => 'Rechazado';

  @override
  String proposed(String sanction) {
    return 'Propuesta: $sanction';
  }

  @override
  String get directBan => 'Bloqueo sin votación';

  @override
  String illegalLabel(String category) {
    return 'Actividad ilegal: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals a favor · $rejections en contra · $voters votantes';
  }

  @override
  String votingEndsIn(String time) {
    return 'La votación termina en $time';
  }

  @override
  String bannedBy(String name) {
    return 'Bloqueado por: $name';
  }

  @override
  String openedBy(String name) {
    return 'Abierto por: $name';
  }

  @override
  String get approve => 'Aprobar';

  @override
  String get reject => 'Rechazar';

  @override
  String get noSanctions =>
      'Aún no hay sanciones. Aquí aparecen las aprobadas por el comité y las apelaciones.';

  @override
  String get liftSanction => 'Retirar la sanción';

  @override
  String get keepSanction => 'Mantener la sanción';

  @override
  String get noteToPerson => 'Nota para la persona (opcional)';

  @override
  String get liftedNotified => 'Sanción retirada; se avisó a la persona.';

  @override
  String get appealRejectedNotified =>
      'Apelación rechazada; se avisó a la persona.';

  @override
  String get lifted => 'Retirada';

  @override
  String get interimMute => 'Silencio de urgencia';

  @override
  String get running => 'Activa';

  @override
  String get applied => 'Aplicada';

  @override
  String get interimUntilDecision =>
      'Silencio de urgencia · hasta que decida el comité';

  @override
  String until(String date) {
    return 'hasta el $date';
  }

  @override
  String appealLine(String status) {
    return 'Apelación · $status';
  }

  @override
  String noteLine(String note) {
    return 'Nota: $note';
  }

  @override
  String get ownerParty =>
      'El propietario es parte del caso, así que el equipo de la plataforma revisa la apelación.';

  @override
  String get keep => 'Mantener';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casos esperan tu voto',
      one: '1 caso espera tu voto',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apelaciones',
      one: '1 apelación',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderación';

  @override
  String get noWork => 'Nada pendiente';

  @override
  String get mySanctions => 'Mis sanciones';

  @override
  String get noMySanctions =>
      'No tienes sanciones en ningún grupo. Gracias por seguir las normas de la comunidad.';

  @override
  String get interimEnded => 'Silencio de urgencia terminado';

  @override
  String interimLatest(String date) {
    return 'Silencio de urgencia · hasta que decida el comité, como tarde el $date';
  }

  @override
  String untilCap(String date) {
    return 'Hasta el $date';
  }

  @override
  String get ended => 'Terminada';

  @override
  String get appeal => 'Apelar';

  @override
  String get appealHint => '¿Por qué crees que es injusto?';

  @override
  String get send => 'Enviar';

  @override
  String get appealSent =>
      'Tu apelación se envió. Te avisaremos de la decisión.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Tu apelación · $status';
  }

  @override
  String get appealOnce => 'Puedes apelar esta decisión una vez en 7 días.';

  @override
  String get reportPost => 'Denunciar publicación';

  @override
  String get reportComment => 'Denunciar comentario';

  @override
  String get reportEvent => 'Denunciar evento';

  @override
  String get reportMessage => 'Denunciar mensaje';

  @override
  String get reportMatchProfile => 'Denunciar perfil de match';

  @override
  String get reportPhoto => 'Denunciar foto';

  @override
  String get reportUser => 'Denunciar usuario';

  @override
  String get reportReceived =>
      'Recibimos tu denuncia. La revisaremos y actuaremos; tu identidad no se muestra a la persona denunciada.';

  @override
  String get whyReport => '¿Por qué lo denuncias?';

  @override
  String get detailsOptional => 'Detalles (opcional)';

  @override
  String get detailsHint => 'Describe brevemente lo que pasó.';

  @override
  String get report => 'Denunciar';
}
