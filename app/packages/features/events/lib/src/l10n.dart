import 'package:core/core.dart';

import 'l10n/events_l10n.dart';

export 'l10n/events_l10n.dart' show EventsL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
EventsL10n get eventsL10n => lookupEventsL10n(currentAppLocale);
