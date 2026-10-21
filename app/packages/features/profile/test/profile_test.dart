import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';
import 'package:profile/src/data/supabase_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _profile = Profile(
  id: 'u1',
  username: 'ayse.k',
  displayName: 'Ayşe Kaya',
  bio: 'Hafta sonları doğa yürüyüşü.',
  createdAt: DateTime(2026, 10, 1),
);

void main() {
  group('UsernameRules', () {
    test('accepts valid names after normalizing', () {
      expect(UsernameRules.validate('  Ayse_K.26 '), isNull);
      expect(UsernameRules.normalize('  Ayse_K.26 '), 'ayse_k.26');
    });

    test('rejects what the database rejects', () {
      for (final bad in ['', 'ab', 'a' * 31, 'ayşe', 'ay se', '.ayse', 'ayse.', 'ay..se', 'ayse!']) {
        expect(UsernameRules.validate(bad), isNotNull, reason: bad);
      }
    });
  });

  test('display name is required and limited', () {
    expect(ProfileRules.validateDisplayName('  '), isNotNull);
    expect(ProfileRules.validateDisplayName('a' * 51), isNotNull);
    expect(ProfileRules.validateDisplayName('Ayşe'), isNull);
  });

  test('username lock lasts 30 days after a change', () {
    final changed = DateTime(2026, 10, 1);
    final p = Profile(id: 'u', username: 'a_b', displayName: 'A', bio: '', createdAt: changed, usernameChangedAt: changed);

    expect(p.usernameLockedUntil(DateTime(2026, 10, 15)), DateTime(2026, 10, 31));
    expect(p.usernameLockedUntil(DateTime(2026, 11, 1)), isNull);
    expect(_profile.usernameLockedUntil(DateTime(2026, 10, 15)), isNull, reason: 'never changed');
  });

  test('only bucket-accepted image types upload', () {
    ImageUpload f(String name) => ImageUpload(bytes: Uint8List(0), fileName: name);

    expect(f('a.JPG').contentType, 'image/jpeg');
    expect(f('a.webp').contentType, 'image/webp');
    expect(f('a.heic').contentType, isNull);
  });

  group('failureFromProfile', () {
    test('database rule messages become Turkish', () {
      expect(
        failureFromProfile(const PostgrestException(message: 'username_change_too_soon', code: 'P0001')).userMessage,
        contains('30 günde'),
      );
      expect(
        failureFromProfile(const PostgrestException(message: 'duplicate key', code: '23505')),
        isA<RuleFailure>().having((f) => f.code, 'code', 'profile.username_taken'),
      );
    });

    test('unknown database errors stay generic', () {
      final f = failureFromProfile(const PostgrestException(message: 'relation "x" does not exist', code: '42P01'));

      expect(f, isA<UnexpectedFailure>());
      expect(f.userMessage, isNot(contains('relation')));
    });
  });

  group('ProfileScreen', () {
    Widget app({String? currentUser = 'u1'}) => ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue(currentUser),
            myProfileProvider.overrideWith((ref) async => _profile),
            profileByUsernameProvider.overrideWith((ref, username) async => throw const NotFoundFailure()),
            interestsProvider.overrideWith((ref, id) async => ['hiking', 'music']),
            categoriesProvider.overrideWith(
              (ref) async => const [Category(slug: 'hiking', name: 'Yürüyüş'), Category(slug: 'music', name: 'Müzik')],
            ),
          ],
          child: MaterialApp(theme: GxTheme.light(), home: const ProfileScreen()),
        );

    testWidgets('shows own profile with interests and edit action', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Ayşe Kaya'), findsWidgets);
      expect(find.text('@ayse.k'), findsWidgets);
      expect(find.text('Yürüyüş'), findsOneWidget);
      expect(find.text('Profili düzenle'), findsOneWidget);
    });

    testWidgets('does not overflow at 130% text scale on a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('missing profile shows an empty state with an action', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('u1'),
            profileByUsernameProvider.overrideWith((ref, username) async => throw const NotFoundFailure()),
          ],
          child: MaterialApp(theme: GxTheme.light(), home: const ProfileScreen(username: 'yok')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bu profil bulunamadı ya da artık görünür değil.'), findsOneWidget);
      expect(find.text('Profilime dön'), findsOneWidget);
    });
  });
}
