import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/profile.dart';
import '../domain/social.dart';
import 'providers.dart';
import 'routes.dart';
import 'social_providers.dart';
import 'social_widgets.dart';

/// Builds a section for the given user, shown under the interests (e.g.
/// their groups). The app supplies it so features stay independent.
typedef ProfileSectionBuilder = Widget Function(BuildContext context, Profile profile, bool isOwn);

/// A user's profile. Without [username] it shows the signed-in user's own.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.username, this.onOpenSettings, this.sections = const []});

  final String? username;

  /// Shown as a settings action on the user's own profile.
  final VoidCallback? onOpenSettings;

  final List<ProfileSectionBuilder> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = username;
    final profile = name == null
        ? ref.watch(myProfileProvider).whenData((p) => p!)
        : ref.watch(profileByUsernameProvider(name));
    final isOwn = profile.value?.id == ref.watch(currentUserIdProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: name == null ? GxSpacing.md : 0,
        title: switch (profile.value) {
          final p? => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('@${p.username}', style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
              ],
            ),
          null => const Text('Profil'),
        },
        actions: [
          if (isOwn && onOpenSettings != null)
            Padding(
              padding: const EdgeInsets.only(right: GxSpacing.xs),
              child: IconButton(tooltip: 'Ayarlar', icon: const Icon(Icons.settings_outlined), onPressed: onOpenSettings),
            ),
        ],
      ),
      body: GxReadingColumn(
        child: switch (profile) {
          AsyncData(:final value) => _ProfileBody(profile: value, isOwn: isOwn, sections: sections),
          AsyncError(error: NotFoundFailure()) => GxEmptyState(
              icon: Icons.person_off_outlined,
              message: 'Bu profil bulunamadı ya da artık görünür değil.',
              actionLabel: 'Profilime dön',
              onAction: () => context.go(ProfileRoutes.mine),
            ),
          AsyncError(:final error) => GxErrorState(
              message: userMessageOf(error),
              onRetry: () => name == null
                  ? ref.invalidate(myProfileProvider)
                  : ref.invalidate(profileByUsernameProvider(name)),
            ),
          _ => const _ProfileSkeleton(),
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.isOwn, required this.sections});

  final Profile profile;
  final bool isOwn;
  final List<ProfileSectionBuilder> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final interests = ref.watch(interestsProvider(profile.id)).value ?? const [];
    final names = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};
    final avatar = gxHeaderAvatarSize(context);
    final social = ref.watch(profileSocialProvider(profile.id)).value;
    final requests = isOwn && profile.isPrivate ? ref.watch(followRequestsProvider).value?.length ?? 0 : 0;
    final hidden = social != null && (social.blockedByMe || !social.canView);

    return RefreshIndicator(
      onRefresh: () async => refreshRelationship(ref, profile.id),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GxCoverHeader(
            name: profile.displayName,
            shape: GxAvatarShape.user,
            coverUrl: profile.coverUrl,
            avatarUrl: profile.avatarUrl,
          ),
          // Actions share the row with the lower half of the avatar.
          Padding(
            padding: EdgeInsets.fromLTRB(GxSpacing.md + avatar + GxSpacing.sm, GxSpacing.sm, GxSpacing.md, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: avatar / 2 - GxSpacing.sm),
              child: Align(
                alignment: Alignment.topRight,
                child: isOwn ? const _OwnActions() : (social == null ? null : _VisitorActions(profile: profile, social: social)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.md, GxSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.displayName, style: textTheme.headlineMedium),
                Row(
                  children: [
                    Flexible(
                      child: Text('@${profile.username}', style: textTheme.bodyLarge?.copyWith(color: GxColors.textSecondary)),
                    ),
                    if (social?.isPrivate ?? profile.isPrivate) ...[
                      const SizedBox(width: GxSpacing.xxs),
                      const Icon(Icons.lock_outline, size: GxSpacing.md, color: GxColors.textSecondary),
                    ],
                  ],
                ),
                if (social != null && !isOwn && (social.isFriend || social.followsMe)) ...[
                  const SizedBox(height: GxSpacing.xs),
                  GxBadge(social.isFriend ? 'Arkadaşsınız' : 'Seni takip ediyor', tone: GxBadgeTone.primary),
                ],
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: GxSpacing.sm),
                  Text(profile.bio, style: textTheme.bodyLarge),
                ],
                const SizedBox(height: GxSpacing.sm),
                _Meta(icon: Icons.calendar_month_outlined, text: 'Katılım: ${formatMonthYearTr(profile.createdAt)}'),
                const SizedBox(height: GxSpacing.md),
                _Stats(profile: profile, social: social),
                if (requests > 0) ...[
                  const SizedBox(height: GxSpacing.md),
                  _Notice(
                    icon: Icons.person_add_alt,
                    text: requests == 1 ? '1 takip isteği onay bekliyor.' : '$requests takip isteği onay bekliyor.',
                    actionLabel: 'İncele',
                    onAction: () => context.push(ProfileRoutes.followRequests),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          if (social != null && social.blockedByMe)
            _Locked(
              icon: Icons.block,
              title: 'Bu hesabı engelledin',
              text: 'Engeli kaldırırsan birbirinizin paylaşımlarını yeniden görebilirsiniz.',
              actionLabel: 'Engeli kaldır',
              onAction: () async {
                final result = await ref.read(socialRepositoryProvider).unblock(profile.id);
                if (result case Err(:final failure) when context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
                }
                refreshRelationship(ref, profile.id);
              },
            )
          else if (hidden)
            const _Locked(
              icon: Icons.lock_outline,
              title: 'Bu hesap gizli',
              text: 'Fotoğraflarını, videolarını ve hikayelerini görmek için bu hesabı takip et.',
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(GxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('İlgi alanları', style: textTheme.titleMedium),
                  const SizedBox(height: GxSpacing.sm),
                  if (interests.isEmpty)
                    Text(
                      isOwn
                          ? 'Henüz ilgi alanı eklemedin. Profilini düzenleyerek ekleyebilirsin.'
                          : 'Henüz ilgi alanı eklenmemiş.',
                      style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                    )
                  else
                    Wrap(
                      spacing: GxSpacing.xs,
                      runSpacing: GxSpacing.xs,
                      children: [
                        for (final slug in interests) _InterestTag(icon: categoryIcon(slug), label: names[slug] ?? slug),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(),
            for (final section in sections) ...[section(context, profile, isOwn), const Divider()],
          ],
        ],
      ),
    );
  }
}

/// "Profili düzenle" on your own profile.
class _OwnActions extends StatelessWidget {
  const _OwnActions();

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => context.push(ProfileRoutes.edit),
        icon: const Icon(Icons.edit_outlined, size: GxSpacing.md + GxSpacing.xxs),
        label: const Text('Profili düzenle'),
        style: OutlinedButton.styleFrom(
          foregroundColor: GxColors.textPrimary,
          shape: const StadiumBorder(),
          side: const BorderSide(color: GxColors.border),
        ),
      );
}

/// Follow button and the menu with block, remove follower and copy link.
class _VisitorActions extends ConsumerWidget {
  const _VisitorActions({required this.profile, required this.social});

  final Profile profile;
  final ProfileSocial social;

  Future<void> _run(BuildContext context, WidgetRef ref, Future<Result<void>> Function(SocialRepository r) action, String done) async {
    final result = await action(ref.read(socialRepositoryProvider));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(switch (result) {
      Ok() => done,
      Err(:final failure) => failure.userMessage,
    })));
    refreshRelationship(ref, profile.id);
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: Text('@${profile.username} engellensin mi?'),
        content: const Text('Profilini, gönderilerini ve hikayelerini göremez, seni bulamaz ve sana yazamaz. '
            'Takipleşmeniz sona erer. Engellediğin bildirilmez.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GxButton(label: 'Engelle', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await _run(context, ref, (r) => r.block(profile.id), '@${profile.username} engellendi.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: GxSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!social.blockedByMe)
          FollowButton(
            userId: profile.id,
            username: profile.username,
            state: social.follow,
            followsMe: social.followsMe,
            isPrivate: social.isPrivate,
          ),
        PopupMenuButton<void>(
          tooltip: 'Diğer seçenekler',
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: () => Clipboard.setData(ClipboardData(text: '/#${ProfileRoutes.user(profile.username)}')).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil bağlantısı kopyalandı.')));
                }
              }),
              child: const Text('Profil bağlantısını kopyala'),
            ),
            if (social.followsMe && !social.blockedByMe)
              PopupMenuItem(
                onTap: () => _run(context, ref, (r) => r.removeFollower(profile.id), 'Takipçilerinden çıkarıldı.'),
                child: const Text('Takipçilerimden çıkar'),
              ),
            PopupMenuItem(
              onTap: () => ref.read(reportLauncherProvider)(context, ReportTarget.user(profile.id)),
              child: const Text('Şikayet et'),
            ),
            if (social.blockedByMe)
              PopupMenuItem(
                onTap: () => _run(context, ref, (r) => r.unblock(profile.id), 'Engel kaldırıldı.'),
                child: const Text('Engeli kaldır'),
              )
            else
              PopupMenuItem(
                onTap: () => _block(context, ref),
                child: const Text('Engelle', style: TextStyle(color: GxColors.error)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Gönderi / Takipçi / Takip; the lists open when the content is visible.
class _Stats extends StatelessWidget {
  const _Stats({required this.profile, required this.social});

  final Profile profile;
  final ProfileSocial? social;

  @override
  Widget build(BuildContext context) {
    final s = social;
    final textTheme = Theme.of(context).textTheme;
    Widget stat(String label, int? value, VoidCallback? onTap) => InkWell(
          borderRadius: GxRadius.mdAll,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.xs, vertical: GxSpacing.xxs),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: value == null ? '–' : formatCount(value), style: textTheme.titleMedium),
                  TextSpan(text: ' $label', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                ]),
              ),
            ),
          ),
        );
    final open = s != null && s.canView && !s.blockedByMe;
    return Wrap(
      spacing: GxSpacing.sm,
      children: [
        stat('gönderi', s?.postCount, null),
        stat('takipçi', s?.followerCount,
            open ? () => context.push(ProfileRoutes.followers(profile.username)) : null),
        stat('takip', s?.followingCount,
            open ? () => context.push(ProfileRoutes.following(profile.username)) : null),
      ],
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.icon, required this.title, required this.text, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(GxSpacing.md),
            decoration: const BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: GxColors.textPrimary, width: 1.5))),
            child: Icon(icon, size: GxSpacing.xl),
          ),
          const SizedBox(height: GxSpacing.md),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: GxSpacing.xs),
          Text(text, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
          if (actionLabel != null) ...[
            const SizedBox(height: GxSpacing.md),
            GxButton(label: actionLabel!, variant: GxButtonVariant.secondary, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.actionLabel, required this.onAction});

  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
        decoration: const BoxDecoration(color: GxColors.primarySoft, borderRadius: GxRadius.mdAll),
        child: Row(
          children: [
            Icon(icon, color: GxColors.primary, size: GxSpacing.md + GxSpacing.xxs),
            const SizedBox(width: GxSpacing.xs),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
        const SizedBox(width: GxSpacing.xxs + 2),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _InterestTag extends StatelessWidget {
  const _InterestTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
      decoration: BoxDecoration(color: GxColors.primarySoft, borderRadius: BorderRadius.circular(GxRadius.xl)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.primary),
          const SizedBox(width: GxSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final avatar = gxHeaderAvatarSize(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const GxCoverHeaderSkeleton(shape: GxAvatarShape.user),
        SizedBox(height: avatar / 2 + GxSpacing.md),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: GxSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GxSkeleton(width: GxSpacing.xxl * 4, height: GxSpacing.lg),
              SizedBox(height: GxSpacing.xs),
              GxSkeleton(width: GxSpacing.xxl * 2, height: GxSpacing.md),
              SizedBox(height: GxSpacing.md),
              GxSkeleton(height: GxSpacing.md),
            ],
          ),
        ),
      ],
    );
  }
}
