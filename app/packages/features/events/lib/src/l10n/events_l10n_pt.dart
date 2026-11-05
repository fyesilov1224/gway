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
}
