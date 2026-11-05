import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n.dart';

/// The language list (docs/ARCHITECTURE.md §11): every language in its own name, the current one checked.
Future<void> showLanguagePicker(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _LanguageList(),
    );

class _LanguageList extends ConsumerWidget {
  const _LanguageList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.xxs),
              child: Text(identityL10n.chooseLanguage, style: textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.sm),
              child: Text(identityL10n.languageNote, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            ),
            for (final language in AppLanguage.values)
              ListTile(
                minTileHeight: GwSpacing.minTouchTarget + GwSpacing.xs,
                title: Text(language.nativeName),
                trailing: language == current ? const Icon(Icons.check_rounded, color: GwColors.primary) : null,
                selected: language == current,
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(appLanguageProvider.notifier).choose(language);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// The current language with a globe, opening [showLanguagePicker]; on the sign-in screens.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);
    return Semantics(
      button: true,
      label: '${identityL10n.language}: ${current.nativeName}',
      excludeSemantics: true,
      child: TextButton.icon(
        onPressed: () => showLanguagePicker(context),
        icon: const Icon(Icons.language_rounded),
        label: Text(current.nativeName),
      ),
    );
  }
}
