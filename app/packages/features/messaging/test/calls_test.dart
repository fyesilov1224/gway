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
  final actions = <String>[];
  final notes = <String?>[];
  CallPermission permission = const CallPermission();

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
  Stream<List<CallInfo>> incoming() => const Stream.empty();

  @override
  Future<Result<CallPeer>> peer(String userId) async =>
      const Ok(CallPeer(id: 'deniz', displayName: 'Deniz', username: 'deniz'));

  @override
  Future<Result<CallPermission>> myPermission() async => Ok(permission);

  @override
  Future<Result<void>> requestPermission(String? note) async {
    notes.add(note);
    permission = const CallPermission(status: CallPermissionStatus.requested);
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

class _FakeRinger implements CallRinger {
  var ringing = false;
  var rang = false;

  @override
  Future<void> start() async => ringing = rang = true;

  @override
  Future<void> stop() async => ringing = false;
}

typedef _Harness = ({_FakeCalls calls, _FakeSession session, _FakeRinger ringer});

Future<_Harness> _pumpCall(WidgetTester tester, {CallJoin? join}) async {
  final harness = (calls: _FakeCalls(), session: _FakeSession(), ringer: _FakeRinger());
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('me'),
      callsRepositoryProvider.overrideWithValue(harness.calls),
      callSessionFactoryProvider.overrideWithValue(() => harness.session),
      callRingerProvider.overrideWithValue(harness.ringer),
    ],
    child: MaterialApp(theme: GwTheme.light(), home: CallScreen(callId: 'k1', join: join)),
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

  testWidgets('the caller hears nothing ring, joins at once and can hang up', (tester) async {
    final h = await _pumpCall(tester, join: _join);
    await _emit(tester, h, _call(CallStatus.ringing, caller: 'me', callee: 'deniz'));
    expect(find.text('Aranıyor…'), findsOneWidget);
    expect(h.ringer.rang, isFalse);
    expect(h.session.joins, [_join]);
    expect(h.calls.actions, isEmpty, reason: 'the join from starting the call is used');

    await tester.tap(find.text('Bitir'));
    await tester.pump();
    expect(h.calls.actions, ['end']);
    await tester.pumpWidget(const SizedBox());
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

  testWidgets('a chat that is not a match shows no call button', (tester) async {
    await pumpChatHeader(tester, const CallEligibility(allowed: false, code: 'call.not_matched'));
    expect(find.byTooltip('Sesli ara'), findsNothing);
  });

  Future<_FakeCalls> pumpPermission(WidgetTester tester, CallPermission permission) async {
    final calls = _FakeCalls()..permission = permission;
    await tester.pumpWidget(ProviderScope(
      overrides: [currentUserIdProvider.overrideWithValue('me'), callsRepositoryProvider.overrideWithValue(calls)],
      child: MaterialApp(theme: GwTheme.light(), home: const CallPermissionScreen()),
    ));
    await tester.pumpAndSettle();
    return calls;
  }

  testWidgets('asking for voice calls sends the note and shows it under review', (tester) async {
    final calls = await pumpPermission(tester, const CallPermission());
    expect(find.text('Talep edilmedi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Eşleştiğim kişiyle konuşmak istiyorum');
    await tester.ensureVisible(find.text('Talep et'));
    await tester.tap(find.text('Talep et'));
    await tester.pumpAndSettle();
    expect(calls.notes, ['Eşleştiğim kişiyle konuşmak istiyorum']);
    expect(find.text('İnceleniyor'), findsOneWidget);
  });

  testWidgets('a closed permission shows the reason and waits a week before asking again', (tester) async {
    await pumpPermission(
      tester,
      CallPermission(status: CallPermissionStatus.revoked, reason: 'Şikayet üzerine', decidedAt: DateTime.now()),
    );
    expect(find.text('Gerekçe: Şikayet üzerine'), findsOneWidget);
    expect(find.textContaining('sonrasında yeniden talep edebilirsin'), findsOneWidget);
    expect(find.text('Talep et'), findsNothing);
  });
}
