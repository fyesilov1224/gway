import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/profile.dart';
import '../domain/username.dart';
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
          appBar: AppBar(title: const Text('Profili düzenle')),
          body: GxErrorState(
            message: userMessageOf(error),
            onRetry: () {
              ref.invalidate(myProfileProvider);
              if (userId != null) ref.invalidate(interestsProvider(userId));
            },
          ),
        ),
      _ => Scaffold(
          appBar: AppBar(title: const Text('Profili düzenle')),
          body: const Padding(
            padding: EdgeInsets.all(GxSpacing.page),
            child: Column(
              children: [
                GxSkeleton(height: GxSpacing.xxl * 2),
                SizedBox(height: GxSpacing.md),
                GxSkeleton(height: GxSpacing.xxl),
                SizedBox(height: GxSpacing.md),
                GxSkeleton(height: GxSpacing.xxl),
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
        title: const Text('Profili düzenle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: GxSpacing.sm),
            child: GxButton(label: 'Kaydet', onPressed: busy ? null : _save, isLoading: _saving),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: GxSpacing.lg, horizontal: GxSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GxPanel(
                    padding: EdgeInsets.zero,
                    child: _ImagesEditor(
                      profile: profile,
                      uploading: _uploading,
                      enabled: !busy,
                      onChange: _changeImage,
                      onRemove: (kind) => _changeImage(kind, remove: true),
                    ),
                  ),
                  const SizedBox(height: GxSpacing.lg),
                  GxPanel(
                    title: 'Profil bilgileri',
                    subtitle: 'Bu bilgiler profilinde herkese görünür.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _displayName,
                          maxLength: ProfileRules.displayNameMaxLength,
                          textCapitalization: TextCapitalization.words,
                          validator: ProfileRules.validateDisplayName,
                          decoration: const InputDecoration(labelText: 'Adın', counterText: ''),
                        ),
                        const SizedBox(height: GxSpacing.md),
                        UsernameField(
                          controller: _username,
                          current: widget.profile.username,
                          enabled: lockedUntil == null,
                          helperText: lockedUntil == null
                              ? 'Kullanıcı adını 30 günde bir değiştirebilirsin.'
                              : '${formatDateTr(lockedUntil)} tarihinden sonra değiştirebilirsin.',
                          onAvailabilityChanged: (v) => setState(() => _usernameAvailable = v),
                        ),
                        const SizedBox(height: GxSpacing.md),
                        TextFormField(
                          controller: _bio,
                          maxLength: ProfileRules.bioMaxLength,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Hakkında',
                            hintText: 'Kendinden, sevdiğin aktivitelerden bahset.',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GxSpacing.lg),
                  GxPanel(
                    title: 'İlgi alanları',
                    subtitle: 'En fazla ${ProfileRules.maxInterests} tane seçebilirsin.',
                    trailing: Text(
                      '${_interests.length} / ${ProfileRules.maxInterests}',
                      style: textTheme.labelLarge?.copyWith(color: GxColors.textSecondary),
                    ),
                    child: InterestPicker(selected: _interests, onChanged: (v) => setState(() => _interests = v)),
                  ),
                  const SizedBox(height: GxSpacing.lg),
                  if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: GxSpacing.sm,
                      runSpacing: GxSpacing.sm,
                      children: [
                        GxButton(
                          label: 'Vazgeç',
                          variant: GxButtonVariant.secondary,
                          onPressed: busy ? null : () => context.pop(),
                        ),
                        GxButton(label: 'Değişiklikleri kaydet', onPressed: busy ? null : _save, isLoading: _saving),
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
    final avatar = GxAvatarSize.xl.dimension;
    final cover = profile.coverUrl;
    final hasAvatar = profile.avatarUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(GxRadius.lg)),
              child: AspectRatio(
                aspectRatio: 3,
                child: cover == null
                    ? const ColoredBox(color: GxColors.primarySoft)
                    : Image.network(cover, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: GxSpacing.sm,
              right: GxSpacing.sm,
              child: Wrap(
                spacing: GxSpacing.xs,
                children: [
                  if (cover != null)
                    _OverlayButton(
                      icon: Icons.delete_outline,
                      label: 'Kaldır',
                      tooltip: 'Kapak fotoğrafını kaldır',
                      onPressed: enabled ? () => onRemove(ProfileImage.cover) : null,
                    ),
                  _OverlayButton(
                    icon: Icons.photo_camera_outlined,
                    label: cover == null ? 'Kapak ekle' : 'Kapağı değiştir',
                    loading: uploading == ProfileImage.cover,
                    onPressed: enabled ? () => onChange(ProfileImage.cover) : null,
                  ),
                ],
              ),
            ),
            Positioned(
              left: GxSpacing.lg,
              bottom: -avatar / 2,
              child: Container(
                padding: const EdgeInsets.all(GxSpacing.xxs),
                decoration: const BoxDecoration(color: GxColors.background, shape: BoxShape.circle),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GxAvatar(
                      name: profile.displayName,
                      shape: GxAvatarShape.user,
                      imageUrl: profile.avatarUrl,
                      size: GxAvatarSize.xl,
                    ),
                    if (uploading == ProfileImage.avatar)
                      const Positioned.fill(
                        child: Center(
                          child: SizedBox.square(
                            dimension: GxSpacing.lg,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    Positioned(
                      right: -GxSpacing.xxs,
                      bottom: -GxSpacing.xxs,
                      child: IconButton.filled(
                        tooltip: 'Profil fotoğrafını değiştir',
                        icon: const Icon(Icons.photo_camera_outlined, size: GxSpacing.md + GxSpacing.xxs),
                        style: IconButton.styleFrom(
                          backgroundColor: GxColors.primary,
                          foregroundColor: GxColors.onPrimary,
                          side: const BorderSide(color: GxColors.background, width: 2),
                        ),
                        onPressed: enabled ? () => onChange(ProfileImage.avatar) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            GxSpacing.lg + avatar + GxSpacing.md,
            GxSpacing.sm,
            GxSpacing.lg,
            GxSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: avatar / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Profil ve kapak fotoğrafı', style: textTheme.labelLarge),
                Text(
                  'JPEG, PNG veya WebP · en fazla 5 MB',
                  style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
                if (hasAvatar)
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: GxColors.error),
                    onPressed: enabled ? () => onRemove(ProfileImage.avatar) : null,
                    child: const Text('Profil fotoğrafını kaldır'),
                  ),
              ],
            ),
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
              dimension: GxSpacing.md,
              child: CircularProgressIndicator(strokeWidth: 2, color: GxColors.onPrimary),
            )
          : Icon(icon, size: GxSpacing.md + GxSpacing.xxs),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: GxColors.textPrimary.withValues(alpha: 0.72),
        foregroundColor: GxColors.onPrimary,
        minimumSize: const Size(GxSpacing.minTouchTarget, GxSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
        shape: const StadiumBorder(),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
