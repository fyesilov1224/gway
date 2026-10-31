import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Color schemes of the brand mark. See docs/brand/README.md.
enum GwLogoTone {
  /// Purple way and blue member, for light backgrounds.
  color(GwColors.primary, GwColors.secondary, GwColors.textPrimary, GwColors.primary),

  /// White way and light blue member, for a purple background.
  onPrimary(GwColors.onPrimary, _lightBlue, GwColors.onPrimary, _lightBlue),

  /// Soft purple way and soft blue member, for dark backgrounds.
  onDark(_softPurple, _softBlue, GwColors.onPrimary, _softPurple);

  const GwLogoTone(this.first, this.second, this.text, this.accent);

  /// The way (the G's arc).
  final Color first;

  /// The member (head and body).
  final Color second;

  /// Wordmark "G".
  final Color text;

  /// Wordmark "WAY".
  final Color accent;
}

// Brand-only tints used by the mark on purple and dark backgrounds.
const _lightBlue = Color(0xFFC9DAFF);
const _softPurple = Color(0xFFB5A6F5);
const _softBlue = Color(0xFF8FB4FF);

/// The GWAY logo: a way curves into a G and a member steps onto it.
/// With [wordmark] the "GWAY" name follows the mark.
class GwLogo extends StatelessWidget {
  const GwLogo({
    super.key,
    this.size = 32,
    this.tone = GwLogoTone.color,
    this.wordmark = false,
  });

  /// Height of the mark.
  final double size;
  final GwLogoTone tone;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(tone)),
    );
    if (!wordmark) return Semantics(label: 'GWAY', image: true, child: mark);

    final style = TextStyle(
      fontFamily: GwTypography.fontFamily,
      package: GwTypography.fontPackage,
      fontWeight: FontWeight.w700,
      fontSize: size * 0.82,
      height: 1,
      letterSpacing: -size * 0.03,
      color: tone.text,
    );
    return Semantics(
      label: 'GWAY',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: size * 0.3),
          Text.rich(
            TextSpan(
              text: 'G',
              children: [TextSpan(text: 'WAY', style: TextStyle(color: tone.accent))],
            ),
            style: style,
            textScaler: TextScaler.noScaling,
          ),
        ],
      ),
    );
  }
}

/// Mirrors docs/brand/gway-mark.svg (120×120 grid).
class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.tone);

  final GwLogoTone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 120;
    Paint stroke(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas
      ..save()
      ..scale(scale)
      ..drawArc(Rect.fromCircle(center: const Offset(60, 60), radius: 40), 0, 290 * math.pi / 180, false,
          stroke(tone.first))
      ..drawLine(const Offset(62, 60), const Offset(100, 60), stroke(tone.second))
      ..drawCircle(const Offset(92, 35), 11, Paint()..color = tone.second)
      ..restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.tone != tone;
}
