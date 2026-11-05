import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// A drawn medal: a two-color ribbon (brand purple and blue) and a shining metal disc with the place on it
/// (docs/DESIGN.md §1, Madalyalar). [size] is the width; the medal is a third taller.
class GwMedalBadge extends StatelessWidget {
  const GwMedalBadge({super.key, required this.medal, required this.rank, this.size = 32});

  final GwMedal medal;
  final int rank;
  final double size;

  static const double aspect = 1.35;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size * aspect,
        child: CustomPaint(
          painter: _MedalPainter(medal: medal, rank: rank, textStyle: Theme.of(context).textTheme.labelLarge!),
        ),
      );
}

class _MedalPainter extends CustomPainter {
  _MedalPainter({required this.medal, required this.rank, required this.textStyle});

  final GwMedal medal;
  final int rank;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset at(double x, double y) => Offset(x * w, y * h);

    // Ribbon: two straps crossing into a V behind the disc.
    final right = Path()
      ..moveTo(at(0.58, 0).dx, 0)
      ..lineTo(at(0.90, 0).dx, 0)
      ..lineTo(at(0.62, 0.56).dx, at(0.62, 0.56).dy)
      ..lineTo(at(0.36, 0.56).dx, at(0.36, 0.56).dy)
      ..close();
    final left = Path()
      ..moveTo(at(0.10, 0).dx, 0)
      ..lineTo(at(0.42, 0).dx, 0)
      ..lineTo(at(0.64, 0.56).dx, at(0.64, 0.56).dy)
      ..lineTo(at(0.38, 0.56).dx, at(0.38, 0.56).dy)
      ..close();
    canvas
      ..drawPath(right, Paint()..color = GwColors.secondary)
      ..drawPath(left, Paint()..color = GwColors.primary)
      // A darker fold where the straps meet the disc.
      ..drawRect(Rect.fromLTWH(at(0.36, 0.46).dx, at(0.36, 0.46).dy, w * 0.28, h * 0.08), Paint()..color = medal.deep);

    // Disc: metal with light from the top left.
    final center = at(0.5, 0.66);
    final radius = w * 0.40;
    final disc = Rect.fromCircle(center: center, radius: radius);
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 1.1,
            colors: [medal.shine, medal.strong, medal.deep],
            stops: const [0, 0.55, 1],
          ).createShader(disc),
      )
      ..drawCircle(center, radius, Paint()..color = medal.deep..style = PaintingStyle.stroke..strokeWidth = w * 0.05)
      ..drawCircle(center, radius * 0.74, Paint()..color = medal.shine.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = w * 0.03)
      // A small glint.
      ..drawArc(Rect.fromCircle(center: center, radius: radius * 0.86), math.pi * 1.1, math.pi * 0.35, false,
          Paint()..color = GwColors.background.withValues(alpha: 0.65)..style = PaintingStyle.stroke..strokeWidth = w * 0.04..strokeCap = StrokeCap.round);

    final text = TextPainter(
      text: TextSpan(
        text: '$rank',
        style: textStyle.copyWith(color: medal.deep, fontWeight: FontWeight.w900, fontSize: radius * 1.05, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(_MedalPainter old) => old.medal != medal || old.rank != rank;
}

/// A drawn crown in the medal's metal, worn above a winner's avatar (docs/DESIGN.md §1, Madalyalar).
/// [size] is the width; the crown is three quarters as tall.
class GwCrown extends StatelessWidget {
  const GwCrown({super.key, required this.medal, this.size = 32});

  final GwMedal medal;
  final double size;

  static const double aspect = 0.75;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size * aspect, child: CustomPaint(painter: _CrownPainter(medal)));
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.medal);

  final GwMedal medal;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset at(double x, double y) => Offset(x * w, y * h);
    final outline = Paint()
      ..color = medal.deep
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeJoin = StrokeJoin.round;
    final metal = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [medal.shine, medal.strong, medal.deep],
        stops: const [0, 0.6, 1],
      ).createShader(Offset.zero & size);

    // Three points over a band.
    final crown = Path()
      ..moveTo(at(0.10, 0.70).dx, at(0.10, 0.70).dy)
      ..lineTo(at(0.06, 0.26).dx, at(0.06, 0.26).dy)
      ..lineTo(at(0.30, 0.48).dx, at(0.30, 0.48).dy)
      ..lineTo(at(0.50, 0.12).dx, at(0.50, 0.12).dy)
      ..lineTo(at(0.70, 0.48).dx, at(0.70, 0.48).dy)
      ..lineTo(at(0.94, 0.26).dx, at(0.94, 0.26).dy)
      ..lineTo(at(0.90, 0.70).dx, at(0.90, 0.70).dy)
      ..close();
    final band = RRect.fromRectAndRadius(Rect.fromLTRB(at(0.08, 0.68).dx, at(0.08, 0.68).dy, at(0.92, 0.92).dx, at(0.92, 0.92).dy),
        Radius.circular(w * 0.05));
    canvas
      ..drawPath(crown, metal)
      ..drawPath(crown, outline)
      ..drawRRect(band, metal)
      ..drawRRect(band, outline);
    // Pearls on the points and a jewel on the band.
    for (final tip in [at(0.06, 0.24), at(0.50, 0.10), at(0.94, 0.24)]) {
      canvas
        ..drawCircle(tip, w * 0.075, Paint()..color = medal.shine)
        ..drawCircle(tip, w * 0.075, outline);
    }
    final jewel = at(0.5, 0.80);
    canvas
      ..drawCircle(jewel, w * 0.07, Paint()..color = GwColors.primary)
      ..drawCircle(jewel, w * 0.07, outline..strokeWidth = w * 0.03)
      ..drawCircle(at(0.27, 0.80), w * 0.04, Paint()..color = GwColors.secondary)
      ..drawCircle(at(0.73, 0.80), w * 0.04, Paint()..color = GwColors.secondary);
  }

  @override
  bool shouldRepaint(_CrownPainter old) => old.medal != medal;
}
