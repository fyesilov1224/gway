import 'dart:async';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/image_processing.dart';
import '../data/media_picker.dart';
import '../domain/media_crop.dart';
import '../domain/post.dart';
import '../domain/story.dart';
import 'crop_editor.dart';
import 'media.dart';
import 'providers.dart';
import 'routes.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

/// An avatar inside a story ring: primary while unseen, a hairline once seen (docs/DESIGN.md §1).
class StoryRingAvatar extends StatelessWidget {
  const StoryRingAvatar({super.key, required this.name, this.imageUrl, required this.unseen, this.size = GwAvatarSize.lg, this.shape = GwAvatarShape.user});

  final String name;
  final String? imageUrl;
  final bool unseen;
  final GwAvatarSize size;
  final GwAvatarShape shape;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(GwBorders.ringWidth),
        decoration: BoxDecoration(
          shape: shape == GwAvatarShape.user ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == GwAvatarShape.user ? null : GwRadius.lgAll,
          border: Border.all(color: unseen ? GwColors.primary : GwColors.border, width: GwBorders.ringWidth),
        ),
        child: GwAvatar(name: name, shape: shape, imageUrl: imageUrl, size: size),
      );
}

/// The story row on the home page: your story first, then followed people,
/// as small chips so stories stay secondary to groups and organizations.
class StoryTray extends ConsumerWidget {
  const StoryTray({super.key});

  static const double _height = GwSpacing.xxl + GwSpacing.xs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rings = ref.watch(storyTrayProvider).value;
    if (rings == null) return const SizedBox(height: _height);
    final mine = rings.where((r) => r.isMine).firstOrNull;
    final others = rings.where((r) => !r.isMine);
    return SizedBox(
      height: _height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
        children: [
          _TrayItem(
            label: mine == null ? 'Hikâye ekle' : 'Hikâyen',
            ring: mine,
            onTap: () => context.push(mine == null ? FeedRoutes.newStory : FeedRoutes.stories(mine.userId)),
          ),
          for (final r in others) _TrayItem(label: r.username, ring: r, onTap: () => context.push(FeedRoutes.stories(r.userId))),
        ],
      ),
    );
  }
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.label, required this.ring, required this.onTap});

  final String label;
  final StoryRing? ring;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: GwSpacing.xs),
        child: Center(
          child: Material(
            color: GwColors.background,
            shape: const StadiumBorder(side: GwBorders.hairline),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.xxs, GwSpacing.xxs, GwSpacing.md, GwSpacing.xxs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ring case final r?)
                      StoryRingAvatar(name: r.username, imageUrl: r.avatarUrl, unseen: r.hasUnseen, size: GwAvatarSize.sm)
                    else
                      Container(
                        width: GwAvatarSize.sm.dimension + GwBorders.ringWidth * 4,
                        height: GwAvatarSize.sm.dimension + GwBorders.ringWidth * 4,
                        decoration: const ShapeDecoration(color: GwColors.primarySoft, shape: CircleBorder()),
                        child: const Icon(Icons.add_rounded, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.primary),
                      ),
                    const SizedBox(width: GwSpacing.xs),
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// A user's active stories, full screen.
class StoryViewerScreen extends ConsumerWidget {
  const StoryViewerScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _StoriesLoader(
        stories: ref.watch(activeStoriesProvider(userId)),
        onRetry: () => ref.invalidate(activeStoriesProvider(userId)),
      );
}

/// A highlight's stories, full screen.
class HighlightViewerScreen extends ConsumerWidget {
  const HighlightViewerScreen({super.key, required this.highlightId});

  final String highlightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _StoriesLoader(
        stories: ref.watch(highlightStoriesProvider(highlightId)),
        onRetry: () => ref.invalidate(highlightStoriesProvider(highlightId)),
        highlightId: highlightId,
      );
}

class _StoriesLoader extends StatelessWidget {
  const _StoriesLoader({required this.stories, required this.onRetry, this.highlightId});

  final AsyncValue<List<Story>> stories;
  final VoidCallback onRetry;
  final String? highlightId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GwColors.media,
        body: SafeArea(
          child: switch (stories) {
            AsyncData(:final value) when value.isEmpty => Theme(
                data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(bodyColor: GwColors.onMedia)),
                child: GwEmptyState(
                  icon: Icons.history_toggle_off,
                  message: 'Burada görebileceğin bir hikaye kalmadı.',
                  actionLabel: 'Kapat',
                  onAction: () => context.canPop() ? context.pop() : context.go(FeedRoutes.home),
                ),
              ),
            // A 9:16 stage, centered on wide screens.
            AsyncData(:final value) => Center(
                child: AspectRatio(aspectRatio: GwMedia.story, child: StoryPlayer(stories: value, highlightId: highlightId)),
              ),
            AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: onRetry),
            _ => const Center(child: CircularProgressIndicator(color: GwColors.onMedia)),
          },
        ),
      );
}

/// Plays stories in order: tap right for next, left for previous, hold to pause.
class StoryPlayer extends ConsumerStatefulWidget {
  const StoryPlayer({super.key, required this.stories, this.highlightId});

  final List<Story> stories;
  final String? highlightId;

  @override
  ConsumerState<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends ConsumerState<StoryPlayer> with SingleTickerProviderStateMixin {
  late final AnimationController _timer = AnimationController(vsync: this)..addStatusListener(_onStatus);
  late int _index = widget.stories.indexWhere((s) => !s.seen).clamp(0, widget.stories.length - 1);
  final _seen = <String>{};

  Story get _story => widget.stories[_index];

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _advanceFrom(_story.id);
  }

  /// The timer and a video's end both finish a story; only the first one advances.
  void _advanceFrom(String storyId) {
    if (mounted && _story.id == storyId) _next();
  }

  void _start() {
    final story = _story;
    _timer
      ..duration = story.displayDuration
      ..forward(from: 0);
    final me = ref.read(currentUserIdProvider);
    if (story.author.id != me && !story.seen && _seen.add(story.id)) {
      ref.read(storyRepositoryProvider).markSeen(story.id).then((_) => ref.invalidate(storyTrayProvider));
    }
  }

  void _close() => context.canPop() ? context.pop() : context.go(FeedRoutes.home);

  void _next() {
    if (_index >= widget.stories.length - 1) return _close();
    setState(() => _index++);
    _start();
  }

  void _previous() {
    if (_index == 0) return _start();
    setState(() => _index--);
    _start();
  }

  Future<T?> _paused<T>(Future<T?> Function() action) async {
    _timer.stop();
    final result = await action();
    if (mounted && _timer.status != AnimationStatus.completed) unawaited(_timer.forward());
    return result;
  }

  Future<void> _showViewers() => _paused(() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => _ViewersSheet(storyId: _story.id),
      ));

  Future<void> _menu() => _paused(() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.highlightId case final highlight?)
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline),
                  title: const Text('Öne çıkandan çıkar'),
                  onTap: () async {
                    Navigator.of(sheet).pop();
                    final result = await ref.read(storyRepositoryProvider).removeFromHighlight(highlight, _story.id);
                    if (!mounted) return;
                    _snack(context, result is Ok ? 'Öne çıkandan çıkarıldı.' : userMessageOf((result as Err).failure));
                    refreshStories(ref);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.bookmark_add_outlined),
                  title: const Text('Öne çıkanlara ekle'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    unawaited(_paused(() => showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => AddToHighlightSheet(storyIds: [_story.id]),
                        )));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: GwColors.error),
                title: const Text('Hikayeyi sil', style: TextStyle(color: GwColors.error)),
                onTap: () async {
                  Navigator.of(sheet).pop();
                  final result = await ref.read(storyRepositoryProvider).delete(_story);
                  if (!mounted) return;
                  _snack(context, result is Ok ? 'Hikaye silindi.' : userMessageOf((result as Err).failure));
                  refreshStories(ref);
                  if (result is Ok) _close();
                },
              ),
            ],
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    final story = _story;
    final isOwner = story.author.id == ref.watch(currentUserIdProvider);
    final textTheme = Theme.of(context).textTheme;
    final onMedia = textTheme.labelLarge?.copyWith(color: GwColors.onMedia);

    return Stack(
      fit: StackFit.expand,
      children: [
        _StoryMedia(story: story, onVideoFinished: () => _advanceFrom(story.id)),
        // Left third goes back, the rest forward; holding pauses.
        Row(
          children: [
            Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _previous, onLongPressStart: (_) => _timer.stop(), onLongPressEnd: (_) => _timer.forward())),
            Expanded(flex: 2, child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _next, onLongPressStart: (_) => _timer.stop(), onLongPressEnd: (_) => _timer.forward())),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [GwColors.mediaScrim, Color(0x00000000)]),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.xs, GwSpacing.xs, GwSpacing.xxs, GwSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < widget.stories.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: AnimatedBuilder(
                              animation: _timer,
                              builder: (_, _) => LinearProgressIndicator(
                                value: i < _index ? 1 : (i == _index ? _timer.value : 0),
                                minHeight: 2,
                                color: GwColors.onMedia,
                                backgroundColor: GwColors.onMedia.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: GwSpacing.xs),
                  Row(
                    children: [
                      GwAvatar(name: story.author.displayName, shape: GwAvatarShape.user, imageUrl: story.author.avatarUrl, size: GwAvatarSize.sm),
                      const SizedBox(width: GwSpacing.xs),
                      Flexible(child: Text(story.author.username, style: onMedia, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: GwSpacing.xs),
                      Text(formatAgoTr(story.createdAt), style: textTheme.labelMedium?.copyWith(color: GwColors.onMedia)),
                      const Spacer(),
                      if (isOwner)
                        IconButton(tooltip: 'Seçenekler', color: GwColors.onMedia, icon: const Icon(Icons.more_horiz), onPressed: _menu),
                      IconButton(tooltip: 'Kapat', color: GwColors.onMedia, icon: const Icon(Icons.close), onPressed: _close),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOwner)
          Positioned(
            left: GwSpacing.md,
            bottom: GwSpacing.md,
            child: TextButton.icon(
              onPressed: _showViewers,
              style: TextButton.styleFrom(foregroundColor: GwColors.onMedia, backgroundColor: GwColors.mediaScrim),
              icon: const Icon(Icons.visibility_outlined, size: GwSpacing.md + GwSpacing.xxs),
              label: const Text('Görenler'),
            ),
          ),
      ],
    );
  }
}

/// Fills the screen when the story is close to 9:16; otherwise fits it over a blurred copy.
class _StoryMedia extends StatelessWidget {
  const _StoryMedia({required this.story, required this.onVideoFinished});

  final Story story;
  final VoidCallback onVideoFinished;

  @override
  Widget build(BuildContext context) {
    final media = story.media;
    final fills = (media.aspectRatio / GwMedia.story - 1).abs() <= GwMedia.storyFitTolerance;
    final fit = fills ? BoxFit.cover : BoxFit.contain;
    final backdrop = media.previewUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!fills && backdrop != null)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: GwMedia.backdropBlur, sigmaY: GwMedia.backdropBlur),
            child: MediaImage(url: backdrop),
          ),
        if (!fills) const ColoredBox(color: GwColors.mediaScrim),
        if (media.kind == MediaKind.image)
          MediaImage(url: media.url, placeholderUrl: media.thumbUrl, fit: fit)
        else
          VideoView(key: ValueKey(story.id), url: media.url, posterUrl: media.posterUrl, autoplay: true, fit: fit, onFinished: onVideoFinished),
      ],
    );
  }
}

class _ViewersSheet extends ConsumerWidget {
  const _ViewersSheet({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewers = ref.watch(storyViewersProvider(storyId));
    final links = ref.read(feedLinksProvider);
    // The sheet's default height limit applies; short lists stay short.
    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: GwSpacing.xxl * 4),
        child: switch (viewers) {
          AsyncData(:final value) when value.isEmpty => GwEmptyState(
              icon: Icons.visibility_outlined,
              message: 'Henüz kimse görmedi. Görenler burada yalnızca sana görünür.',
              actionLabel: 'Yenile',
              onAction: () => ref.invalidate(storyViewersProvider(storyId)),
            ),
          AsyncData(:final value) => ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.xs),
                  child: Text('${value.length} kişi gördü', style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final v in value)
                  ListTile(
                    leading: GwAvatar(name: v.person.displayName, shape: GwAvatarShape.user, imageUrl: v.person.avatarUrl, size: GwAvatarSize.md),
                    title: Text(v.person.username),
                    subtitle: Text(v.person.displayName),
                    trailing: Text(formatAgoTr(v.viewedAt)),
                    onTap: () {
                      Navigator.of(context).pop();
                      links.openProfile(context, v.person.username);
                    },
                  ),
              ],
            ),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(storyViewersProvider(storyId))),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// Picks one photo or video and shares it for 24 hours.
class NewStoryScreen extends ConsumerStatefulWidget {
  const NewStoryScreen({super.key});

  @override
  ConsumerState<NewStoryScreen> createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends ConsumerState<NewStoryScreen> {
  NewMedia? _media;
  CropFrame _frame = const CropFrame();
  bool _picking = false;
  bool _sharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final picked = await pickMedia(multiple: false);
      if (!mounted || picked.isEmpty) return;
      setState(() {
        _media = picked.first;
        _frame = const CropFrame();
        _error = picked.first.kind == MediaKind.video ? picked.first.problem : null;
      });
    } on Object {
      if (mounted) setState(() => _error = 'Seçilen dosya açılamadı. Başka bir fotoğraf ya da video dene.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _share() async {
    final media = _media;
    if (media == null) return;
    setState(() {
      _sharing = true;
      _error = null;
    });
    final NewMedia prepared;
    try {
      prepared = media.kind == MediaKind.video
          ? media
          : await renderPhoto(media, _frame.rectIn(Size(media.width.toDouble(), media.height.toDouble()), GwMedia.story),
              maxSide: GwMedia.storyMaxSide);
    } on Object {
      if (mounted) {
        setState(() {
          _sharing = false;
          _error = 'Fotoğraf hazırlanamadı. Başka bir fotoğraf dene.';
        });
      }
      return;
    }
    final result = await ref.read(storyRepositoryProvider).create(prepared);
    if (!mounted) return;
    setState(() => _sharing = false);
    switch (result) {
      case Ok():
        refreshStories(ref);
        _snack(context, 'Hikayen paylaşıldı. 24 saat görünür.');
        context.pop();
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = _media;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni hikaye'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: GwSpacing.sm),
            child: GwButton(
              label: 'Hikayene ekle',
              isLoading: _sharing,
              onPressed: media == null || (media.kind == MediaKind.video && media.problem != null) ? null : _share,
            ),
          ),
        ],
      ),
      body: GwReadingColumn(
        maxWidth: GwLayout.feedMaxWidth,
        child: ListView(
          padding: const EdgeInsets.all(GwSpacing.md),
          children: [
            if (_error case final error?) ...[GwFormMessage(error), const SizedBox(height: GwSpacing.sm)],
            if (media == null)
              _picking
                  ? const AspectRatio(aspectRatio: GwMedia.story, child: GwSkeleton(height: double.infinity, borderRadius: GwRadius.lgAll))
                  : GwEmptyState(
                      icon: Icons.history_toggle_off,
                      message: 'Hikayen için bir fotoğraf ya da 60 saniyeye kadar video seç.',
                      actionLabel: 'Galeriden seç',
                      onAction: _pick,
                    )
            else ...[
              ClipRRect(
                borderRadius: GwRadius.lgAll,
                child: IgnorePointer(
                  ignoring: _sharing,
                  child: CropEditor(media: media, ratio: GwMedia.story, frame: _frame, onChanged: (f) => setState(() => _frame = f)),
                ),
              ),
              const SizedBox(height: GwSpacing.sm),
              GwButton(label: 'Başka seç', variant: GwButtonVariant.secondary, onPressed: _sharing ? null : _pick),
            ],
          ],
        ),
      ),
    );
  }
}

/// Adds stories to one of the user's highlights or to a new one.
class AddToHighlightSheet extends ConsumerWidget {
  const AddToHighlightSheet({super.key, required this.storyIds});

  final List<String> storyIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final highlights = me == null ? const <Highlight>[] : ref.watch(highlightsProvider(me)).value ?? const <Highlight>[];
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: GwColors.surfaceMuted, child: Icon(Icons.add, color: GwColors.textPrimary)),
            title: const Text('Yeni öne çıkan'),
            onTap: () async {
              final title = await askHighlightTitle(context);
              if (title == null || !context.mounted) return;
              final result = await ref.read(storyRepositoryProvider).createHighlight(title, storyIds);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              _snack(context, result is Ok ? '"$title" oluşturuldu.' : userMessageOf((result as Err).failure));
              refreshStories(ref);
            },
          ),
          for (final h in highlights)
            ListTile(
              leading: _HighlightCover(highlight: h, size: GwSpacing.xxl - GwSpacing.xs),
              title: Text(h.title),
              subtitle: Text('${h.storyCount} hikaye'),
              onTap: () async {
                final result = await ref.read(storyRepositoryProvider).addToHighlight(h.id, storyIds);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _snack(context, result is Ok ? '"${h.title}" öne çıkanına eklendi.' : userMessageOf((result as Err).failure));
                refreshStories(ref);
              },
            ),
        ],
      ),
    );
  }
}

Future<String?> askHighlightTitle(BuildContext context, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: const Text('Öne çıkan başlığı'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 30,
        decoration: const InputDecoration(hintText: 'Ör. Kamp 2026'),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GwButton(
          label: 'Kaydet',
          onPressed: () {
            final t = controller.text.trim();
            if (t.isNotEmpty) Navigator.of(context).pop(t);
          },
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

class _HighlightCover extends StatelessWidget {
  const _HighlightCover({required this.highlight, required this.size});

  final Highlight highlight;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(GwBorders.ringWidth),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: GwColors.border, width: GwBorders.ringWidth)),
        child: ClipOval(
          child: SizedBox.square(
            dimension: size,
            child: highlight.cover == null
                ? const ColoredBox(color: GwColors.surfaceMuted, child: Icon(Icons.collections_bookmark_outlined, color: GwColors.textSecondary))
                : MediaThumb(media: highlight.cover!),
          ),
        ),
      );
}

/// Highlights on a profile; on your own, an "Öne çıkan ekle" chip leads to the archive.
class HighlightsRow extends ConsumerWidget {
  const HighlightsRow({super.key, required this.userId, required this.isOwn});

  final String userId;
  final bool isOwn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightsProvider(userId)).value ?? const <Highlight>[];
    final visible = [for (final h in highlights) if (h.storyCount > 0 || isOwn) h];
    if (visible.isEmpty && !isOwn) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    // Chips like the home story row, so highlights read as a shelf, not a row of circles.
    Widget item({required Widget cover, required String label, required VoidCallback onTap, VoidCallback? onLongPress}) => Padding(
          padding: const EdgeInsets.only(right: GwSpacing.xs),
          child: Center(
            child: Material(
              color: GwColors.background,
              shape: const StadiumBorder(side: GwBorders.hairline),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(GwSpacing.xxs, GwSpacing.xxs, GwSpacing.md, GwSpacing.xxs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      cover,
                      const SizedBox(width: GwSpacing.xs),
                      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
    return SizedBox(
      height: GwSpacing.xxl + GwSpacing.md,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
        children: [
          for (final h in visible)
            item(
              cover: _HighlightCover(highlight: h, size: GwAvatarSize.sm.dimension),
              label: h.title,
              onTap: () => h.storyCount == 0 ? context.push(FeedRoutes.archive) : context.push(FeedRoutes.highlight(h.id)),
              onLongPress: isOwn ? () => _manage(context, ref, h) : null,
            ),
          if (isOwn)
            item(
              cover: Container(
                width: GwAvatarSize.sm.dimension + GwBorders.ringWidth * 4,
                height: GwAvatarSize.sm.dimension + GwBorders.ringWidth * 4,
                decoration: const ShapeDecoration(color: GwColors.primarySoft, shape: CircleBorder()),
                child: const Icon(Icons.add_rounded, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.primary),
              ),
              label: 'Öne çıkan ekle',
              onTap: () => context.push(FeedRoutes.archive),
            ),
        ],
      ),
    );
  }

  Future<void> _manage(BuildContext context, WidgetRef ref, Highlight h) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Başlığı değiştir'),
                onTap: () async {
                  Navigator.of(sheet).pop();
                  final title = await askHighlightTitle(context, initial: h.title);
                  if (title == null || !context.mounted) return;
                  final result = await ref.read(storyRepositoryProvider).renameHighlight(h.id, title);
                  if (result case Err(:final failure) when context.mounted) _snack(context, failure.userMessage);
                  refreshStories(ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: GwColors.error),
                title: const Text('Öne çıkanı sil', style: TextStyle(color: GwColors.error)),
                subtitle: const Text('Hikayeler arşivinde kalır.'),
                onTap: () async {
                  Navigator.of(sheet).pop();
                  final result = await ref.read(storyRepositoryProvider).deleteHighlight(h.id);
                  if (result case Err(:final failure) when context.mounted) _snack(context, failure.userMessage);
                  refreshStories(ref);
                },
              ),
            ],
          ),
        ),
      );
}

/// All of your stories (also expired); select some to make a highlight.
class StoryArchiveScreen extends ConsumerStatefulWidget {
  const StoryArchiveScreen({super.key});

  @override
  ConsumerState<StoryArchiveScreen> createState() => _StoryArchiveScreenState();
}

class _StoryArchiveScreenState extends ConsumerState<StoryArchiveScreen> {
  final _selected = <String>{};

  Future<void> _addSelected() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => AddToHighlightSheet(storyIds: _selected.toList()),
    );
    if (mounted) setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    final archive = ref.watch(storyArchiveProvider);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(_selected.isEmpty ? 'Hikaye arşivi' : '${_selected.length} hikaye seçildi'),
        actions: [
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: GwSpacing.sm),
              child: GwButton(label: 'Öne çıkar', onPressed: _addSelected),
            ),
        ],
      ),
      body: GwReadingColumn(
        child: switch (archive) {
          AsyncData(:final value) when value.isEmpty => GwEmptyState(
              icon: Icons.history_toggle_off,
              message: 'Paylaştığın hikayeler 24 saat sonra burada, yalnızca sana görünür şekilde saklanır.',
              actionLabel: 'Hikaye paylaş',
              onAction: () => context.push(FeedRoutes.newStory),
            ),
          AsyncData(:final value) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(GwSpacing.md),
                  child: Text('Öne çıkan oluşturmak ya da var olana eklemek için hikayeleri seç.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: GwMedia.gridColumns,
                      childAspectRatio: GwMedia.story,
                      mainAxisSpacing: GwMedia.gridGap,
                      crossAxisSpacing: GwMedia.gridGap,
                    ),
                    itemCount: value.length,
                    itemBuilder: (context, i) {
                      final s = value[i];
                      final selected = _selected.contains(s.id);
                      return Semantics(
                        selected: selected,
                        button: true,
                        label: 'Hikaye, ${formatDateTr(s.createdAt)}',
                        child: InkWell(
                          onTap: () => setState(() => selected ? _selected.remove(s.id) : _selected.add(s.id)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              MediaThumb(media: s.media),
                              Positioned(
                                left: GwSpacing.xxs,
                                bottom: GwSpacing.xxs,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xxs, vertical: 2),
                                  decoration: const BoxDecoration(color: GwColors.mediaScrim, borderRadius: GwRadius.smAll),
                                  child: Text(
                                    s.isActive(now) ? 'Yayında' : formatDateTr(s.createdAt),
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GwColors.onMedia),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: GwSpacing.xxs,
                                top: GwSpacing.xxs,
                                child: Icon(
                                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                  color: selected ? GwColors.primary : GwColors.onMedia,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(storyArchiveProvider)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
