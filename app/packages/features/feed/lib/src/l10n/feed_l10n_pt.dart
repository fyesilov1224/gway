// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FeedL10nPt extends FeedL10n {
  FeedL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get commentsOff =>
      'Os comentários estão desativados nesta publicação.';

  @override
  String get commentNotAllowed =>
      'Não é possível comentar nesta publicação agora. Você pode reagir com um emoji.';

  @override
  String get blocked => 'Você não pode interagir com esta conta.';

  @override
  String get commentRate =>
      'Você comentou muito em pouco tempo. Aguarde um pouco e tente novamente.';

  @override
  String get muted =>
      'Você foi silenciado neste grupo e não pode comentar agora.';

  @override
  String get likeRate =>
      'Você curtiu muito em pouco tempo. Aguarde um pouco e tente novamente.';

  @override
  String get replyGone => 'O comentário que você respondeu não existe mais.';

  @override
  String get storyRate =>
      'Você compartilhou muitos stories hoje. Tente novamente amanhã.';

  @override
  String get highlightLimit => 'Você pode criar até 100 destaques.';

  @override
  String get highlightFull => 'Um destaque pode ter até 100 stories.';

  @override
  String get duplicate => 'Isso já foi feito.';

  @override
  String get fileTooLarge =>
      'O arquivo é muito grande. Fotos podem ter até 10 MB e vídeos até 50 MB.';

  @override
  String get unsupportedMedia =>
      'Só é possível compartilhar fotos JPEG, PNG, WebP e vídeos MP4, MOV.';

  @override
  String get commentLength => 'O comentário deve ter de 1 a 2.200 caracteres.';

  @override
  String get highlightTitleLength => 'O título deve ter de 1 a 30 caracteres.';

  @override
  String get pickStory => 'Escolha pelo menos um story.';

  @override
  String get aspectOriginal => 'Original';

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
  String agoWeeks(int n) {
    return '$n sem';
  }

  @override
  String get photoLimit => 'As fotos podem ter até 10 MB.';

  @override
  String get videoSizeLimit => 'Os vídeos podem ter até 50 MB.';

  @override
  String get videoLengthLimit => 'Os vídeos podem ter até 60 segundos.';

  @override
  String get captionLimit => 'A legenda pode ter até 2.200 caracteres.';

  @override
  String get hashtagLimit => 'Uma publicação pode ter até 30 hashtags.';

  @override
  String get mediaCount => 'Uma publicação pode ter de 1 a 10 fotos ou vídeos.';

  @override
  String get comments => 'Comentários';

  @override
  String get noCommentsEmojiOnly =>
      'Ainda não há comentários. Você pode reagir com um emoji.';

  @override
  String get noCommentsFirst =>
      'Ainda não há comentários. Seja o primeiro a comentar.';

  @override
  String get goBack => 'Voltar';

  @override
  String get writeComment => 'Escrever um comentário';

  @override
  String replyingTo(String username) {
    return 'Respondendo a $username';
  }

  @override
  String get cancelReply => 'Cancelar resposta';

  @override
  String get addComment => 'Adicione um comentário…';

  @override
  String get share => 'Compartilhar';

  @override
  String get deleteCommentTitle => 'Excluir comentário?';

  @override
  String get deleteCommentBody =>
      'O comentário e as respostas são excluídos definitivamente.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '1 curtida',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentários',
      one: '1 comentário',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Responder';

  @override
  String get report => 'Denunciar';

  @override
  String get unlike => 'Descurtir';

  @override
  String get likeComment => 'Curtir comentário';

  @override
  String get cantComment =>
      'Você não pode comentar nesta publicação agora. Pode reagir com um emoji.';

  @override
  String get tooManyMedia => 'Uma publicação pode ter até 10 fotos ou vídeos.';

  @override
  String get cantOpenFile =>
      'Não foi possível abrir o arquivo. Tente outra foto ou vídeo.';

  @override
  String get preparingPhotos => 'Preparando fotos…';

  @override
  String get photosFailed => 'Não foi possível preparar as fotos. Tente outra.';

  @override
  String uploading(int done, int total) {
    return 'Enviando: $done/$total';
  }

  @override
  String get sharing => 'Compartilhando…';

  @override
  String get postShared => 'Sua publicação foi compartilhada.';

  @override
  String get newPost => 'Nova publicação';

  @override
  String get memoryNotice =>
      'Esta publicação também aparecerá nas lembranças do evento. Compartilhe só suas fotos e pessoas que deram permissão.';

  @override
  String get pickMediaHint =>
      'Escolha até 10 fotos ou vídeos para compartilhar.';

  @override
  String get pickFromGallery => 'Escolher da galeria';

  @override
  String get cropHint =>
      'Faça pinça para ampliar e arraste para enquadrar. A proporção vale para todas as fotos.';

  @override
  String get caption => 'Legenda';

  @override
  String get captionHint =>
      'Escreva algo… Você pode adicionar #hashtags e @usuários.';

  @override
  String get postAs => 'Publicar como';

  @override
  String get myProfile => 'Meu perfil';

  @override
  String groupOption(String name) {
    return '$name (grupo)';
  }

  @override
  String get turnOffComments => 'Desativar comentários';

  @override
  String get hideLikes => 'Ocultar curtidas';

  @override
  String get onlyYouSee => 'Só você vê o número.';

  @override
  String mediaN(int n) {
    return 'Mídia $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Remover';

  @override
  String get cantShare => 'Não pode ser compartilhado';

  @override
  String get addMedia => 'Adicionar mídia';

  @override
  String get editPost => 'Editar publicação';

  @override
  String get save => 'Salvar';

  @override
  String get noEditPermission =>
      'Você não tem permissão para editar esta publicação.';

  @override
  String get photoToCrop => 'Foto para cortar';

  @override
  String get stories => 'Stories';

  @override
  String get feed => 'Feed';

  @override
  String get feedHint => 'Dos seus grupos e de quem você segue';

  @override
  String get feedEmpty =>
      'Seu feed está vazio. Publicações de pessoas e grupos que você segue aparecem aqui.';

  @override
  String get explore => 'Explorar';

  @override
  String get searchHint => 'Pesquisar pessoas ou #hashtags';

  @override
  String get clear => 'Limpar';

  @override
  String get exploreEmpty => 'Nada novo para explorar. Volte daqui a pouco.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get accounts => 'Contas';

  @override
  String get hashtags => 'Hashtags';

  @override
  String noTagMatch(String query) {
    return 'Nenhuma hashtag começa com \"$query\".';
  }

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações',
      one: '1 publicação',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Não há publicações visíveis com #$tag.';
  }

  @override
  String get backToExplore => 'Voltar para Explorar';

  @override
  String get saved => 'Salvos';

  @override
  String get savedEmpty =>
      'As publicações salvas aparecem aqui e só você as vê.';

  @override
  String get post => 'Publicação';

  @override
  String get postGone =>
      'Esta publicação foi excluída ou você não tem permissão para vê-la.';

  @override
  String get backToFeed => 'Voltar ao feed';

  @override
  String get unmute => 'Ativar som';

  @override
  String get mute => 'Silenciar';

  @override
  String get addedToSaved => 'Adicionado aos salvos.';

  @override
  String get linkCopied => 'Link da publicação copiado.';

  @override
  String get deletePostTitle => 'Excluir publicação?';

  @override
  String get deletePostBody =>
      'A publicação é excluída definitivamente com fotos, vídeos e comentários.';

  @override
  String get postDeleted => 'Publicação excluída.';

  @override
  String get likesHidden => 'Só você vê o número de curtidas.';

  @override
  String memoryOf(String title) {
    return 'Lembrança · $title';
  }

  @override
  String get deletedAccount => 'Conta excluída';

  @override
  String get groupPost => 'Publicação do grupo';

  @override
  String get edited => 'editado';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get edit => 'Editar';

  @override
  String get like => 'Curtir';

  @override
  String get commentAction => 'Comentar';

  @override
  String get unsave => 'Remover dos salvos';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Reação $emoji, $count';
  }

  @override
  String get more => 'mais';

  @override
  String postWithCaption(String caption) {
    return 'Publicação: $caption';
  }

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get addStory => 'Adicionar story';

  @override
  String get yourStory => 'Seu story';

  @override
  String get noStoriesLeft => 'Não há mais stories para você aqui.';

  @override
  String get close => 'Fechar';

  @override
  String get removeFromHighlight => 'Remover do destaque';

  @override
  String get removedFromHighlight => 'Removido do destaque.';

  @override
  String get addToHighlights => 'Adicionar aos destaques';

  @override
  String get deleteStory => 'Excluir story';

  @override
  String get storyDeleted => 'Story excluído.';

  @override
  String get options => 'Opções';

  @override
  String get viewers => 'Visualizações';

  @override
  String get noViewers =>
      'Ninguém viu ainda. As visualizações aparecem aqui e só você as vê.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto por $count pessoas',
      one: 'Visto por 1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'Não foi possível preparar a foto. Tente outra.';

  @override
  String get storyShared =>
      'Seu story foi compartilhado. Fica visível por 24 horas.';

  @override
  String get newStory => 'Novo story';

  @override
  String get addToStory => 'Adicionar ao seu story';

  @override
  String get storyPickHint =>
      'Escolha uma foto ou um vídeo de até 60 segundos para seu story.';

  @override
  String get pickAnother => 'Escolher outra';

  @override
  String get newHighlight => 'Novo destaque';

  @override
  String highlightCreated(String title) {
    return '\"$title\" criado.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Adicionado a \"$title\".';
  }

  @override
  String get highlightTitle => 'Título do destaque';

  @override
  String get highlightExample => 'Ex.: Camping 2026';

  @override
  String get addHighlight => 'Adicionar destaque';

  @override
  String get renameHighlight => 'Renomear';

  @override
  String get deleteHighlight => 'Excluir destaque';

  @override
  String get staysInArchive => 'Os stories continuam no seu arquivo.';

  @override
  String get storyArchive => 'Arquivo de stories';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories selecionados',
      one: '1 story selecionado',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Destacar';

  @override
  String get archiveEmpty =>
      'Os stories que você compartilha ficam aqui depois de 24 horas, visíveis só para você.';

  @override
  String get shareStory => 'Compartilhar um story';

  @override
  String get archiveHint =>
      'Selecione stories para criar um destaque ou adicionar a um.';

  @override
  String storyOn(String date) {
    return 'Story, $date';
  }

  @override
  String get live => 'No ar';
}
