import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mark alone is announced as GWAY and keeps its size', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Center(child: GwLogo(size: 48))));

    expect(tester.getSize(find.byType(GwLogo)), const Size(48, 48));
    expect(find.bySemanticsLabel('GWAY'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('wordmark shows "G" with an accented "WAY" and ignores text scaling', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: Center(child: GwLogo(size: 32, wordmark: true))));

    final text = tester.widget<Text>(find.byType(Text));
    final span = text.textSpan! as TextSpan;
    expect(span.toPlainText(), 'GWAY');
    expect((span.children!.single as TextSpan).style?.color, GwColors.primary);
    expect(text.textScaler, TextScaler.noScaling);
    expect(tester.takeException(), isNull);
  });

  test('every tone keeps its way and member colors distinct', () {
    for (final tone in GwLogoTone.values) {
      expect(tone.first, isNot(tone.second), reason: tone.name);
    }
  });
}
