import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

const _document = LegalDocument(
  kind: LegalKind.terms,
  version: 2,
  title: 'Kullanım Koşulları',
  body: 'Türkçe asıl metin.',
  translation: LegalTranslation(title: 'Terms of Use', body: 'The English translation.'),
);

void main() {
  tearDown(() => setCurrentAppLanguage(AppLanguage.tr));

  testWidgets('a translation comes first with the binding-Turkish note and a switch to the original', (tester) async {
    setCurrentAppLanguage(AppLanguage.en);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: LegalText(document: _document)))));

    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('The English translation.'), findsOneWidget);
    expect(find.textContaining('Turkish original'), findsWidgets);

    await tester.tap(find.text('Show the Turkish original'));
    await tester.pump();
    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(find.text('Türkçe asıl metin.'), findsOneWidget);
    expect(find.text('Show the translation'), findsOneWidget);
  });

  testWidgets('without a translation the Turkish text shows alone', (tester) async {
    setCurrentAppLanguage(AppLanguage.de);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: LegalText(document: _document.withTranslation(null)))),
    ));
    expect(find.text('Türkçe asıl metin.'), findsOneWidget);
    expect(find.byType(GwButton), findsNothing);
  });
}
