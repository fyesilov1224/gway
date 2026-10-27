import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messaging/messaging.dart';

const _me = MessageSender(id: 'me', username: 'ece', displayName: 'Ece');
const _deniz = MessageSender(id: 'deniz', username: 'deniz', displayName: 'Deniz');

Conversation _direct({
  String id = 'c1',
  MemberState myState = MemberState.active,
  MemberState peerState = MemberState.active,
  DateTime? readAt,
  String? blocker,
  int unread = 0,
}) =>
    Conversation(
      id: id,
      kind: ConversationKind.direct,
      myState: myState,
      peer: ChatPeer(id: 'deniz', username: 'deniz', displayName: 'Deniz', state: peerState, readAt: readAt),
      lastMessage: LastMessage(senderId: 'deniz', body: 'Selam', createdAt: DateTime(2026, 10, 22, 9)),
      unread: unread,
      blocker: blocker,
    );

ChatMessage _message(String id, MessageSender sender, DateTime at, {String body = 'Merhaba'}) =>
    ChatMessage(id: id, sender: sender, createdAt: at, body: body);

/// Records the writes the chat makes; reads come from the overridden providers.
class _FakeMessaging implements MessagingRepository {
  final sent = <(String, String)>[];
  final answers = <(String, bool)>[];
  final reads = <String>[];

  @override
  Future<Result<void>> send(String conversationId, {String body = '', ImageUpload? image}) async {
    sent.add((conversationId, body));
    return const Ok(null);
  }

  @override
  Future<Result<void>> answerRequest(String conversationId, {required bool accept}) async {
    answers.add((conversationId, accept));
    return const Ok(null);
  }

  @override
  Future<Result<void>> markRead(String conversationId) async {
    reads.add(conversationId);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeMessaging> _pumpChat(WidgetTester tester, ChatThread thread) async {
  final fake = _FakeMessaging();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      messagingRepositoryProvider.overrideWithValue(fake),
      currentUserIdProvider.overrideWithValue('me'),
      chatProvider.overrideWith((ref, id) => Stream.value(thread)),
      conversationsProvider.overrideWith((ref) => Stream.value(const [])),
    ],
    child: MaterialApp(
      theme: GxTheme.light(),
      home: ChatScreen(conversationId: thread.conversation.id, onOpenProfile: (_, _) {}, onOpenGroup: (_, _) {}),
    ),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('chat times: the hour today, then "Dün", then the date', () {
    final now = DateTime(2026, 10, 22, 18);
    expect(formatChatTime(DateTime(2026, 10, 22, 9, 5), now: now), '09:05');
    expect(formatChatTime(DateTime(2026, 10, 21, 23), now: now), 'Dün');
    expect(formatChatTime(DateTime(2026, 10, 18, 12), now: now), '18 Ekim 2026');
  });

  test('previews and blockers read in Turkish', () {
    expect(LastMessage(senderId: 'a', body: '', createdAt: DateTime(2026), hasImage: true).preview, 'Fotoğraf');
    expect(LastMessage(senderId: 'a', body: 'x', createdAt: DateTime(2026), deleted: true).preview, 'Mesaj silindi');
    expect(_direct(blocker: 'message_declined').blockerText, 'Bu kişi mesaj isteğini kabul etmedi.');
    expect(_direct(blocker: 'something_new').blockerText, 'Bu sohbete şu anda yazamazsın.');
    expect(_direct().blockerText, isNull);
  });

  for (final (allowed, shown) in [(true, findsOneWidget), (false, findsNothing)]) {
    testWidgets('the profile message button shows only when messaging is allowed ($allowed)', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [canMessageProvider.overrideWith((ref, id) async => allowed)],
        child: MaterialApp(theme: GxTheme.light(), home: const Scaffold(body: MessageUserButton(userId: 'deniz'))),
      ));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mesaj gönder'), shown);
    });
  }

  testWidgets('a locked match chat offers the package instead of the composer', (tester) async {
    final thread = ChatThread(conversation: _direct(blocker: 'match_chat_locked'), messages: const []);
    String? opened;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        messagingRepositoryProvider.overrideWithValue(_FakeMessaging()),
        currentUserIdProvider.overrideWithValue('me'),
        chatProvider.overrideWith((ref, id) => Stream.value(thread)),
        conversationsProvider.overrideWith((ref) => Stream.value(const [])),
        packageOpenerProvider.overrideWithValue((_, slug) => opened = slug),
      ],
      child: MaterialApp(
        theme: GxTheme.light(),
        home: ChatScreen(conversationId: 'c1', onOpenProfile: (_, _) {}, onOpenGroup: (_, _) {}),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Eşleşme Sohbeti paketi'), findsOneWidget);
    await tester.tap(find.text('Paketi incele'));
    expect(opened, 'matching_chat');
  });

  testWidgets('requests wait in their own tab', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        conversationsProvider.overrideWith((ref) => Stream.value([
              _direct(unread: 2),
              _direct(id: 'c2', myState: MemberState.request, unread: 1),
            ])),
      ],
      child: MaterialApp(theme: GxTheme.light(), home: ConversationsScreen(onFindPeople: (_) {})),
    ));
    await tester.pumpAndSettle();

    expect(find.text('İstekler (1)'), findsOneWidget);
    expect(find.text('Deniz'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('İstekler (1)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Eski mesaj istekleri'), findsOneWidget);
  });

  testWidgets('an empty inbox suggests finding people', (tester) async {
    var asked = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        conversationsProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: MaterialApp(theme: GxTheme.light(), home: ConversationsScreen(onFindPeople: (_) => asked = true)),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kişi bul'));
    expect(asked, isTrue);
  });

  testWidgets('a request is accepted before replying and is not marked read', (tester) async {
    final fake = await _pumpChat(
      tester,
      ChatThread(
        conversation: _direct(myState: MemberState.request, blocker: 'message_request_pending', unread: 1),
        messages: [_message('m1', _deniz, DateTime(2026, 10, 22, 9))],
      ),
    );

    expect(find.textContaining('sana mesaj göndermek istiyor'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(fake.reads, isEmpty);

    await tester.tap(find.text('Kabul et'));
    await tester.pumpAndSettle();
    expect(fake.answers.single, ('c1', true));
  });

  testWidgets('opening an unread chat marks it read; the read time shows "Görüldü"', (tester) async {
    final fake = await _pumpChat(
      tester,
      ChatThread(
        conversation: _direct(unread: 1, readAt: DateTime(2026, 10, 22, 10)),
        messages: [
          _message('m1', _me, DateTime(2026, 10, 22, 9), body: 'Yarın geliyor musun?'),
          _message('m2', _deniz, DateTime(2026, 10, 22, 9, 30), body: 'Evet'),
        ],
      ),
    );

    expect(fake.reads, ['c1']);
    expect(find.text('09:00 · Görüldü'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Harika  ');
    await tester.tap(find.byTooltip('Gönder'));
    await tester.pumpAndSettle();
    expect(fake.sent.single, ('c1', 'Harika'));
  });

  testWidgets('a pending request hides read receipts and a blocker replaces the composer', (tester) async {
    await _pumpChat(
      tester,
      ChatThread(
        conversation: _direct(peerState: MemberState.request, blocker: 'blocked'),
        messages: [_message('m1', _me, DateTime(2026, 10, 22, 9))],
      ),
    );

    expect(find.textContaining('Mesaj isteğin iletildi'), findsOneWidget);
    expect(find.text('09:00 · Gönderildi'), findsOneWidget);
    expect(find.text('Engel olduğu için bu sohbete yazılamıyor.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('deleted and removed messages keep their place without content', (tester) async {
    await _pumpChat(
      tester,
      ChatThread(
        conversation: _direct(),
        messages: [
          ChatMessage(id: 'm1', sender: _deniz, createdAt: DateTime(2026, 10, 22, 9), deletedAt: DateTime(2026, 10, 22, 9, 1)),
          ChatMessage(
              id: 'm2', sender: _deniz, createdAt: DateTime(2026, 10, 22, 9, 2), deletedAt: DateTime(2026, 10, 22, 9, 3), removed: true),
        ],
      ),
    );

    expect(find.text('Bu mesaj silindi.'), findsOneWidget);
    expect(find.text('Bu mesaj kaldırıldı.'), findsOneWidget);
    expect(find.byTooltip('Mesaj seçenekleri'), findsNothing);
  });
}
