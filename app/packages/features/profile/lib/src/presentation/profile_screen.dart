import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/profile.dart';
import '../domain/social.dart';
import '../domain/teammates.dart';
import 'providers.dart';
import 'routes.dart';
import 'social_providers.dart';
import 'social_widgets.dart';
import 'teammate_providers.dart';
import 'teammate_screens.dart';

/// Builds a section for the given user, shown under the interests (e.g.
/// their groups). The app supplies it so features stay independent.
typedef ProfileSectionBuilder = Widget Function(BuildContext context, Profile profile, bool isOwn);

/// A user's profile. Without [username] it shows the signed-in user's own.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    this.username,
    this.onOpenSettings,
    this.sections = const [],
    this.visitorActions = const [],
    this.ownActions = const [],
  });

  final String? username;

  /// Shown as a settings action on the user's own profile.
  final VoidCallback? onOpenSettings;

  final List<ProfileSectionBuilder> sections;

  /// Other features' buttons next to "Takip et" on someone else's profile (e.g. "Mesaj").
  final List<ProfileSectionBuilder> visitorActions;

  /// Other features' shortcuts in the app bar of your own profile (e.g. "Kaydedilenler").
  final List<Widget> ownActions;

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
        // Opened from a link there is no back button, so the title keeps its padding.
        titleSpacing: name != null && Navigator.canPop(context) ? 0 : GwSpacing.md,
        title: switch (profile.value) {
          final p? => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('@${p.username}', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          null => const Text('Profil'),
        },
        actions: [
          if (isOwn) ...ownActions,
          if (isOwn && onOpenSettings != null)
            Padding(
              padding: const EdgeInsets.only(right: GwSpacing.xs),
              child: IconButton(tooltip: 'Ayarlar', icon: const Icon(Icons.settings_outlined), onPressed: onOpenSettings),
            ),
        ],
      ),
      body: GwReadingColumn(
        child: switch (profile) {
          AsyncData(:final value) => _ProfileBody(profile: value, isOwn: isOwn, sections: sections, visitorActions: visitorActions),
          AsyncError(error: NotFoundFailure()) => GwEmptyState(
              icon: Icons.person_off_outlined,
              message: 'Bu profil bulunamadı ya da artık görünür değil.',
              actionLabel: 'Profilime dön',
              onAction: () => context.go(ProfileRoutes.mine),
            ),
          AsyncError(:final error) => GwErrorState(
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
  const _ProfileBody({required this.profile, required this.isOwn, required this.sections, required this.visitorActions});

  final Profile profile;
  final bool isOwn;
  final List<ProfileSectionBuilder> sections;
  final List<ProfileSectionBuilder> visitorActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final interests = ref.watch(interestsProvider(profile.id)).value ?? const [];
    final names = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};
    final social = ref.watch(profileSocialProvider(profile.id)).value;
    final requests = isOwn && profile.isPrivate ? ref.watch(followRequestsProvider).value?.length ?? 0 : 0;
    final hidden = social != null && (social.blockedByMe || !social.canView);
    final suspendedUntil = isOwn ? null : ref.watch(profileSuspensionProvider(profile.id)).value;
    final teammate = ref.watch(teammateStatusProvider(profile.id)).value;
    final teammateRequests = isOwn ? ref.watch(myTeammatesProvider).value?.incoming.length ?? 0 : 0;

    return RefreshIndicator(
      onRefresh: () async => refreshRelationship(ref, profile.id),
      child: ListView(
        padding: const EdgeInsets.only(bottom: GwSpacing.xl),
        children: [
          GwHeroCard(
            name: profile.displayName,
            subtitle: '@${profile.username}',
            shape: GwAvatarShape.user,
            coverUrl: profile.coverUrl,
            avatarUrl: profile.avatarUrl,
            coverIcon: interests.isEmpty ? Icons.diversity_3_outlined : categoryIcon(interests.first),
            subtitleTrailing: (social?.isPrivate ?? profile.isPrivate)
                ? const Icon(Icons.lock_outline, size: GwSpacing.md, color: GwColors.textSecondary)
                : null,
            children: [
              if (suspendedUntil != null)
                GwFormMessage('Bu hesap ${formatDateTime(suspendedUntil.toLocal())} tarihine kadar askıya alındı.'),
              if ((social != null && !isOwn && (social.isFriend || social.followsMe)) ||
                  (teammate != null && (teammate.looking || teammate.relation == TeammateRelation.teammates)))
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xxs,
                  children: [
                    if (social != null && !isOwn && (social.isFriend || social.followsMe))
                      GwBadge(social.isFriend ? 'Arkadaşsınız' : 'Seni takip ediyor', tone: GwBadgeTone.primary),
                    if (teammate?.relation == TeammateRelation.teammates)
                      const GwBadge('Ekip arkadaşın', tone: GwBadgeTone.success)
                    else if (teammate?.looking ?? false)
                      GwBadge(teammate!.label, tone: GwBadgeTone.info),
                  ],
                ),
              if (profile.bio.isNotEmpty) Text(profile.bio, style: textTheme.bodyLarge),
              _Meta(icon: Icons.calendar_month_outlined, text: 'Katılım: ${formatMonthYear(profile.createdAt)}'),
              if (!hidden && interests.isNotEmpty)
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final slug in interests) GwTag(icon: categoryIcon(slug), label: names[slug] ?? slug, tone: GwTone.of(slug)),
                  ],
                ),
              _Stats(profile: profile, social: social),
              if (isOwn)
                const _OwnActions()
              else if (social != null)
                _VisitorActions(profile: profile, social: social, teammate: teammate, extra: visitorActions),
            ],
          ),
          if (requests > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
              child: _Notice(
                icon: Icons.person_add_alt,
                text: requests == 1 ? '1 takip isteği onay bekliyor.' : '$requests takip isteği onay bekliyor.',
                actionLabel: 'İncele',
                onAction: () => context.push(ProfileRoutes.followRequests),
              ),
            ),
          if (teammateRequests > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
              child: _Notice(
                icon: Icons.diversity_3_outlined,
                text: teammateRequests == 1
                    ? '1 ekip arkadaşlığı isteği seni bekliyor.'
                    : '$teammateRequests ekip arkadaşlığı isteği seni bekliyor.',
                actionLabel: 'İncele',
                onAction: () => context.push(ProfileRoutes.teammates),
              ),
            ),
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
            if (isOwn && interests.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
                child: _Notice(
                  icon: Icons.interests_outlined,
                  text: 'İlgi alanlarını ekle, sana uygun grupları ve ekip arkadaşlarını bulalım.',
                  actionLabel: 'Ekle',
                  onAction: () => context.push(ProfileRoutes.edit),
                ),
              ),
            for (final section in sections) section(context, profile, isOwn),
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
  Widget build(BuildContext context) => GwButton(
        label: 'Profili düzenle',
        icon: Icons.edit_outlined,
        variant: GwButtonVariant.secondary,
        expand: true,
        onPressed: () => context.push(ProfileRoutes.edit),
      );
}

/// Follow button and the menu with block, remove follower and copy link.
class _VisitorActions extends ConsumerWidget {
  const _VisitorActions({required this.profile, required this.social, required this.teammate, required this.extra});

  final Profile profile;
  final ProfileSocial social;
  final TeammateStatus? teammate;
  final List<ProfileSectionBuilder> extra;

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
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text('@${profile.username} engellensin mi?'),
        content: const Text('Profilini, gönderilerini ve hikayelerini göremez, seni bulamaz ve sana yazamaz. '
            'Takipleşmeniz sona erer. Engellediğin bildirilmez.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: 'Engelle', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _run(context, ref, (r) => r.block(profile.id), '@${profile.username} engellendi.');
      refreshTeammates(ref);
    }
  }

  /// Ekip arkadaşı actions; offered only to someone looking (or already related).
  List<PopupMenuEntry<void>> _teammateItems(BuildContext context, WidgetRef ref) {
    final t = teammate;
    if (t == null || social.blockedByMe) return const [];
    final person = PersonSummary(id: profile.id, username: profile.username, displayName: profile.displayName);
    return switch (t.relation) {
      TeammateRelation.none when t.looking => [
          PopupMenuItem(onTap: () => sendTeammateRequest(context, ref, person), child: const Text('Ekip arkadaşı ol')),
        ],
      TeammateRelation.incoming => [
          PopupMenuItem(
            onTap: () => runTeammateAction(
                context, ref, (r) => r.accept(profile.id), '${profile.displayName} ile artık ekip arkadaşısınız.'),
            child: const Text('Ekip arkadaşlığı isteğini kabul et'),
          ),
        ],
      TeammateRelation.requested => [
          PopupMenuItem(
            onTap: () => runTeammateAction(context, ref, (r) => r.remove(profile.id), 'İstek geri çekildi.'),
            child: const Text('Ekip arkadaşlığı isteğini geri çek'),
          ),
        ],
      TeammateRelation.teammates => [
          PopupMenuItem(
            onTap: () => runTeammateAction(context, ref, (r) => r.remove(profile.id), 'Ekip arkadaşlığı bitti.'),
            child: const Text('Ekip arkadaşlığını bitir'),
          ),
        ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: GwSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!social.blockedByMe) ...[for (final action in extra) action(context, profile, false)],
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
            ..._teammateItems(context, ref),
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
                child: const Text('Engelle', style: TextStyle(color: GwColors.error)),
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
    Widget stat(String label, int? value, VoidCallback? onTap) => Expanded(
          child: Material(
            color: GwColors.surface,
            borderRadius: GwRadius.mdAll,
            child: InkWell(
              borderRadius: GwRadius.mdAll,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.xs, vertical: GwSpacing.sm),
                child: Column(
                  children: [
                    Text(value == null ? '–' : formatCount(value), style: textTheme.titleLarge),
                    Text(label,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        );
    final open = s != null && s.canView && !s.blockedByMe;
    return Row(
      children: [
        stat('Gönderi', s?.postCount, null),
        const SizedBox(width: GwSpacing.xs),
        stat('Takipçi', s?.followerCount, open ? () => context.push(ProfileRoutes.followers(profile.username)) : null),
        const SizedBox(width: GwSpacing.xs),
        stat('Takip', s?.followingCount, open ? () => context.push(ProfileRoutes.following(profile.username)) : null),
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
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(GwSpacing.md),
            decoration: const BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: GwColors.textPrimary, width: 1.5))),
            child: Icon(icon, size: GwSpacing.xl),
          ),
          const SizedBox(height: GwSpacing.md),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xs),
          Text(text, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          if (actionLabel != null) ...[
            const SizedBox(height: GwSpacing.md),
            GwButton(label: actionLabel!, variant: GwButtonVariant.secondary, onPressed: onAction),
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
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
        decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
        child: Row(
          children: [
            Icon(icon, color: GwColors.primary, size: GwSpacing.md + GwSpacing.xxs),
            const SizedBox(width: GwSpacing.xs),
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
        Icon(icon, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
        const SizedBox(width: GwSpacing.xxs + 2),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [GwHeroCardSkeleton(shape: GwAvatarShape.user)],
    );
  }
}
