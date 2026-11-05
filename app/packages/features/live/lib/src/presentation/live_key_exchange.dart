import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/live_encryption.dart';

/// Whether everyone in the room checked that they hold the same key (docs/ARCHITECTURE.md §8, Uçtan uca şifreli yayın).
enum LiveCheck {
  /// The key is on its way, or someone's confirmation has not come yet.
  waiting,

  /// Everyone who told the room their key id holds this phone's key, every speaker among them.
  verified,

  /// A speaker sends no key id (an older app version): their sound cannot be played.
  unconfirmed,

  /// Someone holds a different key for longer than a reconnect takes.
  mismatch,
}

/// The room as the key exchange sees it; LiveKit in the app, a fake in tests.
abstract interface class LiveKeyRoom {
  /// Visible people in the room other than this phone. Hidden participants never get the key.
  Set<String> get others;

  bool isHost(String identity);

  bool isOnStage(String identity);

  /// To one person, or to everyone when [to] is null.
  Future<void> send(LiveKeyMessage message, {String? to});
}

/// Shares one audio key among everyone in a live room, with no server ever holding it:
/// a newcomer says hello with a fresh public key; a phone that holds the key seals it for that public key and sends
/// it to the newcomer alone. The host makes the key when the broadcast starts; when nobody holds one (everyone who did
/// has left), the first new phone in identity order makes it. Two keys made at once converge on the smaller key id.
class LiveKeyExchange {
  LiveKeyExchange({
    required this.broadcastId,
    required this.me,
    required LiveKeyRoom room,
    required this.onKey,
    required this.onChange,
  }) : _room = room;

  final String broadcastId;
  final String me;
  final LiveKeyRoom _room;

  /// The key to encrypt and decrypt with from now on.
  final Future<void> Function(LiveRoomKey key) onKey;
  final VoidCallback onChange;

  /// Hellos go out this often until the key is here.
  static const helloEvery = Duration(seconds: 3);

  /// How long the host waits before making the key; others wait longer, so the host's comes first.
  static const hostMakesAfter = Duration(milliseconds: 1500);
  static const othersMakeAfter = Duration(seconds: 6);

  /// A newcomer gets the key from the first holder at once and from the next ones only if it has not arrived.
  static const nextHolderAfter = Duration(seconds: 2);

  /// How long a missing or different key id may be a moment's lag before it counts.
  static const confirmWithin = Duration(seconds: 10);

  final E2eeKeyPair _pair = E2eeKeyPair.generate();
  final _publicKeys = <String, String>{};
  final _keyIds = <String, String>{};
  final _newVersion = <String>{};
  final _gifts = <String, Timer>{};
  Timer? _hello;
  Timer? _make;
  Timer? _settle;
  DateTime _lastAsk = DateTime.fromMillisecondsSinceEpoch(0);
  bool _amHost = false;
  bool _closed = false;

  LiveRoomKey? key;
  LiveCheck check = LiveCheck.waiting;

  /// Key ids others told this phone; for tests and the check.
  Map<String, String> get keyIds => Map.unmodifiable(_keyIds);

  void start({required bool amHost}) {
    _amHost = amHost;
    _sayHello();
    _hello = Timer.periodic(helloEvery, (_) {
      if (key == null) {
        _sayHello();
        _maybeMake();
      }
    });
    _make = Timer(amHost ? hostMakesAfter : othersMakeAfter, _maybeMake);
  }

  void _sayHello({String? to}) => _send(LiveKeyHello(_pair.publicKey, direct: to != null), to: to);

  void _send(LiveKeyMessage message, {String? to}) {
    if (_closed) return;
    unawaited(_room.send(message, to: to).catchError((Object e) => debugPrint('Live key message not sent: $e')));
  }

  /// Nobody holds a key that this phone knows of: the host makes it, or else the first new phone in identity order.
  void _maybeMake() {
    if (_closed || key != null || _keyIds.isNotEmpty) return;
    if (!_amHost) {
      final others = _room.others;
      if (others.any((id) => _room.isHost(id) && _newVersion.contains(id))) return;
      final candidates = {me, ..._newVersion.intersection(others)}.toList()..sort();
      if (candidates.first != me) return;
    }
    unawaited(_adopt(LiveRoomKey.generate(broadcastId)));
  }

  Future<void> _adopt(LiveRoomKey next) async {
    if (_closed || key?.keyId == next.keyId) return;
    key = next;
    for (final t in _gifts.values) {
      t.cancel();
    }
    _gifts.clear();
    await onKey(next);
    _send(LiveKeyHave(next.keyId));
    _evaluate();
    onChange();
  }

  /// A message from [from], whose identity the LiveKit server vouches for.
  void receive(String from, LiveKeyMessage message) {
    if (_closed || from == me || !_room.others.contains(from)) return;
    switch (message) {
      case LiveKeyHello(:final publicKey, :final direct):
        _publicKeys[from] = publicKey;
        _newVersion.add(from);
        final mine = key;
        if (mine == null) return;
        _send(LiveKeyHave(mine.keyId), to: from);
        _gifts.remove(from)?.cancel();
        final wait = direct ? Duration.zero : nextHolderAfter * _holderPlace(mine.keyId);
        _gifts[from] = Timer(wait, () => _gift(from));
      case LiveKeyGift(:final publicKey, :final box, :final keyId):
        _newVersion.add(from);
        final gift = LiveRoomKey.open(_pair, publicKey, box, broadcastId);
        if (gift == null || gift.keyId != keyId) return;
        _keyIds[from] = keyId;
        final mine = key;
        if (mine == null || keyId.compareTo(mine.keyId) < 0) {
          unawaited(_adopt(gift));
        } else {
          _changed();
        }
      case LiveKeyHave(:final keyId):
        _newVersion.add(from);
        _keyIds[from] = keyId;
        _make?.cancel();
        final mine = key;
        if (mine == null) {
          _askOnce(from);
        } else if (keyId.compareTo(mine.keyId) < 0) {
          // Two keys were made at once: the smaller id wins.
          _askOnce(from);
        } else if (keyId != mine.keyId) {
          _send(LiveKeyHave(mine.keyId), to: from);
        } else {
          _gifts.remove(from)?.cancel();
        }
        _changed();
    }
  }

  void _askOnce(String holder) {
    final now = DateTime.now();
    if (now.difference(_lastAsk) < helloEvery) return;
    _lastAsk = now;
    _sayHello(to: holder);
  }

  /// This phone's place among the holders of [keyId], by identity: the first gives the key at once.
  int _holderPlace(String keyId) {
    final holders = {me, for (final e in _keyIds.entries) if (e.value == keyId && _room.others.contains(e.key)) e.key}.toList()
      ..sort();
    return holders.indexOf(me);
  }

  void _gift(String to) {
    _gifts.remove(to);
    final mine = key;
    final publicKey = _publicKeys[to];
    if (mine == null || publicKey == null || _keyIds[to] == mine.keyId || !_room.others.contains(to)) return;
    final box = mine.sealFor(_pair, publicKey);
    if (box != null) _send(LiveKeyGift(_pair.publicKey, box, mine.keyId), to: to);
  }

  /// Someone left: what they said no longer counts.
  void left(String identity) {
    _publicKeys.remove(identity);
    _keyIds.remove(identity);
    _newVersion.remove(identity);
    _gifts.remove(identity)?.cancel();
    _changed();
  }

  /// Someone moved on or off the stage.
  void stageChanged() => _changed();

  void _changed() {
    final before = check;
    _evaluate();
    if (check != before) onChange();
  }

  void _evaluate({bool settle = false}) {
    final mine = key?.keyId;
    if (mine == null) {
      check = LiveCheck.waiting;
      return;
    }
    final others = _room.others;
    final differ = others.any((id) => _keyIds[id] != null && _keyIds[id] != mine);
    final silentSpeaker = others.any((id) => _keyIds[id] == null && _room.isOnStage(id));
    if (!differ && !silentSpeaker) {
      check = LiveCheck.verified;
      _settle?.cancel();
      _settle = null;
      return;
    }
    if (settle) {
      check = differ ? LiveCheck.mismatch : LiveCheck.unconfirmed;
      return;
    }
    if (check == LiveCheck.verified) check = LiveCheck.waiting;
    _settle ??= Timer(confirmWithin, () {
      _settle = null;
      final before = check;
      _evaluate(settle: true);
      if (check != before) onChange();
    });
  }

  void dispose() {
    _closed = true;
    _hello?.cancel();
    _make?.cancel();
    _settle?.cancel();
    for (final t in _gifts.values) {
      t.cancel();
    }
    _gifts.clear();
    key = null;
  }
}
