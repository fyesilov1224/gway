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
    'textPrimary on background': (GxColors.textPrimary, GxColors.background),
    'textPrimary on backdropLilac': (GxColors.textPrimary, GxColors.backdropLilac),
    'textPrimary on backdropPink': (GxColors.textPrimary, GxColors.backdropPink),
    'textSecondary on backdropLilac': (GxColors.textSecondary, GxColors.backdropLilac),
    'textSecondary on backdropPink': (GxColors.textSecondary, GxColors.backdropPink),
    'primary on backdropLilac': (GxColors.primary, GxColors.backdropLilac),
    'textPrimary on surface': (GxColors.textPrimary, GxColors.surface),
    'textPrimary on surfaceMuted': (
      GxColors.textPrimary,
      GxColors.surfaceMuted,
    ),
    'textPrimary on primarySoft': (GxColors.textPrimary, GxColors.primarySoft),
    'textPrimary on secondarySoft': (
      GxColors.textPrimary,
      GxColors.secondarySoft,
    ),
    'textSecondary on background': (
      GxColors.textSecondary,
      GxColors.background,
    ),
    'textSecondary on surface': (GxColors.textSecondary, GxColors.surface),
    'textSecondary on surfaceMuted': (
      GxColors.textSecondary,
      GxColors.surfaceMuted,
    ),
    'onPrimary on primary': (GxColors.onPrimary, GxColors.primary),
    'onPrimary on secondary': (GxColors.onPrimary, GxColors.secondary),
    'primary on background': (GxColors.primary, GxColors.background),
    'primary on primarySoft': (GxColors.primary, GxColors.primarySoft),
    'secondary on background': (GxColors.secondary, GxColors.background),
    'error on background': (GxColors.error, GxColors.background),
    'error on errorSoft': (GxColors.error, GxColors.errorSoft),
    'warning on background': (GxColors.warning, GxColors.background),
    'warning on warningSoft': (GxColors.warning, GxColors.warningSoft),
    'success on background': (GxColors.success, GxColors.background),
    'success on successSoft': (GxColors.success, GxColors.successSoft),
    'like on background': (GxColors.like, GxColors.background),
    'onMedia on media': (GxColors.onMedia, GxColors.media),
  };

  for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
    test('$name meets WCAG AA (4.5:1)', () {
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
    });
  }

  test('secondary on secondarySoft is below AA and must not be used', () {
    // Documented in docs/DESIGN.md §1; guards against silently "fixing" it.
    expect(contrast(GxColors.secondary, GxColors.secondarySoft), lessThan(4.5));
  });
}
