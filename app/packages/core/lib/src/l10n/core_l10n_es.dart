// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class CoreL10nEs extends CoreL10n {
  CoreL10nEs([String locale = 'es']) : super(locale);

  @override
  String get networkFailure =>
      'No se pudo conectar. Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get unauthorizedFailure =>
      'Tu sesión ha caducado. Vuelve a iniciar sesión.';

  @override
  String get forbiddenFailure => 'No tienes permiso para hacer esto.';

  @override
  String get notFoundFailure => 'No encontramos lo que buscas.';

  @override
  String get rateLimitedFailure =>
      'Demasiados intentos. Espera un momento e inténtalo de nuevo.';

  @override
  String get unexpectedFailure => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get storageTooLarge =>
      'El archivo es demasiado grande. Puedes subir hasta 5 MB.';

  @override
  String get storageUnsupportedType =>
      'Este tipo de archivo no es compatible. Elige JPEG, PNG o WebP.';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryHiking => 'Senderismo';

  @override
  String get categoryRunning => 'Running';

  @override
  String get categoryCycling => 'Ciclismo';

  @override
  String get categoryNature => 'Naturaleza';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryArt => 'Arte';

  @override
  String get categoryPhotography => 'Fotografía';

  @override
  String get categoryDance => 'Baile';

  @override
  String get categoryBooks => 'Libros';

  @override
  String get categoryGames => 'Juegos';

  @override
  String get categoryTravel => 'Viajes';

  @override
  String get categoryFood => 'Gastronomía';

  @override
  String get categoryTechnology => 'Tecnología';

  @override
  String get categoryVolunteering => 'Voluntariado';

  @override
  String get categoryMotorcycle => 'Motociclismo';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get categoryChess => 'Ajedrez';
}
