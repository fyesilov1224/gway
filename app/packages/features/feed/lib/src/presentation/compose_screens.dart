import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/image_processing.dart';
import '../data/media_picker.dart';
import '../domain/media_crop.dart';
import '../domain/post.dart';
import 'crop_editor.dart';
import 'providers.dart';
import 'routes.dart';

/// One picked file and how it is framed.
class _Item {
  _Item(this.media);

  final NewMedia media;
  CropFrame frame = const CropFrame();

  Size get size => Size(media.width.toDouble(), media.height.toDouble());
}

/// Shares a post as the user or, with `posts.publish`, as one of their groups.
/// Photos are framed here and prepared on the device before upload (docs/ARCHITECTURE.md §3c).
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.groupId, this.eventId});

  /// Preselected group (from a group page).
  final String? groupId;

  /// Shares a memory of this event (from the event page).
  final String? eventId;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _caption = TextEditingController();
  final _items = <_Item>[];
  int _selected = 0;
  MediaAspect _aspect = MediaAspect.original;
  late String? _groupId = widget.groupId;
  bool _commentsDisabled = false;
  bool _hideLikeCount = false;
  bool _picking = false;
  String? _stage;
  String? _error;

  /// Every item uses the first one's frame shape.
  double get _ratio => _items.isEmpty ? GxMedia.square : _aspect.ratioFor(_items.first.size);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final picked = await pickMedia(multiple: true);
      if (!mounted) return;
      final room = NewPost.maxMedia - _items.length;
      setState(() {
        _items.addAll(picked.take(room).map(_Item.new));
        _error = picked.length > room ? 'Bir gönderide en fazla 10 fotoğraf ya da video olabilir.' : null;
      });
    } on Object {
      if (mounted) setState(() => _error = 'Seçilen dosya açılamadı. Başka bir fotoğraf ya da video dene.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _fail(String message) => setState(() {
        _stage = null;
        _error = message;
      });

  Future<void> _share() async {
    final videoProblem = _items.map((i) => i.media).where((m) => m.kind == MediaKind.video).map((m) => m.problem).nonNulls;
    if (NewPost.captionProblem(_caption.text) ?? videoProblem.firstOrNull case final problem?) return _fail(problem);
    setState(() {
      _error = null;
      _stage = 'Fotoğraflar hazırlanıyor…';
    });
    final List<NewMedia> media;
    try {
      media = [
        for (final item in _items)
          item.media.kind == MediaKind.video
              ? item.media
              : await renderPhoto(item.media, item.frame.rectIn(item.size, _ratio),
                  maxSide: GxMedia.uploadMaxSide, thumbSide: GxMedia.thumbMaxSide),
      ];
    } on Object {
      if (mounted) _fail('Fotoğraflar hazırlanamadı. Başka bir fotoğraf dene.');
      return;
    }
    final post = NewPost(
      media: media,
      caption: _caption.text,
      groupId: _groupId,
      eventId: widget.eventId,
      commentsDisabled: _commentsDisabled,
      hideLikeCount: _hideLikeCount,
    );
    final result = await ref.read(feedRepositoryProvider).create(
          post,
          onProgress: (done, total) =>
              mounted ? setState(() => _stage = done < total ? 'Yükleniyor: $done/$total' : 'Paylaşılıyor…') : null,
        );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        refreshPostLists(ref);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gönderin paylaşıldı.')));
        context.pushReplacement(FeedRoutes.post(value));
      case Err(:final failure):
        _fail(failure.userMessage);
    }
  }

  void _setAspect(MediaAspect aspect) => setState(() {
        _aspect = aspect;
        for (final i in _items) {
          i.frame = const CropFrame();
        }
      });

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(publishableGroupsProvider).value ?? const <PostGroup>[];
    final busy = _stage != null;
    final textTheme = Theme.of(context).textTheme;
    final selected = _items.isEmpty ? null : _items[_selected.clamp(0, _items.length - 1)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni gönderi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: GxSpacing.sm),
            child: GxButton(label: 'Paylaş', isLoading: busy, onPressed: _items.isEmpty ? null : _share),
          ),
        ],
      ),
      body: GxReadingColumn(
        maxWidth: GxLayout.feedMaxWidth,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.md),
          children: [
            if (widget.eventId != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.sm),
                child: Text(
                  'Bu gönderi organizasyonun anıları arasında da görünecek. Yalnızca kendi fotoğraflarını ve izin aldığın kişileri paylaş.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
              ),
            if (selected == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
                child: _picking
                    ? const AspectRatio(
                        aspectRatio: GxMedia.square,
                        child: GxSkeleton(height: double.infinity, borderRadius: GxRadius.lgAll),
                      )
                    : GxEmptyState(
                        icon: Icons.add_photo_alternate_outlined,
                        message: 'Paylaşmak için 10 taneye kadar fotoğraf ya da video seç.',
                        actionLabel: 'Galeriden seç',
                        onAction: _pick,
                      ),
              )
            else ...[
              IgnorePointer(
                ignoring: busy,
                child: CropEditor(
                  key: ObjectKey(selected),
                  media: selected.media,
                  ratio: _ratio,
                  frame: selected.frame,
                  onChanged: (f) => setState(() => selected.frame = f),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.md, 0),
                child: Wrap(
                  spacing: GxSpacing.xs,
                  children: [
                    for (final a in MediaAspect.values)
                      ChoiceChip(label: Text(a.label), selected: _aspect == a, onSelected: busy ? null : (_) => _setAspect(a)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.xs, GxSpacing.md, 0),
                child: Text(
                  'Yakınlaştırmak için iki parmakla aç, kadrajlamak için sürükle. Oran tüm fotoğraflara uygulanır.',
                  style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary),
                ),
              ),
              const SizedBox(height: GxSpacing.sm),
              _MediaStrip(
                items: _items,
                selected: _selected,
                onSelect: (i) => setState(() => _selected = i),
                onRemove: busy
                    ? null
                    : (i) => setState(() {
                          _items.removeAt(i);
                          if (_selected >= _items.length) _selected = _items.isEmpty ? 0 : _items.length - 1;
                        }),
                onAdd: busy || _items.length >= NewPost.maxMedia ? null : _pick,
                onReorder: busy
                    ? null
                    : (from, to) => setState(() {
                          final item = _items.removeAt(from);
                          _items.insert(to > from ? to - 1 : to, item);
                        }),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_stage case final stage?) ...[
                    const SizedBox(height: GxSpacing.sm),
                    const LinearProgressIndicator(borderRadius: GxRadius.smAll),
                    const SizedBox(height: GxSpacing.xxs),
                    Text(stage, style: textTheme.labelMedium),
                  ],
                  if (_error case final error?) ...[
                    const SizedBox(height: GxSpacing.sm),
                    GxFormMessage(error),
                  ],
                  const SizedBox(height: GxSpacing.md),
                  TextField(
                    controller: _caption,
                    enabled: !busy,
                    minLines: 3,
                    maxLines: 8,
                    maxLength: NewPost.maxCaption,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      hintText: 'Bir şeyler yaz… #etiket ve @kullanıcıadı ekleyebilirsin.',
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (groups.isNotEmpty) ...[
                    const SizedBox(height: GxSpacing.md),
                    DropdownButtonFormField<String?>(
                      initialValue: groups.any((g) => g.id == _groupId) ? _groupId : null,
                      decoration: const InputDecoration(labelText: 'Kim adına paylaşılsın?'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Kendi profilim')),
                        for (final g in groups) DropdownMenuItem(value: g.id, child: Text('${g.name} (grup)')),
                      ],
                      onChanged: busy ? null : (v) => setState(() => _groupId = v),
                    ),
                  ],
                  const SizedBox(height: GxSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Yorumları kapat'),
                    value: _commentsDisabled,
                    onChanged: busy ? null : (v) => setState(() => _commentsDisabled = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Beğeni sayısını gizle'),
                    subtitle: const Text('Sayıyı yalnızca sen görürsün.'),
                    value: _hideLikeCount,
                    onChanged: busy ? null : (v) => setState(() => _hideLikeCount = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picked media in order: tap to frame, drag to reorder, × to remove.
class _MediaStrip extends StatelessWidget {
  const _MediaStrip({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onRemove,
    required this.onAdd,
    required this.onReorder,
  });

  final List<_Item> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final void Function(int index)? onRemove;
  final VoidCallback? onAdd;
  final void Function(int from, int to)? onReorder;

  static const _tile = GxSpacing.xxl + GxSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.labelMedium?.copyWith(color: GxColors.onMedia);
    final cacheWidth = gxCacheWidth(_tile, MediaQuery.devicePixelRatioOf(context));
    return SizedBox(
      height: _tile,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
              buildDefaultDragHandles: onReorder != null,
              itemCount: items.length,
              onReorder: onReorder ?? (_, _) {},
              itemBuilder: (context, i) {
                final m = items[i].media;
                return Padding(
                  key: ObjectKey(items[i]),
                  padding: const EdgeInsets.only(right: GxSpacing.xs),
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: '${i + 1}. medya',
                    child: InkWell(
                      onTap: () => onSelect(i),
                      borderRadius: GxRadius.smAll,
                      child: Container(
                        width: _tile,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: GxRadius.smAll,
                          border: Border.all(color: i == selected ? GxColors.primary : GxColors.border, width: GxBorders.ringWidth),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (m.kind == MediaKind.image)
                              Image.memory(m.bytes, fit: BoxFit.cover, cacheWidth: cacheWidth)
                            else
                              ColoredBox(
                                color: GxColors.media,
                                child: Center(child: Text('▶ ${m.duration?.inSeconds ?? 0} sn', style: label)),
                              ),
                            if (onRemove != null)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  tooltip: 'Çıkar',
                                  onPressed: () => onRemove!(i),
                                  style: IconButton.styleFrom(backgroundColor: GxColors.mediaScrim, foregroundColor: GxColors.onMedia),
                                  icon: const Icon(Icons.close, size: GxSpacing.md),
                                ),
                              ),
                            if (m.kind == MediaKind.video && m.problem != null)
                              const Positioned(
                                left: GxSpacing.xxs,
                                bottom: GxSpacing.xxs,
                                child: Icon(Icons.error, color: GxColors.error, semanticLabel: 'Paylaşılamaz'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (onAdd != null)
            Padding(
              padding: const EdgeInsets.only(right: GxSpacing.md),
              child: SizedBox.square(
                dimension: _tile,
                child: OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: GxRadius.smAll),
                    side: const BorderSide(color: GxColors.border),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add, semanticLabel: 'Medya ekle'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Caption and options; media cannot change after posting.
class EditPostScreen extends ConsumerStatefulWidget {
  const EditPostScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  TextEditingController? _caption;
  late bool _commentsDisabled;
  late bool _hideLikeCount;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _caption?.dispose();
    super.dispose();
  }

  Future<void> _save(Post post) async {
    final caption = _caption!.text;
    if (NewPost.captionProblem(caption) case final problem?) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref
        .read(feedRepositoryProvider)
        .update(post.id, caption: caption, commentsDisabled: _commentsDisabled, hideLikeCount: _hideLikeCount);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok():
        ref.read(postEditsProvider.notifier).put(
              post.copyWith(caption: caption.trim(), commentsDisabled: _commentsDisabled, hideLikeCount: _hideLikeCount),
            );
        ref.invalidate(postProvider(post.id));
        context.pop();
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(postProvider(widget.postId));
    final post = loaded.value;
    if (post != null && _caption == null) {
      _caption = TextEditingController(text: post.caption);
      _commentsDisabled = post.commentsDisabled;
      _hideLikeCount = post.hideLikeCount;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderiyi düzenle'),
        actions: [
          if (post != null && post.canManage)
            Padding(
              padding: const EdgeInsets.only(right: GxSpacing.sm),
              child: GxButton(label: 'Kaydet', isLoading: _saving, onPressed: () => _save(post)),
            ),
        ],
      ),
      body: GxReadingColumn(
        maxWidth: GxLayout.feedMaxWidth,
        child: switch (loaded) {
          AsyncData(:final value) when !value.canManage => GxEmptyState(
              icon: Icons.lock_outline,
              message: 'Bu gönderiyi düzenleme yetkin yok.',
              actionLabel: 'Geri dön',
              onAction: () => context.pop(),
            ),
          AsyncData() => ListView(
              padding: const EdgeInsets.all(GxSpacing.md),
              children: [
                if (_error case final error?) ...[GxFormMessage(error), const SizedBox(height: GxSpacing.sm)],
                TextField(
                  controller: _caption,
                  minLines: 3,
                  maxLines: 8,
                  maxLength: NewPost.maxCaption,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Açıklama', alignLabelWithHint: true),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Yorumları kapat'),
                  value: _commentsDisabled,
                  onChanged: (v) => setState(() => _commentsDisabled = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Beğeni sayısını gizle'),
                  subtitle: const Text('Sayıyı yalnızca sen görürsün.'),
                  value: _hideLikeCount,
                  onChanged: (v) => setState(() => _hideLikeCount = v),
                ),
              ],
            ),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postProvider(widget.postId))),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
