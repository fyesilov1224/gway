import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';
import 'package:social_app/src/l10n.dart';

/// Reads a text through a package getter, like every screen does; const, so only `rebuildAll` refreshes it.
class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) => Text(socialAppL10n.settings);
}

/// The part of `SocialApp` that follows the language (docs/ARCHITECTURE.md §11).
class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    ref.listen(appLanguageProvider, (_, _) => WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) rebuildAll(context);
        }));
    return MaterialApp(
      locale: language.locale,
      supportedLocales: AppLanguage.locales,
      localizationsDelegates: appLocalizationsDelegates,
      home: const Scaffold(body: Column(children: [_Label(), LanguageButton()])),
    );
  }
}

void main() {
  tearDown(() => setCurrentAppLanguage(AppLanguage.tr));

  testWidgets('choosing a language changes every text at once, the choice is kept', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appLanguageProvider.notifier).choose(AppLanguage.tr);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const _App()));
    expect(find.text('Ayarlar'), findsOneWidget);

    await tester.tap(find.byType(LanguageButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(currentAppLanguage, AppLanguage.de);
    expect(coreL10n.networkFailure, startsWith('Keine Verbindung'));
  });

  testWidgets('Arabic lays the app out right to left', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appLanguageProvider.notifier).choose(AppLanguage.ar);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const _App()));
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(_Label))), TextDirection.rtl);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
