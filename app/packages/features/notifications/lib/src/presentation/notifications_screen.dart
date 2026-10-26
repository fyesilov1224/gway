import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification.dart';
import 'providers.dart';

/// Pages and actions owned by other features; the app supplies them.
class NotificationLinks {
  const NotificationLinks({
    required this.openProfile,
    required this.openPost,
    required this.openFollowRequests,
    required this.followButton,
    required this.openLive,
    required this.openEvent,
    required this.openGroupModeration,
    required this.openSanctions,
    required this.openGoal,
    required this.openTeammates,
  });

  final void Function(BuildContext context, String username) openProfile;

  /// [comments] opens the post's comments.
  final void Function(BuildContext context, String postId, {required bool comments}) openPost;
  final void Function(BuildContext context) openFollowRequests;

  /// "Takip et" / "Takiptesin" next to follow notifications.
  final Widget Function(BuildContext context, NotificationActor actor) followButton;

  /// A live room, for live_scheduled and live_started.
  final void Function(BuildContext context, String liveId) openLive;

  /// An event page, for the event_* types.
  final void Function(BuildContext context, String eventId) openEvent;

  /// A group's moderation desk, for case_vote and appeal_submitted.
  final void Function(BuildContext context, String groupHandle) openGroupModeration;

  /// The user's own sanctions, for sanction_applied and appeal_decided.
  final void Function(BuildContext context) openSanctions;

  /// A goal page, for goal_completed.
  final void Function(BuildContext context, String goalId) openGoal;

  /// Teammate requests and suggestions, for teammate_request.
  final void Function(BuildContext context) openTeammates;
}

/// Today / this week / earlier, with pending follow requests gathered on top (docs/ARCHITECTURE.md §3c).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, required this.links});

  final NotificationLinks links;

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _marked = false;

  /// Everything shown counts as read; the highlight stays until the screen closes.
  Future<void> _markRead() async {
    if (_marked) return;
    _marked = true;
    await ref.read(notificationsRepositoryProvider).markAllRead();
    ref.invalidate(unreadNotificationsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(notificationListProvider);
    if (page.hasValue) WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: GxReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async {
            _marked = false;
            ref.invalidate(notificationListProvider);
            await ref.read(notificationListProvider.future);
          },
          child: switch (page) {
            AsyncData(:final value) when value.items.isEmpty => ListView(children: [
                const SizedBox(height: GxSpacing.xxl),
                GxEmptyState(
                  icon: Icons.notifications_none_rounded,
                  message: 'Beğeniler, yorumlar ve yeni takipçiler burada görünür.',
                  actionLabel: 'Yenile',
                  onAction: () => ref.invalidate(notificationListProvider),
                ),
              ]),
            AsyncData(:final value) => NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 600) ref.read(notificationListProvider.notifier).loadMore();
                  return false;
                },
                child: ListView(
                  children: [
                    if (value.items.where((n) => n.type == NotificationType.followRequest).toList() case final requests
                        when requests.isNotEmpty)
                      _RequestsRow(requests: requests, onTap: () => widget.links.openFollowRequests(context)),
                    for (final (period, items) in groupByPeriod(
                        [for (final n in value.items) if (n.type != NotificationType.followRequest) n], now)) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
                        child: Text(period.label, style: textTheme.titleMedium),
                      ),
                      for (final n in items) _NotificationRow(notification: n, links: widget.links),
                    ],
                    if (value.loadingMore)
                      const Padding(padding: EdgeInsets.all(GxSpacing.md), child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            AsyncError(:final error) =>
              GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(notificationListProvider)),
            _ => const _Skeleton(),
          },
        ),
      ),
    );
  }
}

class _RequestsRow extends StatelessWidget {
  const _RequestsRow({required this.requests, required this.onTap});

  final List<AppNotification> requests;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = requests.first.actor;
    final others = requests.length - 1;
    return ListTile(
      onTap: onTap,
      leading: GxAvatar(name: first.displayName, shape: GxAvatarShape.user, imageUrl: first.avatarUrl, size: GxAvatarSize.md),
      title: Text('Takip istekleri', style: textTheme.labelLarge),
      subtitle: Text(others == 0 ? first.username : '${first.username} ve $others kişi daha'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification, required this.links});

  static final _thumb = GxAvatarSize.md.dimension + GxSpacing.xxs;

  final AppNotification notification;
  final NotificationLinks links;

  void _open(BuildContext context) {
    final n = notification;
    if (n.goalId != null) return links.openGoal(context, n.goalId!);
    if (n.type == NotificationType.teammateRequest) return links.openTeammates(context);
    if (n.type.fromGroup) return links.openSanctions(context);
    if (n.group != null) return links.openGroupModeration(context, n.group!.handle);
    if (n.liveId != null) return links.openLive(context, n.liveId!);
    if (n.eventId != null) return links.openEvent(context, n.eventId!);
    if (n.type.isFollow || n.postId == null) return links.openProfile(context, n.actor.username);
    links.openPost(context, n.postId!, comments: n.aboutComment);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final textTheme = Theme.of(context).textTheme;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: GxColors.errorSoft,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg),
        child: const Icon(Icons.delete_outline, color: GxColors.error, semanticLabel: 'Sil'),
      ),
      onDismissed: (_) async {
        final result = await ref.read(notificationListProvider.notifier).delete(n);
        if (result case Err(:final failure) when context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
        }
      },
      child: Material(
        color: n.read ? GxColors.background : GxColors.primarySoft,
        child: InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.xs),
            child: Row(
              children: [
                if (n.type.fromGroup)
                  GxAvatar(name: n.group?.name ?? '', shape: GxAvatarShape.group, imageUrl: n.group?.logoUrl, size: GxAvatarSize.md)
                else
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => links.openProfile(context, n.actor.username),
                    child: GxAvatar(name: n.actor.displayName, shape: GxAvatarShape.user, imageUrl: n.actor.avatarUrl, size: GxAvatarSize.md),
                  ),
                const SizedBox(width: GxSpacing.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${n.lead} ', style: textTheme.labelLarge),
                      TextSpan(text: n.action),
                      TextSpan(
                        text: '  ${_ago(n.createdAt)}',
                        style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
                      ),
                    ]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: GxSpacing.sm),
                if (n.type.isFollow)
                  links.followButton(context, n.actor)
                else if (n.postId != null)
                  ClipRRect(
                    borderRadius: GxRadius.smAll,
                    child: SizedBox.square(
                      dimension: _thumb,
                      child: n.thumbUrl == null
                          ? const ColoredBox(color: GxColors.media, child: Icon(Icons.play_arrow_rounded, color: GxColors.onMedia))
                          : Image.network(
                              n.thumbUrl!,
                              fit: BoxFit.cover,
                              cacheWidth: gxCacheWidth(_thumb, MediaQuery.devicePixelRatioOf(context)),
                              errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _ago(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'şimdi';
  if (diff.inHours < 1) return '${diff.inMinutes} dk';
  if (diff.inDays < 1) return '${diff.inHours} sa';
  if (diff.inDays < 7) return '${diff.inDays} g';
  return formatDateTr(time);
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(GxSpacing.md),
        children: [
          for (var i = 0; i < 6; i++) ...[
            const Row(children: [
              GxSkeleton.circle(size: GxSpacing.xxl - GxSpacing.xs),
              SizedBox(width: GxSpacing.sm),
              Expanded(child: GxSkeleton(height: GxSpacing.md)),
            ]),
            const SizedBox(height: GxSpacing.md),
          ],
        ],
      );
}

/// A navigation icon with the unread count.
class NotificationsIcon extends ConsumerWidget {
  const NotificationsIcon({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    final icon = Icon(selected ? Icons.notifications_rounded : Icons.notifications_none_rounded);
    if (unread == 0) return icon;
    return Badge(
      label: Text(unread > 99 ? '99+' : '$unread'),
      backgroundColor: GxColors.primary,
      textColor: GxColors.onPrimary,
      child: icon,
    );
  }
}
