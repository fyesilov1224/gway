// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class CoreL10nNl extends CoreL10n {
  CoreL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get networkFailure =>
      'Geen verbinding. Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get unauthorizedFailure => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get forbiddenFailure => 'Je hebt geen toestemming voor deze actie.';

  @override
  String get notFoundFailure => 'De inhoud die je zoekt is niet gevonden.';

  @override
  String get rateLimitedFailure =>
      'Te veel pogingen. Wacht even en probeer het opnieuw.';

  @override
  String get unexpectedFailure => 'Er ging iets mis. Probeer het opnieuw.';

  @override
  String get storageTooLarge =>
      'Het bestand is te groot. Je kunt maximaal 5 MB uploaden.';

  @override
  String get storageUnsupportedType =>
      'Dit bestandstype wordt niet ondersteund. Kies JPEG, PNG of WebP.';

  @override
  String get categoryMusic => 'Muziek';

  @override
  String get categoryHiking => 'Wandelen';

  @override
  String get categoryRunning => 'Hardlopen';

  @override
  String get categoryCycling => 'Fietsen';

  @override
  String get categoryNature => 'Natuur';

  @override
  String get categorySports => 'Sport';

  @override
  String get categoryArt => 'Kunst';

  @override
  String get categoryPhotography => 'Fotografie';

  @override
  String get categoryDance => 'Dans';

  @override
  String get categoryBooks => 'Boeken';

  @override
  String get categoryGames => 'Spellen';

  @override
  String get categoryTravel => 'Reizen';

  @override
  String get categoryFood => 'Eten';

  @override
  String get categoryTechnology => 'Technologie';

  @override
  String get categoryVolunteering => 'Vrijwilligerswerk';

  @override
  String get categoryMotorcycle => 'Motorrijden';

  @override
  String get categoryCamping => 'Kamperen';

  @override
  String get categoryChess => 'Schaken';
}
