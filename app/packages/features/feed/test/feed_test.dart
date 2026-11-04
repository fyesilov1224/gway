import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feed/feed.dart';
import 'package:feed/src/data/feed_repository_impl.dart';
import 'package:feed/src/data/image_processing.dart';
import 'package:feed/src/domain/media_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

PostMedia _image(int w, int h) => PostMedia(kind: MediaKind.image, url: 'http://x/a.png', width: w, height: h);

Post _post({bool liked = false, int? likes = 3, bool canManage = false}) => Post(
      id: 'p1',
      caption: 'Kamp #Doga @elif.kosar',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      media: [_image(1080, 1350)],
      author: const PostAuthor(id: 'u2', username: 'ayse', displayName: 'Ayşe'),
      likeCount: likes,
      commentCount: 2,
      liked: liked,
      canManage: canManage,
    );

NewMedia _new({MediaKind kind = MediaKind.image, String name = 'a.jpg', int bytes = 10, Duration? duration}) =>
    NewMedia(kind: kind, bytes: Uint8List(bytes), fileName: name, width: 10, height: 10, duration: duration);

/// Records like calls; fails them when [failLikes] is set.
class _FakeFeed implements FeedRepository {
  bool failLikes = false;
  final likes = <bool>[];
  final reactions = <String?>[];

  @override
  Future<Result<void>> setReaction(String postId, String? emoji) async {
    reactions.add(emoji);
    return const Ok(null);
  }

  @override
  Future<Result<void>> setLiked(String postId, bool liked) async {
    likes.add(liked);
    return failLikes ? const Err(RuleFailure('feed.like_rate_limited', 'Çok fazla beğeni.')) : const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child, _FakeFeed repo) => ProviderScope(
      overrides: [
        feedRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue('u1'),
        feedLinksProvider.overrideWithValue(FeedLinks(openProfile: (_, _) {}, openGroup: (_, _) {})),
      ],
      child: MaterialApp.router(
        theme: GwTheme.light(),
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, _) => Scaffold(body: SingleChildScrollView(child: child))),
          GoRoute(path: '/p/:id/comments', builder: (_, _) => const Text('comments')),
        ]),
      ),
    );

void main() {
  group('rich text', () {
    test('finds tags and mentions as the database does', () {
      final parts = parseRichText('Kamp #DoğaYürüyüşü ile @Elif.Kosar. mail@ornek.com');
      expect(parts.whereType<HashtagPart>().single.tag, 'doğayürüyüşü');
      expect(parts.whereType<MentionPart>().single.username, 'elif.kosar');
      expect(parts.map((p) => p.text).join(), 'Kamp #DoğaYürüyüşü ile @Elif.Kosar. mail@ornek.com');
    });

    test('a # inside a word is not a tag', () {
      expect(parseRichText('C#dili').whereType<HashtagPart>(), isEmpty);
    });
  });

  test('the feed keeps the first media between 4:5 and 1.91:1', () {
    expect(feedAspectRatio([_image(1000, 3000)]), 4 / 5);
    expect(feedAspectRatio([_image(3000, 1000)]), 1.91);
    expect(feedAspectRatio([_image(1000, 1000)]), 1);
  });

  test('replies are grouped under their comment', () {
    Comment c(String id, {String? parent}) => Comment(
          id: id,
          postId: 'p',
          author: const PostAuthor(id: 'u', username: 'u', displayName: 'U'),
          body: id,
          createdAt: DateTime(2026),
          parentId: parent,
        );
    final threads = threadComments([c('a'), c('b'), c('a1', parent: 'a'), c('a2', parent: 'a')]);
    expect(threads.map((t) => t.id), ['a', 'b']);
    expect(threads.first.replies.map((r) => r.id), ['a1', 'a2']);
  });

  group('new post rules (same as the API)', () {
    test('needs 1–10 media of allowed types and sizes', () {
      expect(const NewPost(media: []).problem, isNotNull);
      expect(NewPost(media: List.generate(11, (_) => _new())).problem, isNotNull);
      expect(NewPost(media: [_new(name: 'a.heic')]).problem, contains('JPEG'));
      expect(NewPost(media: [_new(bytes: NewMedia.maxImageBytes + 1)]).problem, contains('10 MB'));
      expect(NewPost(media: [_new(kind: MediaKind.video, name: 'v.mp4', duration: const Duration(seconds: 61))]).problem,
          contains('60 saniye'));
      expect(NewPost(media: [_new(), _new(kind: MediaKind.video, name: 'v.mov', duration: const Duration(seconds: 59))]).problem,
          isNull);
    });

    test('limits the caption and its tags', () {
      expect(NewPost.captionProblem('a' * 2201), contains('2.200'));
      expect(NewPost.captionProblem(List.generate(31, (i) => '#t$i').join(' ')), contains('30 etiket'));
      expect(NewPost.captionProblem('Merhaba #doga'), isNull);
    });
  });

  test('database rule codes become Turkish messages', () {
    expect(failureFromFeed(const PostgrestException(message: 'comments_disabled', code: 'P0001')).userMessage,
        'Bu gönderide yorumlar kapalı.');
    expect(failureFromFeed(const StorageException('too big', statusCode: '413')).userMessage, contains('50 MB'));
    expect(failureFromFeed(const PostgrestException(message: 'something internal', code: 'P0001')), isA<UnexpectedFailure>());
  });

  test('relative times are short and Turkish', () {
    final now = DateTime(2026, 10, 19, 12);
    expect(formatAgo(now.subtract(const Duration(seconds: 20)), now: now), 'şimdi');
    expect(formatAgo(now.subtract(const Duration(minutes: 5)), now: now), '5 dk');
    expect(formatAgo(now.subtract(const Duration(hours: 3)), now: now), '3 sa');
    expect(formatAgo(now.subtract(const Duration(days: 2)), now: now), '2 g');
  });

  group('framing and sizing (docs/DESIGN.md §7)', () {
    const photo = Size(3000, 2000);

    test('each aspect gives its frame; the original is kept between 4:5 and 1.91:1', () {
      expect(MediaAspect.original.ratioFor(photo), 1.5);
      expect(MediaAspect.original.ratioFor(const Size(1000, 3000)), GwMedia.portrait);
      expect(MediaAspect.square.ratioFor(photo), 1);
      expect(MediaAspect.portrait.ratioFor(photo), 0.8);
      expect(MediaAspect.landscape.ratioFor(photo), 1.91);
    });

    test('the frame covers the photo at zoom 1 and stays inside it', () {
      expect(const CropFrame().rectIn(photo, 1), const Rect.fromLTWH(500, 0, 2000, 2000));
      expect(const CropFrame().rectIn(photo, 0.8), const Rect.fromLTWH(700, 0, 1600, 2000));
      expect(const CropFrame().rectIn(photo, 1.91).width, 3000);
      // Zoomed in and pushed past the corner: clamped to the edge.
      final r = const CropFrame(zoom: 2, center: Offset(1, 1)).rectIn(photo, 1);
      expect(r, const Rect.fromLTWH(2000, 1000, 1000, 1000));
    });

    test('dragging moves the frame the other way, at the frame scale', () {
      final f = const CropFrame().panned(const Offset(100, 0), photo, 1, 400);
      // 400 px frame shows 2000 source px: 100 px drag = 500 source px to the left.
      expect(f.rectIn(photo, 1).left, 0);
      expect(const CropFrame().zoomed(10, photo, 1).zoom, GwMedia.maxZoom);
    });

    test('uploads keep the ratio within the size limit and never upscale', () {
      expect(outputSize(const Size(2000, 2500), GwMedia.uploadMaxSide), const Size(1152, 1440));
      expect(outputSize(const Size(2000, 2500), GwMedia.thumbMaxSide), const Size(384, 480));
      expect(outputSize(const Size(1080, 1920), GwMedia.storyMaxSide), const Size(1080, 1920));
      expect(outputSize(const Size(600, 600), GwMedia.uploadMaxSide), const Size(600, 600));
    });

    test('images decode at their on-screen pixel width', () {
      expect(gwCacheWidth(130, 3), 390);
      expect(gwCacheWidth(double.infinity, 2), isNull);
    });

    test('grid tiles are 4:5 portraits in three columns', () {
      expect(postGridDelegate.childAspectRatio, GwMedia.gridTile);
      expect(postGridDelegate.crossAxisCount, GwMedia.gridColumns);
    });

    test('a photo is cropped and resized on the device as JPEG with a small copy', () async {
      final source = img.encodePng(img.Image(width: 3000, height: 2000));
      final picked = NewMedia(kind: MediaKind.image, bytes: source, fileName: 'a.png', width: 3000, height: 2000);
      final out = await renderPhoto(picked, const CropFrame().rectIn(photo, GwMedia.portrait),
          maxSide: GwMedia.uploadMaxSide, thumbSide: GwMedia.thumbMaxSide);
      expect((out.width, out.height), (1152, 1440));
      expect(out.contentType, 'image/jpeg');
      expect(img.decodeJpg(out.bytes)!.width, 1152);
      expect(img.decodeJpg(out.thumb!)!.height, GwMedia.thumbMaxSide);
    });
  });

  group('post card', () {
    setUp(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view
        ..physicalSize = const Size(390, 1000)
        ..devicePixelRatio = 1;
      addTearDown(view.reset);
    });

    // Counts are read as "3 beğenme" by screen readers; the card shows the number next to the icon.
    testWidgets('liking shows at once and the count follows', (tester) async {
      final repo = _FakeFeed();
      await tester.pumpWidget(_app(PostCard(post: _post()), repo));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('3 beğenme'), findsOneWidget);

      await tester.tap(find.byTooltip('Beğen'));
      await tester.pumpAndSettle();

      expect(repo.likes, [true]);
      expect(find.bySemanticsLabel('4 beğenme'), findsOneWidget);
      expect(find.byTooltip('Beğenmekten vazgeç'), findsOneWidget);
    });

    testWidgets('an emoji reaction counts at once, changes, and is taken back with a second tap', (tester) async {
      final repo = _FakeFeed();
      final post = Post(
        id: 'p1',
        caption: '',
        createdAt: DateTime.now(),
        media: [_image(1080, 1350)],
        author: const PostAuthor(id: 'u2', username: 'ayse', displayName: 'Ayşe'),
        canComment: false,
        reactions: const {'🔥': 2},
      );
      await tester.pumpWidget(_app(PostCard(post: post), repo));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('🔥 tepkisi, 2'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('🔥 tepkisi, 2'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('🔥 tepkisi, 3'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('😂 tepkisi, 0'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('🔥 tepkisi, 2'), findsOneWidget);
      expect(find.bySemanticsLabel('😂 tepkisi, 1'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('😂 tepkisi, 1'));
      await tester.pumpAndSettle();
      expect(repo.reactions, ['🔥', '😂', null]);
    });

    testWidgets('a refused like is rolled back with the reason', (tester) async {
      final repo = _FakeFeed()..failLikes = true;
      await tester.pumpWidget(_app(PostCard(post: _post()), repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Beğen'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('3 beğenme'), findsOneWidget);
      expect(find.text('Çok fazla beğeni.'), findsOneWidget);
    });

    testWidgets('a hidden like count shows nothing to others; edit is only for managers', (tester) async {
      await tester.pumpWidget(_app(PostCard(post: _post(likes: null)), _FakeFeed()));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('beğenme')), findsNothing);

      await tester.tap(find.byTooltip('Diğer seçenekler'));
      await tester.pumpAndSettle();
      expect(find.text('Bağlantıyı kopyala'), findsOneWidget);
      expect(find.text('Düzenle'), findsNothing);
    });

    testWidgets('lays out at 130% text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(_app(PostCard(post: _post(canManage: true)), _FakeFeed()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('2 yorum'), findsOneWidget);
    });
  });
}
