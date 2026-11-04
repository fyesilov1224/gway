// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class CoreL10nTr extends CoreL10n {
  CoreL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get networkFailure =>
      'Bağlantı kurulamadı. İnternet bağlantını kontrol edip tekrar dene.';

  @override
  String get unauthorizedFailure =>
      'Oturumun sona erdi. Lütfen tekrar giriş yap.';

  @override
  String get forbiddenFailure => 'Bu işlem için yetkin yok.';

  @override
  String get notFoundFailure => 'Aradığın içerik bulunamadı.';

  @override
  String get rateLimitedFailure =>
      'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.';

  @override
  String get unexpectedFailure => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get storageTooLarge =>
      'Dosya çok büyük. En fazla 5 MB yükleyebilirsin.';

  @override
  String get storageUnsupportedType =>
      'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.';

  @override
  String get categoryMusic => 'Müzik';

  @override
  String get categoryHiking => 'Yürüyüş';

  @override
  String get categoryRunning => 'Koşu';

  @override
  String get categoryCycling => 'Bisiklet';

  @override
  String get categoryNature => 'Doğa';

  @override
  String get categorySports => 'Spor';

  @override
  String get categoryArt => 'Sanat';

  @override
  String get categoryPhotography => 'Fotoğraf';

  @override
  String get categoryDance => 'Dans';

  @override
  String get categoryBooks => 'Kitap';

  @override
  String get categoryGames => 'Oyun';

  @override
  String get categoryTravel => 'Seyahat';

  @override
  String get categoryFood => 'Yemek';

  @override
  String get categoryTechnology => 'Teknoloji';

  @override
  String get categoryVolunteering => 'Gönüllülük';

  @override
  String get categoryMotorcycle => 'Motosiklet';

  @override
  String get categoryCamping => 'Kamp';

  @override
  String get categoryChess => 'Satranç';
}
