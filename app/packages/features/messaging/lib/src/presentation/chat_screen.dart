import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/messaging.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Opens a page another feature owns (a profile by username, a group by handle).
typedef OpenPage = void Function(BuildContext context, String key);

/// A direct conversation or a group chat; opening it marks it read.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.onOpenProfile,
    required this.onOpenGroup,
    this.pickImage,
  });

  final String conversationId;
  final OpenPage onOpenProfile;
  final OpenPage onOpenGroup;
  final PickImage? pickImage;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _composerFocus = FocusNode();

  @override
  void dispose() {
    _composerFocus.dispose();
    super.dispose();
  }

  void _markRead(ChatThread thread) {
    final c = thread.conversation;
    // A request stays unread until it is accepted.
    if (c.unread > 0 && !c.isRequest) ref.read(messagingRepositoryProvider).markRead(c.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatProvider(widget.conversationId);
    ref.listen(provider, (_, next) {
      if (next case AsyncData(:final value)) _markRead(value);
    });
    final chat = ref.watch(provider);
    final conversation = chat.value?.conversation;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: conversation == null ? null : _Title(conversation: conversation, onOpen: () => _openHeader(conversation)),
        actions: [
          if (conversation != null && conversation.canManage)
            _ChatSettings(conversation: conversation, onChanged: () => ref.invalidate(provider)),
        ],
      ),
      body: switch (chat) {
        AsyncData(:final value) => _Chat(thread: value, composerFocus: _composerFocus, pickImage: widget.pickImage),
        AsyncError(error: NotFoundFailure()) => GxEmptyState(
            icon: Icons.forum_outlined,
            message: 'Bu sohbet bulunamadı ya da artık göremiyorsun.',
            actionLabel: 'Mesajlara dön',
            onAction: () => context.go(MessagingRoutes.list),
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(provider)),
        _ => const _Skeleton(),
      },
    );
  }

  void _openHeader(Conversation c) {
    if (c.group case final group?) {
      widget.onOpenGroup(context, group.handle);
    } else if (c.peer case final peer?) {
      widget.onOpenProfile(context, peer.username);
    }
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.conversation, required this.onOpen});

  final Conversation conversation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = conversation;
    final subtitle = switch (c) {
      Conversation(kind: ConversationKind.group, adminsOnly: true) => 'Grup sohbeti · yalnızca yöneticiler yazar',
      Conversation(kind: ConversationKind.group) => 'Grup sohbeti',
      Conversation(:final peer?) => '@${peer.username}',
      _ => '',
    };
    return InkWell(
      onTap: onOpen,
      borderRadius: GxRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
        child: Row(
          children: [
            ConversationAvatar(conversation: c, size: GxAvatarSize.sm),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.title, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group managers switch the chat to admins-only.
class _ChatSettings extends ConsumerWidget {
  const _ChatSettings({required this.conversation, required this.onChanged});

  final Conversation conversation;
  final VoidCallback onChanged;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final adminsOnly = !conversation.adminsOnly;
    final result = await ref.read(messagingRepositoryProvider).setAdminsOnly(conversation.group!.id, adminsOnly: adminsOnly);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() when adminsOnly => 'Artık bu sohbete yalnızca grup sahibi ve yöneticiler yazabilir.',
        Ok() => 'Artık grubun tüm üyeleri bu sohbete yazabilir.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<void>(
        tooltip: 'Sohbet ayarları',
        icon: const Icon(Icons.more_vert),
        itemBuilder: (_) => [
          CheckedPopupMenuItem(
            checked: conversation.adminsOnly,
            onTap: () => _toggle(context, ref),
            child: const Text('Yalnızca yöneticiler yazsın'),
          ),
        ],
      );
}

class _Chat extends ConsumerWidget {
  const _Chat({required this.thread, required this.composerFocus, required this.pickImage});

  final ChatThread thread;
  final FocusNode composerFocus;
  final PickImage? pickImage;

  /// The package that unlocks writing here, if a package is what keeps the user from it.
  static String? _packageFor(String? blocker) => switch (blocker) {
        'match_chat_locked' => 'matching_chat',
        'teammate_chat_locked' => 'matching_teammates',
        _ => null,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final c = thread.conversation;
    final messages = thread.messages;
    final group = c.kind == ConversationKind.group;
    // "Görüldü" under the newest of my messages the other person has read.
    final readAt = c.peer?.readAt;
    final seenId = readAt == null
        ? null
        : messages.where((m) => m.sender.id == me && !m.isDeleted && !m.createdAt.isAfter(readAt)).lastOrNull?.id;
    final lastMine = messages.where((m) => m.sender.id == me).lastOrNull?.id;

    return Column(
      children: [
        if (c.peer?.state == MemberState.request)
          const _Notice('Mesaj isteğin iletildi. Kabul edilene kadar okunup okunmadığını göremezsin.'),
        Expanded(
          child: messages.isEmpty
              ? GxEmptyState(
                  icon: Icons.waving_hand_outlined,
                  message: group ? 'Grup sohbetinde henüz mesaj yok. İlk mesajı sen yaz.' : 'Henüz mesaj yok. İlk mesajı sen yaz.',
                  actionLabel: 'Yazmaya başla',
                  onAction: composerFocus.requestFocus,
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final index = messages.length - 1 - i;
                    final m = messages[index];
                    final previous = index > 0 ? messages[index - 1] : null;
                    final newDay = previous == null || !DateUtils.isSameDay(previous.createdAt.toLocal(), m.createdAt.toLocal());
                    final mine = m.sender.id == me;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (newDay) _DayLabel(m.createdAt),
                            _Bubble(
                              message: m,
                              mine: mine,
                              showSender: group && !mine && (newDay || previous.sender.id != m.sender.id),
                              status: m.id == seenId
                                  ? 'Görüldü'
                                  : m.id == lastMine && !group && !m.isDeleted
                                      ? 'Gönderildi'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (c.isRequest)
          _RequestBar(conversation: c)
        else if (c.blockerText case final text?)
          _Notice(
            text,
            bottom: true,
            actionLabel: _packageFor(c.blocker) == null ? null : 'Paketi incele',
            onAction: () => ref.read(packageOpenerProvider)(context, _packageFor(c.blocker)!),
          )
        else
          _Composer(conversationId: c.id, focus: composerFocus, pickImage: pickImage),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.time);

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final label = switch (formatChatTime(time)) {
      final t when t.contains(':') => 'Bugün',
      final t => t,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GxSpacing.sm),
      child: Center(
        child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GxColors.textSecondary)),
      ),
    );
  }
}

class _Bubble extends ConsumerStatefulWidget {
  const _Bubble({required this.message, required this.mine, required this.showSender, this.status});

  final ChatMessage message;
  final bool mine;
  final bool showSender;

  /// "Görüldü" or "Gönderildi" under the user's latest message.
  final String? status;

  @override
  ConsumerState<_Bubble> createState() => _BubbleState();
}

/// Options open with a long press; with a mouse a "…" button appears on hover.
class _BubbleState extends ConsumerState<_Bubble> {
  bool _hovered = false;

  ChatMessage get message => widget.message;
  bool get mine => widget.mine;

  @override
  Widget build(BuildContext context) {
    final showSender = widget.showSender;
    final status = widget.status;
    final textTheme = Theme.of(context).textTheme;
    final m = message;
    final time = formatChatTime(m.createdAt);
    final clock = '${m.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${m.createdAt.toLocal().minute.toString().padLeft(2, '0')}';
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
      decoration: BoxDecoration(
        color: m.isDeleted ? GxColors.surfaceMuted : (mine ? GxColors.primarySoft : GxColors.background),
        borderRadius: GxRadius.lgAll,
        border: mine || m.isDeleted ? null : const Border.fromBorderSide(GxBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (m.isDeleted)
            Text(
              m.removed ? 'Bu mesaj kaldırıldı.' : 'Bu mesaj silindi.',
              style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary, fontStyle: FontStyle.italic),
            )
          else ...[
            if (m.imageUrl case final url?)
              Padding(
                padding: EdgeInsets.only(bottom: m.body.isEmpty ? 0 : GxSpacing.xs),
                child: _Photo(url: url),
              ),
            if (m.body.isNotEmpty) Text(m.body, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );

    final options = SizedBox.square(
      dimension: GxSpacing.minTouchTarget,
      child: _hovered && !m.isDeleted
          ? IconButton(
              tooltip: 'Mesaj seçenekleri',
              icon: const Icon(Icons.more_horiz, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
              onPressed: _actions,
            )
          : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.only(bottom: GxSpacing.xs),
          child: Row(
            mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (mine) options,
              Flexible(
                child: ConstrainedBox(
                  // Bubbles leave room on the other side, as in every messenger.
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
                  child: Column(
                    crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (showSender)
                        Padding(
                          padding: const EdgeInsets.only(left: GxSpacing.xs, bottom: GxSpacing.xxs),
                          child: Text(m.sender.displayName, style: textTheme.labelMedium?.copyWith(color: GxColors.primary)),
                        ),
                      Semantics(
                        label: '${mine ? 'Sen' : m.sender.displayName}, $time',
                        child: GestureDetector(
                          onLongPress: m.isDeleted ? null : _actions,
                          child: bubble,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs),
                        child: Text(
                          status == null ? clock : '$clock · $status',
                          style: textTheme.labelSmall?.copyWith(color: GxColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!mine) options,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _actions() async {
    final m = message;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.body.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Kopyala'),
                onTap: () async {
                  Navigator.of(sheet).pop();
                  await Clipboard.setData(ClipboardData(text: m.body));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj kopyalandı.')));
                  }
                },
              ),
            if (mine)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: GxColors.error),
                title: const Text('Herkesten sil', style: TextStyle(color: GxColors.error)),
                onTap: () {
                  Navigator.of(sheet).pop();
                  _delete();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Şikayet et'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  ref.read(reportLauncherProvider)(context, ReportTarget.message(m.id));
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: const Text('Mesaj herkesten silinsin mi?'),
        content: const Text('Mesaj sohbetteki herkes için "Bu mesaj silindi" olarak görünür. Bu işlem geri alınamaz.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GxButton(label: 'Sil', onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(messagingRepositoryProvider).delete(message.id);
    if (result case Err(:final failure) when mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  static const _maxSide = GxSpacing.xxl * 5;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Fotoğraf',
        button: true,
        child: GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialog) => Dialog.fullscreen(
              backgroundColor: GxColors.media,
              child: Stack(
                children: [
                  Positioned.fill(child: InteractiveViewer(maxScale: GxMedia.maxZoom, child: Image.network(url))),
                  SafeArea(
                    child: IconButton(
                      tooltip: 'Kapat',
                      color: GxColors.onMedia,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialog).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: GxRadius.mdAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxSide, maxHeight: _maxSide),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.square(
                  dimension: GxSpacing.xxl * 2,
                  child: ColoredBox(color: GxColors.surfaceMuted, child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          ),
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.bottom = false, this.actionLabel, this.onAction});

  final String text;
  final bool bottom;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: GxColors.surface,
          border: Border(top: bottom ? GxBorders.hairline : BorderSide.none, bottom: bottom ? BorderSide.none : GxBorders.hairline),
        ),
        child: SafeArea(
          top: false,
          bottom: bottom,
          child: Padding(
            padding: const EdgeInsets.all(GxSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
                const SizedBox(width: GxSpacing.xs),
                Expanded(
                  child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: GxSpacing.xs),
                  GxButton(label: actionLabel!, variant: GxButtonVariant.secondary, onPressed: onAction),
                ],
              ],
            ),
          ),
        ),
      );
}

/// Accept or decline a message request.
class _RequestBar extends ConsumerStatefulWidget {
  const _RequestBar({required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<_RequestBar> createState() => _RequestBarState();
}

class _RequestBarState extends ConsumerState<_RequestBar> {
  bool _busy = false;

  Future<void> _answer({required bool accept}) async {
    setState(() => _busy = true);
    final c = widget.conversation;
    final result = await ref.read(messagingRepositoryProvider).answerRequest(c.id, accept: accept);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok() when accept:
        ref.invalidate(chatProvider(c.id));
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesaj isteği silindi.')));
        context.pop();
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref.invalidate(conversationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.conversation.peer?.displayName ?? '';
    return DecoratedBox(
      decoration: const BoxDecoration(color: GxColors.background, border: Border(top: GxBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GxSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$name sana mesaj göndermek istiyor. Kabul edersen yazışabilirsiniz ve mesajları okuduğunu görebilir.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: GxSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GxButton(
                      label: 'Sil',
                      variant: GxButtonVariant.secondary,
                      onPressed: _busy ? null : () => _answer(accept: false),
                    ),
                  ),
                  const SizedBox(width: GxSpacing.sm),
                  Expanded(child: GxButton(label: 'Kabul et', isLoading: _busy, onPressed: () => _answer(accept: true))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.conversationId, required this.focus, required this.pickImage});

  final String conversationId;
  final FocusNode focus;
  final PickImage? pickImage;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _text = TextEditingController();
  ImageUpload? _image;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final image = await (widget.pickImage ?? () => pickGalleryImage(maxWidth: GxMedia.uploadMaxSide.toDouble()))();
    if (image != null && mounted) setState(() => _image = image);
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty && _image == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(messagingRepositoryProvider).send(widget.conversationId, body: body, image: _image);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (result case Err(:final failure)) {
        _error = failure.userMessage;
      } else {
        _text.clear();
        _image = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return DecoratedBox(
      decoration: const BoxDecoration(color: GxColors.background, border: Border(top: GxBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GxSpacing.sm),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.xs)],
                  if (image != null) ...[
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: GxRadius.mdAll,
                          child: Image.memory(image.bytes, width: GxSpacing.xxl * 1.5, height: GxSpacing.xxl * 1.5, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: GxSpacing.xs),
                        IconButton(
                          tooltip: 'Fotoğrafı kaldır',
                          icon: const Icon(Icons.close),
                          onPressed: _sending ? null : () => setState(() => _image = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: GxSpacing.xs),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Fotoğraf ekle',
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        onPressed: _sending ? null : _pick,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          focusNode: widget.focus,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: MessagingRules.bodyMax,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(hintText: 'Mesaj yaz', counterText: ''),
                        ),
                      ),
                      const SizedBox(width: GxSpacing.xs),
                      IconButton.filled(
                        tooltip: 'Gönder',
                        icon: _sending
                            ? const SizedBox.square(
                                dimension: GxSpacing.md,
                                child: CircularProgressIndicator(strokeWidth: 2, color: GxColors.onPrimary),
                              )
                            : const Icon(Icons.send),
                        onPressed: _sending ? null : _send,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(GxSpacing.md),
        children: [
          for (var i = 0; i < 6; i++)
            Align(
              alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(bottom: GxSpacing.sm),
                child: GxSkeleton(width: GxSpacing.xxl * 4, height: GxSpacing.xl + GxSpacing.xs, borderRadius: GxRadius.lgAll),
              ),
            ),
        ],
      );
}
