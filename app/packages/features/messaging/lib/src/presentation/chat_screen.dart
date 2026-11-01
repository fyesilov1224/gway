import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/calls.dart';
import '../domain/messaging.dart';
import 'call_providers.dart';
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
          if (conversation != null && conversation.kind == ConversationKind.direct) _CallButton(conversationId: conversation.id),
          if (conversation != null && conversation.canManage)
            _ChatSettings(conversation: conversation, onChanged: () => ref.invalidate(provider)),
        ],
      ),
      body: switch (chat) {
        AsyncData(:final value) => _Chat(
            thread: value,
            composerFocus: _composerFocus,
            pickImage: widget.pickImage,
            onOpenProfile: (username) => widget.onOpenProfile(context, username),
          ),
        AsyncError(error: NotFoundFailure()) => GwEmptyState(
            icon: Icons.forum_outlined,
            message: 'Bu sohbet bulunamadı ya da artık göremiyorsun.',
            actionLabel: 'Mesajlara dön',
            onAction: () => context.go(MessagingRoutes.list),
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(provider)),
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

/// Calls the other person of a match chat (docs/ARCHITECTURE.md §8c). Hidden where calls never apply;
/// otherwise a tap either calls or says why it cannot.
class _CallButton extends ConsumerStatefulWidget {
  const _CallButton({required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends ConsumerState<_CallButton> {
  bool _starting = false;

  Future<void> _start() async {
    setState(() => _starting = true);
    final result = await ref.read(callsRepositoryProvider).start(widget.conversationId);
    if (!mounted) return;
    setState(() => _starting = false);
    switch (result) {
      case Ok(:final value):
        await context.push(MessagingRoutes.call(value.callId), extra: value);
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    if (mounted) ref.invalidate(callEligibilityProvider(widget.conversationId));
  }

  void _explain(CallEligibility eligibility) {
    final ownPermission = eligibility.code == 'call.no_permission';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(eligibility.message ?? 'Şu anda arama yapılamıyor.'),
      action: ownPermission
          ? SnackBarAction(label: 'Talep et', onPressed: () => context.push(MessagingRoutes.callSettings))
          : null,
    ));
  }

  @override
  Widget build(BuildContext context) => switch (ref.watch(callEligibilityProvider(widget.conversationId))) {
        AsyncData(:final value) when !value.hidden => IconButton(
            tooltip: 'Sesli ara',
            icon: Icon(Icons.call_outlined, color: value.allowed ? null : GwColors.textSecondary),
            onPressed: _starting ? null : () => value.allowed ? _start() : _explain(value),
          ),
        _ => const SizedBox.shrink(),
      };
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
      Conversation(kind: ConversationKind.table) => 'Küçük masa · ${c.tableMembers} kişi',
      Conversation(:final peer?) => '@${peer.username}',
      _ => '',
    };
    return InkWell(
      onTap: onOpen,
      borderRadius: GwRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
        child: Row(
          children: [
            ConversationAvatar(conversation: c, size: GwAvatarSize.sm),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.title, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary),
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
  const _Chat({required this.thread, required this.composerFocus, required this.pickImage, required this.onOpenProfile});

  final ChatThread thread;
  final FocusNode composerFocus;
  final PickImage? pickImage;
  final ValueChanged<String> onOpenProfile;

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
    // Several people write: names above their messages.
    final group = c.kind != ConversationKind.direct;
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
              ? GwEmptyState(
                  icon: Icons.waving_hand_outlined,
                  message: group ? 'Grup sohbetinde henüz mesaj yok. İlk mesajı sen yaz.' : 'Henüz mesaj yok. İlk mesajı sen yaz.',
                  actionLabel: 'Yazmaya başla',
                  onAction: composerFocus.requestFocus,
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final index = messages.length - 1 - i;
                    final m = messages[index];
                    final previous = index > 0 ? messages[index - 1] : null;
                    final next = index < messages.length - 1 ? messages[index + 1] : null;
                    final newDay = previous == null || !DateUtils.isSameDay(previous.createdAt.toLocal(), m.createdAt.toLocal());
                    final mine = m.sender.id == me;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (newDay) _DayLabel(m.createdAt),
                            _Bubble(
                              message: m,
                              mine: mine,
                              showSender: group && !mine && (newDay || previous.sender.id != m.sender.id),
                              // As in Instagram: the sender's photo beside the last message of their run.
                              showAvatar: !mine &&
                                  (next == null ||
                                      next.sender.id != m.sender.id ||
                                      !DateUtils.isSameDay(next.createdAt.toLocal(), m.createdAt.toLocal())),
                              onOpenSender: m.sender.isHidden ? null : () => onOpenProfile(m.sender.username),
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
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.sm),
      child: Center(
        child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: GwColors.textSecondary)),
      ),
    );
  }
}

class _Bubble extends ConsumerStatefulWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.showSender,
    required this.showAvatar,
    required this.onOpenSender,
    this.status,
  });

  final ChatMessage message;
  final bool mine;
  final bool showSender;

  /// The sender's photo beside the bubble; others' messages without it keep its room so the bubbles line up.
  final bool showAvatar;
  /// Null for a sender whose profile is hidden.
  final VoidCallback? onOpenSender;

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
    // The avatar and the gap after it.
    final avatarRoom = GwAvatarSize.sm.dimension + GwSpacing.xs;
    final clock = '${m.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${m.createdAt.toLocal().minute.toString().padLeft(2, '0')}';
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
      decoration: BoxDecoration(
        color: m.isDeleted ? GwColors.surfaceMuted : (mine ? GwColors.primarySoft : GwColors.background),
        borderRadius: GwRadius.lgAll,
        border: mine || m.isDeleted ? null : const Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (m.isDeleted)
            Text(
              m.removed ? 'Bu mesaj kaldırıldı.' : 'Bu mesaj silindi.',
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary, fontStyle: FontStyle.italic),
            )
          else ...[
            if (m.imageUrl case final url?)
              Padding(
                padding: EdgeInsets.only(bottom: m.body.isEmpty ? 0 : GwSpacing.xs),
                child: _Photo(url: url),
              ),
            if (m.body.isNotEmpty) Text(m.body, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );

    final options = SizedBox.square(
      dimension: GwSpacing.minTouchTarget,
      child: _hovered && !m.isDeleted
          ? IconButton(
              tooltip: 'Mesaj seçenekleri',
              icon: const Icon(Icons.more_horiz, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
              onPressed: _actions,
            )
          : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.xs),
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
                          padding: EdgeInsets.only(left: avatarRoom + GwSpacing.xs, bottom: GwSpacing.xxs),
                          child: Text(m.sender.displayName, style: textTheme.labelMedium?.copyWith(color: GwColors.primary)),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!mine)
                            SizedBox(
                              width: avatarRoom,
                              child: widget.showAvatar
                                  ? Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Semantics(
                                        button: true,
                                        label: '${m.sender.displayName} profili',
                                        child: GestureDetector(
                                          onTap: widget.onOpenSender,
                                          child: GwAvatar(
                                            name: m.sender.displayName,
                                            imageUrl: m.sender.avatarUrl,
                                            shape: GwAvatarShape.user,
                                            size: GwAvatarSize.sm,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          Flexible(
                            child: Semantics(
                              label: '${mine ? 'Sen' : m.sender.displayName}, $time',
                              child: GestureDetector(
                                onLongPress: m.isDeleted ? null : _actions,
                                child: bubble,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: (mine ? 0 : avatarRoom) + GwSpacing.xs,
                          right: GwSpacing.xs,
                          top: GwSpacing.xxs,
                          bottom: GwSpacing.xxs,
                        ),
                        child: Text(
                          status == null ? clock : '$clock · $status',
                          style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary),
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
                leading: const Icon(Icons.delete_outline, color: GwColors.error),
                title: const Text('Herkesten sil', style: TextStyle(color: GwColors.error)),
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
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: const Text('Mesaj herkesten silinsin mi?'),
        content: const Text('Mesaj sohbetteki herkes için "Bu mesaj silindi" olarak görünür. Bu işlem geri alınamaz.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GwButton(label: 'Sil', onPressed: () => Navigator.of(dialog).pop(true)),
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

  static const _maxSide = GwSpacing.xxl * 5;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Fotoğraf',
        button: true,
        child: GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialog) => Dialog.fullscreen(
              backgroundColor: GwColors.media,
              child: Stack(
                children: [
                  Positioned.fill(child: InteractiveViewer(maxScale: GwMedia.maxZoom, child: Image.network(url))),
                  SafeArea(
                    child: IconButton(
                      tooltip: 'Kapat',
                      color: GwColors.onMedia,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialog).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: GwRadius.mdAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxSide, maxHeight: _maxSide),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.square(
                  dimension: GwSpacing.xxl * 2,
                  child: ColoredBox(color: GwColors.surfaceMuted, child: Icon(Icons.broken_image_outlined)),
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
          color: GwColors.surface,
          border: Border(top: bottom ? GwBorders.hairline : BorderSide.none, bottom: bottom ? BorderSide.none : GwBorders.hairline),
        ),
        child: SafeArea(
          top: false,
          bottom: bottom,
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
                const SizedBox(width: GwSpacing.xs),
                Expanded(
                  child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: GwSpacing.xs),
                  GwButton(label: actionLabel!, variant: GwButtonVariant.secondary, onPressed: onAction),
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
      decoration: const BoxDecoration(color: GwColors.background, border: Border(top: GwBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$name sana mesaj göndermek istiyor. Kabul edersen yazışabilirsiniz ve mesajları okuduğunu görebilir.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: GwSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GwButton(
                      label: 'Sil',
                      variant: GwButtonVariant.secondary,
                      onPressed: _busy ? null : () => _answer(accept: false),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  Expanded(child: GwButton(label: 'Kabul et', isLoading: _busy, onPressed: () => _answer(accept: true))),
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
    final image = await (widget.pickImage ?? () => pickGalleryImage(maxWidth: GwMedia.uploadMaxSide.toDouble()))();
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
      decoration: const BoxDecoration(color: GwColors.background, border: Border(top: GwBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.sm),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.xs)],
                  if (image != null) ...[
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: GwRadius.mdAll,
                          child: Image.memory(image.bytes, width: GwSpacing.xxl * 1.5, height: GwSpacing.xxl * 1.5, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: GwSpacing.xs),
                        IconButton(
                          tooltip: 'Fotoğrafı kaldır',
                          icon: const Icon(Icons.close),
                          onPressed: _sending ? null : () => setState(() => _image = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: GwSpacing.xs),
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
                      const SizedBox(width: GwSpacing.xs),
                      IconButton.filled(
                        tooltip: 'Gönder',
                        icon: _sending
                            ? const SizedBox.square(
                                dimension: GwSpacing.md,
                                child: CircularProgressIndicator(strokeWidth: 2, color: GwColors.onPrimary),
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
        padding: const EdgeInsets.all(GwSpacing.md),
        children: [
          for (var i = 0; i < 6; i++)
            Align(
              alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(bottom: GwSpacing.sm),
                child: GwSkeleton(width: GwSpacing.xxl * 4, height: GwSpacing.xl + GwSpacing.xs, borderRadius: GwRadius.lgAll),
              ),
            ),
        ],
      );
}
