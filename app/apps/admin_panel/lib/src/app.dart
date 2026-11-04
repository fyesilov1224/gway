import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';

import 'router.dart';

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GWAY Yönetim',
      // The panel stays Turkish (docs/ARCHITECTURE.md §11).
      locale: AppLanguage.tr.locale,
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: coreLocalizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: GwTheme.light(),
      routerConfig: router,
      builder: (_, child) => SecurityHeartbeat(
        navigatorContext: () => router.routerDelegate.navigatorKey.currentContext,
        child: child!,
      ),
    );
  }
}
