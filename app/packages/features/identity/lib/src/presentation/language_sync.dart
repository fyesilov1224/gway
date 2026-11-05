import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

final _signedInLanguage = Provider<(String?, AppLanguage)>(
  (ref) => (ref.watch(currentUserIdProvider), ref.watch(appLanguageProvider)),
);

/// Tells the server the app language (docs/ARCHITECTURE.md §11, Sunucu) when someone signs in and whenever the
/// language changes, so pushes, server messages and e-mails follow it. A failed write is tried again next time.
class LanguageSync extends ConsumerStatefulWidget {
  const LanguageSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LanguageSync> createState() => _LanguageSyncState();
}

class _LanguageSyncState extends ConsumerState<LanguageSync> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(_signedInLanguage, (_, next) {
      final (userId, language) = next;
      if (userId != null) unawaited(ref.read(serverLanguageRepositoryProvider).save(language));
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
