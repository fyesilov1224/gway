import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/messaging.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';

/// `09:05` today, `Dün`, then `18 Ekim 2026`.
String formatChatTime(DateTime time, {DateTime? now}) {
  final t = time.toLocal();
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final day = DateUtils.dateOnly(t);
  if (day == today) return formatTime(t);
  if (day == today.subtract(const Duration(days: 1))) return messagingL10n.yesterday;
  return formatDate(t);
}

/// The messages icon with the number of conversations that have unread messages.
class MessagesButton extends ConsumerWidget {
  const MessagesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadConversationsProvider);
    const icon = Icon(Icons.chat_bubble_outline_rounded);
    return IconButton(
      tooltip: messagingL10n.messages,
      onPressed: () => context.push(MessagingRoutes.list),
      icon: unread == 0
          ? icon
          : Badge(
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: GwColors.primary,
              textColor: GwColors.onPrimary,
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
      tooltip: messagingL10n.sendMessage,
      onPressed: _busy ? null : _open,
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: GwSpacing.md + GwSpacing.xxs),
      style: IconButton.styleFrom(foregroundColor: GwColors.textPrimary, side: const BorderSide(color: GwColors.border)),
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
            .showSnackBar(SnackBar(content: Text(messagingL10n.groupChatMembersOnly)));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) => GwButton(
        label: messagingL10n.groupChat,
        icon: Icons.forum_outlined,
        variant: GwButtonVariant.secondary,
        isLoading: _busy,
        expand: true,
        onPressed: _open,
      );
}

/// A person's circle or a group's rounded square.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, required this.conversation, this.size = GwAvatarSize.md});

  final Conversation conversation;
  final GwAvatarSize size;

  @override
  Widget build(BuildContext context) => GwAvatar(
        name: conversation.title,
        imageUrl: conversation.avatarUrl,
        shape: conversation.kind == ConversationKind.direct ? GwAvatarShape.user : GwAvatarShape.group,
        size: size,
      );
}
