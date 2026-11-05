import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/legal.dart';
import '../l10n.dart';
import 'account_screens.dart';
import 'legal_documents_screen.dart';
import 'providers.dart';

/// A legal text anyone can open without signing in: the store listing links here (docs/ARCHITECTURE.md §10).
class PublicLegalScreen extends ConsumerWidget {
  const PublicLegalScreen({super.key, required this.kind});

  final LegalKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(latestLegalDocumentsProvider);
    final textTheme = Theme.of(context).textTheme;
    return _PublicPage(
      child: switch (docs) {
        AsyncData(:final value) => switch (value.where((d) => d.kind == kind).firstOrNull) {
            final doc? => LegalText(document: doc, titleStyle: textTheme.headlineMedium),
            null => GwEmptyState(
                icon: Icons.description_outlined,
                message: identityL10n.documentNotPublished,
                actionLabel: identityL10n.refresh,
                onAction: () => ref.invalidate(latestLegalDocumentsProvider),
              ),
          },
        AsyncError(:final error) =>
          GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(latestLegalDocumentsProvider)),
        _ => const GwSkeleton(height: GwSpacing.xxl * 6, borderRadius: GwRadius.lgAll),
      },
    );
  }
}

/// How to delete an account and its data: the web page Google Play asks for (docs/ARCHITECTURE.md §10).
class AccountDeletionInfoScreen extends StatelessWidget {
  const AccountDeletionInfoScreen({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget step(String number, String text) => Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: GwSpacing.lg, child: Text(number, style: textTheme.titleMedium)),
              Expanded(child: Text(text, style: textTheme.bodyLarge)),
            ],
          ),
        );
    return _PublicPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(identityL10n.deletionInfoTitle, style: textTheme.headlineMedium),
          const SizedBox(height: GwSpacing.md),
          Text(identityL10n.deletionInfoIntro, style: textTheme.bodyLarge),
          const SizedBox(height: GwSpacing.md),
          step('1.', identityL10n.deletionInfoStep1),
          step('2.', identityL10n.deletionInfoStep2),
          step('3.', identityL10n.deletionInfoStep3),
          const SizedBox(height: GwSpacing.sm),
          Text(identityL10n.deletionInfoWhat, style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xs),
          Text(
            identityL10n.deletionInfoBody(AccountRetention.graceDays),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: GwSpacing.lg),
          GwButton(label: identityL10n.signIn, icon: Icons.login, onPressed: onSignIn),
        ],
      ),
    );
  }
}

class _PublicPage extends StatelessWidget {
  const _PublicPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: GwLogo(size: GwSpacing.xl + GwSpacing.xs, wordmark: true)),
                  const SizedBox(height: GwSpacing.lg),
                  GwCard(padding: const EdgeInsets.all(GwSpacing.lg), child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
