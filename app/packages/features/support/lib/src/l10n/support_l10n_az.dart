// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class SupportL10nAz extends SupportL10n {
  SupportL10nAz([String locale = 'az']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Bu gün çox mesaj açdın. Sabah yenidən cəhd edə və ya açıq mesajlarına yaza bilərsən.';

  @override
  String get ruleReplyRate =>
      'Qısa müddətdə çox cavab yazdın. Bir az gözləyib yenidən cəhd et.';

  @override
  String get ticketClosed =>
      'Bu mesaj bağlandı. Davam etmək üçün yeni mesaj aç.';

  @override
  String get unsupportedImage =>
      'Bu fayl növü dəstəklənmir. JPEG, PNG və ya WebP seç.';

  @override
  String get kindProblem => 'Problem';

  @override
  String get kindProblemText => 'Nəsə xarabdır və ya işləmir.';

  @override
  String get kindRequest => 'Tələb';

  @override
  String get kindRequestText =>
      'Hesabın, qrupun və ya ödənişin üçün bir əməliyyat istə.';

  @override
  String get kindSuggestion => 'Təklif';

  @override
  String get kindSuggestionText => 'Yeni xüsusiyyət və ya təklif paylaş.';

  @override
  String get statusOpen => 'Yeni';

  @override
  String get statusInProgress => 'Baxılır';

  @override
  String get statusResolved => 'Həll edildi';

  @override
  String get statusClosed => 'Bağlandı';

  @override
  String get guide => 'İstifadə təlimatı';

  @override
  String get guideSearchHint => 'Təlimatda axtar: məs. dəvət linki, şifrə';

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String get guideIntro =>
      'GWAY-in hər bölməsini addım-addım izah edir. Bir bölmə seç və ya yuxarıdan axtar.';

  @override
  String get noHits =>
      'Axtardığını tapmadıq. Başqa söz yoxla və ya dəstək komandasına yaz.';

  @override
  String get writeSupport => 'Dəstək komandasına yaz';

  @override
  String hitsFound(int count) {
    return '$count mövzu tapıldı';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count mövzu.';
  }

  @override
  String topicCount(int count) {
    return '$count mövzu';
  }

  @override
  String get chapterNotFound => 'Bu bölmə tapılmadı.';

  @override
  String get backToGuide => 'Təlimata qayıt';

  @override
  String get notSolved => 'Problemin həll olunmadı?';

  @override
  String get notSolvedHint =>
      'Platforma komandasına yaz; cavabı Ayarlar → Dəstək və rəy bölməsində görəcəksən.';

  @override
  String get nextChapter => 'Növbəti bölmə';

  @override
  String get sent => 'Mesajın platforma komandasına göndərildi.';

  @override
  String get newMessage => 'Yeni mesaj';

  @override
  String get aboutWhat => 'Nə haqqında yazırsan?';

  @override
  String get pickKind => 'Bir növ seç.';

  @override
  String get relatedGroup => 'Əlaqəli qrup (istəyə bağlı)';

  @override
  String get noGroup => 'Qrupla əlaqəli deyil';

  @override
  String get subject => 'Mövzu';

  @override
  String get subjectRequired => 'Qısa mövzu yaz.';

  @override
  String get description => 'İzah';

  @override
  String get descriptionHint =>
      'Nə oldu, nə gözləyirdin? Nə qədər ətraflı, o qədər tez kömək.';

  @override
  String get descriptionRequired => 'Nə olduğunu qısaca danış.';

  @override
  String get send => 'Göndər';

  @override
  String get supportTitle => 'Dəstək və rəy';

  @override
  String get emptyIntro =>
      'Problem, tələb və ya təklif üçün platforma komandasına yaza bilərsən.';

  @override
  String get listIntro =>
      'Mesajların platforma komandasına göndərilir; cavabları və statusu buradan izləyə bilərsən.';

  @override
  String get newReply => 'Yeni cavab';

  @override
  String get message => 'Mesaj';

  @override
  String get notFound => 'Bu mesaj tapılmadı.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String get team => 'GWAY Komandası';

  @override
  String get you => 'Sən';

  @override
  String get addScreenshot => 'Ekran şəkli əlavə et';

  @override
  String get writeReply => 'Cavab yaz';

  @override
  String get removeImage => 'Şəkli götür';

  @override
  String screenshots(int count, int max) {
    return 'Ekran şəkli ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Ekran şəklini böyüt';
}
