import 'package:flutter/material.dart';

import 'tokens/borders.dart';
import 'tokens/colors.dart';
import 'tokens/radius.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// The single source of [ThemeData] for every GrupX app.
abstract final class GxTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: GxColors.primary,
      onPrimary: GxColors.onPrimary,
      primaryContainer: GxColors.primarySoft,
      onPrimaryContainer: GxColors.textPrimary,
      secondary: GxColors.secondary,
      onSecondary: GxColors.onPrimary,
      secondaryContainer: GxColors.secondarySoft,
      onSecondaryContainer: GxColors.textPrimary,
      error: GxColors.error,
      onError: GxColors.onPrimary,
      errorContainer: GxColors.errorSoft,
      onErrorContainer: GxColors.textPrimary,
      surface: GxColors.background,
      onSurface: GxColors.textPrimary,
      onSurfaceVariant: GxColors.textSecondary,
      surfaceContainerLowest: GxColors.background,
      surfaceContainerLow: GxColors.surface,
      surfaceContainer: GxColors.surface,
      surfaceContainerHigh: GxColors.surfaceMuted,
      surfaceContainerHighest: GxColors.surfaceMuted,
      outline: GxColors.border,
      outlineVariant: GxColors.border,
      shadow: Colors.transparent,
      surfaceTint: Colors.transparent,
    );

    final textTheme = GxTypography.textTheme;

    const buttonShape = RoundedRectangleBorder(borderRadius: GxRadius.mdAll);
    const buttonSize = Size(GxSpacing.minTouchTarget, GxSpacing.buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: GxSpacing.lg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GxColors.background,
      fontFamily: GxTypography.fontFamily,
      package: GxTypography.fontPackage,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: const DividerThemeData(
        color: GxColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GxColors.background,
        foregroundColor: GxColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: const Border(bottom: GxBorders.hairline),
      ),
      cardTheme: const CardThemeData(
        color: GxColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: GxRadius.lgAll,
          side: GxBorders.hairline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GxColors.primary,
          foregroundColor: GxColors.onPrimary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: GxColors.background,
          foregroundColor: GxColors.secondary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          side: GxBorders.hairline,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GxColors.primary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GxColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GxSpacing.md,
          vertical: GxSpacing.sm,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: GxColors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: GxRadius.mdAll,
          borderSide: GxBorders.hairline,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: GxRadius.mdAll,
          borderSide: GxBorders.hairline,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: GxRadius.mdAll,
          borderSide: BorderSide(color: GxColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: GxRadius.mdAll,
          borderSide: BorderSide(color: GxColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: GxRadius.mdAll,
          borderSide: BorderSide(color: GxColors.error, width: 1.5),
        ),
      ),
    );
  }
}
