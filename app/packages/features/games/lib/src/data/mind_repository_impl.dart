import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/chess.dart';
import '../domain/mind.dart';

/// Reads come from Supabase under RLS and Realtime; questions are served and answers scored only by the API
/// (docs/ARCHITECTURE.md §3j). Flags come from the games player card (`chess_players`).
class MindRepositoryImpl implements MindRepository {
  MindRepositoryImpl(this._client, this._api);

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

  String? _avatar(Object? path) => path is String ? _client.storage.from('avatars').getPublicUrl(path) : null;

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
          avatarUrl: _avatar(p['avatar_path']),
          country: country[p['id']],
        ),
    };
  }

  @override
  Future<Result<MindProfile>> profile(String userId) => _run(() async {
        final player = (await _players([userId]))[userId] ?? (throw const NotFoundFailure());
        final card = await _client.from('chess_players').select('suspended_until').eq('user_id', userId).maybeSingle();
        final ratings = await _client.from('mind_ratings').select().eq('user_id', userId);
        final ranks = await _client.rpc<List<dynamic>>('mind_ranks', params: {'target': userId});
        return MindProfile(
          player: player,
          ratings: {
            for (final r in ratings)
              r['length'] as int: MindRating(
                length: r['length'] as int,
                rating: r['rating'] as int,
                peak: r['peak'] as int,
                games: r['games'] as int,
                wins: r['wins'] as int,
                draws: r['draws'] as int,
                losses: r['losses'] as int,
                deviation: (r['deviation'] as num).toDouble(),
              ),
          },
          ranks: {for (final r in ranks.cast<Map<String, dynamic>>()) (r['length'] as num).toInt(): (r['rank'] as num?)?.toInt()},
          suspendedUntil: switch (card?['suspended_until']) {
            'infinity' => DateTime(9999),
            final String at => DateTime.parse(at),
            _ => null,
          },
        );
      });

  @override
  Future<Result<List<LeaderboardEntry>>> leaderboard(int length, {int offset = 0, int pageSize = 50}) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('mind_leaderboard',
            params: {'target_length': length, 'page_size': pageSize, 'page_offset': offset});
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            LeaderboardEntry(
              rank: (r['rank'] as num?)?.toInt() ?? 0,
              player: ChessPlayer(
                userId: r['user_id'] as String,
                username: r['username'] as String,
                displayName: r['display_name'] as String,
                avatarUrl: _avatar(r['avatar_path']),
                country: r['country'] as String?,
              ),
              rating: r['rating'] as int,
              games: r['games'] as int,
              wins: r['wins'] as int,
              draws: r['draws'] as int,
              losses: r['losses'] as int,
              provisional: r['provisional'] as bool,
              trend: r['trend'] as int,
            ),
        ];
      });

  @override
  Future<Result<List<MindMatchSummary>>> recentMatches(String userId, {int limit = 20}) => _run(() async {
        final rows = await _client
            .from('mind_matches')
            .select()
            .or('a_id.eq.$userId,b_id.eq.$userId')
            .neq('status', 'aborted')
            .order('created_at', ascending: false)
            .limit(limit);
        final matches = [for (final r in rows) MindMatch.fromRow(r)];
        final people = await _players([for (final m in matches) m.idOf(m.sideOf(userId)?.other ?? MindSide.b)]);
        return [
          for (final m in matches)
            if (m.sideOf(userId) case final side?) MindMatchSummary(match: m, side: side, opponent: people[m.idOf(side.other)]),
        ];
      });

  @override
  Future<Result<MindMatch?>> activeMatch() => _run(() async {
        final me = _me;
        final row = await _client
            .from('mind_matches')
            .select()
            .eq('status', 'active')
            .or('a_id.eq.$me,b_id.eq.$me')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        return row == null ? null : MindMatch.fromRow(row);
      });

  @override
  Future<Result<List<MindChallenge>>> challenges() => _run(() async {
        final me = _me;
        final rows = await _client
            .from('mind_challenges')
            .select()
            .eq('status', 'pending')
            .gt('expires_at', DateTime.now().toUtc().toIso8601String())
            .or('challenger_id.eq.$me,opponent_id.eq.$me')
            .order('created_at', ascending: false);
        String otherOf(Map<String, dynamic> r) => r['challenger_id'] == me ? r['opponent_id'] as String : r['challenger_id'] as String;
        final people = await _players([for (final r in rows) otherOf(r)]);
        return [
          for (final r in rows)
            MindChallenge(
              id: r['id'] as String,
              challengerId: r['challenger_id'] as String,
              opponentId: r['opponent_id'] as String,
              length: r['length'] as int,
              rated: r['rated'] as bool,
              expiresAt: DateTime.parse(r['expires_at'] as String),
              matchId: r['match_id'] as String?,
              rematchOf: r['rematch_of'] as String?,
              other: people[otherOf(r)],
            ),
        ];
      });

  @override
  Stream<void> challengeChanges() {
    final me = _client.auth.currentUser?.id;
    if (me == null) return const Stream.empty();
    late final RealtimeChannel channel;
    final controller = StreamController<void>.broadcast(onCancel: () => _client.removeChannel(channel));
    void changed(PostgresChangePayload _) => controller.add(null);
    channel = _client
        .channel('mind_challenges:$me')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mind_challenges',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'opponent_id', value: me),
          callback: changed,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mind_challenges',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'challenger_id', value: me),
          callback: changed,
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<String?>> seek(int length) =>
      _api.post('/games/mind/seeks', body: {'length': length}, decode: (json) => (json! as Map)['matchId'] as String?);

  @override
  Future<Result<String?>> heartbeat() => _api.post('/games/mind/seeks/heartbeat', decode: (json) => (json! as Map)['matchId'] as String?);

  @override
  Future<Result<void>> cancelSeek() => _api.delete('/games/mind/seeks', decode: (_) {});

  @override
  Stream<String> seekMatches() {
    final me = _client.auth.currentUser?.id;
    if (me == null) return const Stream.empty();
    late final RealtimeChannel channel;
    final controller = StreamController<String>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('mind_seeks:$me')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'mind_seeks',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: me),
          callback: (payload) {
            if (payload.newRecord['match_id'] case final String match) controller.add(match);
          },
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<String>> challenge(String opponentId, int length, {bool rated = true}) => _api.post(
        '/games/mind/challenges',
        body: {'opponentId': opponentId, 'length': length, 'rated': rated},
        decode: (json) => (json! as Map)['id']! as String,
      );

  @override
  Future<Result<String>> accept(String challengeId) =>
      _api.post('/games/mind/challenges/$challengeId/accept', decode: (json) => (json! as Map)['matchId']! as String);

  @override
  Future<Result<void>> decline(String challengeId) => _api.post('/games/mind/challenges/$challengeId/decline', decode: (_) {});

  @override
  Future<Result<void>> cancelChallenge(String challengeId) => _api.delete('/games/mind/challenges/$challengeId', decode: (_) {});

  static Map<String, dynamic> _map(Object? json) => (json! as Map).cast<String, dynamic>();

  static MindView _view(Object? json) {
    final j = _map(json);
    return (match: MindMatch.fromRow(_map(j['match'])), serverNow: DateTime.parse(j['serverNow'] as String));
  }

  @override
  Future<Result<MindView>> match(String id) => _api.get('/games/mind/$id', decode: _view);

  @override
  Stream<MindMatch> matchUpdates(String id) {
    late final RealtimeChannel channel;
    final controller = StreamController<MindMatch>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('mind_match:$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'mind_matches',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: id),
          callback: (payload) {
            try {
              controller.add(MindMatch.fromRow(payload.newRecord));
            } on Object {
              // A row the app cannot read is skipped; the next API answer carries the state.
            }
          },
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<MindNext>> next(String id) => _api.post('/games/mind/$id/next', decode: (json) {
        final j = _map(json);
        return (
          match: MindMatch.fromRow(_map(j['match'])),
          serverNow: DateTime.parse(j['serverNow'] as String),
          question: j['question'] is Map ? MindQuestion.fromJson(_map(j['question'])) : null,
        );
      });

  @override
  Future<Result<MindAnswered>> answer(String id, int index, Map<String, Object?> answer, int elapsedMs) => _api.post(
        '/games/mind/$id/answers',
        body: {'index': index, 'answer': answer, 'elapsedMs': elapsedMs},
        decode: (json) {
          final j = _map(json);
          return MindAnswered(
            points: (j['points'] as num).toInt(),
            correct: j['correct'] as bool,
            solution: _map(j['solution']),
            match: MindMatch.fromRow(_map(j['match'])),
            serverNow: DateTime.parse(j['serverNow'] as String),
          );
        },
      );

  @override
  Future<Result<MindView>> resign(String id) => _api.post('/games/mind/$id/resign', decode: _view);

  @override
  Future<Result<MindRematch>> rematch(String id) => _api.post('/games/mind/$id/rematch', decode: (json) {
        final j = _map(json);
        return (challengeId: j['challengeId'] as String?, matchId: j['matchId'] as String?);
      });
}
