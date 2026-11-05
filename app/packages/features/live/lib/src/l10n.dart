import 'package:core/core.dart';

import 'l10n/live_l10n.dart';

export 'l10n/live_l10n.dart' show LiveL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
LiveL10n get liveL10n => lookupLiveL10n(currentAppLocale);
