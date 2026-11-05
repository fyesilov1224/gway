// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class BillingL10nPt extends BillingL10n {
  BillingL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get perMonth => 'mês';

  @override
  String get perYear => 'ano';

  @override
  String get notOnDevice => 'Indisponível neste dispositivo.';

  @override
  String get goBack => 'Voltar';

  @override
  String get payment => 'Pagamento';

  @override
  String get planUnavailable => 'Não é possível comprar este plano agora.';

  @override
  String get backToPlans => 'Voltar aos planos';

  @override
  String get paymentPageFailed =>
      'Não foi possível abrir a página de pagamento. Tente novamente.';

  @override
  String get billingDetails => 'Dados de faturamento';

  @override
  String get billingDetailsHint => 'Sua nota fiscal é emitida com estes dados.';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Sobrenome';

  @override
  String fieldRequired(String field) {
    return '$field é obrigatório.';
  }

  @override
  String get phone => 'Telefone';

  @override
  String get phoneInvalid => 'Digite um telefone válido.';

  @override
  String get address => 'Endereço';

  @override
  String get addressRequired => 'Digite seu endereço de cobrança.';

  @override
  String get city => 'Cidade';

  @override
  String get cityRequired => 'Digite a cidade.';

  @override
  String get country => 'País';

  @override
  String get countryRequired => 'Digite o país.';

  @override
  String get termsBefore => 'Li e aceito o ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Aceite o contrato para continuar.';

  @override
  String get billingDataUse =>
      'Seus dados de faturamento são usados apenas para o pagamento, a nota fiscal e as obrigações legais de guarda.';

  @override
  String payAmount(String amount) {
    return 'Ir para o pagamento · $amount';
  }

  @override
  String get orderSummary => 'Resumo do pedido';

  @override
  String planPeriod(String plan, String period) {
    return 'Plano $plan · $period';
  }

  @override
  String get start => 'Início';

  @override
  String get whenConfirmed => 'Quando o pagamento for confirmado';

  @override
  String get endEstimated => 'Término (estimado)';

  @override
  String get carriedOver => 'Tempo transferido';

  @override
  String about(String value) {
    return 'cerca de $value';
  }

  @override
  String get total => 'Total';

  @override
  String assuranceTry(String provider) {
    return 'O pagamento é processado com segurança pela $provider em liras turcas. Os dados do cartão nunca chegam ao GWAY. Pagamento único, sem renovação automática.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'O pagamento é processado com segurança pela $provider em dólares americanos. Os dados do cartão nunca chegam ao GWAY. Pagamento único, sem renovação automática.';
  }

  @override
  String get overLimit =>
      'O número de membros passa do limite do plano. Ninguém novo entra até ficar abaixo do limite.';

  @override
  String get atLimit =>
      'O grupo atingiu o limite de membros do plano. Ninguém novo pode entrar.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max membros';
  }

  @override
  String get plan => 'Plano';

  @override
  String get getPlan => 'Assinar um plano';

  @override
  String get upgradePlan => 'Fazer upgrade';

  @override
  String planEnds(String date) {
    return 'Seu plano termina em $date. Depois o grupo volta ao plano gratuito.';
  }

  @override
  String get paymentReceivedPersonal =>
      'Pagamento recebido. Seu plano está ativo.';

  @override
  String get planStatus => 'Status do plano';

  @override
  String get notActive => 'Este plano não está ativo na sua conta.';

  @override
  String activeUntil(String date) {
    return 'Seu plano está ativo até $date.';
  }

  @override
  String get buy => 'Comprar';

  @override
  String get extend => 'Estender';

  @override
  String get oneTime => 'Pagamento único; sem renovação automática.';

  @override
  String newPeriodAfter(String date) {
    return 'O novo período começa após $date.';
  }

  @override
  String get salesClosed =>
      'A venda deste plano está fechada agora. Tente mais tarde.';

  @override
  String continueAmount(String amount) {
    return 'Continuar · $amount';
  }

  @override
  String get personalOnly =>
      'Este plano cobre só você; não afeta o plano do seu grupo.';

  @override
  String saving(int percent) {
    return 'Economize $percent%';
  }

  @override
  String untilDate(String date) {
    return 'Até $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Não é possível comprar este produto agora.';

  @override
  String get personalProduct => 'Produto pessoal';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Seu grupo está pronto';

  @override
  String get freeStartBuy =>
      'Seu grupo começou no plano gratuito. Se precisar de mais membros, eventos ou minutos ao vivo, escolha um plano abaixo.';

  @override
  String get freeStartView =>
      'Seu grupo começou no plano gratuito. Os limites dos planos estão abaixo.';

  @override
  String get continueFree => 'Continuar no gratuito';

  @override
  String get goToGroup => 'Ir para o grupo';

  @override
  String get paymentReceivedGroup =>
      'Pagamento recebido. Seu plano está ativo.';

  @override
  String get membersOnly => 'Só membros do grupo veem o plano.';

  @override
  String get currentPlan => 'Plano atual';

  @override
  String get onFree => 'O grupo usa o plano gratuito.';

  @override
  String periodEnds(String date) {
    return 'Este período termina em $date.';
  }

  @override
  String get overLimitLong =>
      'O número de membros passa do limite. Ninguém é removido, mas ninguém novo entra até ficar abaixo do limite.';

  @override
  String get atLimitLong =>
      'O grupo atingiu o limite. Mude para um plano maior para aceitar novos membros.';

  @override
  String get upcomingPeriods => 'Próximos períodos';

  @override
  String get plans => 'Planos';

  @override
  String get yearlyDeal => 'Anual · 2 meses grátis';

  @override
  String paymentNoteTry(String provider) {
    return 'O pagamento é feito pela $provider em liras turcas, conforme seu país. Sem renovação automática.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'O pagamento é feito pela $provider em dólares americanos, conforme seu país. Sem renovação automática.';
  }

  @override
  String get paymentsOff =>
      'Não é possível receber pagamentos agora. Tente mais tarde.';

  @override
  String get notNow => 'Indisponível no momento';

  @override
  String get choose => 'Escolher';

  @override
  String get upgrade => 'Fazer upgrade';

  @override
  String get renew => 'Estender';

  @override
  String get switchTo => 'Mudar para este plano';

  @override
  String get paidOverYear =>
      'Seu plano está pago para mais de um ano. Por enquanto só é possível fazer upgrade.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Começa já; cerca de $credit do seu tempo restante é somado. Término: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Começa já. Término: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Começa em $date, após o período atual.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Começa em $date, quando o período atual terminar.';
  }

  @override
  String get confirmPending =>
      'A confirmação do pagamento ainda não chegou. Se houve cobrança, o plano ativa em alguns minutos; você pode atualizar a página depois.';

  @override
  String get confirming =>
      'Confirmando seu pagamento. Pode levar alguns segundos.';

  @override
  String get paymentFailed =>
      'Não foi possível concluir o pagamento. Tente de novo ou use outro cartão.';

  @override
  String get refunded => 'Este pagamento foi reembolsado.';

  @override
  String get members => 'Membros';

  @override
  String membersSemantics(int count, int max) {
    return '$count membros, limite $max';
  }

  @override
  String limitMembers(String count) {
    return '$count membros';
  }

  @override
  String limitEvents(String count) {
    return '$count eventos / mês';
  }

  @override
  String limitLive(String count) {
    return '$count min ao vivo / mês';
  }

  @override
  String planName(String plan) {
    return 'Plano $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Plano $plan · até $date';
  }

  @override
  String creditDays(String days) {
    return '$days dias';
  }

  @override
  String get termsTranslationNote =>
      'Esta tradução é informativa. O contrato vinculante, e o que você aceita, é o original em turco.';

  @override
  String get showOriginal => 'Ver o original em turco';

  @override
  String get showTranslation => 'Ver a tradução';
}
