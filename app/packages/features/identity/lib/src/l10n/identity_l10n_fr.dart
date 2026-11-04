// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class IdentityL10nFr extends IdentityL10n {
  IdentityL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get authEmailNotConfirmed =>
      'Tu n\'as pas encore confirmé ton adresse e-mail. Vérifie ta boîte de réception.';

  @override
  String get authEmailExists =>
      'Un compte existe déjà avec cette adresse e-mail. Essaie de te connecter.';

  @override
  String get authWeakPassword =>
      'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule et un chiffre.';

  @override
  String get authSamePassword =>
      'Ton nouveau mot de passe doit être différent de l\'ancien.';

  @override
  String get authInvalidEmail => 'Saisis une adresse e-mail valide.';

  @override
  String get authUserBanned =>
      'Tu ne peux pas te connecter car ton compte est suspendu.';

  @override
  String get authProviderDisabled =>
      'Ce mode de connexion n\'est pas disponible pour le moment.';

  @override
  String ageMinimum(int age) {
    return 'Tu dois avoir au moins $age ans pour utiliser GWAY.';
  }

  @override
  String get deletionPendingTitle => 'Ton compte va bientôt être supprimé';

  @override
  String get deletionRequested =>
      'Nous avons bien reçu ta demande de suppression de compte.';

  @override
  String deletionScheduled(String date) {
    return 'Ton compte et toutes tes données seront définitivement supprimés le $date. D\'ici là, tu peux changer d\'avis.';
  }

  @override
  String get undoDeletion => 'Annuler la suppression';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get bannedTitle => 'Ton compte a été fermé définitivement';

  @override
  String get suspendedTitle => 'Ton compte a été suspendu';

  @override
  String get bannedBody =>
      'L\'équipe de la plateforme a fermé ton compte définitivement. Ton profil n\'est plus visible par personne.';

  @override
  String suspendedBody(String date) {
    return 'Ton compte est suspendu jusqu\'au $date. Pendant ce temps, tu ne peux pas utiliser l\'application ; ton profil indique la suspension.';
  }

  @override
  String banReason(String reason) {
    return 'Motif du bannissement : $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Motif de la suspension : $reason';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get beforeDeleting => 'Avant de supprimer ton compte';

  @override
  String get deletionHidesNow =>
      'Ton profil est masqué immédiatement ; personne ne peut te trouver.';

  @override
  String deletionGraceRestore(int days) {
    return 'Tu peux te connecter dans les $days jours et annuler la suppression.';
  }

  @override
  String get deletionAfterGrace =>
      'Ensuite, ton profil, tes photos et toutes tes données sont définitivement supprimés.';

  @override
  String get deletionUnderstood =>
      'J\'ai compris, je veux supprimer mon compte.';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get heroTitle => 'Ta communauté t\'attend.';

  @override
  String get heroBody =>
      'De la randonnée à la musique, de la course à l\'art : trouve ton groupe, organisez-vous ensemble et soyez-y en même temps.';

  @override
  String get heroPointGroups =>
      'Rejoins des groupes ou crée ta propre communauté';

  @override
  String get heroPointEvents =>
      'Ajoute des événements à ton agenda et trouve des coéquipiers';

  @override
  String get heroPointLive =>
      'Retrouve ton groupe dans des discussions audio en direct';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInSubtitle =>
      'Reprends là où tu en étais avec tes groupes et tes amis.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get noAccountSignUp => 'Pas de compte ? Inscris-toi';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signUpSubtitle =>
      'Trouve tes groupes, participe à des événements et rencontre de nouvelles personnes.';

  @override
  String get passwordRepeat => 'Confirmer le mot de passe';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get haveAccountSignIn => 'Déjà un compte ? Connecte-toi';

  @override
  String get checkEmailTitle => 'Vérifie tes e-mails';

  @override
  String checkEmailBody(String email) {
    return 'Nous avons envoyé un lien de vérification à $email. Tu pourras te connecter après avoir appuyé sur le lien.';
  }

  @override
  String get linkResent => 'Nous avons renvoyé le lien.';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get resendLink => 'Renvoyer le lien';

  @override
  String get resetPasswordTitle => 'Réinitialise ton mot de passe';

  @override
  String get resetPasswordSubtitle =>
      'Saisis ton adresse e-mail et nous t\'enverrons un lien de réinitialisation.';

  @override
  String get resetLinkSent =>
      'Si un compte existe pour cette adresse, nous avons envoyé un lien de réinitialisation.';

  @override
  String get sendLink => 'Envoyer le lien';

  @override
  String get newPasswordTitle => 'Choisis un nouveau mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get newPasswordRepeat => 'Confirmer le nouveau mot de passe';

  @override
  String get savePassword => 'Enregistrer le mot de passe';

  @override
  String get enterEmail => 'Saisis ton adresse e-mail.';

  @override
  String get passwordMin8 =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get passwordMix =>
      'Le mot de passe doit contenir une majuscule, une minuscule et un chiffre.';

  @override
  String get enterPassword => 'Saisis ton mot de passe.';

  @override
  String get birthDateTitle => 'Ta date de naissance';

  @override
  String get chooseBirthDate => 'Choisis ta date de naissance.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY est réservé aux personnes de $age ans et plus. Ta date de naissance n\'est jamais affichée et ne peut pas être modifiée ensuite.';
  }

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get continueAction => 'Continuer';

  @override
  String get agreeTerms =>
      'J\'ai lu et j\'accepte les Conditions d\'utilisation.';

  @override
  String get agreePrivacy =>
      'J\'ai lu la Notice d\'information sur la protection des données (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Je donne mon consentement explicite au traitement de mes données personnelles sur des serveurs situés hors de Turquie.';

  @override
  String get agreeCommunityRules =>
      'J\'ai lu et j\'accepte l\'Accord sur les règles de la communauté, les sanctions et les actions en justice.';

  @override
  String get agreeDistanceSales =>
      'J\'ai lu et j\'accepte le Contrat de vente à distance.';

  @override
  String get readAndAccept => 'J\'ai lu et j\'accepte';

  @override
  String get readWholeText =>
      'Merci de lire le texte en entier avant de l’accepter.';

  @override
  String get beforeContinue => 'Avant de continuer';

  @override
  String get consentIntro =>
      'Pour utiliser GWAY, lis et accepte les textes ci-dessous.';

  @override
  String get readText => 'Lire le texte';

  @override
  String get readToEnd => 'Lis le texte jusqu\'au bout pour l\'accepter.';

  @override
  String versionLabel(int version) {
    return 'Version $version';
  }

  @override
  String get legalDocuments => 'Documents juridiques';

  @override
  String get documentNotPublished =>
      'Ce texte n\'est pas publié pour le moment.';

  @override
  String get deletionInfoTitle => 'Supprimer ton compte GWAY';

  @override
  String get deletionInfoIntro =>
      'Tu peux supprimer ton compte et tes données dans l’application ou sur ce site :';

  @override
  String get deletionInfoStep1 =>
      'Connecte-toi à l\'application ou au site GWAY.';

  @override
  String get deletionInfoStep2 =>
      'Va dans Moi → Paramètres → Supprimer le compte.';

  @override
  String get deletionInfoStep3 =>
      'Confirme la suppression. Ton profil est masqué immédiatement.';

  @override
  String get deletionInfoWhat => 'Que supprime-t-on et que conserve-t-on ?';

  @override
  String deletionInfoBody(int days) {
    return 'Tu peux te connecter dans les $days jours et annuler la suppression. Passé ce délai, ton profil, tes publications, photos, messages, adhésions aux groupes, contrôles de localisation et informations de vérification sont définitivement supprimés. Les justificatifs de paiement soumis à une obligation légale de conservation et les journaux d\'opérations anonymes sont conservés pendant la durée prévue par la loi. Pour les comptes fermés pour des raisons de sécurité, le numéro de téléphone est conservé afin d\'empêcher l\'ouverture d\'un nouveau compte avec le même numéro.';
  }

  @override
  String get securityTitle => 'Vérification de sécurité';

  @override
  String get securityChecking => 'Vérification en cours';

  @override
  String get securityWarning =>
      'Votre position, le téléphone utilisé et un VPN ont été détectés. Veuillez respecter les règles du pays où vous vous trouvez et vous connecter en toute sécurité.';

  @override
  String get vpnInstalledWarning =>
      'Une application VPN a été détectée sur votre appareil. Veuillez respecter les règles du pays où vous vous trouvez et vous connecter en toute sécurité.';

  @override
  String get securityWarningTitle => 'Avertissement de sécurité';

  @override
  String get understood => 'J\'ai compris';

  @override
  String get passkeyNotAdded =>
      'Empreinte non ajoutée : l\'opération a été annulée ou cet appareil est déjà enregistré.';

  @override
  String get locationDeniedForever =>
      'Tu as déjà refusé l\'accès à la position. Active-le pour GWAY dans les réglages de l\'appareil et réessaie.';

  @override
  String get locationRequired =>
      'Tu ne peux pas continuer sans l\'accès à la position.';

  @override
  String get locationServiceOff =>
      'Les services de localisation de l\'appareil sont désactivés. Active-les et réessaie.';

  @override
  String get locationTitle => 'Vérifions ta position';

  @override
  String get locationBody =>
      'Pour la sécurité des comptes et contre les faux comptes, GWAY utilise ta position à la connexion et à l\'ouverture de l\'application. Sans accès à la position, l\'application ne s\'ouvre pas.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get grantLocation => 'Autoriser l\'accès à la position';

  @override
  String get readPrivacyNotice => 'Lire la notice d\'information';

  @override
  String get privacyNoticeUnavailable =>
      'La notice d\'information n\'a pas pu être chargée.';

  @override
  String get enterMobileNumber => 'Saisis ton numéro de mobile.';

  @override
  String get speedUpTitle => 'Connecte-toi plus vite';

  @override
  String get speedUpBodyPasskey =>
      'La prochaine fois, valide avec ton empreinte ou un code Google Authenticator au lieu d\'attendre un SMS.';

  @override
  String get speedUpBodyTotp =>
      'La prochaine fois, valide avec un code Google Authenticator au lieu d\'attendre un SMS.';

  @override
  String get addFingerprint => 'Ajouter une empreinte';

  @override
  String get addAuthenticator => 'Ajouter Google Authenticator';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get fingerprintAdded => 'Empreinte ajoutée.';

  @override
  String get verifyPhoneTitle => 'Vérifie ton téléphone';

  @override
  String get verifyPhoneBody =>
      'Valide avec un numéro de mobile du pays où tu te trouves. Ton numéro n\'est jamais montré aux autres.';

  @override
  String get mobilePhone => 'Téléphone mobile';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get verify => 'Valider';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer le code ($seconds s)';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get changeNumber => 'Changer de numéro';

  @override
  String get passkeyFailed =>
      'La vérification a été annulée ou aucune empreinte n\'est enregistrée sur cet appareil. Tu peux choisir une autre méthode.';

  @override
  String get verifySignInTitle => 'Valide ta connexion';

  @override
  String get verifyWithPasskey =>
      'Valide ta connexion avec l\'empreinte, la reconnaissance faciale ou le verrouillage d\'écran de cet appareil.';

  @override
  String get verifyWithTotp =>
      'Saisis le code à 6 chiffres de ton application d\'authentification.';

  @override
  String smsWillSendTo(String phone) {
    return 'Pour ta sécurité, tu dois valider cette connexion. Nous allons envoyer un code au $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Pour ta sécurité, tu dois valider cette connexion. Nous allons envoyer un code à ton numéro enregistré.';

  @override
  String get methodFingerprint => 'Empreinte';

  @override
  String get methodApp => 'Application';

  @override
  String get verifyWithFingerprint => 'Valider avec mon empreinte';

  @override
  String get reviewTitle => 'Connexion sécurisée impossible';

  @override
  String get reviewBody =>
      'Ton compte fait l\'objet d\'un contrôle de sécurité. Une fois le contrôle terminé, tu pourras reprendre là où tu en étais.';

  @override
  String get refreshStatus => 'Actualiser le statut';

  @override
  String get removeTotpTitle => 'Supprimer l\'application d\'authentification';

  @override
  String get removeTotpBody =>
      'Tu ne pourras ensuite valider tes nouvelles connexions que par code SMS.';

  @override
  String get cancel => 'Annuler';

  @override
  String get remove => 'Supprimer';

  @override
  String get totpRemoved => 'Application d\'authentification supprimée.';

  @override
  String get twoFactorTitle => 'Validation en deux étapes';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get notVerifiedYet => 'Pas encore vérifié';

  @override
  String get authenticatorApp => 'Application d\'authentification';

  @override
  String get totpOn =>
      'Activée. Tu peux aussi valider tes nouvelles connexions avec le code de l\'application.';

  @override
  String get totpOff =>
      'Connecte-toi sans attendre de SMS grâce à une application comme Google Authenticator.';

  @override
  String get addTotp => 'Ajouter une application d\'authentification';

  @override
  String get signInRequired => 'Tu dois te connecter.';

  @override
  String passkeyRemoved(String name) {
    return '$name supprimé.';
  }

  @override
  String get passkeysTitle => 'Empreinte et reconnaissance faciale';

  @override
  String get passkeysOff =>
      'Valide tes connexions avec l\'empreinte, la reconnaissance faciale ou le verrouillage d\'écran de ton appareil.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils enregistrés.',
      one: '1 appareil enregistré.',
    );
    return '$_temp0 Cette méthode est proposée en premier à la connexion.';
  }

  @override
  String get notUsedYet => 'Pas encore utilisé';

  @override
  String lastUsed(String date) {
    return 'Dernière utilisation : $date';
  }

  @override
  String get addFingerprintHere => 'Ajouter une empreinte sur cet appareil';

  @override
  String get passkeyUnsupported =>
      'Cet appareil ou ce navigateur ne prend pas en charge la connexion par empreinte.';

  @override
  String passkeyDefaultName(String date) {
    return 'Empreinte · $date';
  }

  @override
  String get totpAdded => 'Application d\'authentification ajoutée.';

  @override
  String get totpStep1 =>
      '1. Ajoute un nouveau compte dans ton application d\'authentification et scanne ce code. Sur le même téléphone, appuie sur « Ouvrir dans l\'appli » ou saisis la clé manuellement.';

  @override
  String get copyKey => 'Copier la clé';

  @override
  String get openInApp => 'Ouvrir dans l\'appli';

  @override
  String get totpStep2 =>
      '2. Saisis le code à 6 chiffres affiché dans l\'application.';

  @override
  String get activate => 'Activer';

  @override
  String get codeHint => 'Code à 6 chiffres';

  @override
  String get enterCode => 'Saisis le code à 6 chiffres.';

  @override
  String get enterSmsCode => 'Saisis le code à 6 chiffres reçu par SMS.';

  @override
  String get enterAppCode => 'Saisis le code à 6 chiffres de l\'application.';

  @override
  String get refresh => 'Actualiser';
}
