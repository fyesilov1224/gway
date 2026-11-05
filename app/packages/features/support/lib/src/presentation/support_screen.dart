import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/support.dart';
import '../l10n.dart';
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
      appBar: AppBar(title: Text(supportL10n.supportTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(SupportRoutes.create()),
        icon: const Icon(Icons.edit_outlined),
        label: Text(supportL10n.newMessage),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTicketsProvider),
            child: switch (tickets) {
              AsyncData(:final value) when value.isEmpty => ListView(
                  children: [
                    const SizedBox(height: GwSpacing.xxl),
                    GwEmptyState(
                      icon: Icons.support_agent_outlined,
                      message: supportL10n.emptyIntro,
                      actionLabel: supportL10n.newMessage,
                      onAction: () => context.push(SupportRoutes.create()),
                    ),
                  ],
                ),
              AsyncData(:final value) => ListView.separated(
                  padding: const EdgeInsets.only(bottom: GwSpacing.xxl * 2),
                  itemCount: value.length + 1,
                  separatorBuilder: (_, i) => i == 0 ? const SizedBox.shrink() : const Divider(),
                  itemBuilder: (context, i) => i == 0
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.xs),
                          child: Text(
                            supportL10n.listIntro,
                            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                          ),
                        )
                      : _TicketRow(ticket: value[i - 1]),
                ),
              AsyncError(:final error) => GwErrorState(
                  message: userMessageOf(error),
                  onRetry: () => ref.invalidate(myTicketsProvider),
                ),
              _ => const Padding(
                  padding: EdgeInsets.all(GwSpacing.md),
                  child: Column(children: [
                    GwSkeleton(height: GwSpacing.xxl),
                    SizedBox(height: GwSpacing.md),
                    GwSkeleton(height: GwSpacing.xxl),
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
    final meta = [ticket.kind.label, ?ticket.groupName, formatDate(ticket.lastMessageAt)].join(' · ');
    return InkWell(
      onTap: () => context.push(SupportRoutes.ticket(ticket.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
        child: Row(
          children: [
            SupportKindIcon(ticket.kind),
            const SizedBox(width: GwSpacing.sm),
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
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SupportStatusBadge(ticket.status),
                if (ticket.hasUnreadReply) ...[
                  const SizedBox(height: GwSpacing.xxs),
                  GwBadge(supportL10n.newReply, tone: GwBadgeTone.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
