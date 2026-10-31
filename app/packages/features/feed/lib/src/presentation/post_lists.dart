import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/post.dart';
import 'media.dart';
import 'post_card.dart';
import 'providers.dart';
import 'routes.dart';

/// Empty list content: icon, one sentence and an action (docs/DESIGN.md).
typedef EmptyPosts = ({IconData icon, String message, String actionLabel, VoidCallback onAction});

bool _nearEnd(ScrollNotification n) => n.metrics.extentAfter < 800;

/// Portrait tiles in three columns, separate rounded cards (docs/DESIGN.md §7).
const postGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: GwMedia.gridColumns,
  childAspectRatio: GwMedia.gridTile,
  mainAxisSpacing: GwMedia.gridGap,
  crossAxisSpacing: GwMedia.gridGap,
);

/// Post cards that load more near the end; [header] scrolls with them (e.g. the story bar).
class PagedPostFeed extends ConsumerWidget {
  const PagedPostFeed({super.key, required this.source, required this.empty, this.header, this.onRefresh});

  final PostSource source;
  final EmptyPosts empty;
  final Widget? header;

  /// Also reloads what the [header] shows when the list is pulled down.
  final void Function(WidgetRef ref)? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(postListProvider(source));
    final edits = ref.watch(postEditsProvider);
    final posts = [for (final p in page.value?.posts ?? const <Post>[]) if (!edits.containsKey(p.id) || edits[p.id] != null) p];

    return RefreshIndicator(
      onRefresh: () {
        onRefresh?.call(ref);
        return ref.refresh(postListProvider(source).future);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (_nearEnd(n)) ref.read(postListProvider(source).notifier).loadMore();
          return false;
        },
        child: CustomScrollView(
          slivers: [
            if (header != null) SliverToBoxAdapter(child: header),
            const SliverPadding(padding: EdgeInsets.only(top: GwSpacing.xs)),
            switch (page) {
              AsyncData() when posts.isEmpty => SliverFillRemaining(
                  hasScrollBody: false,
                  child: GwEmptyState(icon: empty.icon, message: empty.message, actionLabel: empty.actionLabel, onAction: empty.onAction),
                ),
              AsyncData(:final value) => SliverList.separated(
                  itemCount: posts.length + (value.loadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: GwSpacing.sm),
                  itemBuilder: (_, i) => i == posts.length ? const PostCardSkeleton() : PostCard(post: posts[i]),
                ),
              AsyncError(:final error) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postListProvider(source))),
                ),
              _ => SliverList.list(children: const [PostCardSkeleton(), PostCardSkeleton()]),
            },
            const SliverPadding(padding: EdgeInsets.only(bottom: GwSpacing.lg)),
          ],
        ),
      ),
    );
  }
}

/// Three columns of rounded previews inside the page gutter; opens the post on tap.
class PostGrid extends ConsumerWidget {
  const PostGrid({super.key, required this.posts, this.scrollable = false});

  final List<Post> posts;

  /// Off when the grid sits inside another scroll view.
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edits = ref.watch(postEditsProvider);
    final visible = [for (final p in posts) if (!edits.containsKey(p.id) || edits[p.id] != null) p];
    return GridView.builder(
      shrinkWrap: !scrollable,
      physics: scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.xs),
      gridDelegate: postGridDelegate,
      itemCount: visible.length,
      itemBuilder: (context, i) => PostTile(post: visible[i]),
    );
  }
}

class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: post.caption.isEmpty ? 'Gönderi' : 'Gönderi: ${post.caption}',
        child: Material(
          color: GwColors.surfaceMuted,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.all(Radius.circular(GwMedia.gridRadius)),
          child: InkWell(
            onTap: () => context.push(FeedRoutes.post(post.id)),
            child: post.media.isEmpty
                ? const SizedBox.expand()
                : MediaThumb(
                    media: post.media.first,
                    badge: post.media.length > 1
                        ? Icons.collections_outlined
                        : post.media.first.kind == MediaKind.video
                            ? Icons.play_arrow_rounded
                            : null,
                  ),
          ),
        ),
      );
}

/// A full-screen grid that loads more near the end.
class PagedPostGrid extends ConsumerWidget {
  const PagedPostGrid({super.key, required this.source, required this.empty});

  final PostSource source;
  final EmptyPosts empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(postListProvider(source));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(postListProvider(source).future),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (_nearEnd(n)) ref.read(postListProvider(source).notifier).loadMore();
          return false;
        },
        child: switch (page) {
          AsyncData(:final value) when value.posts.isEmpty => ListView(children: [
              const SizedBox(height: GwSpacing.xxl),
              GwEmptyState(icon: empty.icon, message: empty.message, actionLabel: empty.actionLabel, onAction: empty.onAction),
            ]),
          AsyncData(:final value) => PostGrid(posts: value.posts, scrollable: true),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postListProvider(source))),
          _ => const GridSkeleton(),
        },
      ),
    );
  }
}

/// The posts part of a profile or group page: a grid with "Daha fazla göster".
class PostsSection extends ConsumerWidget {
  const PostsSection({super.key, required this.source, required this.emptyMessage, this.emptyAction});

  final PostSource source;
  final String emptyMessage;

  /// E.g. "Gönderi paylaş" on your own profile; defaults to reloading.
  final ({String label, VoidCallback onPressed})? emptyAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(postListProvider(source));
    return switch (page) {
      AsyncData(:final value) when value.posts.isEmpty => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg),
          child: GwEmptyState(
            icon: Icons.photo_camera_outlined,
            message: emptyMessage,
            actionLabel: emptyAction?.label ?? 'Yenile',
            onAction: emptyAction?.onPressed ?? () => ref.invalidate(postListProvider(source)),
          ),
        ),
      AsyncData(:final value) => Column(
          children: [
            PostGrid(posts: value.posts),
            if (value.hasMore)
              Padding(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: GwButton(
                  label: 'Daha fazla göster',
                  variant: GwButtonVariant.secondary,
                  isLoading: value.loadingMore,
                  onPressed: () => ref.read(postListProvider(source).notifier).loadMore(),
                ),
              ),
          ],
        ),
      AsyncError(:final error) => Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postListProvider(source))),
        ),
      _ => const GridSkeleton(rows: 2, scrollable: false),
    };
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.rows = 4, this.scrollable = true});

  final int rows;
  final bool scrollable;

  @override
  Widget build(BuildContext context) => GridView.builder(
        gridDelegate: postGridDelegate,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.xs),
        shrinkWrap: !scrollable,
        physics: scrollable ? null : const NeverScrollableScrollPhysics(),
        itemCount: rows * GwMedia.gridColumns,
        itemBuilder: (_, _) =>
            const GwSkeleton(height: double.infinity, borderRadius: BorderRadius.all(Radius.circular(GwMedia.gridRadius))),
      );
}
