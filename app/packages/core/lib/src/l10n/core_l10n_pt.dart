// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class CoreL10nPt extends CoreL10n {
  CoreL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get networkFailure =>
      'Não foi possível conectar. Verifique sua conexão com a internet e tente novamente.';

  @override
  String get unauthorizedFailure => 'Sua sessão expirou. Entre novamente.';

  @override
  String get forbiddenFailure => 'Você não tem permissão para fazer isso.';

  @override
  String get notFoundFailure => 'Não encontramos o que você procura.';

  @override
  String get rateLimitedFailure =>
      'Muitas tentativas. Aguarde um pouco e tente novamente.';

  @override
  String get unexpectedFailure => 'Algo deu errado. Tente novamente.';

  @override
  String get storageTooLarge =>
      'O arquivo é muito grande. Você pode enviar até 5 MB.';

  @override
  String get storageUnsupportedType =>
      'Este tipo de arquivo não é compatível. Escolha JPEG, PNG ou WebP.';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryHiking => 'Trilhas';

  @override
  String get categoryRunning => 'Corrida';

  @override
  String get categoryCycling => 'Ciclismo';

  @override
  String get categoryNature => 'Natureza';

  @override
  String get categorySports => 'Esportes';

  @override
  String get categoryArt => 'Arte';

  @override
  String get categoryPhotography => 'Fotografia';

  @override
  String get categoryDance => 'Dança';

  @override
  String get categoryBooks => 'Livros';

  @override
  String get categoryGames => 'Jogos';

  @override
  String get categoryTravel => 'Viagem';

  @override
  String get categoryFood => 'Gastronomia';

  @override
  String get categoryTechnology => 'Tecnologia';

  @override
  String get categoryVolunteering => 'Voluntariado';

  @override
  String get categoryMotorcycle => 'Motociclismo';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get categoryChess => 'Xadrez';
}
