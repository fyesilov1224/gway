import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/chess.dart';

/// Reads come from Supabase under RLS and Realtime; every game action goes through the API, which checks the
/// rules and keeps the clock (docs/ARCHITECTURE.md §3i). The only direct write is the person's own flag.
class ChessRepositoryImpl implements ChessRepository {
  ChessRepositoryImpl(this._client, this._api);

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

  ChessPlayer _player(Map<String, dynamic> p, String? country) => ChessPlayer(
        userId: p['id'] as String,
        username: p['username'] as String,
        displayName: p['display_name'] as String,
        avatarUrl: _avatar(p['avatar_path']),
        country: country,
      );

  /// People by id with their flags, in one round trip each.
  Future<Map<String, ChessPlayer>> _players(Iterable<String?> ids) async {
    final wanted = {...ids.whereType<String>()}.toList();
    if (wanted.isEmpty) return const {};
    final rows = await _client.from('profiles').select('id, username, display_name, avatar_path').inFilter('id', wanted);
    final flags = await _client.from('chess_players').select('user_id, country').inFilter('user_id', wanted);
    final country = {for (final f in flags) f['user_id'] as String: f['country'] as String?};
    return {for (final p in rows) p['id'] as String: _player(p, country[p['id']])};
  }

  @override
  Future<Result<ChessProfile>> profile(String userId) => _run(() async {
        final player = (await _players([userId]))[userId] ?? (throw const NotFoundFailure());
        final card = await _client.from('chess_players').select('suspended_until').eq('user_id', userId).maybeSingle();
        final ratings = await _client.from('chess_ratings').select().eq('user_id', userId);
        final ranks = await _client.rpc<List<dynamic>>('chess_ranks', params: {'target': userId});
        return ChessProfile(
          player: player,
          ratings: {
            for (final r in ratings)
              ChessCategory.parse(r['category']): ChessRating(
                category: ChessCategory.parse(r['category']),
                rating: r['rating'] as int,
                peak: r['peak'] as int,
                games: r['games'] as int,
                wins: r['wins'] as int,
                draws: r['draws'] as int,
                losses: r['losses'] as int,
                deviation: (r['deviation'] as num).toDouble(),
              ),
          },
          ranks: {for (final r in ranks.cast<Map<String, dynamic>>()) ChessCategory.parse(r['category']): (r['rank'] as num?)?.toInt()},
          suspendedUntil: switch (card?['suspended_until']) {
            'infinity' => DateTime(9999),
            final String at => DateTime.parse(at),
            _ => null,
          },
        );
      });

  @override
  Future<Result<void>> setCountry(String code) => _run(() async {
        await _client.from('chess_players').upsert({'user_id': _me, 'country': code}, onConflict: 'user_id');
      });

  @override
  Future<Result<void>> setLevel(int rating) => _api.post('/games/chess/level', body: {'rating': rating}, decode: (_) {});

  @override
  Future<Result<List<LeaderboardEntry>>> leaderboard(ChessCategory category, {int offset = 0, int pageSize = 50}) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_leaderboard',
            params: {'target_category': category.code, 'page_size': pageSize, 'page_offset': offset});
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
  Future<Result<Map<ChessCategory, int?>>> myRanks() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('chess_ranks');
        return {for (final r in rows.cast<Map<String, dynamic>>()) ChessCategory.parse(r['category']): (r['rank'] as num?)?.toInt()};
      });

  @override
  Future<Result<List<GameSummary>>> recentGames(String userId, {int limit = 20}) => _run(() async {
        final rows = await _client
            .from('chess_games')
            .select()
            .or('white_id.eq.$userId,black_id.eq.$userId')
            .neq('status', 'aborted')
            .order('created_at', ascending: false)
            .limit(limit);
        final games = [for (final r in rows) ChessGame.fromRow(r)];
        final people = await _players([for (final g in games) g.colorOf(userId) == ChessColor.white ? g.blackId : g.whiteId]);
        return [
          for (final g in games)
            if (g.colorOf(userId) case final color?) GameSummary(game: g, color: color, opponent: people[g.idOf(color.opposite)]),
        ];
      });

  @override
  Future<Result<ChessGame?>> activeGame() => _run(() async {
        final me = _me;
        final row = await _client
            .from('chess_games')
            .select()
            .eq('status', 'active')
            .or('white_id.eq.$me,black_id.eq.$me')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        return row == null ? null : ChessGame.fromRow(row);
      });

  @override
  Future<Result<List<ChessChallenge>>> challenges() => _run(() async {
        final me = _me;
        final rows = await _client
            .from('chess_challenges')
            .select()
            .eq('status', 'pending')
            .gt('expires_at', DateTime.now().toUtc().toIso8601String())
            .or('challenger_id.eq.$me,opponent_id.eq.$me')
            .order('created_at', ascending: false);
        final people = await _players([for (final r in rows) r['challenger_id'] == me ? r['opponent_id'] as String : r['challenger_id'] as String]);
        return [
          for (final r in rows)
            ChessChallenge(
              id: r['id'] as String,
              challengerId: r['challenger_id'] as String,
              opponentId: r['opponent_id'] as String,
              timeControl: TimeControl(r['base_seconds'] as int, r['increment_seconds'] as int),
              rated: r['rated'] as bool,
              color: ColorChoice.values.firstWhere((c) => c.code == r['color'], orElse: () => ColorChoice.random),
              status: ChallengeStatus.pending,
              createdAt: DateTime.parse(r['created_at'] as String),
              expiresAt: DateTime.parse(r['expires_at'] as String),
              gameId: r['game_id'] as String?,
              rematchOf: r['rematch_of'] as String?,
              other: people[r['challenger_id'] == me ? r['opponent_id'] : r['challenger_id']],
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
        .channel('chess_challenges:$me')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_challenges',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'opponent_id', value: me),
          callback: changed,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chess_challenges',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'challenger_id', value: me),
          callback: changed,
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<List<ChessPlayer>>> searchPlayers(String query) => _run(() async {
        final q = query.trim().replaceAll(RegExp(r'[%_,()]'), '');
        if (q.length < 2) return const <ChessPlayer>[];
        final rows = await _client
            .from('profiles')
            .select('id')
            .or('username.ilike.$q%,display_name.ilike.%$q%')
            .neq('id', _me)
            .limit(20);
        final people = await _players([for (final r in rows) r['id'] as String]);
        return [for (final r in rows) ?people[r['id']]];
      });

  @override
  Future<Result<String?>> seek(TimeControl timeControl, {bool rated = true}) => _api.post(
        '/games/chess/seeks',
        body: {'baseSeconds': timeControl.baseSeconds, 'incrementSeconds': timeControl.incrementSeconds, 'rated': rated},
        decode: (json) => (json! as Map)['gameId'] as String?,
      );

  @override
  Future<Result<String?>> heartbeat() =>
      _api.post('/games/chess/seeks/heartbeat', decode: (json) => (json! as Map)['gameId'] as String?);

  @override
  Future<Result<void>> cancelSeek() => _api.delete('/games/chess/seeks', decode: (_) {});

  @override
  Stream<String> seekMatches() {
    final me = _client.auth.currentUser?.id;
    if (me == null) return const Stream.empty();
    late final RealtimeChannel channel;
    final controller = StreamController<String>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('chess_seeks:$me')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chess_seeks',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: me),
          callback: (payload) {
            if (payload.newRecord['game_id'] case final String game) controller.add(game);
          },
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<String>> challenge(String opponentId, TimeControl timeControl, {bool rated = true, ColorChoice color = ColorChoice.random}) =>
      _api.post(
        '/games/chess/challenges',
        body: {
          'opponentId': opponentId,
          'baseSeconds': timeControl.baseSeconds,
          'incrementSeconds': timeControl.incrementSeconds,
          'rated': rated,
          'color': color.code,
        },
        decode: (json) => (json! as Map)['id']! as String,
      );

  @override
  Future<Result<String>> accept(String challengeId) =>
      _api.post('/games/chess/challenges/$challengeId/accept', decode: (json) => (json! as Map)['gameId']! as String);

  @override
  Future<Result<void>> decline(String challengeId) => _api.post('/games/chess/challenges/$challengeId/decline', decode: (_) {});

  @override
  Future<Result<void>> cancelChallenge(String challengeId) => _api.delete('/games/chess/challenges/$challengeId', decode: (_) {});

  static GameView _view(Object? json) {
    final j = (json! as Map).cast<String, dynamic>();
    return (game: ChessGame.fromRow((j['game'] as Map).cast<String, dynamic>()), serverNow: DateTime.parse(j['server_now'] as String));
  }

  @override
  Future<Result<GameView>> game(String id) => _api.get('/games/chess/$id', decode: _view);

  @override
  Stream<ChessGame> gameUpdates(String id) {
    late final RealtimeChannel channel;
    final controller = StreamController<ChessGame>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('chess_game:$id')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chess_games',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: id),
          callback: (payload) {
            try {
              controller.add(ChessGame.fromRow(payload.newRecord));
            } on Object {
              // A row the app cannot read is skipped; the next API answer carries the state.
            }
          },
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<GameView>> move(String id, String uci, int ply) =>
      _api.post('/games/chess/$id/moves', body: {'uci': uci, 'ply': ply}, decode: _view);

  @override
  Future<Result<GameView>> resign(String id) => _api.post('/games/chess/$id/resign', decode: _view);

  @override
  Future<Result<GameView>> abort(String id) => _api.post('/games/chess/$id/abort', decode: _view);

  @override
  Future<Result<GameView>> offerDraw(String id) => _api.post('/games/chess/$id/draw-offer', decode: _view);

  @override
  Future<Result<GameView>> acceptDraw(String id) => _api.post('/games/chess/$id/draw-accept', decode: _view);

  @override
  Future<Result<GameView>> declineDraw(String id) => _api.post('/games/chess/$id/draw-decline', decode: _view);

  @override
  Future<Result<GameView>> flag(String id) => _api.post('/games/chess/$id/flag', decode: _view);

  @override
  Future<Result<RematchOutcome>> rematch(String id) => _api.post('/games/chess/$id/rematch', decode: (json) {
        final j = (json! as Map).cast<String, Object?>();
        return (challengeId: j['challengeId'] as String?, gameId: j['gameId'] as String?);
      });
}
