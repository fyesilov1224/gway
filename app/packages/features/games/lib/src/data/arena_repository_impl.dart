import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/arena.dart';
import '../domain/chess.dart';
import '../domain/team.dart';

/// Arenas: reads under RLS and Realtime; joining, pausing and leaving through the API.
class ArenaRepositoryImpl implements ArenaRepository {
  ArenaRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String? get _me => _client.auth.currentUser?.id;

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  String? _avatar(Object? path) => path is String ? _client.storage.from('avatars').getPublicUrl(path) : null;

  Arena _arena(Map<String, dynamic> t) => Arena(
        id: t['id'] as String,
        kind: ArenaKind.values.byName(t['kind'] as String),
        title: t['title'] as String?,
        game: TeamGame.parse(t['game']),
        timeControl: t['base_seconds'] is int ? TimeControl(t['base_seconds'] as int, t['increment_seconds'] as int) : null,
        questions: t['length'] as int?,
        startsAt: DateTime.parse(t['starts_at'] as String).toLocal(),
        endsAt: DateTime.parse(t['ends_at'] as String).toLocal(),
        status: ArenaStatus.values.byName(t['status'] as String),
      );

  @override
  Future<Result<ArenaLists>> arenas(TeamGame game) => _run(() async {
        final open = await _client
            .from('chess_tournaments')
            .select()
            .eq('game', game.code)
            .inFilter('status', ['scheduled', 'live'])
            .order('starts_at', ascending: true)
            .limit(12);
        final done = await _client
            .from('chess_tournaments')
            .select()
            .eq('game', game.code)
            .eq('status', 'finished')
            .order('starts_at', ascending: false)
            .limit(10);
        final finished = [for (final t in done) _arena(t)];
        final podiumRows = finished.isEmpty
            ? const <Map<String, dynamic>>[]
            : await _client
                .from('chess_tournament_players')
                .select('tournament_id, final_rank, user:profiles!chess_tournament_players_user_id_fkey(id, username, display_name, avatar_path)')
                .inFilter('tournament_id', [for (final a in finished) a.id])
                .lte('final_rank', 3)
                .order('final_rank', ascending: true);
        final me = _me;
        final joined = me == null || open.isEmpty
            ? const <String>{}
            : {
                for (final r in await _client
                    .from('chess_tournament_players')
                    .select('tournament_id')
                    .eq('user_id', me)
                    .inFilter('tournament_id', [for (final t in open) t['id'] as String]))
                  r['tournament_id'] as String,
              };
        final all = [for (final t in open) _arena(t)];
        return (
          live: [for (final a in all) if (a.status == ArenaStatus.live) a],
          upcoming: [for (final a in all) if (a.status == ArenaStatus.scheduled) a],
          finished: [
            for (final a in finished)
              (
                arena: a,
                podium: [
                  for (final r in podiumRows)
                    if (r['tournament_id'] == a.id && r['user'] is Map)
                      ChessPlayer(
                        userId: (r['user'] as Map)['id'] as String,
                        username: (r['user'] as Map)['username'] as String,
                        displayName: (r['user'] as Map)['display_name'] as String,
                        avatarUrl: _avatar((r['user'] as Map)['avatar_path']),
                      ),
                ],
              ),
          ],
          joined: joined,
        );
      });

  @override
  Future<Result<ArenaDetail>> detail(String id) => _run(() async {
        final t = await _client.from('chess_tournaments').select().eq('id', id).maybeSingle() ?? (throw const NotFoundFailure());
        final rows = await _client.rpc<List<dynamic>>('chess_tournament_standings', params: {'target': id});
        final me = _me;
        final mine = me == null
            ? null
            : await _client
                .from('chess_tournament_players')
                .select('current_game_id, current_match_id')
                .eq('tournament_id', id)
                .eq('user_id', me)
                .maybeSingle();
        return ArenaDetail(
          arena: _arena(t),
          joined: mine != null,
          myGameId: mine?['current_game_id'] as String?,
          myMatchId: mine?['current_match_id'] as String?,
          standings: [
            for (final r in rows.cast<Map<String, dynamic>>())
              ArenaStanding(
                rank: (r['rank'] as num).toInt(),
                player: ChessPlayer(
                  userId: r['user_id'] as String,
                  username: r['username'] as String,
                  displayName: r['display_name'] as String,
                  avatarUrl: _avatar(r['avatar_path']),
                  country: r['country'] as String?,
                ),
                points: r['points'] as int,
                games: r['games'] as int,
                wins: r['wins'] as int,
                draws: r['draws'] as int,
                losses: r['losses'] as int,
                streak: r['streak'] as int,
                performance: r['performance'] as int?,
                waiting: r['waiting'] as bool,
                playing: r['playing'] as bool,
                finalRank: r['final_rank'] as int?,
              ),
          ],
        );
      });

  @override
  Stream<void> changes(String id) {
    late final RealtimeChannel channel;
    final controller = StreamController<void>(onCancel: () => _client.removeChannel(channel));
    void changed(PostgresChangePayload _) => controller.add(null);
    channel = _client
        .channel('chess_arena:$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_tournaments',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: id),
          callback: changed,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_tournament_players',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'tournament_id', value: id),
          callback: changed,
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<void>> join(String id) => _api.post('/games/chess/tournaments/$id/join', decode: (_) {});

  @override
  Future<Result<void>> pause(String id) => _api.post('/games/chess/tournaments/$id/pause', decode: (_) {});

  @override
  Future<Result<void>> leave(String id) => _api.delete('/games/chess/tournaments/$id/registration', decode: (_) {});

  @override
  Future<Result<ChessMedals>> medals(String userId, TeamGame game) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_medals', params: {'target': userId, 'target_game': game.code});
        if (rows.isEmpty) return const ChessMedals();
        final r = (rows.first as Map).cast<String, dynamic>();
        return ChessMedals(gold: r['gold'] as int, silver: r['silver'] as int, bronze: r['bronze'] as int);
      });
}
