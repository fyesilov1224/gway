import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_notifications.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'widgets.dart';

/// Whether push works: registered phones, what reached them and what is waiting (docs/ARCHITECTURE.md §3c, Admin).
class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(pushStatsProvider);
    final stats = result.value;
    final textTheme = Theme.of(context).textTheme;

    return AdminPage(
      title: 'Bildirimler',
      subtitle: 'Telefonlara giden push bildirimleri. Yalnızca sayılar gösterilir; bildirim içerikleri görünmez.',
      actions: [
        GxButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GxButtonVariant.secondary,
          onPressed: () => ref.invalidate(pushStatsProvider),
        ),
      ],
      children: [
        if (result case AsyncError(:final error))
          GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(pushStatsProvider))
        else ...[
          if (stats != null && !stats.configured) ...[
            const DetailBanner(
              tone: GxBadgeTone.danger,
              icon: Icons.notifications_off_outlined,
              title: 'Push kapalı',
              body: 'Sunucuda Firebase anahtarı tanımlı değil. Bildirimler yalnızca uygulama içinde görünür.',
            ),
            const SizedBox(height: GxSpacing.lg),
          ],
          StatCardRow(
            cards: [
              StatCard(
                label: 'Kayıtlı cihaz',
                value: stats?.devices,
                icon: Icons.smartphone_outlined,
                tone: GxBadgeTone.primary,
              ),
              StatCard(
                label: 'Son 24 saatte bildirim',
                value: stats?.created24h,
                icon: Icons.notifications_outlined,
                tone: GxBadgeTone.info,
              ),
              StatCard(
                label: 'Telefona ulaşan',
                value: stats?.delivered24h,
                icon: Icons.mark_email_read_outlined,
                tone: GxBadgeTone.success,
              ),
              StatCard(
                label: 'Kuyrukta bekleyen',
                value: stats?.waiting,
                icon: Icons.hourglass_empty,
                tone: (stats?.waiting ?? 0) > 0 ? GxBadgeTone.warning : GxBadgeTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: GxSpacing.lg),
          if (stats == null)
            const GxSkeleton(height: GxSpacing.xxl * 2)
          else ...[
            InfoPanel(
              title: 'Cihazlar',
              rows: [
                ('Push', stats.configured ? 'Açık' : 'Kapalı'),
                ('Android', formatCount(stats.androidDevices)),
                ('iOS', formatCount(stats.iosDevices)),
                ('Web', formatCount(stats.webDevices)),
                ('Cihazı olan kişi', formatCount(stats.usersWithDevice)),
                ('Son 24 saatte teslim', '${formatCount(stats.deliveries24h)} cihaz'),
              ],
            ),
            const SizedBox(height: GxSpacing.lg),
            GxPanel(
              title: 'Son 24 saat, türlere göre',
              padding: EdgeInsets.zero,
              child: stats.byType24h.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
                      child: GxEmptyState(
                        icon: Icons.notifications_none_outlined,
                        message: 'Son 24 saatte bildirim oluşmadı.',
                        actionLabel: 'Yenile',
                        onAction: () => ref.invalidate(pushStatsProvider),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, t) in stats.byType24h.indexed) ...[
                          if (i > 0) const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(child: Text(notificationTypeLabel(t.type), style: textTheme.bodyMedium)),
                                Text(formatCount(t.count), style: textTheme.labelLarge),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ],
    );
  }
}
