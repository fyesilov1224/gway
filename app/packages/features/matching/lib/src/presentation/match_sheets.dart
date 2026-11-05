import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/matching.dart';
import '../l10n.dart';
import 'providers.dart';

/// "Eşleştiniz!" after a mutual like.
Future<void> showMatchDialog(BuildContext context, {required MatchCard card, required VoidCallback onMessage}) => showDialog<void>(
      context: context,
      builder: (dialog) {
        final textTheme = Theme.of(dialog).textTheme;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GwAvatar(
                name: card.displayName,
                shape: GwAvatarShape.user,
                size: GwAvatarSize.xl,
                imageUrl: card.photoUrls.isEmpty ? null : card.photoUrls.first,
              ),
              const SizedBox(height: GwSpacing.md),
              Text(matchingL10n.itsAMatch, style: textTheme.headlineSmall?.copyWith(color: GwColors.primary)),
              const SizedBox(height: GwSpacing.xs),
              Text(matchingL10n.bothLiked(card.displayName), textAlign: TextAlign.center),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            GwButton(label: matchingL10n.keepSwiping, variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop()),
            GwButton(
              label: matchingL10n.sendMessage,
              icon: Icons.chat_bubble_outline,
              onPressed: () {
                Navigator.of(dialog).pop();
                onMessage();
              },
            ),
          ],
        );
      },
    );

/// Report the profile or the photo on screen, or block the person.
Future<void> showCardMenu(BuildContext context, WidgetRef ref, MatchCard card, {required int photoIndex, required VoidCallback afterBlock}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(matchingL10n.reportProfile),
              onTap: () {
                Navigator.of(sheet).pop();
                ref.read(reportLauncherProvider)(context, ReportTarget.matchProfile(card.userId));
              },
            ),
            if (photoIndex < card.photoIds.length)
              ListTile(
                leading: const Icon(Icons.image_not_supported_outlined),
                title: Text(matchingL10n.reportPhoto),
                onTap: () {
                  Navigator.of(sheet).pop();
                  ref.read(reportLauncherProvider)(context, ReportTarget.matchPhoto(card.photoIds[photoIndex]));
                },
              ),
            ListTile(
              leading: const Icon(Icons.block, color: GwColors.error),
              title: Text(matchingL10n.block, style: const TextStyle(color: GwColors.error)),
              subtitle: Text(matchingL10n.blockHint),
              onTap: () async {
                Navigator.of(sheet).pop();
                final result = await ref.read(matchingRepositoryProvider).block(card.userId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(switch (result) {
                    Ok() => '${card.displayName} engellendi.',
                    Err(:final failure) => failure.userMessage,
                  }),
                ));
                if (result is Ok) afterBlock();
              },
            ),
          ],
        ),
      ),
    );

/// Asks before a destructive step; true when confirmed.
Future<bool> confirmMatchAction(BuildContext context, {required String title, required String message, required String confirmLabel}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          GwButton(label: matchingL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GwButton(label: confirmLabel, onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    ) ??
    false;
