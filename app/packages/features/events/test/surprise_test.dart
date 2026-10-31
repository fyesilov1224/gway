import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _group = EventGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');

final _now = DateTime(2026, 11, 7, 12);

GroupEvent _event(EventSurprise surprise) => GroupEvent(
      id: 'e1',
      group: _group,
      title: 'Gizemli akşam',
      startsAt: _now.add(const Duration(hours: 8)),
      location: "Kadıköy'de, deniz kenarında",
      surprise: surprise,
    );

Future<void> _pump(WidgetTester tester, EventSurprise surprise) => tester.pumpWidget(MaterialApp(
      theme: GwTheme.light(),
      home: Scaffold(body: SurprisePlace(event: _event(surprise), surprise: surprise, now: _now)),
    ));

void main() {
  testWidgets('before the reveal people see the province, the hint and when it opens', (tester) async {
    await _pump(tester, EventSurprise(revealHours: 3, revealAt: _now.add(const Duration(hours: 5)), province: 'İstanbul'));
    expect(find.text('Sürpriz mekan'), findsOneWidget);
    expect(find.text("İstanbul · Kadıköy'de, deniz kenarında"), findsOneWidget);
    expect(find.textContaining('katılanlara açıklanacak'), findsOneWidget);
  });

  testWidgets('after the reveal those not going are told to join', (tester) async {
    await _pump(tester, EventSurprise(revealHours: 3, revealAt: _now.subtract(const Duration(minutes: 5)), province: 'İstanbul'));
    expect(find.text('Mekan katılanlara açıklandı. Katılırsan görürsün.'), findsOneWidget);
  });

  testWidgets('those allowed see the venue with the hint', (tester) async {
    await _pump(tester, EventSurprise(revealHours: 3, revealAt: _now.subtract(const Duration(minutes: 5)), venue: 'Moda Sahnesi önü'));
    expect(find.text('Moda Sahnesi önü'), findsOneWidget);
    expect(find.text("İpucu: Kadıköy'de, deniz kenarında"), findsOneWidget);
  });

  test('the one-line place and the form keep the venue apart from the hint', () {
    final surprise = EventSurprise(revealHours: 3, revealAt: _now);
    expect(_event(surprise).place, "Sürpriz mekan · Kadıköy'de, deniz kenarında");
    final form = EventForm(
      title: 'Gizemli akşam',
      startsAt: _now,
      location: 'İpucu',
      surprise: const EventSurpriseForm(revealHours: 6, venue: ' Moda '),
    ).toJson();
    expect(form['surprise'], {'revealHours': 6, 'venue': 'Moda'});
    expect(form['linkUrl'], isNull);
  });
}
