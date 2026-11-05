import 'package:core/core.dart';

import 'l10n/messaging_l10n.dart';

export 'l10n/messaging_l10n.dart' show MessagingL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
MessagingL10n get messagingL10n => lookupMessagingL10n(currentAppLocale);
