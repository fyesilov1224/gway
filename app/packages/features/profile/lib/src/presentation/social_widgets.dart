import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/social.dart';
import 'routes.dart';
import 'social_providers.dart';

/// Takip et / Geri takip et / İstek gönderildi / Takiptesin, with the change applied right away.
class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({
    super.key,
    required this.userId,
    required this.username,
    required this.state,
    this.followsMe = false,
    this.isPrivate = false,
    this.compact = false,
  });

  final String userId;
  final String username;
  final FollowState state;
  final bool followsMe;
  final bool isPrivate;

  /// Smaller button for list rows.
  final bool compact;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  late FollowState _state = widget.state;
  bool _busy = false;

  @override
  void didUpdateWidget(FollowButton old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _state = widget.state;
  }

  Future<void> _toggle() async {
    if (_state != FollowState.none) {
      final confirmed = await _confirmUnfollow();
      if (!confirmed || !mounted) return;
    }
    final previous = _state;
    final repo = ref.read(socialRepositoryProvider);
    setState(() {
      _busy = true;
      _state = previous == FollowState.none
          ? (widget.isPrivate ? FollowState.requested : FollowState.following)
          : FollowState.none;
    });
    final Result<Object?> result = previous == FollowState.none ? await repo.follow(widget.userId) : await repo.unfollow(widget.userId);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Ok(:final value) when value is FollowState:
          _state = value;
        case Err():
          _state = previous;
        case Ok():
          break;
      }
    });
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    refreshRelationship(ref, widget.userId);
  }

  Future<bool> _confirmUnfollow() async {
    final requested = _state == FollowState.requested;
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
              child: Text(
                requested
                    ? '@${widget.username} için gönderdiğin takip isteğini geri almak istiyor musun?'
                    : '@${widget.username} takibini bırakmak istiyor musun?'
                        '${widget.isPrivate ? ' Hesap gizli olduğu için gönderilerini görmek için yeniden istek göndermen gerekir.' : ''}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
              title: Text(requested ? 'İsteği geri al' : 'Takibi bırak', textAlign: TextAlign.center,
                  style: const TextStyle(color: GxColors.error)),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(title: const Text('Vazgeç', textAlign: TextAlign.center), onTap: () => Navigator.of(context).pop(false)),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final (label, variant) = switch (_state) {
      FollowState.none => (widget.followsMe ? 'Geri takip et' : 'Takip et', GxButtonVariant.primary),
      FollowState.requested => ('İstek gönderildi', GxButtonVariant.secondary),
      FollowState.following => ('Takiptesin', GxButtonVariant.secondary),
    };
    final button = GxButton(label: label, variant: variant, isLoading: _busy, onPressed: _toggle);
    return widget.compact
        ? ConstrainedBox(constraints: const BoxConstraints(minWidth: GxSpacing.xxl * 2 + GxSpacing.lg), child: button)
        : button;
  }
}

/// Avatar, name and @username, with an optional trailing action.
class PersonRow extends StatelessWidget {
  const PersonRow({super.key, required this.person, this.subtitle, this.trailing, this.onTap});

  final PersonSummary person;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap ?? () => context.push(ProfileRoutes.user(person.username)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.xs),
        child: Row(
          children: [
            GxAvatar(name: person.displayName, shape: GxAvatarShape.user, imageUrl: person.avatarUrl),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(person.username, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                      ),
                      if (person.isPrivate) ...[
                        const SizedBox(width: GxSpacing.xxs),
                        const Icon(Icons.lock_outline, size: GxSpacing.sm + GxSpacing.xxs, color: GxColors.textSecondary),
                      ],
                    ],
                  ),
                  Text(
                    subtitle ?? person.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: GxSpacing.sm), trailing!],
          ],
        ),
      ),
    );
  }
}

/// A person with the right follow button; nothing for the signed-in user themselves.
class PersonFollowRow extends ConsumerWidget {
  const PersonFollowRow({super.key, required this.person, this.subtitle});

  final PersonSummary person;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = ref.watch(currentUserIdProvider) == person.id;
    return PersonRow(
      person: person,
      subtitle: subtitle ?? (person.follow == FollowState.following && person.followsMe ? 'Arkadaşsınız' : null),
      trailing: isMe
          ? null
          : FollowButton(
              userId: person.id,
              username: person.username,
              state: person.follow,
              followsMe: person.followsMe,
              isPrivate: person.isPrivate,
              compact: true,
            ),
    );
  }
}

/// People search results for the app's search screen.
class PeopleSearchResults extends ConsumerWidget {
  const PeopleSearchResults({super.key, required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().isEmpty) return const SuggestedPeople();
    final results = ref.watch(peopleSearchProvider(query.trim()));
    return switch (results) {
      AsyncData(:final value) when value.isEmpty => GxEmptyState(
          icon: Icons.person_search_outlined,
          message: '"${query.trim()}" ile eşleşen bir hesap bulunamadı.',
          actionLabel: 'Aramayı temizle',
          onAction: onClear,
        ),
      AsyncData(:final value) => ListView(children: [for (final p in value) PersonFollowRow(person: p)]),
      AsyncError(:final error) => GxErrorState(
          message: userMessageOf(error), onRetry: () => ref.invalidate(peopleSearchProvider(query.trim()))),
      _ => const ListSkeleton(),
    };
  }
}

/// Accounts the user may know, with why.
class SuggestedPeople extends ConsumerWidget {
  const SuggestedPeople({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(suggestedPeopleProvider).value ?? const <PersonSummary>[];
    if (people.isEmpty) {
      return GxEmptyState(
        icon: Icons.person_search_outlined,
        message: 'Kişi ya da etiket aramak için yazmaya başla.',
        actionLabel: 'Önerileri yenile',
        onAction: () => ref.invalidate(suggestedPeopleProvider),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
          child: Text('Senin için öneriler', style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final p in people)
          PersonFollowRow(
            person: p,
            subtitle: p.mutualCount > 0 ? 'Takip ettiğin ${p.mutualCount} kişi takip ediyor' : 'Popüler hesap',
          ),
      ],
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(GxSpacing.md),
        child: Column(children: [
          GxSkeleton(height: GxSpacing.xxl),
          SizedBox(height: GxSpacing.sm),
          GxSkeleton(height: GxSpacing.xxl),
          SizedBox(height: GxSpacing.sm),
          GxSkeleton(height: GxSpacing.xxl),
        ]),
      );
}
