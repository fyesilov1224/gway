/// The in-app user guide (docs/ARCHITECTURE.md §7b): chapters of topics, all text, no server.
class GuideChapter {
  const GuideChapter({required this.id, required this.title, required this.summary, required this.topics});

  /// Stable path segment: `/support/guide/<id>`.
  final String id;
  final String title;
  final String summary;
  final List<GuideTopic> topics;
}

/// One question the user may have, answered with an optional intro, numbered steps, notes and a tip.
class GuideTopic {
  const GuideTopic(this.title, {this.intro, this.steps = const [], this.notes = const [], this.tip});

  final String title;
  final String? intro;
  final List<String> steps;
  final List<String> notes;
  final String? tip;

  Iterable<String> get _texts => [title, ?intro, ...steps, ...notes, ?tip];
}

typedef GuideHit = ({GuideChapter chapter, int topic});

/// Lower case without Turkish marks, so "kilavuz" finds "Kılavuz" and "sifre" finds "şifre".
String foldForSearch(String text) {
  const from = 'çğıöşüâîû';
  const to = 'cgiosuaiu';
  final lower = text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
  final out = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    out.write(i < 0 ? ch : to[i]);
  }
  return out.toString();
}

/// Topics containing every word of [query]; titles that match come first.
List<GuideHit> searchGuide(List<GuideChapter> chapters, String query) {
  final words = foldForSearch(query).split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
  if (words.isEmpty) return const [];
  final inTitle = <GuideHit>[];
  final inText = <GuideHit>[];
  for (final chapter in chapters) {
    for (final (i, topic) in chapter.topics.indexed) {
      final title = foldForSearch('${chapter.title} ${topic.title}');
      final all = foldForSearch(topic._texts.join(' '));
      if (!words.every(all.contains) && !words.every(title.contains)) continue;
      (words.every(title.contains) ? inTitle : inText).add((chapter: chapter, topic: i));
    }
  }
  return [...inTitle, ...inText];
}
