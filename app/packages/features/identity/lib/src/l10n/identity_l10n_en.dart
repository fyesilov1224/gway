// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class IdentityL10nEn extends IdentityL10n {
  IdentityL10nEn([String locale = 'en']) : super(locale);

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authEmailNotConfirmed =>
      'You haven\'t verified your email yet. Check your inbox.';

  @override
  String get authEmailExists =>
      'An account with this email already exists. Try signing in.';

  @override
  String get authWeakPassword =>
      'Your password must be at least 8 characters and include an uppercase letter, a lowercase letter and a number.';

  @override
  String get authSamePassword =>
      'Your new password must be different from the old one.';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authUserBanned =>
      'You can\'t sign in because your account is suspended.';

  @override
  String get authProviderDisabled =>
      'This sign-in method is not available right now.';

  @override
  String ageMinimum(int age) {
    return 'You must be at least $age to use GWAY.';
  }

  @override
  String get deletionPendingTitle => 'Your account is about to be deleted';

  @override
  String get deletionRequested =>
      'We\'ve received your request to delete your account.';

  @override
  String deletionScheduled(String date) {
    return 'Your account and all your data will be permanently deleted on $date. You can change your mind until then.';
  }

  @override
  String get undoDeletion => 'Cancel deletion';

  @override
  String get signOut => 'Sign out';

  @override
  String get bannedTitle => 'Your account has been permanently closed';

  @override
  String get suspendedTitle => 'Your account has been suspended';

  @override
  String get bannedBody =>
      'The platform team has permanently closed your account. Your profile is no longer visible to anyone.';

  @override
  String suspendedBody(String date) {
    return 'Your account is suspended until $date. You can\'t use the app during this time; your profile shows that you are suspended.';
  }

  @override
  String banReason(String reason) {
    return 'Reason for the ban: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Reason for the suspension: $reason';
  }

  @override
  String get retry => 'Try again';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get beforeDeleting => 'Before you delete your account';

  @override
  String get deletionHidesNow =>
      'Your profile is hidden right away; nobody can find you.';

  @override
  String deletionGraceRestore(int days) {
    return 'You can sign in within $days days and cancel the deletion.';
  }

  @override
  String get deletionAfterGrace =>
      'After that, your profile, photos and all your data are permanently deleted.';

  @override
  String get deletionUnderstood => 'I understand. I want to delete my account.';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get heroTitle => 'Your community is waiting.';

  @override
  String get heroBody =>
      'From hiking to music, running to art: find your group, make plans together and be there at the same time.';

  @override
  String get heroPointGroups => 'Join groups or start your own community';

  @override
  String get heroPointEvents =>
      'Add events to your calendar and find teammates';

  @override
  String get heroPointLive => 'Meet your group in live audio chats';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle =>
      'Pick up where you left off with your groups and friends.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get signUp => 'Sign up';

  @override
  String get signUpSubtitle =>
      'Find your groups, join events and meet new people.';

  @override
  String get passwordRepeat => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match.';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String checkEmailBody(String email) {
    return 'We sent a verification link to $email. You can sign in after you tap the link.';
  }

  @override
  String get linkResent => 'We sent the link again.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get resendLink => 'Resend link';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get resetLinkSent =>
      'If an account exists for this address, we\'ve sent a reset link.';

  @override
  String get sendLink => 'Send link';

  @override
  String get newPasswordTitle => 'Set a new password';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordRepeat => 'Confirm new password';

  @override
  String get savePassword => 'Save password';

  @override
  String get enterEmail => 'Enter your email address.';

  @override
  String get passwordMin8 => 'Your password must be at least 8 characters.';

  @override
  String get passwordMix =>
      'Your password must include an uppercase letter, a lowercase letter and a number.';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get birthDateTitle => 'Your date of birth';

  @override
  String get chooseBirthDate => 'Choose your date of birth.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY is for people aged $age and over. Your date of birth is never shown to anyone and cannot be changed later.';
  }

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get continueAction => 'Continue';

  @override
  String get agreeTerms => 'I have read and accept the Terms of Use.';

  @override
  String get agreePrivacy => 'I have read the Privacy Notice (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'I give my explicit consent to my personal data being processed on servers outside Turkey.';

  @override
  String get agreeCommunityRules =>
      'I have read and accept the Community Rules, Sanctions and Legal Action Agreement.';

  @override
  String get agreeDistanceSales =>
      'I have read and accept the Distance Sales Agreement.';

  @override
  String get readAndAccept => 'I\'ve read it and I accept';

  @override
  String get readWholeText => 'Please read the whole text before you accept.';

  @override
  String get beforeContinue => 'Before you continue';

  @override
  String get consentIntro => 'To use GWAY, read and accept the texts below.';

  @override
  String get readText => 'Read the text';

  @override
  String get readToEnd => 'Read the text to the end to accept it.';

  @override
  String versionLabel(int version) {
    return 'Version $version';
  }

  @override
  String get legalDocuments => 'Legal documents';

  @override
  String get documentNotPublished => 'This text is not published right now.';

  @override
  String get deletionInfoTitle => 'Deleting your GWAY account';

  @override
  String get deletionInfoIntro =>
      'You can delete your account and data in the app or on this website:';

  @override
  String get deletionInfoStep1 => 'Sign in to the GWAY app or website.';

  @override
  String get deletionInfoStep2 => 'Go to Me → Settings → Delete account.';

  @override
  String get deletionInfoStep3 =>
      'Confirm the deletion. Your profile is hidden right away.';

  @override
  String get deletionInfoWhat => 'What is deleted and what is kept?';

  @override
  String deletionInfoBody(int days) {
    return 'You can sign in within $days days and cancel the deletion. After that, your profile, posts, photos, messages, group memberships, location check records and verification details are permanently deleted. Payment records with a legal retention duty and anonymous transaction records are kept for the period required by law. For accounts closed for security reasons, the phone number is kept to prevent a new account being opened with the same number.';
  }

  @override
  String get securityTitle => 'Security check';

  @override
  String get securityChecking => 'Checking security';

  @override
  String get securityWarning =>
      'Your location, the phone you are using and a VPN have been detected. Please follow the rules of the country you are in and sign in securely.';

  @override
  String get vpnInstalledWarning =>
      'A VPN app has been detected on your device. Please follow the rules of the country you are in and sign in securely.';

  @override
  String get securityWarningTitle => 'Security warning';

  @override
  String get understood => 'Got it';

  @override
  String get passkeyNotAdded =>
      'Fingerprint not added: it was cancelled or this device is already registered.';

  @override
  String get locationDeniedForever =>
      'You denied location access before. Turn on location access for GWAY in your device settings and try again.';

  @override
  String get locationRequired => 'You can\'t continue without location access.';

  @override
  String get locationServiceOff =>
      'Location services are off on your device. Turn them on and try again.';

  @override
  String get locationTitle => 'Let\'s verify your location';

  @override
  String get locationBody =>
      'For account security and to prevent fake accounts, GWAY uses your location when you sign in and open the app. The app does not open without location access.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get grantLocation => 'Allow location access';

  @override
  String get readPrivacyNotice => 'Read the privacy notice';

  @override
  String get privacyNoticeUnavailable =>
      'The privacy notice couldn\'t be loaded right now.';

  @override
  String get enterMobileNumber => 'Enter your mobile number.';

  @override
  String get speedUpTitle => 'Sign in faster';

  @override
  String get speedUpBodyPasskey =>
      'Next time, verify with your fingerprint or a Google Authenticator code instead of waiting for an SMS.';

  @override
  String get speedUpBodyTotp =>
      'Next time, verify with a Google Authenticator code instead of waiting for an SMS.';

  @override
  String get addFingerprint => 'Add fingerprint';

  @override
  String get addAuthenticator => 'Add Google Authenticator';

  @override
  String get notNow => 'Not now';

  @override
  String get fingerprintAdded => 'Fingerprint added.';

  @override
  String get verifyPhoneTitle => 'Verify your phone';

  @override
  String get verifyPhoneBody =>
      'Verify with a mobile number from the country you are in. Your number is never shown to others.';

  @override
  String get mobilePhone => 'Mobile phone';

  @override
  String get sendCode => 'Send code';

  @override
  String get verify => 'Verify';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code ($seconds s)';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get changeNumber => 'Change number';

  @override
  String get passkeyFailed =>
      'Verification was cancelled or there is no fingerprint registered on this device. You can choose another method.';

  @override
  String get verifySignInTitle => 'Verify your sign-in';

  @override
  String get verifyWithPasskey =>
      'Verify your sign-in with this device\'s fingerprint, face recognition or screen lock.';

  @override
  String get verifyWithTotp =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String smsWillSendTo(String phone) {
    return 'For your security, you need to verify this sign-in. We\'ll send a code to $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'For your security, you need to verify this sign-in. We\'ll send a code to your saved number.';

  @override
  String get methodFingerprint => 'Fingerprint';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Verify with fingerprint';

  @override
  String get reviewTitle => 'Couldn\'t sign in securely';

  @override
  String get reviewBody =>
      'Your account is under security review. Once the review is complete, you can pick up where you left off.';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get removeTotpTitle => 'Remove authenticator app';

  @override
  String get removeTotpBody =>
      'From now on, you can only verify new sign-ins with an SMS code.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get totpRemoved => 'Authenticator app removed.';

  @override
  String get twoFactorTitle => 'Two-step verification';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get notVerifiedYet => 'Not verified yet';

  @override
  String get authenticatorApp => 'Authenticator app';

  @override
  String get totpOn =>
      'On. You can also verify new sign-ins with the code in the app.';

  @override
  String get totpOff =>
      'Sign in without waiting for an SMS, using an app such as Google Authenticator.';

  @override
  String get addTotp => 'Add authenticator app';

  @override
  String get signInRequired => 'You need to sign in.';

  @override
  String passkeyRemoved(String name) {
    return '$name removed.';
  }

  @override
  String get passkeysTitle => 'Fingerprint and face recognition';

  @override
  String get passkeysOff =>
      'Verify sign-ins with your device\'s fingerprint, face recognition or screen lock.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices registered.',
      one: '1 device registered.',
    );
    return '$_temp0 This method is asked first when you sign in.';
  }

  @override
  String get notUsedYet => 'Not used yet';

  @override
  String lastUsed(String date) {
    return 'Last used: $date';
  }

  @override
  String get addFingerprintHere => 'Add fingerprint on this device';

  @override
  String get passkeyUnsupported =>
      'This device or browser doesn\'t support fingerprint sign-in.';

  @override
  String passkeyDefaultName(String date) {
    return 'Fingerprint · $date';
  }

  @override
  String get totpAdded => 'Authenticator app added.';

  @override
  String get totpStep1 =>
      '1. Add a new account in your authenticator app and scan this code. On the same phone, tap \"Open in app\" or enter the key manually.';

  @override
  String get copyKey => 'Copy key';

  @override
  String get openInApp => 'Open in app';

  @override
  String get totpStep2 => '2. Enter the 6-digit code shown in the app.';

  @override
  String get activate => 'Turn on';

  @override
  String get codeHint => '6-digit code';

  @override
  String get enterCode => 'Enter the 6-digit code.';

  @override
  String get enterSmsCode => 'Enter the 6-digit code from the SMS.';

  @override
  String get enterAppCode => 'Enter the 6-digit code from the app.';

  @override
  String get refresh => 'Refresh';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageNote =>
      'Menus, buttons, notifications and agreements are shown in this language. Posts, comments and messages stay in the language they were written in.';

  @override
  String get or => 'or';

  @override
  String get legalTranslationNote =>
      'This translation is for information. The binding text, and the one you accept, is the Turkish original.';

  @override
  String get legalShowOriginal => 'Show the Turkish original';

  @override
  String get legalShowTranslation => 'Show the translation';
}
