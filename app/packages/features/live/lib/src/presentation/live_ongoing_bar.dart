import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_session.dart';
import 'providers.dart';
import 'routes.dart';

/// "Canlı yayındasın" above every page while the user is in a room but not looking at it.
/// Wraps the app's navigator; the tree stays the same whether the strip shows or not.
class LiveOngoingBar extends ConsumerWidget {
  const LiveOngoingBar({
    super.key,
    required this.routeChanges,
    required this.currentPath,
    required this.openLive,
    required this.child,
  });

  final Listenable routeChanges;
  final String Function() currentPath;
  final ValueChanged<String> openLive;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeLiveProvider);
    return ListenableBuilder(
      listenable: Listenable.merge([routeChanges, ?session]),
      builder: (context, _) {
        final visible = session != null && session.isActive && currentPath() != LiveRoutes.room(session.broadcastId);
        return Column(
          children: [
            if (visible) _Strip(session: session, onOpen: () => openLive(session.broadcastId)) else const SizedBox.shrink(),
            Expanded(child: MediaQuery.removePadding(context: context, removeTop: visible, child: child)),
          ],
        );
      },
    );
  }
}

class _Strip extends ConsumerWidget {
  const _Strip({required this.session, required this.onOpen});

  final LiveSession session;
  final VoidCallback onOpen;

  Future<void> _mic(BuildContext context, bool on) async {
    final error = await session.setMicrophone(on);
    if (error != null && context.mounted) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final title = ref.watch(liveBroadcastProvider(session.broadcastId)).value?.title ?? 'Canlı yayın';
    final connecting = session.state == LiveSessionState.connecting;
    final me = session.me;
    final onStage = me != null && me.role.onStage;

    return Material(
      color: GwColors.primarySoft,
      shape: const Border(bottom: GwBorders.hairline),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Canlı yayındasın: $title. Yayına dönmek için dokun.',
                excludeSemantics: true,
                child: InkWell(
                  onTap: onOpen,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.xxs),
                      child: Row(
                        children: [
                          const GwLiveBadge(),
                          const SizedBox(width: GwSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                                Text(
                                  connecting ? 'Yayına bağlanılıyor…' : 'Yayındasın · dönmek için dokun',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_up_rounded, color: GwColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // The strip sits above the navigator, where there is no overlay for tooltips.
            if (onStage)
              Semantics(
                button: true,
                label: me.mutedByModerator
                    ? 'Mikrofonunu yönetici kapattı'
                    : me.micOn
                        ? 'Mikrofonu kapat'
                        : 'Mikrofonu aç',
                excludeSemantics: true,
                child: IconButton(
                  onPressed: me.mutedByModerator ? null : () => _mic(context, !me.micOn),
                  icon: Icon(me.micOn ? Icons.mic_rounded : Icons.mic_off_rounded, color: me.micOn ? GwColors.primary : GwColors.textSecondary),
                ),
              ),
            const SizedBox(width: GwSpacing.xxs),
          ],
        ),
      ),
    );
  }
}
