import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/chess.dart';
import '../domain/team.dart';

/// Team matches: reads under RLS and Realtime, every change through the API (docs/ARCHITECTURE.md §3i, 20b).
class TeamMatchRepositoryImpl implements TeamMatchRepository {
  TeamMatchRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  ChessGroup _group(Map<String, dynamic> g, {String idKey = 'id'}) => ChessGroup(
        id: g[idKey] as String,
        handle: g['handle'] as String,
        name: g['name'] as String,
        logoUrl: _url('group-images', g['logo_path']),
      );

  Future<Map<String, ChessGroup>> _groups(Iterable<String> ids) async {
    final wanted = {...ids}.toList();
    if (wanted.isEmpty) return const {};
    final rows = await _client.from('groups').select('id, handle, name, logo_path').inFilter('id', wanted);
    return {for (final g in rows) g['id'] as String: _group(g)};
  }

  Future<Map<String, ChessPlayer>> _players(Iterable<String?> ids) async {
    final wanted = {...ids.whereType<String>()}.toList();
    if (wanted.isEmpty) return const {};
    final rows = await _client.from('profiles').select('id, username, display_name, avatar_path').inFilter('id', wanted);
    final flags = await _client.from('chess_players').select('user_id, country').inFilter('user_id', wanted);
    final country = {for (final f in flags) f['user_id'] as String: f['country'] as String?};
    return {
      for (final p in rows)
        p['id'] as String: ChessPlayer(
          userId: p['id'] as String,
          username: p['username'] as String,
          displayName: p['display_name'] as String,
          avatarUrl: _url('avatars', p['avatar_path']),
          country: country[p['id']],
        ),
    };
  }

  double? _points(Object? v) => (v as num?)?.toDouble();

  TeamMatch _match(Map<String, dynamic> m, Map<String, ChessGroup> groups) => TeamMatch(
        id: m['id'] as String,
        home: groups[m['home_group_id']] ?? ChessGroup(id: m['home_group_id'] as String, handle: '', name: '—'),
        away: groups[m['away_group_id']] ?? ChessGroup(id: m['away_group_id'] as String, handle: '', name: '—'),
        boards: m['boards'] as int,
        timeControl: TimeControl(m['base_seconds'] as int, m['increment_seconds'] as int),
        startsAt: DateTime.parse(m['starts_at'] as String).toLocal(),
        status: TeamMatchStatus.parse(m['status']),
        homePoints: _points(m['home_points']),
        awayPoints: _points(m['away_points']),
        homeDelta: m['home_delta'] as int?,
        awayDelta: m['away_delta'] as int?,
      );

  @override
  Future<Result<List<GroupLeaderboardEntry>>> groupLeaderboard() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_group_leaderboard', params: {'page_size': 100});
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            GroupLeaderboardEntry(
              rank: (r['rank'] as num).toInt(),
              group: _group(r, idKey: 'group_id'),
              memberCount: r['member_count'] as int,
              rating: r['rating'] as int,
              matches: r['matches'] as int,
              wins: r['wins'] as int,
              draws: r['draws'] as int,
              losses: r['losses'] as int,
            ),
        ];
      });

  @override
  Future<Result<List<ChessGroup>>> captainGroups() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_captain_groups');
        return [for (final r in rows.cast<Map<String, dynamic>>()) _group(r, idKey: 'group_id')];
      });

  @override
  Future<Result<List<ChessGroup>>> searchGroups(String query) => _run(() async {
        final q = query.trim().replaceAll(RegExp(r'[%_,()]'), '');
        if (q.length < 2) return const <ChessGroup>[];
        final rows = await _client
            .from('groups')
            .select('id, handle, name, logo_path')
            .eq('status', 'active')
            .or('name.ilike.%$q%,handle.ilike.$q%')
            .limit(20);
        return [for (final g in rows) _group(g)];
      });

  @override
  Future<Result<List<TeamMatch>>> myMatches() => _run(() async {
        final mine = [for (final r in await _client.from('group_members').select('group_id').eq('user_id', _me)) r['group_id'] as String];
        if (mine.isEmpty) return const <TeamMatch>[];
        final list = mine.join(',');
        final rows = await _client
            .from('chess_team_matches')
            .select()
            .or('home_group_id.in.($list),away_group_id.in.($list)')
            .inFilter('status', ['invited', 'accepted', 'live', 'finished'])
            .order('starts_at', ascending: false)
            .limit(20);
        final groups = await _groups([for (final m in rows) ...[m['home_group_id'] as String, m['away_group_id'] as String]]);
        return [for (final m in rows) _match(m, groups)];
      });

  @override
  Future<Result<TeamMatchDetail>> detail(String id) => _run(() async {
        final m = await _client.from('chess_team_matches').select().eq('id', id).maybeSingle() ?? (throw const NotFoundFailure());
        final home = m['home_group_id'] as String;
        final away = m['away_group_id'] as String;
        final groups = await _groups([home, away]);
        final match = _match(m, groups);
        final ratings = {
          for (final r in await _client.from('chess_group_ratings').select('group_id, rating').inFilter('group_id', [home, away]))
            r['group_id'] as String: r['rating'] as int,
        };
        final captains = {for (final g in (await captainGroups()).getOrThrow()) g.id}..retainAll({home, away});

        final List<TeamBoard> boards;
        if (match.status == TeamMatchStatus.live || match.status == TeamMatchStatus.finished) {
          final rows = await _client.from('chess_team_boards').select().eq('match_id', id).order('board', ascending: true);
          final people = await _players([for (final b in rows) ...[b['home_id'] as String?, b['away_id'] as String?]]);
          boards = [
            for (final b in rows)
              TeamBoard(
                board: b['board'] as int,
                home: people[b['home_id']],
                away: people[b['away_id']],
                gameId: b['game_id'] as String?,
                homePoints: _points(b['home_points']),
                awayPoints: _points(b['away_points']),
              ),
          ];
        } else {
          final rows = await _client.from('chess_team_lineups').select('group_id, board, user_id').eq('match_id', id);
          final people = await _players([for (final l in rows) l['user_id'] as String]);
          final at = {for (final l in rows) (l['group_id'] as String, l['board'] as int): people[l['user_id']]};
          boards = [
            for (var b = 1; b <= match.boards; b++) TeamBoard(board: b, home: at[(home, b)], away: at[(away, b)]),
          ];
        }
        return TeamMatchDetail(
          match: match,
          boards: boards,
          captainOf: captains,
          homeRating: ratings[home] ?? ChessRating.startRating,
          awayRating: ratings[away] ?? ChessRating.startRating,
        );
      });

  @override
  Stream<void> changes(String id) {
    late final RealtimeChannel channel;
    final controller = StreamController<void>(onCancel: () => _client.removeChannel(channel));
    void changed(PostgresChangePayload _) => controller.add(null);
    channel = _client
        .channel('chess_team:$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_team_matches',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: id),
          callback: changed,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_team_boards',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'match_id', value: id),
          callback: changed,
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<List<TeamCandidate>>> candidates(String matchId, String groupId) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_team_candidates', params: {'target_match': matchId, 'target_group': groupId});
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            TeamCandidate(
              player: ChessPlayer(
                userId: r['user_id'] as String,
                username: r['username'] as String,
                displayName: r['display_name'] as String,
                avatarUrl: _url('avatars', r['avatar_path']),
                country: r['country'] as String?,
              ),
              rating: r['rating'] as int,
              games: r['games'] as int,
            ),
        ];
      });

  @override
  Future<Result<String>> create({
    required String homeGroupId,
    required String awayGroupId,
    required int boards,
    required TimeControl timeControl,
    required DateTime startsAt,
  }) =>
      _api.post(
        '/games/chess/team-matches',
        body: {
          'homeGroupId': homeGroupId,
          'awayGroupId': awayGroupId,
          'boards': boards,
          'baseSeconds': timeControl.baseSeconds,
          'incrementSeconds': timeControl.incrementSeconds,
          'startsAt': startsAt.toUtc().toIso8601String(),
        },
        decode: (json) => (json! as Map)['id']! as String,
      );

  @override
  Future<Result<void>> respond(String id, {required bool accept}) =>
      _api.post('/games/chess/team-matches/$id/${accept ? 'accept' : 'decline'}', decode: (_) {});

  @override
  Future<Result<void>> cancel(String id) => _api.delete('/games/chess/team-matches/$id', decode: (_) {});

  @override
  Future<Result<void>> setLineup(String id, String groupId, List<String?> players) =>
      _api.put('/games/chess/team-matches/$id/lineup', body: {'groupId': groupId, 'players': players}, decode: (_) {});
}
