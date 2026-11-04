import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// Every package's texts (docs/ARCHITECTURE.md §11). A package joins here when its ARB files exist.
const List<LocalizationsDelegate<Object>> appLocalizationsDelegates = [
  ...coreLocalizationsDelegates,
];

/// Rebuilds every widget once, so texts read outside `Localizations.of` (domain labels, failure messages)
/// follow a language change too.
void rebuildAll(BuildContext context) {
  void mark(Element e) {
    e.markNeedsBuild();
    e.visitChildren(mark);
  }

  (context as Element).visitChildren(mark);
}
