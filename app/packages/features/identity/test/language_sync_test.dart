import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

class _FakeServerLanguage implements ServerLanguageRepository {
  final saved = <AppLanguage>[];

  @override
  Future<Result<void>> save(AppLanguage language) async {
    saved.add(language);
    return const Ok(null);
  }
}

void main() {
  tearDown(() => setCurrentAppLanguage(AppLanguage.tr));

  testWidgets('a signed-in person\'s language goes to the server at start and on every change', (tester) async {
    final server = _FakeServerLanguage();
    final container = ProviderContainer(overrides: [
      serverLanguageRepositoryProvider.overrideWithValue(server),
      currentUserIdProvider.overrideWithValue('u1'),
      deviceLocalesProvider.overrideWithValue(const [Locale('de')]),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const LanguageSync(child: SizedBox())));
    expect(server.saved, [AppLanguage.de]);

    await container.read(appLanguageProvider.notifier).choose(AppLanguage.ar);
    await tester.pump();
    expect(server.saved, [AppLanguage.de, AppLanguage.ar]);
  });

  testWidgets('nothing is written while nobody is signed in', (tester) async {
    final server = _FakeServerLanguage();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        serverLanguageRepositoryProvider.overrideWithValue(server),
        currentUserIdProvider.overrideWithValue(null),
        deviceLocalesProvider.overrideWithValue(const [Locale('en')]),
      ],
      child: const LanguageSync(child: SizedBox()),
    ));
    expect(server.saved, isEmpty);
  });
}
