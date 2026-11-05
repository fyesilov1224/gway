import 'package:core/core.dart';

import 'l10n/identity_l10n.dart';

export 'l10n/identity_l10n.dart' show IdentityL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
IdentityL10n get identityL10n => lookupIdentityL10n(currentAppLocale);
