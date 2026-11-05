// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class ModerationL10nPt extends ModerationL10n {
  ModerationL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Você enviou denúncias demais hoje. Tente amanhã.';

  @override
  String get ruleTargetInvalid =>
      'Este conteúdo não existe mais ou você não pode vê-lo.';

  @override
  String get ruleSelf => 'Você não pode denunciar a si mesmo nem seu conteúdo.';

  @override
  String get ruleAppealNotAllowed =>
      'Não é mais possível recorrer desta sanção.';

  @override
  String get ruleDuplicate => 'Você já denunciou isto; está em análise.';

  @override
  String get deletedAccount => 'Conta excluída';

  @override
  String get reasonSpam => 'Spam ou enganoso';

  @override
  String get reasonHarassment => 'Assédio ou bullying';

  @override
  String get reasonHate => 'Discurso de ódio';

  @override
  String get reasonViolence => 'Violência ou ameaça';

  @override
  String get reasonSexual => 'Conteúdo sexual';

  @override
  String get reasonMisinformation => 'Informação falsa';

  @override
  String get reasonOther => 'Outro';

  @override
  String get sanctionWarning => 'Advertência';

  @override
  String get sanctionMute => 'Silenciamento';

  @override
  String get sanctionKick => 'Remoção do grupo';

  @override
  String get sanctionBan => 'Banimento';

  @override
  String get illegalViolence => 'Violência';

  @override
  String get illegalThreat => 'Ameaça';

  @override
  String get illegalInsult => 'Injúria';

  @override
  String get illegalHate => 'Discurso de ódio';

  @override
  String get illegalSexual => 'Abuso sexual';

  @override
  String get illegalFraud => 'Fraude';

  @override
  String get illegalDrugs => 'Drogas';

  @override
  String get illegalTerror => 'Terrorismo';

  @override
  String get illegalOther => 'Outro crime';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Silenciado por $days dias',
      one: 'Silenciado por 1 dia',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Banimento de $days dias',
      one: 'Banimento de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Banimento permanente';

  @override
  String get thresholdMajority => 'Maioria simples';

  @override
  String get thresholdMajorityText => 'Mais da metade dos votos';

  @override
  String get thresholdTwoThirds => 'Dois terços';

  @override
  String get thresholdTwoThirdsText => 'Pelo menos dois terços dos votos';

  @override
  String get thresholdUnanimous => 'Unanimidade';

  @override
  String get thresholdUnanimousText => 'Todos os votos';

  @override
  String get targetPost => 'Publicação';

  @override
  String get targetComment => 'Comentário';

  @override
  String get targetEvent => 'Evento';

  @override
  String get targetLiveComment => 'Comentário ao vivo';

  @override
  String get targetMessage => 'Mensagem do chat de grupo';

  @override
  String get targetMember => 'Membro';

  @override
  String get appealPending => 'Aguardando decisão';

  @override
  String get appealUpheld => 'Sanção mantida';

  @override
  String get appealOverturned => 'Sanção retirada';

  @override
  String get banApplied => 'Banimento aplicado.';

  @override
  String get banAppliedSuspended =>
      'Banimento aplicado. A conta da pessoa fica suspensa até a análise da plataforma.';

  @override
  String get caseOpened => 'Caso aberto. O conselho votará em até 72 horas.';

  @override
  String get openCaseTitle => 'Abrir caso disciplinar';

  @override
  String caseAboutNow(String name) {
    return 'Sobre $name. O banimento vale na hora, sem votação do conselho.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Sobre $name. O conselho disciplinar vota sua proposta em até 72 horas.';
  }

  @override
  String get proposedSanction => 'Sanção proposta';

  @override
  String get duration => 'Duração';

  @override
  String get permanent => 'Permanente';

  @override
  String get permanentLower => 'permanente';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Aplicar já, sem votação';

  @override
  String get applyNowHint =>
      'Bane sem esperar o conselho. A pessoa pode recorrer em até 7 dias.';

  @override
  String get illegalActivity => 'Atividade ilegal';

  @override
  String get illegalHintNow =>
      'Ao aplicar o banimento, o caso vai para a equipe da plataforma e a conta fica suspensa até a análise. Esta marcação não pode ser alterada depois.';

  @override
  String get illegalHintVote =>
      'Se o conselho aprovar, o caso vai para a equipe da plataforma e a conta fica suspensa até a análise. Esta marcação não pode ser alterada depois.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonHintNow =>
      'O que aconteceu? A pessoa e quem analisar o recurso veem este texto.';

  @override
  String get reasonHintVote =>
      'O que aconteceu? O conselho votará com base neste texto.';

  @override
  String get reasonMin10 => 'O motivo deve ter pelo menos 10 caracteres.';

  @override
  String get muteNow => 'Silenciar agora (24 horas)';

  @override
  String get muteNowHint =>
      'Até o conselho decidir, a pessoa não pode comentar nem falar ao vivo.';

  @override
  String get ban => 'Banir';

  @override
  String get openCase => 'Abrir caso';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'alguns minutos';

  @override
  String minChars(int min) {
    return 'Escreva pelo menos $min caracteres.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get threshold => 'Limite de decisão do conselho';

  @override
  String thresholdChanged(String threshold) {
    return 'O limite agora é \"$threshold\". Vale para novos casos.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderação · $group';
  }

  @override
  String get reports => 'Denúncias';

  @override
  String reportsCount(int count) {
    return 'Denúncias ($count)';
  }

  @override
  String get cases => 'Casos';

  @override
  String casesCount(int count) {
    return 'Casos ($count)';
  }

  @override
  String get sanctions => 'Sanções';

  @override
  String sanctionsCount(int count) {
    return 'Sanções ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Só o dono e a equipe de moderação veem a moderação deste grupo.';

  @override
  String get goBack => 'Voltar';

  @override
  String get noReports =>
      'Nenhuma denúncia aberta. As denúncias dos membros ficam aqui.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get removeContent => 'Remover conteúdo';

  @override
  String get remove => 'Remover';

  @override
  String get contentRemoved => 'Conteúdo removido.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denúncias',
      one: '1 denúncia',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Ver';

  @override
  String get reportDismissed => 'Denúncia rejeitada.';

  @override
  String get dismiss => 'Rejeitar';

  @override
  String get openCaseShort => 'Abrir caso';

  @override
  String get rankOnlyDismiss =>
      'A posição desta pessoa não é inferior à sua; você só pode rejeitar.';

  @override
  String get noCases =>
      'Ainda não há casos disciplinares. Eles são abertos a partir de uma denúncia ou da página de membros.';

  @override
  String get voteApproved =>
      'Seu voto foi salvo. O conselho aprovou a sanção; ela foi aplicada.';

  @override
  String get voteRejected =>
      'Seu voto foi salvo. O conselho rejeitou a sanção.';

  @override
  String get voteSaved =>
      'Seu voto foi salvo. Você pode mudá-lo até a decisão.';

  @override
  String get statusVoting => 'Em votação';

  @override
  String get statusApproved => 'Aprovado';

  @override
  String get statusRejected => 'Rejeitado';

  @override
  String proposed(String sanction) {
    return 'Proposta: $sanction';
  }

  @override
  String get directBan => 'Banimento sem votação';

  @override
  String illegalLabel(String category) {
    return 'Atividade ilegal: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals a favor · $rejections contra · $voters votantes';
  }

  @override
  String votingEndsIn(String time) {
    return 'A votação termina em $time';
  }

  @override
  String bannedBy(String name) {
    return 'Banido por: $name';
  }

  @override
  String openedBy(String name) {
    return 'Aberto por: $name';
  }

  @override
  String get approve => 'Aprovar';

  @override
  String get reject => 'Rejeitar';

  @override
  String get noSanctions =>
      'Ainda não há sanções. As aprovadas pelo conselho e os recursos aparecem aqui.';

  @override
  String get liftSanction => 'Retirar a sanção';

  @override
  String get keepSanction => 'Manter a sanção';

  @override
  String get noteToPerson => 'Nota para a pessoa (opcional)';

  @override
  String get liftedNotified => 'Sanção retirada; a pessoa foi avisada.';

  @override
  String get appealRejectedNotified =>
      'Recurso rejeitado; a pessoa foi avisada.';

  @override
  String get lifted => 'Retirada';

  @override
  String get interimMute => 'Silenciamento de emergência';

  @override
  String get running => 'Ativa';

  @override
  String get applied => 'Aplicada';

  @override
  String get interimUntilDecision =>
      'Silenciamento de emergência · até a decisão do conselho';

  @override
  String until(String date) {
    return 'até $date';
  }

  @override
  String appealLine(String status) {
    return 'Recurso · $status';
  }

  @override
  String noteLine(String note) {
    return 'Nota: $note';
  }

  @override
  String get ownerParty =>
      'O dono é parte no caso, então a equipe da plataforma analisa o recurso.';

  @override
  String get keep => 'Manter';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casos aguardam seu voto',
      one: '1 caso aguarda seu voto',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos',
      one: '1 recurso',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderação';

  @override
  String get noWork => 'Nada pendente';

  @override
  String get mySanctions => 'Minhas sanções';

  @override
  String get noMySanctions =>
      'Você não tem sanções em nenhum grupo. Obrigado por seguir as regras da comunidade.';

  @override
  String get interimEnded => 'Silenciamento de emergência encerrado';

  @override
  String interimLatest(String date) {
    return 'Silenciamento de emergência · até a decisão do conselho, no máximo até $date';
  }

  @override
  String untilCap(String date) {
    return 'Até $date';
  }

  @override
  String get ended => 'Encerrada';

  @override
  String get appeal => 'Recorrer';

  @override
  String get appealHint => 'Por que você acha injusto?';

  @override
  String get send => 'Enviar';

  @override
  String get appealSent =>
      'Seu recurso foi enviado. Você será avisado da decisão.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Seu recurso · $status';
  }

  @override
  String get appealOnce => 'Você pode recorrer uma vez em até 7 dias.';

  @override
  String get reportPost => 'Denunciar publicação';

  @override
  String get reportComment => 'Denunciar comentário';

  @override
  String get reportEvent => 'Denunciar evento';

  @override
  String get reportMessage => 'Denunciar mensagem';

  @override
  String get reportMatchProfile => 'Denunciar perfil de match';

  @override
  String get reportPhoto => 'Denunciar foto';

  @override
  String get reportUser => 'Denunciar usuário';

  @override
  String get reportReceived =>
      'Recebemos sua denúncia. Vamos analisar e agir; sua identidade não é mostrada à pessoa denunciada.';

  @override
  String get whyReport => 'Por que você está denunciando?';

  @override
  String get detailsOptional => 'Detalhes (opcional)';

  @override
  String get detailsHint => 'Descreva rapidamente o que aconteceu.';

  @override
  String get report => 'Denunciar';
}
