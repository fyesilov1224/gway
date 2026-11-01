import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/feed_repository_impl.dart';
import '../data/story_repository_impl.dart';
import '../domain/post.dart';
import '../domain/story.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final storyRepositoryProvider = Provider<StoryRepository>((ref) => StoryRepositoryImpl(ref.watch(supabaseClientProvider)));

class PostPage {
  const PostPage(this.posts, {required this.hasMore, this.loadingMore = false});

  final List<Post> posts;
  final bool hasMore;
  final bool loadingMore;
}

/// A list of posts that loads more pages on demand.
final postListProvider = AsyncNotifierProvider.autoDispose.family<PostList, PostPage, PostSource>(PostList.new);

class PostList extends AsyncNotifier<PostPage> {
  PostList(this.source);

  final PostSource source;

  @override
  Future<PostPage> build() async {
    // Pages loaded with loadMore would be lost to a background refresh; pull to refresh reloads.
    ref.cacheFor(staleAfter: screenCacheKeep);
    final posts = (await ref.watch(feedRepositoryProvider).posts(source)).getOrThrow();
    return PostPage(posts, hasMore: source is! SavedPosts && posts.length >= FeedRepositoryImpl.pageSize);
  }

  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || !page.hasMore || page.loadingMore) return;
    state = AsyncData(PostPage(page.posts, hasMore: true, loadingMore: true));
    final result = await ref
        .read(feedRepositoryProvider)
        .posts(source, after: page.posts.lastOrNull, offset: page.posts.length);
    state = AsyncData(switch (result) {
      Ok(:final value) => PostPage(
          [...page.posts, ...value.where((p) => !page.posts.any((q) => q.id == p.id))],
          hasMore: value.length >= FeedRepositoryImpl.pageSize,
        ),
      // Keep what is shown; scrolling again retries.
      Err() => PostPage(page.posts, hasMore: true),
    });
  }
}

final postProvider = FutureProvider.autoDispose.family<Post, String>((ref, id) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(feedRepositoryProvider).post(id)).getOrThrow();
});

/// Local changes to posts (likes, saves, edits; null = deleted), so every list
/// showing a post agrees without reloading.
final postEditsProvider = NotifierProvider<PostEdits, Map<String, Post?>>(PostEdits.new);

class PostEdits extends Notifier<Map<String, Post?>> {
  @override
  Map<String, Post?> build() {
    ref.watch(currentUserIdProvider);
    return const {};
  }

  void put(Post post) => state = {...state, post.id: post};

  void deleted(String id) => state = {...state, id: null};
}

/// The newest local version of [post]; null once deleted.
Post? watchPost(WidgetRef ref, Post post) {
  final edits = ref.watch(postEditsProvider);
  return edits.containsKey(post.id) ? edits[post.id] : post;
}

final commentsProvider = FutureProvider.autoDispose.family<List<Comment>, String>((ref, postId) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(feedRepositoryProvider).comments(postId)).getOrThrow();
});

final hashtagSearchProvider = FutureProvider.autoDispose.family<List<HashtagCount>, String>((ref, query) async {
  ref.cacheFor();
  final q = query.trim().replaceAll('#', '');
  if (q.isEmpty) return const [];
  return (await ref.watch(feedRepositoryProvider).searchHashtags(q)).getOrThrow();
});

final publishableGroupsProvider = FutureProvider.autoDispose<List<PostGroup>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(feedRepositoryProvider).publishableGroups()).getOrThrow();
  },
);

final storyTrayProvider = FutureProvider.autoDispose<List<StoryRing>>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(storyRepositoryProvider).tray()).getOrThrow();
});

final activeStoriesProvider = FutureProvider.autoDispose.family<List<Story>, String>(
  (ref, userId) async {
    ref.cacheFor();
    return (await ref.watch(storyRepositoryProvider).active(userId)).getOrThrow();
  },
);

final storyArchiveProvider = FutureProvider.autoDispose<List<Story>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(storyRepositoryProvider).archive()).getOrThrow();
  },
);

final storyViewersProvider = FutureProvider.autoDispose.family<List<StoryViewer>, String>(
  (ref, storyId) async {
    ref.cacheFor();
    return (await ref.watch(storyRepositoryProvider).viewers(storyId)).getOrThrow();
  },
);

final highlightsProvider = FutureProvider.autoDispose.family<List<Highlight>, String>(
  (ref, userId) async {
    ref.cacheFor();
    return (await ref.watch(storyRepositoryProvider).highlights(userId)).getOrThrow();
  },
);

final highlightStoriesProvider = FutureProvider.autoDispose.family<List<Story>, String>(
  (ref, id) async {
    ref.cacheFor();
    return (await ref.watch(storyRepositoryProvider).highlightStories(id)).getOrThrow();
  },
);

/// Bumped whenever a post is created or deleted, so other pages (e.g. profile counts) can reload.
final postsChangedProvider = NotifierProvider<PostsChanged, int>(PostsChanged.new);

class PostsChanged extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// After posting or deleting: lists that may contain the post load again.
void refreshPostLists(WidgetRef ref) {
  ref.invalidate(postListProvider);
  ref.read(postsChangedProvider.notifier).bump();
}

void refreshStories(WidgetRef ref) {
  ref
    ..invalidate(storyTrayProvider)
    ..invalidate(activeStoriesProvider)
    ..invalidate(storyArchiveProvider)
    ..invalidate(highlightsProvider)
    ..invalidate(highlightStoriesProvider);
}
