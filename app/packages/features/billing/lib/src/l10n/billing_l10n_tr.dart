// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class BillingL10nTr extends BillingL10n {
  BillingL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get monthly => 'Aylık';

  @override
  String get yearly => 'Yıllık';

  @override
  String get perMonth => 'ay';

  @override
  String get perYear => 'yıl';

  @override
  String get notOnDevice => 'Bu işlem bu cihazda kullanılamıyor.';

  @override
  String get goBack => 'Geri dön';

  @override
  String get payment => 'Ödeme';

  @override
  String get planUnavailable => 'Bu paket şu anda satın alınamıyor.';

  @override
  String get backToPlans => 'Paketlere dön';

  @override
  String get paymentPageFailed =>
      'Ödeme sayfası açılamadı. Lütfen tekrar dene.';

  @override
  String get billingDetails => 'Fatura bilgileri';

  @override
  String get billingDetailsHint => 'Faturan bu bilgilerle düzenlenir.';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String fieldRequired(String field) {
    return '$field gerekli.';
  }

  @override
  String get phone => 'Telefon';

  @override
  String get phoneInvalid => 'Geçerli bir telefon numarası gir.';

  @override
  String get address => 'Adres';

  @override
  String get addressRequired => 'Fatura adresini gir.';

  @override
  String get city => 'Şehir';

  @override
  String get cityRequired => 'Şehri gir.';

  @override
  String get country => 'Ülke';

  @override
  String get countryRequired => 'Ülkeyi gir.';

  @override
  String get termsBefore => '';

  @override
  String get termsAfter => '\'ni okudum ve kabul ediyorum.';

  @override
  String get acceptTerms => 'Devam etmek için sözleşmeyi onaylamalısın.';

  @override
  String get billingDataUse =>
      'Fatura bilgilerin yalnızca ödemenin alınması, faturalandırma ve yasal saklama yükümlülükleri için kullanılır.';

  @override
  String payAmount(String amount) {
    return 'Ödemeye geç · $amount';
  }

  @override
  String get orderSummary => 'Sipariş özeti';

  @override
  String planPeriod(String plan, String period) {
    return '$plan paketi · $period';
  }

  @override
  String get start => 'Başlangıç';

  @override
  String get whenConfirmed => 'Ödeme onaylanınca';

  @override
  String get endEstimated => 'Bitiş (tahmini)';

  @override
  String get carriedOver => 'Aktarılan süre';

  @override
  String about(String value) {
    return 'yaklaşık $value';
  }

  @override
  String get total => 'Toplam';

  @override
  String assuranceTry(String provider) {
    return 'Ödeme $provider güvencesiyle Türk lirası olarak alınır. Kart bilgilerin GWAY\'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Ödeme $provider güvencesiyle ABD doları olarak alınır. Kart bilgilerin GWAY\'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.';
  }

  @override
  String get overLimit =>
      'Üye sayısı paketin limitini aşıyor. Limitin altına inilene kadar yeni üye alınamaz.';

  @override
  String get atLimit =>
      'Grup, paketinin üye limitine ulaştı. Yeni üye alınamaz.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max üye';
  }

  @override
  String get plan => 'Paket';

  @override
  String get getPlan => 'Paket al';

  @override
  String get upgradePlan => 'Paketi yükselt';

  @override
  String planEnds(String date) {
    return 'Paketin $date tarihinde bitiyor. Bitince grup Ücretsiz pakete döner.';
  }

  @override
  String get paymentReceivedPersonal => 'Ödeme alındı. Paketin açıldı.';

  @override
  String get planStatus => 'Paket durumu';

  @override
  String get notActive => 'Bu paket hesabında açık değil.';

  @override
  String activeUntil(String date) {
    return 'Paketin $date tarihine kadar açık.';
  }

  @override
  String get buy => 'Satın al';

  @override
  String get extend => 'Süreni uzat';

  @override
  String get oneTime => 'Tek seferlik ödeme; otomatik yenilenmez.';

  @override
  String newPeriodAfter(String date) {
    return 'Yeni süre, $date tarihinden sonra başlar.';
  }

  @override
  String get salesClosed =>
      'Bu paketin satışı şu anda kapalı. Lütfen daha sonra tekrar dene.';

  @override
  String continueAmount(String amount) {
    return 'Devam et · $amount';
  }

  @override
  String get personalOnly =>
      'Bu paket yalnızca seni kapsar; grubunun paketini etkilemez.';

  @override
  String saving(int percent) {
    return '%$percent avantajlı';
  }

  @override
  String untilDate(String date) {
    return '$date tarihine kadar';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Bu ürün şu anda satın alınamıyor.';

  @override
  String get personalProduct => 'Kişisel ürün';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Grubun hazır';

  @override
  String get freeStartBuy =>
      'Grubun Ücretsiz paketle başladı. Daha fazla üye, organizasyon ya da yayın dakikası gerekiyorsa aşağıdan bir paket seçebilirsin.';

  @override
  String get freeStartView =>
      'Grubun Ücretsiz paketle başladı. Paketlerin limitleri aşağıda.';

  @override
  String get continueFree => 'Ücretsiz ile devam et';

  @override
  String get goToGroup => 'Gruba git';

  @override
  String get paymentReceivedGroup => 'Ödeme alındı. Paketin etkin.';

  @override
  String get membersOnly =>
      'Grubun paketini yalnızca grubun üyeleri görebilir.';

  @override
  String get currentPlan => 'Mevcut paket';

  @override
  String get onFree => 'Grup ücretsiz paketi kullanıyor.';

  @override
  String periodEnds(String date) {
    return 'Bu dönem $date tarihinde bitiyor.';
  }

  @override
  String get overLimitLong =>
      'Üye sayısı paketin limitini aşıyor. Kimse gruptan çıkarılmaz, ama limitin altına inilene kadar yeni üye alınamaz.';

  @override
  String get atLimitLong =>
      'Grup üye limitine ulaştı. Yeni üye almak için daha büyük bir pakete geçebilirsin.';

  @override
  String get upcomingPeriods => 'Sıradaki dönemler';

  @override
  String get plans => 'Paketler';

  @override
  String get yearlyDeal => 'Yıllık · 2 ay bedava';

  @override
  String paymentNoteTry(String provider) {
    return 'Ödeme $provider ile Türk lirası olarak alınır; bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Ödeme $provider ile ABD doları olarak alınır; bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.';
  }

  @override
  String get paymentsOff =>
      'Ödeme şu anda alınamıyor. Lütfen daha sonra tekrar dene.';

  @override
  String get notNow => 'Şimdilik alınamaz';

  @override
  String get choose => 'Seç';

  @override
  String get upgrade => 'Yükselt';

  @override
  String get renew => 'Süreyi uzat';

  @override
  String get switchTo => 'Bu pakete geç';

  @override
  String get paidOverYear =>
      'Paketin bir yıldan uzun süre için ödenmiş. Şimdilik yalnızca üst pakete geçebilirsin.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Hemen başlar; kalan sürenden yaklaşık $credit eklenir. Bitiş: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Hemen başlar. Bitiş: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Mevcut dönemin ardından $date tarihinde başlar.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Mevcut dönem bitince, $date tarihinde başlar.';
  }

  @override
  String get confirmPending =>
      'Ödeme onayı henüz gelmedi. Ödemen alındıysa paketin birkaç dakika içinde etkinleşir; bu sayfayı sonra yenileyebilirsin.';

  @override
  String get confirming => 'Ödemen onaylanıyor. Bu birkaç saniye sürebilir.';

  @override
  String get paymentFailed =>
      'Ödeme tamamlanamadı. Tekrar deneyebilir ya da başka bir kart kullanabilirsin.';

  @override
  String get refunded => 'Bu ödeme iade edildi.';

  @override
  String get members => 'Üyeler';

  @override
  String membersSemantics(int count, int max) {
    return '$count üye, limit $max';
  }

  @override
  String limitMembers(String count) {
    return '$count üye';
  }

  @override
  String limitEvents(String count) {
    return '$count organizasyon / ay';
  }

  @override
  String limitLive(String count) {
    return '$count dk canlı yayın / ay';
  }

  @override
  String planName(String plan) {
    return '$plan paket';
  }

  @override
  String planUntil(String plan, String date) {
    return '$plan paketi · $date tarihine kadar';
  }

  @override
  String creditDays(String days) {
    return '$days gün';
  }
}
