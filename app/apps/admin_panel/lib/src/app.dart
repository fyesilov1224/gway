import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';

import 'router.dart';

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GrupX Yönetim',
      debugShowCheckedModeBanner: false,
      theme: GxTheme.light(),
      routerConfig: ref.watch(routerProvider),
      builder: (_, child) => SecurityHeartbeat(child: child!),
    );
  }
}
