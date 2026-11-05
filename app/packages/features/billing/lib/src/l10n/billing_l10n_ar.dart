// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class BillingL10nAr extends BillingL10n {
  BillingL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get perMonth => 'شهر';

  @override
  String get perYear => 'سنة';

  @override
  String get notOnDevice => 'غير متاح على هذا الجهاز.';

  @override
  String get goBack => 'رجوع';

  @override
  String get payment => 'الدفع';

  @override
  String get planUnavailable => 'لا يمكن شراء هذه الباقة الآن.';

  @override
  String get backToPlans => 'العودة إلى الباقات';

  @override
  String get paymentPageFailed => 'تعذّر فتح صفحة الدفع. حاول مرة أخرى.';

  @override
  String get billingDetails => 'بيانات الفوترة';

  @override
  String get billingDetailsHint => 'تصدر فاتورتك بهذه البيانات.';

  @override
  String get firstName => 'الاسم';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String fieldRequired(String field) {
    return '$field مطلوب.';
  }

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneInvalid => 'أدخل رقم هاتف صحيحًا.';

  @override
  String get address => 'العنوان';

  @override
  String get addressRequired => 'أدخل عنوان الفوترة.';

  @override
  String get city => 'المدينة';

  @override
  String get cityRequired => 'أدخل المدينة.';

  @override
  String get country => 'الدولة';

  @override
  String get countryRequired => 'أدخل الدولة.';

  @override
  String get termsBefore => 'قرأت ';

  @override
  String get termsAfter => ' وأوافق عليها.';

  @override
  String get acceptTerms => 'وافق على العقد للمتابعة.';

  @override
  String get billingDataUse =>
      'تُستخدم بيانات الفوترة فقط لتحصيل الدفع وإصدار الفاتورة والوفاء بالتزامات الحفظ القانونية.';

  @override
  String payAmount(String amount) {
    return 'المتابعة إلى الدفع · $amount';
  }

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String planPeriod(String plan, String period) {
    return 'باقة $plan · $period';
  }

  @override
  String get start => 'البداية';

  @override
  String get whenConfirmed => 'عند تأكيد الدفع';

  @override
  String get endEstimated => 'النهاية (تقديرية)';

  @override
  String get carriedOver => 'المدة المنقولة';

  @override
  String about(String value) {
    return 'حوالي $value';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String assuranceTry(String provider) {
    return 'يتم الدفع بأمان عبر $provider بالليرة التركية. لا تصل بيانات بطاقتك إلى GWAY. دفعة لمرة واحدة دون تجديد تلقائي.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'يتم الدفع بأمان عبر $provider بالدولار الأمريكي. لا تصل بيانات بطاقتك إلى GWAY. دفعة لمرة واحدة دون تجديد تلقائي.';
  }

  @override
  String get overLimit =>
      'عدد الأعضاء يتجاوز حدّ الباقة. لا يمكن قبول أعضاء جدد حتى ينخفض عن الحد.';

  @override
  String get atLimit =>
      'بلغت المجموعة حدّ الأعضاء في باقتها. لا يمكن قبول أعضاء جدد.';

  @override
  String membersOfMax(String count, String max) {
    return 'الأعضاء: $count / $max';
  }

  @override
  String get plan => 'الباقة';

  @override
  String get getPlan => 'احصل على باقة';

  @override
  String get upgradePlan => 'ترقية الباقة';

  @override
  String planEnds(String date) {
    return 'تنتهي باقتك في $date. بعدها تعود المجموعة إلى الباقة المجانية.';
  }

  @override
  String get paymentReceivedPersonal => 'تم استلام الدفع. باقتك مفعّلة.';

  @override
  String get planStatus => 'حالة الباقة';

  @override
  String get notActive => 'هذه الباقة غير مفعّلة على حسابك.';

  @override
  String activeUntil(String date) {
    return 'باقتك مفعّلة حتى $date.';
  }

  @override
  String get buy => 'شراء';

  @override
  String get extend => 'تمديد';

  @override
  String get oneTime => 'دفعة لمرة واحدة؛ لا تتجدد تلقائيًا.';

  @override
  String newPeriodAfter(String date) {
    return 'تبدأ المدة الجديدة بعد $date.';
  }

  @override
  String get salesClosed => 'بيع هذه الباقة مغلق حاليًا. حاول لاحقًا.';

  @override
  String continueAmount(String amount) {
    return 'متابعة · $amount';
  }

  @override
  String get personalOnly => 'تشملك هذه الباقة وحدك ولا تؤثر في باقة مجموعتك.';

  @override
  String saving(int percent) {
    return 'وفّر $percent٪';
  }

  @override
  String untilDate(String date) {
    return 'حتى $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'لا يمكن شراء هذا المنتج الآن.';

  @override
  String get personalProduct => 'منتج شخصي';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'مجموعتك جاهزة';

  @override
  String get freeStartBuy =>
      'بدأت مجموعتك بالباقة المجانية. إن احتجت مزيدًا من الأعضاء أو الفعاليات أو دقائق البث، اختر باقة أدناه.';

  @override
  String get freeStartView =>
      'بدأت مجموعتك بالباقة المجانية. حدود الباقات أدناه.';

  @override
  String get continueFree => 'المتابعة مجانًا';

  @override
  String get goToGroup => 'الانتقال إلى المجموعة';

  @override
  String get paymentReceivedGroup => 'تم استلام الدفع. باقتك فعّالة.';

  @override
  String get membersOnly => 'لا يرى باقة المجموعة إلا أعضاؤها.';

  @override
  String get currentPlan => 'الباقة الحالية';

  @override
  String get onFree => 'تستخدم المجموعة الباقة المجانية.';

  @override
  String periodEnds(String date) {
    return 'تنتهي هذه المدة في $date.';
  }

  @override
  String get overLimitLong =>
      'عدد الأعضاء يتجاوز الحد. لن يُخرَج أحد، لكن لا يمكن قبول أعضاء جدد حتى ينخفض العدد.';

  @override
  String get atLimitLong =>
      'بلغت المجموعة حدّ الأعضاء. انتقل إلى باقة أكبر لقبول أعضاء جدد.';

  @override
  String get upcomingPeriods => 'المدد القادمة';

  @override
  String get plans => 'الباقات';

  @override
  String get yearlyDeal => 'سنوي · شهران مجانًا';

  @override
  String paymentNoteTry(String provider) {
    return 'يتم الدفع عبر $provider بالليرة التركية حسب بلدك. لا تجديد تلقائي.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'يتم الدفع عبر $provider بالدولار الأمريكي حسب بلدك. لا تجديد تلقائي.';
  }

  @override
  String get paymentsOff => 'لا يمكن استلام المدفوعات الآن. حاول لاحقًا.';

  @override
  String get notNow => 'غير متاح حاليًا';

  @override
  String get choose => 'اختيار';

  @override
  String get upgrade => 'ترقية';

  @override
  String get renew => 'تمديد المدة';

  @override
  String get switchTo => 'الانتقال إلى هذه الباقة';

  @override
  String get paidOverYear =>
      'باقتك مدفوعة لأكثر من سنة. يمكنك الترقية فقط حاليًا.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'يبدأ فورًا؛ ويُضاف نحو $credit من مدتك المتبقية. النهاية: $date.';
  }

  @override
  String startsNow(String date) {
    return 'يبدأ فورًا. النهاية: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'يبدأ في $date بعد المدة الحالية.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'يبدأ في $date عند انتهاء المدة الحالية.';
  }

  @override
  String get confirmPending =>
      'لم يصل تأكيد الدفع بعد. إن خُصم المبلغ فستُفعَّل باقتك خلال دقائق؛ يمكنك تحديث الصفحة لاحقًا.';

  @override
  String get confirming => 'جارٍ تأكيد دفعتك. قد يستغرق ذلك بضع ثوانٍ.';

  @override
  String get paymentFailed =>
      'تعذّر إتمام الدفع. حاول مرة أخرى أو استخدم بطاقة أخرى.';

  @override
  String get refunded => 'تم ردّ هذه الدفعة.';

  @override
  String get members => 'الأعضاء';

  @override
  String membersSemantics(int count, int max) {
    return 'الأعضاء: $count، الحد $max';
  }

  @override
  String limitMembers(String count) {
    return 'الأعضاء: $count';
  }

  @override
  String limitEvents(String count) {
    return 'الفعاليات: $count / شهر';
  }

  @override
  String limitLive(String count) {
    return 'البث المباشر: $count دقيقة / شهر';
  }

  @override
  String planName(String plan) {
    return 'باقة $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'باقة $plan · حتى $date';
  }

  @override
  String creditDays(String days) {
    return '$days يوم';
  }
}
