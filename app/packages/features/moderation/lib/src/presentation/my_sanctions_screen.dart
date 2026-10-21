import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import 'group_moderation_screen.dart';
import 'providers.dart';

/// The user's own sanctions in every group, with the case's reason and the appeal (docs/ARCHITECTURE.md §3e).
class MySanctionsScreen extends ConsumerWidget {
  const MySanctionsScreen({super.key, required this.openGroup});

  final void Function(BuildContext context, String handle) openGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sanctions = ref.watch(mySanctionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Yaptırımlarım')),
      body: switch (sanctions) {
        AsyncData(:final value) when value.isEmpty => GxEmptyState(
            icon: Icons.verified_outlined,
            message: 'Hiçbir grupta yaptırımın yok. Topluluk kurallarına uyduğun için teşekkürler.',
            actionLabel: 'Yenile',
            onAction: () => ref.invalidate(mySanctionsProvider),
          ),
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.refresh(mySanctionsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(GxSpacing.page),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: GxSpacing.sm),
              itemBuilder: (context, i) => _SanctionTile(sanction: value[i], openGroup: openGroup),
            ),
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(mySanctionsProvider)),
        _ => ListView(
            padding: const EdgeInsets.all(GxSpacing.page),
            children: const [GxSkeleton(height: GxSpacing.xxl * 2), SizedBox(height: GxSpacing.sm), GxSkeleton(height: GxSpacing.xxl * 2)],
          ),
      },
    );
  }
}

/// "3 gün susturma · 24 Ekim 2026, 18:00 tarihine kadar", "Gruptan çıkarma", "Kaldırıldı".
String mySanctionStatus(MySanction s) {
  if (s.liftedAt != null) return s.interim ? 'Acil susturma sona erdi' : 'Kaldırıldı';
  if (s.interim) return 'Acil susturma · kurul kararına kadar, en geç ${formatDateTimeTr(s.endsAt!)}';
  return switch (s.type) {
    SanctionType.mute || SanctionType.ban when s.endsAt != null =>
      s.endsAt!.isAfter(DateTime.now()) ? '${formatDateTimeTr(s.endsAt!)} tarihine kadar' : 'Sona erdi',
    SanctionType.ban => 'Kalıcı',
    _ => formatDateTimeTr(s.startsAt),
  };
}

class _SanctionTile extends ConsumerWidget {
  const _SanctionTile({required this.sanction, required this.openGroup});

  final MySanction sanction;
  final void Function(BuildContext context, String handle) openGroup;

  Future<void> _appeal(BuildContext context, WidgetRef ref) async {
    final body = await askText(
      context,
      title: 'İtiraz et',
      label: 'Neden haksız olduğunu düşünüyorsun?',
      confirm: 'Gönder',
      minLength: 10,
      maxLength: 1000,
    );
    if (body == null || !context.mounted) return;
    final result = await ref.read(moderationRepositoryProvider).appeal(sanction.id, body);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => 'İtirazın gönderildi. Karar verilince bildirim alacaksın.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(mySanctionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = sanction;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    final appeal = s.appeal;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: GxRadius.lgAll, border: Border.all(color: GxColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(GxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => openGroup(context, s.group.handle),
              borderRadius: GxRadius.smAll,
              child: Row(
                children: [
                  GxAvatar(name: s.group.name, imageUrl: s.group.logoUrl, shape: GxAvatarShape.group, size: GxAvatarSize.sm),
                  const SizedBox(width: GxSpacing.sm),
                  Expanded(child: Text(s.group.name, style: textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            const SizedBox(height: GxSpacing.sm),
            Text(s.interim ? 'Acil susturma' : s.type.label, style: textTheme.titleSmall),
            Text(mySanctionStatus(s), style: secondary),
            if (s.reason.isNotEmpty) ...[const SizedBox(height: GxSpacing.xs), Text('Gerekçe: ${s.reason}', style: textTheme.bodyMedium)],
            if (appeal != null) ...[
              const SizedBox(height: GxSpacing.sm),
              Text('İtirazın · ${appeal.status.label}', style: textTheme.labelLarge),
              if (appeal.decisionNote case final note?) Text('Not: $note', style: secondary),
            ] else if (s.canAppeal) ...[
              const SizedBox(height: GxSpacing.sm),
              Text('Bu karara 7 gün içinde bir kez itiraz edebilirsin.', style: secondary),
              const SizedBox(height: GxSpacing.xs),
              GxButton(label: 'İtiraz et', icon: Icons.record_voice_over_outlined, variant: GxButtonVariant.secondary, onPressed: () => _appeal(context, ref)),
            ],
          ],
        ),
      ),
    );
  }
}
