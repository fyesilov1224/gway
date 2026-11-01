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
        final cacheWidth = gwCacheWidth(constraints.maxWidth, MediaQuery.devicePixelRatioOf(context));
        final placeholder = placeholderUrl == null || placeholderUrl == url
            ? const GwSkeleton(height: double.infinity, borderRadius: BorderRadius.zero)
            : Image(image: gwNetworkImage(placeholderUrl!, cacheWidth: cacheWidth), fit: fit, width: double.infinity, height: double.infinity,
                errorBuilder: (_, _, _) => const ColoredBox(color: GwColors.surfaceMuted));
        return Image(
          image: gwNetworkImage(url, cacheWidth: cacheWidth),
          fit: fit,
          semanticLabel: semanticLabel,
          width: double.infinity,
          height: double.infinity,
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
            color: GwColors.surfaceMuted,
            child: Center(child: Icon(Icons.broken_image_outlined, color: GwColors.textSecondary)),
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
            color: GwColors.media,
            child: Center(child: Icon(Icons.play_arrow_rounded, color: GwColors.onMedia, size: GwSpacing.xl)),
          ),
        if (badge != null)
          Positioned(
            top: GwSpacing.xs,
            right: GwSpacing.xs,
            child: Icon(badge, color: GwColors.onMedia, size: GwSpacing.md + GwSpacing.xxs,
                shadows: const [Shadow(color: GwColors.mediaScrim, blurRadius: GwSpacing.xxs)]),
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
        color: GwColors.media,
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
              const Center(child: Icon(Icons.videocam_off_outlined, color: GwColors.onMedia))
            else
              const Center(child: CircularProgressIndicator(color: GwColors.onMedia)),
            if (_ready && !v.isPlaying && widget.onFinished == null)
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: GwColors.onMedia, size: GwSpacing.xxl)),
            if (_ready)
              Positioned(
                right: GwSpacing.xs,
                bottom: GwSpacing.xs,
                child: Semantics(
                  button: true,
                  label: _muted ? 'Sesi aç' : 'Sesi kapat',
                  child: IconButton(
                    onPressed: _toggleMute,
                    style: IconButton.styleFrom(backgroundColor: GwColors.mediaScrim, foregroundColor: GwColors.onMedia),
                    icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, size: GwSpacing.md + GwSpacing.xxs),
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
                      child: const Icon(Icons.favorite_rounded, color: GwColors.onMedia, size: GwSpacing.xxl * 2,
                          shadows: [Shadow(color: GwColors.mediaScrim, blurRadius: GwSpacing.md)]),
                    ),
                  );
                },
              ),
            ),
          ),
          if (media.length > 1) ...[
            Positioned(
              top: GwSpacing.sm,
              right: GwSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.xxs),
                decoration: const BoxDecoration(color: GwColors.mediaScrim, borderRadius: GwRadius.lgAll),
                child: Text('${_index + 1}/${media.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GwColors.onMedia)),
              ),
            ),
            Positioned(
              bottom: GwSpacing.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: GwSpacing.xxs,
                children: [
                  for (var i = 0; i < media.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: GwSpacing.xs,
                      height: GwSpacing.xs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? GwColors.onMedia : GwColors.onMedia.withValues(alpha: 0.5),
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
