// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FeedL10nEs extends FeedL10n {
  FeedL10nEs([String locale = 'es']) : super(locale);

  @override
  String get commentsOff =>
      'Los comentarios están desactivados en esta publicación.';

  @override
  String get commentNotAllowed =>
      'Ahora no se puede comentar esta publicación. Puedes reaccionar con un emoji.';

  @override
  String get blocked => 'No puedes interactuar con esta cuenta.';

  @override
  String get commentRate =>
      'Has comentado mucho en poco tiempo. Espera un poco e inténtalo de nuevo.';

  @override
  String get muted =>
      'Estás silenciado en este grupo, así que ahora no puedes comentar.';

  @override
  String get likeRate =>
      'Has dado muchos «me gusta» en poco tiempo. Espera un poco e inténtalo de nuevo.';

  @override
  String get replyGone => 'El comentario al que respondes ya no existe.';

  @override
  String get storyRate =>
      'Hoy has compartido muchas historias. Vuelve a intentarlo mañana.';

  @override
  String get highlightLimit => 'Puedes crear hasta 100 destacados.';

  @override
  String get highlightFull => 'Un destacado puede tener hasta 100 historias.';

  @override
  String get duplicate => 'Esto ya se ha hecho.';

  @override
  String get fileTooLarge =>
      'El archivo es demasiado grande. Las fotos pueden tener hasta 10 MB y los vídeos 50 MB.';

  @override
  String get unsupportedMedia =>
      'Solo se pueden compartir fotos JPEG, PNG, WebP y vídeos MP4, MOV.';

  @override
  String get commentLength =>
      'El comentario debe tener entre 1 y 2.200 caracteres.';

  @override
  String get highlightTitleLength =>
      'El título debe tener entre 1 y 30 caracteres.';

  @override
  String get pickStory => 'Elige al menos una historia.';

  @override
  String get aspectOriginal => 'Original';

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
  String agoWeeks(int n) {
    return '$n sem';
  }

  @override
  String get photoLimit => 'Las fotos pueden tener hasta 10 MB.';

  @override
  String get videoSizeLimit => 'Los vídeos pueden tener hasta 50 MB.';

  @override
  String get videoLengthLimit => 'Los vídeos pueden durar hasta 60 segundos.';

  @override
  String get captionLimit =>
      'La descripción puede tener hasta 2.200 caracteres.';

  @override
  String get hashtagLimit => 'Una publicación puede tener hasta 30 etiquetas.';

  @override
  String get mediaCount =>
      'Una publicación puede tener de 1 a 10 fotos o vídeos.';

  @override
  String get comments => 'Comentarios';

  @override
  String get noCommentsEmojiOnly =>
      'Aún no hay comentarios. Puedes reaccionar con un emoji.';

  @override
  String get noCommentsFirst =>
      'Aún no hay comentarios. Sé el primero en comentar.';

  @override
  String get goBack => 'Volver';

  @override
  String get writeComment => 'Escribir un comentario';

  @override
  String replyingTo(String username) {
    return 'Respondiendo a $username';
  }

  @override
  String get cancelReply => 'Cancelar respuesta';

  @override
  String get addComment => 'Añade un comentario…';

  @override
  String get share => 'Compartir';

  @override
  String get deleteCommentTitle => '¿Eliminar comentario?';

  @override
  String get deleteCommentBody =>
      'El comentario y sus respuestas se eliminan definitivamente.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Responder';

  @override
  String get report => 'Denunciar';

  @override
  String get unlike => 'Ya no me gusta';

  @override
  String get likeComment => 'Me gusta el comentario';

  @override
  String get cantComment =>
      'Ahora no puedes comentar esta publicación. Puedes reaccionar con un emoji.';

  @override
  String get tooManyMedia =>
      'Una publicación puede tener hasta 10 fotos o vídeos.';

  @override
  String get cantOpenFile =>
      'No se pudo abrir el archivo. Prueba con otra foto o vídeo.';

  @override
  String get preparingPhotos => 'Preparando fotos…';

  @override
  String get photosFailed =>
      'No se pudieron preparar las fotos. Prueba con otra.';

  @override
  String uploading(int done, int total) {
    return 'Subiendo: $done/$total';
  }

  @override
  String get sharing => 'Compartiendo…';

  @override
  String get postShared => 'Tu publicación se ha compartido.';

  @override
  String get newPost => 'Nueva publicación';

  @override
  String get memoryNotice =>
      'Esta publicación también aparecerá entre los recuerdos del evento. Comparte solo tus fotos y a personas que hayan dado permiso.';

  @override
  String get pickMediaHint => 'Elige hasta 10 fotos o vídeos para compartir.';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get cropHint =>
      'Pellizca para hacer zoom y arrastra para encuadrar. La proporción se aplica a todas las fotos.';

  @override
  String get caption => 'Descripción';

  @override
  String get captionHint =>
      'Escribe algo… Puedes añadir #etiquetas y @usuarios.';

  @override
  String get postAs => 'Publicar como';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String groupOption(String name) {
    return '$name (grupo)';
  }

  @override
  String get turnOffComments => 'Desactivar comentarios';

  @override
  String get hideLikes => 'Ocultar número de me gusta';

  @override
  String get onlyYouSee => 'Solo tú ves el número.';

  @override
  String mediaN(int n) {
    return 'Archivo $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Quitar';

  @override
  String get cantShare => 'No se puede compartir';

  @override
  String get addMedia => 'Añadir contenido';

  @override
  String get editPost => 'Editar publicación';

  @override
  String get save => 'Guardar';

  @override
  String get noEditPermission =>
      'No tienes permiso para editar esta publicación.';

  @override
  String get photoToCrop => 'Foto para recortar';

  @override
  String get stories => 'Historias';

  @override
  String get feed => 'Muro';

  @override
  String get feedHint => 'De tus grupos y de quienes sigues';

  @override
  String get feedEmpty =>
      'Tu muro está vacío. Aquí aparecen las publicaciones de personas y grupos que sigues.';

  @override
  String get explore => 'Explorar';

  @override
  String get searchHint => 'Buscar personas o #etiquetas';

  @override
  String get clear => 'Borrar';

  @override
  String get exploreEmpty =>
      'No hay nada nuevo que explorar. Vuelve un poco más tarde.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get accounts => 'Cuentas';

  @override
  String get hashtags => 'Etiquetas';

  @override
  String noTagMatch(String query) {
    return 'Ninguna etiqueta empieza por «$query».';
  }

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones',
      one: '1 publicación',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'No hay publicaciones visibles con #$tag.';
  }

  @override
  String get backToExplore => 'Volver a Explorar';

  @override
  String get saved => 'Guardados';

  @override
  String get savedEmpty =>
      'Las publicaciones que guardes aparecen aquí y solo las ves tú.';

  @override
  String get post => 'Publicación';

  @override
  String get postGone =>
      'Esta publicación se eliminó o no tienes permiso para verla.';

  @override
  String get backToFeed => 'Volver al muro';

  @override
  String get unmute => 'Activar sonido';

  @override
  String get mute => 'Silenciar';

  @override
  String get addedToSaved => 'Añadido a guardados.';

  @override
  String get linkCopied => 'Enlace de la publicación copiado.';

  @override
  String get deletePostTitle => '¿Eliminar publicación?';

  @override
  String get deletePostBody =>
      'La publicación se elimina definitivamente con sus fotos, vídeos y comentarios.';

  @override
  String get postDeleted => 'Publicación eliminada.';

  @override
  String get likesHidden => 'Solo tú ves el número de me gusta.';

  @override
  String memoryOf(String title) {
    return 'Recuerdo · $title';
  }

  @override
  String get deletedAccount => 'Cuenta eliminada';

  @override
  String get groupPost => 'Publicación de grupo';

  @override
  String get edited => 'editado';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get edit => 'Editar';

  @override
  String get like => 'Me gusta';

  @override
  String get commentAction => 'Comentar';

  @override
  String get unsave => 'Quitar de guardados';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Reacción $emoji, $count';
  }

  @override
  String get more => 'más';

  @override
  String postWithCaption(String caption) {
    return 'Publicación: $caption';
  }

  @override
  String get showMore => 'Mostrar más';

  @override
  String get addStory => 'Añadir historia';

  @override
  String get yourStory => 'Tu historia';

  @override
  String get noStoriesLeft => 'No quedan historias que puedas ver aquí.';

  @override
  String get close => 'Cerrar';

  @override
  String get removeFromHighlight => 'Quitar del destacado';

  @override
  String get removedFromHighlight => 'Quitado del destacado.';

  @override
  String get addToHighlights => 'Añadir a destacados';

  @override
  String get deleteStory => 'Eliminar historia';

  @override
  String get storyDeleted => 'Historia eliminada.';

  @override
  String get options => 'Opciones';

  @override
  String get viewers => 'Espectadores';

  @override
  String get noViewers =>
      'Nadie la ha visto aún. Los espectadores aparecen aquí y solo los ves tú.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vista por $count personas',
      one: 'Vista por 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'No se pudo preparar la foto. Prueba con otra.';

  @override
  String get storyShared =>
      'Tu historia se ha compartido. Será visible durante 24 horas.';

  @override
  String get newStory => 'Nueva historia';

  @override
  String get addToStory => 'Añadir a tu historia';

  @override
  String get storyPickHint =>
      'Elige una foto o un vídeo de hasta 60 segundos para tu historia.';

  @override
  String get pickAnother => 'Elegir otra';

  @override
  String get newHighlight => 'Nuevo destacado';

  @override
  String highlightCreated(String title) {
    return '«$title» creado.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count historias',
      one: '1 historia',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Añadido a «$title».';
  }

  @override
  String get highlightTitle => 'Título del destacado';

  @override
  String get highlightExample => 'Ej.: Camping 2026';

  @override
  String get addHighlight => 'Añadir destacado';

  @override
  String get renameHighlight => 'Cambiar título';

  @override
  String get deleteHighlight => 'Eliminar destacado';

  @override
  String get staysInArchive => 'Las historias se quedan en tu archivo.';

  @override
  String get storyArchive => 'Archivo de historias';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count historias seleccionadas',
      one: '1 historia seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Destacar';

  @override
  String get archiveEmpty =>
      'Las historias que compartes se guardan aquí después de 24 horas y solo las ves tú.';

  @override
  String get shareStory => 'Compartir una historia';

  @override
  String get archiveHint =>
      'Selecciona historias para crear un destacado o añadirlas a uno.';

  @override
  String storyOn(String date) {
    return 'Historia, $date';
  }

  @override
  String get live => 'Publicada';
}
