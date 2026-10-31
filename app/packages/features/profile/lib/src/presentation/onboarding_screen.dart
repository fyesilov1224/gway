import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile.dart';
import '../domain/username.dart';
import 'providers.dart';
import 'widgets.dart';

/// Three steps after the first sign-in: name and username, photo, interests.
/// Creating the profile finishes onboarding.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 3;

  final _identityForm = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _username = TextEditingController();

  int _step = 0;
  bool? _usernameAvailable;
  ImageUpload? _avatar;
  Set<String> _interests = {};
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _displayName.dispose();
    _username.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && !(_identityForm.currentState!.validate() && _usernameAvailable == true)) return;
    setState(() {
      _error = null;
      _step++;
    });
  }

  Future<void> _pickAvatar() async {
    final image = await pickProfileImage(ProfileImage.avatar);
    if (image == null || !mounted) return;
    setState(() {
      _avatar = image;
      _error = image.contentType == null ? 'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.' : null;
      if (_error != null) _avatar = null;
    });
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(profileRepositoryProvider).create(
          ProfileDraft(
            username: UsernameRules.normalize(_username.text),
            displayName: _displayName.text.trim(),
            avatar: _avatar,
            interests: _interests.toList(),
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        // The router opens the app once the profile exists.
        ref.invalidate(myProfileProvider);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
          // A taken username can only be fixed on the first step.
          if (failure case RuleFailure(code: 'profile.username_taken' || 'profile.username_reserved')) {
            _step = 0;
            _usernameAvailable = false;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (title, subtitle) = switch (_step) {
      0 => ('Seni tanıyalım', 'Profilinde görünecek adını ve kullanıcı adını seç.'),
      1 => ('Profil fotoğrafı', 'Grupların seni tanısın. İstersen sonra da ekleyebilirsin.'),
      _ => ('İlgi alanların', 'Sana uygun grupları önerebilmemiz için en fazla ${ProfileRules.maxInterests} tane seç.'),
    };

    return Scaffold(
      appBar: AppBar(
        leading: _step > 0 && !_saving
            ? IconButton(
                tooltip: 'Geri',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
        title: Text('Adım ${_step + 1} / $_steps'),
        actions: [
          GwButton(label: 'Çıkış yap', variant: GwButtonVariant.text, onPressed: _saving ? null : widget.onSignOut),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(GwSpacing.xxs),
          child: LinearProgressIndicator(
            value: (_step + 1) / _steps,
            minHeight: GwSpacing.xxs,
            backgroundColor: GwColors.surfaceMuted,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: textTheme.titleLarge),
                  const SizedBox(height: GwSpacing.xs),
                  Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                  const SizedBox(height: GwSpacing.lg),
                  switch (_step) {
                    0 => _identityStep(),
                    1 => _photoStep(),
                    _ => InterestPicker(selected: _interests, onChanged: (v) => setState(() => _interests = v)),
                  },
                  const SizedBox(height: GwSpacing.lg),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  if (_step < _steps - 1)
                    GwButton(
                      label: _step == 1 && _avatar == null ? 'Şimdilik atla' : 'Devam et',
                      onPressed: _next,
                      expand: true,
                    )
                  else
                    GwButton(label: 'Bitir', onPressed: _finish, isLoading: _saving, expand: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _identityStep() {
    return Form(
      key: _identityForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _displayName,
            maxLength: ProfileRules.displayNameMaxLength,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            validator: ProfileRules.validateDisplayName,
            decoration: const InputDecoration(labelText: 'Adın', counterText: ''),
          ),
          const SizedBox(height: GwSpacing.md),
          UsernameField(
            controller: _username,
            helperText: 'Küçük harf, rakam, _ ve . kullanabilirsin.',
            onAvailabilityChanged: (v) => setState(() => _usernameAvailable = v),
          ),
        ],
      ),
    );
  }

  Widget _photoStep() {
    final avatar = _avatar;
    final size = GwAvatarSize.xl.dimension;
    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Profil fotoğrafı önizlemesi',
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(color: GwColors.primarySoft, shape: CircleBorder()),
            child: avatar == null
                ? Icon(Icons.person_outline, size: size / 2, color: GwColors.primary)
                : Image.memory(avatar.bytes, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        GwButton(
          label: avatar == null ? 'Fotoğraf seç' : 'Başka fotoğraf seç',
          icon: Icons.photo_library_outlined,
          variant: GwButtonVariant.secondary,
          onPressed: _pickAvatar,
        ),
      ],
    );
  }
}
