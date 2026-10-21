import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography tokens, Plus Jakarta Sans. See docs/DESIGN.md §2.
abstract final class GxTypography {
  static const String fontFamily = 'PlusJakartaSans';
  static const String fontPackage = 'design_system';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: _Style(32, 40, FontWeight.w700),
        headlineMedium: _Style(24, 32, FontWeight.w700),
        titleLarge: _Style(20, 28, FontWeight.w600),
        titleMedium: _Style(16, 24, FontWeight.w600),
        bodyLarge: _Style(16, 24, FontWeight.w400),
        bodyMedium: _Style(14, 20, FontWeight.w400),
        labelLarge: _Style(14, 20, FontWeight.w600),
        labelMedium: _Style(12, 16, FontWeight.w500),
      );
}

class _Style extends TextStyle {
  const _Style(double size, double lineHeight, FontWeight weight)
      : super(
          fontFamily: GxTypography.fontFamily,
          package: GxTypography.fontPackage,
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          color: GxColors.textPrimary,
          letterSpacing: 0,
        );
}
