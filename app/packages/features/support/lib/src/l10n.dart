import 'package:core/core.dart';

import 'l10n/support_l10n.dart';

export 'l10n/support_l10n.dart' show SupportL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
SupportL10n get supportL10n => lookupSupportL10n(currentAppLocale);
