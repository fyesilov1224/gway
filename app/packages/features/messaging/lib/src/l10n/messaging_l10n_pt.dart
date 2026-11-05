// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class MessagingL10nPt extends MessagingL10n {
  MessagingL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get groupInvalid =>
      'Você só pode enviar o pedido a um grupo de que faz parte.';

  @override
  String get permissionExists =>
      'Seu pedido já foi recebido ou sua permissão está ativa.';

  @override
  String get permissionCooldown =>
      'Você poderá enviar um novo pedido 7 dias após a última decisão.';

  @override
  String noteTooLong(int max) {
    return 'A nota pode ter até $max caracteres.';
  }

  @override
  String get requestForbidden => 'Não é possível enviar o pedido agora.';

  @override
  String get unsupportedImage =>
      'Este tipo de arquivo não é compatível. Escolha JPEG, PNG ou WebP.';

  @override
  String get voiceCallHandle => 'Chamada de voz GWAY';

  @override
  String get incomingCalls => 'Chamadas recebidas';

  @override
  String get missedCalls => 'Chamadas perdidas';

  @override
  String get answer => 'Atender';

  @override
  String get decline => 'Recusar';

  @override
  String get noAnswer => 'Sem resposta';

  @override
  String get missedCall => 'Chamada perdida';

  @override
  String get callDeclined => 'Chamada recusada';

  @override
  String get youDeclined => 'Você recusou a chamada';

  @override
  String get callNotAllowed => 'Não é mais possível ligar';

  @override
  String get callCanceled => 'Chamada cancelada';

  @override
  String get timeLimit => 'Os 60 minutos acabaram; a chamada terminou';

  @override
  String get endedNotAllowed =>
      'Chamada encerrada: chamadas de voz não são mais possíveis';

  @override
  String get callEnded => 'Chamada encerrada';

  @override
  String get messageDeleted => 'Mensagem apagada';

  @override
  String get photo => 'Foto';

  @override
  String get tonightTable => 'A mesa de hoje';

  @override
  String get blockRequestPending =>
      'Aceite o pedido de mensagem antes de responder.';

  @override
  String get blockDeclined => 'Esta pessoa não aceitou seu pedido de mensagem.';

  @override
  String get blockMuted =>
      'Você foi silenciado neste grupo e não pode escrever agora.';

  @override
  String get blockAdminsOnly => 'Só administradores podem escrever neste chat.';

  @override
  String get blockTableClosed =>
      'A mesa fechou; você pode ler as mensagens, mas não escrever novas.';

  @override
  String get blockBlocked =>
      'Não é possível escrever aqui por causa de um bloqueio.';

  @override
  String get blockMatchEnded =>
      'Este chat foi fechado porque o match terminou.';

  @override
  String get blockMatchLocked =>
      'Para escrever ao seu match, é preciso o plano Chat de Match. Ler as mensagens é grátis.';

  @override
  String get blockTeammateLocked =>
      'Para escrever ao seu parceiro, é preciso o plano Parceiro de Equipe. Ler é grátis.';

  @override
  String get blockNotAllowed =>
      'Mensagens diretas agora são só para matches e parceiros. Você ainda pode ler as antigas.';

  @override
  String get blockOther => 'Você não pode escrever neste chat agora.';

  @override
  String get hiddenUser => 'Usuário GWAY';

  @override
  String get voiceCalls => 'Chamadas de voz';

  @override
  String get voiceCallsHeadline =>
      'Converse por voz com seus matches e parceiros';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Com as chamadas de voz você liga para seus matches e parceiros pelo chat privado. Não são abertas a todos: você pede a um grupo de que faz parte, e o dono ou um administrador ativa. As chamadas não são gravadas nem ouvidas; duram no máximo $minutes minutos.';
  }

  @override
  String get status => 'Status';

  @override
  String get notRequested => 'Não solicitado';

  @override
  String get underReview => 'Em análise';

  @override
  String get statusOn => 'Ativado';

  @override
  String get statusOff => 'Desativado';

  @override
  String get notRequestedYet => 'Você ainda não solicitou.';

  @override
  String requestedFrom(String group) {
    return 'Seu pedido chegou aos administradores de $group. Você será avisado da decisão.';
  }

  @override
  String get requestedFromGroup =>
      'Seu pedido chegou aos administradores do grupo. Você será avisado da decisão.';

  @override
  String activeFrom(String group) {
    return 'Suas chamadas de voz estão ativadas ($group). Ligue para matches e parceiros pelo ícone de telefone no topo do chat; eles também precisam de permissão.';
  }

  @override
  String get active =>
      'Suas chamadas de voz estão ativadas. Ligue para matches e parceiros pelo ícone de telefone no topo do chat; eles também precisam de permissão.';

  @override
  String get declined => 'Seu pedido não foi aprovado por enquanto.';

  @override
  String get revokedLeftGroup =>
      'Suas chamadas de voz foram desativadas porque você saiu do grupo que as concedeu. Você pode pedir de novo em outro grupo.';

  @override
  String get revoked => 'Suas chamadas de voz foram desativadas.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Sua nota: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Você poderá pedir de novo depois de $date.';
  }

  @override
  String get requestSent => 'Seu pedido foi enviado.';

  @override
  String get joinGroupFirst =>
      'Donos e administradores de grupos ativam as chamadas de voz. Entre primeiro em um grupo para pedir.';

  @override
  String get requestToGroup => 'Grupo para o pedido';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get noteHint =>
      'Você pode explicar rapidamente por que quer as chamadas.';

  @override
  String get request => 'Solicitar';

  @override
  String get lockScreenCalls => 'Chamadas na tela de bloqueio';

  @override
  String get lockScreenHint =>
      'Permita que o GWAY toque em tela cheia com o celular bloqueado.';

  @override
  String get allow => 'Permitir';

  @override
  String get callInfoFailed =>
      'Não foi possível carregar a chamada. Verifique sua conexão.';

  @override
  String get tapEndToHangUp => 'Toque em Encerrar para desligar.';

  @override
  String get callNotFound => 'Chamada não encontrada.';

  @override
  String get close => 'Fechar';

  @override
  String callLimitNote(int minutes) {
    return 'Uma chamada dura no máximo $minutes minutos e não é gravada.';
  }

  @override
  String get audioFailed =>
      'Não foi possível conectar o áudio. Verifique a conexão e tente novamente.';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get incoming => 'está ligando para você…';

  @override
  String get calling => 'Chamando…';

  @override
  String get connecting => 'Conectando…';

  @override
  String get answerCall => 'Atender';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Ativar som';

  @override
  String get end => 'Encerrar';

  @override
  String get speaker => 'Alto-falante';

  @override
  String get peerUnencrypted =>
      'O app da outra pessoa está desatualizado; o áudio não é criptografado e não é tocado. Peça para atualizar.';

  @override
  String get encrypting => 'Estabelecendo conexão criptografada…';

  @override
  String e2eeCode(String code) {
    return 'Criptografia de ponta a ponta. Código de segurança $code';
  }

  @override
  String get e2ee => 'Criptografia de ponta a ponta';

  @override
  String get codeMatchHint =>
      'Se este código for igual ao da tela da outra pessoa, ninguém pode ouvir.';

  @override
  String get micFailed =>
      'Não foi possível ligar o microfone. Verifique a permissão do microfone.';

  @override
  String get chatNotFound => 'Chat não encontrado ou você não pode mais vê-lo.';

  @override
  String get backToMessages => 'Voltar às mensagens';

  @override
  String get cantCallNow => 'Não é possível ligar agora.';

  @override
  String get voiceCall => 'Chamada de voz';

  @override
  String get groupChatAdminsOnly =>
      'Chat de grupo · só administradores escrevem';

  @override
  String get groupChat => 'Chat de grupo';

  @override
  String smallTableMembers(int count) {
    return 'Mesinha · $count pessoas';
  }

  @override
  String get adminsOnlyOn =>
      'Agora só o dono e os administradores podem escrever neste chat.';

  @override
  String get adminsOnlyOff =>
      'Agora todos os membros do grupo podem escrever neste chat.';

  @override
  String get chatSettings => 'Configurações do chat';

  @override
  String get adminsOnlyToggle => 'Só administradores escrevem';

  @override
  String get sendingPhoto => '📷 Enviando foto…';

  @override
  String get requestPendingNote =>
      'Seu pedido de mensagem foi enviado. Até ser aceito, você não vê se foi lido.';

  @override
  String get groupChatEmpty =>
      'Ainda não há mensagens no chat do grupo. Escreva a primeira.';

  @override
  String get chatEmpty => 'Ainda não há mensagens. Escreva a primeira.';

  @override
  String get startWriting => 'Começar a escrever';

  @override
  String get sending => 'Enviando…';

  @override
  String get seen => 'Visto';

  @override
  String get sent => 'Enviada';

  @override
  String get seePackage => 'Ver o plano';

  @override
  String get today => 'Hoje';

  @override
  String get messageRemoved => 'Esta mensagem foi removida.';

  @override
  String get thisMessageDeleted => 'Esta mensagem foi apagada.';

  @override
  String get messageOptions => 'Opções da mensagem';

  @override
  String profileOf(String name) {
    return 'Perfil de $name';
  }

  @override
  String get you => 'Você';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Mensagem copiada.';

  @override
  String get deleteForAll => 'Apagar para todos';

  @override
  String get report => 'Denunciar';

  @override
  String get deleteForAllTitle => 'Apagar a mensagem para todos?';

  @override
  String get deleteForAllBody =>
      'Todos no chat verão \"Esta mensagem foi apagada\". Não é possível desfazer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Apagar';

  @override
  String get requestDeleted => 'Pedido de mensagem apagado.';

  @override
  String wantsToMessage(String name) {
    return '$name quer mandar mensagem. Se aceitar, vocês podem conversar e a pessoa verá quando você ler.';
  }

  @override
  String get accept => 'Aceitar';

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get writeMessage => 'Escreva uma mensagem';

  @override
  String get send => 'Enviar';

  @override
  String get messages => 'Mensagens';

  @override
  String get chats => 'Conversas';

  @override
  String get requests => 'Pedidos';

  @override
  String requestsCount(int count) {
    return 'Pedidos ($count)';
  }

  @override
  String get noChats =>
      'Você ainda não tem conversas. Pode escrever para matches e parceiros.';

  @override
  String get findPeople => 'Encontrar pessoas';

  @override
  String get oldRequestsNote =>
      'Pedidos antigos ficam aqui. Mensagens diretas agora são só para matches e parceiros; não chegam novos pedidos.';

  @override
  String get noRequests => 'Nenhum pedido de mensagem pendente.';

  @override
  String get backToChats => 'Voltar às conversas';

  @override
  String get callRequests => 'Pedidos de chamadas de voz';

  @override
  String noPendingWithActive(int count) {
    return 'Nenhum pedido pendente · $count ativos';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos pendentes',
      one: '1 pedido pendente',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'Pendentes';

  @override
  String get activeTab => 'Ativos';

  @override
  String get requestsOwnersOnly =>
      'Só o dono e os administradores veem os pedidos.';

  @override
  String get goBack => 'Voltar';

  @override
  String noPendingFor(String group) {
    return 'Nenhum pedido pendente. Os dos membros de $group aparecem aqui.';
  }

  @override
  String get noActive => 'Este grupo não concedeu chamadas de voz.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get grantHint =>
      'Com a permissão concedida, a pessoa pode ligar para todos os matches e parceiros. As chamadas não são gravadas; se ela sair do grupo, a permissão acaba.';

  @override
  String get granted => 'Chamadas de voz ativadas.';

  @override
  String get turnedOff => 'Chamadas de voz desativadas.';

  @override
  String theirNote(String note) {
    return 'Nota: $note';
  }

  @override
  String get turnOff => 'Desativar';

  @override
  String get turnOn => 'Ativar';

  @override
  String get rankOnlyGrant =>
      'A posição é igual ou superior à sua; você só pode aprovar este pedido.';

  @override
  String get rankCannotRevoke =>
      'A posição é igual ou superior à sua; você não pode desativar.';

  @override
  String get declineRequest => 'Recusar pedido';

  @override
  String get turnOffCalls => 'Desativar chamadas de voz';

  @override
  String get declineHint =>
      'A pessoa vê o motivo e pode pedir de novo após 7 dias.';

  @override
  String get revokeHint =>
      'Uma chamada em andamento termina na hora. A pessoa vê o motivo e pode pedir de novo após 7 dias.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonMin3 => 'O motivo deve ter pelo menos 3 caracteres.';

  @override
  String get yesterday => 'Ontem';

  @override
  String get sendMessage => 'Enviar mensagem';

  @override
  String get groupChatMembersOnly => 'Só membros do grupo veem o chat.';

  @override
  String get callVerifying => 'Verificando a criptografia…';

  @override
  String get callSecure => 'Chamada segura';

  @override
  String get callSecureDetail =>
      'Criptografia de ponta a ponta. Os códigos de segurança dos dois telefones coincidem; ninguém está no meio.';

  @override
  String get callCheckFailed =>
      'Não foi possível verificar a criptografia: os códigos de segurança não coincidem. Encerre e ligue de novo.';

  @override
  String get showSecurityCode => 'Mostrar código de segurança';
}
