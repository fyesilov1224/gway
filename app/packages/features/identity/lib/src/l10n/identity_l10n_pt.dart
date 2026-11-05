// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class IdentityL10nPt extends IdentityL10n {
  IdentityL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get authInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authEmailNotConfirmed =>
      'Você ainda não confirmou seu e-mail. Verifique sua caixa de entrada.';

  @override
  String get authEmailExists =>
      'Já existe uma conta com este e-mail. Tente entrar.';

  @override
  String get authWeakPassword =>
      'A senha deve ter pelo menos 8 caracteres e incluir letra maiúscula, letra minúscula e número.';

  @override
  String get authSamePassword => 'A nova senha deve ser diferente da anterior.';

  @override
  String get authInvalidEmail => 'Digite um e-mail válido.';

  @override
  String get authUserBanned =>
      'Você não pode entrar porque sua conta está suspensa.';

  @override
  String get authProviderDisabled =>
      'Este método de login não está disponível no momento.';

  @override
  String ageMinimum(int age) {
    return 'Você precisa ter pelo menos $age anos para usar o GWAY.';
  }

  @override
  String get deletionPendingTitle => 'Sua conta está prestes a ser excluída';

  @override
  String get deletionRequested => 'Recebemos seu pedido de exclusão da conta.';

  @override
  String deletionScheduled(String date) {
    return 'Sua conta e todos os seus dados serão excluídos definitivamente em $date. Até lá, você pode mudar de ideia.';
  }

  @override
  String get undoDeletion => 'Cancelar exclusão';

  @override
  String get signOut => 'Sair';

  @override
  String get bannedTitle => 'Sua conta foi encerrada definitivamente';

  @override
  String get suspendedTitle => 'Sua conta foi suspensa';

  @override
  String get bannedBody =>
      'A equipe da plataforma encerrou sua conta definitivamente. Seu perfil não está mais visível para ninguém.';

  @override
  String suspendedBody(String date) {
    return 'Sua conta está suspensa até $date. Durante esse período, você não pode usar o app; seu perfil mostra a suspensão.';
  }

  @override
  String banReason(String reason) {
    return 'Motivo do banimento: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Motivo da suspensão: $reason';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get beforeDeleting => 'Antes de excluir sua conta';

  @override
  String get deletionHidesNow =>
      'Seu perfil é ocultado na hora; ninguém poderá encontrar você.';

  @override
  String deletionGraceRestore(int days) {
    return 'Você pode entrar em até $days dias e cancelar a exclusão.';
  }

  @override
  String get deletionAfterGrace =>
      'Depois disso, seu perfil, suas fotos e todos os seus dados são excluídos definitivamente.';

  @override
  String get deletionUnderstood => 'Entendi, quero excluir minha conta.';

  @override
  String get deleteMyAccount => 'Excluir minha conta';

  @override
  String get heroTitle => 'Sua comunidade está esperando por você.';

  @override
  String get heroBody =>
      'Da trilha à música, da corrida à arte: encontre seu grupo, planejem juntos e estejam lá ao mesmo tempo.';

  @override
  String get heroPointGroups =>
      'Entre em grupos ou crie sua própria comunidade';

  @override
  String get heroPointEvents =>
      'Adicione eventos à sua agenda e encontre parceiros de equipe';

  @override
  String get heroPointLive =>
      'Encontre seu grupo em conversas de áudio ao vivo';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get signInSubtitle =>
      'Continue de onde parou com seus grupos e amigos.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get continueWithApple => 'Continuar com a Apple';

  @override
  String get noAccountSignUp => 'Não tem uma conta? Cadastre-se';

  @override
  String get signUp => 'Cadastrar-se';

  @override
  String get signUpSubtitle =>
      'Encontre seus grupos, participe de eventos e conheça pessoas novas.';

  @override
  String get passwordRepeat => 'Confirmar senha';

  @override
  String get passwordsDontMatch => 'As senhas não coincidem.';

  @override
  String get haveAccountSignIn => 'Já tem uma conta? Entre';

  @override
  String get checkEmailTitle => 'Verifique seu e-mail';

  @override
  String checkEmailBody(String email) {
    return 'Enviamos um link de verificação para $email. Você poderá entrar depois de tocar no link.';
  }

  @override
  String get linkResent => 'Enviamos o link novamente.';

  @override
  String get backToSignIn => 'Voltar para o login';

  @override
  String get resendLink => 'Reenviar link';

  @override
  String get resetPasswordTitle => 'Redefina sua senha';

  @override
  String get resetPasswordSubtitle =>
      'Digite seu e-mail e enviaremos um link para redefinir a senha.';

  @override
  String get resetLinkSent =>
      'Se houver uma conta com este endereço, enviamos um link de redefinição.';

  @override
  String get sendLink => 'Enviar link';

  @override
  String get newPasswordTitle => 'Defina uma nova senha';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get newPasswordRepeat => 'Confirmar nova senha';

  @override
  String get savePassword => 'Salvar senha';

  @override
  String get enterEmail => 'Digite seu e-mail.';

  @override
  String get passwordMin8 => 'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get passwordMix =>
      'A senha deve incluir letra maiúscula, letra minúscula e número.';

  @override
  String get enterPassword => 'Digite sua senha.';

  @override
  String get birthDateTitle => 'Sua data de nascimento';

  @override
  String get chooseBirthDate => 'Escolha sua data de nascimento.';

  @override
  String birthDateExplain(int age) {
    return 'O GWAY é para pessoas com $age anos ou mais. Sua data de nascimento não é mostrada a ninguém e não pode ser alterada depois.';
  }

  @override
  String get chooseDate => 'Escolher data';

  @override
  String get continueAction => 'Continuar';

  @override
  String get agreeTerms => 'Li e aceito os Termos de Uso.';

  @override
  String get agreePrivacy => 'Li o Aviso de Privacidade (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Dou meu consentimento explícito para que meus dados pessoais sejam tratados em servidores fora da Turquia.';

  @override
  String get agreeCommunityRules =>
      'Li e aceito o Acordo de Regras da Comunidade, Sanções e Medidas Legais.';

  @override
  String get agreeDistanceSales =>
      'Li e aceito o Contrato de Venda a Distância.';

  @override
  String get readAndAccept => 'Li e aceito';

  @override
  String get readWholeText => 'Leia o texto completo antes de aceitar.';

  @override
  String get beforeContinue => 'Antes de continuar';

  @override
  String get consentIntro =>
      'Para usar o GWAY, leia e aceite os textos abaixo.';

  @override
  String get readText => 'Ler o texto';

  @override
  String get readToEnd => 'Leia o texto até o fim para aceitar.';

  @override
  String versionLabel(int version) {
    return 'Versão $version';
  }

  @override
  String get legalDocuments => 'Documentos legais';

  @override
  String get documentNotPublished =>
      'Este texto não está publicado no momento.';

  @override
  String get deletionInfoTitle => 'Excluir sua conta GWAY';

  @override
  String get deletionInfoIntro =>
      'Você pode excluir sua conta e seus dados no app ou neste site:';

  @override
  String get deletionInfoStep1 => 'Entre no app ou no site do GWAY.';

  @override
  String get deletionInfoStep2 => 'Vá em Eu → Configurações → Excluir conta.';

  @override
  String get deletionInfoStep3 =>
      'Confirme a exclusão. Seu perfil é ocultado na hora.';

  @override
  String get deletionInfoWhat => 'O que é excluído e o que fica?';

  @override
  String deletionInfoBody(int days) {
    return 'Você pode entrar em até $days dias e cancelar a exclusão. Depois desse prazo, seu perfil, publicações, fotos, mensagens, participações em grupos, registros de verificação de localização e dados de verificação são excluídos definitivamente. Registros de pagamento com obrigação legal de guarda e registros anônimos de operações são mantidos pelo prazo exigido por lei. Em contas encerradas por motivos de segurança, o número de telefone é mantido para impedir a abertura de uma nova conta com o mesmo número.';
  }

  @override
  String get securityTitle => 'Verificação de segurança';

  @override
  String get securityChecking => 'Verificando a segurança';

  @override
  String get securityWarning =>
      'Sua localização, o telefone que você usa e uma VPN foram detectados. Respeite as regras do país em que você está e entre com segurança.';

  @override
  String get vpnInstalledWarning =>
      'Um app de VPN foi detectado no seu dispositivo. Respeite as regras do país em que você está e entre com segurança.';

  @override
  String get securityWarningTitle => 'Aviso de segurança';

  @override
  String get understood => 'Entendi';

  @override
  String get passkeyNotAdded =>
      'Digital não adicionada: a ação foi cancelada ou este dispositivo já está cadastrado.';

  @override
  String get locationDeniedForever =>
      'Você recusou o acesso à localização antes. Ative-o para o GWAY nas configurações do dispositivo e tente novamente.';

  @override
  String get locationRequired =>
      'Você não pode continuar sem acesso à localização.';

  @override
  String get locationServiceOff =>
      'Os serviços de localização estão desativados. Ative-os e tente novamente.';

  @override
  String get locationTitle => 'Vamos verificar sua localização';

  @override
  String get locationBody =>
      'Para a segurança da conta e para evitar contas falsas, o GWAY usa sua localização ao entrar e abrir o app. Sem acesso à localização, o app não abre.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get grantLocation => 'Permitir acesso à localização';

  @override
  String get readPrivacyNotice => 'Ler o aviso de privacidade';

  @override
  String get privacyNoticeUnavailable =>
      'Não foi possível carregar o aviso de privacidade.';

  @override
  String get enterMobileNumber => 'Digite seu número de celular.';

  @override
  String get speedUpTitle => 'Entre mais rápido';

  @override
  String get speedUpBodyPasskey =>
      'Na próxima vez, confirme com sua digital ou um código do Google Authenticator sem esperar um SMS.';

  @override
  String get speedUpBodyTotp =>
      'Na próxima vez, confirme com um código do Google Authenticator sem esperar um SMS.';

  @override
  String get addFingerprint => 'Adicionar digital';

  @override
  String get addAuthenticator => 'Adicionar Google Authenticator';

  @override
  String get notNow => 'Agora não';

  @override
  String get fingerprintAdded => 'Digital adicionada.';

  @override
  String get verifyPhoneTitle => 'Verifique seu telefone';

  @override
  String get verifyPhoneBody =>
      'Confirme com um número de celular do país em que você está. Seu número nunca é mostrado a outras pessoas.';

  @override
  String get mobilePhone => 'Celular';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get verify => 'Confirmar';

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código ($seconds s)';
  }

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get changeNumber => 'Alterar número';

  @override
  String get passkeyFailed =>
      'A verificação foi cancelada ou não há digital cadastrada neste dispositivo. Você pode escolher outro método.';

  @override
  String get verifySignInTitle => 'Confirme seu login';

  @override
  String get verifyWithPasskey =>
      'Confirme seu login com a digital, o reconhecimento facial ou o bloqueio de tela deste dispositivo.';

  @override
  String get verifyWithTotp =>
      'Digite o código de 6 dígitos do seu app autenticador.';

  @override
  String smsWillSendTo(String phone) {
    return 'Para sua segurança, você precisa confirmar este login. Enviaremos um código para $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Para sua segurança, você precisa confirmar este login. Enviaremos um código para seu número cadastrado.';

  @override
  String get methodFingerprint => 'Digital';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Confirmar com digital';

  @override
  String get reviewTitle => 'Não foi possível entrar com segurança';

  @override
  String get reviewBody =>
      'Sua conta está em análise de segurança. Quando a análise terminar, você poderá continuar de onde parou.';

  @override
  String get refreshStatus => 'Atualizar status';

  @override
  String get removeTotpTitle => 'Remover app autenticador';

  @override
  String get removeTotpBody =>
      'A partir de agora, você só poderá confirmar novos logins com código SMS.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get totpRemoved => 'App autenticador removido.';

  @override
  String get twoFactorTitle => 'Verificação em duas etapas';

  @override
  String get phoneNumber => 'Número de telefone';

  @override
  String get notVerifiedYet => 'Ainda não verificado';

  @override
  String get authenticatorApp => 'App autenticador';

  @override
  String get totpOn =>
      'Ativado. Você também pode confirmar novos logins com o código do app.';

  @override
  String get totpOff =>
      'Entre sem esperar um SMS usando um app como o Google Authenticator.';

  @override
  String get addTotp => 'Adicionar app autenticador';

  @override
  String get signInRequired => 'Você precisa entrar.';

  @override
  String passkeyRemoved(String name) {
    return '$name removido.';
  }

  @override
  String get passkeysTitle => 'Digital e reconhecimento facial';

  @override
  String get passkeysOff =>
      'Confirme logins com a digital, o reconhecimento facial ou o bloqueio de tela do dispositivo.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos cadastrados.',
      one: '1 dispositivo cadastrado.',
    );
    return '$_temp0 Este método é pedido primeiro no login.';
  }

  @override
  String get notUsedYet => 'Ainda não usado';

  @override
  String lastUsed(String date) {
    return 'Último uso: $date';
  }

  @override
  String get addFingerprintHere => 'Adicionar digital neste dispositivo';

  @override
  String get passkeyUnsupported =>
      'Este dispositivo ou navegador não aceita login com digital.';

  @override
  String passkeyDefaultName(String date) {
    return 'Digital · $date';
  }

  @override
  String get totpAdded => 'App autenticador adicionado.';

  @override
  String get totpStep1 =>
      '1. Adicione uma nova conta no seu app autenticador e escaneie este código. No mesmo celular, toque em \"Abrir no app\" ou digite a chave manualmente.';

  @override
  String get copyKey => 'Copiar chave';

  @override
  String get openInApp => 'Abrir no app';

  @override
  String get totpStep2 => '2. Digite o código de 6 dígitos mostrado no app.';

  @override
  String get activate => 'Ativar';

  @override
  String get codeHint => 'Código de 6 dígitos';

  @override
  String get enterCode => 'Digite o código de 6 dígitos.';

  @override
  String get enterSmsCode => 'Digite o código de 6 dígitos do SMS.';

  @override
  String get enterAppCode => 'Digite o código de 6 dígitos do app.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get language => 'Idioma';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get languageNote =>
      'Menus, botões, notificações e contratos aparecem neste idioma. Publicações, comentários e mensagens ficam no idioma em que foram escritos.';

  @override
  String get or => 'ou';

  @override
  String get legalTranslationNote =>
      'Esta tradução é informativa. O texto vinculante, e o que você aceita, é o original em turco.';

  @override
  String get legalShowOriginal => 'Ver o original em turco';

  @override
  String get legalShowTranslation => 'Ver a tradução';
}
