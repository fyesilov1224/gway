import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

class _FakeBirthDates implements BirthDateRepository {
  DateTime? saved;

  @override
  Future<Result<DateTime?>> mine() async => Ok(saved);

  @override
  Future<Result<void>> save(DateTime birthDate) async {
    saved = birthDate;
    return const Ok(null);
  }
}

void main() {
  test('age counts full years only', () {
    final today = DateTime(2026, 10, 27);
    expect(ageOn(DateTime(2008, 10, 27), today), 18);
    expect(ageOn(DateTime(2008, 10, 28), today), 17);
    expect(ageOn(DateTime(2000, 2, 29), DateTime(2026, 2, 28)), 25);
  });

  testWidgets('the date is required before going on', (tester) async {
    final repo = _FakeBirthDates();
    await tester.pumpWidget(ProviderScope(
      overrides: [birthDateRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: GxTheme.light(), home: const BirthDateScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('18 yaş ve üstündekiler'), findsOneWidget);
    await tester.tap(find.text('Devam et'));
    await tester.pump();
    expect(find.text('Doğum tarihini seç.'), findsOneWidget);
    expect(repo.saved, isNull);
  });
}
