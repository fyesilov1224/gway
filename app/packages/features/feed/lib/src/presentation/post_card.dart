import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/post.dart';
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
      if (saved) _snack(context, 'Kaydedilenlere eklendi.');
  }
}

Future<void> copyPostLink(BuildContext context, Post post) async {
  await Clipboard.setData(ClipboardData(text: FeedRoutes.shareLink(post.id)));
  if (context.mounted) _snack(context, 'Gönderi bağlantısı kopyalandı.');
}

/// Asks first; returns true when the post was deleted.
Future<bool> deletePost(BuildContext context, WidgetRef ref, Post post) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
      title: const Text('Gönderi silinsin mi?'),
      content: const Text('Gönderi, fotoğrafları, videoları ve yorumlarıyla birlikte kalıcı olarak silinir.'),
      actions: [
        GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
        GxButton(label: 'Sil', onPressed: () => Navigator.of(context).pop(true)),
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
      _snack(context, 'Gönderi silindi.');
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
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
      child: GxCard(
        radius: GxRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(post: current, onOpenOwner: openOwner, onDeleted: onDeleted),
            if (current.media.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs),
                child: ClipRRect(
                  borderRadius: GxRadius.mdAll,
                  child: MediaCarousel(media: current.media, onDoubleTap: () => toggleLike(context, ref, current, onlyLike: true)),
                ),
              ),
            _Actions(post: current, showComments: showAllComments),
            PostReactions(post: current),
            if (current.caption.isNotEmpty || current.event != null || (current.hideLikeCount && current.canManage))
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (current.hideLikeCount && current.canManage)
                      Text('Beğeni sayısı yalnızca sana görünür.', style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                    if (current.caption.isNotEmpty) _Caption(post: current, onOpenOwner: openOwner),
                    if (current.event case final event?)
                      Padding(
                        padding: const EdgeInsets.only(top: GxSpacing.xs),
                        child: InkWell(
                          borderRadius: GxRadius.xlAll,
                          onTap: links.openEvent == null ? null : () => links.openEvent!(context, event.id),
                          child: GxTag(label: 'Anı · ${event.title}', icon: Icons.event_outlined),
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
    final name = group?.name ?? author?.displayName ?? 'Silinmiş hesap';
    final meta = [
      if (author != null) '@${author.username}' else if (group != null) 'Grup gönderisi',
      formatAgoTr(post.createdAt),
      if (post.editedAt != null) 'düzenlendi',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.sm, GxSpacing.sm, GxSpacing.xxs, GxSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpenOwner,
              borderRadius: GxRadius.mdAll,
              child: Row(
                children: [
                  GxAvatar(
                    name: group?.name ?? author?.displayName ?? '?',
                    shape: group == null ? GxAvatarShape.user : GxAvatarShape.group,
                    imageUrl: group?.logoUrl ?? author?.avatarUrl,
                  ),
                  const SizedBox(width: GxSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                        Text(meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<void>(
            tooltip: 'Diğer seçenekler',
            icon: const Icon(Icons.more_horiz),
            itemBuilder: (_) => [
              PopupMenuItem(onTap: () => copyPostLink(context, post), child: const Text('Bağlantıyı kopyala')),
              if (!post.canManage)
                PopupMenuItem(
                  onTap: () => ref.read(reportLauncherProvider)(context, ReportTarget.post(post.id)),
                  child: const Text('Şikayet et'),
                ),
              if (post.canManage) ...[
                PopupMenuItem(onTap: () => context.push(FeedRoutes.edit(post.id)), child: const Text('Düzenle')),
                PopupMenuItem(
                  onTap: () async {
                    if (await deletePost(context, ref, post)) onDeleted?.call();
                  },
                  child: const Text('Sil', style: TextStyle(color: GxColors.error)),
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
        padding: const EdgeInsets.fromLTRB(GxSpacing.xs, GxSpacing.xxs, GxSpacing.xxs, GxSpacing.xxs),
        child: Row(
          children: [
            _Counter(
              tooltip: post.liked ? 'Beğenmekten vazgeç' : 'Beğen',
              icon: post.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: post.liked ? GxColors.like : null,
              count: post.likeCount,
              unit: 'beğenme',
              onTap: () => toggleLike(context, ref, post),
            ),
            if (!post.commentsDisabled)
              _Counter(
                tooltip: 'Yorum yap',
                icon: Icons.mode_comment_outlined,
                count: post.commentCount,
                unit: 'yorum',
                onTap: showComments ? () => context.push(FeedRoutes.comments(post.id)) : null,
              ),
            _Counter(tooltip: 'Bağlantıyı kopyala', icon: Icons.ios_share_rounded, onTap: () => copyPostLink(context, post)),
            const Spacer(),
            IconButton(
              tooltip: post.saved ? 'Kaydedilenlerden çıkar' : 'Kaydet',
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
      padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.xs),
      child: Row(
        children: [
          for (final emoji in postReactionEmojis)
            Padding(
              padding: const EdgeInsets.only(right: GxSpacing.xs),
              child: Semantics(
                button: true,
                selected: post.myReaction == emoji,
                label: '$emoji tepkisi, ${post.reactions[emoji] ?? 0}',
                child: InkWell(
                  onTap: () => toggleReaction(context, ref, post, emoji),
                  borderRadius: GxRadius.xlAll,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget - GxSpacing.xs, minWidth: GxSpacing.minTouchTarget),
                    padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
                    decoration: BoxDecoration(
                      color: post.myReaction == emoji ? GxColors.primarySoft : GxColors.surface,
                      borderRadius: GxRadius.xlAll,
                      border: Border.all(color: post.myReaction == emoji ? GxColors.primary : GxColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(child: Text(emoji, style: textTheme.titleMedium)),
                        if ((post.reactions[emoji] ?? 0) > 0) ...[
                          const SizedBox(width: GxSpacing.xxs),
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
  const _Counter({required this.tooltip, required this.icon, this.onTap, this.color, this.count, this.unit = ''});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final int? count;

  /// Read after the number by screen readers ("3 beğenme").
  final String unit;

  @override
  Widget build(BuildContext context) {
    final n = count;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: GxRadius.xlAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget, minWidth: GxSpacing.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color ?? GxColors.textPrimary, size: GxSpacing.lg - GxSpacing.xxs),
                if (n != null && n > 0) ...[
                  const SizedBox(width: GxSpacing.xxs),
                  Semantics(
                    label: '${formatCount(n)} $unit',
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

/// Two lines with "devamı" to expand.
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
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
            child: Text('devamı', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
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
        padding: EdgeInsets.symmetric(horizontal: GxSpacing.page),
        child: GxCard(
          radius: GxRadius.lgAll,
          padding: EdgeInsets.all(GxSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GxSkeleton.circle(size: GxSpacing.xl + GxSpacing.xs),
                SizedBox(width: GxSpacing.sm),
                GxSkeleton(width: GxSpacing.xxl * 2, height: GxSpacing.md),
              ]),
              SizedBox(height: GxSpacing.sm),
              AspectRatio(aspectRatio: 1, child: GxSkeleton(height: double.infinity, borderRadius: GxRadius.mdAll)),
              SizedBox(height: GxSpacing.sm),
              GxSkeleton(width: GxSpacing.xxl * 4, height: GxSpacing.md),
            ],
          ),
        ),
      );
}
