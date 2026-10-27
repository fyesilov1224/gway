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
        GxButton(label: 'Yenile', icon: Icons.refresh, variant: GxButtonVariant.secondary, onPressed: refresh),
      ],
      children: switch (kinds) {
        AsyncData(:final value) => [
            for (final kind in value) ...[
              _KindPanel(kind: kind, onChanged: refresh),
              const SizedBox(height: GxSpacing.lg),
            ],
          ],
        AsyncError(:final error) => [GxPanel(child: GxErrorState(message: userMessageOf(error), onRetry: refresh))],
        _ => [
            for (var i = 0; i < 4; i++) ...[
              const GxSkeleton(height: GxSpacing.xxl * 3, borderRadius: GxRadius.lgAll),
              const SizedBox(height: GxSpacing.lg),
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

    return GxPanel(
      title: legalKindLabel(kind.kind),
      subtitle: audience,
      trailing: GxButton(
        label: 'Yeni sürüm',
        icon: Icons.add,
        variant: GxButtonVariant.secondary,
        onPressed: () => _openEditor(context, ref, kind: kind.kind),
      ),
      padding: EdgeInsets.zero,
      child: kind.versions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(GxSpacing.lg),
              child: Text('Bu tür için henüz bir metin yayınlanmadı.',
                  style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
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
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: const Text('Sürümü sil'),
        content: Text('${legalKindLabel(kind)} v${version.version} silinsin mi? Bu işlem geri alınamaz.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GxButton(label: 'Sil', onPressed: () => Navigator.of(dialog).pop(true)),
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
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: GxSpacing.xxl,
              child: Text('v${version.version}', style: textTheme.titleMedium?.copyWith(color: GxColors.textSecondary)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(version.title, style: textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: GxSpacing.xxs),
                  Wrap(
                    spacing: GxSpacing.xs,
                    runSpacing: GxSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (version.isCurrent) const GxBadge('Yürürlükte', tone: GxBadgeTone.success, dot: true),
                      if (version.isDraft)
                        const GxBadge('Taslak · ileri tarihli', tone: GxBadgeTone.warning, dot: true),
                      if (version.isFrozen)
                        GxBadge('${formatCount(version.consentCount)} onay · kilitli', tone: GxBadgeTone.info),
                      Text(
                        version.isDraft
                            ? 'Yürürlük: ${formatDateTimeTr(version.publishedAt)}'
                            : 'Yayın: ${formatDateTimeTr(version.publishedAt)}',
                        style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
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
                icon: const Icon(Icons.delete_outline, color: GxColors.error),
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
      backgroundColor: GxColors.surface,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.only(right: GxSpacing.md),
              child: GxButton(
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
            child: GxErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(legalDocumentProvider((kind: widget.kind, version: widget.version!))),
            ),
          ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(GxSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.readOnly)
                        const DetailBanner(
                          tone: GxBadgeTone.info,
                          icon: Icons.lock_outline,
                          title: 'Bu sürüm kilitli',
                          body: 'En az bir kullanıcı onayladığı için değiştirilemez. Güncellemek için yeni bir sürüm yayınla.',
                        ),
                      if (widget.readOnly) const SizedBox(height: GxSpacing.md),
                      TextFormField(
                        controller: _title,
                        readOnly: widget.readOnly,
                        maxLength: 200,
                        decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
                        validator: (v) => (v ?? '').trim().length < 3 ? 'Başlık en az 3 karakter olmalı.' : null,
                      ),
                      const SizedBox(height: GxSpacing.md),
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
                      const SizedBox(height: GxSpacing.md),
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
                            title: Text('Yürürlük: ${formatDateTimeTr(_publishedAt)}'),
                            trailing: GxButton(label: 'Değiştir', variant: GxButtonVariant.text, onPressed: _pickDate),
                          ),
                      ],
                      if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
                      const SizedBox(height: GxSpacing.sm),
                      Text(
                        'Metinler hukuki bağlayıcılığı olan belgelerdir; yayınlamadan önce hukuk danışmanının onayından geçmelidir.',
                        style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                      ),
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
