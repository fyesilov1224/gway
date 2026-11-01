import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:matching/matching.dart';
import 'package:messaging/messaging.dart';
import 'package:moderation/moderation.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';
import 'package:support/support.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget tile(IconData icon, String title, VoidCallback onTap, {Color? color, String? badge}) => ListTile(
          minTileHeight: GwSpacing.xxl + GwSpacing.xs,
          leading: Icon(icon, color: color),
          title: Text(title, style: color == null ? null : TextStyle(color: color)),
          trailing: color != null
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null) GwBadge(badge, tone: GwBadgeTone.primary),
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
          constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
          child: ListView(
            children: [
              tile(Icons.person_outline, 'Profili düzenle', () => context.push(ProfileRoutes.edit)),
              const Divider(),
              const _PrivacyTile(),
              const _GroupsVisibilityTile(),
              const Divider(),
              tile(Icons.diversity_3_outlined, 'Ekip arkadaşı tercihleri', () => context.push(ProfileRoutes.teammateSettings)),
              const Divider(),
              tile(Icons.favorite_border_rounded, 'Eşleşme profili', () => context.push(MatchingRoutes.profile)),
              const Divider(),
              tile(Icons.call_outlined, 'Sesli görüşme', () => context.push(MessagingRoutes.callSettings)),
              const Divider(),
              tile(Icons.block, 'Engellenen hesaplar', () => context.push(ProfileRoutes.blocked)),
              const Divider(),
              tile(Icons.bookmark_border_rounded, 'Kaydedilenler', () => context.push(FeedRoutes.saved)),
              const Divider(),
              tile(Icons.history_toggle_off, 'Hikaye arşivi', () => context.push(FeedRoutes.archive)),
              const Divider(),
              tile(Icons.notifications_active_outlined, 'Bildirim tercihleri', () => context.push(NotificationRoutes.preferences)),
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
              tile(Icons.verified_user_outlined, 'İki adımlı doğrulama', () => context.push(IdentityRoutes.twoFactor)),
              const Divider(),
              tile(Icons.description_outlined, 'Hukuki metinler', () => context.push(IdentityRoutes.legalDocuments)),
              const Divider(),
              tile(Icons.delete_outline, 'Hesabı sil', () => context.push(IdentityRoutes.deleteAccount)),
              const Divider(),
              tile(
                Icons.logout,
                'Çıkış yap',
                () => ref.read(authRepositoryProvider).signOut(),
                color: GwColors.error,
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
      minTileHeight: GwSpacing.xxl + GwSpacing.xs,
      secondary: const Icon(Icons.lock_outline),
      title: const Text('Gizli hesap'),
      subtitle: const Text('Açıkken yalnızca onayladığın takipçiler gönderilerini ve hikayelerini görür.'),
      value: isPrivate,
      onChanged: _busy ? null : _set,
    );
  }
}

/// Memberships are shown to fellow members only unless the user opens them (docs/ARCHITECTURE.md §3b).
class _GroupsVisibilityTile extends ConsumerStatefulWidget {
  const _GroupsVisibilityTile();

  @override
  ConsumerState<_GroupsVisibilityTile> createState() => _GroupsVisibilityTileState();
}

class _GroupsVisibilityTileState extends ConsumerState<_GroupsVisibilityTile> {
  bool _busy = false;

  Future<void> _set(bool value) async {
    setState(() => _busy = true);
    final result = await ref.read(socialRepositoryProvider).setGroupsPublic(value);
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(myProfileProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => value ? 'Grupların artık profilinde herkese görünüyor.' : 'Grupların artık yalnızca aynı gruptaki üyelere görünüyor.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final groupsPublic = ref.watch(myProfileProvider).value?.groupsPublic ?? false;
    return SwitchListTile(
      minTileHeight: GwSpacing.xxl + GwSpacing.xs,
      secondary: const Icon(Icons.groups_outlined),
      title: const Text('Gruplarımı profilimde göster'),
      subtitle: const Text('Kapalıyken bir gruptaki üyeliğini yalnızca o grubun üyeleri görür; başka grupların yöneticileri göremez.'),
      value: groupsPublic,
      onChanged: _busy ? null : _set,
    );
  }
}
