import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_games.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Games: chess counts, running games and suspended players (docs/ARCHITECTURE.md §3i, Yönetim paneli).
/// Aborting a game changes no rating; every action is written to audit_log.
class AdminGamesScreen extends ConsumerWidget {
  const AdminGamesScreen({super.key});

  static const _categories = {'bullet': 'Bullet', 'blitz': 'Blitz', 'rapid': 'Rapid'};

  Future<void> _act(BuildContext context, WidgetRef ref, Future<Result<void>> Function() action, String done) async {
    final result = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => done,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(adminChessProvider);
  }

  Future<void> _abort(BuildContext context, WidgetRef ref, AdminChessGame game) async {
    final request = await showSuspendDialog(
      context,
      title: 'Oyunu iptal et',
      description: 'Oyun sonuçsuz biter; iki oyuncunun puanı değişmez. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'İptal et',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref, () => ref.read(adminGamesRepositoryProvider).abortGame(game.id, reason: request.reason), 'Oyun iptal edildi.');
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref, String userId, String username) async {
    final request = await showSuspendDialog(
      context,
      title: '@$username satrançtan uzaklaştır',
      description: 'Kişi bu süre boyunca oyun arayamaz, davet gönderemez ve alamaz; sıralamada görünmez. Gerekçe kayda geçer.',
      confirmLabel: 'Uzaklaştır',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref,
        () => ref.read(adminGamesRepositoryProvider).suspendPlayer(userId, reason: request.reason, until: request.until), 'Kişi satrançtan uzaklaştırıldı.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(adminChessProvider);
    final o = result.value;
    void refresh() => ref.invalidate(adminChessProvider);

    return AdminPage(
      title: 'Oyunlar',
      subtitle: 'Satranç: oyun sayıları, süren oyunlar ve uzaklaştırılan oyuncular. İptal edilen oyunda puan değişmez.',
      actions: [GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: refresh)],
      children: [
        if (result case AsyncError(:final error))
          GwErrorState(message: userMessageOf(error), onRetry: refresh)
        else ...[
          StatCardRow(
            cards: [
              StatCard(label: 'Bugün oynanan', value: o?.gamesToday, icon: Icons.today_outlined, tone: GwBadgeTone.primary),
              StatCard(label: 'Şu an süren', value: o?.activeGames, icon: Icons.play_circle_outline, tone: GwBadgeTone.success),
              StatCard(label: 'Rakip bekleyen', value: o?.waitingSeeks, icon: Icons.hourglass_empty_rounded, tone: GwBadgeTone.info),
              StatCard(label: 'Açık davet', value: o?.pendingChallenges, icon: Icons.mail_outline, tone: GwBadgeTone.neutral),
            ],
          ),
          const SizedBox(height: GwSpacing.lg),
          if (o == null)
            const GwSkeleton(height: GwSpacing.xxl * 2)
          else ...[
            InfoPanel(
              title: 'Toplam',
              rows: [
                ('Biten oyun', formatCount(o.gamesTotal)),
                ('Puanlı oynamış kişi', formatCount(o.ratedPlayers)),
                ('Uzaklaştırılmış oyuncu', formatCount(o.suspended.length)),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            GwPanel(
              title: 'Süren oyunlar',
              subtitle: 'En yeni 100 oyun.',
              padding: EdgeInsets.zero,
              child: o.active.isEmpty
                  ? const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: Text('Şu an süren oyun yok.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final g in o.active)
                          ListTile(
                            title: Text('@${g.white ?? 'silinmiş'} – @${g.black ?? 'silinmiş'}'),
                            subtitle: Text(
                              '${g.timeControl} · ${_categories[g.category] ?? g.category} · ${g.rated ? 'puanlı' : 'puansız'} · '
                              '${formatCount(g.plies)} yarım hamle · ${formatDateTime(g.createdAt)}',
                            ),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'İşlemler',
                              onSelected: (action) => switch (action) {
                                'abort' => _abort(context, ref, g),
                                'white' => _suspend(context, ref, g.whiteId!, g.white!),
                                _ => _suspend(context, ref, g.blackId!, g.black!),
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'abort', child: Text('Oyunu iptal et')),
                                if (g.whiteId != null && g.white != null)
                                  PopupMenuItem(value: 'white', child: Text('@${g.white} uzaklaştır')),
                                if (g.blackId != null && g.black != null)
                                  PopupMenuItem(value: 'black', child: Text('@${g.black} uzaklaştır')),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: GwSpacing.lg),
            GwPanel(
              title: 'Uzaklaştırılan oyuncular',
              padding: EdgeInsets.zero,
              child: o.suspended.isEmpty
                  ? const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: Text('Uzaklaştırılmış oyuncu yok.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final s in o.suspended)
                          ListTile(
                            title: Text('@${s.username}'),
                            subtitle: Text('${s.until == null ? 'Süresiz' : '${formatDateTime(s.until!)} tarihine kadar'} · ${s.reason ?? ''}'),
                            trailing: GwButton(
                              label: 'Geri al',
                              variant: GwButtonVariant.text,
                              onPressed: () => _act(context, ref, () => ref.read(adminGamesRepositoryProvider).restorePlayer(s.userId),
                                  'Uzaklaştırma kaldırıldı.'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ],
      ],
    );
  }
}
