// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class NotificationsL10nPt extends NotificationsL10n {
  NotificationsL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get actLike => 'curtiu sua publicação.';

  @override
  String actComment(String text) {
    return 'comentou: $text';
  }

  @override
  String actReply(String text) {
    return 'respondeu ao seu comentário: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'curtiu seu comentário: $text';
  }

  @override
  String get actMentionPost => 'mencionou você em uma publicação.';

  @override
  String actMentionComment(String text) {
    return 'mencionou você em um comentário: $text';
  }

  @override
  String get actFollow => 'começou a seguir você.';

  @override
  String get actFollowRequest => 'quer seguir você.';

  @override
  String get actFollowAccepted => 'aceitou sua solicitação para seguir.';

  @override
  String actLiveScheduled(String title) {
    return 'agendou uma transmissão ao vivo: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'agendou uma transmissão ao vivo para $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'está ao vivo: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Abriu uma vaga em \"$title\" — agora você vai.';
  }

  @override
  String actEventUpdated(String title) {
    return 'mudou o horário ou o local de \"$title\".';
  }

  @override
  String actEventCanceled(String title) {
    return 'cancelou \"$title\".';
  }

  @override
  String actReminderTomorrow(String title) {
    return '\"$title\" começa amanhã. Você vem? Confirme.';
  }

  @override
  String actReminderHour(String title) {
    return '\"$title\" começa em menos de uma hora.';
  }

  @override
  String actCaseVote(String group) {
    return 'abriu um processo disciplinar em $group; seu voto é necessário.';
  }

  @override
  String get actMuted => 'silenciou você. Toque para ver detalhes ou recorrer.';

  @override
  String get actKicked =>
      'removeu você do grupo. Toque para ver detalhes ou recorrer.';

  @override
  String get actBanned =>
      'baniu você do grupo. Toque para ver detalhes ou recorrer.';

  @override
  String get actWarned =>
      'deu uma advertência a você. Toque para ver detalhes ou recorrer.';

  @override
  String actAppealSubmitted(String group) {
    return 'recorreu de uma sanção em $group.';
  }

  @override
  String get actAppealDecided => 'decidiu sobre seu recurso.';

  @override
  String actEventApproved(String title) {
    return 'aprovou seu pedido para \"$title\".';
  }

  @override
  String actEventDeclined(String title) {
    return 'não pôde aceitar seu pedido para \"$title\".';
  }

  @override
  String actEventReview(String title) {
    return 'Como foi \"$title\"? Avalie e compartilhe suas lembranças.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Você concluiu \"$title\"! Seu emblema está no perfil.';
  }

  @override
  String get actTeammateRequest => 'quer formar parceria com você.';

  @override
  String get actTeammateAccepted => 'aceitou seu pedido de parceria.';

  @override
  String get actMatchCreated => 'Veja quem é em Meus matches.';

  @override
  String get actSuperLiked =>
      'deu um superlike em você! Aparece primeiro no seu baralho.';

  @override
  String actWelcomeRequested(String title) {
    return 'vai pela primeira vez a \"$title\" e quer ser recebido.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'vai receber você em \"$title\". Veja a nota de encontro.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'não poderá mais receber você em \"$title\"; estamos procurando outra pessoa.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'retirou o pedido de recepção para \"$title\".';
  }

  @override
  String get actLeagueResult =>
      'ficou entre os três primeiros da liga no mês passado! Veja a classificação na página do grupo.';

  @override
  String actWelcomeThanked(String title) {
    return 'agradeceu por você tê-lo recebido em \"$title\".';
  }

  @override
  String get actTableInvite =>
      'montou uma mesinha hoje à noite e está convidando você.';

  @override
  String get actTableReady =>
      'entrou na mesa; ela está pronta. Combinem lugar e horário no chat.';

  @override
  String actVenueRevealed(String title) {
    return '\"$title\": toque para ver aonde ir.';
  }

  @override
  String actHandshake(String title) {
    return 'trocou um aperto de mão com você em \"$title\".';
  }

  @override
  String get actCallMissed => 'ligou para você; você não atendeu.';

  @override
  String get actCallGranted =>
      '— agora você tem permissão. Pode ligar para seus matches pelo chat.';

  @override
  String get actCallDeclined =>
      '— seu pedido não foi aprovado por enquanto. Toque para ver detalhes.';

  @override
  String get actCallRevoked =>
      '— sua permissão foi retirada. Toque para ver detalhes.';

  @override
  String actSeriesLimit(String title) {
    return '— a próxima data de \"$title\" não pôde abrir: o limite mensal do grupo foi atingido. Ela abre no próximo mês ou com upgrade do plano.';
  }

  @override
  String get leadNewMatch => 'Você tem um novo match!';

  @override
  String get leadSeries => 'Evento recorrente';

  @override
  String get leadVenue => 'Local surpresa revelado';

  @override
  String get leadCalls => 'Chamadas de voz';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodWeek => 'Esta semana';

  @override
  String get periodEarlier => 'Antes';

  @override
  String get agoNow => 'agora';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n h';
  }

  @override
  String agoDays(int n) {
    return '$n d';
  }

  @override
  String get join => 'Entrar';

  @override
  String get see => 'Ver';

  @override
  String get prefsTitle => 'Preferências de notificação';

  @override
  String get messages => 'Mensagens';

  @override
  String get directMessages => 'Mensagens diretas';

  @override
  String get directMessagesHint =>
      'Quando chega uma mensagem direta, com som mesmo com o app fechado';

  @override
  String get groupMessages => 'Mensagens de grupo';

  @override
  String get groupMessagesHint =>
      'Quando chegam mensagens nos chats de grupo e na mesa de hoje, com som mesmo com o app fechado';

  @override
  String get events => 'Eventos';

  @override
  String get remindDay => 'Lembrar 1 dia antes';

  @override
  String get remindDayHint =>
      'Se um evento de que você participa começa amanhã';

  @override
  String get remindHour => 'Lembrar 1 hora antes';

  @override
  String get remindHourHint =>
      'Se um evento de que você participa começa em até uma hora';

  @override
  String get changes => 'Alterações e cancelamentos';

  @override
  String get changesHint =>
      'Quando o horário ou o local muda, ou um evento é cancelado';

  @override
  String get reviewRequests => 'Pedidos de avaliação';

  @override
  String get reviewRequestsHint =>
      'Perguntar \"Como foi?\" quando o evento acabar';

  @override
  String get live => 'Transmissões ao vivo';

  @override
  String get liveAlerts => 'Transmissões agendadas e iniciadas';

  @override
  String get liveAlertsHint =>
      'Quando seu grupo agenda ou inicia uma transmissão, com alerta sonoro se o app estiver aberto';

  @override
  String get matching => 'Matches';

  @override
  String get newMatches => 'Novos matches';

  @override
  String get newMatchesHint => 'Quando vocês se curtem';

  @override
  String get alwaysSent =>
      'O resultado dos seus pedidos, subir da lista de espera e sanções de grupo afetam você diretamente, por isso são sempre notificados.';

  @override
  String get notifications => 'Notificações';

  @override
  String get empty => 'Curtidas, comentários e novos seguidores aparecem aqui.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get followRequests => 'Solicitações para seguir';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$name e mais $_temp0';
  }

  @override
  String get delete => 'Excluir';
}
