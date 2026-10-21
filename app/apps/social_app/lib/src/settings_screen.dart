import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:moderation/moderation.dart';
import 'package:profile/profile.dart';
import 'package:support/support.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget tile(IconData icon, String title, VoidCallback onTap, {Color? color, String? badge}) => ListTile(
          minTileHeight: GxSpacing.xxl + GxSpacing.xs,
          leading: Icon(icon, color: color),
          title: Text(title, style: color == null ? null : TextStyle(color: color)),
          trailing: color != null
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) GxBadge(badge, tone: GxBadgeTone.primary),
                    const Icon(Icons.chevron_right),
                  ],
                ),
          onTap: onTap,
        );
    final unread = ref.watch(unreadSupportCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
          child: ListView(
            children: [
              tile(Icons.person_outline, 'Profili düzenle', () => context.push(ProfileRoutes.edit)),
              const Divider(),
              const _PrivacyTile(),
              const Divider(),
              tile(Icons.block, 'Engellenen hesaplar', () => context.push(ProfileRoutes.blocked)),
              const Divider(),
              tile(Icons.bookmark_border_rounded, 'Kaydedilenler', () => context.push(FeedRoutes.saved)),
              const Divider(),
              tile(Icons.history_toggle_off, 'Hikaye arşivi', () => context.push(FeedRoutes.archive)),
              const Divider(),
              tile(Icons.shield_outlined, 'Grup yaptırımlarım', () => context.push(ModerationRoutes.mySanctions)),
              const Divider(),
              tile(
                Icons.support_agent_outlined,
                'Destek ve geri bildirim',
                () => context.push(SupportRoutes.list),
                badge: unread == 0 ? null : '$unread yeni yanıt',
              ),
              const Divider(),
              tile(Icons.description_outlined, 'Hukuki metinler', () => context.push(IdentityRoutes.legalDocuments)),
              const Divider(),
              tile(Icons.delete_outline, 'Hesabı sil', () => context.push(IdentityRoutes.deleteAccount)),
              const Divider(),
              tile(
                Icons.logout,
                'Çıkış yap',
                () => ref.read(authRepositoryProvider).signOut(),
                color: GxColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Private account: following needs approval, content is for followers only.
class _PrivacyTile extends ConsumerStatefulWidget {
  const _PrivacyTile();

  @override
  ConsumerState<_PrivacyTile> createState() => _PrivacyTileState();
}

class _PrivacyTileState extends ConsumerState<_PrivacyTile> {
  bool _busy = false;

  Future<void> _set(bool value) async {
    setState(() => _busy = true);
    final result = await ref.read(socialRepositoryProvider).setPrivate(value);
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(myProfileProvider);
    final me = ref.read(currentUserIdProvider);
    if (me != null) refreshRelationship(ref, me);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => value ? 'Hesabın artık gizli.' : 'Hesabın artık herkese açık; bekleyen istekler onaylandı.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = ref.watch(myProfileProvider).value?.isPrivate ?? false;
    return SwitchListTile(
      minTileHeight: GxSpacing.xxl + GxSpacing.xs,
      secondary: const Icon(Icons.lock_outline),
      title: const Text('Gizli hesap'),
      subtitle: const Text('Açıkken yalnızca onayladığın takipçiler gönderilerini ve hikayelerini görür.'),
      value: isPrivate,
      onChanged: _busy ? null : _set,
    );
  }
}
