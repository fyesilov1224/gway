// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class EventsL10nPt extends EventsL10n {
  EventsL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get pollSingle => 'Nesta enquete só é possível escolher uma opção.';

  @override
  String get pollOptionGone => 'Esta opção não existe mais. Atualize a página.';

  @override
  String get reviewWindow =>
      'Os participantes podem avaliar o evento até 30 dias depois do fim.';

  @override
  String get greeterNeedsAttendance =>
      'Para recepcionar, você precisa ter participado de um evento do grupo.';

  @override
  String get note80 => 'A nota pode ter até 80 caracteres.';

  @override
  String get pollClosed => 'Esta enquete foi encerrada ou você não pode votar.';

  @override
  String get cover5mb => 'A imagem de capa pode ter até 5 MB.';

  @override
  String get imagesOnly => 'Só é possível enviar imagens JPEG, PNG ou WebP.';

  @override
  String get claimNotAllowed =>
      'Não é possível informar esta tarefa agora: ela terminou ou você não está no grupo.';

  @override
  String get claimApprovedLocked => 'Um relato aprovado não pode ser retirado.';

  @override
  String get claimDuplicate => 'Você já informou esta tarefa.';

  @override
  String get repeatsWeekly => 'Repete toda semana';

  @override
  String get repeatsBiweekly => 'Repete a cada duas semanas';

  @override
  String surprisePlace(String place) {
    return 'Local surpresa · $place';
  }

  @override
  String get goalPersonal => 'Meta pessoal';

  @override
  String get goalPersonalHint => 'Cada membro completa o próprio número.';

  @override
  String get goalGroup => 'Meta do grupo';

  @override
  String get goalGroupHint =>
      'As contribuições de todos somam em um único contador.';

  @override
  String get goalTeam => 'Meta de equipe';

  @override
  String get goalTeamHint =>
      'Os administradores formam as equipes; cada equipe tem um contador comum.';

  @override
  String get goalTask => 'Tarefa aprovada';

  @override
  String get goalTaskHint =>
      'Um membro diz \"Feito\" e um administrador aprova.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'participações',
      one: 'participação',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'eventos organizados',
      one: 'evento organizado',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lembranças',
      one: 'lembrança',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'Aguardando aprovação';

  @override
  String get claimApproved => 'Aprovado';

  @override
  String get claimRejected => 'Não aprovado';

  @override
  String get notClaimedYet => 'Ainda não informado';

  @override
  String get whenAny => 'A qualquer hora';

  @override
  String get whenToday => 'Hoje';

  @override
  String get whenWeek => 'Em 7 dias';

  @override
  String get viewDay => 'Dia';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewMonth => 'Mês';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participações',
      one: '1 participação',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos organizados',
      one: '1 evento organizado',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lembranças',
      one: '1 lembrança',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avaliações',
      one: '1 avaliação',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novatos recebidos',
      one: '1 novato recebido',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apertos de mão',
      one: '1 aperto de mão',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avaliações positivas',
      one: '1 avaliação positiva',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $rankº de $groups grupos, $points pontos.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity participantes';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Primeiro evento do ano: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Primeiro evento do ano: $title · $date';
  }

  @override
  String get myCalendar => 'Minha agenda';

  @override
  String get groupCalendar => 'Agenda do grupo';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Próximo';

  @override
  String get today => 'Hoje';

  @override
  String get groupsEvents => 'Eventos dos meus grupos';

  @override
  String get showNotJoined => 'Mostrar também os que você não participa';

  @override
  String get noJoinedInRange =>
      'Você não participa de eventos nestas datas. Também pode ver os dos seus grupos.';

  @override
  String get noEventsInRange => 'Nenhum evento nestas datas.';

  @override
  String get showGroupsEvents => 'Mostrar eventos dos meus grupos';

  @override
  String get backToToday => 'Voltar para hoje';

  @override
  String get noEventsDay => 'Nenhum evento neste dia.';

  @override
  String get contributions => 'Contribuição para a comunidade';

  @override
  String get howBadges => 'Como ganhar emblemas?';

  @override
  String get badgesEmpty =>
      'Quando participar de um evento, sua contribuição e seu primeiro emblema aparecem aqui.';

  @override
  String get badgesRules =>
      'Os emblemas vêm só do que você realmente faz: eventos que frequenta e organiza, lembranças compartilhadas e avaliações. Curtidas e seguidores não contam. Participações marcadas como \"não veio\" pelo organizador não contam. Ninguém é ranqueado.';

  @override
  String get categoryFan => 'Fã da categoria';

  @override
  String get pastEvents => 'Eventos passados';

  @override
  String get noPastEvents => 'Este grupo ainda não tem eventos passados.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get canceled => 'Cancelado';

  @override
  String get olderEvents => 'Eventos mais antigos';

  @override
  String get completed => 'Concluído';

  @override
  String get ended => 'Encerrado';

  @override
  String teamName(String name) {
    return 'Equipe: $name';
  }

  @override
  String get teamNotice =>
      'Quando for adicionado a uma equipe, seu progresso aparece aqui.';

  @override
  String get goals => 'Metas';

  @override
  String get createGoal => 'Criar meta';

  @override
  String get goalsEmpty =>
      'Por exemplo \"4 trilhas este mês\" ou \"50 participações juntos\": crie a primeira meta.';

  @override
  String get claimSent => 'Seu relato foi enviado ao administrador.';

  @override
  String get goal => 'Meta';

  @override
  String get goalCountsRule =>
      'Só contam os eventos deste grupo no período; participações marcadas como \"não veio\" não contam.';

  @override
  String get withdrawClaim => 'Retirar relato';

  @override
  String get claimWithdrawn => 'Seu relato foi retirado.';

  @override
  String get done => 'Feito';

  @override
  String get teams => 'Equipes';

  @override
  String get createTeam => 'Criar equipe';

  @override
  String get noTeams => 'Ainda não há equipes.';

  @override
  String deleteTeam(String name) {
    return 'Excluir a equipe $name';
  }

  @override
  String get teamDeleted => 'Equipe excluída.';

  @override
  String pendingClaims(int count) {
    return 'Relatos pendentes ($count)';
  }

  @override
  String get claimRejectedToast => 'Relato não aprovado.';

  @override
  String get decline => 'Recusar';

  @override
  String get approve => 'Aprovar';

  @override
  String taskDone(String name) {
    return '$name concluiu a tarefa.';
  }

  @override
  String completions(int count) {
    return 'Concluído por ($count)';
  }

  @override
  String get noCompletions =>
      'Ninguém concluiu ainda. Quem concluir ganha o emblema desta meta no perfil.';

  @override
  String get goalCanceled => 'Meta cancelada.';

  @override
  String get cancelGoal => 'Cancelar meta';

  @override
  String teamCreated(String name) {
    return 'Equipe \"$name\" criada.';
  }

  @override
  String get teamNameLabel => 'Nome da equipe';

  @override
  String get createTheTeam => 'Criar a equipe';

  @override
  String createTeamWith(int count) {
    return 'Criar a equipe ($count pessoas)';
  }

  @override
  String get goalCreated => 'Meta criada.';

  @override
  String get title => 'Título';

  @override
  String get goalTitleExample => 'Ex.: Trilhas de outubro';

  @override
  String get taskTitleExample => 'Ex.: Mostrar o percurso a um novo membro';

  @override
  String get titleMin3 => 'O título deve ter pelo menos 3 caracteres.';

  @override
  String get descriptionOptional => 'Descrição (opcional)';

  @override
  String get targetNumber => 'Número-alvo';

  @override
  String get target1to1000 => 'Digite um número de 1 a 1000.';

  @override
  String get period => 'Período';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (até 92 dias)';
  }

  @override
  String get createTheGoal => 'Criar a meta';

  @override
  String get iDidTask => 'Fiz a tarefa';

  @override
  String get whatDidYouDo => 'O que você fez? (opcional)';

  @override
  String get whatDidYouDoHint =>
      'O administrador aprova depois de ler esta nota.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get send => 'Enviar';

  @override
  String get handshake => 'Aperto de mão';

  @override
  String get handshakeHint =>
      'Escaneiem os códigos um do outro; os dois entram em \"Pessoas que conheci\".';

  @override
  String get open => 'Abrir';

  @override
  String handshakeAt(String title) {
    return 'Aperto de mão · $title';
  }

  @override
  String get myCode => 'Meu código';

  @override
  String get scan => 'Escanear';

  @override
  String get yourHandshakeCode => 'Seu código de aperto de mão';

  @override
  String get codeHint =>
      'A outra pessoa escaneia este código na aba \"Escanear\" ou digita. O código muda a cada poucos minutos; uma foto não funcionará depois.';

  @override
  String get cameraFailed =>
      'Não foi possível abrir a câmera. Permita o acesso nas configurações ou digite o código abaixo.';

  @override
  String get scanHint =>
      'Aponte a câmera para o QR code da outra pessoa ou digite o código.';

  @override
  String get typeCodeHint =>
      'Digite o código de 6 caracteres da tela da outra pessoa.';

  @override
  String get code => 'Código';

  @override
  String get alreadyMet => 'Vocês já se conhecem';

  @override
  String get metNow => 'Vocês se conheceram!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'OK';

  @override
  String get metPeople => 'Pessoas que conheci';

  @override
  String get metEmpty =>
      'Quando trocar um aperto de mão em um evento, a pessoa aparece aqui. O aperto de mão abre na página do evento.';

  @override
  String get goToCalendar => 'Ir para minha agenda';

  @override
  String get metPrivacy =>
      'Só você vê isso. Seu perfil mostra apenas o número de apertos de mão.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Como os pontos são calculados?';

  @override
  String get leagueIntro =>
      'Grupos da mesma categoria e província competem todo mês. Contam os eventos encerrados no mês.';

  @override
  String get ruleAttendance => 'Participação: 1 ponto';

  @override
  String get ruleAttendanceHint => 'Cada pessoa que vai; até 30 por evento.';

  @override
  String get ruleHeld => 'Evento: 5 pontos';

  @override
  String get ruleHeldHint =>
      'Cada evento com pelo menos 3 pessoas além do organizador.';

  @override
  String get ruleWelcome => 'Recepção: 3 pontos';

  @override
  String get ruleWelcomeHint => 'Receber alguém que vem pela primeira vez.';

  @override
  String get ruleReview => 'Avaliação positiva: 1 ponto';

  @override
  String get ruleReviewHint => 'Cada avaliação de 4 ou 5 estrelas.';

  @override
  String get leagueRulesNote =>
      'Quem é marcado como \"não veio\" não conta. Os resultados ficam definitivos 8 dias após o fim do mês; os membros dos três primeiros grupos são avisados.';

  @override
  String get groupsLeague => 'Liga dos grupos';

  @override
  String get category => 'Categoria';

  @override
  String get province => 'Província';

  @override
  String get month => 'Mês';

  @override
  String seasonClosed(String month) {
    return 'A temporada de $month acabou; a classificação é definitiva.';
  }

  @override
  String get seasonRunning =>
      'A temporada está em andamento. Os pontos atualizam quando os eventos terminam; resultados definitivos 8 dias após o fim do mês.';

  @override
  String leagueEmpty(String province) {
    return 'Nenhum grupo da liga de $province pontuou este mês.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos',
      one: '1 ponto',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rankº';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Liga de $category';
  }

  @override
  String get noPointsYet =>
      'Ainda sem pontos este mês. Eventos concluídos, participações e recepções rendem pontos.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © colaboradores do OpenStreetMap';

  @override
  String get map => 'Mapa';

  @override
  String get mapView => 'Ver mapa';

  @override
  String get listView => 'Ver lista';

  @override
  String get all => 'Todos';

  @override
  String get wholeArea => 'Área toda';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Não foi possível carregar os dados do mapa.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noFilterResults => 'Nada encontrado com esses filtros.';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noNearby => 'Nenhum evento próximo ou grupo nesta área.';

  @override
  String get zoomOut => 'Diminuir zoom';

  @override
  String get openEvent => 'Abrir evento';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get noVisible => 'Nenhum evento próximo ou grupo na área visível.';

  @override
  String get backToMap => 'Voltar ao mapa';

  @override
  String upcomingCount(int count) {
    return 'Próximos eventos ($count)';
  }

  @override
  String get directions => 'Rotas';

  @override
  String get meetingPointOptional => 'Ponto de encontro (opcional)';

  @override
  String get meetingPointHint => 'Escolha no mapa; o evento aparece no mapa.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Selecionado · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Remover ponto de encontro';

  @override
  String get meetingPoint => 'Ponto de encontro';

  @override
  String get pickHint => 'Aproxime o mapa e toque no ponto de encontro.';

  @override
  String get pickAgainHint => 'Toque em outro lugar para mudar o ponto.';

  @override
  String get pickThisPoint => 'Escolher este ponto';

  @override
  String get mapUnavailable => 'O mapa não está disponível no momento.';

  @override
  String get pollClosedShort => 'Encerrada';

  @override
  String closesAt(String date) {
    return 'Encerra: $date';
  }

  @override
  String get multipleAllowed => 'Múltipla escolha';

  @override
  String get anonymousVote => 'Votação anônima';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Opções da enquete';

  @override
  String get pollClosedToast => 'Enquete encerrada.';

  @override
  String get pollDeleted => 'Enquete excluída.';

  @override
  String get closePoll => 'Encerrar enquete';

  @override
  String get deletePoll => 'Excluir enquete';

  @override
  String get vote => 'Votar';

  @override
  String get voteSaved => 'Seu voto foi registrado.';

  @override
  String get voters => 'Votantes';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get polls => 'Enquetes';

  @override
  String get openPoll => 'Criar enquete';

  @override
  String get pollsEmpty =>
      'Faça uma pergunta aos membros, por exemplo: que dia vamos nos encontrar?';

  @override
  String get pollOpened => 'Enquete criada.';

  @override
  String get question => 'Pergunta';

  @override
  String get questionExample => 'Ex.: Que dia vamos nos encontrar?';

  @override
  String get questionMin3 => 'A pergunta deve ter pelo menos 3 caracteres.';

  @override
  String optionN(int n) {
    return 'Opção $n';
  }

  @override
  String get removeOption => 'Remover opção';

  @override
  String get optionRequired => 'Preencha a opção ou remova.';

  @override
  String get addOption => 'Adicionar opção';

  @override
  String get allowMultiple => 'Permitir várias opções';

  @override
  String get anonymousHint => 'Ninguém vê quem votou em quê.';

  @override
  String get noEndTime => 'Sem horário de término';

  @override
  String get add => 'Adicionar';

  @override
  String get removeEndTime => 'Remover horário de término';

  @override
  String get startPoll => 'Criar a enquete';

  @override
  String get cardFooter => 'gway · encontre sua comunidade';

  @override
  String myYear(int year) {
    return 'Meu $year';
  }

  @override
  String get statAttended => 'eventos que participei';

  @override
  String get statHours => 'horas juntos';

  @override
  String get statOneGroup => 'grupo com quem me encontrei';

  @override
  String get statGroups => 'grupos diferentes';

  @override
  String get statProvinces => 'províncias diferentes';

  @override
  String get statOrganized => 'eventos organizados';

  @override
  String get statWelcomed => 'novatos recebidos';

  @override
  String get statMemories => 'lembranças compartilhadas';

  @override
  String get favorites => 'Meus favoritos';

  @override
  String get topGroup => 'O grupo com quem mais estive';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontros',
      one: '1 encontro',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'Eu estava lá';

  @override
  String get firstWithGroup => 'Meu primeiro evento com este grupo.';

  @override
  String nthWithGroup(int n) {
    return 'Meu $nº evento com este grupo.';
  }

  @override
  String get shareFailed =>
      'Não foi possível compartilhar neste dispositivo. Tire um print do cartão e compartilhe.';

  @override
  String get share => 'Compartilhar';

  @override
  String yearSummaryTitle(int year) {
    return 'Minha retrospectiva $year';
  }

  @override
  String get yearEmpty =>
      'Você ainda não participou de eventos este ano. Seu resumo aparece aqui depois do primeiro encontro.';

  @override
  String yearShareText(int year) {
    return 'Meu $year no GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Mapa da Turquia: $count províncias exploradas';
  }

  @override
  String get explorationMap => 'Meu mapa de exploração';

  @override
  String get statExplored => 'províncias exploradas';

  @override
  String get statMetAt => 'eventos em que nos encontramos';

  @override
  String get recentExplored => 'Descobertas recentes';

  @override
  String get explorationEmpty =>
      'As províncias dos seus eventos acendem aqui. Seu mapa ganha cor depois do primeiro encontro.';

  @override
  String get findOnMap => 'Encontrar eventos no mapa';

  @override
  String explorationShareText(int count) {
    return 'Explorei $count províncias no GWAY';
  }

  @override
  String get exploredProvinces => 'Províncias exploradas';

  @override
  String get explorationPrivacy =>
      'Só você vê isso. Contam os eventos de que participou sem marcação \"não veio\".';

  @override
  String get tonightVisible =>
      'Quem está nos seus grupos verá que você está livre hoje à noite. Desliga sozinho às 4h.';

  @override
  String get joinedTable => 'Você entrou na mesa.';

  @override
  String get declinedInvite => 'Você recusou o convite.';

  @override
  String get yourStatus => 'Seu status';

  @override
  String get visibleUntil4 => 'Você fica visível até as 4h';

  @override
  String get notVisible => 'Você não está visível agora';

  @override
  String get youreFree => 'Você está livre';

  @override
  String get tonightIntro =>
      'Se estiver livre, avise seus grupos; vocês podem montar uma mesinha juntos.';

  @override
  String get imFreeTonight => 'Estou livre hoje à noite';

  @override
  String get noLongerFree => 'Você não aparece mais como livre.';

  @override
  String get turnOffStatus => 'Desativar status';

  @override
  String get leftTable => 'Você saiu da mesa.';

  @override
  String get smallTable => 'Mesinha';

  @override
  String get smallTableHint =>
      'Chame algumas pessoas livres; o chat da mesa abre quando houver três.';

  @override
  String get setUpTable => 'Montar uma mesinha';

  @override
  String tableInvitesSent(int count) {
    return 'Convites enviados para $count pessoas. O chat abre quando houver três.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Para uma mesinha, são necessárias pelo menos mais $min pessoas livres dos seus grupos (agora $now). Quando alguém estiver livre, você pode montar aqui.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas dos seus grupos estão livres hoje à noite',
      one: '1 pessoa dos seus grupos está livre hoje à noite',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Café';

  @override
  String get chipWalk => 'Caminhada curta';

  @override
  String get chipFood => 'Comida';

  @override
  String get chipCinema => 'Cinema';

  @override
  String get tonightSheetHint =>
      'Só pessoas dos seus grupos veem. Seu status desliga sozinho às 4h.';

  @override
  String get whatToDo => 'O que você quer fazer? (opcional)';

  @override
  String get whatToDoHint => 'ex.: café, caminhada curta';

  @override
  String get imFree => 'Estou livre';

  @override
  String get yourTable => 'Sua mesa';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entraram',
      one: '1 entrou',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aguardando',
      one: '1 aguardando',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'Montando';

  @override
  String get chatOpen => 'Chat aberto';

  @override
  String get tableChat => 'Chat da mesa';

  @override
  String chatOpensWhen(int count) {
    return 'O chat abre quando mais $count pessoas entrarem. Lá vocês escolhem juntos o lugar e o horário.';
  }

  @override
  String get leaveTable => 'Sair da mesa';

  @override
  String tableInviteTitle(String name) {
    return '$name montou uma mesinha e está convidando você.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined entraram · $pending aguardando. O chat abre com três pessoas.';
  }

  @override
  String get join => 'Entrar';

  @override
  String get notTonight => 'Hoje não';

  @override
  String get tonight => 'Hoje à noite';

  @override
  String get freeTonight => 'Livres hoje à noite';

  @override
  String get sharedGroupsOnly => 'Só pessoas dos seus grupos';

  @override
  String get nobodyFree => 'Ninguém dos seus grupos está livre agora.';

  @override
  String get howItWorks => 'Como funciona?';

  @override
  String get howStep1 =>
      'Diga \"Estou livre hoje à noite\" e, se quiser, escreva o que quer fazer.';

  @override
  String get howStep2 =>
      'Quem está nos seus grupos vê você, e você vê quem está livre.';

  @override
  String get howStep3 =>
      'Monte uma mesinha; o chat abre com três pessoas e lá vocês escolhem lugar e horário.';

  @override
  String get upcoming => 'Próximos';

  @override
  String get calendar => 'Agenda';

  @override
  String get noUpcomingJoined => 'Você não participa de nenhum evento próximo.';

  @override
  String get showAll => 'Mostrar tudo';

  @override
  String get noUpcoming60 =>
      'Seus grupos não têm eventos nos próximos 60 dias.';

  @override
  String get findGroup => 'Encontrar grupo';

  @override
  String filterAll(int count) {
    return 'Todos · $count';
  }

  @override
  String filterMine(int count) {
    return 'Participo · $count';
  }

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get going => 'Você vai';

  @override
  String get waitlisted => 'Na lista de espera';

  @override
  String get awaitingApproval => 'Aguardando aprovação';

  @override
  String get full => 'Lotado';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity participantes';
  }

  @override
  String get startingSoon => 'Começa em breve';

  @override
  String get next6Hours => 'Próximas 6 horas';

  @override
  String get wantWelcome => 'Quero ser recebido';

  @override
  String get wantWelcomeHint =>
      'Um membro voluntário do grupo recebe você na entrada; você não vai sozinho.';

  @override
  String get noteForGreeter => 'Uma nota para reconhecerem você (opcional)';

  @override
  String get noteForGreeterHint =>
      'Ex.: Estou de jaqueta vermelha e mochila azul';

  @override
  String get sendRequest => 'Enviar pedido';

  @override
  String get welcomeRequestSent =>
      'Seu pedido foi enviado aos recepcionistas. Avisaremos quando alguém aceitar.';

  @override
  String get editMeetingNote => 'Editar nota de encontro';

  @override
  String welcomePerson(String name) {
    return 'Receber $name';
  }

  @override
  String describedAs(String note) {
    return 'Descreveu-se assim: $note';
  }

  @override
  String get whereMeet => 'Onde vão se encontrar?';

  @override
  String get whereMeetHint => 'Ex.: Em frente ao café da entrada, 8h45';

  @override
  String get save => 'Salvar';

  @override
  String get iWillWelcome => 'Eu recebo';

  @override
  String get noteUpdated => 'Nota de encontro atualizada.';

  @override
  String youWillWelcome(String name) {
    return 'Você vai receber $name; a pessoa viu a nota de encontro.';
  }

  @override
  String get stopWelcoming => 'Deixar de receber';

  @override
  String stopWelcomingBody(String name) {
    return 'Vamos procurar outro recepcionista para $name e avisar.';
  }

  @override
  String get release => 'Deixar';

  @override
  String get releasedWelcome =>
      'Você deixou de receber; estamos procurando outro recepcionista.';

  @override
  String get firstTime => 'É sua primeira vez?';

  @override
  String greetersAvailable(int count) {
    return 'Este grupo tem $count recepcionistas. Um deles pode receber você na entrada e apresentar ao grupo.';
  }

  @override
  String get youWelcomed => 'Pessoas que você recebe';

  @override
  String meetingAt(String note) {
    return 'Encontro: $note';
  }

  @override
  String get thankedYou => 'Agradeceu você';

  @override
  String optionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Aguardando recepção ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas têm recepcionista.',
      one: '1 pessoa tem recepcionista.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Primeira vez';

  @override
  String get max3Welcomes => 'Você pode receber até 3 pessoas por evento.';

  @override
  String get greeterJoinHint =>
      'Você é recepcionista. Participe do evento para receber quem vem pela primeira vez.';

  @override
  String get lookingGreeter => 'Procurando recepcionista';

  @override
  String get lookingGreeterHint =>
      'Avisamos os recepcionistas. Você receberá uma notificação quando alguém aceitar.';

  @override
  String yourNote(String note) {
    return 'Sua nota: $note';
  }

  @override
  String get welcomeWithdrawn => 'Seu pedido foi retirado.';

  @override
  String get withdrawRequest => 'Retirar pedido';

  @override
  String get greetedBy => 'Recebido por';

  @override
  String get willGreet => 'Vai receber você';

  @override
  String get thank => 'Agradecer';

  @override
  String thankReceived(String name) {
    return '$name recebeu seu agradecimento.';
  }

  @override
  String get thanked => 'Você agradeceu.';

  @override
  String get cancelWelcome => 'Cancelar recepção';

  @override
  String get nowGreeter =>
      'Agora você é recepcionista. Avisaremos quando alguém novo pedir para ser recebido.';

  @override
  String get noLongerGreeter => 'Você não é mais recepcionista.';

  @override
  String get welcomeSection => 'Recepção';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepcionistas',
      one: '1 recepcionista',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Quem vem pela primeira vez pode pedir recepção na página do evento. Se você for recepcionista, será avisado; recebe na entrada e apresenta ao grupo.';

  @override
  String greeterMemberHint(int count) {
    return 'Este grupo tem $count recepcionistas. No seu primeiro evento, toque em \"Quero ser recebido\".';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Este grupo tem $count recepcionistas: você não vai sozinho ao primeiro evento, alguém recebe você na entrada.';
  }

  @override
  String get becomeGreeter => 'Ser recepcionista';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }
}
