// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SupportL10nEs extends SupportL10n {
  SupportL10nEs([String locale = 'es']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Hoy abriste demasiados mensajes. Inténtalo mañana o responde en tus mensajes abiertos.';

  @override
  String get ruleReplyRate =>
      'Escribiste demasiadas respuestas en poco tiempo. Espera un poco y vuelve a intentarlo.';

  @override
  String get ticketClosed =>
      'Este mensaje está cerrado. Abre uno nuevo para continuar.';

  @override
  String get unsupportedImage =>
      'Este tipo de archivo no es compatible. Elige JPEG, PNG o WebP.';

  @override
  String get kindProblem => 'Problema';

  @override
  String get kindProblemText => 'Algo está roto o no funciona.';

  @override
  String get kindRequest => 'Solicitud';

  @override
  String get kindRequestText =>
      'Pide una gestión para tu cuenta, grupo o pago.';

  @override
  String get kindSuggestion => 'Sugerencia';

  @override
  String get kindSuggestionText => 'Comparte una idea o sugerencia.';

  @override
  String get statusOpen => 'Nuevo';

  @override
  String get statusInProgress => 'En revisión';

  @override
  String get statusResolved => 'Resuelto';

  @override
  String get statusClosed => 'Cerrado';

  @override
  String get guide => 'Guía de uso';

  @override
  String get guideSearchHint =>
      'Buscar en la guía: p. ej. enlace de invitación, contraseña';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get guideIntro =>
      'Explica cada parte de GWAY paso a paso. Elige un capítulo o busca arriba.';

  @override
  String get noHits =>
      'No encontramos nada. Prueba otra palabra o escribe al equipo de soporte.';

  @override
  String get writeSupport => 'Escribir a soporte';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temas encontrados',
      one: '1 tema encontrado',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count temas.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temas',
      one: '1 tema',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'No se encontró el capítulo.';

  @override
  String get backToGuide => 'Volver a la guía';

  @override
  String get notSolved => '¿No se resolvió tu problema?';

  @override
  String get notSolvedHint =>
      'Escribe al equipo de la plataforma; verás la respuesta en Ajustes → Soporte y comentarios.';

  @override
  String get nextChapter => 'Siguiente capítulo';

  @override
  String get sent => 'Tu mensaje se envió al equipo de la plataforma.';

  @override
  String get newMessage => 'Nuevo mensaje';

  @override
  String get aboutWhat => '¿Sobre qué escribes?';

  @override
  String get pickKind => 'Elige un tipo.';

  @override
  String get relatedGroup => 'Grupo relacionado (opcional)';

  @override
  String get noGroup => 'No es sobre un grupo';

  @override
  String get subject => 'Asunto';

  @override
  String get subjectRequired => 'Escribe un asunto breve.';

  @override
  String get description => 'Descripción';

  @override
  String get descriptionHint =>
      '¿Qué pasó y qué esperabas? Más detalles, ayuda más rápida.';

  @override
  String get descriptionRequired => 'Describe brevemente lo que pasó.';

  @override
  String get send => 'Enviar';

  @override
  String get supportTitle => 'Soporte y comentarios';

  @override
  String get emptyIntro =>
      'Puedes escribir al equipo de la plataforma por un problema, solicitud o sugerencia.';

  @override
  String get listIntro =>
      'Tus mensajes van al equipo de la plataforma; sigue aquí las respuestas y el estado.';

  @override
  String get newReply => 'Nueva respuesta';

  @override
  String get message => 'Mensaje';

  @override
  String get notFound => 'No se encontró el mensaje.';

  @override
  String get goBack => 'Volver';

  @override
  String get team => 'Equipo de GWAY';

  @override
  String get you => 'Tú';

  @override
  String get addScreenshot => 'Añadir captura';

  @override
  String get writeReply => 'Escribe una respuesta';

  @override
  String get removeImage => 'Quitar imagen';

  @override
  String screenshots(int count, int max) {
    return 'Capturas ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Ampliar captura';
}
