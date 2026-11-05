import 'package:core/core.dart';

import 'l10n/games_l10n.dart';

export 'l10n/games_l10n.dart' show GamesL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
GamesL10n get gamesL10n => lookupGamesL10n(currentAppLocale);
