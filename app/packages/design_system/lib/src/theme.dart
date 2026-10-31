import 'package:flutter/material.dart';

import 'components/backdrop.dart';
import 'tokens/borders.dart';
import 'tokens/colors.dart';
import 'tokens/radius.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// The single source of [ThemeData] for every GWAY app.
abstract final class GwTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: GwColors.primary,
      onPrimary: GwColors.onPrimary,
      primaryContainer: GwColors.primarySoft,
      onPrimaryContainer: GwColors.textPrimary,
      secondary: GwColors.secondary,
      onSecondary: GwColors.onPrimary,
      secondaryContainer: GwColors.secondarySoft,
      onSecondaryContainer: GwColors.textPrimary,
      error: GwColors.error,
      onError: GwColors.onPrimary,
      errorContainer: GwColors.errorSoft,
      onErrorContainer: GwColors.textPrimary,
      surface: GwColors.background,
      onSurface: GwColors.textPrimary,
      onSurfaceVariant: GwColors.textSecondary,
      surfaceContainerLowest: GwColors.background,
      surfaceContainerLow: GwColors.surface,
      surfaceContainer: GwColors.surface,
      surfaceContainerHigh: GwColors.surfaceMuted,
      surfaceContainerHighest: GwColors.surfaceMuted,
      outline: GwColors.border,
      outlineVariant: GwColors.border,
      shadow: Colors.transparent,
      surfaceTint: Colors.transparent,
    );

    final textTheme = GwTypography.textTheme;

    const buttonShape = RoundedRectangleBorder(borderRadius: GwRadius.mdAll);
    const buttonSize = Size(GwSpacing.minTouchTarget, GwSpacing.buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: GwSpacing.lg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Pages are transparent over GwBackdrop; content sits on white cards (docs/DESIGN.md §1, §5).
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: GwBackdropTransitions(FadeForwardsPageTransitionsBuilder()),
          TargetPlatform.fuchsia: GwBackdropTransitions(FadeForwardsPageTransitionsBuilder()),
          TargetPlatform.linux: GwBackdropTransitions(FadeForwardsPageTransitionsBuilder()),
          TargetPlatform.windows: GwBackdropTransitions(FadeForwardsPageTransitionsBuilder()),
          TargetPlatform.iOS: GwBackdropTransitions(CupertinoPageTransitionsBuilder()),
          TargetPlatform.macOS: GwBackdropTransitions(CupertinoPageTransitionsBuilder()),
        },
      ),
      fontFamily: GwTypography.fontFamily,
      package: GwTypography.fontPackage,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: const DividerThemeData(
        color: GwColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: GwColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: GwColors.textPrimary,
        unselectedLabelColor: GwColors.textSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const _PillIndicator(),
        dividerColor: GwColors.border,
        splashBorderRadius: GwRadius.xlAll,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: GwColors.background,
          foregroundColor: GwColors.textSecondary,
          selectedBackgroundColor: GwColors.primarySoft,
          selectedForegroundColor: GwColors.textPrimary,
          side: GwBorders.hairline,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GwColors.background,
        selectedColor: GwColors.primarySoft,
        side: GwBorders.hairline,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge,
        showCheckmark: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GwColors.background,
        modalBackgroundColor: GwColors.background,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: GwColors.border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(GwRadius.xl))),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: GwColors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: GwColors.background,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyLarge,
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.mdAll, side: GwBorders.hairline),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GwColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: GwColors.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.mdAll),
      ),
      cardTheme: const CardThemeData(
        color: GwColors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: GwRadius.lgAll,
          side: GwBorders.hairline,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GwColors.primary,
          foregroundColor: GwColors.onPrimary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: GwColors.background,
          foregroundColor: GwColors.secondary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          side: GwBorders.hairline,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GwColors.primary,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GwColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GwSpacing.md,
          vertical: GwSpacing.sm,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: GwRadius.mdAll,
          borderSide: GwBorders.hairline,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: GwRadius.mdAll,
          borderSide: GwBorders.hairline,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: GwRadius.mdAll,
          borderSide: BorderSide(color: GwColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: GwRadius.mdAll,
          borderSide: BorderSide(color: GwColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: GwRadius.mdAll,
          borderSide: BorderSide(color: GwColors.error, width: 1.5),
        ),
      ),
    );
  }
}

/// The selected tab: a soft pill inset from the tab's edges.
class _PillIndicator extends Decoration {
  const _PillIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _PillPainter();
}

class _PillPainter extends BoxPainter {
  static const _inset = EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs + GwSpacing.xxs / 2);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = _inset.deflateRect(offset & configuration.size!);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)), Paint()..color = GwColors.primarySoft);
  }
}
