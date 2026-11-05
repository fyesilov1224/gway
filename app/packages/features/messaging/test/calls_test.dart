import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:messaging/messaging.dart';

const _join = CallJoin(callId: 'k1', url: 'wss://livekit.test', token: 't');

CallInfo _call(CallStatus status, {String caller = 'deniz', String callee = 'me', DateTime? answeredAt}) => CallInfo(
      id: 'k1',
      conversationId: 'c1',
      callerId: caller,
      calleeId: callee,
      status: status,
      createdAt: DateTime.now(),
      answeredAt: answeredAt,
    );

class _FakeCalls implements CallsRepository {
  _FakeCalls({this.eligible = const CallEligibility(allowed: false, code: 'call.not_matched')});

  final CallEligibility eligible;
  final rows = StreamController<CallInfo?>.broadcast();
  final ringing = StreamController<List<CallInfo>>.broadcast();
  final actions = <String>[];
  final notes = <String?>[];
  final requestedGroups = <String>[];
  final decisions = <String>[];
  CallPermission permission = const CallPermission();
  List<CallGroup> groups = const [CallGroup(id: 'g1', name: 'Doğa Yürüyüşü'), CallGroup(id: 'g2', name: 'Koşu Kulübü')];
  GroupCallDesk? desk;

  @override
  Future<Result<CallEligibility>> eligibility(String conversationId) async => Ok(eligible);

  @override
  Future<Result<CallJoin>> start(String conversationId) async {
    actions.add('start $conversationId');
    return const Ok(_join);
  }

  @override
  Future<Result<CallJoin>> accept(String callId) async {
    actions.add('accept');
    return const Ok(_join);
  }

  @override
  Future<Result<CallJoin>> rejoin(String callId) async {
    actions.add('rejoin');
    return const Ok(_join);
  }

  @override
  Future<Result<void>> decline(String callId) async {
    actions.add('decline');
    return const Ok(null);
  }

  @override
  Future<Result<void>> end(String callId) async {
    actions.add('end');
    return const Ok(null);
  }

  @override
  Stream<CallInfo?> watch(String callId) => rows.stream;

  @override
  Stream<List<CallInfo>> incoming() => ringing.stream;

  @override
  Future<Result<CallPeer>> peer(String userId) async =>
      const Ok(CallPeer(id: 'deniz', displayName: 'Deniz', username: 'deniz'));

  @override
  Future<Result<CallPermission>> myPermission() async => Ok(permission);

  @override
  Future<Result<List<CallGroup>>> myGroups() async => Ok(groups);

  @override
  Future<Result<void>> requestPermission(String groupId, String? note) async {
    requestedGroups.add(groupId);
    notes.add(note);
    permission = const CallPermission(status: CallPermissionStatus.requested, groupName: 'Koşu Kulübü');
    return const Ok(null);
  }

  @override
  Future<Result<GroupCallDesk?>> groupDesk(String groupId) async => Ok(desk);

  @override
  Future<Result<void>> decide(String groupId, String userId, {required bool active, String? reason}) async {
    decisions.add('$userId ${active ? 'open' : 'close'} ${reason ?? ''}'.trim());
    return const Ok(null);
  }
}

class _FakeSession extends CallSession {
  final joins = <CallJoin>[];
  var left = 0;

  @override
  Future<void> connect(CallJoin join) async {
    joins.add(join);
    connection = CallConnection.connected;
    notifyListeners();
  }

  @override
  Future<void> leave() async {
    left++;
    connection = CallConnection.idle;
  }
}

class _FakeKeepAlive implements CallKeepAlive {
  final log = <String>[];

  @override
  Future<void> start() async => log.add('start');

  @override
  Future<void> stop() async => log.add('stop');

  @override
  Future<bool> toBackground() async {
    log.add('background');
    return true;
  }
}

class _FakeRinger implements CallRinger {
  CallTone? playing;
  final played = <CallTone>[];

  bool get ringing => playing == CallTone.incoming;

  @override
  Future<void> start(CallTone tone) async => played.add(playing = tone);

  @override
  Future<void> stop() async => playing = null;
}

/// The phone's own call screen, recorded.
class _FakeNative implements NativeCalls {
  _FakeNative({this.supported = false});

  @override
  final bool supported;
  final log = <String>[];
  final choices = StreamController<NativeCallAction>.broadcast();
  List<String> answeredEarlier = const [];
  Set<String> answeredHere = const {};
  bool lockScreenAllowed = true;

  @override
  Future<void> ring({required String callId, required String caller}) async => log.add('ring $callId $caller');

  @override
  Future<void> end(String callId) async => log.add('end $callId');

  @override
  Stream<NativeCallAction> get actions => choices.stream;

  @override
  Future<List<String>> answeredBeforeStart() async => answeredEarlier;

  @override
  Future<bool> answered(String callId) async => answeredHere.contains(callId);

  @override
  Future<bool> canRingOnLockScreen() async => lockScreenAllowed;

  @override
  Future<void> openLockScreenSetting() async => log.add('lock screen setting');
}

typedef _Harness = ({
  _FakeCalls calls,
  _FakeSession session,
  _FakeRinger ringer,
  _FakeNative native,
  _FakeKeepAlive keepAlive,
});

Future<_Harness> _pumpCall(
  WidgetTester tester, {
  CallJoin? join,
  bool answer = false,
  _FakeNative? native,
  CallScreens? screens,
}) async {
  final harness = (
    calls: _FakeCalls(),
    session: _FakeSession(),
    ringer: _FakeRinger(),
    native: native ?? _FakeNative(),
    keepAlive: _FakeKeepAlive(),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('me'),
      callsRepositoryProvider.overrideWithValue(harness.calls),
      callSessionFactoryProvider.overrideWithValue(() => harness.session),
      callRingerProvider.overrideWithValue(harness.ringer),
      nativeCallsProvider.overrideWithValue(harness.native),
      callKeepAliveProvider.overrideWithValue(harness.keepAlive),
      if (screens != null) callScreensProvider.overrideWithValue(screens),
    ],
    child: MaterialApp(theme: GwTheme.light(), home: CallScreen(callId: 'k1', join: join, answer: answer)),
  ));
  return harness;
}

Future<void> _emit(WidgetTester tester, _Harness h, CallInfo? call) async {
  h.calls.rows.add(call);
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('an incoming call rings, connects when answered, and says when it is over', (tester) async {
    final h = await _pumpCall(tester);
    await _emit(tester, h, _call(CallStatus.ringing));
    expect(find.text('Seni sesli arıyor…'), findsOneWidget);
    expect(find.text('Deniz'), findsOneWidget);
    expect(h.ringer.ringing, isTrue);
    expect(h.session.joins, isEmpty, reason: 'no audio before answering');

    await tester.tap(find.text('Cevapla'));
    await tester.pump();
    expect(h.calls.actions, ['accept']);
    expect(h.ringer.ringing, isFalse);
    expect(h.session.joins, [_join]);

    await _emit(tester, h, _call(CallStatus.active, answeredAt: DateTime.now()));
    expect(find.text('00:00'), findsOneWidget);
    expect(find.textContaining('kaydedilmez'), findsOneWidget);
    expect(h.calls.actions, ['accept'], reason: 'already connected, no second token');

    await _emit(tester, h, _call(CallStatus.ended));
    expect(find.text('Görüşme bitti'), findsOneWidget);
    expect(h.session.left, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('declining a ringing call stops the ring', (tester) async {
    final h = await _pumpCall(tester);
    await _emit(tester, h, _call(CallStatus.ringing));
    await tester.tap(find.text('Reddet'));
    await tester.pump();
    expect(h.calls.actions, ['decline']);
    await _emit(tester, h, _call(CallStatus.declined));
    expect(find.text('Aramayı reddettin'), findsOneWidget);
    expect(h.ringer.ringing, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the caller hears the ringback, joins at once and can hang up', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.ringing, caller: 'me', callee: 'deniz'));
    expect(find.text('Aranıyor…'), findsOneWidget);
    expect(h.ringer.played, [CallTone.outgoing], reason: 'the ringback, not the incoming ring');
    expect(h.ringer.playing, CallTone.outgoing);
    expect(h.session.joins, [_join]);
    expect(h.calls.actions, isEmpty, reason: 'the join from starting the call is used');

    await tester.tap(find.text('Bitir'));
    await tester.pump();
    expect(h.calls.actions, ['end']);
    await _emit(tester, h, _call(CallStatus.canceled, caller: 'me', callee: 'deniz'));
    expect(h.ringer.playing, isNull, reason: 'the ringback stops when the call is over');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the call goes on in the background; back never hangs up', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.ringing, caller: 'me', callee: 'deniz'));
    expect(h.keepAlive.log, ['start'], reason: 'the audio is connected while it rings');

    await _emit(tester, h, _call(CallStatus.active, caller: 'me', callee: 'deniz', answeredAt: DateTime.now()));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(h.keepAlive.log, ['start', 'background']);
    expect(h.calls.actions, isEmpty, reason: 'back does not end the call');
    expect(find.byType(CallScreen), findsOneWidget);

    await _emit(tester, h, _call(CallStatus.ended, caller: 'me', callee: 'deniz'));
    expect(h.keepAlive.log, ['start', 'background', 'stop']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the phones check the keys themselves: green when they match, the code only on request', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.active, caller: 'me', callee: 'deniz', answeredAt: DateTime.now()));
    expect(find.text('Şifreli bağlantı kuruluyor…'), findsOneWidget);

    h.session
      ..secure = true
      ..safetyCode = '1234 5678 9012'
      ..notifyListeners();
    await tester.pump();
    expect(find.text('Şifreleme doğrulanıyor…'), findsOneWidget);
    expect(find.text('1234 5678 9012'), findsNothing);

    h.session
      ..check = CallCheck.verified
      ..notifyListeners();
    await tester.pump();
    expect(find.text('Güvenli görüşme'), findsOneWidget);
    expect(find.text('1234 5678 9012'), findsNothing, reason: 'the code stays hidden');

    await tester.ensureVisible(find.text('Güvenlik kodunu göster'));
    await tester.tap(find.text('Güvenlik kodunu göster'));
    await tester.pump();
    expect(find.text('1234 5678 9012'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('different keys on the two phones: a warning instead of the green note', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.active, caller: 'me', callee: 'deniz', answeredAt: DateTime.now()));
    h.session
      ..secure = true
      ..safetyCode = '1234 5678 9012'
      ..check = CallCheck.mismatch
      ..notifyListeners();
    await tester.pump();
    expect(find.textContaining('Şifreleme doğrulanamadı'), findsOneWidget);
    expect(find.text('Güvenli görüşme'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the ringback stops once the other person answers', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.ringing, caller: 'me', callee: 'deniz'));
    await _emit(tester, h, _call(CallStatus.active, caller: 'me', callee: 'deniz', answeredAt: DateTime.now()));
    expect(h.ringer.playing, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets("answered on the phone's call screen: the app answers at once, without ringing again", (tester) async {
    final h = await _pumpCall(tester, answer: true);
    expect(h.native.log, ['end k1'], reason: "the app takes over from the phone's screen");
    await _emit(tester, h, _call(CallStatus.ringing));
    expect(h.calls.actions, ['accept']);
    expect(h.session.joins, [_join]);
    expect(h.ringer.played, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  test("a ringing push opens the phone's call screen and call_ended closes it", () async {
    final native = _FakeNative(supported: true);
    Future<bool> ringing(String _) async => true;
    await handleCallPush({'type': 'call_incoming', 'call_id': 'k1', 'title': 'deniz'}, calls: native, stillRinging: ringing);
    await handleCallPush({'type': 'call_ended', 'call_id': 'k1'}, calls: native, stillRinging: ringing);
    await handleCallPush({'type': 'message', 'conversation_id': 'c1'}, calls: native, stillRinging: ringing);
    expect(native.log, ['ring k1 deniz', 'end k1']);
  });

  test('a ringing push that arrives after the call was answered or ended does not ring', () async {
    final native = _FakeNative(supported: true);
    await handleCallPush({'type': 'call_incoming', 'call_id': 'k1', 'title': 'deniz'},
        calls: native, stillRinging: (_) async => false);
    expect(native.log, isEmpty);
  });

  testWidgets("answered on the phone's call screen after the app's screen opened: answered once, not asked again",
      (tester) async {
    final screens = CallScreens();
    expect(screens.claim('k1'), isTrue);
    final h = await _pumpCall(tester, screens: screens);
    await _emit(tester, h, _call(CallStatus.ringing));
    expect(find.text('Cevapla'), findsOneWidget);

    expect(screens.claim('k1', answer: true), isFalse, reason: 'no second screen');
    await tester.pump();
    await tester.pump();
    expect(h.calls.actions, ['accept']);
    expect(h.ringer.ringing, isFalse);

    expect(screens.claim('k1', answer: true), isFalse);
    await tester.pump();
    expect(h.calls.actions, ['accept'], reason: 'answered once');
    await tester.pumpWidget(const SizedBox());
    expect(screens.claim('k1'), isTrue, reason: 'the closed screen let go of the call');
  });

  testWidgets("the phone's call screen was answered just before the app's screen opened: no second answer button",
      (tester) async {
    final native = _FakeNative(supported: true)..answeredHere = {'k1'};
    final h = await _pumpCall(tester, native: native);
    await _emit(tester, h, _call(CallStatus.ringing));
    expect(h.calls.actions, ['accept']);
    expect(native.log, ['end k1']);
    await tester.pumpWidget(const SizedBox());
  });

  test('one screen per call: asks a moment apart open one screen', () {
    final screens = CallScreens();
    expect(screens.claim('k1'), isTrue);
    expect(screens.claim('k1'), isFalse);
    expect(screens.claim('k1', answer: true), isFalse);
    expect(screens.attach('k1', () {}), isTrue, reason: 'the answer waits for the screen');
    expect(screens.claim('k2'), isTrue);
  });

  Future<(_FakeCalls, _FakeNative, List<String>)> pumpBridge(WidgetTester tester, {List<String> earlier = const []}) async {
    final calls = _FakeCalls();
    final native = _FakeNative(supported: true)..answeredEarlier = earlier;
    final opened = <String>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        callsRepositoryProvider.overrideWithValue(calls),
        nativeCallsProvider.overrideWithValue(native),
      ],
      child: NativeCallBridge(
        openCall: (id, {answer = false}) => opened.add('$id $answer'),
        child: IncomingCallAlerts(openCall: (id) => opened.add('in-app $id'), child: const SizedBox()),
      ),
    ));
    await tester.pump();
    return (calls, native, opened);
  }

  testWidgets("answering on the phone's screen opens the call; declining tells the server", (tester) async {
    final (calls, native, opened) = await pumpBridge(tester, earlier: ['k0']);
    expect(opened, ['k0 true'], reason: 'answered before the app was running');
    native.choices.add((callId: 'k1', choice: NativeCallChoice.answer));
    native.choices.add((callId: 'k2', choice: NativeCallChoice.decline));
    await tester.pump();
    expect(opened, ['k0 true', 'k1 true']);
    expect(calls.actions, ['decline']);
  });

  testWidgets("in the background the phone's screen rings; the app's own opens when it comes to the front",
      (tester) async {
    final (calls, _, opened) = await pumpBridge(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    calls.ringing.add([_call(CallStatus.ringing)]);
    await tester.pump();
    expect(opened, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(opened, ['in-app k1']);
  });

  testWidgets('back on a call this phone is not in: a fresh token joins it', (tester) async {
    final h = await _pumpCall(tester);
    await _emit(tester, h, _call(CallStatus.active, answeredAt: DateTime.now()));
    expect(h.calls.actions, ['rejoin']);
    expect(h.session.joins, [_join]);
    await tester.pumpWidget(const SizedBox());
  });

  Future<_FakeCalls> pumpChatHeader(WidgetTester tester, CallEligibility eligible) async {
    final calls = _FakeCalls(eligible: eligible);
    const conversation = Conversation(
      id: 'c1',
      kind: ConversationKind.direct,
      myState: MemberState.active,
      peer: ChatPeer(id: 'deniz', username: 'deniz', displayName: 'Deniz', state: MemberState.active),
    );
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => ChatScreen(conversationId: 'c1', onOpenProfile: (_, _) {}, onOpenGroup: (_, _) {}),
      ),
      GoRoute(path: '/calls/:id', builder: (_, state) => Text('arama ${state.pathParameters['id']} ${state.extra != null}')),
      GoRoute(path: MessagingRoutes.callSettings, builder: (_, _) => const Text('yetki sayfası')),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        callsRepositoryProvider.overrideWithValue(calls),
        chatProvider.overrideWith((ref, id) => Stream.value(const ChatThread(conversation: conversation, messages: []))),
        conversationsProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
    ));
    await tester.pumpAndSettle();
    return calls;
  }

  testWidgets('a match chat calls from its header and opens the call', (tester) async {
    final calls = await pumpChatHeader(tester, const CallEligibility(allowed: true));
    await tester.tap(find.byTooltip('Sesli ara'));
    await tester.pumpAndSettle();
    expect(calls.actions, ['start c1']);
    expect(find.text('arama k1 true'), findsOneWidget);
  });

  testWidgets('without your own permission the button says why and links to the request', (tester) async {
    await pumpChatHeader(
      tester,
      const CallEligibility(allowed: false, code: 'call.no_permission', message: 'Sesli görüşme yetkin yok.'),
    );
    await tester.tap(find.byTooltip('Sesli ara'));
    await tester.pumpAndSettle();
    expect(find.text('Sesli görüşme yetkin yok.'), findsOneWidget);
    await tester.tap(find.text('Talep et'));
    await tester.pumpAndSettle();
    expect(find.text('yetki sayfası'), findsOneWidget);
  });

  testWidgets('a chat that is neither a match nor teammates shows a dim button that says why', (tester) async {
    final calls = await pumpChatHeader(
      tester,
      const CallEligibility(
        allowed: false,
        code: 'call.not_matched',
        message: 'Sesli görüşme yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla yapılabilir.',
      ),
    );
    await tester.tap(find.byTooltip('Sesli ara'));
    await tester.pumpAndSettle();
    expect(find.text('Sesli görüşme yalnızca eşleştiğin kişilerle ve ekip arkadaşlarınla yapılabilir.'), findsOneWidget);
    expect(find.text('Talep et'), findsNothing);
    expect(calls.actions, isEmpty);
  });

  testWidgets('a chat that cannot call at all shows no call button', (tester) async {
    await pumpChatHeader(tester, const CallEligibility(allowed: false, code: 'call.forbidden'));
    expect(find.byTooltip('Sesli ara'), findsNothing);
  });

  Future<_FakeCalls> pumpPermission(WidgetTester tester, CallPermission permission, {_FakeNative? native}) async {
    final calls = _FakeCalls()..permission = permission;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        callsRepositoryProvider.overrideWithValue(calls),
        nativeCallsProvider.overrideWithValue(native ?? _FakeNative()),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const CallPermissionScreen()),
    ));
    await tester.pumpAndSettle();
    return calls;
  }

  testWidgets('asking a chosen group for voice calls sends the note and shows it under review', (tester) async {
    final calls = await pumpPermission(tester, const CallPermission());
    expect(find.text('Talep edilmedi'), findsOneWidget);
    await tester.tap(find.text('Doğa Yürüyüşü'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Koşu Kulübü').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Eşleştiğim kişiyle konuşmak istiyorum');
    await tester.ensureVisible(find.text('Talep et'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Talep et'));
    await tester.pumpAndSettle();
    expect(calls.requestedGroups, ['g2']);
    expect(calls.notes, ['Eşleştiğim kişiyle konuşmak istiyorum']);
    expect(find.text('İnceleniyor'), findsOneWidget);
    expect(find.textContaining('Koşu Kulübü yöneticilerine'), findsOneWidget);
  });

  testWidgets('without a group there is nobody to ask', (tester) async {
    final calls = _FakeCalls()..groups = const [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        callsRepositoryProvider.overrideWithValue(calls),
        nativeCallsProvider.overrideWithValue(_FakeNative()),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const CallPermissionScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('önce bir gruba katıl'), findsOneWidget);
    expect(find.text('Talep et'), findsNothing);
  });

  testWidgets('a group manager opens a request and cannot close a higher rank', (tester) async {
    final calls = _FakeCalls()
      ..desk = const GroupCallDesk(rank: 80, items: [
        GroupCallRequest(userId: 'u1', username: 'ayse', displayName: 'Ayşe', rank: 10, status: CallPermissionStatus.requested, note: 'Lütfen'),
        GroupCallRequest(userId: 'u2', username: 'sahip', displayName: 'Sahip', rank: 100, status: CallPermissionStatus.requested),
      ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [callsRepositoryProvider.overrideWithValue(calls)],
      child: MaterialApp(theme: GwTheme.light(), home: const GroupCallRequestsScreen(groupId: 'g1', groupName: 'Koşu Kulübü')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Notu: Lütfen'), findsOneWidget);
    expect(find.widgetWithText(GwButton, 'Reddet'), findsOneWidget);
    expect(find.textContaining('yalnızca açabilirsin'), findsOneWidget);
    await tester.tap(find.widgetWithText(GwButton, 'Aç').first);
    await tester.pumpAndSettle();
    expect(calls.decisions, ['u1 open']);

    await tester.tap(find.widgetWithText(GwButton, 'Reddet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Şimdilik değil');
    await tester.tap(find.widgetWithText(GwButton, 'Reddet').last);
    await tester.pumpAndSettle();
    expect(calls.decisions, ['u1 open', 'u1 close Şimdilik değil']);
  });

  testWidgets('a closed permission shows the reason and waits a week before asking again', (tester) async {
    await pumpPermission(
      tester,
      CallPermission(status: CallPermissionStatus.revoked, reason: 'Şikayet üzerine', decidedAt: DateTime.now(), decidedByPerson: true),
    );

    expect(find.text('Gerekçe: Şikayet üzerine'), findsOneWidget);
    expect(find.textContaining('sonrasında yeniden talep edebilirsin'), findsOneWidget);
    expect(find.text('Talep et'), findsNothing);
  });

  testWidgets('with calls open but no lock-screen permission, the settings ask for it', (tester) async {
    final native = _FakeNative(supported: true)..lockScreenAllowed = false;
    await pumpPermission(tester, const CallPermission(status: CallPermissionStatus.active), native: native);
    expect(find.text('Kilit ekranında gelen arama'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(GwButton, 'İzni aç'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GwButton, 'İzni aç'), warnIfMissed: true);
    await tester.pump();
    expect(native.log, ['lock screen setting']);
  });

  testWidgets('with the lock-screen permission there is nothing to ask', (tester) async {
    await pumpPermission(tester, const CallPermission(status: CallPermissionStatus.active), native: _FakeNative(supported: true));
    expect(find.text('Kilit ekranında gelen arama'), findsNothing);
  });
}
