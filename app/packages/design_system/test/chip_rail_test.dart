import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _names = ['Tümü', 'Müzik', 'Yürüyüş', 'Koşu', 'Bisiklet', 'Motosiklet', 'Doğa', 'Kamp', 'Spor', 'Sanat'];

Future<void> _pump(WidgetTester tester, double width, {double textScale = 1}) async {
  tester.view.physicalSize = Size(width, 400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: GwTheme.light(),
    home: MediaQuery.withClampedTextScaling(
      minScaleFactor: textScale,
      maxScaleFactor: textScale,
      child: Scaffold(
        body: GwChipRail(children: [for (final n in _names) ChoiceChip(label: Text(n), selected: n == 'Tümü')]),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('on a narrow screen an arrow scrolls to the chips beyond the edge', (tester) async {
    await _pump(tester, 360, textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Öncekiler'), findsNothing);
    expect(find.byTooltip('Sonrakiler'), findsOneWidget);

    final before = tester.getTopLeft(find.text('Müzik')).dx;
    await tester.tap(find.byTooltip('Sonrakiler'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Müzik')).dx, lessThan(before));
    expect(find.byTooltip('Öncekiler'), findsOneWidget, reason: 'now it can go back');
  });

  testWidgets('a swipe scrolls the row too', (tester) async {
    await _pump(tester, 360);
    final before = tester.getTopLeft(find.text('Müzik')).dx;
    await tester.drag(find.text('Yürüyüş'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Müzik')).dx, lessThan(before));
  });

  testWidgets('when every chip fits there are no arrows', (tester) async {
    await _pump(tester, 2400);
    expect(find.byTooltip('Öncekiler'), findsNothing);
    expect(find.byTooltip('Sonrakiler'), findsNothing);
  });
}
