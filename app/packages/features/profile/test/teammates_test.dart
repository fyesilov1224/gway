import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';

const _elif = PersonSummary(id: 'u2', username: 'elif', displayName: 'Elif');
const _ayse = PersonSummary(id: 'u3', username: 'ayse', displayName: 'Ayşe');

/// Records what the teammate screens send.
class _FakeTeammates implements TeammatesRepository {
  final calls = <String>[];
  TeammatePreferences? saved;

  /// Sending answers like a user without the Ekip Arkadaşı package.
  bool needsPackage = false;

  @override
  Future<Result<void>> savePreferences(TeammatePreferences preferences) async {
    saved = preferences;
    return const Ok(null);
  }

  @override
  Future<Result<TeammateRelation>> request(String userId, {String message = ''}) async {
    calls.add('request:$userId:$message');
    if (needsPackage) {
      return const Err(RuleFailure('profile.teammate_package_required', 'Ekip arkadaşı isteği göndermek için Ekip Arkadaşı paketi gerekir.'));
    }
    return const Ok(TeammateRelation.requested);
  }

  @override
  Future<Result<void>> accept(String userId) async {
    calls.add('accept:$userId');
    return const Ok(null);
  }

  @override
  Future<Result<void>> decline(String userId) async {
    calls.add('decline:$userId');
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _openedPackages = <String>[];

Future<_FakeTeammates> _pump(
  WidgetTester tester,
  Widget home, {
  TeammatePreferences prefs = const TeammatePreferences(),
  MyTeammates mine = const MyTeammates(),
  bool needsPackage = false,
}) async {
  tester.view.physicalSize = const Size(1170, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final fake = _FakeTeammates()..needsPackage = needsPackage;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      packageOpenerProvider.overrideWithValue((_, slug) => _openedPackages.add(slug)),
      categoriesProvider.overrideWith((ref) async => const [Category(slug: 'running', name: 'Koşu'), Category(slug: 'hiking', name: 'Yürüyüş')]),
      currentUserIdProvider.overrideWithValue('u1'),
      teammatesRepositoryProvider.overrideWithValue(fake),
      teammatePreferencesProvider.overrideWith((ref) async => prefs),
      myTeammatesProvider.overrideWith((ref) async => mine),
      teammateSuggestionsProvider.overrideWith((ref) async => const [
            TeammateSuggestion(
              person: _elif,
              level: TeammateLevel.intermediate,
              note: 'Hafta sonu yürüyüşü',
              interests: ['Yürüyüş'],
              groups: ['Doğa Yürüyüşü'],
              times: [TeammateSlot.weekendMorning],
              sameLevel: true,
              sameProvince: true,
            ),
          ]),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: home),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('a suggestion explains itself without the province', () {
    const s = TeammateSuggestion(
      person: _elif,
      level: TeammateLevel.advanced,
      interests: ['Koşu', 'Bisiklet'],
      groups: ['A', 'B'],
      times: [TeammateSlot.weekdayEvening],
      sameLevel: true,
      sameProvince: true,
    );
    expect(s.reasons, [
      'Ortak ilgi: Koşu, Bisiklet',
      'Aynı ildesiniz',
      '2 ortak grup',
      'İkiniz de ileri seviye',
      'Uygun zaman: hafta içi akşam',
    ]);
    expect(const TeammateStatus(looking: true, level: TeammateLevel.beginner).label, 'Ekip arıyor · Başlangıç seviye');
    expect(turkishProvinces, hasLength(81));
    expect(turkishProvinces[33], 'İstanbul');
  });

  testWidgets('suggestions show the reasons and send a request with a message', (tester) async {
    final fake = await _pump(tester, const TeammatesScreen(), prefs: const TeammatePreferences(looking: true));
    expect(find.text('Aynı ildesiniz'), findsOneWidget);
    expect(find.text('"Hafta sonu yürüyüşü"'), findsOneWidget);
    expect(find.text('Sen de görün'), findsNothing);

    await tester.tap(find.widgetWithText(GxButton, 'İstek gönder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cumartesi Belgrad?');
    await tester.tap(find.widgetWithText(GxButton, 'İstek gönder').last);
    await tester.pumpAndSettle();
    expect(fake.calls, ['request:u2:Cumartesi Belgrad?']);
  });

  testWidgets('without the package a request offers the Ekip Arkadaşı package', (tester) async {
    await _pump(tester, const TeammatesScreen(), prefs: const TeammatePreferences(looking: true), needsPackage: true);

    await tester.tap(find.widgetWithText(GxButton, 'İstek gönder'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GxButton, 'İstek gönder').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Ekip Arkadaşı paketi gerekir'), findsOneWidget);
    await tester.tap(find.text('Paketi incele'));
    expect(_openedPackages, ['matching_teammates']);
  });

  testWidgets('without the package the section is locked and shows the waiting requests', (tester) async {
    await _pump(tester, const TeammatesScreen(), mine: const MyTeammates(locked: true, waiting: 5));

    expect(find.text('5 kişi seninle ekip arkadaşı olmak istiyor'), findsOneWidget);
    expect(find.text('Öneriler'), findsNothing);
    await tester.tap(find.text('Paketi incele'));
    expect(_openedPackages.last, 'matching_teammates');
  });

  testWidgets('people who are not looking are invited to turn it on', (tester) async {
    await _pump(tester, const TeammatesScreen());
    expect(find.text('Sen de görün'), findsOneWidget);
  });

  testWidgets('incoming requests open first and are accepted or declined', (tester) async {
    final fake = await _pump(
      tester,
      const TeammatesScreen(),
      mine: MyTeammates(incoming: [
        TeammateRequest(person: _ayse, message: 'Pazar koşusu?', createdAt: DateTime(2026, 10, 20)),
        TeammateRequest(person: _elif, createdAt: DateTime(2026, 10, 20)),
      ]),
    );
    expect(find.text('İstekler (2)'), findsOneWidget);
    expect(find.text('"Pazar koşusu?"'), findsOneWidget);
    await tester.tap(find.widgetWithText(GxButton, 'Kabul et').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reddet').last);
    await tester.pumpAndSettle();
    expect(fake.calls, ['accept:u3', 'decline:u2']);
  });

  testWidgets('settings save looking, level, times and province', (tester) async {
    final fake = await _pump(tester, const TeammateSettingsScreen());
    final list = find.byType(Scrollable).first;
    Future<void> tap(Finder f) async {
      await tester.scrollUntilVisible(f, 200, scrollable: list);
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    expect(find.text('Tercihlerin %0 tamam'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tap(find.text('Koşu'));
    await tap(find.text('Orta'));
    await tap(find.text('Formda kalmak'));
    await tap(find.text('Haftada 2–3'));
    await tap(find.bySemanticsLabel('Hafta sonu sabah'));
    await tap(find.text('Küçük grup (3–6)'));
    await tap(find.text('Belirtmek istemiyorum'));
    await tester.tap(find.text('Adana').last);
    await tester.pumpAndSettle();
    await tap(find.text('Aracım var'));
    await tester.scrollUntilVisible(find.byType(TextField), 200, scrollable: list);
    await tester.enterText(find.byType(TextField), ' Sabah yürüyüşü ');
    await tester.pumpAndSettle();
    expect(find.text('Tercihlerin %100 tamam'), findsNothing); // the bar stays at the top
    await tester.tap(find.widgetWithText(GxButton, 'Kaydet'));
    await tester.pumpAndSettle();

    final saved = fake.saved!;
    expect(saved.looking, isTrue);
    expect(saved.activities, {'running'});
    expect(saved.level, TeammateLevel.intermediate);
    expect(saved.goals, {TeammateGoal.fitness});
    expect(saved.frequency, TeammateFrequency.fewWeekly);
    expect(saved.availability, {TeammateSlot.weekendMorning});
    expect(saved.groupSizes, {TeammateGroupSize.small});
    expect(saved.province, 1);
    expect(saved.hasVehicle, isTrue);
    expect(saved.note, ' Sabah yürüyüşü ');
    expect(saved.answered, TeammatePreferences.sections);
  });
}
