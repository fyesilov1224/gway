// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class CoreL10nAz extends CoreL10n {
  CoreL10nAz([String locale = 'az']) : super(locale);

  @override
  String get networkFailure =>
      'Bağlantı qurulmadı. İnternet bağlantını yoxla və yenidən cəhd et.';

  @override
  String get unauthorizedFailure =>
      'Sessiyanın müddəti bitdi. Zəhmət olmasa, yenidən daxil ol.';

  @override
  String get forbiddenFailure => 'Bu əməliyyat üçün icazən yoxdur.';

  @override
  String get notFoundFailure => 'Axtardığın məzmun tapılmadı.';

  @override
  String get rateLimitedFailure =>
      'Çox sayda cəhd edildi. Bir az gözlə və yenidən cəhd et.';

  @override
  String get unexpectedFailure =>
      'Nəsə səhv getdi. Zəhmət olmasa, yenidən cəhd et.';

  @override
  String get storageTooLarge =>
      'Fayl çox böyükdür. Ən çox 5 MB yükləyə bilərsən.';

  @override
  String get storageUnsupportedType =>
      'Bu fayl növü dəstəklənmir. JPEG, PNG və ya WebP seç.';

  @override
  String get categoryMusic => 'Musiqi';

  @override
  String get categoryHiking => 'Yürüyüş';

  @override
  String get categoryRunning => 'Qaçış';

  @override
  String get categoryCycling => 'Velosiped';

  @override
  String get categoryNature => 'Təbiət';

  @override
  String get categorySports => 'İdman';

  @override
  String get categoryArt => 'İncəsənət';

  @override
  String get categoryPhotography => 'Fotoqrafiya';

  @override
  String get categoryDance => 'Rəqs';

  @override
  String get categoryBooks => 'Kitab';

  @override
  String get categoryGames => 'Oyun';

  @override
  String get categoryTravel => 'Səyahət';

  @override
  String get categoryFood => 'Yemək';

  @override
  String get categoryTechnology => 'Texnologiya';

  @override
  String get categoryVolunteering => 'Könüllülük';

  @override
  String get categoryMotorcycle => 'Motosiklet';

  @override
  String get categoryCamping => 'Düşərgə';

  @override
  String get categoryChess => 'Şahmat';
}
