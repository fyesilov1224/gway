import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_legal.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'widgets.dart';

/// Hukuki metin yönetimi (docs/ARCHITECTURE.md §8b): her türün sürümleri; yeni sürüm yayınla, onaysızları düzenle/sil.
class AdminLegalScreen extends ConsumerWidget {
  const AdminLegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kinds = ref.watch(legalKindsProvider);
    void refresh() => ref.invalidate(legalKindsProvider);

    return AdminPage(
      title: 'Hukuki metinler',
      subtitle: 'KVKK, kullanım koşulları, açık rıza ve mesafeli satış metinleri. Bir sürümü biri onayladıktan sonra '
          'değiştirilemez; metni güncellemek için yeni sürüm yayınlarsın. Yayından önce metinlerin hukuki incelemeden '
          'geçmesi gerekir.',
      actions: [
        GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: refresh),
      ],
      children: switch (kinds) {
        AsyncData(:final value) => [
            for (final kind in value) ...[
              _KindPanel(kind: kind, onChanged: refresh),
              const SizedBox(height: GwSpacing.lg),
            ],
          ],
        AsyncError(:final error) => [GwPanel(child: GwErrorState(message: userMessageOf(error), onRetry: refresh))],
        _ => [
            for (var i = 0; i < 4; i++) ...[
              const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
              const SizedBox(height: GwSpacing.lg),
            ],
          ],
      },
    );
  }
}

class _KindPanel extends ConsumerWidget {
  const _KindPanel({required this.kind, required this.onChanged});

  final LegalKind kind;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final audience = kind.audience == 'purchase' ? 'Satın alırken onaylanır' : 'Kayıtta onaylanır';

    return GwPanel(
      title: legalKindLabel(kind.kind),
      subtitle: audience,
      trailing: GwButton(
        label: 'Yeni sürüm',
        icon: Icons.add,
        variant: GwButtonVariant.secondary,
        onPressed: () => _openEditor(context, ref, kind: kind.kind),
      ),
      padding: EdgeInsets.zero,
      child: kind.versions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(GwSpacing.lg),
              child: Text('Bu tür için henüz bir metin yayınlanmadı.',
                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, v) in kind.versions.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  _VersionRow(kind: kind.kind, version: v, onChanged: onChanged),
                ],
              ],
            ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, {required String kind, LegalVersion? version}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LegalEditorScreen(kind: kind, version: version?.version, readOnly: version?.isFrozen ?? false),
    )).then((_) => onChanged());
  }
}

class _VersionRow extends ConsumerWidget {
  const _VersionRow({required this.kind, required this.version, required this.onChanged});

  final String kind;
  final LegalVersion version;
  final VoidCallback onChanged;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: const Text('Sürümü sil'),
        content: Text('${legalKindLabel(kind)} v${version.version} silinsin mi? Bu işlem geri alınamaz.'),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GwButton(label: 'Sil', onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(adminLegalRepositoryProvider).remove(kind, version.version);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) { Ok() => 'Sürüm silindi.', Err(:final failure) => failure.userMessage }),
    ));
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    void edit() => Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (_) => LegalEditorScreen(kind: kind, version: version.version, readOnly: version.isFrozen),
        ))
        .then((_) => onChanged());

    return InkWell(
      onTap: edit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: GwSpacing.xxl,
              child: Text('v${version.version}', style: textTheme.titleMedium?.copyWith(color: GwColors.textSecondary)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(version.title, style: textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: GwSpacing.xxs),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (version.isCurrent) const GwBadge('Yürürlükte', tone: GwBadgeTone.success, dot: true),
                      if (version.isDraft)
                        const GwBadge('Taslak · ileri tarihli', tone: GwBadgeTone.warning, dot: true),
                      if (version.isFrozen)
                        GwBadge('${formatCount(version.consentCount)} onay · kilitli', tone: GwBadgeTone.info),
                      Text(
                        version.isDraft
                            ? 'Yürürlük: ${formatDateTime(version.publishedAt)}'
                            : 'Yayın: ${formatDateTime(version.publishedAt)}',
                        style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: version.isFrozen ? 'Görüntüle' : 'Düzenle',
              icon: Icon(version.isFrozen ? Icons.visibility_outlined : Icons.edit_outlined),
              onPressed: edit,
            ),
            if (!version.isFrozen)
              IconButton(
                tooltip: 'Sil',
                icon: const Icon(Icons.delete_outline, color: GwColors.error),
                onPressed: () => _delete(context, ref),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bir sürümü yazar ya da düzenler. Yeni sürümde [version] null; onaylı sürümde [readOnly] (yalnızca okunur).
class LegalEditorScreen extends ConsumerStatefulWidget {
  const LegalEditorScreen({super.key, required this.kind, this.version, this.readOnly = false});

  final String kind;
  final int? version;
  final bool readOnly;

  @override
  ConsumerState<LegalEditorScreen> createState() => _LegalEditorScreenState();
}

class _LegalEditorScreenState extends ConsumerState<LegalEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _form = GlobalKey<FormState>();
  DateTime _publishedAt = DateTime.now();
  bool _schedule = false;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  bool get _creating => widget.version == null;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _fill(LegalDocument doc) {
    if (_loaded) return;
    _loaded = true;
    _title.text = doc.title;
    _body.text = doc.body;
    _publishedAt = doc.publishedAt.toLocal();
    _schedule = doc.publishedAt.isAfter(DateTime.now());
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _publishedAt.isBefore(now) ? now : _publishedAt,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_publishedAt));
    if (!mounted) return;
    setState(() => _publishedAt = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(adminLegalRepositoryProvider);
    final at = _schedule ? _publishedAt : null;
    final result = _creating
        ? await repo.publish(widget.kind, title: _title.text.trim(), body: _body.text.trim(), publishedAt: at)
        : await repo.update(widget.kind, widget.version!,
            title: _title.text.trim(), body: _body.text.trim(), publishedAt: at ?? DateTime.now());
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(legalKindsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_creating ? 'Yeni sürüm yayınlandı.' : 'Sürüm güncellendi.')),
        );
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final doc = _creating ? null : ref.watch(legalDocumentProvider((kind: widget.kind, version: widget.version!)));
    if (doc case AsyncData(:final value)) _fill(value);
    final title = '${legalKindLabel(widget.kind)}${_creating ? ' · yeni sürüm' : ' · v${widget.version}'}';

    return Scaffold(
      backgroundColor: GwColors.surface,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.only(right: GwSpacing.md),
              child: GwButton(
                label: _creating ? 'Yayınla' : 'Kaydet',
                icon: Icons.check,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
        ],
      ),
      body: switch (doc) {
        AsyncError(:final error) => Center(
            child: GwErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(legalDocumentProvider((kind: widget.kind, version: widget.version!))),
            ),
          ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(GwSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.readOnly)
                        const DetailBanner(
                          tone: GwBadgeTone.info,
                          icon: Icons.lock_outline,
                          title: 'Bu sürüm kilitli',
                          body: 'En az bir kullanıcı onayladığı için değiştirilemez. Güncellemek için yeni bir sürüm yayınla.',
                        ),
                      if (widget.readOnly) const SizedBox(height: GwSpacing.md),
                      TextFormField(
                        controller: _title,
                        readOnly: widget.readOnly,
                        maxLength: 200,
                        decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
                        validator: (v) => (v ?? '').trim().length < 3 ? 'Başlık en az 3 karakter olmalı.' : null,
                      ),
                      const SizedBox(height: GwSpacing.md),
                      TextFormField(
                        controller: _body,
                        readOnly: widget.readOnly,
                        minLines: 14,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Metin',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v ?? '').trim().length < 20 ? 'Metin en az 20 karakter olmalı.' : null,
                      ),
                      const SizedBox(height: GwSpacing.md),
                      if (!widget.readOnly) ...[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _schedule,
                          title: const Text('İleri tarihte yürürlüğe girsin'),
                          subtitle: Text(_schedule
                              ? 'Seçilen zamana kadar taslak kalır, kimseye görünmez.'
                              : 'Kaydedilince hemen yürürlüğe girer.'),
                          onChanged: (v) => setState(() => _schedule = v),
                        ),
                        if (_schedule)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_outlined),
                            title: Text('Yürürlük: ${formatDateTime(_publishedAt)}'),
                            trailing: GwButton(label: 'Değiştir', variant: GwButtonVariant.text, onPressed: _pickDate),
                          ),
                      ],
                      if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
                      const SizedBox(height: GwSpacing.sm),
                      Text(
                        'Metinler hukuki bağlayıcılığı olan belgelerdir; yayınlamadan önce hukuk danışmanının onayından geçmelidir.',
                        style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                      ),
                      if (!_creating) ...[
                        const SizedBox(height: GwSpacing.xl),
                        _Translations(kind: widget.kind, version: widget.version!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      },
    );
  }
}

/// Bir sürümün bilgi amaçlı çevirileri (docs/ARCHITECTURE.md §11): bağlayıcı olan Türkçe metindir; çeviri onaydan
/// sonra da düzeltilebilir.
class _Translations extends ConsumerWidget {
  const _Translations({required this.kind, required this.version});

  final String kind;
  final int version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (kind: kind, version: version);
    final translations = ref.watch(legalTranslationsProvider(key));
    final textTheme = Theme.of(context).textTheme;

    Future<void> open(String language, LegalTranslation? existing) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => LegalTranslationEditorScreen(kind: kind, version: version, language: language, existing: existing),
      ));
      ref.invalidate(legalTranslationsProvider(key));
    }

    return GwPanel(
      title: 'Çeviriler',
      subtitle: 'Uygulama metni kişinin dilinde gösterir ve "Bağlayıcı metin Türkçedir" notunu ekler. Onay her zaman Türkçe '
          'sürüme verilir. Çeviriler bu sürüm onaylandıktan sonra da düzeltilebilir.',
      padding: EdgeInsets.zero,
      child: switch (translations) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, MapEntry(key: code, value: name)) in legalTranslationLanguages.entries.indexed) ...[
                if (i > 0) const Divider(height: 1),
                () {
                  final existing = value.where((t) => t.language == code).firstOrNull;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text(existing == null ? 'Çeviri yok' : 'Güncelleme: ${formatDateTime(existing.updatedAt)}',
                        style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                    leading: existing == null
                        ? const GwBadge('Yok', tone: GwBadgeTone.neutral)
                        : const GwBadge('Var', tone: GwBadgeTone.success, dot: true),
                    trailing: GwButton(
                      label: existing == null ? 'Ekle' : 'Düzenle',
                      variant: GwButtonVariant.text,
                      onPressed: () => open(code, existing),
                    ),
                    onTap: () => open(code, existing),
                  );
                }(),
              ],
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.all(GwSpacing.lg),
            child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(legalTranslationsProvider(key))),
          ),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: GwSkeleton(height: GwSpacing.xxl * 3)),
      },
    );
  }
}

/// Bir sürümün tek bir dildeki çevirisini yazar ya da düzeltir.
class LegalTranslationEditorScreen extends ConsumerStatefulWidget {
  const LegalTranslationEditorScreen({super.key, required this.kind, required this.version, required this.language, this.existing});

  final String kind;
  final int version;
  final String language;
  final LegalTranslation? existing;

  @override
  ConsumerState<LegalTranslationEditorScreen> createState() => _LegalTranslationEditorScreenState();
}

class _LegalTranslationEditorScreenState extends ConsumerState<LegalTranslationEditorScreen> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _body = TextEditingController(text: widget.existing?.body);
  final _form = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Result<void>> Function(AdminLegalRepository repo) action, String done) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await action(ref.read(adminLegalRepositoryProvider));
    if (!mounted) return;
    switch (result) {
      case Ok():
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    _run((repo) => repo.saveTranslation(widget.kind, widget.version, widget.language, title: _title.text.trim(), body: _body.text.trim()),
        'Çeviri kaydedildi.');
  }

  @override
  Widget build(BuildContext context) {
    final language = legalTranslationLanguages[widget.language] ?? widget.language;
    return Scaffold(
      backgroundColor: GwColors.surface,
      appBar: AppBar(
        title: Text('${legalKindLabel(widget.kind)} · v${widget.version} · $language'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Çeviriyi sil',
              icon: const Icon(Icons.delete_outline, color: GwColors.error),
              onPressed: _saving
                  ? null
                  : () => _run((repo) => repo.removeTranslation(widget.kind, widget.version, widget.language), 'Çeviri silindi.'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: GwSpacing.md),
            child: GwButton(label: 'Kaydet', icon: Icons.check, isLoading: _saving, onPressed: _save),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GwSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DetailBanner(
                    tone: GwBadgeTone.info,
                    icon: Icons.translate,
                    title: 'Bilgi amaçlı çeviri',
                    body: 'Bağlayıcı olan Türkçe metindir; kişi her zaman Türkçe sürümü onaylar. Çeviriyi yayından önce o dili '
                        'anadili olarak konuşan birine kontrol ettir.',
                  ),
                  const SizedBox(height: GwSpacing.md),
                  TextFormField(
                    controller: _title,
                    maxLength: 200,
                    textDirection: widget.language == 'ar' ? TextDirection.rtl : null,
                    decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().length < 3 ? 'Başlık en az 3 karakter olmalı.' : null,
                  ),
                  const SizedBox(height: GwSpacing.md),
                  TextFormField(
                    controller: _body,
                    minLines: 14,
                    maxLines: null,
                    textDirection: widget.language == 'ar' ? TextDirection.rtl : null,
                    decoration: const InputDecoration(labelText: 'Metin', alignLabelWithHint: true, border: OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().length < 20 ? 'Metin en az 20 karakter olmalı.' : null,
                  ),
                  if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
