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

import 'l10n.dart';

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
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(socialAppL10n.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
          child: ListView(
            children: [
              tile(Icons.person_outline, socialAppL10n.editProfile, () => context.push(ProfileRoutes.edit)),
              const Divider(),
              ListTile(
                minTileHeight: GwSpacing.xxl + GwSpacing.xs,
                leading: const Icon(Icons.language_rounded),
                title: Text(socialAppL10n.language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.nativeName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => showLanguagePicker(context),
              ),
              const Divider(),
              const _PrivacyTile(),
              const _GroupsVisibilityTile(),
              const Divider(),
              tile(Icons.diversity_3_outlined, socialAppL10n.teammatePrefs, () => context.push(ProfileRoutes.teammateSettings)),
              const Divider(),
              tile(Icons.favorite_border_rounded, socialAppL10n.matchProfile, () => context.push(MatchingRoutes.profile)),
              const Divider(),
              tile(Icons.call_outlined, socialAppL10n.voiceCalls, () => context.push(MessagingRoutes.callSettings)),
              const Divider(),
              tile(Icons.block, socialAppL10n.blockedAccounts, () => context.push(ProfileRoutes.blocked)),
              const Divider(),
              tile(Icons.bookmark_border_rounded, socialAppL10n.saved, () => context.push(FeedRoutes.saved)),
              const Divider(),
              tile(Icons.history_toggle_off, socialAppL10n.storyArchive, () => context.push(FeedRoutes.archive)),
              const Divider(),
              tile(Icons.notifications_active_outlined, socialAppL10n.notificationPrefs, () => context.push(NotificationRoutes.preferences)),
              const Divider(),
              tile(Icons.shield_outlined, socialAppL10n.mySanctions, () => context.push(ModerationRoutes.mySanctions)),
              const Divider(),
              tile(Icons.menu_book_outlined, socialAppL10n.userGuide, () => context.push(SupportRoutes.guide)),
              const Divider(),
              tile(
                Icons.support_agent_outlined,
                socialAppL10n.supportFeedback,
                () => context.push(SupportRoutes.list),
                badge: unread == 0 ? null : socialAppL10n.newReplies(unread),
              ),
              const Divider(),
              tile(Icons.verified_user_outlined, socialAppL10n.twoFactor, () => context.push(IdentityRoutes.twoFactor)),
              const Divider(),
              tile(Icons.description_outlined, socialAppL10n.legalDocuments, () => context.push(IdentityRoutes.legalDocuments)),
              const Divider(),
              tile(Icons.delete_outline, socialAppL10n.deleteAccount, () => context.push(IdentityRoutes.deleteAccount)),
              const Divider(),
              tile(
                Icons.logout,
                socialAppL10n.signOut,
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
        Ok() => value ? socialAppL10n.nowPrivate : socialAppL10n.nowPublic,
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
      title: Text(socialAppL10n.privateAccount),
      subtitle: Text(socialAppL10n.privateAccountHint),
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
        Ok() => value ? socialAppL10n.groupsNowPublic : socialAppL10n.groupsNowMembers,
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
      title: Text(socialAppL10n.showGroups),
      subtitle: Text(socialAppL10n.showGroupsHint),
      value: groupsPublic,
      onChanged: _busy ? null : _set,
    );
  }
}
