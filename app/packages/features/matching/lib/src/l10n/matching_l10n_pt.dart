// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class MatchingL10nPt extends MatchingL10n {
  MatchingL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get unsupportedImage =>
      'Só é possível enviar fotos JPEG, PNG ou WebP.';

  @override
  String get modeFriend => 'Amizade';

  @override
  String get modeDating => 'Namoro';

  @override
  String get genderWoman => 'Mulher';

  @override
  String get genderMan => 'Homem';

  @override
  String get genderNonbinary => 'Não binário';

  @override
  String get adultsOnly => 'O match é só para maiores de 18 anos.';

  @override
  String get pickMode => 'Escolha pelo menos um modo: Amizade ou Namoro.';

  @override
  String get pickInterest => 'Escolha quem você procura no Namoro.';

  @override
  String get ageRangeInvalid => 'A faixa etária é inválida.';

  @override
  String sharedGroup(String group) {
    return 'Grupo em comum: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Em comum: $group e mais $count grupos',
      one: 'Em comum: $group e mais 1 grupo',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'Meus matches';

  @override
  String get pkgRevealText => 'Veja com quem deu match: nome, fotos e perfil.';

  @override
  String get pkgChat => 'Chat de Match';

  @override
  String get pkgChatText => 'Escreva para seus matches. Inclui ver os matches.';

  @override
  String get pkgAdmirers => 'Quem curtiu você';

  @override
  String get pkgAdmirersText =>
      'Veja quem curtiu você e dê match na hora curtindo de volta.';

  @override
  String get pkgUnlimited => 'Curtidas ilimitadas';

  @override
  String get pkgUnlimitedText =>
      'Sem limite diário; inclui desfazer e filtros.';

  @override
  String get pkgSuper => 'Super Curtida';

  @override
  String get pkgSuperText =>
      '5 Super Curtidas por dia; a pessoa vê você primeiro no baralho.';

  @override
  String get pkgBoost => 'Destaque';

  @override
  String get pkgBoostText =>
      'Uma vez por dia, apareça no topo dos baralhos dos grupos em comum por 30 minutos.';

  @override
  String get pkgTeammates => 'Parceiro de Equipe';

  @override
  String get pkgTeammatesText =>
      'Envie pedidos de parceiro e converse com seus parceiros.';

  @override
  String get pkgAll => 'Tudo em um';

  @override
  String get pkgAllText =>
      'Todos os planos em um, bem mais barato do que separados.';

  @override
  String get superLikedYou => 'Deu uma Super Curtida em você';

  @override
  String get options => 'Opções';

  @override
  String get fullProfile => 'Perfil completo';

  @override
  String get stampLike => 'CURTIR';

  @override
  String get stampPass => 'PASSAR';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, foto $number';
  }

  @override
  String get about => 'Sobre';

  @override
  String get interests => 'Interesses';

  @override
  String get sharedGroupsTitle => 'Grupos em comum';

  @override
  String get createProfileTitle => 'Criar perfil de match';

  @override
  String get myProfile => 'Meu perfil de match';

  @override
  String get birthDateLabel => 'Sua data de nascimento';

  @override
  String get pickBasics => 'Escolha data de nascimento, gênero e província.';

  @override
  String get confirmAgeConsent =>
      'Para continuar, confirme que tem mais de 18 anos e dê seu consentimento explícito.';

  @override
  String profileReady(int min) {
    return 'Seu perfil está pronto. Agora adicione pelo menos $min fotos.';
  }

  @override
  String get saved => 'Salvo.';

  @override
  String get pickBirthDate => 'Escolher data de nascimento';

  @override
  String ageNote(int age) {
    return '$age anos · seu cartão mostra só a idade';
  }

  @override
  String get gender => 'Gênero';

  @override
  String get province => 'Província';

  @override
  String get aboutHint => 'Fale sobre você';

  @override
  String get jobOptional => 'Profissão (opcional)';

  @override
  String get educationOptional => 'Formação (opcional)';

  @override
  String get interestsFromProfile =>
      'Seus interesses vêm do seu perfil social.';

  @override
  String get lookingFor => 'O que você procura?';

  @override
  String get friendHint => 'Pessoas para ir a eventos e conversar';

  @override
  String get datingHint => 'Um relacionamento romântico';

  @override
  String get whoLookingFor => 'Quem você procura?';

  @override
  String ageRange(int min, int max) {
    return 'Faixa etária: $min–$max';
  }

  @override
  String get consentTitle => 'Consentimento';

  @override
  String get iam18 => 'Tenho mais de 18 anos.';

  @override
  String get consentText =>
      'Para o match, dou consentimento explícito ao tratamento do meu gênero, de quem procuro, da minha data de nascimento, da minha província e das minhas fotos, e à sua exibição a pessoas dos meus grupos em comum que ativaram o match. Posso retirar o consentimento a qualquer momento apagando meus dados de match.';

  @override
  String get createProfile => 'Criar meu perfil';

  @override
  String get save => 'Salvar';

  @override
  String get photos => 'Fotos';

  @override
  String photosMin(int min) {
    return 'Adicione pelo menos $min fotos para seu cartão aparecer. A primeira é a capa.';
  }

  @override
  String photosMax(int max) {
    return 'Até $max fotos. A primeira é a capa; toque numa foto para trocá-la.';
  }

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get cover => 'Capa';

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get pauseProfile => 'Pausar meu perfil';

  @override
  String get pauseHint =>
      'Ninguém vê você e não chegam novos cartões; seus matches e conversas continuam.';

  @override
  String get deleteData => 'Apagar meus dados de match';

  @override
  String get deleteDataHint =>
      'Perfil, fotos e curtidas são apagados; seus matches terminam. Seu consentimento é retirado.';

  @override
  String get deleteDataTitle => 'Apagar dados de match';

  @override
  String get deleteDataBody =>
      'Seu perfil de match, fotos e curtidas são apagados para sempre e todos os matches terminam. Não é possível desfazer.';

  @override
  String get delete => 'Apagar';

  @override
  String get dataDeleted => 'Seus dados de match foram apagados.';

  @override
  String get itsAMatch => 'Deu match!';

  @override
  String bothLiked(String name) {
    return 'Você e $name curtiram um ao outro.';
  }

  @override
  String get keepSwiping => 'Continuar deslizando';

  @override
  String get sendMessage => 'Enviar mensagem';

  @override
  String get reportProfile => 'Denunciar perfil';

  @override
  String get reportPhoto => 'Denunciar esta foto';

  @override
  String get block => 'Bloquear';

  @override
  String get blockHint => 'Vocês não se verão em lugar nenhum.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get newMatch => 'Você deu match com alguém!';

  @override
  String tapToSee(String date) {
    return 'Toque para ver quem é · $date';
  }

  @override
  String get revealReason =>
      'Você deu match! Pegue o plano Meus matches para ver quem é.';

  @override
  String get keepFriend => 'Ficar só na amizade';

  @override
  String get keepDating => 'Ficar só no namoro';

  @override
  String keepFriendBody(String name) {
    return 'O match de namoro com $name termina para os dois; o de amizade e a conversa continuam.';
  }

  @override
  String keepDatingBody(String name) {
    return 'O match de amizade com $name termina para os dois; o de namoro e a conversa continuam.';
  }

  @override
  String get keptFriend => 'Agora vocês têm match só de amizade.';

  @override
  String get keptDating => 'Agora vocês têm match só de namoro.';

  @override
  String get continueAction => 'Continuar';

  @override
  String get endMatch => 'Encerrar match';

  @override
  String endMatchBody(String name) {
    return 'Seu match com $name termina e a conversa fecha para os dois. Não é possível desfazer.';
  }

  @override
  String get end => 'Encerrar';

  @override
  String get matchEnded => 'O match terminou.';

  @override
  String get noMatches =>
      'Ainda não há matches. Curtidas mútuas aparecem aqui.';

  @override
  String get backToDiscover => 'Voltar a descobrir';

  @override
  String get report => 'Denunciar';

  @override
  String get matching => 'Match';

  @override
  String get admirers => 'Quem curtiu você';

  @override
  String get packages => 'Planos';

  @override
  String get more => 'Mais';

  @override
  String get filtersLocked =>
      'Filtrar por idade, província e interesse vem com o plano Curtidas ilimitadas.';

  @override
  String get filters => 'Filtros';

  @override
  String get suspended =>
      'Seu perfil de match foi fechado pela equipe da plataforma. Escreva ao Suporte para saber mais.';

  @override
  String addPhotosToStart(int min) {
    return 'Adicione pelo menos $min fotos para mostrar seu cartão e começar a descobrir.';
  }

  @override
  String get paused =>
      'Seu perfil está pausado; ninguém vê você. Seus matches e conversas continuam.';

  @override
  String get likesOut =>
      'Suas curtidas grátis de hoje acabaram. Curta à vontade com Curtidas ilimitadas.';

  @override
  String get supersOut =>
      'Suas Super Curtidas de hoje acabaram. Amanhã renovam.';

  @override
  String get superUsed =>
      'Você usou sua Super Curtida de hoje. 5 por dia com o plano Super Curtida.';

  @override
  String get rewindLocked =>
      'Recuperar alguém que você passou sem querer vem com Curtidas ilimitadas.';

  @override
  String rewoundTo(String mode) {
    return 'A última pessoa que você passou voltou ao baralho de $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Com um Destaque você aparece no topo por $minutes minutos.';
  }

  @override
  String boosting(int minutes) {
    return 'Você está em destaque. Faltam $minutes minutos.';
  }

  @override
  String get boostUsed => 'Você usou o Destaque de hoje. Amanhã renova.';

  @override
  String get boost => 'Destacar';

  @override
  String boostBody(int minutes) {
    return 'Por $minutes minutos você aparece primeiro nos baralhos dos grupos em comum. Uma vez por dia.';
  }

  @override
  String boosted(int minutes) {
    return 'Destaque ativado! Você fica no topo por $minutes minutos.';
  }

  @override
  String get deckEmpty =>
      'Por enquanto não há mais ninguém. Isso enche conforme você entra em grupos e outros ativam o match.';

  @override
  String get deckEmptyFiltered =>
      'Ninguém mais combina com seus filtros. Tente ampliá-los.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String allowanceUnlimited(int supers) {
    return 'Curtidas ilimitadas · $supers Super Curtidas restantes.';
  }

  @override
  String get allowanceOut => 'Suas curtidas de hoje acabaram; amanhã renovam.';

  @override
  String allowance(int likes, int supers) {
    return 'Hoje você tem $likes curtidas e $supers Super Curtidas.';
  }

  @override
  String get undo => 'Desfazer';

  @override
  String get pass => 'Passar';

  @override
  String get superLike => 'Super Curtir';

  @override
  String get like => 'Curtir';

  @override
  String get introTitle => 'Conheça gente nova dos seus grupos em comum';

  @override
  String get intro1 =>
      'Você só vê pessoas que ativaram o match em grupos de que participa ou que segue.';

  @override
  String get intro2 =>
      'Deslize para a direita para curtir, para a esquerda para passar e para cima para Super Curtir.';

  @override
  String get intro3 =>
      'Quando os dois se curtem, dá match. Você escreve ao match com o plano Chat de Match.';

  @override
  String get intro4 =>
      'Amizade e Namoro são modos separados; escolha um ou os dois.';

  @override
  String get intro5 =>
      'Seu perfil só aparece para quem ativou o match. Pause ou apague quando quiser.';

  @override
  String get createMyProfile => 'Criar meu perfil de match';

  @override
  String seePackageOf(String package) {
    return 'Ver o plano $package';
  }

  @override
  String get allPackages => 'Todos os planos';

  @override
  String get packagesTitle => 'Planos de match';

  @override
  String get packagesIntro =>
      'Criar perfil e deslizar é grátis. Cada recurso é um plano à parte; pegue só o que quiser.';

  @override
  String get adminAllOpen => 'Como administrador, todos os planos estão ativos';

  @override
  String openUntil(String date) {
    return 'Ativo até $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Idade: $min – $max';
  }

  @override
  String get allProvinces => 'Todas as províncias';

  @override
  String get interest => 'Interesse';

  @override
  String get all => 'Todos';

  @override
  String get apply => 'Aplicar';

  @override
  String get clear => 'Limpar';

  @override
  String get noAdmirers =>
      'Por enquanto não há curtidas pendentes. Continue deslizando; quem curtir você aparece aqui.';

  @override
  String get backToSwiping => 'Voltar a deslizar';

  @override
  String get likeAndMatch => 'Curtir e dar match';

  @override
  String get noPendingLikes => 'Ainda não há curtidas pendentes';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas curtiram você',
      one: '1 pessoa curtiu você',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Com o plano Quem curtiu você, veja quem são e dê match na hora curtindo de volta.';

  @override
  String get seePackage => 'Ver o plano';
}
