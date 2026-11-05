import 'package:core/core.dart';

import 'l10n/moderation_l10n.dart';

export 'l10n/moderation_l10n.dart' show ModerationL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
ModerationL10n get moderationL10n => lookupModerationL10n(currentAppLocale);
