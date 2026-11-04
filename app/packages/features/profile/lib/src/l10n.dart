import 'package:core/core.dart';

import 'l10n/profile_l10n.dart';

export 'l10n/profile_l10n.dart' show ProfileL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
ProfileL10n get profileL10n => lookupProfileL10n(currentAppLocale);
