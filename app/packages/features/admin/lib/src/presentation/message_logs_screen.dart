import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_message_logs.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

const _minReason = 10;
const _maxReason = 500;

const _notice = 'Yalnızca platform yöneticisi görür. Her arama ve her açılan sohbet, yazdığın gerekçeyle kayda geçer.';

extension on LogConversationKind {
  IconData get icon => switch (this) {
        LogConversationKind.direct => Icons.person_outline,
        LogConversationKind.group => Icons.groups_2_outlined,
        LogConversationKind.table => Icons.table_restaurant_outlined,
      };
}

String? _reasonError(String value) {
  final length = value.trim().length;
  if (length < _minReason) return 'Gerekçe en az $_minReason karakter olmalı.';
  if (length > _maxReason) return 'Gerekçe en fazla $_maxReason karakter olabilir.';
  return null;
}

/// Search a person's conversations by username (docs/ARCHITECTURE.md §3f, Mesaj kayıtları). Platform admin only.
class AdminMessageLogsScreen extends ConsumerStatefulWidget {
  const AdminMessageLogsScreen({super.key, this.initialUsername});

  /// Filled in when the page is opened from a user's page.
  final String? initialUsername;

  @override
  ConsumerState<AdminMessageLogsScreen> createState() => _AdminMessageLogsScreenState();
}

class _AdminMessageLogsScreenState extends ConsumerState<AdminMessageLogsScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _withUsername;
  late final TextEditingController _reason;
  LogConversationKind? _kind;

  @override
  void initState() {
    super.initState();
    final session = ref.read(messageLogSessionProvider);
    final last = session.search;
    _username = TextEditingController(text: widget.initialUsername ?? last?.username ?? '');
    _withUsername = TextEditingController(text: widget.initialUsername == null ? last?.withUsername ?? '' : '');
    _reason = TextEditingController(text: session.reason ?? '');
    _kind = widget.initialUsername == null ? last?.kind : null;
  }

  @override
  void dispose() {
    _username.dispose();
    _withUsername.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _search() {
    if (!(_form.currentState?.validate() ?? false)) return;
    String clean(String v) => v.trim().replaceFirst(RegExp('^@'), '');
    final other = clean(_withUsername.text);
    ref.read(messageLogSessionProvider.notifier).search(
          _reason.text.trim(),
          (username: clean(_username.text), withUsername: other.isEmpty ? null : other, kind: _kind, page: 1),
        );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(messageLogResultsProvider);
    final hasSearch = ref.watch(messageLogSessionProvider.select((s) => s.search != null));

    return AdminPage(
      title: 'Mesaj kayıtları',
      subtitle: 'Kullanıcıların birebir, grup ve küçük masa yazışmaları; silinen mesajların metni 180 gün saklanır.',
      children: [
        GwPanel(
          title: 'Kullanıcı ara',
          subtitle: _notice,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fields = [
                      TextFormField(
                        controller: _username,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Kullanıcı adı', prefixText: '@'),
                        validator: (v) => (v ?? '').trim().replaceFirst(RegExp('^@'), '').isEmpty ? 'Bir kullanıcı adı yaz.' : null,
                      ),
                      TextFormField(
                        controller: _withUsername,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'İkinci kullanıcı (isteğe bağlı)',
                          prefixText: '@',
                          helperText: 'Yalnızca ikisinin birlikte olduğu sohbetler gelir.',
                        ),
                      ),
                    ];
                    return constraints.maxWidth >= GwLayout.contentMaxWidth
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fields[0]),
                              const SizedBox(width: GwSpacing.md),
                              Expanded(child: fields[1]),
                            ],
                          )
                        : Column(children: [fields[0], const SizedBox(height: GwSpacing.md), fields[1]]);
                  },
                ),
                const SizedBox(height: GwSpacing.md),
                TextFormField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: _maxReason,
                  decoration: const InputDecoration(
                    labelText: 'Gerekçe',
                    hintText: 'Örn. 1234 numaralı taciz şikayetinin incelenmesi',
                  ),
                  validator: (v) => _reasonError(v ?? ''),
                ),
                const SizedBox(height: GwSpacing.sm),
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final (value, label) in <(LogConversationKind?, String)>[
                      (null, 'Tümü'),
                      for (final k in LogConversationKind.values) (k, k.label),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _kind == value,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _kind = value),
                      ),
                  ],
                ),
                const SizedBox(height: GwSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: GwButton(
                    label: 'Sohbetleri getir',
                    icon: Icons.manage_search,
                    isLoading: results.isLoading,
                    onPressed: _search,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GwSpacing.lg),
        if (hasSearch) _Results(results: results) else const SizedBox.shrink(),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.results});

  final AsyncValue<LogConversationPage?> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (results) {
      AsyncData(value: final page?) => GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GwSpacing.lg),
                child: _ResultsHeader(page: page),
              ),
              const Divider(),
              if (page.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                  child: GwEmptyState(
                    icon: Icons.forum_outlined,
                    message: 'Bu aramaya uygun sohbet yok.',
                    actionLabel: 'Kullanıcı sayfasını aç',
                    onAction: () => context.go(AdminRoutes.user(page.user.id)),
                  ),
                )
              else ...[
                for (final c in page.items) ...[_ConversationRow(conversation: c), const Divider()],
                PageFooter(
                  from: page.range.$1,
                  to: page.range.$2,
                  total: page.total,
                  noun: 'sohbet',
                  page: page.page,
                  pageCount: page.pageCount,
                  onPage: (p) => ref.read(messageLogSessionProvider.notifier).page(p),
                ),
              ],
            ],
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(messageLogResultsProvider)),
      _ => const GwPanel(
          child: Column(children: [
            GwSkeleton(height: GwSpacing.xl),
            SizedBox(height: GwSpacing.md),
            GwSkeleton(height: GwSpacing.xl),
          ]),
        ),
    };
  }
}

class _ResultsHeader extends ConsumerWidget {
  const _ResultsHeader({required this.page});

  final LogConversationPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = page.user;
    return Row(
      children: [
        GwAvatar(name: user.displayName, shape: GwAvatarShape.user, imageUrl: ref.watch(avatarUrlProvider(user.avatarPath))),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.label, style: textTheme.titleMedium),
              Text(
                page.withUser == null ? '${page.total} sohbet' : '${page.withUser!.label} ile ${page.total} ortak sohbet',
                style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
              ),
            ],
          ),
        ),
        GwButton(
          label: 'Kullanıcı sayfası',
          icon: Icons.person_search_outlined,
          variant: GwButtonVariant.text,
          onPressed: () => context.go(AdminRoutes.user(user.id)),
        ),
      ],
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation});

  final LogConversation conversation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = conversation;
    final meta = [
      c.kind.label,
      '${c.messageCount} mesaj',
      'kişinin ${c.targetMessageCount} mesajı',
      if (c.deletedCount > 0) '${c.deletedCount} silinmiş',
      if (c.lastMessageAt != null) 'son: ${formatDateTimeTr(c.lastMessageAt!)}' else 'mesaj yok',
    ].join(' · ');
    return InkWell(
      onTap: () => context.go(AdminRoutes.messageLog(c.id)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(GwSpacing.xs),
              decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
              child: Icon(c.kind.icon, color: GwColors.primary, size: GwSpacing.md + GwSpacing.xxs),
            ),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.xs),
            const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// One conversation's messages, oldest first, with older pages and a text search.
class AdminMessageLogScreen extends ConsumerStatefulWidget {
  const AdminMessageLogScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<AdminMessageLogScreen> createState() => _AdminMessageLogScreenState();
}

class _AdminMessageLogScreenState extends ConsumerState<AdminMessageLogScreen> {
  final _reasonForm = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _search = TextEditingController();

  LogConversationView? _view;
  List<LogMessage> _messages = const [];
  bool _hasOlder = false;
  bool _loading = false;
  bool _loadingOlder = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (ref.read(messageLogSessionProvider).reason != null) _load();
  }

  @override
  void dispose() {
    _reason.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final reason = ref.read(messageLogSessionProvider).reason;
    if (reason == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(adminMessageLogsRepositoryProvider).view(widget.conversationId, reason: reason, query: _query);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok(:final value):
          _view = value;
          _messages = value.messages;
          _hasOlder = value.hasOlder;
        case Err(:final failure):
          _error = failure.userMessage;
      }
    });
  }

  Future<void> _loadOlder() async {
    final reason = ref.read(messageLogSessionProvider).reason;
    if (reason == null || _messages.isEmpty) return;
    setState(() => _loadingOlder = true);
    final result = await ref
        .read(adminMessageLogsRepositoryProvider)
        .view(widget.conversationId, reason: reason, before: _messages.first.createdAt, query: _query);
    if (!mounted) return;
    setState(() => _loadingOlder = false);
    switch (result) {
      case Ok(:final value):
        setState(() {
          _messages = [...value.messages, ..._messages];
          _hasOlder = value.hasOlder;
        });
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  void _applySearch() {
    final query = _search.text.trim();
    if (query == _query) return;
    _query = query;
    _load();
  }

  void _openWithReason() {
    if (!(_reasonForm.currentState?.validate() ?? false)) return;
    ref.read(messageLogSessionProvider.notifier).setReason(_reason.text.trim());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final reason = ref.watch(messageLogSessionProvider.select((s) => s.reason));
    final view = _view;
    return AdminPage(
      breadcrumbs: const [('Mesaj kayıtları', AdminRoutes.messageLogs)],
      title: view?.title ?? 'Sohbet',
      children: [
        if (reason == null)
          GwPanel(
            title: 'Gerekçe gerekli',
            subtitle: _notice,
            child: Form(
              key: _reasonForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _reason,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: _maxReason,
                    decoration: const InputDecoration(labelText: 'Gerekçe'),
                    validator: (v) => _reasonError(v ?? ''),
                  ),
                  const SizedBox(height: GwSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GwButton(label: 'Sohbeti aç', icon: Icons.lock_open_outlined, onPressed: _openWithReason),
                  ),
                ],
              ),
            ),
          )
        else if (_error != null && view == null)
          GwErrorState(message: _error!, onRetry: _load)
        else if (view == null)
          const GwPanel(
            child: Column(children: [
              GwSkeleton(height: GwSpacing.xxl),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xxl),
            ]),
          )
        else ...[
          _ConversationHeader(view: view, reason: reason),
          const SizedBox(height: GwSpacing.lg),
          GwPanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(GwSpacing.md),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _applySearch(),
                    decoration: InputDecoration(
                      hintText: 'Sohbette ara (silinmiş mesajlar dahil)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? IconButton(tooltip: 'Ara', icon: const Icon(Icons.arrow_forward), onPressed: _applySearch)
                          : IconButton(
                              tooltip: 'Aramayı temizle',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _search.clear();
                                _applySearch();
                              },
                            ),
                    ),
                  ),
                ),
                const Divider(),
                if (_loading) const LinearProgressIndicator(),
                if (_hasOlder)
                  Padding(
                    padding: const EdgeInsets.all(GwSpacing.sm),
                    child: Center(
                      child: GwButton(
                        label: 'Daha eski mesajlar',
                        icon: Icons.expand_less,
                        variant: GwButtonVariant.secondary,
                        isLoading: _loadingOlder,
                        onPressed: _loadOlder,
                      ),
                    ),
                  ),
                if (_messages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwEmptyState(
                      icon: _query.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
                      message: _query.isEmpty ? 'Bu sohbette mesaj yok.' : 'Aramana uygun mesaj yok.',
                      actionLabel: _query.isEmpty ? 'Mesaj kayıtlarına dön' : 'Aramayı temizle',
                      onAction: _query.isEmpty
                          ? () => context.go(AdminRoutes.messageLogs)
                          : () {
                              _search.clear();
                              _applySearch();
                            },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(GwSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [for (final m in _messages) _MessageTile(message: m)],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ConversationHeader extends ConsumerWidget {
  const _ConversationHeader({required this.view, required this.reason});

  final LogConversationView view;
  final String reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final c = view.conversation;
    return GwPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GwBadge(c.kind.label, tone: GwBadgeTone.primary),
              Text('${c.messageCount} mesaj · açılış ${formatDateTimeTr(c.createdAt)}', style: secondary),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Text(c.kind == LogConversationKind.group ? 'Üyeler (${view.participants.length})' : 'Katılımcılar', style: textTheme.labelLarge),
          const SizedBox(height: GwSpacing.xs),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              for (final p in view.participants)
                ActionChip(
                  avatar: GwAvatar(
                    name: p.displayName,
                    shape: GwAvatarShape.user,
                    size: GwAvatarSize.sm,
                    imageUrl: ref.watch(avatarUrlProvider(p.avatarPath)),
                  ),
                  label: Text('@${p.username}'),
                  tooltip: 'Kullanıcının mesaj kayıtları',
                  onPressed: () => context.go(AdminRoutes.messageLogsOf(p.username)),
                ),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Text('Gerekçe: $reason', style: secondary),
        ],
      ),
    );
  }
}

class _MessageTile extends ConsumerWidget {
  const _MessageTile({required this.message});

  final LogMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final m = message;
    final sender = m.sender;
    return Container(
      margin: const EdgeInsets.only(bottom: GwSpacing.xs),
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: BoxDecoration(
        color: m.isDeleted ? GwColors.errorSoft : GwColors.surface,
        borderRadius: GwRadius.mdAll,
        border: const Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GwAvatar(
            name: sender?.displayName ?? '?',
            shape: GwAvatarShape.user,
            size: GwAvatarSize.sm,
            imageUrl: ref.watch(avatarUrlProvider(sender?.avatarPath)),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(sender?.label ?? 'Silinmiş hesap', style: textTheme.labelMedium),
                    Text(formatDateTimeTr(m.createdAt), style: secondary),
                    if (m.isDeleted)
                      GwBadge(
                        m.removedReason == null ? 'Gönderen sildi' : 'Moderasyonla kaldırıldı',
                        tone: GwBadgeTone.danger,
                      ),
                  ],
                ),
                const SizedBox(height: GwSpacing.xxs),
                if (m.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GwSpacing.xxs),
                    child: ClipRRect(
                      borderRadius: GwRadius.smAll,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: GwLayout.storyCardWidth, maxWidth: GwLayout.storyCardWidth),
                        child: Image.network(
                          m.imageUrl!,
                          fit: BoxFit.cover,
                          semanticLabel: 'Mesajdaki fotoğraf',
                          errorBuilder: (_, _, _) => Text('Fotoğraf yüklenemedi.', style: secondary),
                        ),
                      ),
                    ),
                  )
                else if (m.hadImage)
                  Text('[Fotoğraf vardı; silinen mesajların fotoğrafı saklanmaz]', style: secondary),
                if (m.body.isNotEmpty)
                  SelectableText(m.body, style: textTheme.bodyMedium)
                else if (m.isDeleted && !m.hadImage)
                  Text('Metin saklanmıyor (bu kayıt sisteminden önce silinmiş ya da 180 gün dolmuş).',
                      style: secondary?.copyWith(fontStyle: FontStyle.italic)),
                if (m.isDeleted) ...[
                  const SizedBox(height: GwSpacing.xxs),
                  Text(
                    [
                      'Silinme: ${formatDateTimeTr(m.deletedAt!)}',
                      if (m.removedReason != null) 'Gerekçe: ${m.removedReason}',
                      if (m.purgeAfter != null) 'Arşivden silinecek: ${formatDateTr(m.purgeAfter!)}',
                    ].join(' · '),
                    style: secondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
