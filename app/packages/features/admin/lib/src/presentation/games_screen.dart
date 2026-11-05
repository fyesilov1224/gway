import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_games.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Games: chess and Zihin Düellosu counts, running games and suspended players (docs/ARCHITECTURE.md §3i, §3j, Yönetim paneli).
/// Aborting a game changes no rating; every action is written to audit_log.
class AdminGamesScreen extends ConsumerWidget {
  const AdminGamesScreen({super.key});

  static const _categories = {'bullet': 'Bullet', 'blitz': 'Blitz', 'rapid': 'Rapid'};

  static const _arenaStatus = {'scheduled': 'planlandı', 'live': 'oynanıyor', 'finished': 'bitti', 'canceled': 'iptal'};

  Future<void> _cancelArena(BuildContext context, WidgetRef ref, AdminTournament t) async {
    final request = await showSuspendDialog(
      context,
      title: 'Turnuvayı iptal et',
      description: '${t.name} başlamadan iptal edilir; kayıtlı oyunculara oyun açılmaz. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'İptal et',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref, () => ref.read(adminGamesRepositoryProvider).cancelTournament(t.id, reason: request.reason), 'Turnuva iptal edildi.');
    ref.invalidate(adminTournamentsProvider);
  }

  Future<void> _createTournament(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<_ArenaDraft>(context: context, builder: (_) => const _CreateArenaDialog());
    if (draft == null || !context.mounted) return;
    await _act(
      context,
      ref,
      () => ref.read(adminGamesRepositoryProvider).createTournament(
            game: draft.game,
            length: draft.length,
            title: draft.title,
            baseSeconds: draft.baseSeconds,
            incrementSeconds: draft.incrementSeconds,
            startsAt: draft.startsAt,
            minutes: draft.minutes,
          ),
      'Turnuva açıldı.',
    );
    ref.invalidate(adminTournamentsProvider);
  }

  static const _teamStatus = {'invited': 'yanıt bekliyor', 'accepted': 'kabul edildi', 'live': 'oynanıyor'};

  Future<void> _cancelTeam(BuildContext context, WidgetRef ref, AdminTeamMatch match) async {
    final request = await showSuspendDialog(
      context,
      title: 'Takım maçını iptal et',
      description: '${match.home} – ${match.away} maçı başlamadan iptal edilir; grupların puanı değişmez. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'İptal et',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref, () => ref.read(adminGamesRepositoryProvider).cancelTeamMatch(match.id, reason: request.reason), 'Takım maçı iptal edildi.');
    ref.invalidate(adminTeamMatchesProvider);
  }

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

  Future<void> _abortMind(BuildContext context, WidgetRef ref, AdminMindMatch match) async {
    final request = await showSuspendDialog(
      context,
      title: 'Düelloyu iptal et',
      description: 'Düello sonuçsuz biter; iki oyuncunun puanı değişmez. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'İptal et',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref, () => ref.read(adminGamesRepositoryProvider).abortMindMatch(match.id, reason: request.reason), 'Düello iptal edildi.');
    ref.invalidate(adminMindProvider);
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref, String userId, String username) async {
    final request = await showSuspendDialog(
      context,
      title: '@$username oyunlardan uzaklaştır',
      description: 'Kişi bu süre boyunca satranç ve Zihin Düellosu oynayamaz, davet gönderemez ve alamaz; sıralamalarda görünmez. Gerekçe kayda geçer.',
      confirmLabel: 'Uzaklaştır',
    );
    if (request == null || !context.mounted) return;
    await _act(context, ref,
        () => ref.read(adminGamesRepositoryProvider).suspendPlayer(userId, reason: request.reason, until: request.until), 'Kişi oyunlardan uzaklaştırıldı.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(adminChessProvider);
    final o = result.value;
    final teams = ref.watch(adminTeamMatchesProvider).value;
    final arenas = ref.watch(adminTournamentsProvider).value;
    final mind = ref.watch(adminMindProvider).value;
    final isAdmin = ref.watch(myStaffRoleProvider).value?.code == 'admin';
    void refresh() => ref
      ..invalidate(adminChessProvider)
      ..invalidate(adminTeamMatchesProvider)
      ..invalidate(adminTournamentsProvider)
      ..invalidate(adminMindProvider);

    return AdminPage(
      title: 'Oyunlar',
      subtitle: 'Satranç ve Zihin Düellosu: oyun sayıları, süren oyunlar ve uzaklaştırılan oyuncular. İptal edilen oyunda puan değişmez.',
      actions: [
        if (isAdmin)
          GwButton(label: 'Turnuva aç', icon: Icons.emoji_events_outlined, variant: GwButtonVariant.secondary,
              onPressed: () => _createTournament(context, ref)),
        GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: refresh),
      ],
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
              title: 'Turnuvalar',
              subtitle: 'Haftalık (pazar 21:00, 3+2, 60 dk) ve aylık (ayın son pazarı 19:00, 5+0, 120 dk) Arena turnuvaları kendiliğinden açılır. '
                  'Başlamamış turnuva gerekçeyle iptal edilebilir.',
              padding: EdgeInsets.zero,
              child: (arenas ?? const []).isEmpty
                  ? const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: Text('Turnuva yok.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final t in arenas!)
                          ListTile(
                            title: Text(t.name),
                            subtitle: Text('${t.format} · ${formatDateTime(t.startsAt)} – ${formatTime(t.endsAt)} · '
                                '${_arenaStatus[t.status] ?? t.status} · ${formatCount(t.players)} oyuncu'),
                            trailing: t.status == 'scheduled'
                                ? GwButton(label: 'İptal et', variant: GwButtonVariant.text, onPressed: () => _cancelArena(context, ref, t))
                                : null,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: GwSpacing.lg),
            GwPanel(
              title: 'Takım maçları',
              subtitle: 'Gruplar arası açık satranç maçları ve grup düelloları. Başlamamış bir maç gerekçeyle iptal edilebilir.',
              padding: EdgeInsets.zero,
              child: (teams ?? const []).isEmpty
                  ? const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: Text('Açık takım maçı yok.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final m in teams!)
                          ListTile(
                            title: Text('${m.home} – ${m.away}'),
                            subtitle: Text('${m.game == 'mind' ? 'Zihin Düellosu · ${m.boards} sıra · ${m.length} soru' : 'Satranç · ${m.boards} tahta · ${m.baseSeconds! ~/ 60}+${m.incrementSeconds}'} · '
                                '${_teamStatus[m.status] ?? m.status} · ${formatDateTime(m.startsAt)}'),
                            trailing: m.status == 'live'
                                ? null
                                : GwButton(
                                    label: 'İptal et',
                                    variant: GwButtonVariant.text,
                                    onPressed: () => _cancelTeam(context, ref, m),
                                  ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: GwSpacing.lg),
            GwPanel(
              title: 'Zihin Düellosu',
              subtitle: mind == null
                  ? 'Yükleniyor…'
                  : 'Bugün ${formatCount(mind.matchesToday)} düello · toplam ${formatCount(mind.matchesTotal)} biten · '
                      '${formatCount(mind.waitingSeeks)} rakip bekleyen · ${formatCount(mind.pendingChallenges)} açık davet · '
                      '${formatCount(mind.ratedPlayers)} puanlı oynamış kişi',
              padding: EdgeInsets.zero,
              child: (mind?.active ?? const []).isEmpty
                  ? const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: Text('Şu an süren düello yok.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final m in mind!.active)
                          ListTile(
                            title: Text('@${m.a ?? 'silinmiş'} ${m.aScore} – ${m.bScore} @${m.b ?? 'silinmiş'}'),
                            subtitle: Text('${m.length} soru · ${m.rated ? 'puanlı' : 'puansız'} · '
                                '${m.aAnswered}/${m.length} ve ${m.bAnswered}/${m.length} cevaplandı · ${formatDateTime(m.createdAt)}'),
                            trailing: GwButton(label: 'İptal et', variant: GwButtonVariant.text, onPressed: () => _abortMind(context, ref, m)),
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

typedef _ArenaDraft = ({String game, int? length, String title, int baseSeconds, int incrementSeconds, DateTime startsAt, int minutes});

/// Title, time control, start and length of an extra arena.
class _CreateArenaDialog extends StatefulWidget {
  const _CreateArenaDialog();

  @override
  State<_CreateArenaDialog> createState() => _CreateArenaDialogState();
}

class _CreateArenaDialogState extends State<_CreateArenaDialog> {
  static const _controls = [(60, 0), (120, 1), (180, 0), (180, 2), (300, 0), (300, 3), (600, 0), (600, 5), (900, 10)];
  final _title = TextEditingController();
  (int, int) _tc = (180, 2);
  String _game = 'chess';
  int _length = 10;
  int _minutes = 60;
  DateTime _starts = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: _starts, firstDate: now, lastDate: now.add(const Duration(days: 90)));
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_starts));
    if (time == null) return;
    setState(() => _starts = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Turnuva aç'),
        content: SizedBox(
          width: GwLayout.formMaxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _title, maxLength: 80, decoration: const InputDecoration(labelText: 'Başlık')),
              DropdownButtonFormField<String>(
                initialValue: _game,
                decoration: const InputDecoration(labelText: 'Oyun'),
                items: const [
                  DropdownMenuItem(value: 'chess', child: Text('Satranç')),
                  DropdownMenuItem(value: 'mind', child: Text('Zihin Düellosu')),
                ],
                onChanged: (v) => setState(() => _game = v ?? _game),
              ),
              if (_game == 'mind')
                DropdownButtonFormField<int>(
                  initialValue: _length,
                  decoration: const InputDecoration(labelText: 'Soru sayısı'),
                  items: [for (final n in [5, 10, 20, 50]) DropdownMenuItem(value: n, child: Text('$n soru'))],
                  onChanged: (v) => setState(() => _length = v ?? _length),
                )
              else
                DropdownButtonFormField<(int, int)>(
                  initialValue: _tc,
                  decoration: const InputDecoration(labelText: 'Süre'),
                  items: [for (final c in _controls) DropdownMenuItem(value: c, child: Text('${c.$1 ~/ 60}+${c.$2}'))],
                  onChanged: (v) => setState(() => _tc = v ?? _tc),
                ),
              DropdownButtonFormField<int>(
                initialValue: _minutes,
                decoration: const InputDecoration(labelText: 'Uzunluk'),
                items: [for (final m in [30, 45, 60, 90, 120, 180]) DropdownMenuItem(value: m, child: Text('$m dakika'))],
                onChanged: (v) => setState(() => _minutes = v ?? _minutes),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Başlangıç'),
                subtitle: Text(formatDateTime(_starts)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: _pick,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop((
              game: _game,
              length: _game == 'mind' ? _length : null,
              title: _title.text.trim(),
              baseSeconds: _tc.$1,
              incrementSeconds: _tc.$2,
              startsAt: _starts,
              minutes: _minutes,
            )),
            child: const Text('Aç'),
          ),
        ],
      );
}
