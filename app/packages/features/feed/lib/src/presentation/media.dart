import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/post.dart';

/// A network photo filling its box. It is decoded at the box's pixel width
/// (`cacheWidth`), shows [placeholderUrl] (the small copy) or a skeleton until
/// it arrives, fades in, and shows an icon if it fails.
class MediaImage extends StatelessWidget {
  const MediaImage({super.key, required this.url, this.placeholderUrl, this.fit = BoxFit.cover, this.semanticLabel});

  final String url;
  final String? placeholderUrl;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final cacheWidth = gxCacheWidth(constraints.maxWidth, MediaQuery.devicePixelRatioOf(context));
        final placeholder = placeholderUrl == null || placeholderUrl == url
            ? const GxSkeleton(height: double.infinity, borderRadius: BorderRadius.zero)
            : Image.network(placeholderUrl!, fit: fit, width: double.infinity, height: double.infinity, cacheWidth: cacheWidth,
                errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted));
        return Image.network(
          url,
          fit: fit,
          semanticLabel: semanticLabel,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: cacheWidth,
          frameBuilder: (context, child, frame, synchronous) => synchronous
              ? child
              : Stack(fit: StackFit.expand, children: [
                  placeholder,
                  AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 250),
                    child: child,
                  ),
                ]),
          errorBuilder: (_, _, _) => const ColoredBox(
            color: GxColors.surfaceMuted,
            child: Center(child: Icon(Icons.broken_image_outlined, color: GxColors.textSecondary)),
          ),
        );
      });
}

/// Small square preview for grids: the photo, or the video's cover.
class MediaThumb extends StatelessWidget {
  const MediaThumb({super.key, required this.media, this.badge});

  final PostMedia media;

  /// Top-right icon, e.g. for carousels and videos.
  final IconData? badge;

  @override
  Widget build(BuildContext context) {
    final poster = media.previewUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster != null)
          MediaImage(url: poster)
        else
          const ColoredBox(
            color: GxColors.media,
            child: Center(child: Icon(Icons.play_arrow_rounded, color: GxColors.onMedia, size: GxSpacing.xl)),
          ),
        if (badge != null)
          Positioned(
            top: GxSpacing.xs,
            right: GxSpacing.xs,
            child: Icon(badge, color: GxColors.onMedia, size: GxSpacing.md + GxSpacing.xxs,
                shadows: const [Shadow(color: GxColors.mediaScrim, blurRadius: GxSpacing.xxs)]),
          ),
      ],
    );
  }
}

/// Plays a video in place: tap to play or pause, with a mute toggle. Starts muted.
class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.url, this.posterUrl, this.autoplay = false, this.onFinished, this.fit = BoxFit.cover});

  final String url;
  final String? posterUrl;
  final bool autoplay;

  /// Called once at the end (stories advance with it).
  final VoidCallback? onFinished;
  final BoxFit fit;

  @override
  State<VideoView> createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> {
  late final VideoPlayerController _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  bool _ready = false;
  bool _muted = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..setVolume(0)
      ..addListener(_onTick)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        if (widget.autoplay) _controller.play();
      }, onError: (_) {});
  }

  void _onTick() {
    final v = _controller.value;
    if (!_finished && v.isInitialized && v.duration > Duration.zero && v.position >= v.duration && !v.isPlaying) {
      _finished = true;
      widget.onFinished?.call();
    }
    if (mounted) setState(() {});
  }

  void pause() => _controller.pause();

  void play() => _ready ? _controller.play() : null;

  void _toggle() => _controller.value.isPlaying ? _controller.pause() : _controller.play();

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _controller.setVolume(_muted ? 0 : 1);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _controller.value;
    return GestureDetector(
      onTap: _ready ? _toggle : null,
      child: ColoredBox(
        color: GxColors.media,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready)
              FittedBox(
                fit: widget.fit,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(width: v.size.width, height: v.size.height, child: VideoPlayer(_controller)),
              )
            else if (widget.posterUrl != null)
              MediaImage(url: widget.posterUrl!)
            else if (v.hasError)
              const Center(child: Icon(Icons.videocam_off_outlined, color: GxColors.onMedia))
            else
              const Center(child: CircularProgressIndicator(color: GxColors.onMedia)),
            if (_ready && !v.isPlaying && widget.onFinished == null)
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: GxColors.onMedia, size: GxSpacing.xxl)),
            if (_ready)
              Positioned(
                right: GxSpacing.xs,
                bottom: GxSpacing.xs,
                child: Semantics(
                  button: true,
                  label: _muted ? 'Sesi aç' : 'Sesi kapat',
                  child: IconButton(
                    onPressed: _toggleMute,
                    style: IconButton.styleFrom(backgroundColor: GxColors.mediaScrim, foregroundColor: GxColors.onMedia),
                    icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, size: GxSpacing.md + GxSpacing.xxs),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A photo or a video, filling its box.
class MediaView extends StatelessWidget {
  const MediaView({super.key, required this.media, this.fit = BoxFit.cover});

  final PostMedia media;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => switch (media.kind) {
        MediaKind.image => MediaImage(url: media.url, placeholderUrl: media.thumbUrl, fit: fit),
        MediaKind.video => VideoView(url: media.url, posterUrl: media.posterUrl, fit: fit),
      };
}

/// Swipeable media of a post, with page dots; a double tap calls [onDoubleTap]
/// and shows a heart.
class MediaCarousel extends StatefulWidget {
  const MediaCarousel({super.key, required this.media, this.onDoubleTap});

  final List<PostMedia> media;
  final VoidCallback? onDoubleTap;

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> with SingleTickerProviderStateMixin {
  final _pages = PageController();
  int _index = 0;
  late final AnimationController _heart = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void dispose() {
    _pages.dispose();
    _heart.dispose();
    super.dispose();
  }

  void _doubleTap() {
    widget.onDoubleTap?.call();
    if (!MediaQuery.disableAnimationsOf(context)) _heart.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return AspectRatio(
      aspectRatio: feedAspectRatio(media),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTap: _doubleTap,
            child: PageView.builder(
              controller: _pages,
              itemCount: media.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => MediaView(media: media[i]),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _heart,
                builder: (_, _) {
                  final t = _heart.value;
                  if (t == 0 || t == 1) return const SizedBox.shrink();
                  final scale = t < 0.3 ? Curves.easeOutBack.transform(t / 0.3) : 1.0;
                  return Opacity(
                    opacity: t < 0.7 ? 1 : (1 - (t - 0.7) / 0.3),
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.favorite_rounded, color: GxColors.onMedia, size: GxSpacing.xxl * 2,
                          shadows: [Shadow(color: GxColors.mediaScrim, blurRadius: GxSpacing.md)]),
                    ),
                  );
                },
              ),
            ),
          ),
          if (media.length > 1) ...[
            Positioned(
              top: GxSpacing.sm,
              right: GxSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs),
                decoration: const BoxDecoration(color: GxColors.mediaScrim, borderRadius: GxRadius.lgAll),
                child: Text('${_index + 1}/${media.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GxColors.onMedia)),
              ),
            ),
            Positioned(
              bottom: GxSpacing.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: GxSpacing.xxs,
                children: [
                  for (var i = 0; i < media.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: GxSpacing.xs,
                      height: GxSpacing.xs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? GxColors.onMedia : GxColors.onMedia.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
