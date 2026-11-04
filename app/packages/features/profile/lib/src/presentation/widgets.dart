import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile.dart';
import '../domain/username.dart';
import '../l10n.dart';
import 'providers.dart';

/// Picks a gallery image sized for [kind]. Null when the user cancels.
Future<ImageUpload?> pickProfileImage(ProfileImage kind) =>
    pickGalleryImage(maxWidth: kind == ProfileImage.avatar ? GwMedia.avatarMaxSide : 2048);

/// Selectable interest chips, limited to [ProfileRules.maxInterests].
class InterestPicker extends ConsumerWidget {
  const InterestPicker({super.key, required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return switch (categories) {
      AsyncData(:final value) => Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          children: [
            for (final c in value)
              FilterChip(
                avatar: Icon(categoryIcon(c.slug), size: GwSpacing.md + GwSpacing.xxs),
                label: Text(c.name),
                selected: selected.contains(c.slug),
                showCheckmark: false,
                onSelected: (on) {
                  if (on && selected.length >= ProfileRules.maxInterests) return;
                  onChanged(on ? {...selected, c.slug} : ({...selected}..remove(c.slug)));
                },
              ),
          ],
        ),
      AsyncError(:final error) => GwFormMessage(userMessageOf(error)),
      _ => const Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          children: [
            GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.xl),
            GwSkeleton(width: GwSpacing.xxl + GwSpacing.xl, height: GwSpacing.xl),
            GwSkeleton(width: GwSpacing.xxl * 2 + GwSpacing.md, height: GwSpacing.xl),
            GwSkeleton(width: GwSpacing.xxl + GwSpacing.lg, height: GwSpacing.xl),
          ],
        ),
    };
  }
}

/// Username field that checks availability on the server while typing.
///
/// [current] is the user's existing username, which counts as available.
class UsernameField extends ConsumerStatefulWidget {
  const UsernameField({
    super.key,
    required this.controller,
    this.current,
    this.enabled = true,
    this.helperText,
    required this.onAvailabilityChanged,
  });

  final TextEditingController controller;
  final String? current;
  final bool enabled;
  final String? helperText;

  /// Called with true/false once checked, null while unknown.
  final ValueChanged<bool?> onAvailabilityChanged;

  @override
  ConsumerState<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends ConsumerState<UsernameField> {
  Timer? _debounce;
  bool? _available;
  bool _checking = false;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final name = UsernameRules.normalize(value);
    _setAvailability(null);
    if (UsernameRules.validate(name) != null) return;
    if (name == widget.current) {
      _setAvailability(true);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _check(name));
  }

  Future<void> _check(String name) async {
    final id = ++_requestId;
    setState(() => _checking = true);
    final result = await ref.read(profileRepositoryProvider).isUsernameAvailable(name);
    if (!mounted || id != _requestId) return;
    setState(() => _checking = false);
    _setAvailability(switch (result) {
      Ok(:final value) => value,
      Err() => null,
    });
  }

  void _setAvailability(bool? value) {
    if (_available == value) return;
    setState(() => _available = value);
    widget.onAvailabilityChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      autocorrect: false,
      maxLength: UsernameRules.maxLength,
      onChanged: _onChanged,
      validator: (v) =>
          UsernameRules.validate(v) ??
          (_available == false ? profileL10n.usernameTaken : null),
      decoration: InputDecoration(
        labelText: profileL10n.username,
        prefixText: '@',
        helperText: widget.helperText,
        counterText: '',
        suffixIcon: _checking
            ? const Padding(
                padding: EdgeInsets.all(GwSpacing.sm),
                child: SizedBox.square(
                  dimension: GwSpacing.md,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : switch (_available) {
                true => Icon(Icons.check_circle, color: GwColors.primary, semanticLabel: profileL10n.available),
                false => Icon(Icons.cancel, color: GwColors.error, semanticLabel: profileL10n.taken),
                null => null,
              },
      ),
    );
  }
}
