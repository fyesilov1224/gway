import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification.dart';
import 'providers.dart';

/// The user turns event reminders and change notices on or off (docs/ARCHITECTURE.md §3c, Tercihler).
class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  /// The switches move at once; a failed save puts them back.
  NotificationPreferences? _shown;

  Future<void> _save(NotificationPreferences before, NotificationPreferences after) async {
    setState(() => _shown = after);
    final result = await ref.read(notificationsRepositoryProvider).savePreferences(after);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      setState(() => _shown = before);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(notificationPreferencesProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim tercihleri')),
      body: GxReadingColumn(
        child: switch (saved) {
          AsyncData(:final value) => () {
              final p = _shown ?? value;
              Widget toggle(String title, String subtitle, bool on, NotificationPreferences Function(bool) change) => SwitchListTile(
                    value: on,
                    onChanged: (v) => _save(p, change(v)),
                    title: Text(title),
                    subtitle: Text(subtitle),
                  );
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: GxSpacing.sm),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.xs, GxSpacing.page, GxSpacing.xs),
                    child: Text('Organizasyonlar', style: textTheme.titleSmall),
                  ),
                  toggle('1 gün önce hatırlat', 'Katıldığın organizasyon yarın başlıyorsa', p.reminderDay,
                      (v) => p.copyWith(reminderDay: v)),
                  toggle('1 saat önce hatırlat', 'Katıldığın organizasyon 1 saat içinde başlıyorsa', p.reminderHour,
                      (v) => p.copyWith(reminderHour: v)),
                  toggle('Değişiklik ve iptaller', 'Zaman ya da yer değişince ya da organizasyon iptal edilince', p.eventUpdates,
                      (v) => p.copyWith(eventUpdates: v)),
                  toggle('Değerlendirme istekleri', 'Katıldığın organizasyon bitince "Nasıldı?" diye sor', p.reviewRequests,
                      (v) => p.copyWith(reviewRequests: v)),
                  Padding(
                    padding: const EdgeInsets.all(GxSpacing.page),
                    child: Text(
                      'Katılım isteğinin sonucu, bekleme listesinden yükselmen ve grup yaptırımları seni doğrudan ilgilendirdiği için her zaman bildirilir.',
                      style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                    ),
                  ),
                ],
              );
            }(),
          AsyncError(:final error) => GxErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(notificationPreferencesProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(GxSpacing.page),
              child: Column(children: [GxSkeleton(height: GxSpacing.xxl), SizedBox(height: GxSpacing.sm), GxSkeleton(height: GxSpacing.xxl)]),
            ),
        },
      ),
    );
  }
}
