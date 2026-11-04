import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/media_crop.dart';
import '../domain/post.dart';
import '../l10n.dart';
import 'media.dart';

/// Shows [media] inside a frame of [ratio]: pinch to zoom, drag to move what is kept.
/// Videos are not cropped; they fill the frame as they will in the feed.
class CropEditor extends StatefulWidget {
  const CropEditor({super.key, required this.media, required this.ratio, required this.frame, required this.onChanged});

  final NewMedia media;
  final double ratio;
  final CropFrame frame;
  final ValueChanged<CropFrame> onChanged;

  @override
  State<CropEditor> createState() => _CropEditorState();
}

class _CropEditorState extends State<CropEditor> {
  double _lastScale = 1;
  bool _moving = false;

  Size get _source => Size(widget.media.width.toDouble(), widget.media.height.toDouble());

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return AspectRatio(
      aspectRatio: widget.ratio,
      child: ClipRect(
        child: media.kind == MediaKind.video
            ? VideoView(url: media.previewPath!, autoplay: true)
            : LayoutBuilder(builder: (context, constraints) {
                final frameWidth = constraints.maxWidth;
                final rect = widget.frame.rectIn(_source, widget.ratio);
                final scale = frameWidth / rect.width;
                return GestureDetector(
                  onScaleStart: (_) => setState(() {
                    _lastScale = 1;
                    _moving = true;
                  }),
                  onScaleUpdate: (d) {
                    var frame = widget.frame;
                    if (d.scale != _lastScale) frame = frame.zoomed(d.scale / _lastScale, _source, widget.ratio);
                    _lastScale = d.scale;
                    widget.onChanged(frame.panned(d.focalPointDelta, _source, widget.ratio, frameWidth));
                  },
                  onScaleEnd: (_) => setState(() => _moving = false),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -rect.left * scale,
                        top: -rect.top * scale,
                        width: _source.width * scale,
                        height: _source.height * scale,
                        child: Image.memory(media.bytes, fit: BoxFit.fill, gaplessPlayback: true, semanticLabel: feedL10n.photoToCrop),
                      ),
                      if (_moving) const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ThirdsPainter()))),
                    ],
                  ),
                );
              }),
      ),
    );
  }
}

/// Rule-of-thirds guides while adjusting.
class _ThirdsPainter extends CustomPainter {
  const _ThirdsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GwColors.onMedia.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      canvas
        ..drawLine(Offset(size.width * i / 3, 0), Offset(size.width * i / 3, size.height), paint)
        ..drawLine(Offset(0, size.height * i / 3), Offset(size.width, size.height * i / 3), paint);
    }
  }

  @override
  bool shouldRepaint(_ThirdsPainter oldDelegate) => false;
}
