import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_support.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'support_screen.dart';

/// One support message: conversation, reply box, status and who sent it.
class AdminTicketDetailScreen extends ConsumerWidget {
  const AdminTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(ticketDetailProvider(ticketId));
    const crumbs = [('Destek', AdminRoutes.support)];

    return switch (detail) {
      AsyncData(:final value) => AdminPage(breadcrumbs: crumbs, title: value.ticket.subject, children: [_Content(detail: value)]),
      AsyncError(error: NotFoundFailure()) => AdminPage(
          breadcrumbs: crumbs,
          title: 'Bulunamadı',
          children: [
            GwPanel(
              child: GwEmptyState(
                icon: Icons.search_off,
                message: 'Bu mesaj bulunamadı. Gönderenin hesabı silinmiş olabilir.',
                actionLabel: 'Destek listesine dön',
                onAction: () => context.go(AdminRoutes.support),
              ),
            ),
          ],
        ),
      AsyncError(:final error) => AdminPage(
          breadcrumbs: crumbs,
          children: [
            GwPanel(child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(ticketDetailProvider(ticketId)))),
          ],
        ),
      _ => const AdminPage(
          breadcrumbs: crumbs,
          children: [GwSkeleton(height: GwSpacing.xxl * 5, borderRadius: GwRadius.lgAll)],
        ),
    };
  }
}

class _Content extends ConsumerStatefulWidget {
  const _Content({required this.detail});

  final AdminTicketDetail detail;

  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content> {
  final _reply = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Result<void>> Function(AdminSupportRepository repo) action, {bool clearReply = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await action(ref.read(adminSupportRepositoryProvider));
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case Err(:final failure)) {
        _error = failure.userMessage;
      } else if (clearReply) {
        _reply.clear();
      }
    });
    ref
      ..invalidate(ticketDetailProvider(widget.detail.ticket.id))
      ..invalidate(ticketSearchProvider)
      ..invalidate(supportStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final t = d.ticket;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final textTheme = Theme.of(context).textTheme;

    final conversation = GwPanel(
      title: 'Yazışma',
      subtitle: '${d.messages.length} mesaj',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in d.messages) _Message(message: m, senderName: t.displayName ?? t.username ?? 'Kullanıcı'),
          const SizedBox(height: GwSpacing.sm),
          if (t.status == AdminSupportStatus.closed)
            const GwFormMessage('Mesaj kapatıldı. Yanıt yazmak için önce durumunu değiştir.', kind: GwFormMessageKind.info)
          else ...[
            TextField(
              controller: _reply,
              minLines: 3,
              maxLines: 8,
              maxLength: 4000,
              decoration: const InputDecoration(labelText: 'Yanıt', alignLabelWithHint: true, counterText: ''),
            ),
            const SizedBox(height: GwSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: GwButton(
                label: 'Yanıtla',
                icon: Icons.send_outlined,
                isLoading: _busy,
                onPressed: () {
                  final body = _reply.text.trim();
                  if (body.isNotEmpty) _run((r) => r.reply(t.id, body), clearReply: true);
                },
              ),
            ),
          ],
          if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
        ],
      ),
    );

    final info = GwPanel(
      title: 'Bilgiler',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SupportKindIcon(t.kind),
              const SizedBox(width: GwSpacing.sm),
              GwBadge(t.kind.label, tone: t.kind.tone),
            ],
          ),
          const SizedBox(height: GwSpacing.md),
          DropdownButtonFormField<AdminSupportStatus>(
            initialValue: t.status,
            decoration: const InputDecoration(labelText: 'Durum'),
            items: [for (final s in AdminSupportStatus.values) DropdownMenuItem(value: s, child: Text(s.label))],
            onChanged: _busy ? null : (s) => s == null || s == t.status ? null : _run((r) => r.setStatus(t.id, s)),
          ),
          const SizedBox(height: GwSpacing.md),
          Text('Gönderen', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
          InkWell(
            onTap: () => context.go(AdminRoutes.user(t.userId)),
            child: Text(
              t.username == null ? 'Silinmiş hesap' : '${t.displayName ?? ''} (@${t.username})',
              style: textTheme.bodyMedium?.copyWith(color: GwColors.primary),
            ),
          ),
          if (d.email != null) SelectableText(d.email!, style: textTheme.bodyMedium),
          if (t.groupId != null) ...[
            const SizedBox(height: GwSpacing.sm),
            Text('Grup', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
            InkWell(
              onTap: () => context.go(AdminRoutes.group(t.groupId!)),
              child: Text(
                '${t.groupName ?? ''}${d.groupHandle == null ? '' : ' (@${d.groupHandle})'}',
                style: textTheme.bodyMedium?.copyWith(color: GwColors.primary),
              ),
            ),
          ],
          const SizedBox(height: GwSpacing.sm),
          Text('Açıldı', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
          Text(formatDateTimeTr(t.createdAt), style: textTheme.bodyMedium),
        ],
      ),
    );

    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: conversation),
              const SizedBox(width: GwSpacing.lg),
              Expanded(flex: 2, child: info),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: GwSpacing.lg), conversation],
          );
  }
}

class _Message extends ConsumerWidget {
  const _Message({required this.message, required this.senderName});

  final AdminTicketMessage message;
  final String senderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final staff = message.fromStaff;
    return Container(
      margin: const EdgeInsets.only(bottom: GwSpacing.sm),
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: BoxDecoration(
        color: staff ? GwColors.primarySoft : GwColors.surface,
        borderRadius: GwRadius.lgAll,
        border: staff ? null : const Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            staff ? 'Ekip · ${message.authorName ?? 'Platform ekibi'}' : senderName,
            style: textTheme.labelMedium?.copyWith(color: staff ? GwColors.primary : GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.xxs),
          SelectableText(message.body, style: textTheme.bodyLarge),
          if (message.attachments.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [for (final path in message.attachments) _Attachment(path: path)],
            ),
          ],
          const SizedBox(height: GwSpacing.xxs),
          Text(formatDateTimeTr(message.createdAt), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Attachment extends ConsumerWidget {
  const _Attachment({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const size = GwSpacing.xxl * 2;
    final url = ref.watch(supportAttachmentUrlProvider(path)).value;
    if (url == null) return const GwSkeleton(width: size, height: size);
    return InkWell(
      borderRadius: GwRadius.mdAll,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(borderRadius: GwRadius.lgAll),
          child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
        ),
      ),
      child: ClipRRect(
        borderRadius: GwRadius.mdAll,
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.square(
            dimension: size,
            child: Icon(Icons.broken_image_outlined, color: GwColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
