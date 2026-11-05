// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LiveL10nPt extends LiveL10n {
  LiveL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get commentRate =>
      'Você comentou muito em pouco tempo. Aguarde um pouco e tente novamente.';

  @override
  String get mutedListenOnly =>
      'Você foi silenciado neste grupo e só pode ouvir.';

  @override
  String get cannotComment => 'Você não pode comentar nesta transmissão agora.';

  @override
  String get roleHost => 'Apresentador';

  @override
  String get roleSpeaker => 'Palestrante';

  @override
  String get roleListener => 'Ouvinte';

  @override
  String get startLive => 'Iniciar transmissão';

  @override
  String hostedBy(String name) {
    return 'Apresentado por $name';
  }

  @override
  String get join => 'Entrar';

  @override
  String upcomingAt(String date) {
    return 'Em breve · $date';
  }

  @override
  String get scheduledCanceled => 'Transmissão agendada cancelada.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get start => 'Iniciar';

  @override
  String get reminderRemoved => 'Lembrete removido.';

  @override
  String get reminderSet => 'Avisaremos quando começar.';

  @override
  String get reminding => 'Lembrete ativado';

  @override
  String get remind => 'Lembrar';

  @override
  String get schedule5min =>
      'Uma transmissão agendada deve começar daqui a pelo menos 5 minutos.';

  @override
  String get scheduled =>
      'Transmissão agendada. Os membros podem pedir lembrete.';

  @override
  String get liveBroadcast => 'Transmissão ao vivo';

  @override
  String get liveIntro =>
      'Os membros entram na sala de áudio; quem você chamar ao palco pode falar.';

  @override
  String get title => 'Título';

  @override
  String get titleExample => 'Ex.: Planejar a trilha de domingo';

  @override
  String get titleMin3 => 'O título deve ter pelo menos 3 caracteres.';

  @override
  String get now => 'Agora';

  @override
  String get scheduleIt => 'Agendar';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count minutos de transmissão este mês.',
      one: 'Resta 1 minuto de transmissão este mês.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'O tempo de transmissão do mês acabou. Faça upgrade do plano para ter mais.';

  @override
  String get startTheLive => 'Iniciar a transmissão';

  @override
  String get liveNow => 'Ao vivo agora';

  @override
  String trayLabel(String group, String title) {
    return '$group está ao vivo: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Você está numa transmissão: $title. Toque para voltar.';
  }

  @override
  String get connecting => 'Conectando à transmissão…';

  @override
  String get inBroadcast => 'Ao vivo · toque para voltar';

  @override
  String get micMutedByMod => 'Um responsável desligou seu microfone';

  @override
  String get micOff => 'Desligar microfone';

  @override
  String get micOn => 'Ligar microfone';

  @override
  String startsOn(String date) {
    return 'Esta transmissão começa em $date.';
  }

  @override
  String get ended => 'Esta transmissão terminou.';

  @override
  String get notFound =>
      'Transmissão não encontrada. Talvez seja preciso ser membro do grupo.';

  @override
  String get goBack => 'Voltar';

  @override
  String get onStageNow => 'Você está no palco. Ligue o microfone para falar.';

  @override
  String get nowListener => 'Agora você é ouvinte.';

  @override
  String get leaveBroadcast => 'Sair da transmissão';

  @override
  String get leaveHostBody =>
      'Você pode encerrar para todos. Se só sair, ela termina sozinha em 2 minutos.';

  @override
  String get justLeave => 'Só sair';

  @override
  String get endBroadcast => 'Encerrar a transmissão';

  @override
  String get inviteToStage => 'Chamar ao palco';

  @override
  String get removeFromStage => 'Tirar do palco';

  @override
  String get muteMic => 'Desligar o microfone';

  @override
  String get unmuteMic => 'Ligar o microfone';

  @override
  String get kick => 'Remover da transmissão';

  @override
  String kickBody(String name) {
    return '$name não poderá entrar de novo nesta transmissão.';
  }

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get raisedHands => 'Mãos levantadas';

  @override
  String get commentDeleted => 'Comentário excluído.';

  @override
  String get thanksForJoining =>
      'A transmissão terminou. Obrigado por participar.';

  @override
  String get youWereKicked => 'Você foi removido desta transmissão.';

  @override
  String get connectFailedShort => 'Não foi possível conectar à transmissão.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mãos levantadas',
      one: '1 mão levantada',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'No palco';

  @override
  String listeners(int count) {
    return 'Ouvintes · $count';
  }

  @override
  String get noListeners => 'Ainda sem ouvintes.';

  @override
  String get minimize => 'Minimizar e continuar na transmissão';

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
  String get broadcastOptions => 'Opções da transmissão';

  @override
  String get endForAll => 'Encerrar para todos';

  @override
  String get handRaised =>
      'Você levantou a mão. O apresentador pode chamar você ao palco.';

  @override
  String get you => 'Você';

  @override
  String get speaking => 'falando';

  @override
  String get micOffState => 'microfone desligado';

  @override
  String get handUp => 'mão levantada';

  @override
  String get sendReaction => 'Enviar reação';

  @override
  String get leave => 'Sair';

  @override
  String get leaveStage => 'Sair do palco';

  @override
  String get reactions => 'Reações';

  @override
  String get comments => 'Comentários';

  @override
  String get raiseHand => 'Levantar a mão';

  @override
  String get lowerHand => 'Abaixar a mão';

  @override
  String get report => 'Denunciar';

  @override
  String get deleteComment => 'Excluir comentário';

  @override
  String get firstComment => 'Seja o primeiro a comentar.';

  @override
  String get writeComment => 'Escreva um comentário…';

  @override
  String get send => 'Enviar';

  @override
  String get connectFailed =>
      'Não foi possível conectar à transmissão. Verifique a conexão e tente novamente.';

  @override
  String get participant => 'Participante';

  @override
  String get micNeedsManager =>
      'Só um responsável pela transmissão pode ligar seu microfone.';

  @override
  String get micFailed =>
      'Não foi possível ligar o microfone. Verifique a permissão do microfone.';

  @override
  String get connectionLost =>
      'A conexão com a transmissão caiu. Toque para reconectar.';

  @override
  String get micAfterEncryption =>
      'Criando a conexão criptografada; seu microfone vai ligar em instantes.';

  @override
  String get encrypting => 'Criando a conexão criptografada…';

  @override
  String get verifying => 'Verificando a criptografia…';

  @override
  String get liveSecure => 'Transmissão segura';

  @override
  String get liveSecureDetail =>
      'Criptografia de ponta a ponta. Todos na sala usam a mesma chave; ninguém, nem o servidor, pode ouvir.';

  @override
  String get liveCheckFailed =>
      'Não foi possível verificar a criptografia: nem todos na sala usam a mesma chave. Saia da transmissão e entre de novo.';

  @override
  String get liveUnconfirmed =>
      'Alguém no palco usa uma versão antiga do app; o áudio não pode ser criptografado e não é tocado.';

  @override
  String get peerUnencrypted =>
      'Um orador com versão antiga envia áudio sem criptografia, que não é tocado. Ele precisa atualizar o app.';

  @override
  String get e2ee => 'Criptografia de ponta a ponta';

  @override
  String get showSecurityCode => 'Mostrar código de segurança';

  @override
  String get codeMatchHint => 'Este código é o mesmo na tela de todos na sala.';

  @override
  String e2eeCode(String code) {
    return 'Criptografia de ponta a ponta. Código de segurança $code';
  }

  @override
  String get liveOngoingTitle => 'Você está numa transmissão ao vivo';

  @override
  String get liveOngoingText =>
      'Criptografia de ponta a ponta. Toque para voltar.';
}
