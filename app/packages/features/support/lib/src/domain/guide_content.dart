import 'package:core/core.dart';

import 'guide.dart';
import 'guide/tr.dart';

/// The guide in the app language (docs/ARCHITECTURE.md §11, Kullanma kılavuzu). Every language has the same
/// chapters, topics, steps and notes; test/guide_test.dart checks it.
List<GuideChapter> get guideChapters => guideIn(currentAppLanguage);

List<GuideChapter> guideIn(AppLanguage language) => switch (language) {
      _ => guideTr,
    };
