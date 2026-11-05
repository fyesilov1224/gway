// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class BillingL10nEs extends BillingL10n {
  BillingL10nEs([String locale = 'es']) : super(locale);

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get perMonth => 'mes';

  @override
  String get perYear => 'año';

  @override
  String get notOnDevice => 'No disponible en este dispositivo.';

  @override
  String get goBack => 'Volver';

  @override
  String get payment => 'Pago';

  @override
  String get planUnavailable => 'Ahora no se puede comprar este plan.';

  @override
  String get backToPlans => 'Volver a los planes';

  @override
  String get paymentPageFailed =>
      'No se pudo abrir la página de pago. Inténtalo de nuevo.';

  @override
  String get billingDetails => 'Datos de facturación';

  @override
  String get billingDetailsHint => 'Tu factura se emite con estos datos.';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellidos';

  @override
  String fieldRequired(String field) {
    return '$field es obligatorio.';
  }

  @override
  String get phone => 'Teléfono';

  @override
  String get phoneInvalid => 'Introduce un número de teléfono válido.';

  @override
  String get address => 'Dirección';

  @override
  String get addressRequired => 'Introduce tu dirección de facturación.';

  @override
  String get city => 'Ciudad';

  @override
  String get cityRequired => 'Introduce la ciudad.';

  @override
  String get country => 'País';

  @override
  String get countryRequired => 'Introduce el país.';

  @override
  String get termsBefore => 'He leído y acepto el ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Acepta el contrato para continuar.';

  @override
  String get billingDataUse =>
      'Tus datos de facturación solo se usan para cobrar, facturar y cumplir las obligaciones legales de conservación.';

  @override
  String payAmount(String amount) {
    return 'Ir al pago · $amount';
  }

  @override
  String get orderSummary => 'Resumen del pedido';

  @override
  String planPeriod(String plan, String period) {
    return 'Plan $plan · $period';
  }

  @override
  String get start => 'Inicio';

  @override
  String get whenConfirmed => 'Al confirmarse el pago';

  @override
  String get endEstimated => 'Fin (estimada)';

  @override
  String get carriedOver => 'Tiempo transferido';

  @override
  String about(String value) {
    return 'unos $value';
  }

  @override
  String get total => 'Total';

  @override
  String assuranceTry(String provider) {
    return 'El pago lo procesa $provider de forma segura en liras turcas. Los datos de tu tarjeta nunca llegan a GWAY. Es un pago único y no se renueva solo.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'El pago lo procesa $provider de forma segura en dólares estadounidenses. Los datos de tu tarjeta nunca llegan a GWAY. Es un pago único y no se renueva solo.';
  }

  @override
  String get overLimit =>
      'Hay más miembros que el límite del plan. No entra nadie nuevo hasta bajar del límite.';

  @override
  String get atLimit =>
      'El grupo alcanzó el límite de miembros de su plan. No pueden entrar más.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max miembros';
  }

  @override
  String get plan => 'Plan';

  @override
  String get getPlan => 'Conseguir un plan';

  @override
  String get upgradePlan => 'Mejorar plan';

  @override
  String planEnds(String date) {
    return 'Tu plan termina el $date. Después el grupo vuelve al plan gratuito.';
  }

  @override
  String get paymentReceivedPersonal => 'Pago recibido. Tu plan está activo.';

  @override
  String get planStatus => 'Estado del plan';

  @override
  String get notActive => 'Este plan no está activo en tu cuenta.';

  @override
  String activeUntil(String date) {
    return 'Tu plan está activo hasta el $date.';
  }

  @override
  String get buy => 'Comprar';

  @override
  String get extend => 'Ampliar';

  @override
  String get oneTime => 'Pago único; no se renueva automáticamente.';

  @override
  String newPeriodAfter(String date) {
    return 'El nuevo periodo empieza después del $date.';
  }

  @override
  String get salesClosed =>
      'La venta de este plan está cerrada ahora. Inténtalo más tarde.';

  @override
  String continueAmount(String amount) {
    return 'Continuar · $amount';
  }

  @override
  String get personalOnly =>
      'Este plan solo te cubre a ti; no afecta al plan de tu grupo.';

  @override
  String saving(int percent) {
    return 'Ahorra un $percent %';
  }

  @override
  String untilDate(String date) {
    return 'Hasta el $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Ahora no se puede comprar este producto.';

  @override
  String get personalProduct => 'Producto personal';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Tu grupo está listo';

  @override
  String get freeStartBuy =>
      'Tu grupo empezó con el plan gratuito. Si necesitas más miembros, eventos o minutos en directo, elige un plan abajo.';

  @override
  String get freeStartView =>
      'Tu grupo empezó con el plan gratuito. Los límites de los planes están abajo.';

  @override
  String get continueFree => 'Seguir con el gratuito';

  @override
  String get goToGroup => 'Ir al grupo';

  @override
  String get paymentReceivedGroup => 'Pago recibido. Tu plan está activo.';

  @override
  String get membersOnly => 'Solo los miembros del grupo ven su plan.';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get onFree => 'El grupo usa el plan gratuito.';

  @override
  String periodEnds(String date) {
    return 'Este periodo termina el $date.';
  }

  @override
  String get overLimitLong =>
      'Hay más miembros que el límite. No se expulsa a nadie, pero no entra nadie nuevo hasta bajar del límite.';

  @override
  String get atLimitLong =>
      'El grupo alcanzó su límite. Cambia a un plan mayor para aceptar nuevos miembros.';

  @override
  String get upcomingPeriods => 'Próximos periodos';

  @override
  String get plans => 'Planes';

  @override
  String get yearlyDeal => 'Anual · 2 meses gratis';

  @override
  String paymentNoteTry(String provider) {
    return 'El pago lo procesa $provider en liras turcas, según tu país. Sin renovación automática.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'El pago lo procesa $provider en dólares estadounidenses, según tu país. Sin renovación automática.';
  }

  @override
  String get paymentsOff =>
      'Ahora no se pueden recibir pagos. Inténtalo más tarde.';

  @override
  String get notNow => 'No disponible por ahora';

  @override
  String get choose => 'Elegir';

  @override
  String get upgrade => 'Mejorar';

  @override
  String get renew => 'Ampliar';

  @override
  String get switchTo => 'Cambiar a este plan';

  @override
  String get paidOverYear =>
      'Tu plan está pagado para más de un año. Por ahora solo puedes mejorarlo.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Empieza ya; se suman unos $credit de tu tiempo restante. Fin: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Empieza ya. Fin: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Empieza el $date, después del periodo actual.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Empieza el $date, al terminar el periodo actual.';
  }

  @override
  String get confirmPending =>
      'Aún no llegó la confirmación del pago. Si se te cobró, tu plan se activará en unos minutos; puedes actualizar la página más tarde.';

  @override
  String get confirming => 'Confirmando tu pago. Puede tardar unos segundos.';

  @override
  String get paymentFailed =>
      'No se pudo completar el pago. Inténtalo de nuevo o usa otra tarjeta.';

  @override
  String get refunded => 'Este pago se ha reembolsado.';

  @override
  String get members => 'Miembros';

  @override
  String membersSemantics(int count, int max) {
    return '$count miembros, límite $max';
  }

  @override
  String limitMembers(String count) {
    return '$count miembros';
  }

  @override
  String limitEvents(String count) {
    return '$count eventos / mes';
  }

  @override
  String limitLive(String count) {
    return '$count min en directo / mes';
  }

  @override
  String planName(String plan) {
    return 'Plan $plan';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Plan $plan · hasta el $date';
  }

  @override
  String creditDays(String days) {
    return '$days días';
  }

  @override
  String get termsTranslationNote =>
      'Esta traducción es informativa. El contrato vinculante, y el que aceptas, es el original en turco.';

  @override
  String get showOriginal => 'Ver el original en turco';

  @override
  String get showTranslation => 'Ver la traducción';

  @override
  String get planNameFree => 'Gratis';

  @override
  String get planNameStarter => 'Inicial';

  @override
  String get planNameCommunity => 'Comunidad';
}
