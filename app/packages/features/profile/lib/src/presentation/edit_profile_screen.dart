import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/profile.dart';
import '../domain/username.dart';
import '../l10n.dart';
import 'providers.dart';
import 'widgets.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final userId = ref.watch(currentUserIdProvider);
    final interests = userId == null ? const AsyncValue<List<String>>.data([]) : ref.watch(interestsProvider(userId));

    return switch ((profile, interests)) {
      (AsyncData(value: final p?), AsyncData(value: final i)) => _EditForm(profile: p, interests: i.toSet()),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)) => Scaffold(
          appBar: AppBar(title: Text(profileL10n.editProfile)),
          body: GwErrorState(
            message: userMessageOf(error),
            onRetry: () {
              ref.invalidate(myProfileProvider);
              if (userId != null) ref.invalidate(interestsProvider(userId));
            },
          ),
        ),
      _ => Scaffold(
          appBar: AppBar(title: Text(profileL10n.editProfile)),
          body: const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: Column(
              children: [
                GwSkeleton(height: GwSpacing.xxl * 2),
                SizedBox(height: GwSpacing.md),
                GwSkeleton(height: GwSpacing.xxl),
                SizedBox(height: GwSpacing.md),
                GwSkeleton(height: GwSpacing.xxl),
              ],
            ),
          ),
        ),
    };
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.profile, required this.interests});

  final Profile profile;
  final Set<String> interests;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  late final _displayName = TextEditingController(text: widget.profile.displayName);
  late final _username = TextEditingController(text: widget.profile.username);
  late final _bio = TextEditingController(text: widget.profile.bio);
  late Set<String> _interests = {...widget.interests};

  bool? _usernameAvailable = true;
  ProfileImage? _uploading;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(myProfileProvider);
    ref.invalidate(interestsProvider(widget.profile.id));
  }

  Future<void> _changeImage(ProfileImage kind, {bool remove = false}) async {
    final repo = ref.read(profileRepositoryProvider);
    ImageUpload? image;
    if (!remove) {
      image = await pickProfileImage(kind);
      if (image == null || !mounted) return;
    }
    setState(() {
      _uploading = kind;
      _error = null;
    });
    final result = remove ? await repo.removeImage(kind) : await repo.setImage(kind, image!);
    if (!mounted) return;
    setState(() {
      _uploading = null;
      if (result case Err(:final failure)) _error = failure.userMessage;
    });
    ref.invalidate(myProfileProvider);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _usernameAvailable != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(profileRepositoryProvider);
    final updated = await repo.update(
      username: UsernameRules.normalize(_username.text),
      displayName: _displayName.text.trim(),
      bio: _bio.text.trim(),
    );
    final interests = updated is Ok && !_sameSet(_interests, widget.interests)
        ? await repo.setInterests(_interests.toList())
        : updated;
    if (!mounted) return;
    switch (interests) {
      case Ok():
        _refresh();
        context.pop();
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  static bool _sameSet(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(myProfileProvider).value ?? widget.profile;
    final lockedUntil = profile.usernameLockedUntil(DateTime.now());
    final busy = _saving || _uploading != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileL10n.editProfile),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: GwSpacing.sm),
            child: GwButton(label: profileL10n.save, onPressed: busy ? null : _save, isLoading: _saving),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg, horizontal: GwSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GwPanel(
                    padding: EdgeInsets.zero,
                    child: _ImagesEditor(
                      profile: profile,
                      uploading: _uploading,
                      enabled: !busy,
                      onChange: _changeImage,
                      onRemove: (kind) => _changeImage(kind, remove: true),
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: profileL10n.profileInfo,
                    subtitle: profileL10n.profileInfoHint,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _displayName,
                          maxLength: ProfileRules.displayNameMaxLength,
                          textCapitalization: TextCapitalization.words,
                          validator: ProfileRules.validateDisplayName,
                          decoration: InputDecoration(labelText: profileL10n.yourName, counterText: ''),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        UsernameField(
                          controller: _username,
                          current: widget.profile.username,
                          enabled: lockedUntil == null,
                          helperText: lockedUntil == null
                              ? profileL10n.usernameEvery30
                              : profileL10n.usernameLockedUntil(formatDate(lockedUntil)),
                          onAvailabilityChanged: (v) => setState(() => _usernameAvailable = v),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        TextFormField(
                          controller: _bio,
                          maxLength: ProfileRules.bioMaxLength,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: profileL10n.about,
                            hintText: profileL10n.aboutHint,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: profileL10n.interests,
                    subtitle: profileL10n.interestsMax(ProfileRules.maxInterests),
                    trailing: Text(
                      '${_interests.length} / ${ProfileRules.maxInterests}',
                      style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary),
                    ),
                    child: InterestPicker(selected: _interests, onChanged: (v) => setState(() => _interests = v)),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: GwSpacing.sm,
                      runSpacing: GwSpacing.sm,
                      children: [
                        GwButton(
                          label: profileL10n.cancel,
                          variant: GwButtonVariant.secondary,
                          onPressed: busy ? null : () => context.pop(),
                        ),
                        GwButton(label: profileL10n.saveChanges, onPressed: busy ? null : _save, isLoading: _saving),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//// Cover and avatar as they appear on the profile, with change / remove controls.
class _ImagesEditor extends StatelessWidget {
  const _ImagesEditor({
    required this.profile,
    required this.uploading,
    required this.enabled,
    required this.onChange,
    required this.onRemove,
  });

  final Profile profile;
  final ProfileImage? uploading;
  final bool enabled;
  final ValueChanged<ProfileImage> onChange;
  final ValueChanged<ProfileImage> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cover = profile.coverUrl;
    final hasAvatar = profile.avatarUrl != null;

    // Same proportions as the profile's identity card; nothing overlaps, so every control is tappable.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(GwRadius.lg)),
          child: AspectRatio(
            aspectRatio: gwCoverAspectRatio(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover == null) const ColoredBox(color: GwColors.primarySoft) else Image(image: gwNetworkImage(cover), fit: BoxFit.cover),
                PositionedDirectional(
                  top: GwSpacing.sm,
                  end: GwSpacing.sm,
                  child: Wrap(
                    spacing: GwSpacing.xs,
                    children: [
                      if (cover != null)
                        _OverlayButton(
                          icon: Icons.delete_outline,
                          label: profileL10n.remove,
                          tooltip: profileL10n.removeCover,
                          onPressed: enabled ? () => onRemove(ProfileImage.cover) : null,
                        ),
                      _OverlayButton(
                        icon: Icons.photo_camera_outlined,
                        label: cover == null ? profileL10n.addCover : profileL10n.changeCover,
                        loading: uploading == ProfileImage.cover,
                        onPressed: enabled ? () => onChange(ProfileImage.cover) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Row(
            children: [
              Stack(
                children: [
                  GwAvatar(name: profile.displayName, shape: GwAvatarShape.user, imageUrl: profile.avatarUrl, size: GwAvatarSize.xl),
                  if (uploading == ProfileImage.avatar)
                    const Positioned.fill(
                      child: Center(
                        child: SizedBox.square(dimension: GwSpacing.lg, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: profileL10n.changeAvatar,
                      icon: const Icon(Icons.photo_camera_outlined, size: GwSpacing.md + GwSpacing.xxs),
                      style: IconButton.styleFrom(
                        backgroundColor: GwColors.primary,
                        foregroundColor: GwColors.onPrimary,
                        side: const BorderSide(color: GwColors.background, width: 2),
                      ),
                      onPressed: enabled ? () => onChange(ProfileImage.avatar) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: GwSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profileL10n.photos, style: textTheme.labelLarge),
                    Text(profileL10n.photosHint, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: enabled ? () => onChange(ProfileImage.avatar) : null,
                      child: Text(hasAvatar ? profileL10n.changeAvatar : profileL10n.addAvatar),
                    ),
                    if (hasAvatar)
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: GwColors.error),
                        onPressed: enabled ? () => onRemove(ProfileImage.avatar) : null,
                        child: Text(profileL10n.removeAvatar),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact pill button laid over the cover image.
class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String? tooltip;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox.square(
              dimension: GwSpacing.md,
              child: CircularProgressIndicator(strokeWidth: 2, color: GwColors.onPrimary),
            )
          : Icon(icon, size: GwSpacing.md + GwSpacing.xxs),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: GwColors.textPrimary.withValues(alpha: 0.72),
        foregroundColor: GwColors.onPrimary,
        minimumSize: const Size(GwSpacing.minTouchTarget, GwSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm),
        shape: const StadiumBorder(),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
