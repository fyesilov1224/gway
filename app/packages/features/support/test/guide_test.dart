import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:support/src/domain/guide.dart';
import 'package:support/src/domain/guide_content.dart';
import 'package:support/support.dart';

Widget _app() => MaterialApp.router(
      theme: GwTheme.light(),
      routerConfig: GoRouter(
        initialLocation: SupportRoutes.guide,
        routes: [
          GoRoute(path: SupportRoutes.guide, builder: (_, _) => const UserGuideScreen()),
          GoRoute(
            path: '${SupportRoutes.guide}/:id',
            builder: (_, state) => GuideChapterScreen(
              chapterId: state.pathParameters['id']!,
              openTopic: int.tryParse(state.uri.queryParameters['topic'] ?? ''),
            ),
          ),
          GoRoute(path: '/support/new', builder: (_, _) => const Scaffold(body: Text('Yeni destek mesajı'))),
        ],
      ),
    );

void main() {
  test('chapters have unique ids and no empty topics', () {
    final ids = guideChapters.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final c in guideChapters) {
      expect(c.topics, isNotEmpty, reason: c.id);
      for (final t in c.topics) {
        expect(t.intro != null || t.steps.isNotEmpty || t.notes.isNotEmpty, isTrue, reason: '${c.id}: ${t.title}');
      }
    }
  });

  test('every language has its own guide with the same chapters, topics, steps and notes', () {
    final source = guideIn(AppLanguage.tr);
    for (final language in AppLanguage.values.where((l) => l != AppLanguage.tr)) {
      final guide = guideIn(language);
      expect(identical(guide, source), isFalse, reason: '${language.code} has no translation');
      expect(guide.map((c) => c.id), source.map((c) => c.id), reason: language.code);
      for (final (i, chapter) in guide.indexed) {
        final original = source[i];
        expect(chapter.topics.length, original.topics.length, reason: '${language.code} ${chapter.id}');
        for (final (j, topic) in chapter.topics.indexed) {
          final o = original.topics[j];
          final where = '${language.code} ${chapter.id} #$j';
          expect(topic.steps.length, o.steps.length, reason: '$where steps');
          expect(topic.notes.length, o.notes.length, reason: '$where notes');
          expect(topic.intro == null, o.intro == null, reason: '$where intro');
          expect(topic.tip == null, o.tip == null, reason: '$where tip');
        }
      }
    }
  });

  test('search folds accents in other languages', () {
    expect(foldForSearch('Réseau Größe Ñandú'), 'reseau grose nandu');
    expect(searchGuide(guideIn(AppLanguage.en), 'password').first.chapter.id, 'start');
  });

  test('search ignores Turkish marks and case, titles come first', () {
    expect(foldForSearch('Şifremi UNUTTUM İzin'), 'sifremi unuttum izin');
    final hits = searchGuide(guideChapters, 'sifre');
    expect(hits, isNotEmpty);
    expect(hits.first.chapter.topics[hits.first.topic].title, 'Şifremi unuttum');
    expect(searchGuide(guideChapters, 'davet baglantisi').map((h) => h.chapter.topics[h.topic].title), contains('Davet bağlantısı'));
    expect(searchGuide(guideChapters, 'zzqx'), isEmpty);
  });

  testWidgets('lists chapters, searches and opens the topic expanded', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('İlk adımlar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'canli yayindayken');
    await tester.pumpAndSettle();
    expect(find.text('Yayındayken uygulamada gezinmek'), findsOneWidget);

    await tester.tap(find.text('Yayındayken uygulamada gezinmek'));
    await tester.pumpAndSettle();
    expect(find.text('Canlı sesli yayın'), findsOneWidget); // app bar
    expect(find.textContaining('"Canlı yayındasın" şeridi'), findsOneWidget); // open topic body
  });

  testWidgets('nothing found offers support', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzqx');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Destek ekibine yaz'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni destek mesajı'), findsOneWidget);
  });
}
