import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

import 'l10n/social_app_l10n.dart';

export 'l10n/social_app_l10n.dart' show SocialAppL10n;

/// This app's own texts in the app language (docs/ARCHITECTURE.md §11).
SocialAppL10n get socialAppL10n => lookupSocialAppL10n(currentAppLocale);

/// Flutter's own widget texts and core; packages read their texts through their `<package>L10n` getters.
const List<LocalizationsDelegate<Object>> appLocalizationsDelegates = [
  ...coreLocalizationsDelegates,
];

/// Rebuilds every widget once, so texts read outside `Localizations.of` (every `<package>L10n` getter)
/// follow a language change too.
void rebuildAll(BuildContext context) {
  void mark(Element e) {
    e.markNeedsBuild();
    e.visitChildren(mark);
  }

  (context as Element).visitChildren(mark);
}
