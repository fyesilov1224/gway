import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mark alone is announced as GrupX and keeps its size', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Center(child: GxLogo(size: 48))));

    expect(tester.getSize(find.byType(GxLogo)), const Size(48, 48));
    expect(find.bySemanticsLabel('GrupX'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('wordmark shows "Grup" with an accented "X" and ignores text scaling', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: Center(child: GxLogo(size: 32, wordmark: true))));

    final text = tester.widget<Text>(find.byType(Text));
    final span = text.textSpan! as TextSpan;
    expect(span.toPlainText(), 'GrupX');
    expect((span.children!.single as TextSpan).style?.color, GxColors.primary);
    expect(text.textScaler, TextScaler.noScaling);
    expect(tester.takeException(), isNull);
  });

  test('every tone keeps its two member colors distinct', () {
    for (final tone in GxLogoTone.values) {
      expect(tone.first, isNot(tone.second), reason: tone.name);
    }
  });
}
