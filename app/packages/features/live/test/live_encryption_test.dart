import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live/src/data/live_encryption.dart';
import 'package:live/src/presentation/live_key_exchange.dart';

/// A LiveKit room in memory: messages arrive a moment later, from the identity that sent them.
class _Bus {
  final phones = <String, _Phone>{};
  final hidden = <String>{};
  final stage = <String>{};
  String? host;
  final sent = <(String from, String? to, String type)>[];

  _Phone join(String id, {bool amHost = false, bool onStage = false}) {
    if (amHost) host = id;
    if (onStage || amHost) stage.add(id);
    final phone = _Phone(this, id);
    phones[id] = phone;
    phone.exchange.start(amHost: amHost);
    return phone;
  }

  void leave(String id) {
    phones.remove(id)?.exchange.dispose();
    for (final p in phones.values) {
      p.exchange.left(id);
    }
  }

  void deliver(String from, LiveKeyMessage message, String? to) {
    sent.add((from, to, message.toJson()['t']! as String));
    final bytes = message.encode();
    scheduleMicrotask(() {
      for (final p in phones.values) {
        if (p.id == from || (to != null && p.id != to)) continue;
        p.exchange.receive(from, LiveKeyMessage.decode(bytes)!);
      }
    });
  }
}

class _Phone implements LiveKeyRoom {
  _Phone(this.bus, this.id) {
    exchange = LiveKeyExchange(
      broadcastId: 'b1',
      me: id,
      room: this,
      onKey: (key) async => keys.add(key.keyId),
      onChange: () {},
    );
  }

  final _Bus bus;
  final String id;
  late final LiveKeyExchange exchange;
  final keys = <String>[];

  String? get keyId => exchange.key?.keyId;

  @override
  Set<String> get others => {for (final p in bus.phones.keys) if (p != id && !bus.hidden.contains(p)) p};

  @override
  bool isHost(String identity) => bus.host == identity;

  @override
  bool isOnStage(String identity) => bus.stage.contains(identity);

  @override
  Future<void> send(LiveKeyMessage message, {String? to}) async => bus.deliver(id, message, to);
}

/// Lets messages, zero-length timers and the key callbacks run.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

void main() {
  test('a sealed room key opens only for the phone it was sealed for', () {
    final key = LiveRoomKey.generate('b1');
    final host = E2eeKeyPair.generate();
    final guest = E2eeKeyPair.generate();
    final stranger = E2eeKeyPair.generate();

    final box = key.sealFor(host, guest.publicKey)!;
    final opened = LiveRoomKey.open(guest, host.publicKey, box, 'b1')!;
    expect(opened.keyId, key.keyId);
    expect(opened.safetyCode, key.safetyCode);
    expect(opened.safetyCode, matches(RegExp(r'^\d{4} \d{4} \d{4}$')));

    expect(LiveRoomKey.open(stranger, host.publicKey, box, 'b1'), isNull, reason: 'someone else cannot open it');
    expect(LiveRoomKey.open(guest, host.publicKey, box, 'b2'), isNull, reason: 'bound to its broadcast');
    expect(key.keyId, isNot(contains(key.audioKey)), reason: 'the key id gives nothing away');
  });

  testWidgets('the host makes the key; everyone who joins gets the same one and the room is verified', (tester) async {
    final bus = _Bus();
    final host = bus.join('host', amHost: true);
    await tester.pump(LiveKeyExchange.hostMakesAfter);
    await _settle(tester);
    expect(host.keyId, isNotNull);

    final ayse = bus.join('ayse');
    final mert = bus.join('mert');
    await _settle(tester);
    expect(ayse.keyId, host.keyId);
    expect(mert.keyId, host.keyId);
    for (final p in [host, ayse, mert]) {
      expect(p.exchange.check, LiveCheck.verified, reason: p.id);
    }
    expect(bus.sent.where((m) => m.$3 == 'key' && m.$2 == 'ayse'), hasLength(1), reason: 'one holder sends the key');

    // Everyone who had the key leaves except Ayşe: a newcomer still gets it, from her.
    bus.leave('host');
    bus.leave('mert');
    final can = bus.join('can');
    await _settle(tester);
    expect(can.keyId, ayse.keyId);
    bus.leave('ayse');
    bus.leave('can');
    await tester.pump(LiveKeyExchange.confirmWithin);
  });

  testWidgets('with nobody holding a key, the first phone by identity makes one; two at once converge', (tester) async {
    final bus = _Bus();
    final b = bus.join('b');
    final a = bus.join('a');
    await tester.pump(LiveKeyExchange.othersMakeAfter);
    await _settle(tester);
    expect(a.keyId, isNotNull);
    expect(b.keyId, a.keyId);

    // Two phones that both make a key at the same moment (two hosts) end up with one: the smaller key id wins.
    final x = bus.join('x', amHost: true);
    final y = bus.join('y', amHost: true);
    expect(bus.host, 'y');
    await tester.pump(LiveKeyExchange.hostMakesAfter);
    await _settle(tester);
    for (var i = 0; i < 3; i++) {
      await tester.pump(LiveKeyExchange.helloEvery);
      await _settle(tester);
    }
    final ids = {a.keyId, b.keyId, x.keyId, y.keyId};
    expect(ids, hasLength(1), reason: 'everyone holds one key');
    for (final id in ['a', 'b', 'x', 'y']) {
      bus.leave(id);
    }
    await tester.pump(LiveKeyExchange.confirmWithin);
  });

  testWidgets('a hidden participant never gets the key', (tester) async {
    final bus = _Bus();
    final host = bus.join('host', amHost: true);
    await tester.pump(LiveKeyExchange.hostMakesAfter);
    bus.hidden.add('spy');
    final spy = bus.join('spy');
    for (var i = 0; i < 3; i++) {
      await tester.pump(LiveKeyExchange.helloEvery);
    }
    expect(host.keyId, isNotNull);
    expect(spy.keyId == host.keyId, isFalse);
    expect(bus.sent.where((m) => m.$3 == 'key' && m.$2 == 'spy'), isEmpty);
    bus.leave('spy');
    bus.leave('host');
    await tester.pump(LiveKeyExchange.confirmWithin);
  });

  testWidgets('a speaker that never confirms (an older app) is reported after a while', (tester) async {
    final bus = _Bus();
    final host = bus.join('host', amHost: true);
    await tester.pump(LiveKeyExchange.hostMakesAfter);
    await tester.pump();
    // An old phone on stage: present, but it never takes part in the exchange.
    bus.stage.add('old');
    bus.phones['old'] = _Phone(bus, 'old');
    host.exchange.stageChanged();
    expect(host.exchange.check, LiveCheck.waiting);
    await tester.pump(LiveKeyExchange.confirmWithin);
    expect(host.exchange.check, LiveCheck.unconfirmed);
    bus.leave('old');
    expect(host.exchange.check, LiveCheck.verified);
    bus.leave('host');
  });
}
