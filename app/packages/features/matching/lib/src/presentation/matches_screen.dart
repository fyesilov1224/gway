import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
import 'match_sheets.dart';
import 'matching_screen.dart';
import 'package_widgets.dart';
import 'providers.dart';
import 'routes.dart';

enum _MatchAction { message, keepFriend, keepDating, end, report, block }

/// "Arkadaş · Sevgili" tags of one match.
class _ModeTags extends StatelessWidget {
  const _ModeTags({required this.modes});

  final Iterable<MatchMode> modes;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: GxSpacing.xxs,
        children: [for (final m in modes) GxTag(label: m.label, tone: m == MatchMode.dating ? GxTone.lilac : GxTone.sky)],
      );
}

/// A match whose person is hidden until the Eşleşmelerim package.
class _LockedMatch extends StatelessWidget {
  const _LockedMatch({required this.match, required this.onTap});

  final MatchSummary match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GxCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
      child: Row(
        children: [
          Container(
            width: GxAvatarSize.lg.dimension,
            height: GxAvatarSize.lg.dimension,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [GxColors.backdropLilac, GxColors.backdropPink]),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: GxColors.primary),
          ),
          const SizedBox(width: GxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Biriyle eşleştin!', style: textTheme.titleMedium),
                Text(
                  'Kim olduğunu görmek için dokun · ${formatDateTr(match.matchedAt)}',
                  style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                ),
                const SizedBox(height: GxSpacing.xxs),
                _ModeTags(modes: match.modes.keys),
              ],
            ),
          ),
          const Icon(Icons.workspace_premium_outlined, color: GxColors.primary),
        ],
      ),
    );
  }
}

/// Running matches, newest first; a tap opens the chat (docs/ARCHITECTURE.md §3g).
/// Without the Eşleşmelerim package a match is a locked card that offers the package.
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key, required this.openChat});

  final OpenChat openChat;

  Future<void> _act(BuildContext context, WidgetRef ref, MatchSummary m, _MatchAction action) async {
    final card = m.card;
    if (card == null) {
      return showPackageSheet(context, feature: MatchFeature.reveal, reason: 'Biriyle eşleştin! Kim olduğunu görmek için Eşleşmelerim paketini al.');
    }
    final repo = ref.read(matchingRepositoryProvider);
    void show(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    switch (action) {
      case _MatchAction.message:
        final result = await repo.openChat(card.userId);
        if (!context.mounted) return;
        switch (result) {
          case Ok(:final value):
            openChat(context, value);
          case Err(:final failure):
            show(failure.userMessage);
        }
      case _MatchAction.keepFriend || _MatchAction.keepDating:
        final (keep, drop) = action == _MatchAction.keepFriend
            ? (MatchMode.friend, MatchMode.dating)
            : (MatchMode.dating, MatchMode.friend);
        final sure = await confirmMatchAction(
          context,
          title: 'Yalnızca ${keep.label.toLowerCase()} kal',
          message: '${card.displayName} ile ${drop.label.toLowerCase()} eşleşmeniz ikiniz için de biter; '
              '${keep.label.toLowerCase()} olarak eşleşmeniz ve sohbetiniz sürer.',
          confirmLabel: 'Devam et',
        );
        if (!sure || !context.mounted) return;
        final result = await repo.endMatch(m.modes[drop]!);
        if (!context.mounted) return;
        show(switch (result) {
          Ok() => 'Artık yalnızca ${keep.label.toLowerCase()} olarak eşleşiksiniz.',
          Err(:final failure) => failure.userMessage,
        });
        ref.invalidate(matchListProvider);
      case _MatchAction.end:
        final sure = await confirmMatchAction(
          context,
          title: 'Eşleşmeyi bitir',
          message: '${card.displayName} ile eşleşmen biter, sohbetiniz ikiniz için de kapanır. Bu geri alınamaz.',
          confirmLabel: 'Bitir',
        );
        if (!sure || !context.mounted) return;
        Result<void> result = const Ok(null);
        for (final id in m.modes.values) {
          result = await repo.endMatch(id);
          if (result is Err) break;
        }
        if (!context.mounted) return;
        show(switch (result) {
          Ok() => 'Eşleşme bitti.',
          Err(:final failure) => failure.userMessage,
        });
        ref.invalidate(matchListProvider);
      case _MatchAction.report:
        await ref.read(reportLauncherProvider)(context, ReportTarget.matchProfile(card.userId));
      case _MatchAction.block:
        final result = await repo.block(card.userId);
        if (!context.mounted) return;
        show(switch (result) {
          Ok() => '${card.displayName} engellendi.',
          Err(:final failure) => failure.userMessage,
        });
        ref.invalidate(matchListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchListProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Eşleşmelerim')),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: switch (matches) {
          AsyncData(:final value) when value.isEmpty => Padding(
              padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
              child: GxEmptyState(
                icon: Icons.favorite_border_rounded,
                message: 'Henüz eşleşmen yok. Birbirinizi beğendiğiniz kişiler burada görünür.',
                actionLabel: 'Keşfetmeye dön',
                onAction: () => context.canPop() ? context.pop() : context.go(MatchingRoutes.home),
              ),
            ),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.refresh(matchListProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(GxSpacing.page),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: GxSpacing.sm),
                itemBuilder: (context, i) {
                  final m = value[i];
                  final card = m.card;
                  if (card == null) return _LockedMatch(match: m, onTap: () => _act(context, ref, m, _MatchAction.message));
                  return GxCard(
                    onTap: () => _act(context, ref, m, _MatchAction.message),
                    padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
                    child: Row(
                      children: [
                        GxAvatar(
                          name: card.displayName,
                          shape: GxAvatarShape.user,
                          size: GxAvatarSize.lg,
                          imageUrl: card.photoUrls.isEmpty ? null : card.photoUrls.first,
                        ),
                        const SizedBox(width: GxSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${card.displayName}, ${card.age}', style: textTheme.titleMedium),
                              Text(
                                '@${m.username} · ${formatDateTr(m.matchedAt)}',
                                style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                              ),
                              const SizedBox(height: GxSpacing.xxs),
                              _ModeTags(modes: m.modes.keys),
                            ],
                          ),
                        ),
                        PopupMenuButton<_MatchAction>(
                          tooltip: 'Seçenekler',
                          onSelected: (a) => _act(context, ref, m, a),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: _MatchAction.message, child: Text('Mesaj gönder')),
                            // Matched both ways: the person chooses which one stays.
                            if (m.modes.length > 1) ...const [
                              PopupMenuItem(value: _MatchAction.keepFriend, child: Text('Yalnızca arkadaş kal')),
                              PopupMenuItem(value: _MatchAction.keepDating, child: Text('Yalnızca sevgili kal')),
                            ],
                            const PopupMenuItem(value: _MatchAction.end, child: Text('Eşleşmeyi bitir')),
                            const PopupMenuItem(value: _MatchAction.report, child: Text('Şikayet et')),
                            const PopupMenuItem(value: _MatchAction.block, child: Text('Engelle')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(matchListProvider)),
          _ => const Padding(
              padding: EdgeInsets.all(GxSpacing.page),
              child: Column(children: [GxSkeleton(height: GxSpacing.xxl), SizedBox(height: GxSpacing.sm), GxSkeleton(height: GxSpacing.xxl)]),
            ),
        },
      ),
    );
  }
}
