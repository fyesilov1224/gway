import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/guide.dart';
import '../domain/guide_content.dart';
import '../l10n.dart';
import 'routes.dart';

const _icons = <String, IconData>{
  'start': Icons.rocket_launch_outlined,
  'profile': Icons.person_outline_rounded,
  'feed': Icons.wb_sunny_outlined,
  'groups': Icons.groups_outlined,
  'group-admin': Icons.admin_panel_settings_outlined,
  'events': Icons.event_outlined,
  'event-admin': Icons.edit_calendar_outlined,
  'calendar': Icons.calendar_month_outlined,
  'live': Icons.podcasts_outlined,
  'messages': Icons.chat_bubble_outline_rounded,
  'matching': Icons.favorite_border_rounded,
  'notifications': Icons.notifications_none_rounded,
  'safety': Icons.shield_outlined,
  'moderation': Icons.gavel_outlined,
  'account': Icons.manage_accounts_outlined,
};

const _tones = [GwTone.lilac, GwTone.sky, GwTone.mist];

IconData _iconOf(GuideChapter c) => _icons[c.id] ?? Icons.menu_book_outlined;

GwTone _toneOf(GuideChapter c) => _tones[guideChapters.indexOf(c) % _tones.length];

Widget _page(List<Widget> children) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, GwSpacing.xxl),
          children: children,
        ),
      ),
    );

class _ChapterIcon extends StatelessWidget {
  const _ChapterIcon(this.chapter);

  final GuideChapter chapter;

  @override
  Widget build(BuildContext context) {
    final tone = _toneOf(chapter);
    return Container(
      width: GwAvatarSize.md.dimension,
      height: GwAvatarSize.md.dimension,
      decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
      child: Icon(_iconOf(chapter), color: tone.strong),
    );
  }
}

/// Settings → "Kullanma kılavuzu": every part of the app, chapter by chapter, with search.
class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searching = _query.trim().length > 1;
    final hits = searching ? searchGuide(guideChapters, _query) : const <GuideHit>[];

    return Scaffold(
      appBar: AppBar(title: Text(supportL10n.guide)),
      body: _page([
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: supportL10n.guideSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: supportL10n.clearSearch,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                    }),
                  ),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        if (!searching) ...[
          Text(
            supportL10n.guideIntro,
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.md),
          for (final c in guideChapters) ...[
            _ChapterCard(chapter: c),
            const SizedBox(height: GwSpacing.sm),
          ],
        ] else if (hits.isEmpty)
          GwEmptyState(
            icon: Icons.search_off_rounded,
            message: supportL10n.noHits,
            actionLabel: supportL10n.writeSupport,
            onAction: () => context.push(SupportRoutes.create()),
          )
        else ...[
          Text(supportL10n.hitsFound(hits.length), style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
          const SizedBox(height: GwSpacing.xs),
          GwCard(
            radius: GwRadius.lgAll,
            child: Column(
              children: [
                for (final (i, h) in hits.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    minTileHeight: GwSpacing.minTouchTarget + GwSpacing.sm,
                    leading: Icon(_iconOf(h.chapter), color: _toneOf(h.chapter).strong),
                    title: Text(h.chapter.topics[h.topic].title),
                    subtitle: Text(h.chapter.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(SupportRoutes.guideChapter(h.chapter.id, topic: h.topic)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ]),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter});

  final GuideChapter chapter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: supportL10n.chapterSemantics(chapter.title, chapter.summary, chapter.topics.length),
      excludeSemantics: true,
      child: GwCard(
        radius: GwRadius.lgAll,
        padding: const EdgeInsets.all(GwSpacing.sm),
        onTap: () => context.push(SupportRoutes.guideChapter(chapter.id)),
        child: Row(
          children: [
            _ChapterIcon(chapter),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: textTheme.titleSmall),
                  const SizedBox(height: GwSpacing.xxs / 2),
                  Text(chapter.summary, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.xs),
            Text(supportL10n.topicCount(chapter.topics.length), style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary)),
            const Icon(Icons.chevron_right, color: GwColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// One chapter: its topics as cards that open in place; [openTopic] starts open (from search).
class GuideChapterScreen extends StatelessWidget {
  const GuideChapterScreen({super.key, required this.chapterId, this.openTopic});

  final String chapterId;
  final int? openTopic;

  @override
  Widget build(BuildContext context) {
    final chapter = guideChapters.where((c) => c.id == chapterId).firstOrNull;
    if (chapter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: GwEmptyState(
          icon: Icons.menu_book_outlined,
          message: supportL10n.chapterNotFound,
          actionLabel: supportL10n.backToGuide,
          onAction: () => context.pushReplacement(SupportRoutes.guide),
        ),
      );
    }
    final textTheme = Theme.of(context).textTheme;
    final index = guideChapters.indexOf(chapter);
    final next = index + 1 < guideChapters.length ? guideChapters[index + 1] : null;

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: _page([
        Row(
          children: [
            _ChapterIcon(chapter),
            const SizedBox(width: GwSpacing.sm),
            Expanded(child: Text(chapter.summary, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))),
          ],
        ),
        const SizedBox(height: GwSpacing.md),
        for (final (i, t) in chapter.topics.indexed) ...[
          _TopicCard(topic: t, initiallyOpen: i == openTopic),
          const SizedBox(height: GwSpacing.sm),
        ],
        const SizedBox(height: GwSpacing.sm),
        GwCard(
          radius: GwRadius.lgAll,
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(supportL10n.notSolved, style: textTheme.titleSmall),
              const SizedBox(height: GwSpacing.xxs),
              Text(supportL10n.notSolvedHint,
                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
              const SizedBox(height: GwSpacing.sm),
              GwButton(
                label: supportL10n.writeSupport,
                icon: Icons.support_agent_outlined,
                variant: GwButtonVariant.secondary,
                onPressed: () => context.push(SupportRoutes.create()),
              ),
            ],
          ),
        ),
        if (next != null) ...[
          const SizedBox(height: GwSpacing.sm),
          ListTile(
            minTileHeight: GwSpacing.minTouchTarget + GwSpacing.sm,
            title: Text(supportL10n.nextChapter, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
            subtitle: Text(next.title, style: textTheme.titleSmall),
            trailing: const Icon(Icons.arrow_forward_rounded),
            onTap: () => context.pushReplacement(SupportRoutes.guideChapter(next.id)),
          ),
        ],
      ]),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.initiallyOpen});

  final GuideTopic topic;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = textTheme.bodyMedium;
    return GwCard(
      radius: GwRadius.lgAll,
      child: ExpansionTile(
        initiallyExpanded: initiallyOpen,
        shape: const Border(),
        collapsedShape: const Border(),
        minTileHeight: GwSpacing.minTouchTarget + GwSpacing.sm,
        tilePadding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
        childrenPadding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(topic.title, style: textTheme.titleSmall),
        children: [
          if (topic.intro case final intro?) ...[
            Text(intro, style: body),
            const SizedBox(height: GwSpacing.sm),
          ],
          for (final (i, step) in topic.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: GwSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: GwSpacing.lg,
                    height: GwSpacing.lg,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: GwColors.primarySoft, shape: BoxShape.circle),
                    child: Text('${i + 1}', style: textTheme.labelMedium?.copyWith(color: GwColors.primary)),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  Expanded(child: Text(step, style: body)),
                ],
              ),
            ),
          if (topic.steps.isNotEmpty && topic.notes.isNotEmpty) const SizedBox(height: GwSpacing.xs),
          for (final note in topic.notes)
            Padding(
              padding: const EdgeInsets.only(bottom: GwSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs),
                    child: Text('•', style: body?.copyWith(color: GwColors.primary)),
                  ),
                  const SizedBox(width: GwSpacing.xxs),
                  Expanded(child: Text(note, style: body)),
                ],
              ),
            ),
          if (topic.tip case final tip?)
            Container(
              margin: const EdgeInsets.only(top: GwSpacing.xs),
              padding: const EdgeInsets.all(GwSpacing.sm),
              decoration: const BoxDecoration(color: GwColors.secondarySoft, borderRadius: GwRadius.mdAll),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: GwColors.secondary, size: GwSpacing.lg - GwSpacing.xxs),
                  const SizedBox(width: GwSpacing.xs),
                  Expanded(child: Text(tip, style: body)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
