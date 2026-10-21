import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/support.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// The user's messages to the platform team, with status and unread replies.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(myTicketsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Destek ve geri bildirim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(SupportRoutes.create()),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Yeni mesaj'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GxLayout.contentMaxWidth),
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTicketsProvider),
            child: switch (tickets) {
              AsyncData(:final value) when value.isEmpty => ListView(
                  children: [
                    const SizedBox(height: GxSpacing.xxl),
                    GxEmptyState(
                      icon: Icons.support_agent_outlined,
                      message: 'Bir sorun, talep ya da istek için platform ekibine yazabilirsin.',
                      actionLabel: 'Yeni mesaj',
                      onAction: () => context.push(SupportRoutes.create()),
                    ),
                  ],
                ),
              AsyncData(:final value) => ListView.separated(
                  padding: const EdgeInsets.only(bottom: GxSpacing.xxl * 2),
                  itemCount: value.length + 1,
                  separatorBuilder: (_, i) => i == 0 ? const SizedBox.shrink() : const Divider(),
                  itemBuilder: (context, i) => i == 0
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
                          child: Text(
                            'Mesajların platform ekibine iletilir; yanıtları ve durumlarını buradan izleyebilirsin.',
                            style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                          ),
                        )
                      : _TicketRow(ticket: value[i - 1]),
                ),
              AsyncError(:final error) => GxErrorState(
                  message: userMessageOf(error),
                  onRetry: () => ref.invalidate(myTicketsProvider),
                ),
              _ => const Padding(
                  padding: EdgeInsets.all(GxSpacing.md),
                  child: Column(children: [
                    GxSkeleton(height: GxSpacing.xxl),
                    SizedBox(height: GxSpacing.md),
                    GxSkeleton(height: GxSpacing.xxl),
                  ]),
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meta = [ticket.kind.label, ?ticket.groupName, formatDateTr(ticket.lastMessageAt)].join(' · ');
    return InkWell(
      onTap: () => context.push(SupportRoutes.ticket(ticket.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
        child: Row(
          children: [
            SupportKindIcon(ticket.kind),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(fontWeight: ticket.hasUnreadReply ? FontWeight.w700 : null),
                  ),
                  Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GxSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SupportStatusBadge(ticket.status),
                if (ticket.hasUnreadReply) ...[
                  const SizedBox(height: GxSpacing.xxs),
                  const GxBadge('Yeni yanıt', tone: GxBadgeTone.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
