import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
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
      appBar: AppBar(title: Text(profile.value == null ? 'Eşleşme profili oluştur' : 'Eşleşme profilim')),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: switch (profile) {
          AsyncData(:final value) => _Form(key: ValueKey(value == null), profile: value, pickImage: pickImage),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myMatchProfileProvider)),
          _ => const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 4)),
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
      helpText: 'Doğum tarihin',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final birthDate = _birthDate;
    final gender = _gender;
    final province = _province;
    if (birthDate == null || gender == null || province == null) {
      setState(() => _error = 'Doğum tarihini, cinsiyetini ve ilini seç.');
      return;
    }
    if (_creating && (!_adult || !_consent)) {
      setState(() => _error = 'Devam etmek için 18 yaşından büyük olduğunu onayla ve açık rıza ver.');
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
          content: Text(_creating ? 'Profilin hazır. Şimdi en az $matchMinPhotos fotoğraf ekle.' : 'Kaydedildi.'),
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
          padding: const EdgeInsets.only(bottom: GxSpacing.md),
          child: GxCard(
            padding: const EdgeInsets.all(GxSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [Text(title, style: textTheme.titleMedium), const SizedBox(height: GxSpacing.sm), ...children],
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(GxSpacing.page),
      children: [
        if (profile != null) _Photos(profile: profile, pickImage: widget.pickImage),
        section('Hakkında', [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined),
            title: Text(_birthDate == null ? 'Doğum tarihi seç' : formatDateTr(_birthDate!)),
            subtitle: _birthDate == null ? null : Text('${ageOn(_birthDate!, DateTime.now())} yaş · kartında yalnızca yaşın görünür'),
            onTap: _pickBirthDate,
          ),
          DropdownButtonFormField<MatchGender>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: 'Cinsiyet'),
            items: [for (final g in MatchGender.values) DropdownMenuItem(value: g, child: Text(g.label))],
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: GxSpacing.sm),
          DropdownButtonFormField<int>(
            initialValue: _province,
            decoration: const InputDecoration(labelText: 'İl'),
            items: [for (var i = 0; i < turkishProvinces.length; i++) DropdownMenuItem(value: i + 1, child: Text(turkishProvinces[i]))],
            onChanged: (p) => setState(() => _province = p),
          ),
          const SizedBox(height: GxSpacing.sm),
          TextField(
            controller: _about,
            maxLength: 300,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Kendinden bahset', alignLabelWithHint: true),
          ),
          TextField(controller: _job, maxLength: 60, decoration: const InputDecoration(labelText: 'Meslek (isteğe bağlı)')),
          TextField(controller: _education, maxLength: 60, decoration: const InputDecoration(labelText: 'Eğitim (isteğe bağlı)')),
          Text('İlgi alanların sosyal profilinden gelir.', style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
        ]),
        section('Ne arıyorsun?', [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _friend,
            onChanged: (v) => setState(() => _friend = v),
            title: const Text('Arkadaş'),
            subtitle: const Text('Birlikte etkinliğe gidecek, sohbet edecek insanlar'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _dating,
            onChanged: (v) => setState(() => _dating = v),
            title: const Text('Sevgili'),
            subtitle: const Text('Romantik bir ilişki'),
          ),
          if (_dating) ...[
            const SizedBox(height: GxSpacing.xs),
            Text('Kimi arıyorsun?', style: textTheme.labelLarge),
            const SizedBox(height: GxSpacing.xs),
            Wrap(
              spacing: GxSpacing.xs,
              children: [
                for (final g in MatchGender.values)
                  FilterChip(
                    label: Text(g.label),
                    selected: _interestedIn.contains(g),
                    onSelected: (on) => setState(() => _interestedIn = on ? {..._interestedIn, g} : ({..._interestedIn}..remove(g))),
                  ),
              ],
            ),
            const SizedBox(height: GxSpacing.sm),
            Text('Yaş aralığı: ${_ages.start.round()}–${_ages.end.round()}', style: textTheme.labelLarge),
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
          section('Onay', [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _adult,
              onChanged: (v) => setState(() => _adult = v ?? false),
              title: const Text('18 yaşından büyüğüm.'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: const Text(
                'Eşleşme için cinsiyetimin, aradığım kişinin, doğum tarihimin, ilimin ve fotoğraflarımın işlenmesine ve '
                'ortak gruplarımdaki eşleşmeyi açmış kişilere gösterilmesine açık rıza veriyorum. Rızamı istediğim an '
                'eşleşme verilerimi silerek geri alabilirim.',
              ),
            ),
          ]),
        if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.sm)],
        GxButton(label: _creating ? 'Profilimi oluştur' : 'Kaydet', expand: true, isLoading: _busy, onPressed: _save),
        if (profile != null) ...[
          const SizedBox(height: GxSpacing.lg),
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
    final pick = widget.pickImage ?? () => pickGalleryImage(maxWidth: GxMedia.uploadMaxSide.toDouble());
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
      padding: const EdgeInsets.only(bottom: GxSpacing.md),
      child: GxCard(
        padding: const EdgeInsets.all(GxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Fotoğraflar', style: textTheme.titleMedium),
            Text(
              photos.length < matchMinPhotos
                  ? 'Kartının görünmesi için en az $matchMinPhotos fotoğraf ekle. İlki kapaktır.'
                  : 'En fazla $matchMaxPhotos fotoğraf. İlki kapaktır; değiştirmek için bir fotoğrafa dokun.',
              style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
            ),
            const SizedBox(height: GxSpacing.sm),
            GridView.count(
              crossAxisCount: GxMedia.gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: GxMedia.gridGap,
              crossAxisSpacing: GxMedia.gridGap,
              childAspectRatio: GxMedia.gridTile,
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
                    color: GxColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(GxMedia.gridRadius),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(GxMedia.gridRadius),
                      onTap: _busy ? null : _add,
                      child: Center(
                        child: _busy
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.add_a_photo_outlined, color: GxColors.primary, semanticLabel: 'Fotoğraf ekle'),
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
        borderRadius: BorderRadius.circular(GxMedia.gridRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              onTap: onMakeCover,
              child: (photo.url ?? '').isEmpty
                  ? const ColoredBox(color: GxColors.surfaceMuted)
                  : Image.network(photo.url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: GxColors.surfaceMuted)),
            ),
            if (cover) const Positioned(left: GxSpacing.xs, bottom: GxSpacing.xs, child: GxBadge('Kapak', tone: GxBadgeTone.primary)),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Fotoğrafı kaldır',
                color: GxColors.onMedia,
                style: IconButton.styleFrom(backgroundColor: GxColors.mediaScrim),
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
    return GxCard(
      padding: const EdgeInsets.all(GxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: profile.paused,
            title: const Text('Profilimi duraklat'),
            subtitle: const Text('Kimse seni görmez ve yeni kart gelmez; eşleşmelerin ve sohbetlerin kalır.'),
            onChanged: (v) async {
              final result = await repo.setPaused(v);
              if (result case Err(:final failure) when context.mounted) show(failure.userMessage);
              ref.invalidate(myMatchProfileProvider);
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever_outlined, color: GxColors.error),
            title: const Text('Eşleşme verilerimi sil', style: TextStyle(color: GxColors.error)),
            subtitle: const Text('Profil, fotoğraflar ve beğeniler silinir; eşleşmelerin biter. Açık rızan geri alınmış olur.'),
            onTap: () async {
              final sure = await confirmMatchAction(
                context,
                title: 'Eşleşme verilerini sil',
                message: 'Eşleşme profilin, fotoğrafların ve beğenilerin kalıcı olarak silinir; tüm eşleşmelerin biter. Bu geri alınamaz.',
                confirmLabel: 'Sil',
              );
              if (!sure || !context.mounted) return;
              final result = await repo.deleteAll();
              if (!context.mounted) return;
              switch (result) {
                case Ok():
                  show('Eşleşme verilerin silindi.');
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
