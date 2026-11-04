import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/core_l10n.dart';
import 'language.dart';

/// Core texts in the current language, for code without a `BuildContext`.
CoreL10n get coreL10n => lookupCoreL10n(currentAppLocale);

extension CoreL10nContext on BuildContext {
  CoreL10n get coreL10n => CoreL10n.of(this);
}

/// Flutter's own widget texts plus core; each app adds its feature delegates.
const List<LocalizationsDelegate<Object>> coreLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  CoreL10n.delegate,
];

/// The display name of a category (`public.categories.slug`); unknown slugs keep the stored name.
String categoryLabel(String slug, {String? fallback}) {
  final l = coreL10n;
  return switch (slug) {
        'music' => l.categoryMusic,
        'hiking' => l.categoryHiking,
        'running' => l.categoryRunning,
        'cycling' => l.categoryCycling,
        'nature' => l.categoryNature,
        'sports' => l.categorySports,
        'art' => l.categoryArt,
        'photography' => l.categoryPhotography,
        'dance' => l.categoryDance,
        'books' => l.categoryBooks,
        'games' => l.categoryGames,
        'travel' => l.categoryTravel,
        'food' => l.categoryFood,
        'technology' => l.categoryTechnology,
        'volunteering' => l.categoryVolunteering,
        'motorcycle' => l.categoryMotorcycle,
        'camping' => l.categoryCamping,
        'chess' => l.categoryChess,
        _ => null,
      } ??
      fallback ??
      slug;
}
