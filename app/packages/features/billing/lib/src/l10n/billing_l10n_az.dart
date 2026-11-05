// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class BillingL10nAz extends BillingL10n {
  BillingL10nAz([String locale = 'az']) : super(locale);

  @override
  String get monthly => 'Aylıq';

  @override
  String get yearly => 'İllik';

  @override
  String get perMonth => 'ay';

  @override
  String get perYear => 'il';

  @override
  String get notOnDevice => 'Bu əməliyyat bu cihazda istifadə edilə bilmir.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String get payment => 'Ödəniş';

  @override
  String get planUnavailable => 'Bu paketi hazırda almaq olmur.';

  @override
  String get backToPlans => 'Paketlərə qayıt';

  @override
  String get paymentPageFailed =>
      'Ödəniş səhifəsi açılmadı. Zəhmət olmasa yenidən cəhd et.';

  @override
  String get billingDetails => 'Faktura məlumatları';

  @override
  String get billingDetailsHint => 'Fakturan bu məlumatlarla tərtib olunur.';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String fieldRequired(String field) {
    return '$field tələb olunur.';
  }

  @override
  String get phone => 'Telefon';

  @override
  String get phoneInvalid => 'Düzgün telefon nömrəsi daxil et.';

  @override
  String get address => 'Ünvan';

  @override
  String get addressRequired => 'Faktura ünvanını daxil et.';

  @override
  String get city => 'Şəhər';

  @override
  String get cityRequired => 'Şəhəri daxil et.';

  @override
  String get country => 'Ölkə';

  @override
  String get countryRequired => 'Ölkəni daxil et.';

  @override
  String get termsBefore => '';

  @override
  String get termsAfter => ' ilə tanış oldum və qəbul edirəm.';

  @override
  String get acceptTerms => 'Davam etmək üçün müqaviləni təsdiqləməlisən.';

  @override
  String get billingDataUse =>
      'Faktura məlumatların yalnız ödənişin alınması, fakturalaşdırma və qanuni saxlama öhdəlikləri üçün istifadə olunur.';

  @override
  String payAmount(String amount) {
    return 'Ödənişə keç · $amount';
  }

  @override
  String get orderSummary => 'Sifarişin xülasəsi';

  @override
  String planPeriod(String plan, String period) {
    return '$plan paketi · $period';
  }

  @override
  String get start => 'Başlanğıc';

  @override
  String get whenConfirmed => 'Ödəniş təsdiqlənəndə';

  @override
  String get endEstimated => 'Bitmə (təxmini)';

  @override
  String get carriedOver => 'Köçürülən müddət';

  @override
  String about(String value) {
    return 'təxminən $value';
  }

  @override
  String get total => 'Cəmi';

  @override
  String assuranceTry(String provider) {
    return 'Ödəniş $provider təminatı ilə türk lirəsi ilə alınır. Kart məlumatların GWAY-ə ötürülmür. Birdəfəlik ödənişdir, avtomatik yenilənmir.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Ödəniş $provider təminatı ilə ABŞ dolları ilə alınır. Kart məlumatların GWAY-ə ötürülmür. Birdəfəlik ödənişdir, avtomatik yenilənmir.';
  }

  @override
  String get overLimit =>
      'Üzv sayı paketin limitini aşır. Limitdən aşağı düşənə qədər yeni üzv qəbul olunmur.';

  @override
  String get atLimit =>
      'Qrup paketinin üzv limitinə çatdı. Yeni üzv qəbul olunmur.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max üzv';
  }

  @override
  String get plan => 'Paket';

  @override
  String get getPlan => 'Paket al';

  @override
  String get upgradePlan => 'Paketi yüksəlt';

  @override
  String planEnds(String date) {
    return 'Paketin $date tarixində bitir. Bitəndə qrup Pulsuz paketə qayıdır.';
  }

  @override
  String get paymentReceivedPersonal => 'Ödəniş alındı. Paketin açıldı.';

  @override
  String get planStatus => 'Paket statusu';

  @override
  String get notActive => 'Bu paket hesabında açıq deyil.';

  @override
  String activeUntil(String date) {
    return 'Paketin $date tarixinədək açıqdır.';
  }

  @override
  String get buy => 'Satın al';

  @override
  String get extend => 'Müddəti uzat';

  @override
  String get oneTime => 'Birdəfəlik ödəniş; avtomatik yenilənmir.';

  @override
  String newPeriodAfter(String date) {
    return 'Yeni müddət $date tarixindən sonra başlayır.';
  }

  @override
  String get salesClosed =>
      'Bu paketin satışı hazırda bağlıdır. Zəhmət olmasa sonra yenidən cəhd et.';

  @override
  String continueAmount(String amount) {
    return 'Davam et · $amount';
  }

  @override
  String get personalOnly =>
      'Bu paket yalnız səni əhatə edir; qrupunun paketinə təsir etmir.';

  @override
  String saving(int percent) {
    return '$percent% sərfəli';
  }

  @override
  String untilDate(String date) {
    return '$date tarixinədək';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Bu məhsulu hazırda almaq olmur.';

  @override
  String get personalProduct => 'Şəxsi məhsul';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Qrupun hazırdır';

  @override
  String get freeStartBuy =>
      'Qrupun Pulsuz paketlə başladı. Daha çox üzv, tədbir və ya yayım dəqiqəsi lazımdırsa, aşağıdan paket seçə bilərsən.';

  @override
  String get freeStartView =>
      'Qrupun Pulsuz paketlə başladı. Paketlərin limitləri aşağıdadır.';

  @override
  String get continueFree => 'Pulsuz davam et';

  @override
  String get goToGroup => 'Qrupa keç';

  @override
  String get paymentReceivedGroup => 'Ödəniş alındı. Paketin aktivdir.';

  @override
  String get membersOnly => 'Qrupun paketini yalnız qrupun üzvləri görə bilər.';

  @override
  String get currentPlan => 'Cari paket';

  @override
  String get onFree => 'Qrup pulsuz paketdən istifadə edir.';

  @override
  String periodEnds(String date) {
    return 'Bu dövr $date tarixində bitir.';
  }

  @override
  String get overLimitLong =>
      'Üzv sayı paketin limitini aşır. Heç kim qrupdan çıxarılmır, amma limitdən aşağı düşənə qədər yeni üzv qəbul olunmur.';

  @override
  String get atLimitLong =>
      'Qrup üzv limitinə çatdı. Yeni üzv qəbul etmək üçün daha böyük paketə keçə bilərsən.';

  @override
  String get upcomingPeriods => 'Növbəti dövrlər';

  @override
  String get plans => 'Paketlər';

  @override
  String get yearlyDeal => 'İllik · 2 ay pulsuz';

  @override
  String paymentNoteTry(String provider) {
    return 'Ödəniş $provider ilə türk lirəsi ilə alınır; olduğun ölkəyə görə müəyyən edilir. Avtomatik yenilənmə yoxdur.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Ödəniş $provider ilə ABŞ dolları ilə alınır; olduğun ölkəyə görə müəyyən edilir. Avtomatik yenilənmə yoxdur.';
  }

  @override
  String get paymentsOff =>
      'Ödəniş hazırda qəbul olunmur. Zəhmət olmasa sonra yenidən cəhd et.';

  @override
  String get notNow => 'Hələlik alınmır';

  @override
  String get choose => 'Seç';

  @override
  String get upgrade => 'Yüksəlt';

  @override
  String get renew => 'Müddəti uzat';

  @override
  String get switchTo => 'Bu paketə keç';

  @override
  String get paidOverYear =>
      'Paketin bir ildən uzun müddətə ödənib. Hələlik yalnız üst paketə keçə bilərsən.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Dərhal başlayır; qalan müddətindən təxminən $credit əlavə olunur. Bitmə: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Dərhal başlayır. Bitmə: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Cari dövrdən sonra, $date tarixində başlayır.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Cari dövr bitəndə, $date tarixində başlayır.';
  }

  @override
  String get confirmPending =>
      'Ödəniş təsdiqi hələ gəlməyib. Ödənişin alınıbsa, paketin bir neçə dəqiqəyə aktivləşir; bu səhifəni sonra yeniləyə bilərsən.';

  @override
  String get confirming =>
      'Ödənişin təsdiqlənir. Bu bir neçə saniyə çəkə bilər.';

  @override
  String get paymentFailed =>
      'Ödəniş tamamlanmadı. Yenidən cəhd edə və ya başqa kart istifadə edə bilərsən.';

  @override
  String get refunded => 'Bu ödəniş geri qaytarıldı.';

  @override
  String get members => 'Üzvlər';

  @override
  String membersSemantics(int count, int max) {
    return '$count üzv, limit $max';
  }

  @override
  String limitMembers(String count) {
    return '$count üzv';
  }

  @override
  String limitEvents(String count) {
    return '$count tədbir / ay';
  }

  @override
  String limitLive(String count) {
    return '$count dəq canlı yayım / ay';
  }

  @override
  String planName(String plan) {
    return '$plan paket';
  }

  @override
  String planUntil(String plan, String date) {
    return '$plan paketi · $date tarixinədək';
  }

  @override
  String creditDays(String days) {
    return '$days gün';
  }

  @override
  String get termsTranslationNote =>
      'Bu tərcümə məlumat xarakterlidir. Bağlayıcı olan və təsdiqlədiyin müqavilə türkcə orijinaldır.';

  @override
  String get showOriginal => 'Türkcə orijinalı göstər';

  @override
  String get showTranslation => 'Tərcüməni göstər';

  @override
  String get planNameFree => 'Pulsuz';

  @override
  String get planNameStarter => 'Başlanğıc';

  @override
  String get planNameCommunity => 'İcma';
}
