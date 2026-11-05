import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n.dart';
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
    return _DeferredListenableBuilder(
      listenable: Listenable.merge([routeChanges, ?session]),
      builder: (context) {
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
    final title = ref.watch(liveBroadcastProvider(session.broadcastId)).value?.title ?? liveL10n.liveBroadcast;
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
                label: liveL10n.youAreLive(title),
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
                                  connecting ? liveL10n.connecting : liveL10n.inBroadcast,
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
                    ? liveL10n.micMutedByMod
                    : me.micOn
                        ? liveL10n.micOff
                        : liveL10n.micOn,
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

/// Like [ListenableBuilder], but applies a change on the next frame: the router announces its first route while the
/// app's first build is still running, and an immediate rebuild there fails the build-phase assertion.
class _DeferredListenableBuilder extends StatefulWidget {
  const _DeferredListenableBuilder({required this.listenable, required this.builder});

  final Listenable listenable;
  final WidgetBuilder builder;

  @override
  State<_DeferredListenableBuilder> createState() => _DeferredListenableBuilderState();
}

class _DeferredListenableBuilderState extends State<_DeferredListenableBuilder> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_changed);
  }

  @override
  void didUpdateWidget(_DeferredListenableBuilder old) {
    super.didUpdateWidget(old);
    if (old.listenable != widget.listenable) {
      old.listenable.removeListener(_changed);
      widget.listenable.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_changed);
    super.dispose();
  }

  var _pending = false;

  void _changed() {
    if (_pending) return;
    _pending = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _pending = false;
        if (mounted) setState(() {});
      })
      ..ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
