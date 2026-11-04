import 'package:core/core.dart';

import 'l10n/design_system_l10n.dart';

export 'l10n/design_system_l10n.dart' show DesignSystemL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
DesignSystemL10n get designSystemL10n => lookupDesignSystemL10n(currentAppLocale);
