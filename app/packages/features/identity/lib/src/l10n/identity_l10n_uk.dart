// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class IdentityL10nUk extends IdentityL10n {
  IdentityL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'Неправильна електронна адреса або пароль.';

  @override
  String get authEmailNotConfirmed =>
      'Ви ще не підтвердили електронну адресу. Перевірте вхідні.';

  @override
  String get authEmailExists =>
      'Обліковий запис із цією адресою вже існує. Спробуйте увійти.';

  @override
  String get authWeakPassword =>
      'Пароль має містити щонайменше 8 символів, велику й малу літери та цифру.';

  @override
  String get authSamePassword => 'Новий пароль має відрізнятися від старого.';

  @override
  String get authInvalidEmail => 'Введіть дійсну електронну адресу.';

  @override
  String get authUserBanned =>
      'Ви не можете увійти: ваш обліковий запис призупинено.';

  @override
  String get authProviderDisabled => 'Цей спосіб входу зараз недоступний.';

  @override
  String ageMinimum(int age) {
    return 'Щоб користуватися GWAY, вам має бути щонайменше $age років.';
  }

  @override
  String get deletionPendingTitle => 'Ваш обліковий запис скоро буде видалено';

  @override
  String get deletionRequested =>
      'Ми отримали ваш запит на видалення облікового запису.';

  @override
  String deletionScheduled(String date) {
    return 'Ваш обліковий запис і всі дані буде остаточно видалено $date. До того часу ви можете передумати.';
  }

  @override
  String get undoDeletion => 'Скасувати видалення';

  @override
  String get signOut => 'Вийти';

  @override
  String get bannedTitle => 'Ваш обліковий запис закрито назавжди';

  @override
  String get suspendedTitle => 'Ваш обліковий запис призупинено';

  @override
  String get bannedBody =>
      'Команда платформи назавжди закрила ваш обліковий запис. Ваш профіль більше нікому не видно.';

  @override
  String suspendedBody(String date) {
    return 'Ваш обліковий запис призупинено до $date. У цей час ви не можете користуватися застосунком; у профілі видно призупинення.';
  }

  @override
  String banReason(String reason) {
    return 'Причина блокування: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Причина призупинення: $reason';
  }

  @override
  String get retry => 'Повторити';

  @override
  String get deleteAccount => 'Видалити обліковий запис';

  @override
  String get beforeDeleting => 'Перед видаленням облікового запису';

  @override
  String get deletionHidesNow =>
      'Ваш профіль одразу приховується — ніхто не зможе вас знайти.';

  @override
  String deletionGraceRestore(int days) {
    return 'Протягом $days днів ви можете увійти й скасувати видалення.';
  }

  @override
  String get deletionAfterGrace =>
      'Після цього ваш профіль, фото й усі дані видаляються остаточно.';

  @override
  String get deletionUnderstood =>
      'Зрозуміло, я хочу видалити обліковий запис.';

  @override
  String get deleteMyAccount => 'Видалити мій обліковий запис';

  @override
  String get heroTitle => 'Ваша спільнота чекає на вас.';

  @override
  String get heroBody =>
      'Від походів до музики, від бігу до мистецтва: знайдіть свою групу, плануйте разом і будьте там водночас.';

  @override
  String get heroPointGroups =>
      'Приєднуйтеся до груп або створіть власну спільноту';

  @override
  String get heroPointEvents =>
      'Додавайте події до календаря й знаходьте напарників';

  @override
  String get heroPointLive => 'Спілкуйтеся з групою в живих аудіочатах';

  @override
  String get showPassword => 'Показати пароль';

  @override
  String get hidePassword => 'Приховати пароль';

  @override
  String get signIn => 'Увійти';

  @override
  String get signInSubtitle =>
      'Продовжуйте з того місця, де зупинилися, — з групами й друзями.';

  @override
  String get email => 'Електронна пошта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get continueWithGoogle => 'Продовжити з Google';

  @override
  String get continueWithApple => 'Продовжити з Apple';

  @override
  String get noAccountSignUp => 'Немає облікового запису? Зареєструйтеся';

  @override
  String get signUp => 'Зареєструватися';

  @override
  String get signUpSubtitle =>
      'Знаходьте групи, долучайтеся до подій і знайомтеся з новими людьми.';

  @override
  String get passwordRepeat => 'Повторіть пароль';

  @override
  String get passwordsDontMatch => 'Паролі не збігаються.';

  @override
  String get haveAccountSignIn => 'Уже маєте обліковий запис? Увійдіть';

  @override
  String get checkEmailTitle => 'Перевірте пошту';

  @override
  String checkEmailBody(String email) {
    return 'Ми надіслали посилання для підтвердження на $email. Після переходу за посиланням ви зможете увійти.';
  }

  @override
  String get linkResent => 'Ми надіслали посилання ще раз.';

  @override
  String get backToSignIn => 'Повернутися до входу';

  @override
  String get resendLink => 'Надіслати посилання ще раз';

  @override
  String get resetPasswordTitle => 'Скидання пароля';

  @override
  String get resetPasswordSubtitle =>
      'Введіть електронну адресу, і ми надішлемо посилання для скидання пароля.';

  @override
  String get resetLinkSent =>
      'Якщо для цієї адреси є обліковий запис, ми надіслали посилання для скидання.';

  @override
  String get sendLink => 'Надіслати посилання';

  @override
  String get newPasswordTitle => 'Установіть новий пароль';

  @override
  String get newPassword => 'Новий пароль';

  @override
  String get newPasswordRepeat => 'Повторіть новий пароль';

  @override
  String get savePassword => 'Зберегти пароль';

  @override
  String get enterEmail => 'Введіть електронну адресу.';

  @override
  String get passwordMin8 => 'Пароль має містити щонайменше 8 символів.';

  @override
  String get passwordMix => 'Пароль має містити велику й малу літери та цифру.';

  @override
  String get enterPassword => 'Введіть пароль.';

  @override
  String get birthDateTitle => 'Дата народження';

  @override
  String get chooseBirthDate => 'Виберіть дату народження.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY призначено для людей від $age років. Дату народження нікому не показують, і її не можна змінити згодом.';
  }

  @override
  String get chooseDate => 'Вибрати дату';

  @override
  String get continueAction => 'Продовжити';

  @override
  String get agreeTerms => 'Я прочитав(-ла) і приймаю Умови використання.';

  @override
  String get agreePrivacy =>
      'Я прочитав(-ла) Повідомлення про конфіденційність (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Я надаю явну згоду на обробку моїх персональних даних на серверах за межами Туреччини.';

  @override
  String get agreeCommunityRules =>
      'Я прочитав(-ла) і приймаю Угоду про правила спільноти, санкції та правові заходи.';

  @override
  String get agreeDistanceSales =>
      'Я прочитав(-ла) і приймаю Договір дистанційного продажу.';

  @override
  String get readAndAccept => 'Прочитав(-ла) і приймаю';

  @override
  String get readWholeText =>
      'Будь ласка, прочитайте текст повністю, перш ніж прийняти.';

  @override
  String get beforeContinue => 'Перш ніж продовжити';

  @override
  String get consentIntro =>
      'Щоб користуватися GWAY, прочитайте й прийміть тексти нижче.';

  @override
  String get readText => 'Прочитати текст';

  @override
  String get readToEnd => 'Щоб прийняти, дочитайте текст до кінця.';

  @override
  String versionLabel(int version) {
    return 'Версія $version';
  }

  @override
  String get legalDocuments => 'Юридичні документи';

  @override
  String get documentNotPublished => 'Цей текст зараз не опубліковано.';

  @override
  String get deletionInfoTitle => 'Видалення облікового запису GWAY';

  @override
  String get deletionInfoIntro =>
      'Видалити обліковий запис і дані можна в застосунку або на цьому сайті:';

  @override
  String get deletionInfoStep1 => 'Увійдіть у застосунок або на сайт GWAY.';

  @override
  String get deletionInfoStep2 =>
      'Відкрийте Я → Налаштування → Видалити обліковий запис.';

  @override
  String get deletionInfoStep3 =>
      'Підтвердьте видалення. Профіль одразу приховується.';

  @override
  String get deletionInfoWhat => 'Що видаляється, а що зберігається?';

  @override
  String deletionInfoBody(int days) {
    return 'Протягом $days днів ви можете увійти й скасувати видалення. Після цього ваш профіль, дописи, фото, повідомлення, членство в групах, записи перевірки місцезнаходження та дані верифікації видаляються остаточно. Платіжні записи, які закон зобов’язує зберігати, і знеособлені журнали операцій зберігаються протягом визначеного законом строку. Для облікових записів, закритих із міркувань безпеки, номер телефону зберігається, щоб на нього не можна було відкрити новий обліковий запис.';
  }

  @override
  String get securityTitle => 'Перевірка безпеки';

  @override
  String get securityChecking => 'Перевіряємо безпеку';

  @override
  String get securityWarning =>
      'Виявлено ваше місцезнаходження, телефон, яким ви користуєтеся, і VPN. Будь ласка, дотримуйтеся правил країни, у якій ви перебуваєте, і увійдіть безпечно.';

  @override
  String get vpnInstalledWarning =>
      'На вашому пристрої виявлено VPN-застосунок. Будь ласка, дотримуйтеся правил країни, у якій ви перебуваєте, і увійдіть безпечно.';

  @override
  String get securityWarningTitle => 'Попередження безпеки';

  @override
  String get understood => 'Зрозуміло';

  @override
  String get passkeyNotAdded =>
      'Відбиток не додано: дію скасовано або цей пристрій уже зареєстровано.';

  @override
  String get locationDeniedForever =>
      'Раніше ви заборонили доступ до геолокації. Увімкніть його для GWAY у налаштуваннях пристрою та спробуйте ще раз.';

  @override
  String get locationRequired =>
      'Без доступу до геолокації продовжити не можна.';

  @override
  String get locationServiceOff =>
      'Служби геолокації на пристрої вимкнено. Увімкніть їх і спробуйте ще раз.';

  @override
  String get locationTitle => 'Підтвердьмо ваше місцезнаходження';

  @override
  String get locationBody =>
      'Для безпеки облікового запису й захисту від фейків GWAY використовує ваше місцезнаходження під час входу та відкриття застосунку. Без доступу до геолокації застосунок не відкриється.';

  @override
  String get openSettings => 'Відкрити налаштування';

  @override
  String get grantLocation => 'Дозволити доступ до геолокації';

  @override
  String get readPrivacyNotice => 'Прочитати повідомлення про конфіденційність';

  @override
  String get privacyNoticeUnavailable =>
      'Не вдалося завантажити повідомлення про конфіденційність.';

  @override
  String get enterMobileNumber => 'Введіть номер мобільного телефону.';

  @override
  String get speedUpTitle => 'Входьте швидше';

  @override
  String get speedUpBodyPasskey =>
      'Наступного разу підтверджуйте вхід відбитком пальця або кодом Google Authenticator, не чекаючи SMS.';

  @override
  String get speedUpBodyTotp =>
      'Наступного разу підтверджуйте вхід кодом Google Authenticator, не чекаючи SMS.';

  @override
  String get addFingerprint => 'Додати відбиток';

  @override
  String get addAuthenticator => 'Додати Google Authenticator';

  @override
  String get notNow => 'Не зараз';

  @override
  String get fingerprintAdded => 'Відбиток додано.';

  @override
  String get verifyPhoneTitle => 'Підтвердьте телефон';

  @override
  String get verifyPhoneBody =>
      'Підтвердьте номером мобільного телефону країни, у якій ви перебуваєте. Ваш номер нікому не показують.';

  @override
  String get mobilePhone => 'Мобільний телефон';

  @override
  String get sendCode => 'Надіслати код';

  @override
  String get verify => 'Підтвердити';

  @override
  String resendCodeIn(int seconds) {
    return 'Надіслати код ще раз ($seconds с)';
  }

  @override
  String get resendCode => 'Надіслати код ще раз';

  @override
  String get changeNumber => 'Змінити номер';

  @override
  String get passkeyFailed =>
      'Підтвердження скасовано або на цьому пристрої немає зареєстрованого відбитка. Виберіть інший спосіб.';

  @override
  String get verifySignInTitle => 'Підтвердьте вхід';

  @override
  String get verifyWithPasskey =>
      'Підтвердьте вхід відбитком пальця, розпізнаванням обличчя або блокуванням екрана цього пристрою.';

  @override
  String get verifyWithTotp =>
      'Введіть 6-значний код із застосунку-автентифікатора.';

  @override
  String smsWillSendTo(String phone) {
    return 'Для вашої безпеки потрібно підтвердити цей вхід. Ми надішлемо код на номер $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Для вашої безпеки потрібно підтвердити цей вхід. Ми надішлемо код на збережений номер.';

  @override
  String get methodFingerprint => 'Відбиток';

  @override
  String get methodApp => 'Застосунок';

  @override
  String get verifyWithFingerprint => 'Підтвердити відбитком';

  @override
  String get reviewTitle => 'Не вдалося безпечно увійти';

  @override
  String get reviewBody =>
      'Ваш обліковий запис проходить перевірку безпеки. Коли вона завершиться, ви зможете продовжити з того самого місця.';

  @override
  String get refreshStatus => 'Оновити статус';

  @override
  String get removeTotpTitle => 'Видалити застосунок-автентифікатор';

  @override
  String get removeTotpBody =>
      'Відтепер нові входи можна буде підтверджувати лише кодом із SMS.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get remove => 'Видалити';

  @override
  String get totpRemoved => 'Застосунок-автентифікатор видалено.';

  @override
  String get twoFactorTitle => 'Двоетапна перевірка';

  @override
  String get phoneNumber => 'Номер телефону';

  @override
  String get notVerifiedYet => 'Ще не підтверджено';

  @override
  String get authenticatorApp => 'Застосунок-автентифікатор';

  @override
  String get totpOn =>
      'Увімкнено. Нові входи можна підтверджувати й кодом із застосунку.';

  @override
  String get totpOff =>
      'Входьте без очікування SMS за допомогою застосунку, як-от Google Authenticator.';

  @override
  String get addTotp => 'Додати застосунок-автентифікатор';

  @override
  String get signInRequired => 'Потрібно увійти.';

  @override
  String passkeyRemoved(String name) {
    return '$name: видалено.';
  }

  @override
  String get passkeysTitle => 'Відбиток пальця й розпізнавання обличчя';

  @override
  String get passkeysOff =>
      'Підтверджуйте вхід відбитком пальця, розпізнаванням обличчя або блокуванням екрана пристрою.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зареєстровано $count пристроїв.',
      few: 'Зареєстровано $count пристрої.',
      one: 'Зареєстровано $count пристрій.',
    );
    return '$_temp0 Під час входу цей спосіб пропонується першим.';
  }

  @override
  String get notUsedYet => 'Ще не використовувався';

  @override
  String lastUsed(String date) {
    return 'Останнє використання: $date';
  }

  @override
  String get addFingerprintHere => 'Додати відбиток на цьому пристрої';

  @override
  String get passkeyUnsupported =>
      'Цей пристрій або браузер не підтримує вхід за відбитком.';

  @override
  String passkeyDefaultName(String date) {
    return 'Відбиток · $date';
  }

  @override
  String get totpAdded => 'Застосунок-автентифікатор додано.';

  @override
  String get totpStep1 =>
      '1. Додайте новий обліковий запис у застосунку-автентифікаторі та відскануйте цей код. На тому самому телефоні натисніть «Відкрити в застосунку» або введіть ключ вручну.';

  @override
  String get copyKey => 'Скопіювати ключ';

  @override
  String get openInApp => 'Відкрити в застосунку';

  @override
  String get totpStep2 => '2. Введіть 6-значний код із застосунку.';

  @override
  String get activate => 'Увімкнути';

  @override
  String get codeHint => '6-значний код';

  @override
  String get enterCode => 'Введіть 6-значний код.';

  @override
  String get enterSmsCode => 'Введіть 6-значний код із SMS.';

  @override
  String get enterAppCode => 'Введіть 6-значний код із застосунку.';

  @override
  String get refresh => 'Оновити';

  @override
  String get language => 'Мова';

  @override
  String get chooseLanguage => 'Виберіть мову';

  @override
  String get languageNote =>
      'Меню, кнопки, сповіщення й угоди показуються цією мовою. Дописи, коментарі та повідомлення залишаються мовою оригіналу.';

  @override
  String get or => 'або';
}
