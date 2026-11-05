// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class ProfileL10nPt extends ProfileL10n {
  ProfileL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get unsupportedImage =>
      'Este tipo de arquivo não é compatível. Escolha JPEG, PNG ou WebP.';

  @override
  String get usernameTaken =>
      'Este nome de usuário já está em uso. Tente outro.';

  @override
  String get checkInput => 'Confira os dados informados.';

  @override
  String get usernameReserved =>
      'Este nome de usuário não pode ser usado. Tente outro.';

  @override
  String get usernameCooldown =>
      'Você só pode mudar seu nome de usuário uma vez a cada 30 dias.';

  @override
  String get maxInterests10 => 'Você pode escolher até 10 interesses.';

  @override
  String get levelBeginner => 'Iniciante';

  @override
  String get levelBeginnerHint => 'Estou começando';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelIntermediateHint => 'Pratico com regularidade';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelAdvancedHint => 'Tenho experiência';

  @override
  String get slotWeekdayMorning => 'Manhãs durante a semana';

  @override
  String get slotWeekdayNoon => 'Meio-dia durante a semana';

  @override
  String get slotWeekdayEvening => 'Noites durante a semana';

  @override
  String get slotWeekendMorning => 'Manhãs de fim de semana';

  @override
  String get slotWeekendAfternoon => 'Tardes de fim de semana';

  @override
  String get slotWeekendEvening => 'Noites de fim de semana';

  @override
  String get partMorning => 'Manhã';

  @override
  String get partNoon => 'Tarde';

  @override
  String get partEvening => 'Noite';

  @override
  String get goalFun => 'Me divertir';

  @override
  String get goalFitness => 'Manter a forma';

  @override
  String get goalCompetition => 'Me preparar para competições';

  @override
  String get goalLearning => 'Aprender coisas novas';

  @override
  String get goalMentoring => 'Compartilhar minha experiência';

  @override
  String get goalSocial => 'Conhecer pessoas novas';

  @override
  String get freqMonthly => 'Algumas vezes por mês';

  @override
  String get freqWeekly => 'Uma vez por semana';

  @override
  String get freqFewWeekly => '2–3 vezes por semana';

  @override
  String get freqDaily => 'Quase todo dia';

  @override
  String get sizePair => 'Em dupla';

  @override
  String get sizeSmall => 'Grupo pequeno (3–6)';

  @override
  String get sizeLarge => 'Grupo grande';

  @override
  String get looking => 'Procurando equipe';

  @override
  String lookingWithLevel(String level) {
    return 'Procurando equipe · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Mesma atividade: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Interesses em comum: $list';
  }

  @override
  String get reasonProvince => 'Vocês estão na mesma província';

  @override
  String reasonGroup(String group) {
    return 'Grupo em comum: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count grupos em comum';
  }

  @override
  String reasonLevel(String level) {
    return 'Mesmo nível: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Horário em comum: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Objetivos em comum: $list';
  }

  @override
  String get reasonFrequency =>
      'Vocês querem se encontrar com a mesma frequência';

  @override
  String get hasVehicle => 'Tem veículo';

  @override
  String get hasEquipment => 'Tem o próprio equipamento';

  @override
  String get usernameRequired => 'Escolha um nome de usuário.';

  @override
  String usernameMin(int min) {
    return 'O nome de usuário deve ter pelo menos $min caracteres.';
  }

  @override
  String usernameMax(int max) {
    return 'O nome de usuário pode ter no máximo $max caracteres.';
  }

  @override
  String get usernameChars =>
      'Use apenas a–z, 0–9, sublinhado (_) e ponto (.).';

  @override
  String get usernameDots =>
      'O nome de usuário não pode começar nem terminar com ponto.';

  @override
  String get usernameDoubleDot => 'Não é possível usar dois pontos seguidos.';

  @override
  String get nameRequired => 'Digite seu nome.';

  @override
  String nameMax(int max) {
    return 'O nome pode ter no máximo $max caracteres.';
  }

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get save => 'Salvar';

  @override
  String get profileInfo => 'Dados do perfil';

  @override
  String get profileInfoHint =>
      'Esses dados ficam visíveis para todos no seu perfil.';

  @override
  String get yourName => 'Seu nome';

  @override
  String get usernameEvery30 =>
      'Você pode mudar seu nome de usuário a cada 30 dias.';

  @override
  String usernameLockedUntil(String date) {
    return 'Você poderá mudá-lo depois de $date.';
  }

  @override
  String get about => 'Sobre mim';

  @override
  String get aboutHint => 'Fale de você e das atividades de que gosta.';

  @override
  String get interests => 'Interesses';

  @override
  String interestsMax(int max) {
    return 'Você pode escolher até $max.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get remove => 'Remover';

  @override
  String get removeCover => 'Remover foto de capa';

  @override
  String get addCover => 'Adicionar capa';

  @override
  String get changeCover => 'Alterar capa';

  @override
  String get changeAvatar => 'Alterar foto de perfil';

  @override
  String get photos => 'Foto de perfil e capa';

  @override
  String get photosHint => 'JPEG, PNG ou WebP · até 5 MB';

  @override
  String get addAvatar => 'Adicionar foto de perfil';

  @override
  String get removeAvatar => 'Remover foto de perfil';

  @override
  String get followers => 'Seguidores';

  @override
  String get following => 'Seguindo';

  @override
  String get privateLists => 'Esta conta é privada. Siga para ver as listas.';

  @override
  String get backToProfile => 'Voltar ao perfil';

  @override
  String get noFollowers => 'Ainda sem seguidores.';

  @override
  String get noFollowing => 'Ainda não segue ninguém.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get removeFollower => 'Remover seguidor';

  @override
  String removeFollowerBody(String username) {
    return 'Remover $username dos seus seguidores? A pessoa não será avisada.';
  }

  @override
  String get removeAction => 'Remover';

  @override
  String get friends => 'Vocês são amigos';

  @override
  String get followRequests => 'Solicitações para seguir';

  @override
  String get noFollowRequests =>
      'Nenhuma solicitação pendente. Contas privadas aprovam solicitações aqui.';

  @override
  String get approve => 'Aprovar';

  @override
  String get delete => 'Excluir';

  @override
  String get blockedAccounts => 'Contas bloqueadas';

  @override
  String get noBlocked =>
      'Você não bloqueou ninguém. É possível bloquear pelo menu de um perfil.';

  @override
  String get unblock => 'Desbloquear';

  @override
  String get onboardWho => 'Vamos conhecer você';

  @override
  String get onboardWhoHint =>
      'Escolha o nome e o nome de usuário que aparecerão no seu perfil.';

  @override
  String get onboardPhoto => 'Foto de perfil';

  @override
  String get onboardPhotoHint =>
      'Para seus grupos reconhecerem você. Você também pode adicionar depois.';

  @override
  String get onboardInterests => 'Seus interesses';

  @override
  String onboardInterestsHint(int max) {
    return 'Escolha até $max para sugerirmos grupos para você.';
  }

  @override
  String get back => 'Voltar';

  @override
  String stepOf(int step, int total) {
    return 'Etapa $step de $total';
  }

  @override
  String get signOut => 'Sair';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String get continueAction => 'Continuar';

  @override
  String get finish => 'Concluir';

  @override
  String get usernameHelper => 'Use letras minúsculas, números, _ e .';

  @override
  String get avatarPreview => 'Prévia da foto de perfil';

  @override
  String get choosePhoto => 'Escolher foto';

  @override
  String get chooseAnotherPhoto => 'Escolher outra foto';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configurações';

  @override
  String get profileNotFound =>
      'Este perfil não foi encontrado ou não está mais visível.';

  @override
  String get backToMyProfile => 'Voltar ao meu perfil';

  @override
  String suspendedUntil(String date) {
    return 'Esta conta está suspensa até $date.';
  }

  @override
  String get followsYou => 'Segue você';

  @override
  String get yourTeammate => 'Seu parceiro de equipe';

  @override
  String joined(String date) {
    return 'Entrou em $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitações para seguir aguardam aprovação.',
      one: '1 solicitação para seguir aguarda aprovação.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Revisar';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos de parceria aguardam você.',
      one: '1 pedido de parceria aguarda você.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Você bloqueou esta conta';

  @override
  String get youBlockedHint =>
      'Se desbloquear, vocês voltarão a ver as publicações um do outro.';

  @override
  String get privateAccount => 'Esta conta é privada';

  @override
  String get privateAccountHint =>
      'Siga esta conta para ver fotos, vídeos e stories.';

  @override
  String get addInterestsNudge =>
      'Adicione seus interesses e encontraremos grupos e parceiros para você.';

  @override
  String get add => 'Adicionar';

  @override
  String blockTitle(String username) {
    return 'Bloquear $username?';
  }

  @override
  String get blockBody =>
      'A pessoa não verá seu perfil, publicações nem stories, não poderá encontrar você nem escrever. Vocês deixarão de se seguir. Ela não será avisada do bloqueio.';

  @override
  String get block => 'Bloquear';

  @override
  String get becomeTeammates => 'Formar parceria';

  @override
  String nowTeammates(String name) {
    return 'Você e $name agora são parceiros de equipe.';
  }

  @override
  String get acceptTeammate => 'Aceitar pedido de parceria';

  @override
  String get requestWithdrawn => 'Pedido retirado.';

  @override
  String get withdrawTeammate => 'Retirar pedido de parceria';

  @override
  String get teammateEnded => 'A parceria foi encerrada.';

  @override
  String get endTeammate => 'Encerrar parceria';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get linkCopied => 'Link do perfil copiado.';

  @override
  String get copyLink => 'Copiar link do perfil';

  @override
  String get removedFromFollowers => 'Removido dos seus seguidores.';

  @override
  String get removeFromFollowers => 'Remover dos meus seguidores';

  @override
  String get report => 'Denunciar';

  @override
  String get unblocked => 'Desbloqueado.';

  @override
  String get statPosts => 'Publicações';

  @override
  String get statFollowers => 'Seguidores';

  @override
  String get statFollowing => 'Seguindo';

  @override
  String withdrawFollowBody(String username) {
    return 'Retirar sua solicitação para seguir $username?';
  }

  @override
  String unfollowBody(String username) {
    return 'Deixar de seguir $username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Deixar de seguir $username? A conta é privada; para ver as publicações, você precisará pedir de novo.';
  }

  @override
  String get withdrawRequest => 'Retirar solicitação';

  @override
  String get unfollow => 'Deixar de seguir';

  @override
  String get followBack => 'Seguir de volta';

  @override
  String get follow => 'Seguir';

  @override
  String get requestSent => 'Solicitado';

  @override
  String get followingState => 'Seguindo';

  @override
  String noAccountMatch(String query) {
    return 'Nenhuma conta corresponde a \"$query\".';
  }

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get searchHint => 'Comece a digitar para buscar pessoas ou tags.';

  @override
  String get refreshSuggestions => 'Atualizar sugestões';

  @override
  String get suggestionsForYou => 'Sugestões para você';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seguido por $count pessoas que você segue',
      one: 'Seguido por 1 pessoa que você segue',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Conta popular';

  @override
  String get seePackage => 'Ver o plano';

  @override
  String requestSentNotify(String name) {
    return 'Pedido enviado. Avisaremos quando $name aceitar.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Formar parceria com $name';
  }

  @override
  String get shortMessage => 'Uma mensagem curta (opcional)';

  @override
  String get shortMessageHint => 'Sábado de manhã no parque?';

  @override
  String get sendRequest => 'Enviar pedido';

  @override
  String get findTeammates => 'Encontrar parceiros de equipe';

  @override
  String get myTeammatePrefs => 'Minhas preferências de parceria';

  @override
  String get tabSuggestions => 'Sugestões';

  @override
  String get tabRequests => 'Pedidos';

  @override
  String tabRequestsCount(int count) {
    return 'Pedidos ($count)';
  }

  @override
  String get tabMyTeam => 'Minha equipe';

  @override
  String get findYourTeammate => 'Encontre seu parceiro de equipe';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas querem ser suas parceiras de equipe',
      one: '1 pessoa quer ser sua parceira de equipe',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Ver sugestões, enviar e aceitar pedidos e conversar com seus parceiros fazem parte do plano Parceiro de Equipe.';

  @override
  String get beVisible => 'Apareça também';

  @override
  String get beVisibleBody =>
      'Ative \"Procuro equipe\" e quem curte as mesmas coisas poderá enviar pedidos a você.';

  @override
  String get setPrefs => 'Definir minhas preferências';

  @override
  String get nowPublicSuggest =>
      'Sua conta agora é pública; você pode aparecer nas sugestões.';

  @override
  String get privateHidden =>
      'Sua conta é privada; você não aparece nas sugestões';

  @override
  String get privateHiddenBody =>
      'Contas privadas não aparecem nas sugestões de parceria. Se você tornar sua conta pública, as solicitações pendentes também serão aprovadas.';

  @override
  String get makePublic => 'Tornar minha conta pública';

  @override
  String get noSuggestions =>
      'Ainda não há ninguém compatível. Preencha seus interesses e preferências para receber mais sugestões.';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }

  @override
  String get whySuggested => 'Por que foi sugerido';

  @override
  String get noPendingTeammate => 'Nenhum pedido de parceria pendente.';

  @override
  String get seeSuggestions => 'Ver sugestões';

  @override
  String get incoming => 'Recebidos';

  @override
  String get accept => 'Aceitar';

  @override
  String get decline => 'Recusar';

  @override
  String get requestDeclined => 'Pedido recusado.';

  @override
  String get outgoing => 'Enviados';

  @override
  String get awaitingReply => 'Aguardando resposta';

  @override
  String get withdraw => 'Retirar';

  @override
  String get noTeammates =>
      'Você ainda não tem parceiros. Comece enviando um pedido a alguém sugerido.';

  @override
  String optionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String get teammatePrefs => 'Preferências de parceria';

  @override
  String get prefsSavedVisible =>
      'Preferências salvas. Agora você aparece nas sugestões.';

  @override
  String get prefsSaved => 'Preferências salvas.';

  @override
  String get whatToDo => 'O que você quer fazer?';

  @override
  String activitiesHint(int max) {
    return 'Atividades para as quais você procura parceiros. Até $max.';
  }

  @override
  String get yourLevel => 'Seu nível';

  @override
  String get yourGoals => 'Seus objetivos';

  @override
  String get multipleChoice => 'Você pode escolher mais de um.';

  @override
  String get howOften => 'Com que frequência quer se encontrar?';

  @override
  String get whenFree => 'Quando você está livre?';

  @override
  String get whenFreeHint => 'Toque nos horários em que está livre.';

  @override
  String get whatTeam => 'Que tipo de equipe você quer?';

  @override
  String get whichProvince => 'Em que província você está?';

  @override
  String get provinceHint =>
      'Usada só para sugestões; não aparece no seu perfil.';

  @override
  String get province => 'Província';

  @override
  String get ratherNotSay => 'Prefiro não dizer';

  @override
  String get extras => 'Informações extras';

  @override
  String get iHaveVehicle => 'Tenho veículo';

  @override
  String get iHaveVehicleHint => 'Posso dar carona.';

  @override
  String get iHaveEquipment => 'Tenho meu próprio equipamento';

  @override
  String get iHaveEquipmentHint =>
      'Tenho bicicleta, barraca, raquete ou outro equipamento.';

  @override
  String get describeYourself => 'Descreva-se';

  @override
  String get describeHint => 'Aparece abaixo do seu nome nas sugestões.';

  @override
  String get describeExample =>
      'Procuro alguém para caminhadas nas manhãs de fim de semana.';

  @override
  String get willAppear => 'Você vai aparecer nas sugestões.';

  @override
  String get notAppearing => 'No momento você não aparece nas sugestões.';

  @override
  String get lookingForTeam => 'Procuro equipe';

  @override
  String get lookingOn =>
      'Você aparece nas sugestões; podem enviar pedidos de parceria a você.';

  @override
  String get lookingOff =>
      'Ative e quem curte as mesmas coisas vai encontrar você. Contas privadas não aparecem nas sugestões.';

  @override
  String prefsComplete(int percent) {
    return 'Preferências $percent% completas';
  }

  @override
  String get prefsCompleteHint =>
      'Quanto mais você preencher, melhores serão as sugestões.';

  @override
  String get weekday => 'Dias úteis';

  @override
  String get weekend => 'Fim de semana';

  @override
  String get username => 'Nome de usuário';

  @override
  String get available => 'Disponível';

  @override
  String get taken => 'Em uso';

  @override
  String blockedUser(String username) {
    return '$username foi bloqueado.';
  }
}
