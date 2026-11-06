// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class IdentityL10nRu extends IdentityL10n {
  IdentityL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'Неверный адрес электронной почты или пароль.';

  @override
  String get authEmailNotConfirmed =>
      'Вы ещё не подтвердили адрес электронной почты. Проверьте входящие.';

  @override
  String get authEmailExists =>
      'Аккаунт с этим адресом уже существует. Попробуйте войти.';

  @override
  String get authWeakPassword =>
      'Пароль должен содержать не менее 8 символов, заглавную и строчную буквы и цифру.';

  @override
  String get authSamePassword => 'Новый пароль должен отличаться от старого.';

  @override
  String get authInvalidEmail =>
      'Введите действительный адрес электронной почты.';

  @override
  String get authUserBanned => 'Вы не можете войти: ваш аккаунт заблокирован.';

  @override
  String get authProviderDisabled => 'Этот способ входа сейчас недоступен.';

  @override
  String ageMinimum(int age) {
    return 'Чтобы пользоваться GWAY, вам должно быть не меньше $age лет.';
  }

  @override
  String get deletionPendingTitle => 'Ваш аккаунт скоро будет удалён';

  @override
  String get deletionRequested =>
      'Мы получили ваш запрос на удаление аккаунта.';

  @override
  String deletionScheduled(String date) {
    return 'Ваш аккаунт и все данные будут безвозвратно удалены $date. До этого времени вы можете передумать.';
  }

  @override
  String get undoDeletion => 'Отменить удаление';

  @override
  String get signOut => 'Выйти';

  @override
  String get bannedTitle => 'Ваш аккаунт закрыт навсегда';

  @override
  String get suspendedTitle => 'Ваш аккаунт заблокирован';

  @override
  String get bannedBody =>
      'Команда платформы закрыла ваш аккаунт навсегда. Ваш профиль больше никому не виден.';

  @override
  String suspendedBody(String date) {
    return 'Ваш аккаунт заблокирован до $date. В это время вы не можете пользоваться приложением; в профиле видна блокировка.';
  }

  @override
  String banReason(String reason) {
    return 'Причина блокировки: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Причина приостановки: $reason';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get beforeDeleting => 'Перед удалением аккаунта';

  @override
  String get deletionHidesNow =>
      'Ваш профиль сразу скрывается — никто не сможет вас найти.';

  @override
  String deletionGraceRestore(int days) {
    return 'В течение $days дней вы можете войти и отменить удаление.';
  }

  @override
  String get deletionAfterGrace =>
      'После этого ваш профиль, фотографии и все данные удаляются безвозвратно.';

  @override
  String get deletionUnderstood => 'Понятно, я хочу удалить аккаунт.';

  @override
  String get deleteMyAccount => 'Удалить мой аккаунт';

  @override
  String get heroTitle => 'Ваше сообщество ждёт вас.';

  @override
  String get heroBody =>
      'От походов до музыки, от бега до искусства: найдите свою группу, планируйте вместе и будьте там в одно время.';

  @override
  String get heroPointGroups =>
      'Вступайте в группы или создайте своё сообщество';

  @override
  String get heroPointEvents =>
      'Добавляйте мероприятия в календарь и находите напарников';

  @override
  String get heroPointLive => 'Общайтесь с группой в живых аудиочатах';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get signInSubtitle =>
      'Продолжите с того места, где остановились, — с группами и друзьями.';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get noAccountSignUp => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get signUpSubtitle =>
      'Находите группы, участвуйте в мероприятиях и знакомьтесь с новыми людьми.';

  @override
  String get passwordRepeat => 'Повторите пароль';

  @override
  String get passwordsDontMatch => 'Пароли не совпадают.';

  @override
  String get haveAccountSignIn => 'Уже есть аккаунт? Войдите';

  @override
  String get checkEmailTitle => 'Проверьте почту';

  @override
  String checkEmailBody(String email) {
    return 'Мы отправили ссылку для подтверждения на $email. После перехода по ссылке вы сможете войти.';
  }

  @override
  String get linkResent => 'Мы отправили ссылку ещё раз.';

  @override
  String get backToSignIn => 'Вернуться ко входу';

  @override
  String get resendLink => 'Отправить ссылку ещё раз';

  @override
  String get resetPasswordTitle => 'Сброс пароля';

  @override
  String get resetPasswordSubtitle =>
      'Введите адрес электронной почты, и мы пришлём ссылку для сброса пароля.';

  @override
  String get resetLinkSent =>
      'Если для этого адреса есть аккаунт, мы отправили ссылку для сброса.';

  @override
  String get sendLink => 'Отправить ссылку';

  @override
  String get newPasswordTitle => 'Задайте новый пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get newPasswordRepeat => 'Повторите новый пароль';

  @override
  String get savePassword => 'Сохранить пароль';

  @override
  String get enterEmail => 'Введите адрес электронной почты.';

  @override
  String get passwordMin8 => 'Пароль должен содержать не менее 8 символов.';

  @override
  String get passwordMix =>
      'Пароль должен содержать заглавную и строчную буквы и цифру.';

  @override
  String get enterPassword => 'Введите пароль.';

  @override
  String get birthDateTitle => 'Дата рождения';

  @override
  String get chooseBirthDate => 'Выберите дату рождения.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY предназначен для людей от $age лет. Дата рождения никому не показывается, и её нельзя изменить позже.';
  }

  @override
  String get chooseDate => 'Выбрать дату';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get agreeTerms => 'Я прочитал(а) и принимаю Условия использования.';

  @override
  String get agreePrivacy =>
      'Я прочитал(а) Уведомление о конфиденциальности (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Я даю явное согласие на обработку моих персональных данных на серверах за пределами Турции.';

  @override
  String get agreeCommunityRules =>
      'Я прочитал(а) и принимаю Соглашение о правилах сообщества, санкциях и правовых мерах.';

  @override
  String get agreeDistanceSales =>
      'Я прочитал(а) и принимаю Договор дистанционной продажи.';

  @override
  String get readAndAccept => 'Прочитал(а) и принимаю';

  @override
  String get readWholeText =>
      'Пожалуйста, прочитайте текст полностью, прежде чем принять.';

  @override
  String get beforeContinue => 'Прежде чем продолжить';

  @override
  String get consentIntro =>
      'Чтобы пользоваться GWAY, прочитайте и примите тексты ниже.';

  @override
  String get readText => 'Прочитать текст';

  @override
  String get readToEnd => 'Чтобы принять, дочитайте текст до конца.';

  @override
  String versionLabel(int version) {
    return 'Версия $version';
  }

  @override
  String get legalDocuments => 'Юридические документы';

  @override
  String get documentNotPublished => 'Этот текст сейчас не опубликован.';

  @override
  String get deletionInfoTitle => 'Удаление аккаунта GWAY';

  @override
  String get deletionInfoIntro =>
      'Удалить аккаунт и данные можно в приложении или на этом сайте:';

  @override
  String get deletionInfoStep1 => 'Войдите в приложение или на сайт GWAY.';

  @override
  String get deletionInfoStep2 => 'Откройте Я → Настройки → Удалить аккаунт.';

  @override
  String get deletionInfoStep3 =>
      'Подтвердите удаление. Профиль сразу скрывается.';

  @override
  String get deletionInfoWhat => 'Что удаляется и что сохраняется?';

  @override
  String deletionInfoBody(int days) {
    return 'В течение $days дней вы можете войти и отменить удаление. После этого ваш профиль, публикации, фото, сообщения, членство в группах, записи о проверке местоположения и данные верификации удаляются безвозвратно. Платёжные записи, которые закон обязывает хранить, и обезличенные журналы операций хранятся в течение установленного законом срока. Для аккаунтов, закрытых по соображениям безопасности, сохраняется номер телефона, чтобы на него нельзя было открыть новый аккаунт.';
  }

  @override
  String get securityTitle => 'Проверка безопасности';

  @override
  String get securityChecking => 'Проверяем безопасность';

  @override
  String get securityWarning =>
      'Обнаружены ваше местоположение, используемый телефон и VPN. Пожалуйста, соблюдайте правила страны, в которой вы находитесь, и войдите безопасно.';

  @override
  String get vpnInstalledWarning =>
      'На вашем устройстве обнаружено VPN-приложение. Пожалуйста, соблюдайте правила страны, в которой вы находитесь, и войдите безопасно.';

  @override
  String get securityWarningTitle => 'Предупреждение безопасности';

  @override
  String get understood => 'Понятно';

  @override
  String get passkeyNotAdded =>
      'Отпечаток не добавлен: действие отменено или это устройство уже зарегистрировано.';

  @override
  String get locationDeniedForever =>
      'Ранее вы запретили доступ к геолокации. Включите его для GWAY в настройках устройства и повторите попытку.';

  @override
  String get locationRequired => 'Без доступа к геолокации продолжить нельзя.';

  @override
  String get locationServiceOff =>
      'Службы геолокации на устройстве отключены. Включите их и повторите попытку.';

  @override
  String get locationTitle => 'Подтвердим ваше местоположение';

  @override
  String get locationBody =>
      'Для безопасности аккаунта и защиты от фейков GWAY использует ваше местоположение при входе и открытии приложения. Без доступа к геолокации приложение не откроется.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get grantLocation => 'Разрешить доступ к геолокации';

  @override
  String get readPrivacyNotice => 'Прочитать уведомление о конфиденциальности';

  @override
  String get privacyNoticeUnavailable =>
      'Не удалось загрузить уведомление о конфиденциальности.';

  @override
  String get enterMobileNumber => 'Введите номер мобильного телефона.';

  @override
  String get speedUpTitle => 'Входите быстрее';

  @override
  String get speedUpBodyPasskey =>
      'В следующий раз подтверждайте вход отпечатком пальца или кодом Google Authenticator, не дожидаясь SMS.';

  @override
  String get speedUpBodyTotp =>
      'В следующий раз подтверждайте вход кодом Google Authenticator, не дожидаясь SMS.';

  @override
  String get addFingerprint => 'Добавить отпечаток';

  @override
  String get addAuthenticator => 'Добавить Google Authenticator';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get fingerprintAdded => 'Отпечаток добавлен.';

  @override
  String get verifyPhoneTitle => 'Подтвердите телефон';

  @override
  String get verifyPhoneBody =>
      'Подтвердите номером мобильного телефона страны, в которой вы находитесь. Ваш номер никому не показывается.';

  @override
  String get mobilePhone => 'Мобильный телефон';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get verify => 'Подтвердить';

  @override
  String resendCodeIn(int seconds) {
    return 'Отправить код ещё раз ($seconds с)';
  }

  @override
  String get resendCode => 'Отправить код ещё раз';

  @override
  String get changeNumber => 'Изменить номер';

  @override
  String get passkeyFailed =>
      'Подтверждение отменено или на этом устройстве нет зарегистрированного отпечатка. Выберите другой способ.';

  @override
  String get verifySignInTitle => 'Подтвердите вход';

  @override
  String get verifyWithPasskey =>
      'Подтвердите вход отпечатком пальца, распознаванием лица или блокировкой экрана этого устройства.';

  @override
  String get verifyWithTotp =>
      'Введите 6-значный код из приложения-аутентификатора.';

  @override
  String smsWillSendTo(String phone) {
    return 'Для вашей безопасности нужно подтвердить этот вход. Мы отправим код на номер $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Для вашей безопасности нужно подтвердить этот вход. Мы отправим код на сохранённый номер.';

  @override
  String get methodFingerprint => 'Отпечаток';

  @override
  String get methodApp => 'Приложение';

  @override
  String get verifyWithFingerprint => 'Подтвердить отпечатком';

  @override
  String get reviewTitle => 'Не удалось безопасно войти';

  @override
  String get reviewBody =>
      'Ваш аккаунт проходит проверку безопасности. Когда она завершится, вы сможете продолжить с того же места.';

  @override
  String get refreshStatus => 'Обновить статус';

  @override
  String get removeTotpTitle => 'Удалить приложение-аутентификатор';

  @override
  String get removeTotpBody =>
      'После этого новые входы можно будет подтверждать только кодом из SMS.';

  @override
  String get cancel => 'Отмена';

  @override
  String get remove => 'Удалить';

  @override
  String get totpRemoved => 'Приложение-аутентификатор удалено.';

  @override
  String get twoFactorTitle => 'Двухэтапная проверка';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get notVerifiedYet => 'Ещё не подтверждён';

  @override
  String get authenticatorApp => 'Приложение-аутентификатор';

  @override
  String get totpOn =>
      'Включено. Новые входы можно подтверждать и кодом из приложения.';

  @override
  String get totpOff =>
      'Входите без ожидания SMS с помощью приложения, например Google Authenticator.';

  @override
  String get addTotp => 'Добавить приложение-аутентификатор';

  @override
  String get signInRequired => 'Нужно войти.';

  @override
  String passkeyRemoved(String name) {
    return '$name: удалено.';
  }

  @override
  String get passkeysTitle => 'Отпечаток пальца и распознавание лица';

  @override
  String get passkeysOff =>
      'Подтверждайте вход отпечатком пальца, распознаванием лица или блокировкой экрана устройства.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зарегистрировано $count устройств.',
      few: 'Зарегистрировано $count устройства.',
      one: 'Зарегистрировано $count устройство.',
    );
    return '$_temp0 При входе этот способ предлагается первым.';
  }

  @override
  String get notUsedYet => 'Ещё не использовался';

  @override
  String lastUsed(String date) {
    return 'Последнее использование: $date';
  }

  @override
  String get addFingerprintHere => 'Добавить отпечаток на этом устройстве';

  @override
  String get passkeyUnsupported =>
      'Это устройство или браузер не поддерживает вход по отпечатку.';

  @override
  String passkeyDefaultName(String date) {
    return 'Отпечаток · $date';
  }

  @override
  String get totpAdded => 'Приложение-аутентификатор добавлено.';

  @override
  String get totpStep1 =>
      '1. Добавьте новый аккаунт в приложении-аутентификаторе и отсканируйте этот код. На том же телефоне нажмите «Открыть в приложении» или введите ключ вручную.';

  @override
  String get copyKey => 'Скопировать ключ';

  @override
  String get openInApp => 'Открыть в приложении';

  @override
  String get totpStep2 => '2. Введите 6-значный код из приложения.';

  @override
  String get activate => 'Включить';

  @override
  String get codeHint => '6-значный код';

  @override
  String get enterCode => 'Введите 6-значный код.';

  @override
  String get enterSmsCode => 'Введите 6-значный код из SMS.';

  @override
  String get enterAppCode => 'Введите 6-значный код из приложения.';

  @override
  String get refresh => 'Обновить';

  @override
  String get language => 'Язык';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get languageNote =>
      'Меню, кнопки, уведомления и соглашения показываются на этом языке. Публикации, комментарии и сообщения остаются на языке оригинала.';

  @override
  String get or => 'или';

  @override
  String get legalTranslationNote =>
      'Перевод носит информационный характер. Юридическую силу имеет турецкий оригинал — именно его вы принимаете.';

  @override
  String get legalShowOriginal => 'Показать турецкий оригинал';

  @override
  String get legalShowTranslation => 'Показать перевод';

  @override
  String get authCaptchaFailed =>
      'Не удалось подтвердить, что вы не робот. Пройдите проверку в рамке и попробуйте снова.';

  @override
  String get humanCheckWaiting =>
      'Сначала подтвердите, что вы не робот: дождитесь окончания проверки в рамке.';
}
