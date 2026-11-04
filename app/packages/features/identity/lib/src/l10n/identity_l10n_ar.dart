// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class IdentityL10nAr extends IdentityL10n {
  IdentityL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authEmailNotConfirmed =>
      'لم تؤكّد بريدك الإلكتروني بعد. تحقّق من صندوق الوارد.';

  @override
  String get authEmailExists =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. جرّب تسجيل الدخول.';

  @override
  String get authWeakPassword =>
      'يجب أن تتكوّن كلمة المرور من 8 أحرف على الأقل وتتضمّن حرفًا كبيرًا وحرفًا صغيرًا ورقمًا.';

  @override
  String get authSamePassword => 'يجب أن تختلف كلمة المرور الجديدة عن القديمة.';

  @override
  String get authInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get authUserBanned => 'لا يمكنك تسجيل الدخول لأن حسابك معلّق.';

  @override
  String get authProviderDisabled => 'طريقة تسجيل الدخول هذه غير متاحة حاليًا.';

  @override
  String ageMinimum(int age) {
    return 'يجب أن يكون عمرك $age عامًا على الأقل لاستخدام GWAY.';
  }

  @override
  String get deletionPendingTitle => 'حسابك على وشك الحذف';

  @override
  String get deletionRequested => 'تلقّينا طلبك لحذف الحساب.';

  @override
  String deletionScheduled(String date) {
    return 'سيُحذف حسابك وجميع بياناتك نهائيًا في $date. يمكنك تغيير رأيك حتى ذلك الحين.';
  }

  @override
  String get undoDeletion => 'إلغاء الحذف';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get bannedTitle => 'أُغلق حسابك نهائيًا';

  @override
  String get suspendedTitle => 'تم تعليق حسابك';

  @override
  String get bannedBody =>
      'أغلق فريق المنصة حسابك نهائيًا. لم يعد ملفك الشخصي ظاهرًا لأي أحد.';

  @override
  String suspendedBody(String date) {
    return 'حسابك معلّق حتى $date. لا يمكنك استخدام التطبيق خلال هذه المدة، ويظهر التعليق في ملفك الشخصي.';
  }

  @override
  String banReason(String reason) {
    return 'سبب الحظر: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'سبب التعليق: $reason';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get beforeDeleting => 'قبل حذف حسابك';

  @override
  String get deletionHidesNow =>
      'يُخفى ملفك الشخصي فورًا، ولن يتمكّن أحد من العثور عليك.';

  @override
  String deletionGraceRestore(int days) {
    return 'يمكنك تسجيل الدخول خلال $days يومًا وإلغاء الحذف.';
  }

  @override
  String get deletionAfterGrace =>
      'بعد ذلك تُحذف بيانات ملفك الشخصي وصورك وجميع بياناتك نهائيًا.';

  @override
  String get deletionUnderstood => 'فهمت، أريد حذف حسابي.';

  @override
  String get deleteMyAccount => 'حذف حسابي';

  @override
  String get heroTitle => 'مجتمعك بانتظارك.';

  @override
  String get heroBody =>
      'من المشي إلى الموسيقى، ومن الجري إلى الفن: اعثر على مجموعتك، خطّطوا معًا وكونوا هناك في الوقت نفسه.';

  @override
  String get heroPointGroups => 'انضم إلى المجموعات أو أنشئ مجتمعك الخاص';

  @override
  String get heroPointEvents => 'أضف الفعاليات إلى تقويمك واعثر على زملاء فريق';

  @override
  String get heroPointLive => 'التقِ بمجموعتك في محادثات صوتية مباشرة';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInSubtitle => 'تابع من حيث توقّفت مع مجموعاتك وأصدقائك.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get continueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get noAccountSignUp => 'ليس لديك حساب؟ أنشئ حسابًا';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signUpSubtitle =>
      'اعثر على مجموعاتك وشارك في الفعاليات وتعرّف إلى أشخاص جدد.';

  @override
  String get passwordRepeat => 'تأكيد كلمة المرور';

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get haveAccountSignIn => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get checkEmailTitle => 'تحقّق من بريدك الإلكتروني';

  @override
  String checkEmailBody(String email) {
    return 'أرسلنا رابط تحقّق إلى $email. يمكنك تسجيل الدخول بعد النقر على الرابط.';
  }

  @override
  String get linkResent => 'أعدنا إرسال الرابط.';

  @override
  String get backToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get resendLink => 'إعادة إرسال الرابط';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل إليك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get resetLinkSent =>
      'إذا كان هناك حساب مسجّل بهذا العنوان، فقد أرسلنا رابط إعادة التعيين.';

  @override
  String get sendLink => 'إرسال الرابط';

  @override
  String get newPasswordTitle => 'عيّن كلمة مرور جديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get newPasswordRepeat => 'تأكيد كلمة المرور الجديدة';

  @override
  String get savePassword => 'حفظ كلمة المرور';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني.';

  @override
  String get passwordMin8 => 'يجب أن تتكوّن كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get passwordMix =>
      'يجب أن تتضمّن كلمة المرور حرفًا كبيرًا وحرفًا صغيرًا ورقمًا.';

  @override
  String get enterPassword => 'أدخل كلمة المرور.';

  @override
  String get birthDateTitle => 'تاريخ ميلادك';

  @override
  String get chooseBirthDate => 'اختر تاريخ ميلادك.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY مخصّص لمن هم في عمر $age عامًا فأكثر. لا يُعرض تاريخ ميلادك لأي أحد ولا يمكن تغييره لاحقًا.';
  }

  @override
  String get chooseDate => 'اختر تاريخًا';

  @override
  String get continueAction => 'متابعة';

  @override
  String get agreeTerms => 'قرأت شروط الاستخدام وأوافق عليها.';

  @override
  String get agreePrivacy => 'قرأت إشعار الخصوصية (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'أمنح موافقتي الصريحة على معالجة بياناتي الشخصية على خوادم خارج تركيا.';

  @override
  String get agreeCommunityRules =>
      'قرأت اتفاقية قواعد المجتمع والعقوبات والإجراءات القانونية وأوافق عليها.';

  @override
  String get agreeDistanceSales => 'قرأت عقد البيع عن بُعد وأوافق عليه.';

  @override
  String get readAndAccept => 'قرأت وأوافق';

  @override
  String get readWholeText => 'يُرجى قراءة النص كاملًا قبل الموافقة.';

  @override
  String get beforeContinue => 'قبل المتابعة';

  @override
  String get consentIntro => 'لاستخدام GWAY، اقرأ النصوص أدناه ووافق عليها.';

  @override
  String get readText => 'اقرأ النص';

  @override
  String get readToEnd => 'اقرأ النص حتى نهايته للموافقة عليه.';

  @override
  String versionLabel(int version) {
    return 'الإصدار $version';
  }

  @override
  String get legalDocuments => 'المستندات القانونية';

  @override
  String get documentNotPublished => 'هذا النص غير منشور حاليًا.';

  @override
  String get deletionInfoTitle => 'حذف حسابك في GWAY';

  @override
  String get deletionInfoIntro =>
      'يمكنك حذف حسابك وبياناتك من التطبيق أو من هذا الموقع:';

  @override
  String get deletionInfoStep1 => 'سجّل الدخول إلى تطبيق GWAY أو موقعه.';

  @override
  String get deletionInfoStep2 => 'انتقل إلى أنا ← الإعدادات ← حذف الحساب.';

  @override
  String get deletionInfoStep3 => 'أكّد الحذف. يُخفى ملفك الشخصي فورًا.';

  @override
  String get deletionInfoWhat => 'ما الذي يُحذف وما الذي يُحتفظ به؟';

  @override
  String deletionInfoBody(int days) {
    return 'يمكنك تسجيل الدخول خلال $days يومًا وإلغاء الحذف. بعد انقضاء المدة تُحذف نهائيًا بيانات ملفك الشخصي ومنشوراتك وصورك ورسائلك وعضوياتك في المجموعات وسجلات التحقّق من الموقع وبيانات التحقّق. تُحفظ سجلات الدفع الخاضعة لالتزام قانوني بالحفظ وسجلات العمليات المجهولة الهوية طوال المدة التي يحدّدها القانون. وفي الحسابات المغلقة لأسباب أمنية يُحتفظ برقم الهاتف لمنع فتح حساب جديد بالرقم نفسه.';
  }

  @override
  String get securityTitle => 'التحقّق الأمني';

  @override
  String get securityChecking => 'جارٍ التحقّق الأمني';

  @override
  String get securityWarning =>
      'تم رصد موقعك والهاتف الذي تستخدمه وشبكة VPN. يُرجى الالتزام بقواعد البلد الذي توجد فيه وتسجيل الدخول بشكل آمن.';

  @override
  String get vpnInstalledWarning =>
      'تم رصد تطبيق VPN على جهازك. يُرجى الالتزام بقواعد البلد الذي توجد فيه وتسجيل الدخول بشكل آمن.';

  @override
  String get securityWarningTitle => 'تحذير أمني';

  @override
  String get understood => 'فهمت';

  @override
  String get passkeyNotAdded =>
      'لم تُضف البصمة: أُلغيت العملية أو أن هذا الجهاز مسجّل بالفعل.';

  @override
  String get locationDeniedForever =>
      'سبق أن رفضت إذن الموقع. فعّل إذن الموقع لتطبيق GWAY من إعدادات الجهاز ثم حاول مرة أخرى.';

  @override
  String get locationRequired => 'لا يمكنك المتابعة دون إذن الموقع.';

  @override
  String get locationServiceOff =>
      'خدمة الموقع متوقّفة على جهازك. شغّلها ثم حاول مرة أخرى.';

  @override
  String get locationTitle => 'لنتحقّق من موقعك';

  @override
  String get locationBody =>
      'لأمان الحساب ومنع الحسابات المزيّفة، يستخدم GWAY موقعك عند تسجيل الدخول وفتح التطبيق. لا يُفتح التطبيق دون إذن الموقع.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get grantLocation => 'السماح بالوصول إلى الموقع';

  @override
  String get readPrivacyNotice => 'اقرأ إشعار الخصوصية';

  @override
  String get privacyNoticeUnavailable => 'تعذّر تحميل إشعار الخصوصية حاليًا.';

  @override
  String get enterMobileNumber => 'أدخل رقم هاتفك المحمول.';

  @override
  String get speedUpTitle => 'سجّل الدخول أسرع';

  @override
  String get speedUpBodyPasskey =>
      'في المرة القادمة، تحقّق ببصمتك أو برمز Google Authenticator بدل انتظار رسالة SMS.';

  @override
  String get speedUpBodyTotp =>
      'في المرة القادمة، تحقّق برمز Google Authenticator بدل انتظار رسالة SMS.';

  @override
  String get addFingerprint => 'إضافة بصمة';

  @override
  String get addAuthenticator => 'إضافة Google Authenticator';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get fingerprintAdded => 'تمت إضافة البصمة.';

  @override
  String get verifyPhoneTitle => 'تحقّق من هاتفك';

  @override
  String get verifyPhoneBody =>
      'تحقّق برقم هاتف محمول من البلد الذي توجد فيه. لا يُعرض رقمك للآخرين أبدًا.';

  @override
  String get mobilePhone => 'الهاتف المحمول';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get verify => 'تحقّق';

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة إرسال الرمز ($seconds ث)';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get passkeyFailed =>
      'أُلغي التحقّق أو لا توجد بصمة مسجّلة على هذا الجهاز. يمكنك اختيار طريقة أخرى.';

  @override
  String get verifySignInTitle => 'تحقّق من تسجيل الدخول';

  @override
  String get verifyWithPasskey =>
      'تحقّق من تسجيل الدخول ببصمة هذا الجهاز أو التعرّف على الوجه أو قفل الشاشة.';

  @override
  String get verifyWithTotp =>
      'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.';

  @override
  String smsWillSendTo(String phone) {
    return 'لأمانك، عليك التحقّق من تسجيل الدخول هذا. سنرسل رمزًا إلى $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'لأمانك، عليك التحقّق من تسجيل الدخول هذا. سنرسل رمزًا إلى رقمك المسجّل.';

  @override
  String get methodFingerprint => 'البصمة';

  @override
  String get methodApp => 'التطبيق';

  @override
  String get verifyWithFingerprint => 'التحقّق بالبصمة';

  @override
  String get reviewTitle => 'تعذّر تسجيل الدخول بأمان';

  @override
  String get reviewBody =>
      'حسابك قيد المراجعة الأمنية. عند انتهاء المراجعة يمكنك المتابعة من حيث توقّفت.';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get removeTotpTitle => 'إزالة تطبيق المصادقة';

  @override
  String get removeTotpBody =>
      'من الآن فصاعدًا يمكنك التحقّق من عمليات الدخول الجديدة برمز SMS فقط.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'إزالة';

  @override
  String get totpRemoved => 'تمت إزالة تطبيق المصادقة.';

  @override
  String get twoFactorTitle => 'التحقّق بخطوتين';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get notVerifiedYet => 'لم يتم التحقّق بعد';

  @override
  String get authenticatorApp => 'تطبيق المصادقة';

  @override
  String get totpOn =>
      'مفعّل. يمكنك أيضًا التحقّق من عمليات الدخول الجديدة بالرمز في التطبيق.';

  @override
  String get totpOff =>
      'سجّل الدخول دون انتظار رسالة SMS باستخدام تطبيق مثل Google Authenticator.';

  @override
  String get addTotp => 'إضافة تطبيق مصادقة';

  @override
  String get signInRequired => 'عليك تسجيل الدخول.';

  @override
  String passkeyRemoved(String name) {
    return 'تمت إزالة $name.';
  }

  @override
  String get passkeysTitle => 'البصمة والتعرّف على الوجه';

  @override
  String get passkeysOff =>
      'تحقّق من عمليات الدخول ببصمة جهازك أو التعرّف على الوجه أو قفل الشاشة.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهازًا مسجّلًا.',
      few: '$count أجهزة مسجّلة.',
      two: 'جهازان مسجّلان.',
      one: 'جهاز واحد مسجّل.',
    );
    return '$_temp0 تُطلب هذه الطريقة أولًا عند تسجيل الدخول.';
  }

  @override
  String get notUsedYet => 'لم يُستخدم بعد';

  @override
  String lastUsed(String date) {
    return 'آخر استخدام: $date';
  }

  @override
  String get addFingerprintHere => 'إضافة بصمة على هذا الجهاز';

  @override
  String get passkeyUnsupported =>
      'لا يدعم هذا الجهاز أو المتصفح تسجيل الدخول بالبصمة.';

  @override
  String passkeyDefaultName(String date) {
    return 'بصمة · $date';
  }

  @override
  String get totpAdded => 'تمت إضافة تطبيق المصادقة.';

  @override
  String get totpStep1 =>
      '1. أضف حسابًا جديدًا في تطبيق المصادقة وامسح هذا الرمز. إذا كنت على الهاتف نفسه فانقر «فتح في التطبيق» أو أدخل المفتاح يدويًا.';

  @override
  String get copyKey => 'نسخ المفتاح';

  @override
  String get openInApp => 'فتح في التطبيق';

  @override
  String get totpStep2 => '2. أدخل الرمز المكوّن من 6 أرقام الظاهر في التطبيق.';

  @override
  String get activate => 'تفعيل';

  @override
  String get codeHint => 'رمز من 6 أرقام';

  @override
  String get enterCode => 'أدخل الرمز المكوّن من 6 أرقام.';

  @override
  String get enterSmsCode =>
      'أدخل الرمز المكوّن من 6 أرقام الوارد في رسالة SMS.';

  @override
  String get enterAppCode => 'أدخل الرمز المكوّن من 6 أرقام من التطبيق.';

  @override
  String get refresh => 'تحديث';

  @override
  String get language => 'اللغة';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get languageNote =>
      'تظهر القوائم والأزرار والإشعارات والاتفاقيات بهذه اللغة. تبقى المنشورات والتعليقات والرسائل باللغة التي كُتبت بها.';

  @override
  String get or => 'أو';
}
