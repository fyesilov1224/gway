// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class CoreL10nDe extends CoreL10n {
  CoreL10nDe([String locale = 'de']) : super(locale);

  @override
  String get networkFailure =>
      'Keine Verbindung möglich. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get unauthorizedFailure =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get forbiddenFailure => 'Du hast keine Berechtigung für diese Aktion.';

  @override
  String get notFoundFailure => 'Der gesuchte Inhalt wurde nicht gefunden.';

  @override
  String get rateLimitedFailure =>
      'Zu viele Versuche. Warte kurz und versuche es erneut.';

  @override
  String get unexpectedFailure =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get storageTooLarge =>
      'Die Datei ist zu groß. Du kannst bis zu 5 MB hochladen.';

  @override
  String get storageUnsupportedType =>
      'Dieser Dateityp wird nicht unterstützt. Wähle JPEG, PNG oder WebP.';

  @override
  String get categoryMusic => 'Musik';

  @override
  String get categoryHiking => 'Wandern';

  @override
  String get categoryRunning => 'Laufen';

  @override
  String get categoryCycling => 'Radfahren';

  @override
  String get categoryNature => 'Natur';

  @override
  String get categorySports => 'Sport';

  @override
  String get categoryArt => 'Kunst';

  @override
  String get categoryPhotography => 'Fotografie';

  @override
  String get categoryDance => 'Tanz';

  @override
  String get categoryBooks => 'Bücher';

  @override
  String get categoryGames => 'Spiele';

  @override
  String get categoryTravel => 'Reisen';

  @override
  String get categoryFood => 'Essen';

  @override
  String get categoryTechnology => 'Technik';

  @override
  String get categoryVolunteering => 'Ehrenamt';

  @override
  String get categoryMotorcycle => 'Motorrad';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get categoryChess => 'Schach';
}
