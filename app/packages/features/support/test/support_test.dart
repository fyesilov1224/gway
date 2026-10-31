import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:support/support.dart';

final _now = DateTime(2026, 10, 19, 12);

SupportTicket _ticket({
  String id = 't1',
  SupportKind kind = SupportKind.problem,
  SupportStatus status = SupportStatus.inProgress,
  bool unread = false,
  String? group,
}) =>
    SupportTicket(
      id: id,
      kind: kind,
      subject: 'Kapak fotoğrafı yüklenmiyor',
      status: status,
      createdAt: _now.subtract(const Duration(days: 2)),
      lastMessageAt: _now,
      lastFromStaff: unread,
      userReadAt: unread ? _now.subtract(const Duration(hours: 1)) : _now,
      groupName: group,
    );

class _FakeSupport implements SupportRepository {
  final created = <NewTicket>[];
  final replies = <(String, String)>[];
  final read = <String>[];

  @override
  Future<Result<String>> create(NewTicket ticket) async {
    created.add(ticket);
    return const Ok('t9');
  }

  @override
  Future<Result<void>> reply(String ticketId, String body, {List<ImageUpload> images = const []}) async {
    replies.add((ticketId, body));
    return const Ok(null);
  }

  @override
  Future<Result<void>> markRead(String ticketId) async {
    read.add(ticketId);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _thread = SupportThread(
  ticket: _ticket(group: 'Doğa Yürüyüşçüleri'),
  messages: [
    SupportMessage(id: 1, fromStaff: false, body: 'Kapak seçince hata veriyor.', createdAt: _now.subtract(const Duration(days: 2))),
    SupportMessage(id: 2, fromStaff: true, body: 'İnceliyoruz, teşekkürler.', createdAt: _now),
  ],
);

Widget _app(
  Widget child, {
  _FakeSupport? repo,
  List<SupportTicket> tickets = const [],
  List<ManagedGroup> groups = const [],
  SupportThread? thread,
}) =>
    ProviderScope(
      overrides: [
        supportRepositoryProvider.overrideWithValue(repo ?? _FakeSupport()),
        currentUserIdProvider.overrideWithValue('u1'),
        myTicketsProvider.overrideWith((ref) async => tickets),
        managedGroupsProvider.overrideWith((ref) async => groups),
        supportThreadProvider.overrideWith((ref, id) async => thread ?? _thread),
      ],
      child: MaterialApp.router(
        theme: GwTheme.light(),
        routerConfig: GoRouter(routes: [
          GoRoute(path: '/', builder: (_, _) => child),
          GoRoute(path: '/support/t/:id', builder: (_, state) => Text('ticket ${state.pathParameters['id']}')),
        ]),
      ),
    );

Future<void> _pump(WidgetTester tester, Widget app, {Size size = const Size(390, 844), double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  test('a team reply after the last visit is unread', () {
    expect(_ticket(unread: true).hasUnreadReply, isTrue);
    expect(_ticket().hasUnreadReply, isFalse);
  });

  group('support list', () {
    testWidgets('empty list explains and offers a new message', (tester) async {
      await _pump(tester, _app(const SupportScreen()));

      expect(find.textContaining('platform ekibine yazabilirsin'), findsOneWidget);
      expect(find.text('Yeni mesaj'), findsWidgets);
    });

    testWidgets('shows kind, status and unread replies at 130% text', (tester) async {
      await _pump(
        tester,
        _app(const SupportScreen(), tickets: [
          _ticket(unread: true),
          _ticket(id: 't2', kind: SupportKind.suggestion, status: SupportStatus.resolved, group: 'Akustik Geceler'),
        ]),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Yeni yanıt'), findsOneWidget);
      expect(find.text('İnceleniyor'), findsOneWidget);
      expect(find.text('Çözüldü'), findsOneWidget);
      expect(find.textContaining('İstek · Akustik Geceler'), findsOneWidget);
    });
  });

  group('new message', () {
    testWidgets('needs a kind, a subject and a description', (tester) async {
      final repo = _FakeSupport();
      await _pump(tester, _app(const NewTicketScreen(), repo: repo), size: const Size(1024, 1400));

      await tester.tap(find.text('Gönder'));
      await tester.pumpAndSettle();

      expect(find.text('Bir tür seç.'), findsOneWidget);
      expect(find.text('Kısa bir konu yaz.'), findsOneWidget);
      expect(find.text('Ne olduğunu kısaca anlat.'), findsOneWidget);
      expect(repo.created, isEmpty);
    });

    testWidgets('a group manager sends a request about their group with a screenshot', (tester) async {
      final repo = _FakeSupport();
      final screenshot = ImageUpload(bytes: Uint8List.fromList(_png), fileName: 'ekran.png');
      await _pump(
        tester,
        _app(
          NewTicketScreen(groupId: 'g1', pickImage: () async => screenshot),
          repo: repo,
          groups: const [ManagedGroup(id: 'g1', name: 'Doğa Yürüyüşçüleri', handle: 'doga')],
        ),
        size: const Size(1024, 1400),
      );

      expect(find.text('Doğa Yürüyüşçüleri'), findsOneWidget, reason: 'the group from the group page is preselected');
      await tester.tap(find.text('Talep'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Konu'), 'Grup adresini değiştirmek istiyorum');
      await tester.enterText(find.widgetWithText(TextFormField, 'Açıklama'), 'Yeni adres: doga.istanbul');
      await tester.tap(find.textContaining('Ekran görüntüsü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gönder'));
      await tester.pumpAndSettle();

      expect(find.text('ticket t9'), findsOneWidget, reason: 'the new message opens');
      final sent = repo.created.single;
      expect((sent.kind, sent.groupId, sent.images.length), (SupportKind.request, 'g1', 1));
      expect(sent.subject, 'Grup adresini değiştirmek istiyorum');
    });
  });

  group('conversation', () {
    testWidgets('shows both sides, marks replies read and sends an answer', (tester) async {
      final repo = _FakeSupport();
      await _pump(tester, _app(const TicketScreen(ticketId: 't1'), repo: repo));

      expect(find.text('GWAY Ekibi'), findsOneWidget);
      expect(find.text('İnceliyoruz, teşekkürler.'), findsOneWidget);
      expect(find.text('Doğa Yürüyüşçüleri'), findsOneWidget);
      expect(repo.read, ['t1']);

      await tester.enterText(find.byType(TextField), 'Hâlâ olmuyor.');
      await tester.tap(find.byTooltip('Gönder'));
      await tester.pumpAndSettle();
      expect(repo.replies.single, ('t1', 'Hâlâ olmuyor.'));
    });

    testWidgets('a closed message takes no answer', (tester) async {
      await _pump(
        tester,
        _app(
          const TicketScreen(ticketId: 't1'),
          thread: SupportThread(ticket: _ticket(status: SupportStatus.closed), messages: _thread.messages),
        ),
      );

      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Bu mesaj kapatıldı'), findsOneWidget);
    });
  });
}

/// 1×1 transparent PNG.
const _png = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];
