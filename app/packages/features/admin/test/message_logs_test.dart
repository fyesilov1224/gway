import 'package:admin/admin.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ayse = LogPerson(id: 'u1', username: 'ayse.k', displayName: 'Ayşe Kaya');
const _can = LogPerson(id: 'u2', username: 'can_dag', displayName: 'Can Dağ');

class _FakeLogs implements AdminMessageLogsRepository {
  final reasons = <String>[];

  @override
  Future<Result<LogConversationPage>> search({
    required String username,
    String? withUsername,
    LogConversationKind? kind,
    int page = 1,
    required String reason,
  }) async {
    reasons.add(reason);
    return Ok(LogConversationPage(
      user: _ayse,
      withUser: null,
      items: [
        LogConversation(
          id: 'c1',
          kind: LogConversationKind.direct,
          createdAt: DateTime(2026, 10, 1),
          lastMessageAt: DateTime(2026, 10, 30, 21, 5),
          messageCount: 12,
          targetMessageCount: 7,
          deletedCount: 1,
          peer: _can,
        ),
      ],
      page: 1,
      pageSize: 20,
      total: 1,
    ));
  }

  @override
  Future<Result<LogConversationView>> view(String conversationId, {required String reason, DateTime? before, String? query}) async {
    reasons.add(reason);
    return Ok(LogConversationView(
      conversation: LogConversation(
        id: conversationId,
        kind: LogConversationKind.direct,
        createdAt: DateTime(2026, 10, 1),
        lastMessageAt: DateTime(2026, 10, 30),
        messageCount: 2,
        targetMessageCount: 0,
        deletedCount: 1,
      ),
      participants: const [_ayse, _can],
      messages: [
        LogMessage(
          id: 'm1',
          sender: _ayse,
          body: 'Cumartesi geliyor musun?',
          imageUrl: null,
          hadImage: false,
          archived: false,
          createdAt: DateTime(2026, 10, 30, 20),
          deletedAt: null,
          removedReason: null,
          purgeAfter: null,
        ),
        LogMessage(
          id: 'm2',
          sender: _can,
          body: 'Silinen tehdit mesajı',
          imageUrl: null,
          hadImage: false,
          archived: true,
          createdAt: DateTime(2026, 10, 30, 21),
          deletedAt: DateTime(2026, 10, 30, 21, 5),
          removedReason: null,
          purgeAfter: DateTime(2027, 4, 28),
        ),
      ],
      hasOlder: false,
    ));
  }
}

Widget _app(Widget child, _FakeLogs logs) => ProviderScope(
      overrides: [adminMessageLogsRepositoryProvider.overrideWithValue(logs)],
      child: MaterialApp(theme: GwTheme.light(), home: Scaffold(body: child)),
    );

void main() {
  const reason = 'Taciz şikayeti incelemesi';

  testWidgets('searching asks for a reason, then lists the conversations', (tester) async {
    final logs = _FakeLogs();
    await tester.pumpWidget(_app(const AdminMessageLogsScreen(), logs));

    await tester.enterText(find.widgetWithText(TextFormField, 'Kullanıcı adı'), '@ayse.k');
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'kısa');
    await tester.ensureVisible(find.text('Sohbetleri getir'));
    await tester.tap(find.text('Sohbetleri getir'));
    await tester.pumpAndSettle();
    expect(find.text('Gerekçe en az 10 karakter olmalı.'), findsOneWidget);
    expect(logs.reasons, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), reason);
    await tester.ensureVisible(find.text('Sohbetleri getir'));
    await tester.tap(find.text('Sohbetleri getir'));
    await tester.pumpAndSettle();
    expect(logs.reasons, [reason]);
    expect(find.text('Can Dağ (@can_dag)'), findsOneWidget);
    expect(find.textContaining('kişinin 7 mesajı · 1 silinmiş'), findsOneWidget);
  });

  testWidgets('a conversation opens only with a reason and shows deleted texts', (tester) async {
    final logs = _FakeLogs();
    await tester.pumpWidget(_app(const AdminMessageLogScreen(conversationId: 'c1'), logs));
    expect(find.text('Gerekçe gerekli'), findsOneWidget);
    expect(logs.reasons, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), reason);
    await tester.ensureVisible(find.text('Sohbeti aç'));
    await tester.tap(find.text('Sohbeti aç'));
    await tester.pumpAndSettle();
    expect(logs.reasons, [reason]);
    expect(find.text('Cumartesi geliyor musun?'), findsOneWidget);
    expect(find.text('Silinen tehdit mesajı'), findsOneWidget);
    expect(find.text('Gönderen sildi'), findsOneWidget);
    expect(find.textContaining('Arşivden silinecek'), findsOneWidget);
  });
}
