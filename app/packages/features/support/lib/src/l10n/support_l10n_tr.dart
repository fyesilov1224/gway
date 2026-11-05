// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class SupportL10nTr extends SupportL10n {
  SupportL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Bugün çok fazla mesaj açtın. Yarın tekrar deneyebilir ya da açık mesajlarına yazabilirsin.';

  @override
  String get ruleReplyRate =>
      'Kısa sürede çok fazla yanıt yazdın. Biraz bekleyip tekrar dene.';

  @override
  String get ticketClosed =>
      'Bu mesaj kapatıldı. Devam etmek için yeni bir mesaj aç.';

  @override
  String get unsupportedImage =>
      'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.';

  @override
  String get kindProblem => 'Sorun';

  @override
  String get kindProblemText => 'Bir şey bozuk ya da çalışmıyor.';

  @override
  String get kindRequest => 'Talep';

  @override
  String get kindRequestText =>
      'Hesabın, grubun ya da ödemen için bir işlem iste.';

  @override
  String get kindSuggestion => 'İstek';

  @override
  String get kindSuggestionText => 'Yeni bir özellik ya da öneri paylaş.';

  @override
  String get statusOpen => 'Yeni';

  @override
  String get statusInProgress => 'İnceleniyor';

  @override
  String get statusResolved => 'Çözüldü';

  @override
  String get statusClosed => 'Kapatıldı';

  @override
  String get guide => 'Kullanma kılavuzu';

  @override
  String get guideSearchHint => 'Kılavuzda ara: ör. davet bağlantısı, şifre';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get guideIntro =>
      'GWAY\'in her bölümünü adım adım anlatır. Bir bölüm seç ya da yukarıdan ara.';

  @override
  String get noHits =>
      'Aradığını bulamadık. Başka bir kelime dene ya da destek ekibine yaz.';

  @override
  String get writeSupport => 'Destek ekibine yaz';

  @override
  String hitsFound(int count) {
    return '$count konu bulundu';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count konu.';
  }

  @override
  String topicCount(int count) {
    return '$count konu';
  }

  @override
  String get chapterNotFound => 'Bu bölüm bulunamadı.';

  @override
  String get backToGuide => 'Kılavuza dön';

  @override
  String get notSolved => 'Sorunun çözülmedi mi?';

  @override
  String get notSolvedHint =>
      'Platform ekibine yaz; yanıtı Ayarlar → Destek ve geri bildirim\'de görürsün.';

  @override
  String get nextChapter => 'Sonraki bölüm';

  @override
  String get sent => 'Mesajın platform ekibine iletildi.';

  @override
  String get newMessage => 'Yeni mesaj';

  @override
  String get aboutWhat => 'Ne hakkında yazıyorsun?';

  @override
  String get pickKind => 'Bir tür seç.';

  @override
  String get relatedGroup => 'İlgili grup (isteğe bağlı)';

  @override
  String get noGroup => 'Grupla ilgili değil';

  @override
  String get subject => 'Konu';

  @override
  String get subjectRequired => 'Kısa bir konu yaz.';

  @override
  String get description => 'Açıklama';

  @override
  String get descriptionHint =>
      'Ne oldu, ne bekliyordun? Ne kadar ayrıntı, o kadar hızlı yardım.';

  @override
  String get descriptionRequired => 'Ne olduğunu kısaca anlat.';

  @override
  String get send => 'Gönder';

  @override
  String get supportTitle => 'Destek ve geri bildirim';

  @override
  String get emptyIntro =>
      'Bir sorun, talep ya da istek için platform ekibine yazabilirsin.';

  @override
  String get listIntro =>
      'Mesajların platform ekibine iletilir; yanıtları ve durumlarını buradan izleyebilirsin.';

  @override
  String get newReply => 'Yeni yanıt';

  @override
  String get message => 'Mesaj';

  @override
  String get notFound => 'Bu mesaj bulunamadı.';

  @override
  String get goBack => 'Geri dön';

  @override
  String get team => 'GWAY Ekibi';

  @override
  String get you => 'Sen';

  @override
  String get addScreenshot => 'Ekran görüntüsü ekle';

  @override
  String get writeReply => 'Yanıt yaz';

  @override
  String get removeImage => 'Görseli kaldır';

  @override
  String screenshots(int count, int max) {
    return 'Ekran görüntüsü ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Ekran görüntüsünü büyüt';
}
