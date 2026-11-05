import 'package:core/core.dart';

import 'l10n/billing_l10n.dart';

export 'l10n/billing_l10n.dart' show BillingL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
BillingL10n get billingL10n => lookupBillingL10n(currentAppLocale);
