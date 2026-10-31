import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/post.dart';
import 'post_card.dart';
import 'providers.dart';
import 'rich_text.dart';
import 'routes.dart';

/// Comments of a post with one level of replies.
class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  Comment? _replyTo;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _reply(Comment c) {
    setState(() => _replyTo = c);
    _text
      ..text = '@${c.author.username} '
      ..selection = TextSelection.collapsed(offset: c.author.username.length + 2);
    _focus.requestFocus();
  }

  Future<void> _send(Post post) async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    final result = await ref.read(feedRepositoryProvider).addComment(widget.postId, body, replyTo: _replyTo?.id);
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case Ok():
        _text.clear();
        setState(() => _replyTo = null);
        ref.read(postEditsProvider.notifier).put(post.copyWith(commentCount: post.commentCount + 1));
        ref.invalidate(commentsProvider(widget.postId));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(postProvider(widget.postId));
    final post = switch (loaded.value) {
      final p? => watchPost(ref, p),
      null => null,
    };
    final comments = ref.watch(commentsProvider(widget.postId));
    final me = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yorumlar')),
      body: GwReadingColumn(
        maxWidth: GwLayout.feedMaxWidth,
        child: Column(
          children: [
            Expanded(
              child: switch (comments) {
                AsyncData(:final value) when value.isEmpty => GwEmptyState(
                    icon: Icons.mode_comment_outlined,
                    message: switch (post) {
                      Post(commentsDisabled: true) => 'Bu gönderide yorumlar kapalı.',
                      Post(canComment: false) => 'Henüz yorum yok. Bu paylaşıma emojiyle tepki bırakabilirsin.',
                      _ => 'Henüz yorum yok. İlk yorumu sen yaz.',
                    },
                    actionLabel: post?.commentsDisabled == true || post?.canComment == false ? 'Geri dön' : 'Yorum yaz',
                    onAction: post?.commentsDisabled == true || post?.canComment == false
                        ? () => Navigator.of(context).maybePop()
                        : _focus.requestFocus,
                  ),
                AsyncData(:final value) => RefreshIndicator(
                    onRefresh: () => ref.refresh(commentsProvider(widget.postId).future),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
                      children: [
                        if (post != null && post.caption.isNotEmpty) ...[
                          _CaptionRow(post: post),
                          const Divider(),
                        ],
                        for (final c in value) ...[
                          _CommentRow(
                            comment: c,
                            canDelete: c.author.id == me || (post?.canManage ?? false),
                            onReply: post?.commentsDisabled == true || post?.canComment == false ? null : () => _reply(c),
                            post: post,
                          ),
                          for (final r in c.replies)
                            Padding(
                              padding: const EdgeInsets.only(left: GwSpacing.xxl),
                              child: _CommentRow(
                                comment: r,
                                canDelete: r.author.id == me || (post?.canManage ?? false),
                                onReply: post?.commentsDisabled == true || post?.canComment == false ? null : () => _reply(c),
                                post: post,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                AsyncError(:final error) =>
                  GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(commentsProvider(widget.postId))),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            if (post != null && !post.commentsDisabled && post.canComment) _composer(post),
            if (post != null && !post.commentsDisabled && !post.canComment) _ReactOnly(post: post),
          ],
        ),
      ),
    );
  }

  Widget _composer(Post post) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(top: GwBorders.hairline), color: GwColors.background),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.xs, GwSpacing.xs, GwSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_replyTo case final reply?)
                Row(
                  children: [
                    Expanded(
                      child: Text('@${reply.author.username} kullanıcısına yanıt veriyorsun',
                          style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                    ),
                    IconButton(
                      tooltip: 'Yanıtı iptal et',
                      icon: const Icon(Icons.close, size: GwSpacing.md),
                      onPressed: () => setState(() {
                        _replyTo = null;
                        _text.clear();
                      }),
                    ),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: NewPost.maxCaption,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Yorum ekle…', counterText: '', isDense: true),
                      onSubmitted: (_) => _send(post),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.xs),
                  TextButton(onPressed: _sending ? null : () => _send(post), child: const Text('Paylaş')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptionRow extends ConsumerWidget {
  const _CaptionRow({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.read(feedLinksProvider);
    final group = post.group;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GwAvatar(
            name: group?.name ?? post.author?.displayName ?? '?',
            shape: group == null ? GwAvatarShape.user : GwAvatarShape.group,
            imageUrl: group?.logoUrl ?? post.author?.avatarUrl,
            size: GwAvatarSize.sm,
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: FeedRichText(
              text: post.caption,
              lead: group?.name ?? post.author?.username,
              onLeadTap: () => group != null
                  ? links.openGroup(context, group.handle)
                  : post.author == null
                      ? null
                      : links.openProfile(context, post.author!.username),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends ConsumerStatefulWidget {
  const _CommentRow({required this.comment, required this.canDelete, required this.onReply, required this.post});

  final Comment comment;
  final bool canDelete;
  final VoidCallback? onReply;
  final Post? post;

  @override
  ConsumerState<_CommentRow> createState() => _CommentRowState();
}

class _CommentRowState extends ConsumerState<_CommentRow> {
  late bool _liked = widget.comment.liked;
  late int _likes = widget.comment.likeCount;

  @override
  void didUpdateWidget(_CommentRow old) {
    super.didUpdateWidget(old);
    if (old.comment != widget.comment) {
      _liked = widget.comment.liked;
      _likes = widget.comment.likeCount;
    }
  }

  Future<void> _toggleLike() async {
    final liked = !_liked;
    setState(() {
      _liked = liked;
      _likes += liked ? 1 : -1;
    });
    final result = await ref.read(feedRepositoryProvider).setCommentLiked(widget.comment.id, liked);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      setState(() {
        _liked = !liked;
        _likes += liked ? -1 : 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: const Text('Yorum silinsin mi?'),
        content: const Text('Yorum ve yanıtları kalıcı olarak silinir.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: 'Sil', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(feedRepositoryProvider).deleteComment(widget.comment.id);
    if (!mounted) return;
    switch (result) {
      case Ok():
        if (widget.post case final post?) {
          final removed = 1 + widget.comment.replies.length;
          ref.read(postEditsProvider.notifier).put(post.copyWith(commentCount: (post.commentCount - removed).clamp(0, 1 << 30)));
        }
        ref.invalidate(commentsProvider(widget.comment.postId));
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.labelMedium?.copyWith(color: GwColors.textSecondary);
    final links = ref.read(feedLinksProvider);
    return InkWell(
      onLongPress: widget.canDelete ? _delete : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.xs, GwSpacing.xxs, GwSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => links.openProfile(context, c.author.username),
              customBorder: const CircleBorder(),
              child: GwAvatar(name: c.author.displayName, shape: GwAvatarShape.user, imageUrl: c.author.avatarUrl, size: GwAvatarSize.sm),
            ),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeedRichText(text: c.body, lead: c.author.username, onLeadTap: () => links.openProfile(context, c.author.username)),
                  Wrap(
                    spacing: GwSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(formatAgoTr(c.createdAt), style: muted),
                      if (_likes > 0) Text('$_likes beğenme', style: muted),
                      if (widget.onReply != null)
                        TextButton(
                          onPressed: widget.onReply,
                          style: TextButton.styleFrom(foregroundColor: GwColors.textSecondary, textStyle: textTheme.labelMedium),
                          child: const Text('Yanıtla'),
                        ),
                      if (widget.canDelete)
                        TextButton(
                          onPressed: _delete,
                          style: TextButton.styleFrom(foregroundColor: GwColors.textSecondary, textStyle: textTheme.labelMedium),
                          child: const Text('Sil'),
                        ),
                      if (c.author.id != ref.read(currentUserIdProvider))
                        TextButton(
                          onPressed: () => ref.read(reportLauncherProvider)(context, ReportTarget.comment(c.id)),
                          style: TextButton.styleFrom(foregroundColor: GwColors.textSecondary, textStyle: textTheme.labelMedium),
                          child: const Text('Şikayet et'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _liked ? 'Beğenmekten vazgeç' : 'Yorumu beğen',
              onPressed: _toggleLike,
              icon: Icon(
                _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: GwSpacing.md,
                color: _liked ? GwColors.like : GwColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// In place of the composer when the viewer may not comment: why, and the emoji reactions.
class _ReactOnly extends StatelessWidget {
  const _ReactOnly({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(color: GwColors.surface, border: Border(top: GwBorders.hairline)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
                  child: Text(
                    'Bu paylaşıma şu anda yorum yazamazsın. Emojiyle tepki bırakabilirsin.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                  ),
                ),
                const SizedBox(height: GwSpacing.xs),
                PostReactions(post: post),
              ],
            ),
          ),
        ),
      );
}
