import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/messaging.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Conversations and "Mesaj istekleri" (docs/ARCHITECTURE.md §3f).
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key, required this.onFindPeople});

  /// The empty list's action: where to find someone to write to.
  final void Function(BuildContext context) onFindPeople;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final requests = conversations.value?.where((c) => c.isRequest).length ?? 0;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mesajlar'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Sohbetler'),
              Tab(text: requests == 0 ? 'İstekler' : 'İstekler ($requests)'),
            ],
          ),
        ),
        body: GxReadingColumn(
          child: switch (conversations) {
            AsyncData(:final value) => TabBarView(
                children: [
                  _List(
                    items: [for (final c in value) if (!c.isRequest) c],
                    empty: GxEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      message: 'Henüz bir sohbetin yok. Ekip arkadaşlarına ya da takipleştiğin kişilere yazabilirsin.',
                      actionLabel: 'Kişi bul',
                      onAction: () => onFindPeople(context),
                    ),
                  ),
                  _List(
                    items: [for (final c in value) if (c.isRequest) c],
                    header: 'Takipleşmediğin kişilerin mesajları burada bekler. Kabul edersen sohbetlerine taşınır.',
                    empty: Builder(
                      builder: (context) => GxEmptyState(
                        icon: Icons.mark_email_unread_outlined,
                        message: 'Bekleyen mesaj isteğin yok.',
                        actionLabel: 'Sohbetlere dön',
                        onAction: () => DefaultTabController.of(context).animateTo(0),
                      ),
                    ),
                  ),
                ],
              ),
            AsyncError(:final error) => GxErrorState(
                message: userMessageOf(error),
                onRetry: () => ref.invalidate(conversationsProvider),
              ),
            _ => const _Skeleton(),
          },
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.items, required this.empty, this.header});

  final List<Conversation> items;
  final Widget empty;
  final String? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return empty;
    final me = ref.watch(currentUserIdProvider);
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(conversationsProvider.future),
      child: ListView(
        children: [
          if (header case final text?)
            Padding(
              padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
              child: Text(text, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
            ),
          for (final c in items) _Tile(conversation: c, mine: c.lastMessage?.senderId == me),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.conversation, required this.mine});

  final Conversation conversation;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = conversation;
    final last = c.lastMessage;
    final unread = c.unread > 0;
    return ListTile(
      minTileHeight: GxSpacing.xxl + GxSpacing.md,
      contentPadding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
      leading: ConversationAvatar(conversation: c),
      title: Text(
        c.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleSmall?.copyWith(fontWeight: unread ? FontWeight.w700 : null),
      ),
      subtitle: last == null
          ? null
          : Text(
              '${mine ? 'Sen: ' : ''}${last.preview}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: unread ? GxColors.textPrimary : GxColors.textSecondary,
                fontStyle: last.deleted ? FontStyle.italic : null,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (last != null)
            Text(formatChatTime(last.createdAt), style: textTheme.labelSmall?.copyWith(color: GxColors.textSecondary)),
          if (unread) ...[
            const SizedBox(height: GxSpacing.xxs),
            Badge(
              label: Text(c.unread > 99 ? '99+' : '${c.unread}'),
              backgroundColor: GxColors.primary,
              textColor: GxColors.onPrimary,
            ),
          ],
        ],
      ),
      onTap: () => context.push(MessagingRoutes.chat(c.id)),
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
            Padding(
              padding: const EdgeInsets.only(bottom: GxSpacing.md),
              child: Row(
                children: [
                  GxSkeleton.circle(size: GxAvatarSize.md.dimension),
                  const SizedBox(width: GxSpacing.sm),
                  const Expanded(child: GxSkeleton(height: GxSpacing.xl)),
                ],
              ),
            ),
        ],
      );
}
