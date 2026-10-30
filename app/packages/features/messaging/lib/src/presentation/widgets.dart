import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/messaging.dart';
import 'providers.dart';
import 'routes.dart';

/// `09:05` today, `Dün`, then `18 Ekim 2026`.
String formatChatTime(DateTime time, {DateTime? now}) {
  final t = time.toLocal();
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final day = DateUtils.dateOnly(t);
  if (day == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  if (day == today.subtract(const Duration(days: 1))) return 'Dün';
  return formatDateTr(t);
}

/// The messages icon with the number of conversations that have unread messages.
class MessagesButton extends ConsumerWidget {
  const MessagesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadConversationsProvider);
    const icon = Icon(Icons.chat_bubble_outline_rounded);
    return IconButton(
      tooltip: 'Mesajlar',
      onPressed: () => context.push(MessagingRoutes.list),
      icon: unread == 0
          ? icon
          : Badge(
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: GxColors.primary,
              textColor: GxColors.onPrimary,
              child: icon,
            ),
    );
  }
}

/// The message icon next to "Takip et" on another person's profile: opens (or starts) the direct conversation.
/// Shown only to matches, teammates and people who already have a conversation (docs/ARCHITECTURE.md §3f).
class MessageUserButton extends ConsumerStatefulWidget {
  const MessageUserButton({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<MessageUserButton> createState() => _MessageUserButtonState();
}

class _MessageUserButtonState extends ConsumerState<MessageUserButton> {
  bool _busy = false;

  Future<void> _open() async {
    setState(() => _busy = true);
    final result = await ref.read(messagingRepositoryProvider).openDirect(widget.userId);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        await context.push(MessagingRoutes.chat(value.id));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(ref.watch(canMessageProvider(widget.userId)).value ?? false)) return const SizedBox.shrink();
    return IconButton.outlined(
      tooltip: 'Mesaj gönder',
      onPressed: _busy ? null : _open,
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: GxSpacing.md + GxSpacing.xxs),
      style: IconButton.styleFrom(foregroundColor: GxColors.textPrimary, side: const BorderSide(color: GxColors.border)),
    );
  }
}

/// "Grup sohbeti" on the group page, for members.
class GroupChatButton extends ConsumerStatefulWidget {
  const GroupChatButton({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupChatButton> createState() => _GroupChatButtonState();
}

class _GroupChatButtonState extends ConsumerState<GroupChatButton> {
  bool _busy = false;

  Future<void> _open() async {
    setState(() => _busy = true);
    final result = await ref.read(messagingRepositoryProvider).groupConversation(widget.groupId);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(value: final id?):
        await context.push(MessagingRoutes.chat(id));
      case Ok():
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Grup sohbetini yalnızca grubun üyeleri görebilir.')));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) => GxButton(
        label: 'Grup sohbeti',
        icon: Icons.forum_outlined,
        variant: GxButtonVariant.secondary,
        isLoading: _busy,
        expand: true,
        onPressed: _open,
      );
}

/// A person's circle or a group's rounded square.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, required this.conversation, this.size = GxAvatarSize.md});

  final Conversation conversation;
  final GxAvatarSize size;

  @override
  Widget build(BuildContext context) => GxAvatar(
        name: conversation.title,
        imageUrl: conversation.avatarUrl,
        shape: conversation.kind == ConversationKind.direct ? GxAvatarShape.user : GxAvatarShape.group,
        size: size,
      );
}
