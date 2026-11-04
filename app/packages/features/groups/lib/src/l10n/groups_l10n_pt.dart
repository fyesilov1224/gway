// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class GroupsL10nPt extends GroupsL10n {
  GroupsL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get unsupportedImage =>
      'Este tipo de arquivo não é compatível. Escolha JPEG, PNG ou WebP.';

  @override
  String get joinOpen => 'Aberto a todos';

  @override
  String get joinOpenHint => 'Qualquer pessoa pode entrar diretamente.';

  @override
  String get joinRequest => 'Entrada por solicitação';

  @override
  String get joinRequestHint => 'Os administradores aprovam os pedidos.';

  @override
  String get joinInvite => 'Só por convite';

  @override
  String get joinInviteHint => 'Só pessoas convidadas podem entrar.';

  @override
  String get roleOwner => 'Dono do grupo';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleDiscipline => 'Comitê disciplinar';

  @override
  String get roleModerator => 'Moderador';

  @override
  String get roleMember => 'Membro';

  @override
  String get handleMin =>
      'O endereço do grupo deve ter pelo menos 3 caracteres.';

  @override
  String get handleChars =>
      'Use só letras minúsculas, números, sublinhados e pontos.';

  @override
  String get handleDots =>
      'Não pode começar nem terminar com ponto nem ter dois seguidos.';

  @override
  String get nameMin => 'O nome do grupo deve ter pelo menos 3 caracteres.';

  @override
  String nameMax(int max) {
    return 'O nome do grupo pode ter no máximo $max caracteres.';
  }

  @override
  String get httpsOnly => 'Digite um endereço que comece com https://.';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get groupInfo => 'Dados do grupo';

  @override
  String get groupInfoHint =>
      'Você pode adicionar logo, capa, regras e links depois de criar o grupo.';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String get about => 'Sobre';

  @override
  String get aboutHint => 'O que o grupo faz e quem pode participar?';

  @override
  String get joining => 'Entrada';

  @override
  String get changeLater => 'Você pode mudar isso depois.';

  @override
  String get createTheGroup => 'Criar o grupo';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get noEditPermission =>
      'Você não tem permissão para editar este grupo.';

  @override
  String get backToGroup => 'Voltar ao grupo';

  @override
  String get save => 'Salvar';

  @override
  String get logoAndCover => 'Logo e capa';

  @override
  String get imageHint => 'JPEG, PNG ou WebP · até 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Capa';

  @override
  String groupHandle(String handle) {
    return 'Endereço do grupo: @$handle';
  }

  @override
  String get rules => 'Regras';

  @override
  String get rulesHint => 'O que você espera dos membros, uma regra por linha.';

  @override
  String get links => 'Links';

  @override
  String linksHint(int max) {
    return 'Site e redes sociais. Até $max.';
  }

  @override
  String get enterLabel => 'Digite um rótulo.';

  @override
  String get label => 'Rótulo';

  @override
  String get address => 'Endereço';

  @override
  String get removeLink => 'Remover link';

  @override
  String get addLink => 'Adicionar link';

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get deleteGroup => 'Excluir grupo';

  @override
  String get deleteGroupBody =>
      'O grupo, as participações, funções, pedidos e convites são excluídos definitivamente. O tempo restante do plano não é reembolsado.';

  @override
  String deleteGroupNamed(String name) {
    return 'Excluir $name';
  }

  @override
  String changeImage(String label) {
    return 'Alterar $label';
  }

  @override
  String addImage(String label) {
    return 'Adicionar $label';
  }

  @override
  String get remove => 'Remover';

  @override
  String get deleteForever => 'Excluir o grupo definitivamente';

  @override
  String deleteConfirm(String handle) {
    return 'Isso não pode ser desfeito. Para confirmar, digite o endereço do grupo: $handle';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get group => 'Grupo';

  @override
  String get share => 'Compartilhar';

  @override
  String shareText(String name) {
    return 'Conheça $name no GWAY:';
  }

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get leaveGroup => 'Sair do grupo';

  @override
  String get groupNotFound =>
      'Este grupo não foi encontrado ou não está mais visível.';

  @override
  String get backToGroups => 'Voltar aos grupos';

  @override
  String leaveConfirm(String name) {
    return 'Sair de $name? Se você tiver uma função no grupo, ela também será removida.';
  }

  @override
  String get leave => 'Sair';

  @override
  String leftGroup(String name) {
    return 'Você saiu de $name.';
  }

  @override
  String get suspendedNotice =>
      'A equipe da plataforma suspendeu este grupo. Durante a suspensão, só os membros o veem.';

  @override
  String founded(String date) {
    return 'Criado em $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos aguardam aprovação.',
      one: '1 pedido aguarda aprovação.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Revisar';

  @override
  String get requestSent => 'Seu pedido foi enviado.';

  @override
  String get youAreMember => 'Você é membro';

  @override
  String get join => 'Entrar';

  @override
  String joined(String name) {
    return 'Você entrou em $name.';
  }

  @override
  String get sendJoinRequest => 'Pedir para entrar';

  @override
  String get requestSentShort => 'Solicitado';

  @override
  String get withdrawRequest => 'Retirar pedido';

  @override
  String get withdrawConfirm => 'Retirar seu pedido?';

  @override
  String get undo => 'Retirar';

  @override
  String get requestWithdrawn => 'Seu pedido foi retirado.';

  @override
  String get decline => 'Recusar';

  @override
  String get inviteDeclined => 'Convite recusado.';

  @override
  String get acceptInvite => 'Aceitar convite';

  @override
  String followOn(String name) {
    return 'As publicações de $name vão aparecer no seu feed.';
  }

  @override
  String get followOff => 'Você deixou de seguir o grupo.';

  @override
  String get following => 'Seguindo';

  @override
  String get follow => 'Seguir';

  @override
  String get managementTeam => 'Equipe de gestão';

  @override
  String allMembers(int count) {
    return 'Todos os membros ($count)';
  }

  @override
  String get groups => 'Grupos';

  @override
  String get discover => 'Descobrir';

  @override
  String get myGroups => 'Meus grupos';

  @override
  String get plans => 'Planos';

  @override
  String get searchHint => 'Buscar pelo nome ou endereço do grupo';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get all => 'Todos';

  @override
  String get noMatch => 'Nenhum grupo corresponde à sua busca.';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noGroupsYet => 'Ainda não há grupos. Crie o primeiro.';

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get notJoinedYet => 'Você ainda não entrou em nenhum grupo.';

  @override
  String get discoverGroups => 'Descobrir grupos';

  @override
  String get plansHint =>
      'Os planos são comprados pelos donos dos grupos. Crie seu grupo e escolha um plano.';

  @override
  String get yourInvitations => 'Seus convites';

  @override
  String get invitationsHint => 'Estes grupos convidaram você.';

  @override
  String invitedBy(String name) {
    return 'Convite de $name';
  }

  @override
  String get linkCopied => 'Link copiado.';

  @override
  String inviteShareText(String name) {
    return 'Entre em $name no GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Revogar o link?';

  @override
  String get revokeLinkBody =>
      'Ninguém mais poderá entrar com este link. Quem já entrou continua membro.';

  @override
  String get revoke => 'Revogar';

  @override
  String get inviteLink => 'Link de convite';

  @override
  String get inviteLinkHint =>
      'Compartilhe no WhatsApp ou no Instagram. Quem abrir o link entra direto, seja qual for o tipo de entrada.';

  @override
  String get createLink => 'Criar link';

  @override
  String validUntil(String date) {
    return 'Até $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas entraram',
      one: '1 pessoa entrou',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max entraram';
  }

  @override
  String get newInviteLink => 'Novo link de convite';

  @override
  String get validity => 'Validade';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Quantas pessoas podem entrar?';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Criar e compartilhar';

  @override
  String get invitation => 'Convite';

  @override
  String get linkInvalid =>
      'Este link de convite não é mais válido. Peça um novo ao administrador do grupo.';

  @override
  String get seeGroup => 'Ver grupo';

  @override
  String get invitedToGroup => 'Você foi convidado para este grupo.';

  @override
  String get joinGroup => 'Entrar no grupo';

  @override
  String get members => 'Membros';

  @override
  String get requests => 'Pedidos';

  @override
  String get invitations => 'Convites';

  @override
  String get roles => 'Funções';

  @override
  String get openCase => 'Abrir processo disciplinar';

  @override
  String get report => 'Denunciar';

  @override
  String membersVisibility(int shown, int total) {
    return 'Só os membros veem a lista completa. Aqui: a equipe de gestão e $shown pessoas que mostram seus grupos; o grupo tem $total membros no total.';
  }

  @override
  String optionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String get transferOwnership => 'Transferir a propriedade';

  @override
  String transferBody(String group, String person) {
    return 'A propriedade de $group passará para $person. Você continuará como membro comum e não poderá desfazer isso.';
  }

  @override
  String get transfer => 'Transferir';

  @override
  String transferred(String name) {
    return 'Propriedade transferida para $name.';
  }

  @override
  String get hintAdmin => 'Edita o grupo e gerencia pedidos e convites.';

  @override
  String get hintDiscipline =>
      'Analisa processos de denúncia e decide sanções.';

  @override
  String get hintModerator => 'Revisa conteúdos e comentários.';

  @override
  String personJoined(String name) {
    return '$name entrou no grupo.';
  }

  @override
  String get requestDeclined => 'Pedido recusado.';

  @override
  String get noPendingRequests => 'Nenhum pedido pendente.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get approve => 'Aprovar';

  @override
  String get inviteSent => 'Convite enviado.';

  @override
  String get inviteByUsername => 'Convidar pelo nome de usuário';

  @override
  String get invite => 'Convidar';

  @override
  String get noPendingInvites => 'Nenhum convite pendente.';

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
  String get suspended => 'Suspenso';

  @override
  String get groupsSection => 'Grupos';

  @override
  String get groupsOwnHint =>
      'Só membros do mesmo grupo veem seus grupos. Você pode torná-los públicos nas Configurações.';

  @override
  String get groupsOtherHint =>
      'Só aparecem os grupos em comum e os que a pessoa ajuda a gerir.';

  @override
  String get noGroupsToShow => 'Nenhum grupo para mostrar.';

  @override
  String get handleTaken => 'Este endereço já está em uso. Tente outro.';

  @override
  String get groupAddress => 'Endereço do grupo';

  @override
  String get groupAddressHint =>
      'O endereço da página do grupo. Não pode ser alterado depois.';

  @override
  String get available => 'Disponível';

  @override
  String get taken => 'Em uso';

  @override
  String get notSpecified => 'Não informado';

  @override
  String get provinceOptional => 'Província (opcional)';

  @override
  String get provinceHint => 'O grupo aparece nesta província no mapa.';

  @override
  String get chooseCategory => 'Escolha uma categoria.';

  @override
  String get category => 'Categoria';
}
