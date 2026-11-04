// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class CoreL10nFr extends CoreL10n {
  CoreL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get networkFailure =>
      'Connexion impossible. Vérifie ta connexion Internet et réessaie.';

  @override
  String get unauthorizedFailure => 'Ta session a expiré. Reconnecte-toi.';

  @override
  String get forbiddenFailure =>
      'Tu n\'as pas l\'autorisation de faire cette action.';

  @override
  String get notFoundFailure => 'Le contenu que tu cherches est introuvable.';

  @override
  String get rateLimitedFailure =>
      'Trop de tentatives. Patiente un peu et réessaie.';

  @override
  String get unexpectedFailure => 'Une erreur s\'est produite. Réessaie.';

  @override
  String get storageTooLarge =>
      'Le fichier est trop volumineux. Tu peux importer jusqu\'à 5 Mo.';

  @override
  String get storageUnsupportedType =>
      'Ce type de fichier n\'est pas pris en charge. Choisis JPEG, PNG ou WebP.';

  @override
  String get categoryMusic => 'Musique';

  @override
  String get categoryHiking => 'Randonnée';

  @override
  String get categoryRunning => 'Course à pied';

  @override
  String get categoryCycling => 'Vélo';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categorySports => 'Sport';

  @override
  String get categoryArt => 'Art';

  @override
  String get categoryPhotography => 'Photographie';

  @override
  String get categoryDance => 'Danse';

  @override
  String get categoryBooks => 'Livres';

  @override
  String get categoryGames => 'Jeux';

  @override
  String get categoryTravel => 'Voyage';

  @override
  String get categoryFood => 'Cuisine';

  @override
  String get categoryTechnology => 'Technologie';

  @override
  String get categoryVolunteering => 'Bénévolat';

  @override
  String get categoryMotorcycle => 'Moto';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get categoryChess => 'Échecs';
}
