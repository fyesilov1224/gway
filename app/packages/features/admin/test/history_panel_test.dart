import 'package:admin/admin.dart';
import 'package:admin/src/presentation/widgets.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 12 group invitations and 3 security records, newest first.
  final now = DateTime.now();
  final history = [
    for (var i = 0; i < 12; i++)
      AdminAuditItem(
        occurredAt: now.subtract(Duration(hours: i)),
        action: 'group.invitation_sent',
        actorKind: 'user',
        actorName: 'Elif',
        targetName: 'Doğa Yürüyüşü',
      ),
    for (var i = 0; i < 3; i++)
      AdminAuditItem(
        occurredAt: now.subtract(Duration(days: 3, hours: i)),
        action: 'security.phone_verified',
        actorKind: 'user',
        detail: 'TR',
      ),
  ];

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        theme: GwTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: HistoryPanel(
              history: history,
              labels: const {
                'group.invitation_sent': ('Gruba davet edildi', Icons.mail_outline),
                'security.phone_verified': ('Telefon doğrulandı', Icons.sms_outlined),
              },
              detailLabels: const {'TR': 'Türkiye'},
              emptyText: 'Kayıt yok.',
              userActorLabel: 'Kullanıcının kendisi',
            ),
          ),
        ),
      ));

  testWidgets('the history shows one page at a time with readable rows', (tester) async {
    await pump(tester);
    expect(find.text('Gruba davet edildi'), findsNWidgets(HistoryPanel.pageSize));
    expect(find.text('1–8 / 15 kayıt'), findsOneWidget);
    expect(find.textContaining('Doğa Yürüyüşü · Kullanıcının kendisi'), findsWidgets);
    expect(find.text('Bugün'), findsOneWidget);
    expect(find.textContaining('group.'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Sonraki sayfa'));
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('9–15 / 15 kayıt'), findsOneWidget);
    expect(find.text('Telefon doğrulandı'), findsNWidgets(3));
  });

  testWidgets('filter chips narrow the history by kind', (tester) async {
    await pump(tester);
    expect(find.text('Tümü (15)'), findsOneWidget);
    await tester.tap(find.text('Güvenlik (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Telefon doğrulandı'), findsNWidgets(3));
    expect(find.text('Gruba davet edildi'), findsNothing);
    expect(find.textContaining('Türkiye'), findsNWidgets(3));
    expect(find.byTooltip('Sonraki sayfa'), findsNothing);
  });
}
