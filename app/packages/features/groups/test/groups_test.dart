import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groups/groups.dart';

Group _group({JoinPolicy policy = JoinPolicy.open, String owner = 'owner', bool suspended = false}) => Group(
      id: 'g1',
      handle: 'istanbul.kosu',
      name: 'İstanbul Koşu Kulübü',
      categorySlug: 'running',
      joinPolicy: policy,
      ownerId: owner,
      memberCount: 42,
      createdAt: DateTime(2026, 10, 1),
      about: 'Her pazar sabahı sahilde koşuyoruz.',
      rules: 'Saygılı ol.',
      links: const [GroupLink(label: 'Instagram', url: 'https://instagram.com/kosu')],
      isSuspended: suspended,
    );

const _owner = GroupPerson(userId: 'owner', username: 'elif', displayName: 'Elif Koşar', roles: [GroupRole.owner, GroupRole.member]);
const _admin = GroupPerson(
  userId: 'u2',
  username: 'zeynep',
  displayName: 'Zeynep Sanat',
  roles: [GroupRole.admin, GroupRole.moderator, GroupRole.member],
);
const _member = GroupPerson(userId: 'u3', username: 'demo', displayName: 'Demo Kullanıcı', roles: [GroupRole.member]);

const _ownerPermissions = {
  GroupPermission.edit,
  GroupPermission.delete,
  GroupPermission.transfer,
  GroupPermission.assignRoles,
  GroupPermission.approveMembers,
  GroupPermission.inviteMembers,
};

Widget _app(
  Widget child, {
  required String? userId,
  Group? group,
  MyMembership me = const MyMembership(),
  List<GroupPerson> requests = const [],
  List<Group> myGroups = const [],
}) =>
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue(userId),
        categoriesProvider.overrideWith((ref) async => const [Category(slug: 'running', name: 'Koşu')]),
        groupByHandleProvider.overrideWith((ref, handle) async => group ?? (throw const NotFoundFailure())),
        myMembershipProvider.overrideWith((ref, id) async => me),
        groupMembersProvider.overrideWith((ref, key) async => const [_owner, _admin, _member]),
        joinRequestsProvider.overrideWith((ref, id) async => requests),
        groupInvitationsProvider.overrideWith((ref, id) async => const []),
        discoverGroupsProvider.overrideWith((ref, search) async => [_group(), _group(policy: JoinPolicy.request)]),
        myInvitationsProvider.overrideWith((ref) async => const []),
        userGroupsProvider.overrideWith((ref, id) async => myGroups),
      ],
      child: MaterialApp(theme: GxTheme.light(), home: child),
    );

void _onOpenProfile(BuildContext context, String username) {}

Future<void> _pumpSmallPhone(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('joinStateOf', () {
    test('follows membership, invitations, requests and join policy', () {
      JoinState of(Group g, MyMembership m, [String? user = 'me']) => joinStateOf(g, m, userId: user);

      expect(of(_group(owner: 'me'), const MyMembership(isMember: true)), JoinState.owner);
      expect(of(_group(), const MyMembership(isMember: true)), JoinState.member);
      expect(of(_group(policy: JoinPolicy.invite), const MyMembership(hasInvitation: true)), JoinState.invited);
      expect(of(_group(policy: JoinPolicy.request), const MyMembership(hasPendingRequest: true)), JoinState.requested);
      expect(of(_group(), const MyMembership()), JoinState.canJoin);
      expect(of(_group(policy: JoinPolicy.request), const MyMembership()), JoinState.canRequest);
      expect(of(_group(policy: JoinPolicy.invite), const MyMembership()), JoinState.inviteOnly);
      expect(of(_group(suspended: true), const MyMembership(isMember: true)), JoinState.suspended);
    });

    test('an invitation wins over the join policy', () {
      expect(
        joinStateOf(_group(policy: JoinPolicy.request), const MyMembership(hasInvitation: true), userId: 'me'),
        JoinState.invited,
      );
    });
  });

  group('GroupRules', () {
    test('handles follow the database format', () {
      expect(GroupRules.validateHandle('istanbul.kosu'), isNull);
      for (final bad in ['ab', 'a' * 31, 'koşu', 'ko su', '.kosu', 'kosu.', 'ko..su', 'kosu!']) {
        expect(GroupRules.validateHandle(bad), isNotNull, reason: bad);
      }
    });

    test('suggested handles fold Turkish letters and are valid', () {
      expect(GroupRules.suggestHandle('İstanbul Koşu Kulübü'), 'istanbul.kosu.kulubu');
      expect(GroupRules.suggestHandle('  Doğa & Yürüyüş!! '), 'doga.yuruyus');
      expect(GroupRules.validateHandle(GroupRules.suggestHandle('Çok uzun bir grup adı ki otuz karakteri geçiyor')), isNull);
    });

    test('links must be http(s) addresses', () {
      expect(GroupRules.validateLinkUrl('https://instagram.com/kosu'), isNull);
      expect(GroupRules.validateLinkUrl('instagram.com/kosu'), isNotNull);
      expect(GroupRules.validateLinkUrl('ftp://dosya.example'), isNotNull);
    });

    test('updates send only the changed fields', () {
      expect(const GroupUpdate(name: 'Yeni').toJson(), {'name': 'Yeni'});
      expect(const GroupUpdate(joinPolicy: JoinPolicy.invite, links: []).toJson(), {'joinPolicy': 'invite', 'links': <Object?>[]});
    });
  });

  group('GroupScreen', () {
    testWidgets('owner sees edit, team and pending requests', (tester) async {
      await tester.pumpWidget(_app(
        const GroupScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
        userId: 'owner',
        group: _group(policy: JoinPolicy.request),
        me: const MyMembership(isMember: true, permissions: _ownerPermissions),
        requests: const [_member],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Grubu düzenle'), findsOneWidget);
      expect(find.text('1 katılım isteği onay bekliyor.'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Zeynep Sanat'), 200);
      expect(find.text('Zeynep Sanat'), findsOneWidget, reason: 'admins are on the team');
      expect(find.text('Demo Kullanıcı'), findsNothing, reason: 'plain members are not on the team');
      expect(find.text('Kurallar'), findsOneWidget);
      expect(find.textContaining('Instagram', findRichText: true), findsOneWidget);
    });

    testWidgets('sections from other features appear once the membership is known', (tester) async {
      Widget section(BuildContext context, Group group, MyMembership me) =>
          Text(me.can(GroupPermission.manageBilling) ? 'Paket: ${group.name}' : 'Paket yok');

      await tester.pumpWidget(_app(
        GroupScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile, sections: [section]),
        userId: 'owner',
        group: _group(),
        me: const MyMembership(isMember: true, permissions: {..._ownerPermissions, GroupPermission.manageBilling}),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Paket: İstanbul Koşu Kulübü'), 200);
      expect(find.text('Paket: İstanbul Koşu Kulübü'), findsOneWidget);
    });

    testWidgets('visitor of a request group can ask to join', (tester) async {
      await tester.pumpWidget(_app(
        const GroupScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
        userId: 'visitor',
        group: _group(policy: JoinPolicy.request),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Katılma isteği gönder'), findsOneWidget);
      expect(find.text('Grubu düzenle'), findsNothing);
    });

    testWidgets('invited user can accept or decline', (tester) async {
      await tester.pumpWidget(_app(
        const GroupScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
        userId: 'visitor',
        group: _group(policy: JoinPolicy.invite),
        me: const MyMembership(hasInvitation: true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Daveti kabul et'), findsOneWidget);
      expect(find.text('Reddet'), findsOneWidget);
    });

    testWidgets('does not overflow at 130% text scale on a small phone', (tester) async {
      await _pumpSmallPhone(
        tester,
        _app(
          const GroupScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
          userId: 'visitor',
          group: _group(policy: JoinPolicy.invite),
          me: const MyMembership(hasInvitation: true),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('missing group shows an empty state with an action', (tester) async {
      await tester.pumpWidget(_app(const GroupScreen(handle: 'yok', onOpenProfile: _onOpenProfile), userId: 'visitor'));
      await tester.pumpAndSettle();

      expect(find.text('Bu grup bulunamadı ya da artık görünür değil.'), findsOneWidget);
      expect(find.text('Gruplara dön'), findsOneWidget);
    });
  });

  group('GroupsScreen', () {
    testWidgets('lists groups and lays out at 130% text scale', (tester) async {
      await _pumpSmallPhone(tester, _app(const GroupsScreen(), userId: 'me'));

      expect(tester.takeException(), isNull);
      expect(find.text('İstanbul Koşu Kulübü'), findsNWidgets(2));
      expect(find.text('İstekle katılım'), findsOneWidget);
    });

    testWidgets('my groups shows an empty state with an action', (tester) async {
      await tester.pumpWidget(_app(const GroupsScreen(), userId: 'me'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gruplarım'));
      await tester.pumpAndSettle();

      expect(find.text('Henüz bir gruba katılmadın.'), findsOneWidget);
      expect(find.text('Grupları keşfet'), findsOneWidget);
    });

    testWidgets('packages tab lists only the groups the user owns, at 130% text scale', (tester) async {
      final owned = _group(owner: 'me');
      final joined = Group(
        id: 'g2',
        handle: 'bisiklet',
        name: 'Bisiklet Turları',
        categorySlug: 'running',
        joinPolicy: JoinPolicy.open,
        ownerId: 'owner',
        memberCount: 8,
        createdAt: DateTime(2026, 10, 1),
      );
      await _pumpSmallPhone(
        tester,
        _app(GroupsScreen(packages: (_, g) => Text('paket ${g.handle}')), userId: 'me', myGroups: [owned, joined]),
      );

      await tester.tap(find.text('Paketler'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('paket istanbul.kosu'), findsOneWidget);
      expect(find.text('Bisiklet Turları'), findsNothing);
    });

    testWidgets('packages tab without an owned group offers to create one', (tester) async {
      await tester.pumpWidget(_app(GroupsScreen(packages: (_, g) => const SizedBox()), userId: 'me'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paketler'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Paketleri grup sahipleri alır.'), findsOneWidget);
      expect(find.text('Grup oluştur'), findsNWidgets(2));
    });
  });

  group('GroupMembersScreen', () {
    testWidgets('owner gets request and invitation tabs and role controls', (tester) async {
      await tester.pumpWidget(_app(
        const GroupMembersScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
        userId: 'owner',
        group: _group(),
        me: const MyMembership(isMember: true, permissions: _ownerPermissions),
      ));
      await tester.pumpAndSettle();

      expect(find.text('İstekler'), findsOneWidget);
      expect(find.text('Davetler'), findsOneWidget);
      expect(find.byTooltip('Zeynep Sanat için seçenekler'), findsOneWidget);
      expect(find.byTooltip('Elif Koşar için seçenekler'), findsNothing, reason: 'no controls on yourself');

      await tester.tap(find.byTooltip('Zeynep Sanat için seçenekler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Roller'));
      await tester.pumpAndSettle();
      expect(find.text('Sahipliği devret'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Yönetici')).value, isTrue);
    });

    testWidgets('plain member sees the member list and can only report', (tester) async {
      await tester.pumpWidget(_app(
        const GroupMembersScreen(handle: 'istanbul.kosu', onOpenProfile: _onOpenProfile),
        userId: 'u3',
        group: _group(),
        me: const MyMembership(isMember: true, roles: [GroupRole.member]),
      ));
      await tester.pumpAndSettle();

      expect(find.text('İstekler'), findsNothing);
      expect(find.text('Demo Kullanıcı'), findsOneWidget);
      await tester.tap(find.byTooltip('Zeynep Sanat için seçenekler'));
      await tester.pumpAndSettle();
      expect(find.text('Şikayet et'), findsOneWidget);
      expect(find.text('Roller'), findsNothing);
      expect(find.text('Disiplin dosyası aç'), findsNothing);
    });

    testWidgets('a moderator opens cases only about lower ranks', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(_app(
        GroupMembersScreen(
          handle: 'istanbul.kosu',
          onOpenProfile: _onOpenProfile,
          onOpenCase: (context, group, person, {required canMute}) => opened.add('${person.userId}:$canMute'),
        ),
        userId: 'u4',
        group: _group(),
        me: const MyMembership(
          isMember: true,
          roles: [GroupRole.moderator, GroupRole.member],
          permissions: {GroupPermission.reviewReports, GroupPermission.muteMembers},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Zeynep Sanat için seçenekler'));
      await tester.pumpAndSettle();
      expect(find.text('Disiplin dosyası aç'), findsNothing, reason: 'a Yönetici outranks a moderator');
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Demo Kullanıcı için seçenekler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disiplin dosyası aç'));
      await tester.pumpAndSettle();
      expect(opened, ['u3:true']);
    });
  });
  testWidgets('another feature can add a line under each member', (tester) async {
    await tester.pumpWidget(_app(
      GroupMembersScreen(
        handle: 'istanbul.kosu',
        onOpenProfile: _onOpenProfile,
        memberNote: (ref, group, person) => person.userId == 'u3' ? '12 katılım' : null,
      ),
      userId: 'u3',
      group: _group(),
      me: const MyMembership(isMember: true, roles: [GroupRole.member]),
    ));
    await tester.pumpAndSettle();
    expect(find.text('@demo · 12 katılım'), findsOneWidget);
    expect(find.text('@zeynep'), findsOneWidget);
  });
}
