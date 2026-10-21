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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(post: current, onOpenOwner: openOwner, onDeleted: onDeleted),
        MediaCarousel(media: current.media, onDoubleTap: () => toggleLike(context, ref, current, onlyLike: true)),
        _Actions(post: current),
        Padding(
          padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (current.likeCount case final likes? when likes > 0)
                Text('${formatCount(likes)} beğenme', style: textTheme.labelLarge),
              if (current.hideLikeCount && current.canManage)
                Text('Beğeni sayısı yalnızca sana görünür.', style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
              if (current.caption.isNotEmpty) ...[
                const SizedBox(height: GxSpacing.xxs),
                _Caption(post: current, onOpenOwner: openOwner),
              ],
              if (current.event case final event?)
                InkWell(
                  onTap: links.openEvent == null ? null : () => links.openEvent!(context, event.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
                    child: Row(children: [
                      const Icon(Icons.event_outlined, size: GxSpacing.md, color: GxColors.primary),
                      const SizedBox(width: GxSpacing.xxs),
                      Expanded(
                        child: Text('Anı · ${event.title}', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(color: GxColors.primary)),
                      ),
                    ]),
                  ),
                ),
              if (showAllComments && !current.commentsDisabled && current.commentCount > 0) ...[
                const SizedBox(height: GxSpacing.xxs),
                InkWell(
                  onTap: () => context.push(FeedRoutes.comments(current.id)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
                    child: Text(
                      current.commentCount == 1 ? '1 yorumu gör' : '${formatCount(current.commentCount)} yorumun tümünü gör',
                      style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: GxSpacing.xxs),
              Text(
                '${formatAgoTr(current.createdAt)}${current.editedAt != null ? ' · düzenlendi' : ''}',
                style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
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
    final name = group?.name ?? post.author?.username ?? 'Silinmiş hesap';
    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.xs, GxSpacing.xxs, GxSpacing.xs),
      child: Row(
        children: [
          InkWell(
            onTap: onOpenOwner,
            borderRadius: GxRadius.mdAll,
            child: Row(
              children: [
                GxAvatar(
                  name: group?.name ?? post.author?.displayName ?? '?',
                  shape: group == null ? GxAvatarShape.user : GxAvatarShape.group,
                  imageUrl: group?.logoUrl ?? post.author?.avatarUrl,
                  size: GxAvatarSize.sm,
                ),
                const SizedBox(width: GxSpacing.sm),
              ],
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onOpenOwner,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  if (group != null)
                    Text(
                      post.author == null ? 'Grup gönderisi' : 'Grup gönderisi · @${post.author!.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
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

class _Actions extends ConsumerWidget {
  const _Actions({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xxs),
        child: Row(
          children: [
            IconButton(
              tooltip: post.liked ? 'Beğenmekten vazgeç' : 'Beğen',
              onPressed: () => toggleLike(context, ref, post),
              icon: post.liked
                  ? const Icon(Icons.favorite_rounded, color: GxColors.like)
                  : const Icon(Icons.favorite_border_rounded),
            ),
            if (!post.commentsDisabled)
              IconButton(
                tooltip: 'Yorum yap',
                onPressed: () => context.push(FeedRoutes.comments(post.id)),
                icon: const Icon(Icons.mode_comment_outlined),
              ),
            IconButton(
              tooltip: 'Bağlantıyı kopyala',
              onPressed: () => copyPostLink(context, post),
              icon: const Icon(Icons.send_outlined),
            ),
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
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(GxSpacing.md),
            child: Row(children: [
              GxSkeleton.circle(size: GxSpacing.xl),
              SizedBox(width: GxSpacing.sm),
              GxSkeleton(width: GxSpacing.xxl * 2, height: GxSpacing.md),
            ]),
          ),
          AspectRatio(aspectRatio: 1, child: GxSkeleton(height: double.infinity, borderRadius: BorderRadius.zero)),
          Padding(
            padding: EdgeInsets.all(GxSpacing.md),
            child: GxSkeleton(width: GxSpacing.xxl * 4, height: GxSpacing.md),
          ),
        ],
      );
}
