// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class CoreL10nIt extends CoreL10n {
  CoreL10nIt([String locale = 'it']) : super(locale);

  @override
  String get networkFailure =>
      'Impossibile connettersi. Controlla la connessione a internet e riprova.';

  @override
  String get unauthorizedFailure => 'La sessione è scaduta. Accedi di nuovo.';

  @override
  String get forbiddenFailure => 'Non hai il permesso per questa azione.';

  @override
  String get notFoundFailure => 'Non abbiamo trovato quello che cerchi.';

  @override
  String get rateLimitedFailure =>
      'Troppi tentativi. Aspetta un momento e riprova.';

  @override
  String get unexpectedFailure => 'Qualcosa è andato storto. Riprova.';

  @override
  String get storageTooLarge =>
      'Il file è troppo grande. Puoi caricare fino a 5 MB.';

  @override
  String get storageUnsupportedType =>
      'Questo tipo di file non è supportato. Scegli JPEG, PNG o WebP.';

  @override
  String get categoryMusic => 'Musica';

  @override
  String get categoryHiking => 'Escursionismo';

  @override
  String get categoryRunning => 'Corsa';

  @override
  String get categoryCycling => 'Ciclismo';

  @override
  String get categoryNature => 'Natura';

  @override
  String get categorySports => 'Sport';

  @override
  String get categoryArt => 'Arte';

  @override
  String get categoryPhotography => 'Fotografia';

  @override
  String get categoryDance => 'Danza';

  @override
  String get categoryBooks => 'Libri';

  @override
  String get categoryGames => 'Giochi';

  @override
  String get categoryTravel => 'Viaggi';

  @override
  String get categoryFood => 'Cucina';

  @override
  String get categoryTechnology => 'Tecnologia';

  @override
  String get categoryVolunteering => 'Volontariato';

  @override
  String get categoryMotorcycle => 'Moto';

  @override
  String get categoryCamping => 'Campeggio';

  @override
  String get categoryChess => 'Scacchi';
}
