import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _group = EventGroup(id: 'g1', handle: 'kosu', name: 'Koşu Kulübü');

Goal _goal({GoalKind kind = GoalKind.personal, int progress = 3, bool manage = false, ClaimStatus? claim, String? team}) => Goal(
      id: 'q1',
      group: _group,
      title: 'Ekim koşuları',
      kind: kind,
      metric: kind == GoalKind.task ? null : GoalMetric.attended,
      target: kind == GoalKind.task ? 1 : 4,
      startsAt: DateTime.now().subtract(const Duration(days: 3)),
      endsAt: DateTime.now().add(const Duration(days: 20)),
      progress: progress,
      canManage: manage,
      myClaim: claim,
      myTeam: team,
    );

/// Records what the goal screens send.
class _FakeGoals implements GoalsRepository {
  final calls = <String>[];

  @override
  Future<Result<void>> claim(String goalId, {String note = ''}) async {
    calls.add('claim:$goalId:$note');
    return const Ok(null);
  }

  @override
  Future<Result<void>> decideClaim(String goalId, String userId, {required bool approve}) async {
    calls.add('decide:$userId:$approve');
    return const Ok(null);
  }

  @override
  Future<Result<void>> createTeam(String goalId, String name, List<String> memberIds) async {
    calls.add('team:$name:${memberIds.join(',')}');
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeGoals> _pump(WidgetTester tester, GoalDetail detail) async {
  tester.view.physicalSize = const Size(1170, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final fake = _FakeGoals();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      goalsRepositoryProvider.overrideWithValue(fake),
      goalDetailProvider.overrideWith((ref, id) async => detail),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: const GoalScreen(goalId: 'q1')),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('progress reads as counts of the metric', () {
    expect(_goal().progressLabel, '3 / 4 katılım');
    expect(_goal().share, 0.75);
    expect(_goal(kind: GoalKind.task, progress: 0, claim: ClaimStatus.pending).progressLabel, 'Onay bekliyor');
  });

  testWidgets('a member reports a task with a note', (tester) async {
    final fake = await _pump(tester, GoalDetail(goal: _goal(kind: GoalKind.task, progress: 0)));
    await tester.tap(find.widgetWithText(GxButton, 'Yaptım'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Yeni üyeye rotayı anlattım');
    await tester.tap(find.text('Gönder'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['claim:q1:Yeni üyeye rotayı anlattım']);
  });

  testWidgets('managers approve claims and set up teams', (tester) async {
    final fake = await _pump(
      tester,
      GoalDetail(
        goal: _goal(kind: GoalKind.team, manage: true),
        teams: const [GoalTeam(id: 't1', name: 'Kuzey', progress: 2, members: [EventPerson(id: 'u2', username: 'elif', displayName: 'Elif')])],
        claims: const [GoalClaim(person: EventPerson(id: 'u5', username: 'can', displayName: 'Can'), note: 'Yaptım')],
        candidates: const [EventPerson(id: 'u3', username: 'ayse', displayName: 'Ayşe')],
      ),
    );
    expect(find.textContaining('2 / 4 katılım · Elif'), findsOneWidget);
    await tester.tap(find.widgetWithText(GxButton, 'Onayla'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['decide:u5:true']);

    await tester.tap(find.text('Takım kur'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Takım adı'), 'Güney');
    await tester.tap(find.text('Ayşe'));
    await tester.pump();
    await tester.tap(find.widgetWithText(GxButton, 'Takımı kur (1 kişi)'));
    await tester.pumpAndSettle();
    expect(fake.calls.last, 'team:Güney:u3');
  });

  testWidgets('the group page lists goals; managers can open one', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [groupGoalsProvider.overrideWith((ref, id) async => [_goal(kind: GoalKind.team, progress: 0)])],
      child: MaterialApp(theme: GxTheme.light(), home: const Scaffold(body: GroupGoalsSection(groupId: 'g1', canManage: true))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Ekim koşuları'), findsOneWidget);
    expect(find.text('Bir takıma eklenince ilerlemen burada görünür.'), findsOneWidget);
    expect(find.text('Hedef oluştur'), findsOneWidget);
  });
}
