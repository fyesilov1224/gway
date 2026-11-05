import 'package:core/core.dart';

import 'guide.dart';
import 'guide/ar.dart';
import 'guide/az.dart';
import 'guide/de.dart';
import 'guide/en.dart';
import 'guide/es.dart';
import 'guide/fr.dart';
import 'guide/it.dart';
import 'guide/nl.dart';
import 'guide/pt.dart';
import 'guide/ru.dart';
import 'guide/tr.dart';
import 'guide/uk.dart';

/// The guide in the app language (docs/ARCHITECTURE.md §11, Kullanma kılavuzu). Every language has the same
/// chapters, topics, steps and notes; test/guide_test.dart checks it.
List<GuideChapter> get guideChapters => guideIn(currentAppLanguage);

List<GuideChapter> guideIn(AppLanguage language) => switch (language) {
      AppLanguage.ar => guideAr,
      AppLanguage.az => guideAz,
      AppLanguage.de => guideDe,
      AppLanguage.en => guideEn,
      AppLanguage.es => guideEs,
      AppLanguage.fr => guideFr,
      AppLanguage.it => guideIt,
      AppLanguage.nl => guideNl,
      AppLanguage.pt => guidePt,
      AppLanguage.ru => guideRu,
      AppLanguage.uk => guideUk,
      AppLanguage.tr => guideTr,
    };
