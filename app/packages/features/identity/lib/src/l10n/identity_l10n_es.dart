// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class IdentityL10nEs extends IdentityL10n {
  IdentityL10nEs([String locale = 'es']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'Correo electrónico o contraseña incorrectos.';

  @override
  String get authEmailNotConfirmed =>
      'Aún no has verificado tu correo. Revisa tu bandeja de entrada.';

  @override
  String get authEmailExists =>
      'Ya existe una cuenta con este correo. Intenta iniciar sesión.';

  @override
  String get authWeakPassword =>
      'La contraseña debe tener al menos 8 caracteres e incluir una mayúscula, una minúscula y un número.';

  @override
  String get authSamePassword =>
      'Tu nueva contraseña debe ser distinta de la anterior.';

  @override
  String get authInvalidEmail => 'Introduce un correo electrónico válido.';

  @override
  String get authUserBanned =>
      'No puedes iniciar sesión porque tu cuenta está suspendida.';

  @override
  String get authProviderDisabled =>
      'Este método de inicio de sesión no está disponible ahora.';

  @override
  String ageMinimum(int age) {
    return 'Debes tener al menos $age años para usar GWAY.';
  }

  @override
  String get deletionPendingTitle => 'Tu cuenta está a punto de eliminarse';

  @override
  String get deletionRequested =>
      'Hemos recibido tu solicitud para eliminar la cuenta.';

  @override
  String deletionScheduled(String date) {
    return 'Tu cuenta y todos tus datos se eliminarán definitivamente el $date. Hasta entonces puedes cambiar de opinión.';
  }

  @override
  String get undoDeletion => 'Cancelar la eliminación';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get bannedTitle => 'Tu cuenta se ha cerrado definitivamente';

  @override
  String get suspendedTitle => 'Tu cuenta ha sido suspendida';

  @override
  String get bannedBody =>
      'El equipo de la plataforma ha cerrado tu cuenta definitivamente. Tu perfil ya no es visible para nadie.';

  @override
  String suspendedBody(String date) {
    return 'Tu cuenta está suspendida hasta el $date. Durante este tiempo no puedes usar la app; tu perfil muestra la suspensión.';
  }

  @override
  String banReason(String reason) {
    return 'Motivo del bloqueo: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Motivo de la suspensión: $reason';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get beforeDeleting => 'Antes de eliminar tu cuenta';

  @override
  String get deletionHidesNow =>
      'Tu perfil se oculta de inmediato; nadie podrá encontrarte.';

  @override
  String deletionGraceRestore(int days) {
    return 'Puedes iniciar sesión en los próximos $days días y cancelar la eliminación.';
  }

  @override
  String get deletionAfterGrace =>
      'Después, tu perfil, tus fotos y todos tus datos se eliminan definitivamente.';

  @override
  String get deletionUnderstood => 'Lo entiendo, quiero eliminar mi cuenta.';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get heroTitle => 'Tu comunidad te espera.';

  @override
  String get heroBody =>
      'Del senderismo a la música, del running al arte: encuentra tu grupo, planead juntos y estad allí al mismo tiempo.';

  @override
  String get heroPointGroups => 'Únete a grupos o crea tu propia comunidad';

  @override
  String get heroPointEvents =>
      'Añade eventos a tu calendario y encuentra compañeros de equipo';

  @override
  String get heroPointLive => 'Reúnete con tu grupo en chats de voz en directo';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInSubtitle =>
      'Continúa donde lo dejaste con tus grupos y amigos.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get noAccountSignUp => '¿No tienes cuenta? Regístrate';

  @override
  String get signUp => 'Registrarse';

  @override
  String get signUpSubtitle =>
      'Encuentra tus grupos, únete a eventos y conoce gente nueva.';

  @override
  String get passwordRepeat => 'Confirmar contraseña';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get haveAccountSignIn => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get checkEmailTitle => 'Revisa tu correo';

  @override
  String checkEmailBody(String email) {
    return 'Enviamos un enlace de verificación a $email. Podrás iniciar sesión después de tocar el enlace.';
  }

  @override
  String get linkResent => 'Hemos vuelto a enviar el enlace.';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get resendLink => 'Reenviar enlace';

  @override
  String get resetPasswordTitle => 'Restablece tu contraseña';

  @override
  String get resetPasswordSubtitle =>
      'Introduce tu correo y te enviaremos un enlace para restablecer la contraseña.';

  @override
  String get resetLinkSent =>
      'Si existe una cuenta con esta dirección, hemos enviado un enlace para restablecerla.';

  @override
  String get sendLink => 'Enviar enlace';

  @override
  String get newPasswordTitle => 'Crea una contraseña nueva';

  @override
  String get newPassword => 'Contraseña nueva';

  @override
  String get newPasswordRepeat => 'Confirmar contraseña nueva';

  @override
  String get savePassword => 'Guardar contraseña';

  @override
  String get enterEmail => 'Introduce tu correo electrónico.';

  @override
  String get passwordMin8 => 'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get passwordMix =>
      'La contraseña debe incluir una mayúscula, una minúscula y un número.';

  @override
  String get enterPassword => 'Introduce tu contraseña.';

  @override
  String get birthDateTitle => 'Tu fecha de nacimiento';

  @override
  String get chooseBirthDate => 'Elige tu fecha de nacimiento.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY es para personas de $age años o más. Tu fecha de nacimiento no se muestra a nadie y no se puede cambiar después.';
  }

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get continueAction => 'Continuar';

  @override
  String get agreeTerms => 'He leído y acepto las Condiciones de uso.';

  @override
  String get agreePrivacy => 'He leído el Aviso de privacidad (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Doy mi consentimiento explícito para que mis datos personales se traten en servidores fuera de Turquía.';

  @override
  String get agreeCommunityRules =>
      'He leído y acepto el Acuerdo de normas de la comunidad, sanciones y acciones legales.';

  @override
  String get agreeDistanceSales =>
      'He leído y acepto el Contrato de venta a distancia.';

  @override
  String get readAndAccept => 'Lo he leído y acepto';

  @override
  String get readWholeText => 'Lee el texto completo antes de aceptarlo.';

  @override
  String get beforeContinue => 'Antes de continuar';

  @override
  String get consentIntro =>
      'Para usar GWAY, lee y acepta los textos siguientes.';

  @override
  String get readText => 'Leer el texto';

  @override
  String get readToEnd => 'Lee el texto hasta el final para aceptarlo.';

  @override
  String versionLabel(int version) {
    return 'Versión $version';
  }

  @override
  String get legalDocuments => 'Documentos legales';

  @override
  String get documentNotPublished => 'Este texto no está publicado ahora.';

  @override
  String get deletionInfoTitle => 'Eliminar tu cuenta de GWAY';

  @override
  String get deletionInfoIntro =>
      'Puedes eliminar tu cuenta y tus datos desde la app o en este sitio web:';

  @override
  String get deletionInfoStep1 =>
      'Inicia sesión en la app o el sitio web de GWAY.';

  @override
  String get deletionInfoStep2 => 'Ve a Yo → Ajustes → Eliminar cuenta.';

  @override
  String get deletionInfoStep3 =>
      'Confirma la eliminación. Tu perfil se oculta de inmediato.';

  @override
  String get deletionInfoWhat => '¿Qué se elimina y qué se conserva?';

  @override
  String deletionInfoBody(int days) {
    return 'Puedes iniciar sesión en los próximos $days días y cancelar la eliminación. Pasado ese plazo, tu perfil, publicaciones, fotos, mensajes, membresías de grupos, registros de verificación de ubicación y datos de verificación se eliminan definitivamente. Los registros de pago con obligación legal de conservación y los registros anónimos de operaciones se guardan durante el plazo que exige la ley. En las cuentas cerradas por motivos de seguridad, se conserva el número de teléfono para impedir que se abra una cuenta nueva con el mismo número.';
  }

  @override
  String get securityTitle => 'Verificación de seguridad';

  @override
  String get securityChecking => 'Comprobando la seguridad';

  @override
  String get securityWarning =>
      'Se han detectado su ubicación, el teléfono que usa y una VPN. Respete las normas del país en el que se encuentra e inicie sesión de forma segura.';

  @override
  String get vpnInstalledWarning =>
      'Se ha detectado una app de VPN en su dispositivo. Respete las normas del país en el que se encuentra e inicie sesión de forma segura.';

  @override
  String get securityWarningTitle => 'Aviso de seguridad';

  @override
  String get understood => 'Entendido';

  @override
  String get passkeyNotAdded =>
      'No se añadió la huella: se canceló o este dispositivo ya está registrado.';

  @override
  String get locationDeniedForever =>
      'Ya rechazaste el acceso a la ubicación. Actívalo para GWAY en los ajustes del dispositivo e inténtalo de nuevo.';

  @override
  String get locationRequired =>
      'No puedes continuar sin acceso a la ubicación.';

  @override
  String get locationServiceOff =>
      'Los servicios de ubicación están desactivados. Actívalos e inténtalo de nuevo.';

  @override
  String get locationTitle => 'Verifiquemos tu ubicación';

  @override
  String get locationBody =>
      'Por la seguridad de la cuenta y para evitar cuentas falsas, GWAY usa tu ubicación al iniciar sesión y abrir la app. Sin acceso a la ubicación, la app no se abre.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get grantLocation => 'Permitir acceso a la ubicación';

  @override
  String get readPrivacyNotice => 'Leer el aviso de privacidad';

  @override
  String get privacyNoticeUnavailable =>
      'No se pudo cargar el aviso de privacidad.';

  @override
  String get enterMobileNumber => 'Introduce tu número de móvil.';

  @override
  String get speedUpTitle => 'Inicia sesión más rápido';

  @override
  String get speedUpBodyPasskey =>
      'La próxima vez, verifica con tu huella o un código de Google Authenticator sin esperar un SMS.';

  @override
  String get speedUpBodyTotp =>
      'La próxima vez, verifica con un código de Google Authenticator sin esperar un SMS.';

  @override
  String get addFingerprint => 'Añadir huella';

  @override
  String get addAuthenticator => 'Añadir Google Authenticator';

  @override
  String get notNow => 'Ahora no';

  @override
  String get fingerprintAdded => 'Huella añadida.';

  @override
  String get verifyPhoneTitle => 'Verifica tu teléfono';

  @override
  String get verifyPhoneBody =>
      'Verifica con un número de móvil del país en el que estás. Tu número nunca se muestra a otras personas.';

  @override
  String get mobilePhone => 'Teléfono móvil';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get verify => 'Verificar';

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código ($seconds s)';
  }

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get changeNumber => 'Cambiar número';

  @override
  String get passkeyFailed =>
      'Se canceló la verificación o no hay ninguna huella registrada en este dispositivo. Puedes elegir otro método.';

  @override
  String get verifySignInTitle => 'Verifica tu inicio de sesión';

  @override
  String get verifyWithPasskey =>
      'Verifica tu inicio de sesión con la huella, el reconocimiento facial o el bloqueo de pantalla de este dispositivo.';

  @override
  String get verifyWithTotp =>
      'Introduce el código de 6 dígitos de tu app de autenticación.';

  @override
  String smsWillSendTo(String phone) {
    return 'Por tu seguridad, debes verificar este inicio de sesión. Enviaremos un código al $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Por tu seguridad, debes verificar este inicio de sesión. Enviaremos un código a tu número guardado.';

  @override
  String get methodFingerprint => 'Huella';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Verificar con huella';

  @override
  String get reviewTitle => 'No se pudo iniciar sesión de forma segura';

  @override
  String get reviewBody =>
      'Tu cuenta está en revisión de seguridad. Cuando termine la revisión, podrás continuar donde lo dejaste.';

  @override
  String get refreshStatus => 'Actualizar estado';

  @override
  String get removeTotpTitle => 'Quitar app de autenticación';

  @override
  String get removeTotpBody =>
      'A partir de ahora solo podrás verificar nuevos inicios de sesión con un código SMS.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Quitar';

  @override
  String get totpRemoved => 'App de autenticación quitada.';

  @override
  String get twoFactorTitle => 'Verificación en dos pasos';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get notVerifiedYet => 'Aún no verificado';

  @override
  String get authenticatorApp => 'App de autenticación';

  @override
  String get totpOn =>
      'Activada. También puedes verificar nuevos inicios de sesión con el código de la app.';

  @override
  String get totpOff =>
      'Inicia sesión sin esperar un SMS con una app como Google Authenticator.';

  @override
  String get addTotp => 'Añadir app de autenticación';

  @override
  String get signInRequired => 'Debes iniciar sesión.';

  @override
  String passkeyRemoved(String name) {
    return '$name quitado.';
  }

  @override
  String get passkeysTitle => 'Huella y reconocimiento facial';

  @override
  String get passkeysOff =>
      'Verifica los inicios de sesión con la huella, el reconocimiento facial o el bloqueo de pantalla del dispositivo.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos registrados.',
      one: '1 dispositivo registrado.',
    );
    return '$_temp0 Este método se pide primero al iniciar sesión.';
  }

  @override
  String get notUsedYet => 'Aún sin usar';

  @override
  String lastUsed(String date) {
    return 'Último uso: $date';
  }

  @override
  String get addFingerprintHere => 'Añadir huella en este dispositivo';

  @override
  String get passkeyUnsupported =>
      'Este dispositivo o navegador no admite el inicio de sesión con huella.';

  @override
  String passkeyDefaultName(String date) {
    return 'Huella · $date';
  }

  @override
  String get totpAdded => 'App de autenticación añadida.';

  @override
  String get totpStep1 =>
      '1. Añade una cuenta nueva en tu app de autenticación y escanea este código. Si estás en el mismo teléfono, toca «Abrir en la app» o introduce la clave a mano.';

  @override
  String get copyKey => 'Copiar clave';

  @override
  String get openInApp => 'Abrir en la app';

  @override
  String get totpStep2 =>
      '2. Introduce el código de 6 dígitos que muestra la app.';

  @override
  String get activate => 'Activar';

  @override
  String get codeHint => 'Código de 6 dígitos';

  @override
  String get enterCode => 'Introduce el código de 6 dígitos.';

  @override
  String get enterSmsCode => 'Introduce el código de 6 dígitos del SMS.';

  @override
  String get enterAppCode => 'Introduce el código de 6 dígitos de la app.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get languageNote =>
      'Los menús, botones, notificaciones y acuerdos se muestran en este idioma. Las publicaciones, comentarios y mensajes se mantienen en su idioma original.';

  @override
  String get or => 'o';

  @override
  String get legalTranslationNote =>
      'Esta traducción es informativa. El texto vinculante, y el que aceptas, es el original en turco.';

  @override
  String get legalShowOriginal => 'Ver el original en turco';

  @override
  String get legalShowTranslation => 'Ver la traducción';

  @override
  String get authCaptchaFailed =>
      'No pudimos verificar que no eres un robot. Completa la verificación del recuadro e inténtalo de nuevo.';

  @override
  String get humanCheckWaiting =>
      'Primero confirma que no eres un robot: espera a que termine la verificación del recuadro.';
}
