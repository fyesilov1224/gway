import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
import '../l10n.dart';
import 'match_sheets.dart';
import 'providers.dart';
import 'routes.dart';

/// Opens the matching profile with explicit consent, or edits it with photos, pause and delete
/// (docs/ARCHITECTURE.md §3g, Eşleşme profili).
class MatchProfileScreen extends ConsumerWidget {
  const MatchProfileScreen({super.key, this.pickImage});

  /// Tests replace the gallery.
  final PickImage? pickImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myMatchProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(profile.value == null ? matchingL10n.createProfileTitle : matchingL10n.myProfile)),
      body: GwReadingColumn(
        maxWidth: GwLayout.formMaxWidth,
        child: switch (profile) {
          AsyncData(:final value) => _Form(key: ValueKey(value == null), profile: value, pickImage: pickImage),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myMatchProfileProvider)),
          _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
        },
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({super.key, required this.profile, required this.pickImage});

  final MatchProfile? profile;
  final PickImage? pickImage;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final _about = TextEditingController(text: widget.profile?.draft.about ?? '');
  late final _job = TextEditingController(text: widget.profile?.draft.job ?? '');
  late final _education = TextEditingController(text: widget.profile?.draft.education ?? '');
  late DateTime? _birthDate = widget.profile?.draft.birthDate;
  late MatchGender? _gender = widget.profile?.draft.gender;
  late int? _province = widget.profile?.draft.province;
  late bool _friend = widget.profile?.draft.friend ?? true;
  late bool _dating = widget.profile?.draft.dating ?? false;
  late Set<MatchGender> _interestedIn = {...?widget.profile?.draft.interestedIn};
  late RangeValues _ages = RangeValues(
    (widget.profile?.draft.ageMin ?? matchMinAge).toDouble(),
    (widget.profile?.draft.ageMax ?? matchMaxAge).toDouble(),
  );
  bool _adult = false;
  bool _consent = false;
  bool _busy = false;
  String? _error;

  bool get _creating => widget.profile == null;

  @override
  void dispose() {
    _about.dispose();
    _job.dispose();
    _education.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year - matchMinAge, today.month, today.day),
      helpText: matchingL10n.birthDateLabel,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final birthDate = _birthDate;
    final gender = _gender;
    final province = _province;
    if (birthDate == null || gender == null || province == null) {
      setState(() => _error = matchingL10n.pickBasics);
      return;
    }
    if (_creating && (!_adult || !_consent)) {
      setState(() => _error = matchingL10n.confirmAgeConsent);
      return;
    }
    final draft = MatchProfileDraft(
      birthDate: birthDate,
      gender: gender,
      province: province,
      about: _about.text,
      job: _job.text,
      education: _education.text,
      friend: _friend,
      dating: _dating,
      interestedIn: _interestedIn,
      ageMin: _ages.start.round(),
      ageMax: _ages.end.round(),
    );
    if (draft.problem(DateTime.now()) case final problem?) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(matchingRepositoryProvider).saveProfile(draft, create: _creating);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_creating ? matchingL10n.profileReady(matchMinPhotos) : matchingL10n.saved),
        ));
        ref.invalidate(myMatchProfileProvider);
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile = widget.profile;
    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.md),
          child: GwCard(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Text(title, style: textTheme.titleMedium), const SizedBox(height: GwSpacing.sm), ...children],
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(GwSpacing.page),
      children: [
        if (profile != null) _Photos(profile: profile, pickImage: widget.pickImage),
        section(matchingL10n.about, [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined),
            title: Text(_birthDate == null ? matchingL10n.pickBirthDate : formatDate(_birthDate!)),
            subtitle: _birthDate == null ? null : Text(matchingL10n.ageNote(ageOn(_birthDate!, DateTime.now()))),
            onTap: _pickBirthDate,
          ),
          DropdownButtonFormField<MatchGender>(
            initialValue: _gender,
            decoration: InputDecoration(labelText: matchingL10n.gender),
            items: [for (final g in MatchGender.values) DropdownMenuItem(value: g, child: Text(g.label))],
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: GwSpacing.sm),
          DropdownButtonFormField<int>(
            initialValue: _province,
            decoration: InputDecoration(labelText: matchingL10n.province),
            items: [for (var i = 0; i < turkishProvinces.length; i++) DropdownMenuItem(value: i + 1, child: Text(turkishProvinces[i]))],
            onChanged: (p) => setState(() => _province = p),
          ),
          const SizedBox(height: GwSpacing.sm),
          TextField(
            controller: _about,
            maxLength: 300,
            maxLines: 4,
            decoration: InputDecoration(labelText: matchingL10n.aboutHint, alignLabelWithHint: true),
          ),
          TextField(controller: _job, maxLength: 60, decoration: InputDecoration(labelText: matchingL10n.jobOptional)),
          TextField(controller: _education, maxLength: 60, decoration: InputDecoration(labelText: matchingL10n.educationOptional)),
          Text(matchingL10n.interestsFromProfile, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
        ]),
        section(matchingL10n.lookingFor, [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _friend,
            onChanged: (v) => setState(() => _friend = v),
            title: Text(matchingL10n.modeFriend),
            subtitle: Text(matchingL10n.friendHint),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _dating,
            onChanged: (v) => setState(() => _dating = v),
            title: Text(matchingL10n.modeDating),
            subtitle: Text(matchingL10n.datingHint),
          ),
          if (_dating) ...[
            const SizedBox(height: GwSpacing.xs),
            Text(matchingL10n.whoLookingFor, style: textTheme.labelLarge),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              children: [
                for (final g in MatchGender.values)
                  FilterChip(
                    label: Text(g.label),
                    selected: _interestedIn.contains(g),
                    onSelected: (on) => setState(() => _interestedIn = on ? {..._interestedIn, g} : ({..._interestedIn}..remove(g))),
                  ),
              ],
            ),
            const SizedBox(height: GwSpacing.sm),
            Text(matchingL10n.ageRange(_ages.start.round(), _ages.end.round()), style: textTheme.labelLarge),
            RangeSlider(
              values: _ages,
              min: matchMinAge.toDouble(),
              max: matchMaxAge.toDouble(),
              divisions: matchMaxAge - matchMinAge,
              labels: RangeLabels('${_ages.start.round()}', '${_ages.end.round()}'),
              onChanged: (v) => setState(() => _ages = v),
            ),
          ],
        ]),
        if (_creating)
          section(matchingL10n.consentTitle, [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _adult,
              onChanged: (v) => setState(() => _adult = v ?? false),
              title: Text(matchingL10n.iam18),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: Text(matchingL10n.consentText),
            ),
          ]),
        if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.sm)],
        GwButton(label: _creating ? matchingL10n.createProfile : matchingL10n.save, expand: true, isLoading: _busy, onPressed: _save),
        if (profile != null) ...[
          const SizedBox(height: GwSpacing.lg),
          _Controls(profile: profile),
        ],
      ],
    );
  }
}

class _Photos extends ConsumerStatefulWidget {
  const _Photos({required this.profile, required this.pickImage});

  final MatchProfile profile;
  final PickImage? pickImage;

  @override
  ConsumerState<_Photos> createState() => _PhotosState();
}

class _PhotosState extends ConsumerState<_Photos> {
  bool _busy = false;

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref.invalidate(myMatchProfileProvider);
  }

  Future<void> _add() async {
    final pick = widget.pickImage ?? () => pickGalleryImage(maxWidth: GwMedia.uploadMaxSide.toDouble());
    final image = await pick();
    if (image == null || !mounted) return;
    final taken = {for (final p in widget.profile.photos) p.position};
    final position = [for (var i = 0; i < matchMaxPhotos; i++) i].firstWhere((i) => !taken.contains(i));
    await _run(() => ref.read(matchingRepositoryProvider).addPhoto(image, position));
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.profile.photos;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: GwSpacing.md),
      child: GwCard(
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(matchingL10n.photos, style: textTheme.titleMedium),
            Text(
              photos.length < matchMinPhotos
                  ? matchingL10n.photosMin(matchMinPhotos)
                  : matchingL10n.photosMax(matchMaxPhotos),
              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
            ),
            const SizedBox(height: GwSpacing.sm),
            GridView.count(
              crossAxisCount: GwMedia.gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: GwMedia.gridGap,
              crossAxisSpacing: GwMedia.gridGap,
              childAspectRatio: GwMedia.gridTile,
              children: [
                for (final (i, p) in photos.indexed)
                  _PhotoTile(
                    photo: p,
                    cover: i == 0,
                    onRemove: _busy ? null : () => _run(() => ref.read(matchingRepositoryProvider).removePhoto(p)),
                    onMakeCover:
                        _busy || i == 0 ? null : () => _run(() => ref.read(matchingRepositoryProvider).makeCover(p, photos.first)),
                  ),
                if (photos.length < matchMaxPhotos)
                  Material(
                    color: GwColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(GwMedia.gridRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(GwMedia.gridRadius),
                      onTap: _busy ? null : _add,
                      child: Center(
                        child: _busy
                            ? const CircularProgressIndicator()
                            : Icon(Icons.add_a_photo_outlined, color: GwColors.primary, semanticLabel: matchingL10n.addPhoto),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.cover, required this.onRemove, required this.onMakeCover});

  final MatchPhoto photo;
  final bool cover;
  final VoidCallback? onRemove;
  final VoidCallback? onMakeCover;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(GwMedia.gridRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              onTap: onMakeCover,
              child: (photo.url ?? '').isEmpty
                  ? const ColoredBox(color: GwColors.surfaceMuted)
                  : Image.network(photo.url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GwColors.surfaceMuted)),
            ),
            if (cover) PositionedDirectional(start: GwSpacing.xs, bottom: GwSpacing.xs, child: GwBadge(matchingL10n.cover, tone: GwBadgeTone.primary)),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton(
                tooltip: matchingL10n.removePhoto,
                color: GwColors.onMedia,
                style: IconButton.styleFrom(backgroundColor: GwColors.mediaScrim),
                icon: const Icon(Icons.close_rounded),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      );
}

/// Pause and delete everything.
class _Controls extends ConsumerWidget {
  const _Controls({required this.profile});

  final MatchProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(matchingRepositoryProvider);
    void show(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.paused,
            title: Text(matchingL10n.pauseProfile),
            subtitle: Text(matchingL10n.pauseHint),
            onChanged: (v) async {
              final result = await repo.setPaused(v);
              if (result case Err(:final failure) when context.mounted) show(failure.userMessage);
              ref.invalidate(myMatchProfileProvider);
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever_outlined, color: GwColors.error),
            title: Text(matchingL10n.deleteData, style: const TextStyle(color: GwColors.error)),
            subtitle: Text(matchingL10n.deleteDataHint),
            onTap: () async {
              final sure = await confirmMatchAction(
                context,
                title: matchingL10n.deleteDataTitle,
                message: matchingL10n.deleteDataBody,
                confirmLabel: matchingL10n.delete,
              );
              if (!sure || !context.mounted) return;
              final result = await repo.deleteAll();
              if (!context.mounted) return;
              switch (result) {
                case Ok():
                  show(matchingL10n.dataDeleted);
                  ref.invalidate(myMatchProfileProvider);
                  context.go(MatchingRoutes.home);
                case Err(:final failure):
                  show(failure.userMessage);
              }
            },
          ),
        ],
      ),
    );
  }
}
