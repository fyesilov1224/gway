import 'package:core/core.dart';

import 'l10n/matching_l10n.dart';

export 'l10n/matching_l10n.dart' show MatchingL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
MatchingL10n get matchingL10n => lookupMatchingL10n(currentAppLocale);
