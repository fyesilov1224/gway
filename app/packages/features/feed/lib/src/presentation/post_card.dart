import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/post.dart';
import '../l10n.dart';
import 'media.dart';
import 'providers.dart';
import 'rich_text.dart';
import 'routes.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

/// Likes or unlikes right away and rolls back if the server refuses.
Future<void> toggleLike(BuildContext context, WidgetRef ref, Post post, {bool onlyLike = false}) async {
  if (onlyLike && post.liked) return;
  final liked = !post.liked;
  final edits = ref.read(postEditsProvider.notifier);
  final count = post.likeCount;
  edits.put(post.copyWith(liked: liked, likeCount: count == null ? null : count + (liked ? 1 : -1)));
  final result = await ref.read(feedRepositoryProvider).setLiked(post.id, liked);
  if (result case Err(:final failure)) {
    edits.put(post);
    if (context.mounted) _snack(context, failure.userMessage);
  }
}

/// Sets, changes or (tapping the same one) removes the viewer's emoji right away; rolls back if refused.
Future<void> toggleReaction(BuildContext context, WidgetRef ref, Post post, String emoji) async {
  final next = post.myReaction == emoji ? null : emoji;
  final counts = {...post.reactions};
  if (post.myReaction case final old?) counts.update(old, (n) => n - 1);
  if (next != null) counts.update(next, (n) => n + 1, ifAbsent: () => 1);
  counts.removeWhere((_, n) => n <= 0);
  final edits = ref.read(postEditsProvider.notifier)..put(post.copyWith(reactions: counts, myReaction: () => next));
  final result = await ref.read(feedRepositoryProvider).setReaction(post.id, next);
  if (result case Err(:final failure)) {
    edits.put(post);
    if (context.mounted) _snack(context, failure.userMessage);
  }
}

Future<void> toggleSave(BuildContext context, WidgetRef ref, Post post) async {
  final saved = !post.saved;
  final edits = ref.read(postEditsProvider.notifier)..put(post.copyWith(saved: saved));
  final result = await ref.read(feedRepositoryProvider).setSaved(post.id, saved);
  if (!context.mounted) return;
  switch (result) {
    case Err(:final failure):
      edits.put(post);
      _snack(context, failure.userMessage);
    case Ok():
      ref.invalidate(postListProvider(const SavedPosts()));
      if (saved) _snack(context, feedL10n.addedToSaved);
  }
}

Future<void> copyPostLink(BuildContext context, Post post) async {
  await Clipboard.setData(ClipboardData(text: FeedRoutes.shareLink(post.id)));
  if (context.mounted) _snack(context, feedL10n.linkCopied);
}

/// Asks first; returns true when the post was deleted.
Future<bool> deletePost(BuildContext context, WidgetRef ref, Post post) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: Text(feedL10n.deletePostTitle),
      content: Text(feedL10n.deletePostBody),
      actions: [
        GwButton(label: feedL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
        GwButton(label: feedL10n.delete, onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  final result = await ref.read(feedRepositoryProvider).delete(post.id);
  if (!context.mounted) return false;
  switch (result) {
    case Ok():
      ref.read(postEditsProvider.notifier).deleted(post.id);
      ref.read(postsChangedProvider.notifier).bump();
      _snack(context, feedL10n.postDeleted);
      return true;
    case Err(:final failure):
      _snack(context, failure.userMessage);
      return false;
  }
}

/// A post as shown in the feed and on its own page.
class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, this.onDeleted, this.showAllComments = true});

  final Post post;

  /// Called after the post was deleted from this card (e.g. to leave its page).
  final VoidCallback? onDeleted;

  /// Off on the comments page itself.
  final bool showAllComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = watchPost(ref, post);
    if (current == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final links = ref.read(feedLinksProvider);
    void openOwner() => switch (current.group) {
          final g? => links.openGroup(context, g.handle),
          null => current.author == null ? null : links.openProfile(context, current.author!.username),
        };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
      child: GwCard(
        radius: GwRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(post: current, onOpenOwner: openOwner, onDeleted: onDeleted),
            if (current.media.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
                child: ClipRRect(
                  borderRadius: GwRadius.mdAll,
                  child: MediaCarousel(media: current.media, onDoubleTap: () => toggleLike(context, ref, current, onlyLike: true)),
                ),
              ),
            _Actions(post: current, showComments: showAllComments),
            PostReactions(post: current),
            if (current.caption.isNotEmpty || current.event != null || (current.hideLikeCount && current.canManage))
              Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (current.hideLikeCount && current.canManage)
                      Text(feedL10n.likesHidden, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                    if (current.caption.isNotEmpty) _Caption(post: current, onOpenOwner: openOwner),
                    if (current.event case final event?)
                      Padding(
                        padding: const EdgeInsets.only(top: GwSpacing.xs),
                        child: InkWell(
                          borderRadius: GwRadius.xlAll,
                          onTap: links.openEvent == null ? null : () => links.openEvent!(context, event.id),
                          child: GwTag(label: feedL10n.memoryOf(event.title), icon: Icons.event_outlined),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.post, required this.onOpenOwner, this.onDeleted});

  final Post post;
  final VoidCallback onOpenOwner;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final group = post.group;
    final author = post.author;
    final name = group?.name ?? author?.displayName ?? feedL10n.deletedAccount;
    final meta = [
      if (author != null) '@${author.username}' else if (group != null) feedL10n.groupPost,
      formatAgo(post.createdAt),
      if (post.editedAt != null) feedL10n.edited,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.sm, GwSpacing.sm, GwSpacing.xxs, GwSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpenOwner,
              borderRadius: GwRadius.mdAll,
              child: Row(
                children: [
                  GwAvatar(
                    name: group?.name ?? author?.displayName ?? '?',
                    shape: group == null ? GwAvatarShape.user : GwAvatarShape.group,
                    imageUrl: group?.logoUrl ?? author?.avatarUrl,
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                        Text(meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<void>(
            tooltip: feedL10n.moreOptions,
            icon: const Icon(Icons.more_horiz),
            itemBuilder: (_) => [
              PopupMenuItem(onTap: () => copyPostLink(context, post), child: Text(feedL10n.copyLink)),
              if (!post.canManage)
                PopupMenuItem(
                  onTap: () => ref.read(reportLauncherProvider)(context, ReportTarget.post(post.id)),
                  child: Text(feedL10n.report),
                ),
              if (post.canManage) ...[
                PopupMenuItem(onTap: () => context.push(FeedRoutes.edit(post.id)), child: Text(feedL10n.edit)),
                PopupMenuItem(
                  onTap: () async {
                    if (await deletePost(context, ref, post)) onDeleted?.call();
                  },
                  child: Text(feedL10n.delete, style: const TextStyle(color: GwColors.error)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Like, comment and share with their counts; save on the right.
class _Actions extends ConsumerWidget {
  const _Actions({required this.post, required this.showComments});

  final Post post;

  /// Off on the comments page itself.
  final bool showComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.fromLTRB(GwSpacing.xs, GwSpacing.xxs, GwSpacing.xxs, GwSpacing.xxs),
        child: Row(
          children: [
            _Counter(
              tooltip: post.liked ? feedL10n.unlike : feedL10n.like,
              icon: post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: post.liked ? GwColors.like : null,
              count: post.likeCount,
              describe: feedL10n.likeCount,
              onTap: () => toggleLike(context, ref, post),
            ),
            if (!post.commentsDisabled)
              _Counter(
                tooltip: feedL10n.commentAction,
                icon: Icons.mode_comment_outlined,
                count: post.commentCount,
                describe: feedL10n.commentCount,
                onTap: showComments ? () => context.push(FeedRoutes.comments(post.id)) : null,
              ),
            _Counter(tooltip: feedL10n.copyLink, icon: Icons.ios_share_rounded, onTap: () => copyPostLink(context, post)),
            const Spacer(),
            IconButton(
              tooltip: post.saved ? feedL10n.unsave : feedL10n.save,
              onPressed: () => toggleSave(context, ref, post),
              icon: Icon(post.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            ),
          ],
        ),
      );
}

/// The emoji reactions under a photo or video: anyone who sees it may leave one; each shows its count.
class PostReactions extends ConsumerWidget {
  const PostReactions({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.xs),
      child: Row(
        children: [
          for (final emoji in postReactionEmojis)
            Padding(
              padding: const EdgeInsets.only(right: GwSpacing.xs),
              child: Semantics(
                button: true,
                selected: post.myReaction == emoji,
                label: feedL10n.reactionLabel(emoji, post.reactions[emoji] ?? 0),
                child: InkWell(
                  onTap: () => toggleReaction(context, ref, post, emoji),
                  borderRadius: GwRadius.xlAll,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget - GwSpacing.xs, minWidth: GwSpacing.minTouchTarget),
                    padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm),
                    decoration: BoxDecoration(
                      color: post.myReaction == emoji ? GwColors.primarySoft : GwColors.surface,
                      borderRadius: GwRadius.xlAll,
                      border: Border.all(color: post.myReaction == emoji ? GwColors.primary : GwColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(child: Text(emoji, style: textTheme.titleMedium)),
                        if ((post.reactions[emoji] ?? 0) > 0) ...[
                          const SizedBox(width: GwSpacing.xxs),
                          ExcludeSemantics(child: Text(formatCount(post.reactions[emoji]!), style: textTheme.labelLarge)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// An icon with its count; no number when it is zero or hidden.
class _Counter extends StatelessWidget {
  const _Counter({required this.tooltip, required this.icon, this.onTap, this.color, this.count, this.describe});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final int? count;

  /// Read after the number by screen readers ("3 beğenme").
  /// The count for screen readers, e.g. "3 beğenme".
  final String Function(int count)? describe;

  @override
  Widget build(BuildContext context) {
    final n = count;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: GwRadius.xlAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget, minWidth: GwSpacing.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color ?? GwColors.textPrimary, size: GwSpacing.lg - GwSpacing.xxs),
                if (n != null && n > 0) ...[
                  const SizedBox(width: GwSpacing.xxs),
                  Semantics(
                    label: describe?.call(n) ?? formatCount(n),
                    excludeSemantics: true,
                    child: Text(formatCount(n), style: Theme.of(context).textTheme.labelLarge),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two lines with feedL10n.more to expand.
class _Caption extends StatefulWidget {
  const _Caption({required this.post, required this.onOpenOwner});

  final Post post;
  final VoidCallback onOpenOwner;

  @override
  State<_Caption> createState() => _CaptionState();
}

class _CaptionState extends State<_Caption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final lead = post.group?.name ?? post.author?.username;
    final text = FeedRichText(text: post.caption, lead: lead, onLeadTap: widget.onOpenOwner, maxLines: _expanded ? null : 2);
    if (_expanded || (post.caption.length < 90 && !post.caption.contains('\n'))) return text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text,
        InkWell(
          onTap: () => setState(() => _expanded = true),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
            child: Text(feedL10n.more, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}

/// Feed card placeholder.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: GwSpacing.page),
        child: GwCard(
          radius: GwRadius.lgAll,
          padding: EdgeInsets.all(GwSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GwSkeleton.circle(size: GwSpacing.xl + GwSpacing.xs),
                SizedBox(width: GwSpacing.sm),
                GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.md),
              ]),
              SizedBox(height: GwSpacing.sm),
              AspectRatio(aspectRatio: 1, child: GwSkeleton(height: double.infinity, borderRadius: GwRadius.mdAll)),
              SizedBox(height: GwSpacing.sm),
              GwSkeleton(width: GwSpacing.xxl * 4, height: GwSpacing.md),
            ],
          ),
        ),
      );
}
