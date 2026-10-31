import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/post.dart';
import 'routes.dart';

/// Text with tappable #tags (tag page) and @mentions (profile); [lead] is a bold name before it.
class FeedRichText extends ConsumerStatefulWidget {
  const FeedRichText({super.key, required this.text, this.lead, this.onLeadTap, this.maxLines, this.style});

  final String text;
  final String? lead;
  final VoidCallback? onLeadTap;
  final int? maxLines;
  final TextStyle? style;

  @override
  ConsumerState<FeedRichText> createState() => _FeedRichTextState();
}

class _FeedRichTextState extends ConsumerState<FeedRichText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _tap(VoidCallback onTap) {
    final r = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final base = widget.style ?? Theme.of(context).textTheme.bodyMedium!;
    final link = base.copyWith(color: GwColors.secondary);
    final links = ref.read(feedLinksProvider);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (widget.lead case final lead?)
            TextSpan(
              text: '$lead ',
              style: base.copyWith(fontWeight: FontWeight.w600),
              recognizer: widget.onLeadTap == null ? null : _tap(widget.onLeadTap!),
            ),
          for (final part in parseRichText(widget.text))
            switch (part) {
              PlainPart(:final text) => TextSpan(text: text),
              HashtagPart(:final text, :final tag) =>
                TextSpan(text: text, style: link, recognizer: _tap(() => context.push(FeedRoutes.hashtag(tag)))),
              MentionPart(:final text, :final username) =>
                TextSpan(text: text, style: link, recognizer: _tap(() => links.openProfile(context, username))),
            },
        ],
      ),
      maxLines: widget.maxLines,
      overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
