import 'package:core/core.dart';

import 'l10n/notifications_l10n.dart';

export 'l10n/notifications_l10n.dart' show NotificationsL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
NotificationsL10n get notificationsL10n => lookupNotificationsL10n(currentAppLocale);
