import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Color schemes of the brand mark. See docs/brand/README.md.
enum GxLogoTone {
  /// Purple and blue members, for light backgrounds.
  color(GxColors.primary, GxColors.secondary, GxColors.textPrimary, GxColors.primary),

  /// White and light blue members, for a purple background.
  onPrimary(GxColors.onPrimary, _lightBlue, GxColors.onPrimary, _lightBlue),

  /// Soft purple and blue members, for dark backgrounds.
  onDark(_softPurple, _softBlue, GxColors.onPrimary, _softPurple);

  const GxLogoTone(this.first, this.second, this.text, this.accent);

  final Color first;
  final Color second;

  /// Wordmark "Grup".
  final Color text;

  /// Wordmark "X".
  final Color accent;
}

// Brand-only tints used by the mark on purple and dark backgrounds.
const _lightBlue = Color(0xFFC9DAFF);
const _softPurple = Color(0xFFB5A6F5);
const _softBlue = Color(0xFF8FB4FF);

/// The GrupX logo: four members meeting in the middle form an X.
/// With [wordmark] the "GrupX" name follows the mark.
class GxLogo extends StatelessWidget {
  const GxLogo({
    super.key,
    this.size = 32,
    this.tone = GxLogoTone.color,
    this.wordmark = false,
  });

  /// Height of the mark.
  final double size;
  final GxLogoTone tone;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(tone)),
    );
    if (!wordmark) return Semantics(label: 'GrupX', image: true, child: mark);

    final style = TextStyle(
      fontFamily: GxTypography.fontFamily,
      package: GxTypography.fontPackage,
      fontWeight: FontWeight.w700,
      fontSize: size * 0.82,
      height: 1,
      letterSpacing: -size * 0.03,
      color: tone.text,
    );
    return Semantics(
      label: 'GrupX',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: size * 0.3),
          Text.rich(
            TextSpan(
              text: 'Grup',
              children: [TextSpan(text: 'X', style: TextStyle(color: tone.accent))],
            ),
            style: style,
            textScaler: TextScaler.noScaling,
          ),
        ],
      ),
    );
  }
}

/// Mirrors docs/brand/grupx-mark.svg (120×120 grid).
class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.tone);

  final GxLogoTone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 120;
    canvas
      ..save()
      ..scale(scale)
      ..translate(60, 60);
    for (var i = 0; i < 4; i++) {
      final color = i.isEven ? tone.first : tone.second;
      final fill = Paint()..color = color;
      final body = Paint()
        ..color = color
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      canvas
        ..save()
        ..rotate(i * math.pi / 2)
        ..drawCircle(const Offset(-38, -38), 12, fill)
        ..drawLine(const Offset(-21, -21), const Offset(-10, -10), body)
        ..restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.tone != tone;
}
