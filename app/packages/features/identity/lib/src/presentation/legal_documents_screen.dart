import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/legal.dart';
import 'providers.dart';

/// Full text of a legal document in a scrollable bottom sheet.
Future<void> showLegalDocument(BuildContext context, LegalDocument document) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(GxRadius.xl)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(GxSpacing.lg, 0, GxSpacing.lg, GxSpacing.xl),
        children: [
          Text(document.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: GxSpacing.xxs),
          Text(
            'Sürüm ${document.version}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
          ),
          const SizedBox(height: GxSpacing.md),
          SelectableText(document.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}

/// The latest version of every legal document, readable at any time (KVKK).
class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(latestLegalDocumentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Hukuki metinler')),
      body: switch (docs) {
        AsyncData(:final value) => ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xs),
            itemCount: value.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              minTileHeight: GxSpacing.xxl + GxSpacing.xs,
              title: Text(value[i].title),
              subtitle: Text('Sürüm ${value[i].version}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLegalDocument(context, value[i]),
            ),
          ),
        AsyncError(:final error) => GxErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(latestLegalDocumentsProvider),
          ),
        _ => ListView(
            padding: const EdgeInsets.all(GxSpacing.md),
            children: const [
              GxSkeleton(height: GxSpacing.xl),
              SizedBox(height: GxSpacing.md),
              GxSkeleton(height: GxSpacing.xl),
              SizedBox(height: GxSpacing.md),
              GxSkeleton(height: GxSpacing.xl),
            ],
          ),
      },
    );
  }
}
