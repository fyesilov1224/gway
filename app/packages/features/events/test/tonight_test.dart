import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the tonight writes.
class _FakeEvents implements EventsRepository {
  final calls = <String>[];

  @override
  Future<Result<void>> setFree(String note) async {
    calls.add('free:$note');
    return const Ok(null);
  }

  @override
  Future<Result<int>> createTable() async {
    calls.add('table');
    return const Ok(4);
  }

  @override
  Future<Result<void>> answerTable(String tableId, {required bool accept}) async {
    calls.add('answer:$tableId:$accept');
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _ayse = TonightPerson(id: 'u2', username: 'ayse', displayName: 'Ayşe Kaya');
const _can = TonightPerson(id: 'u3', username: 'can', displayName: 'Can Dağ');

Future<_FakeEvents> _pump(WidgetTester tester, Tonight tonight, {void Function(String id)? onChat, double textScale = 1}) async {
  final fake = _FakeEvents();
  // A fresh ProviderScope each time, so overridden data is never reused.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(ProviderScope(
    overrides: [
      eventsRepositoryProvider.overrideWithValue(fake),
      tonightProvider.overrideWith((ref) async => tonight),
    ],
    child: MaterialApp(
      theme: GxTheme.light(),
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(
          body: SingleChildScrollView(child: TonightCard(openChat: (_, id) => onChat?.call(id))),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('saying "boşum" asks for an optional note', (tester) async {
    final fake = await _pump(tester, const Tonight());

    expect(find.textContaining('ortak gruplarındakiler görsün'), findsOneWidget);
    await tester.tap(find.text('Bu akşam boşum'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  kahve  ');
    await tester.tap(find.text('Boşum'));
    await tester.pumpAndSettle();

    expect(fake.calls, ['free:kahve']);
  });

  testWidgets('a free person sees how many are free and sets up a table', (tester) async {
    final fake = await _pump(tester, Tonight(note: 'yürüyüş', until: DateTime(2026, 10, 31, 4), people: 6));

    expect(find.text('Ortak gruplarından 6 kişi bu akşam boş'), findsOneWidget);
    expect(find.textContaining('"yürüyüş"'), findsOneWidget);
    await tester.tap(find.text('Küçük masa kur'));
    await tester.pumpAndSettle();

    expect(fake.calls, ['table']);
    expect(find.textContaining('4 kişiye davet gönderildi'), findsOneWidget);
  });

  testWidgets('an invitation names the founder and counts the rest; joining answers it', (tester) async {
    final invite = TonightTable(id: 't1', closesAt: DateTime(2026, 10, 31, 12), founder: _ayse, joined: const [_ayse], pending: 3);
    final fake = await _pump(tester, Tonight(invites: [invite]), textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(find.text('Ayşe Kaya küçük bir masa kurdu ve seni de çağırıyor.'), findsOneWidget);
    expect(find.textContaining('3 kişi bekleniyor'), findsOneWidget);
    await tester.tap(find.text('Katıl'));
    await tester.pumpAndSettle();

    expect(fake.calls, ['answer:t1:true']);
  });

  testWidgets('a set table opens its chat; before three it says how many are missing', (tester) async {
    String? opened;
    final waiting = TonightTable(id: 't1', closesAt: DateTime(2026, 10, 31, 12), founder: _ayse, joined: const [_ayse, _can]);
    await _pump(tester, Tonight(until: DateTime(2026, 10, 31, 4), table: waiting));
    expect(find.textContaining('1 kişi daha katılınca açılır'), findsOneWidget);
    expect(find.text('Küçük masa kur'), findsNothing);

    final set = TonightTable(
      id: 't1',
      closesAt: DateTime(2026, 10, 31, 12),
      founder: _ayse,
      joined: const [_ayse, _can, TonightPerson(id: 'u1', username: 'ben', displayName: 'Ben')],
      conversationId: 'c1',
    );
    await _pump(tester, Tonight(until: DateTime(2026, 10, 31, 4), table: set), onChat: (id) => opened = id);
    await tester.tap(find.text('Masanın sohbeti'));
    expect(opened, 'c1');
  });
}
