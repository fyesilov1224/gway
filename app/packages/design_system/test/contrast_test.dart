import 'package:design_system/design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Every text/background pair the design system uses. WCAG AA, normal text.
  const pairs = <String, (Color, Color)>{
    'textPrimary on background': (GwColors.textPrimary, GwColors.background),
    'textPrimary on backdropLilac': (GwColors.textPrimary, GwColors.backdropLilac),
    'textPrimary on backdropPink': (GwColors.textPrimary, GwColors.backdropPink),
    'textSecondary on backdropLilac': (GwColors.textSecondary, GwColors.backdropLilac),
    'textSecondary on backdropPink': (GwColors.textSecondary, GwColors.backdropPink),
    'primary on backdropLilac': (GwColors.primary, GwColors.backdropLilac),
    'textPrimary on surface': (GwColors.textPrimary, GwColors.surface),
    'textPrimary on surfaceMuted': (
      GwColors.textPrimary,
      GwColors.surfaceMuted,
    ),
    'textPrimary on primarySoft': (GwColors.textPrimary, GwColors.primarySoft),
    'textPrimary on secondarySoft': (
      GwColors.textPrimary,
      GwColors.secondarySoft,
    ),
    'textSecondary on background': (
      GwColors.textSecondary,
      GwColors.background,
    ),
    'textSecondary on surface': (GwColors.textSecondary, GwColors.surface),
    'textSecondary on surfaceMuted': (
      GwColors.textSecondary,
      GwColors.surfaceMuted,
    ),
    'onPrimary on primary': (GwColors.onPrimary, GwColors.primary),
    'onPrimary on secondary': (GwColors.onPrimary, GwColors.secondary),
    'primary on background': (GwColors.primary, GwColors.background),
    'primary on primarySoft': (GwColors.primary, GwColors.primarySoft),
    'secondary on background': (GwColors.secondary, GwColors.background),
    'error on background': (GwColors.error, GwColors.background),
    'error on errorSoft': (GwColors.error, GwColors.errorSoft),
    'warning on background': (GwColors.warning, GwColors.background),
    'warning on warningSoft': (GwColors.warning, GwColors.warningSoft),
    'success on background': (GwColors.success, GwColors.background),
    'success on successSoft': (GwColors.success, GwColors.successSoft),
    'like on background': (GwColors.like, GwColors.background),
    'onMedia on media': (GwColors.onMedia, GwColors.media),
  };

  for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
    test('$name meets WCAG AA (4.5:1)', () {
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
    });
  }

  test('secondary on secondarySoft is below AA and must not be used', () {
    // Documented in docs/DESIGN.md §1; guards against silently "fixing" it.
    expect(contrast(GwColors.secondary, GwColors.secondarySoft), lessThan(4.5));
  });
}
