import 'package:core/core.dart';

import 'l10n/feed_l10n.dart';

export 'l10n/feed_l10n.dart' show FeedL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
FeedL10n get feedL10n => lookupFeedL10n(currentAppLocale);
