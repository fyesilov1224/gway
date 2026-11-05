import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_content.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Posts by caption, author or group; removed ones behind a filter.
class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminContentFilter? _filter;
  int _page = 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => setState(() {
          _query = value.trim();
          _page = 1;
        }));
  }

  void _clear() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _filter = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: _query, filter: _filter, page: _page);
    final result = ref.watch(contentSearchProvider(key));
    final filtered = _query.isNotEmpty || _filter != null;

    return AdminPage(
      title: 'İçerik',
      subtitle: 'Kullanıcı ve grup gönderileri. Kaldırılan içerik kullanıcılara görünmez, kanıt olarak saklanır.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(contentSearchProvider),
        ),
      ],
      children: [
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminContentFilter>(
                controller: _search,
                hint: 'Açıklama, kullanıcı adı veya grup ile ara',
                query: _query,
                filters: [for (final f in AdminContentFilter.values) (f, f.label)],
                selected: _filter,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: (f) => setState(() {
                  _filter = f;
                  _page = 1;
                }),
                onClear: _clear,
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: filtered
                        ? GwEmptyState(
                            icon: Icons.search_off,
                            message: 'Aramana ve filtrene uygun gönderi bulunamadı.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clear,
                          )
                        : GwEmptyState(
                            icon: Icons.photo_library_outlined,
                            message: 'Henüz gönderi yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(contentSearchProvider(key)),
                          ),
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p in value.items) ...[_PostRow(post: p), const Divider()],
                      PageFooter(
                        from: value.range.$1,
                        to: value.range.$2,
                        total: value.total,
                        noun: 'gönderi',
                        page: value.page,
                        pageCount: value.pageCount,
                        onPage: (p) => setState(() => _page = p),
                      ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(contentSearchProvider(key))),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.all(GwSpacing.lg),
                    child: Column(children: [
                      GwSkeleton(height: GwSpacing.xl),
                      SizedBox(height: GwSpacing.md),
                      GwSkeleton(height: GwSpacing.xl),
                    ]),
                  ),
              },
            ],
          ),
        ),
      ],
    );
  }
}

/// Square preview of a photo or a video's poster.
class _MediaThumb extends ConsumerWidget {
  const _MediaThumb({required this.media, required this.size});

  final AdminPostMedia? media;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = media;
    final path = m == null ? null : (m.isVideo ? m.posterPath : m.path);
    final placeholder = Icon(m?.isVideo ?? false ? Icons.videocam_outlined : Icons.image_outlined, color: GwColors.textSecondary);
    return ClipRRect(
      borderRadius: GwRadius.mdAll,
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: GwColors.surfaceMuted,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (path == null)
                placeholder
              else
                Image.network(ref.watch(mediaUrlProvider(path)), fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
              if (m?.isVideo ?? false)
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(GwSpacing.xxs),
                    child: Icon(Icons.play_circle_fill, color: GwColors.background, size: GwSpacing.md),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});

  final AdminPostSummary post;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = post;
    final meta = [
      p.owner,
      '${formatCount(p.likeCount)} beğeni',
      '${formatCount(p.commentCount)} yorum',
      formatDateTime(p.createdAt),
    ].join(' · ');
    return InkWell(
      onTap: () => context.go(AdminRoutes.post(p.id)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            _MediaThumb(media: p.cover, size: GwSpacing.xxl + GwSpacing.sm),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.caption.isEmpty ? '(Açıklama yok)' : p.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge,
                  ),
                  Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            if (p.isRemoved) ...[const SizedBox(width: GwSpacing.sm), const GwBadge('Kaldırıldı', dot: true, tone: GwBadgeTone.danger)],
            const SizedBox(width: GwSpacing.xs),
            const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// One post: media, counts, comments; remove / restore and comment removal.
class AdminPostDetailScreen extends ConsumerStatefulWidget {
  const AdminPostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<AdminPostDetailScreen> createState() => _AdminPostDetailScreenState();
}

class _AdminPostDetailScreenState extends ConsumerState<AdminPostDetailScreen> {
  bool _saving = false;

  Future<void> _run(Future<Result<void>> Function(AdminContentRepository repo) action) async {
    setState(() => _saving = true);
    final result = await action(ref.read(adminContentRepositoryProvider));
    if (!mounted) return;
    setState(() => _saving = false);
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref
      ..invalidate(postDetailProvider(widget.postId))
      ..invalidate(contentSearchProvider);
  }

  Future<void> _removePost() async {
    final request = await showSuspendDialog(
      context,
      title: 'Gönderiyi kaldır',
      description: 'Gönderi kullanıcılara görünmez ve sayaçlardan düşer. Kanıt olarak saklanır, geri alınabilir.',
      withDuration: false,
      confirmLabel: 'Kaldır',
    );
    if (request == null) return;
    await _run((repo) => repo.removePost(widget.postId, reason: request.reason));
  }

  Future<void> _removeComment(AdminComment comment) async {
    final request = await showSuspendDialog(
      context,
      title: 'Yorumu kaldır',
      description: 'Yorum ve yanıtları kullanıcılara görünmez. Kanıt olarak saklanır.',
      withDuration: false,
      confirmLabel: 'Kaldır',
    );
    if (request == null) return;
    await _run((repo) => repo.removeComment(comment.id, reason: request.reason));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(postDetailProvider(widget.postId));
    final canModerate = ref.watch(myStaffRoleProvider).value?.canModerateContent ?? false;
    const crumbs = [('İçerik', AdminRoutes.content)];

    return switch (detail) {
      AsyncData(:final value) => AdminPage(breadcrumbs: crumbs, title: 'Gönderi', children: _content(value, canModerate)),
      AsyncError(error: NotFoundFailure()) => AdminPage(
          breadcrumbs: crumbs,
          title: 'Bulunamadı',
          children: [
            GwPanel(
              child: GwEmptyState(
                icon: Icons.search_off,
                message: 'Bu gönderi bulunamadı. Yazarı silmiş olabilir.',
                actionLabel: 'İçerik listesine dön',
                onAction: () => context.go(AdminRoutes.content),
              ),
            ),
          ],
        ),
      AsyncError(:final error) => AdminPage(
          breadcrumbs: crumbs,
          children: [
            GwPanel(child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(postDetailProvider(widget.postId)))),
          ],
        ),
      _ => const AdminPage(
          breadcrumbs: crumbs,
          children: [GwSkeleton(height: GwSpacing.xxl * 5, borderRadius: GwRadius.lgAll)],
        ),
    };
  }

  List<Widget> _content(AdminPostDetail d, bool canModerate) {
    final p = d.post;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final textTheme = Theme.of(context).textTheme;

    final header = GwPanel(
      child: Wrap(
        spacing: GwSpacing.md,
        runSpacing: GwSpacing.sm,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.owner, style: textTheme.titleMedium),
              Text(formatDateTime(p.createdAt), style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
          if (canModerate && p.isRemoved)
            GwButton(
              label: 'Geri al',
              icon: Icons.restore,
              variant: GwButtonVariant.secondary,
              isLoading: _saving,
              onPressed: () => _run((repo) => repo.restorePost(widget.postId)),
            ),
          if (canModerate && !p.isRemoved)
            GwButton(label: 'Kaldır', icon: Icons.remove_circle_outline, isLoading: _saving, onPressed: _removePost),
        ],
      ),
    );

    final media = GwPanel(
      title: 'Medya',
      subtitle: '${d.media.length} dosya',
      child: Wrap(
        spacing: GwSpacing.xs,
        runSpacing: GwSpacing.xs,
        children: [for (final m in d.media) _MediaThumb(media: m, size: GwSpacing.xxl * 3)],
      ),
    );

    final info = InfoPanel(
      title: 'Bilgiler',
      rows: [
        ('Paylaşan', p.owner),
        ('Açıklama', p.caption.isEmpty ? '—' : p.caption),
        ('Beğeni', formatCount(p.likeCount)),
        ('Yorum', formatCount(p.commentCount)),
        ('Paylaşıldı', formatDateTime(p.createdAt)),
        ('Gönderi kimliği', p.id),
      ],
    );

    final comments = GwPanel(
      title: 'Yorumlar',
      subtitle: '${d.comments.length} yorum',
      child: d.comments.isEmpty
          ? Text('Bu gönderide yorum yok.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in d.comments)
                  _CommentTile(
                    comment: c,
                    onRemove: canModerate && c.removedAt == null && !_saving ? () => _removeComment(c) : null,
                  ),
              ],
            ),
    );

    return [
      header,
      const SizedBox(height: GwSpacing.lg),
      if (p.isRemoved) ...[
        DetailBanner(
          tone: GwBadgeTone.danger,
          icon: Icons.remove_circle_outline,
          title: 'Kaldırıldı · ${formatDateTime(p.removedAt!)}',
          body: p.removedReason,
        ),
        const SizedBox(height: GwSpacing.lg),
      ],
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Column(children: [media, const SizedBox(height: GwSpacing.lg), comments])),
            const SizedBox(width: GwSpacing.lg),
            Expanded(flex: 2, child: info),
          ],
        )
      else ...[
        info,
        const SizedBox(height: GwSpacing.lg),
        media,
        const SizedBox(height: GwSpacing.lg),
        comments,
      ],
    ];
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.onRemove});

  final AdminComment comment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = comment;
    final removed = c.removedAt != null;
    return Padding(
      padding: EdgeInsets.only(left: c.parentId == null ? 0 : GwSpacing.xl, bottom: GwSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [c.authorUsername == null ? 'Silinmiş hesap' : '@${c.authorUsername}', formatDateTime(c.createdAt)].join(' · '),
                  style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary),
                ),
                SelectableText(
                  c.body,
                  style: textTheme.bodyMedium?.copyWith(color: removed ? GwColors.textSecondary : null),
                ),
                if (removed)
                  Text('Kaldırıldı: ${c.removedReason ?? ''}', style: textTheme.bodySmall?.copyWith(color: GwColors.error)),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(tooltip: 'Yorumu kaldır', icon: const Icon(Icons.remove_circle_outline), onPressed: onRemove),
        ],
      ),
    );
  }
}
