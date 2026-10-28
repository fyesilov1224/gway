import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moderation/moderation.dart';

const _offender = ModerationPerson(id: 'u6', username: 'kaba', displayName: 'Kaba Üye', rank: 10);
const _admin = ModerationPerson(id: 'u2', username: 'yonetici', displayName: 'Yönetici', rank: 80);

GroupReport _report({ModerationPerson subject = _offender, String type = 'comment'}) => GroupReport(
      id: 'r1',
      targetType: type,
      targetId: 'c1',
      postId: 'p1',
      subject: subject,
      excerpt: 'Kaba bir yorum',
      reasons: const [ReportReason.harassment],
      notes: const ['Hakaret ediyor'],
      count: 3,
      lastAt: DateTime(2026, 10, 21, 9),
    );

ModerationCase _case({bool? myVote, CaseStatus status = CaseStatus.voting}) => ModerationCase(
      id: 'c1',
      subject: _offender,
      sanction: SanctionType.ban,
      durationDays: 7,
      reason: 'Üyelere tekrar tekrar hakaret etti.',
      status: status,
      votingEndsAt: DateTime.now().add(const Duration(hours: 50)),
      createdAt: DateTime(2026, 10, 21),
      voters: 2,
      approvals: myVote == true ? 1 : 0,
      isVoter: true,
      myVote: myVote,
    );

/// Records what the screens send; nothing else is called.
class _FakeModeration implements ModerationRepository {
  final calls = <String>[];

  @override
  Future<Result<void>> report(ReportTarget target, ReportReason reason, {String? note}) async {
    calls.add('report:${target.type}:${target.id}:${reason.code}:${note ?? ''}');
    return const Ok(null);
  }

  @override
  Future<Result<void>> dismiss(String reportId) async {
    calls.add('dismiss:$reportId');
    return const Ok(null);
  }

  @override
  Future<Result<void>> openCase(String groupId, CaseForm form) async {
    calls.add('case:$groupId:${form.sanction.code}:${form.durationDays}:${form.illegalCategory?.code}');
    return const Ok(null);
  }

  @override
  Future<Result<CaseStatus>> vote(String caseId, {required bool approve}) async {
    calls.add('vote:$caseId:$approve');
    return const Ok(CaseStatus.voting);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _links = ModerationLinks(openProfile: _noop, openPost: _noop, openEvent: _noop);

void _noop(BuildContext context, String id) {}

Future<_FakeModeration> _pump(WidgetTester tester, Widget child, {GroupModeration? desk, List<MySanction> mine = const []}) async {
  final fake = _FakeModeration();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      moderationRepositoryProvider.overrideWithValue(fake),
      groupModerationProvider.overrideWith((ref, id) async => desk),
      mySanctionsProvider.overrideWith((ref) async => mine),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: child),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('sanctions read like a decision', () {
    expect(sanctionLabel(SanctionType.ban, 7), '7 gün ban');
    expect(sanctionLabel(SanctionType.ban, null), 'Kalıcı ban');
    expect(sanctionLabel(SanctionType.mute, 3), '3 gün susturma');
    expect(sanctionLabel(SanctionType.kick, null), 'Gruptan çıkarma');
    expect(SanctionType.ban.durations.last, isNull, reason: 'a ban may be permanent');
    final now = DateTime(2026, 10, 21, 12);
    expect(timeLeft(DateTime(2026, 10, 23, 16), now: now), '2 gün 4 saat');
    expect(timeLeft(DateTime(2026, 10, 21, 15), now: now), '3 saat');
  });

  test('the open work counts reports, my votes and the owner\'s appeals', () {
    final appealed = GroupSanction(
      id: 's1',
      user: _offender,
      type: SanctionType.ban,
      startsAt: DateTime(2026, 10, 20),
      reason: 'Hakaret',
      appeal: Appeal(id: 'a1', body: 'Özür dilerim, yanlış anlaşıldım.', status: AppealStatus.pending, createdAt: DateTime(2026, 10, 21)),
    );
    final desk = GroupModeration(rank: 100, isOwner: true, reports: [_report()], cases: [_case(), _case(myVote: true)], sanctions: [appealed]);
    expect(desk.awaitingMyVote, 1);
    expect(desk.pendingAppeals, [appealed]);
    expect(desk.pending, 3);
    expect(GroupModeration(rank: 50, sanctions: [appealed]).pendingAppeals, isEmpty, reason: 'only the owner decides appeals');
  });

  testWidgets('a report needs a reason and goes out with the note', (tester) async {
    // A phone-sized screen: the whole sheet fits.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final fake = await _pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showReportSheet(context, const ReportTarget.comment('c9')),
            child: const Text('Aç'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();

    expect(find.text('Yorumu şikayet et'), findsOneWidget);
    await tester.tap(find.widgetWithText(GxButton, 'Şikayet et'));
    await tester.pumpAndSettle();
    expect(fake.calls, isEmpty, reason: 'nothing is sent without a reason');

    await tester.tap(find.text('Taciz ya da zorbalık'));
    await tester.enterText(find.byType(TextField), 'Sürekli hakaret ediyor');
    await tester.tap(find.widgetWithText(GxButton, 'Şikayet et'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['report:comment:c9:harassment:Sürekli hakaret ediyor']);
    expect(find.textContaining('Şikayetin alındı'), findsOneWidget);
  });

  testWidgets('reviewers act only on people they outrank', (tester) async {
    final fake = await _pump(
      tester,
      const GroupModerationScreen(groupId: 'g1', groupName: 'Koşu Kulübü', links: _links),
      desk: GroupModeration(rank: 50, canMute: true, reports: [_report(), _report(subject: _admin, type: 'post')]),
    );

    expect(find.text('Şikayetler (2)'), findsOneWidget);
    expect(find.text('Kaba bir yorum'), findsNWidgets(2));
    expect(find.text('Dosya aç'), findsOneWidget);
    expect(find.text('İçeriği kaldır'), findsOneWidget);
    expect(find.textContaining('yalnızca reddedebilirsin'), findsOneWidget);

    await tester.tap(find.text('Reddet').first);
    await tester.pumpAndSettle();
    expect(fake.calls, ['dismiss:r1']);
  });

  testWidgets('board members vote on open cases', (tester) async {
    final fake = await _pump(
      tester,
      const GroupModerationScreen(groupId: 'g1', groupName: 'Koşu Kulübü', links: _links),
      desk: GroupModeration(rank: 60, cases: [_case()]),
    );
    await tester.tap(find.text('Dosyalar (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Önerilen: 7 gün ban'), findsOneWidget);
    expect(find.textContaining('Oylama 2 gün'), findsOneWidget);
    await tester.tap(find.widgetWithText(GxButton, 'Onayla'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['vote:c1:true']);
  });

  testWidgets('only a ban case is marked as illegal activity, with a category', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final fake = await _pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showCaseSheet(context, groupId: 'g1', subjectId: 'u6', subjectName: 'Kaba Üye'),
            child: const Text('Aç'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
    expect(find.text('Yasa dışı faaliyet'), findsNothing, reason: 'a warning is never illegal activity');
    await tester.enterText(find.byType(TextFormField), 'Üyeleri ölümle tehdit etti.');

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ban'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yasa dışı faaliyet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Tehdit'));
    await tester.scrollUntilVisible(find.widgetWithText(GxButton, 'Dosyayı aç'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.widgetWithText(GxButton, 'Dosyayı aç'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['case:g1:ban:7:threat']);
  });

  testWidgets('the case card shows the illegal-activity mark', (tester) async {
    final marked = ModerationCase(
      id: 'c2',
      subject: _offender,
      sanction: SanctionType.ban,
      illegalCategory: IllegalCategory.fraud,
      reason: 'Üyelerden sahte bilet parası topladı.',
      status: CaseStatus.voting,
      votingEndsAt: DateTime.now().add(const Duration(hours: 50)),
      createdAt: DateTime(2026, 10, 28),
      voters: 2,
      isVoter: true,
    );
    await _pump(
      tester,
      const GroupModerationScreen(groupId: 'g1', groupName: 'Koşu Kulübü', links: _links),
      desk: GroupModeration(rank: 60, cases: [marked]),
    );
    await tester.tap(find.text('Dosyalar (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Yasa dışı faaliyet: Dolandırıcılık'), findsOneWidget);
  });

  testWidgets('people outside the moderation team see why the desk is closed', (tester) async {
    await _pump(tester, const GroupModerationScreen(groupId: 'g1', groupName: 'Koşu Kulübü', links: _links));
    expect(find.textContaining('yalnızca grup sahibi ve moderasyon ekibi'), findsOneWidget);
  });

  testWidgets('a sanction can be appealed once, within its window', (tester) async {
    await _pump(
      tester,
      MySanctionsScreen(openGroup: (_, _) {}),
      mine: [
        MySanction(
          id: 's1',
          group: const SanctionGroup(id: 'g1', handle: 'kosu', name: 'Koşu Kulübü'),
          type: SanctionType.mute,
          startsAt: DateTime.now(),
          endsAt: DateTime.now().add(const Duration(days: 3)),
          reason: 'Yorumlarda hakaret etti.',
          canAppeal: true,
        ),
        MySanction(
          id: 's2',
          group: const SanctionGroup(id: 'g2', handle: 'bisiklet', name: 'Bisiklet'),
          type: SanctionType.warning,
          startsAt: DateTime(2026, 9, 1),
          reason: 'Spam paylaştı.',
          appeal: Appeal(id: 'a1', body: 'Haksız buldum bu uyarıyı.', status: AppealStatus.upheld, createdAt: DateTime(2026, 9, 2)),
        ),
      ],
    );
    expect(find.text('Gerekçe: Yorumlarda hakaret etti.'), findsOneWidget);
    expect(find.widgetWithText(GxButton, 'İtiraz et'), findsOneWidget);
    expect(find.text('İtirazın · Yaptırım sürüyor'), findsOneWidget);
  });
}
