// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SupportL10nPt extends SupportL10n {
  SupportL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Você abriu mensagens demais hoje. Tente amanhã ou responda nas mensagens abertas.';

  @override
  String get ruleReplyRate =>
      'Você escreveu respostas demais em pouco tempo. Aguarde um pouco e tente de novo.';

  @override
  String get ticketClosed =>
      'Esta mensagem foi fechada. Abra uma nova para continuar.';

  @override
  String get unsupportedImage =>
      'Este tipo de arquivo não é compatível. Escolha JPEG, PNG ou WebP.';

  @override
  String get kindProblem => 'Problema';

  @override
  String get kindProblemText => 'Algo está quebrado ou não funciona.';

  @override
  String get kindRequest => 'Solicitação';

  @override
  String get kindRequestText =>
      'Peça uma ação para sua conta, grupo ou pagamento.';

  @override
  String get kindSuggestion => 'Sugestão';

  @override
  String get kindSuggestionText => 'Compartilhe uma ideia ou sugestão.';

  @override
  String get statusOpen => 'Novo';

  @override
  String get statusInProgress => 'Em análise';

  @override
  String get statusResolved => 'Resolvido';

  @override
  String get statusClosed => 'Fechado';

  @override
  String get guide => 'Guia de uso';

  @override
  String get guideSearchHint => 'Pesquisar no guia: ex. link de convite, senha';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get guideIntro =>
      'Explica cada parte do GWAY passo a passo. Escolha um capítulo ou pesquise acima.';

  @override
  String get noHits =>
      'Não encontramos nada. Tente outra palavra ou escreva para o suporte.';

  @override
  String get writeSupport => 'Escrever ao suporte';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tópicos encontrados',
      one: '1 tópico encontrado',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count tópicos.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tópicos',
      one: '1 tópico',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'Capítulo não encontrado.';

  @override
  String get backToGuide => 'Voltar ao guia';

  @override
  String get notSolved => 'Seu problema não foi resolvido?';

  @override
  String get notSolvedHint =>
      'Escreva para a equipe da plataforma; a resposta aparece em Configurações → Suporte e feedback.';

  @override
  String get nextChapter => 'Próximo capítulo';

  @override
  String get sent => 'Sua mensagem foi enviada à equipe da plataforma.';

  @override
  String get newMessage => 'Nova mensagem';

  @override
  String get aboutWhat => 'Sobre o que você está escrevendo?';

  @override
  String get pickKind => 'Escolha um tipo.';

  @override
  String get relatedGroup => 'Grupo relacionado (opcional)';

  @override
  String get noGroup => 'Não é sobre um grupo';

  @override
  String get subject => 'Assunto';

  @override
  String get subjectRequired => 'Escreva um assunto curto.';

  @override
  String get description => 'Descrição';

  @override
  String get descriptionHint =>
      'O que aconteceu e o que você esperava? Quanto mais detalhes, mais rápida a ajuda.';

  @override
  String get descriptionRequired => 'Descreva rapidamente o que aconteceu.';

  @override
  String get send => 'Enviar';

  @override
  String get supportTitle => 'Suporte e feedback';

  @override
  String get emptyIntro =>
      'Você pode escrever à equipe da plataforma sobre um problema, solicitação ou sugestão.';

  @override
  String get listIntro =>
      'Suas mensagens vão para a equipe da plataforma; acompanhe aqui respostas e status.';

  @override
  String get newReply => 'Nova resposta';

  @override
  String get message => 'Mensagem';

  @override
  String get notFound => 'Mensagem não encontrada.';

  @override
  String get goBack => 'Voltar';

  @override
  String get team => 'Equipe GWAY';

  @override
  String get you => 'Você';

  @override
  String get addScreenshot => 'Adicionar captura de tela';

  @override
  String get writeReply => 'Escreva uma resposta';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String screenshots(int count, int max) {
    return 'Capturas de tela ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Ampliar captura de tela';
}
