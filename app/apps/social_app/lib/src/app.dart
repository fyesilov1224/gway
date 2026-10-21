import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GrupX',
      debugShowCheckedModeBanner: false,
      theme: GxTheme.light(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
