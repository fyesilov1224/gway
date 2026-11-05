// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SocialAppL10nPt extends SocialAppL10n {
  SocialAppL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get posts => 'Publicações';

  @override
  String get newPost => 'Nova publicação';

  @override
  String get noOwnPosts =>
      'Você ainda não compartilhou nada. Compartilhe sua primeira foto ou vídeo.';

  @override
  String get noPosts => 'Ainda não há publicações.';

  @override
  String get shareFirstOwn => 'Compartilhe sua primeira publicação';

  @override
  String get groupFirstPost => 'Seja o primeiro a publicar no feed do grupo.';

  @override
  String get groupNoPosts => 'Ainda não há publicações neste grupo.';

  @override
  String get shareFirstGroup => 'Compartilhar a primeira publicação';

  @override
  String get groupNotFound => 'Grupo não encontrado.';

  @override
  String get memoriesEmpty =>
      'Nenhuma lembrança compartilhada ainda. Os participantes podem adicionar fotos aqui.';

  @override
  String get plan => 'Plano';

  @override
  String get payment => 'Pagamento';

  @override
  String get onlyOwnerBilling => 'Só o dono do grupo pode gerenciar planos.';

  @override
  String get backToGroup => 'Voltar ao grupo';

  @override
  String get writeSupportAboutGroup =>
      'Escrever para a equipe da plataforma sobre este grupo';

  @override
  String get search => 'Pesquisar';

  @override
  String get notifications => 'Notificações';

  @override
  String get goodNight => 'Boa noite';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Hoje';

  @override
  String get tabGroups => 'Grupos';

  @override
  String get tabCalendar => 'Agenda';

  @override
  String get tabMe => 'Eu';

  @override
  String get tonightSay => 'Livre? Avise e monte uma mesa';

  @override
  String get tonightTableSet => 'Sua mesa está pronta';

  @override
  String get tonightInvited => 'Você foi convidado para uma mesa';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas estão livres como você',
      one: '1 pessoa está livre como você',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Você está livre · até 4h';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas estão livres hoje à noite',
      one: '1 pessoa está livre hoje à noite',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Planos dos seus grupos';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planos',
      one: '1 plano',
    );
    return '$_temp0 · $mine participações';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planos',
      one: '1 plano',
    );
    return '$_temp0, 60 dias';
  }

  @override
  String get forToday => 'Para hoje';

  @override
  String get tonight => 'Hoje à noite';

  @override
  String get upcoming => 'Próximos';

  @override
  String get share => 'Compartilhar';

  @override
  String get post => 'Publicação';

  @override
  String get postHint => 'Até 10 fotos ou vídeos';

  @override
  String get story => 'Story';

  @override
  String get storyHint => 'Visível por 24 horas';

  @override
  String get group => 'Grupo';

  @override
  String get groupHint => 'Crie sua própria comunidade';

  @override
  String get create => 'Criar';

  @override
  String get messages => 'Mensagens';

  @override
  String get matching => 'Matches';

  @override
  String get myGroups => 'Meus grupos';

  @override
  String get pageNotFound =>
      'Não encontramos essa página. O link pode estar desatualizado ou errado.';

  @override
  String get backHome => 'Voltar ao início';

  @override
  String get groupsLeague => 'Liga dos grupos';

  @override
  String get exploreOnMap => 'Explorar no mapa';

  @override
  String get yearMenu =>
      'Retrospectiva do ano, meu mapa de exploração e pessoas que conheci';

  @override
  String get yearSummary => 'Retrospectiva do ano';

  @override
  String get yearSummaryHint =>
      'Seus encontros deste ano, em um cartão para compartilhar';

  @override
  String get explorationMap => 'Meu mapa de exploração';

  @override
  String get explorationMapHint =>
      'Províncias dos eventos de que você participou';

  @override
  String get metPeople => 'Pessoas que conheci';

  @override
  String get metPeopleHint =>
      'Pessoas com quem você trocou um aperto de mão em eventos';

  @override
  String get findTeammates => 'Encontrar parceiros de equipe';

  @override
  String get saved => 'Salvos';

  @override
  String get gateError =>
      'Não foi possível carregar seus dados. Verifique a conexão e tente novamente.';

  @override
  String get searchPeople => 'Pesquisar pessoas';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get settings => 'Configurações';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get teammatePrefs => 'Preferências de parceiros de equipe';

  @override
  String get matchProfile => 'Perfil de matches';

  @override
  String get voiceCalls => 'Chamadas de voz';

  @override
  String get blockedAccounts => 'Contas bloqueadas';

  @override
  String get storyArchive => 'Arquivo de stories';

  @override
  String get notificationPrefs => 'Preferências de notificação';

  @override
  String get mySanctions => 'Minhas sanções de grupo';

  @override
  String get userGuide => 'Guia de uso';

  @override
  String get supportFeedback => 'Suporte e feedback';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas respostas',
      one: '1 nova resposta',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Verificação em duas etapas';

  @override
  String get legalDocuments => 'Documentos legais';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get signOut => 'Sair';

  @override
  String get nowPrivate => 'Sua conta agora é privada.';

  @override
  String get nowPublic =>
      'Sua conta agora é pública; as solicitações pendentes foram aprovadas.';

  @override
  String get privateAccount => 'Conta privada';

  @override
  String get privateAccountHint =>
      'Quando ativado, só os seguidores que você aprovar veem suas publicações e stories.';

  @override
  String get groupsNowPublic =>
      'Agora todos podem ver seus grupos no seu perfil.';

  @override
  String get groupsNowMembers =>
      'Agora seus grupos só aparecem para membros do mesmo grupo.';

  @override
  String get showGroups => 'Mostrar meus grupos no perfil';

  @override
  String get showGroupsHint =>
      'Quando desativado, só os membros de um grupo veem que você faz parte dele; administradores de outros grupos não.';

  @override
  String get language => 'Idioma';

  @override
  String get games => 'Jogos';

  @override
  String get chessHint =>
      'Partidas rápidas, desafie amigos e suba no ranking Elo.';

  @override
  String get gamesHint =>
      'Xadrez: partidas rápidas, torneios, confrontos por equipes';
}
