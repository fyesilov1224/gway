import 'package:core/core.dart';

import 'l10n/groups_l10n.dart';

export 'l10n/groups_l10n.dart' show GroupsL10n;

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
GroupsL10n get groupsL10n => lookupGroupsL10n(currentAppLocale);
