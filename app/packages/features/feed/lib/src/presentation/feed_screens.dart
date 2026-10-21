import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/post.dart';
import 'post_card.dart';
import 'post_lists.dart';
import 'providers.dart';
import 'routes.dart';
import 'stories.dart';

/// Opens a sheet to share a post or a story.
Future<void> showCreateSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.grid_on_outlined),
              title: const Text('Gönderi'),
              subtitle: const Text('10 fotoğraf ya da videoya kadar'),
              onTap: () {
                Navigator.of(sheet).pop();
                context.push(FeedRoutes.create);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Hikaye'),
              subtitle: const Text('24 saat görünür'),
              onTap: () {
                Navigator.of(sheet).pop();
                context.push(FeedRoutes.newStory);
              },
            ),
          ],
        ),
      ),
    );

/// Own posts, followed people and groups, newest first, under the story bar.
class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key, this.trailingActions = const [], this.top});

  /// App-level actions, e.g. notifications.
  final List<Widget> trailingActions;

  /// Shown above the story tray, e.g. live broadcasts (supplied by the app).
  final Widget? top;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: GxSpacing.md,
          title: const GxLogo(size: GxSpacing.lg + GxSpacing.xxs, wordmark: true),
          actions: [
            IconButton(tooltip: 'Paylaş', icon: const Icon(Icons.add_box_outlined), onPressed: () => showCreateSheet(context)),
            IconButton(tooltip: 'Kaydedilenler', icon: const Icon(Icons.bookmark_border_rounded), onPressed: () => context.push(FeedRoutes.saved)),
            ...trailingActions,
            const SizedBox(width: GxSpacing.xs),
          ],
        ),
        body: GxReadingColumn(
        maxWidth: GxLayout.feedMaxWidth,
          child: PagedPostFeed(
            source: const HomeFeed(),
            header: top == null ? const StoryTray() : Column(mainAxisSize: MainAxisSize.min, children: [top!, const StoryTray()]),
            empty: (
              icon: Icons.dynamic_feed_outlined,
              message: 'Akışın boş. Takip ettiğin kişilerin ve grupların gönderileri burada görünür.',
              actionLabel: 'Keşfet',
              onAction: () => context.go(FeedRoutes.explore),
            ),
          ),
        ),
      );
}

/// People results for a query, supplied by the app (the profile feature owns people).
typedef PeopleResultsBuilder = Widget Function(BuildContext context, String query, VoidCallback onClear);

/// Popular recent posts, and search for accounts and #tags.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, required this.peopleResults});

  final PeopleResultsBuilder peopleResults;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _query = value.trim()));
  }

  void _clear() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final searching = _query.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: GxSpacing.md,
        title: TextField(
          controller: _search,
          onChanged: _changed,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Kişi ya da #etiket ara',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isEmpty ? null : IconButton(tooltip: 'Temizle', icon: const Icon(Icons.close), onPressed: _clear),
            isDense: true,
          ),
        ),
      ),
      body: GxReadingColumn(
        child: !searching
            ? PagedPostGrid(
                source: const ExplorePosts(),
                empty: (
                  icon: Icons.explore_outlined,
                  message: 'Keşfedilecek yeni gönderi yok. Biraz sonra tekrar bak.',
                  actionLabel: 'Yenile',
                  onAction: () => ref.invalidate(postListProvider(const ExplorePosts())),
                ),
              )
            : DefaultTabController(
                length: 2,
                initialIndex: _query.startsWith('#') ? 1 : 0,
                child: Column(
                  children: [
                    const TabBar(tabs: [Tab(text: 'Hesaplar'), Tab(text: 'Etiketler')]),
                    Expanded(
                      child: TabBarView(
                        children: [
                          widget.peopleResults(context, _query.replaceAll('#', ''), _clear),
                          _HashtagResults(query: _query, onClear: _clear),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HashtagResults extends ConsumerWidget {
  const _HashtagResults({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(hashtagSearchProvider(query));
    return switch (tags) {
      AsyncData(:final value) when value.isEmpty => GxEmptyState(
          icon: Icons.tag,
          message: '"$query" ile başlayan bir etiket bulunamadı.',
          actionLabel: 'Aramayı temizle',
          onAction: onClear,
        ),
      AsyncData(:final value) => ListView(
          children: [
            for (final t in value)
              ListTile(
                leading: const CircleAvatar(backgroundColor: GxColors.surfaceMuted, child: Icon(Icons.tag, color: GxColors.textPrimary)),
                title: Text('#${t.tag}'),
                subtitle: Text('${formatCount(t.postCount)} gönderi'),
                onTap: () => context.push(FeedRoutes.hashtag(t.tag)),
              ),
          ],
        ),
      AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(hashtagSearchProvider(query))),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class HashtagScreen extends StatelessWidget {
  const HashtagScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final normalized = tag.toLowerCase();
    return Scaffold(
      appBar: AppBar(title: Text('#$normalized')),
      body: GxReadingColumn(
        child: PagedPostGrid(
          source: HashtagPosts(normalized),
          empty: (
            icon: Icons.tag,
            message: '#$normalized etiketiyle görebileceğin bir gönderi yok.',
            actionLabel: 'Keşfete dön',
            onAction: () => context.go(FeedRoutes.explore),
          ),
        ),
      ),
    );
  }
}

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Kaydedilenler')),
        body: GxReadingColumn(
          child: PagedPostGrid(
            source: const SavedPosts(),
            empty: (
              icon: Icons.bookmark_border_rounded,
              message: 'Kaydettiğin gönderiler burada yalnızca sana görünür.',
              actionLabel: 'Keşfet',
              onAction: () => context.go(FeedRoutes.explore),
            ),
          ),
        ),
      );
}

/// A single post, e.g. from a shared link or a grid.
class PostScreen extends ConsumerWidget {
  const PostScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(postId));
    return Scaffold(
      appBar: AppBar(title: const Text('Gönderi')),
      body: GxReadingColumn(
        child: switch (post) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.refresh(postProvider(postId).future),
              child: ListView(
                children: [
                  PostCard(post: value, onDeleted: () => context.canPop() ? context.pop() : context.go(FeedRoutes.home)),
                ],
              ),
            ),
          AsyncError(error: NotFoundFailure()) => GxEmptyState(
              icon: Icons.image_not_supported_outlined,
              message: 'Bu gönderi silinmiş ya da görme iznin yok.',
              actionLabel: 'Akışa dön',
              onAction: () => context.go(FeedRoutes.home),
            ),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postProvider(postId))),
          _ => const PostCardSkeleton(),
        },
      ),
    );
  }
}
