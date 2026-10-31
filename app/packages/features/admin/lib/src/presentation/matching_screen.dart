import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_matching.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Matching at a glance, its daily allowances and Eşleşme Premium (docs/ARCHITECTURE.md §3g, Admin).
/// Reported profiles and photos are handled on the reports page.
class AdminMatchingScreen extends ConsumerWidget {
  const AdminMatchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(matchingStatsProvider);
    final stats = result.value;
    final packages = ref.watch(matchingPackagesProvider).value;
    final members = packages?.fold<int>(0, (n, p) => n + p.activeMembers);
    final isAdmin = ref.watch(myStaffRoleProvider).value?.code == 'admin';

    void refresh() => ref
      ..invalidate(matchingStatsProvider)
      ..invalidate(matchingPackagesProvider);

    return AdminPage(
      title: 'Eşleşme',
      subtitle: 'Arkadaş ve sevgili eşleşmeleri ve ücretli paketler. Yalnızca sayılar gösterilir; şikayet edilen profiller ve fotoğraflar Şikayetler sayfasındadır.',
      actions: [
        if (isAdmin && packages != null)
          GwButton(
            label: 'Paket tanımla',
            icon: Icons.workspace_premium_outlined,
            variant: GwButtonVariant.secondary,
            onPressed: () => _grantPackage(context, ref, packages),
          ),
        GwButton(
          label: 'Şikayetler',
          icon: Icons.flag_outlined,
          variant: GwButtonVariant.secondary,
          onPressed: () => context.go(AdminRoutes.reports),
        ),
        GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: refresh),
      ],
      children: [
        if (result case AsyncError(:final error))
          GwErrorState(message: userMessageOf(error), onRetry: refresh)
        else ...[
          StatCardRow(
            cards: [
              StatCard(label: 'Açık profil', value: stats?.profiles, icon: Icons.badge_outlined, tone: GwBadgeTone.primary),
              StatCard(label: 'Son 24 saatte eşleşme', value: stats?.matches24h, icon: Icons.favorite_border_rounded, tone: GwBadgeTone.success),
              StatCard(label: 'Paket (kişi × paket)', value: members, icon: Icons.workspace_premium_outlined, tone: GwBadgeTone.info),
              StatCard(
                label: 'Açık şikayet',
                value: stats?.openReports,
                icon: Icons.flag_outlined,
                tone: (stats?.openReports ?? 0) > 0 ? GwBadgeTone.danger : GwBadgeTone.neutral,
                onTap: () => context.go(AdminRoutes.reports),
              ),
            ],
          ),
          const SizedBox(height: GwSpacing.lg),
          if (stats == null)
            const GwSkeleton(height: GwSpacing.xxl * 2)
          else ...[
            InfoPanel(
              title: 'Profiller',
              rows: [
                ('Arkadaş modu', formatCount(stats.friendProfiles)),
                ('Sevgili modu', formatCount(stats.datingProfiles)),
                ('Kadın · Erkek · İkili olmayan', '${formatCount(stats.women)} · ${formatCount(stats.men)} · ${formatCount(stats.nonbinary)}'),
                ('Paketli profil', formatCount(stats.premiumProfiles)),
                ('Duraklatılmış', formatCount(stats.paused)),
                ('Platform ekibince kapatılmış', formatCount(stats.suspended)),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            InfoPanel(
              title: 'Son 24 saat',
              rows: [
                ('Beğeni', formatCount(stats.likes24h)),
                ('Süper beğeni', formatCount(stats.superLikes24h)),
                ('Geç', formatCount(stats.passes24h)),
                ('Yeni eşleşme', formatCount(stats.matches24h)),
                ('Süren eşleşme', formatCount(stats.activeMatches)),
                ('Şu an öne çıkan', formatCount(stats.activeBoosts)),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            GwPanel(
              title: 'Günlük haklar',
              trailing: isAdmin
                  ? GwButton(
                      label: 'Değiştir',
                      icon: Icons.edit_outlined,
                      variant: GwButtonVariant.text,
                      onPressed: () => _editSettings(context, ref, stats.settings),
                    )
                  : null,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoRow(label: 'Günlük ücretsiz beğeni', value: formatCount(stats.settings.dailyFreeLikes)),
                  InfoRow(
                    label: 'Süper beğeni (ücretsiz · paketli)',
                    value: '${stats.settings.dailyFreeSuperLikes} · ${stats.settings.dailyPremiumSuperLikes}',
                  ),
                  InfoRow(label: 'Öne çıkma süresi', value: '${stats.settings.boostMinutes} dakika'),
                ],
              ),
            ),
          ],
          const SizedBox(height: GwSpacing.lg),
          if (packages != null)
            GwPanel(
              title: 'Paketler',
              subtitle: 'Aylık fiyat (TRY) · kişi (tanımlanan) · son 30 gün gelir. ${isAdmin ? 'Düzenlemek için pakete dokun.' : ''}',
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final p in packages)
                    ListTile(
                      onTap: isAdmin ? () => _editPremium(context, ref, p) : null,
                      title: Text('${p.name}${p.isActive ? '' : ' · satış kapalı'}'),
                      subtitle: Text(
                        '${p.price('TRY', 'month') == null ? '—' : formatMoney(p.price('TRY', 'month')!, 'TRY')} · '
                        '${formatCount(p.activeMembers)} kişi (${formatCount(p.grantedMembers)}) · '
                        '${p.revenue30d.isEmpty ? 'gelir yok' : [for (final r in p.revenue30d) formatMoney(r.amountMinor, r.currency)].join(' + ')}',
                      ),
                      trailing: isAdmin ? const Icon(Icons.edit_outlined) : null,
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

void _say(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

Future<void> _editSettings(BuildContext context, WidgetRef ref, AdminMatchingSettings current) async {
  final fields = [
    ('Günlük ücretsiz beğeni (1–1000)', current.dailyFreeLikes),
    ('Günlük süper beğeni, ücretsiz (0–100)', current.dailyFreeSuperLikes),
    ('Günlük süper beğeni, Premium (0–100)', current.dailyPremiumSuperLikes),
    ('Öne çıkma süresi, dakika (5–180)', current.boostMinutes),
  ];
  final controllers = [for (final (_, v) in fields) TextEditingController(text: '$v')];
  final save = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Günlük haklar'),
      content: SizedBox(
        width: GwLayout.formMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (label, _)) in fields.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: GwSpacing.sm),
                child: TextField(controller: controllers[i], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label)),
              ),
          ],
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
        GwButton(label: 'Kaydet', onPressed: () => Navigator.of(dialog).pop(true)),
      ],
    ),
  );
  final values = [for (final c in controllers) int.tryParse(c.text.trim())];
  for (final c in controllers) {
    c.dispose();
  }
  if (save != true || !context.mounted) return;
  if (values.contains(null)) return _say(context, 'Her alana bir sayı gir.');
  final result = await ref.read(adminMatchingRepositoryProvider).updateSettings(AdminMatchingSettings(
        dailyFreeLikes: values[0]!,
        dailyFreeSuperLikes: values[1]!,
        dailyPremiumSuperLikes: values[2]!,
        boostMinutes: values[3]!,
      ));
  if (!context.mounted) return;
  _reportDone(context, result, 'Günlük haklar güncellendi.');
  ref.invalidate(matchingStatsProvider);
}

Future<void> _editPremium(BuildContext context, WidgetRef ref, AdminPremium current) async {
  final name = TextEditingController(text: current.name);
  final keys = [for (final c in ['TRY', 'USD']) for (final p in ['month', 'year']) (c, p)];
  // Prices are typed in major units: 149,00.
  final prices = [
    for (final (c, p) in keys) TextEditingController(text: ((current.price(c, p) ?? 0) / 100).toStringAsFixed(2).replaceAll('.', ',')),
  ];
  var active = current.isActive;
  final save = await showDialog<bool>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setState) => AlertDialog(
        title: Text(current.name),
        content: SizedBox(
          width: GwLayout.formMaxWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Ürün adı')),
                const SizedBox(height: GwSpacing.sm),
                for (final (i, (c, p)) in keys.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GwSpacing.sm),
                    child: TextField(
                      controller: prices[i],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: '${p == 'year' ? 'Yıllık' : 'Aylık'} fiyat ($c)'),
                    ),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Satışta'),
                  value: active,
                  onChanged: (v) => setState(() => active = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GwButton(label: 'Kaydet', onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    ),
  );
  final amounts = [for (final c in prices) double.tryParse(c.text.trim().replaceAll('.', '').replaceAll(',', '.'))];
  final newName = name.text.trim();
  name.dispose();
  for (final c in prices) {
    c.dispose();
  }
  if (save != true || !context.mounted) return;
  if (amounts.any((a) => a == null || a <= 0)) return _say(context, 'Her fiyat sıfırdan büyük bir sayı olmalı.');
  final result = await ref.read(adminMatchingRepositoryProvider).updatePackage(
        current.slug,
        name: newName,
        isActive: active,
        prices: [for (final (i, (c, p)) in keys.indexed) (currency: c, period: p, amountMinor: (amounts[i]! * 100).round())],
      );
  if (!context.mounted) return;
  _reportDone(context, result, '${current.name} güncellendi.');
  ref.invalidate(matchingPackagesProvider);
}

Future<void> _grantPackage(BuildContext context, WidgetRef ref, List<AdminPremium> packages) async {
  final request = await showGrantPackageDialog(context, packages);
  if (request == null || !context.mounted) return;
  final (:username, :package, :days, :reason) = request;
  final result = await ref.read(adminMatchingRepositoryProvider).grantPackage(username: username!, slug: package.slug, days: days, reason: reason);
  if (!context.mounted) return;
  _reportDone(context, result, '@$username için $days gün ${package.name} tanımlandı.');
  ref
    ..invalidate(matchingPackagesProvider)
    ..invalidate(matchingStatsProvider);
}

typedef GrantPackageRequest = ({String? username, AdminPremium package, int days, String reason});

/// Package, days and reason; the username too unless the person is already known ([askUsername] false).
Future<GrantPackageRequest?> showGrantPackageDialog(BuildContext context, List<AdminPremium> packages, {bool askUsername = true}) async {
  final username = TextEditingController();
  final days = TextEditingController(text: '30');
  final reason = TextEditingController();
  var package = packages.last;
  final save = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Paket tanımla'),
      content: SizedBox(
        width: GwLayout.formMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Süre, kişinin o paketteki kalan süresinin ardına eklenir. Gerekçe kayda geçer.'),
            const SizedBox(height: GwSpacing.sm),
            DropdownButtonFormField<AdminPremium>(
              initialValue: package,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Paket'),
              items: [for (final p in packages) DropdownMenuItem(value: p, child: Text(p.name))],
              onChanged: (p) => package = p ?? package,
            ),
            if (askUsername) ...[
              const SizedBox(height: GwSpacing.sm),
              TextField(controller: username, decoration: const InputDecoration(labelText: 'Kullanıcı adı', prefixText: '@')),
            ],
            const SizedBox(height: GwSpacing.sm),
            TextField(controller: days, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gün (1–365)')),
            const SizedBox(height: GwSpacing.sm),
            TextField(controller: reason, decoration: const InputDecoration(labelText: 'Gerekçe')),
          ],
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
        GwButton(label: 'Tanımla', onPressed: () => Navigator.of(dialog).pop(true)),
      ],
    ),
  );
  final (who, count, why) = (username.text.trim(), int.tryParse(days.text.trim()) ?? 0, reason.text.trim());
  for (final c in [username, days, reason]) {
    c.dispose();
  }
  if (save != true) return null;
  return (username: askUsername ? who : null, package: package, days: count, reason: why);
}

/// A reported matching photo; matching photos are private, so the address is short-lived.
class MatchPhotoDialog extends ConsumerWidget {
  const MatchPhotoDialog({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: const Text('Şikayet edilen fotoğraf'),
        content: SizedBox(
          width: GwLayout.formMaxWidth / 2,
          child: FutureBuilder(
            future: ref.read(adminMatchingRepositoryProvider).photoUrl(path),
            builder: (context, snapshot) => switch (snapshot.data) {
              Ok(:final value) => ClipRRect(
                  borderRadius: GwRadius.mdAll,
                  child: Image.network(
                    value,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Text('Fotoğraf artık yok; kaldırılmış olabilir.'),
                  ),
                ),
              Err(:final failure) => Text(failure.userMessage),
              null => const GwSkeleton(height: GwSpacing.xxl * 3),
            },
          ),
        ),
        actions: [GwButton(label: 'Kapat', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop())],
      );
}

/// Asks for a reason and removes the photo; true when removed.
Future<bool> removeMatchPhoto(BuildContext context, String photoId) async {
  final request = await showSuspendDialog(
    context,
    title: 'Fotoğrafı kaldır',
    description: 'Fotoğraf eşleşme profilinden ve depodan silinir. Gerekçe kayda geçer.',
    withDuration: false,
    confirmLabel: 'Kaldır',
  );
  if (request == null || !context.mounted) return false;
  final result = await ProviderScope.containerOf(context).read(adminMatchingRepositoryProvider).removePhoto(photoId, reason: request.reason);
  if (!context.mounted) return false;
  return _reportDone(context, result, 'Fotoğraf kaldırıldı.');
}

/// Asks for a reason and a duration and closes the matching profile; true when closed.
Future<bool> suspendMatchProfile(BuildContext context, String userId) async {
  final request = await showSuspendDialog(
    context,
    title: 'Eşleşme profilini kapat',
    description: 'Profil süre boyunca kimseye görünmez ve eşleşmeleri biter. Hesabın geri kalanı etkilenmez. Gerekçe kayda geçer.',
    confirmLabel: 'Kapat',
  );
  if (request == null || !context.mounted) return false;
  final result = await ProviderScope.containerOf(context)
      .read(adminMatchingRepositoryProvider)
      .suspend(userId, reason: request.reason, until: request.until);
  if (!context.mounted) return false;
  return _reportDone(context, result, 'Eşleşme profili kapatıldı.');
}

bool _reportDone(BuildContext context, Result<void> result, String done) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(switch (result) {
      Ok() => done,
      Err(:final failure) => failure.userMessage,
    }),
  ));
  return result is Ok;
}
