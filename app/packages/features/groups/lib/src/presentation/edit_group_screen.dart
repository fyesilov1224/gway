import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Profile of the group for members with `group.edit`; deletion for the owner.
class EditGroupScreen extends ConsumerWidget {
  const EditGroupScreen({super.key, required this.handle});

  final String handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupByHandleProvider(handle));
    final g = group.value;
    final me = g == null ? null : ref.watch(myMembershipProvider(g.id));

    return switch ((group, me)) {
      (AsyncData(value: final g), AsyncData(value: final m)) when m.can(GroupPermission.edit) => _EditForm(group: g, me: m),
      (AsyncData(), AsyncData()) => Scaffold(
          appBar: AppBar(title: const Text('Grubu düzenle')),
          body: GwEmptyState(
            icon: Icons.lock_outline,
            message: 'Bu grubu düzenleme yetkin yok.',
            actionLabel: 'Gruba dön',
            onAction: () => context.pop(),
          ),
        ),
      (AsyncError(:final error), _) || (_, AsyncError(:final error)?) => Scaffold(
          appBar: AppBar(title: const Text('Grubu düzenle')),
          body: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(groupByHandleProvider(handle))),
        ),
      _ => Scaffold(
          appBar: AppBar(title: const Text('Grubu düzenle')),
          body: const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: Column(
              children: [
                GwSkeleton(height: GwSpacing.xxl * 2),
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
  const _EditForm({required this.group, required this.me});

  final Group group;
  final MyMembership me;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _LinkControllers {
  _LinkControllers([GroupLink? link])
      : label = TextEditingController(text: link?.label),
        url = TextEditingController(text: link?.url);

  final TextEditingController label;
  final TextEditingController url;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.group.name);
  late final _about = TextEditingController(text: widget.group.about);
  late final _rules = TextEditingController(text: widget.group.rules);
  late final List<_LinkControllers> _links = [for (final l in widget.group.links) _LinkControllers(l)];
  late String _category = widget.group.categorySlug;
  late int? _province = widget.group.province;
  late JoinPolicy _policy = widget.group.joinPolicy;
  GroupImage? _uploading;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _about.dispose();
    _rules.dispose();
    for (final l in _links) {
      l.dispose();
    }
    super.dispose();
  }

  Group get _current => ref.read(groupByHandleProvider(widget.group.handle)).value ?? widget.group;

  Future<void> _changeImage(GroupImage kind, {bool remove = false}) async {
    final repo = ref.read(groupsRepositoryProvider);
    ImageUpload? image;
    if (!remove) {
      image = await pickGalleryImage(maxWidth: kind == GroupImage.logo ? GwMedia.avatarMaxSide : 2048);
      if (image == null || !mounted) return;
    }
    setState(() {
      _uploading = kind;
      _error = null;
    });
    final result = remove ? await repo.removeImage(_current, kind) : await repo.setImage(_current, kind, image!);
    if (!mounted) return;
    setState(() {
      _uploading = null;
      if (result case Err(:final failure)) _error = failure.userMessage;
    });
    refreshGroup(ref, widget.group);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).update(
          widget.group.id,
          GroupUpdate(
            name: _name.text.trim(),
            categorySlug: _category,
            joinPolicy: _policy,
            about: _about.text.trim(),
            rules: _rules.text.trim(),
            links: [for (final l in _links) GroupLink(label: l.label.text.trim(), url: l.url.text.trim())],
            province: _province == widget.group.province ? null : _province ?? 0,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        refreshGroup(ref, widget.group);
        context.pop();
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(group: widget.group),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).delete(widget.group.id);
    if (!mounted) return;
    switch (result) {
      case Ok():
        refreshGroup(ref, widget.group);
        context.go(GroupRoutes.discover);
        showGroupMessage(context, '${widget.group.name} silindi.');
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupByHandleProvider(widget.group.handle)).value ?? widget.group;
    final busy = _saving || _uploading != null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grubu düzenle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: GwSpacing.sm),
            child: GwButton(label: 'Kaydet', onPressed: busy ? null : _save, isLoading: _saving),
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
                    title: 'Logo ve kapak',
                    subtitle: 'JPEG, PNG veya WebP · en fazla 5 MB',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImageRow(
                          label: 'Logo',
                          preview: GwAvatar(name: group.name, shape: GwAvatarShape.group, imageUrl: group.logoUrl, size: GwAvatarSize.lg),
                          hasImage: group.logoUrl != null,
                          loading: _uploading == GroupImage.logo,
                          enabled: !busy,
                          onChange: () => _changeImage(GroupImage.logo),
                          onRemove: () => _changeImage(GroupImage.logo, remove: true),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        _ImageRow(
                          label: 'Kapak',
                          preview: ClipRRect(
                            borderRadius: GwRadius.smAll,
                            child: SizedBox(
                              width: GwAvatarSize.lg.dimension * 3,
                              height: GwAvatarSize.lg.dimension,
                              child: group.coverUrl == null
                                  ? const ColoredBox(color: GwColors.primarySoft)
                                  : Image.network(group.coverUrl!, fit: BoxFit.cover),
                            ),
                          ),
                          hasImage: group.coverUrl != null,
                          loading: _uploading == GroupImage.cover,
                          enabled: !busy,
                          onChange: () => _changeImage(GroupImage.cover),
                          onRemove: () => _changeImage(GroupImage.cover, remove: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: 'Grup bilgileri',
                    subtitle: 'Grup adresi: @${group.handle}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          maxLength: GroupRules.nameMaxLength,
                          textCapitalization: TextCapitalization.words,
                          validator: GroupRules.validateName,
                          decoration: const InputDecoration(labelText: 'Grup adı', counterText: ''),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        CategoryField(value: _category, onChanged: (v) => setState(() => _category = v ?? _category)),
                        const SizedBox(height: GwSpacing.md),
                        ProvinceField(value: _province, onChanged: (v) => setState(() => _province = v)),
                        const SizedBox(height: GwSpacing.md),
                        TextFormField(
                          controller: _about,
                          maxLength: GroupRules.aboutMaxLength,
                          minLines: 3,
                          maxLines: 8,
                          decoration: const InputDecoration(labelText: 'Tanıtım', alignLabelWithHint: true),
                        ),
                        const SizedBox(height: GwSpacing.md),
                        TextFormField(
                          controller: _rules,
                          maxLength: GroupRules.rulesMaxLength,
                          minLines: 3,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Kurallar',
                            hintText: 'Üyelerden beklentilerin, her satıra bir kural.',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: 'Katılım',
                    child: JoinPolicyPicker(value: _policy, onChanged: (p) => setState(() => _policy = p)),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  GwPanel(
                    title: 'Bağlantılar',
                    subtitle: 'Web sitesi, sosyal medya hesapları. En fazla ${GroupRules.maxLinks} tane.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, link) in _links.indexed) ...[
                          if (i > 0) const SizedBox(height: GwSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: link.label,
                                      maxLength: GroupRules.linkLabelMaxLength,
                                      validator: (v) => (v ?? '').trim().isEmpty ? 'Bir etiket yaz.' : null,
                                      decoration: const InputDecoration(labelText: 'Etiket', hintText: 'Instagram', counterText: ''),
                                    ),
                                    const SizedBox(height: GwSpacing.xs),
                                    TextFormField(
                                      controller: link.url,
                                      keyboardType: TextInputType.url,
                                      autocorrect: false,
                                      validator: GroupRules.validateLinkUrl,
                                      decoration: const InputDecoration(labelText: 'Adres', hintText: 'https://'),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Bağlantıyı kaldır',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => setState(() => _links.removeAt(i).dispose()),
                              ),
                            ],
                          ),
                        ],
                        if (_links.length < GroupRules.maxLinks) ...[
                          if (_links.isNotEmpty) const SizedBox(height: GwSpacing.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GwButton(
                              label: 'Bağlantı ekle',
                              icon: Icons.add_link,
                              variant: GwButtonVariant.secondary,
                              onPressed: () => setState(() => _links.add(_LinkControllers())),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: GwSpacing.lg),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: GwSpacing.sm,
                      runSpacing: GwSpacing.sm,
                      children: [
                        GwButton(label: 'Vazgeç', variant: GwButtonVariant.secondary, onPressed: busy ? null : () => context.pop()),
                        GwButton(label: 'Değişiklikleri kaydet', onPressed: busy ? null : _save, isLoading: _saving),
                      ],
                    ),
                  ),
                  if (widget.me.can(GroupPermission.delete)) ...[
                    const SizedBox(height: GwSpacing.xl),
                    GwPanel(
                      title: 'Grubu sil',
                      subtitle: 'Grup, üyelikler, roller, istekler ve davetler kalıcı olarak silinir. Paketin kalan süresi iade edilmez.',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: GwColors.error),
                          onPressed: busy ? null : _delete,
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: Text('${group.name} grubunu sil', style: textTheme.labelLarge?.copyWith(color: GwColors.error)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({
    required this.label,
    required this.preview,
    required this.hasImage,
    required this.loading,
    required this.enabled,
    required this.onChange,
    required this.onRemove,
  });

  final String label;
  final Widget preview;
  final bool hasImage;
  final bool loading;
  final bool enabled;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: GwSpacing.md,
      runSpacing: GwSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        preview,
        Wrap(
          spacing: GwSpacing.xs,
          children: [
            GwButton(
              label: hasImage ? '$label değiştir' : '$label ekle',
              icon: Icons.photo_camera_outlined,
              variant: GwButtonVariant.secondary,
              isLoading: loading,
              onPressed: enabled ? onChange : null,
            ),
            if (hasImage)
              GwButton(label: 'Kaldır', variant: GwButtonVariant.text, onPressed: enabled ? onRemove : null),
          ],
        ),
      ],
    );
  }
}

/// Deletion is permanent, so the owner types the group address to confirm.
class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.group});

  final Group group;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _confirm.text.trim().toLowerCase() == widget.group.handle;
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: const Text('Grubu kalıcı olarak sil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bu işlem geri alınamaz. Onaylamak için grup adresini yaz: ${widget.group.handle}'),
            const SizedBox(height: GwSpacing.md),
            TextField(
              controller: _confirm,
              autocorrect: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: widget.group.handle),
            ),
          ],
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
        GwButton(label: 'Sil', onPressed: matches ? () => Navigator.of(context).pop(true) : null),
      ],
    );
  }
}
