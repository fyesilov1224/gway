import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
import '../l10n.dart';
import 'match_card_view.dart';
import 'match_sheets.dart';
import 'package_widgets.dart';
import 'providers.dart';
import 'routes.dart';

/// Opens the chat with a match; the app supplies the messaging route.
typedef OpenChat = void Function(BuildContext context, String conversationId);

/// The deck: people who share a group, one card at a time, swiped like a stack of photos
/// (docs/ARCHITECTURE.md §3g).
class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key, required this.openChat});

  final OpenChat openChat;

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  MatchMode? _mode;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myMatchProfileProvider);
    final status = ref.watch(matchStatusProvider).value;
    final filters = ref.watch(deckFiltersProvider);
    final hasProfile = profile.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(matchingL10n.matching),
        // Four actions at most, so the title never collides with them on a phone.
        actions: [
          if (hasProfile) ...[
            IconButton(
              tooltip: matchingL10n.admirers,
              icon: Badge(
                isLabelVisible: (status?.admirerCount ?? 0) > 0,
                label: Text('${status?.admirerCount ?? 0}'),
                child: const Icon(Icons.favorite_border_rounded),
              ),
              onPressed: () => context.push(MatchingRoutes.likes),
            ),
            IconButton(
              tooltip: matchingL10n.pkgReveal,
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => context.push(MatchingRoutes.matches),
            ),
            IconButton(
              tooltip: matchingL10n.packages,
              color: GwColors.primary,
              icon: Icon(status?.hasAnyPackage ?? false ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined),
              onPressed: () => context.push(MatchingRoutes.packages),
            ),
            PopupMenuButton<void>(
              tooltip: matchingL10n.more,
              icon: Badge(isLabelVisible: !filters.isEmpty, smallSize: GwSpacing.xs, child: const Icon(Icons.more_vert)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => status?.has(MatchFeature.unlimited) ?? false
                      ? showDeckFilters(context)
                      : showPackageSheet(context,
                          feature: MatchFeature.unlimited, reason: matchingL10n.filtersLocked),
                  child: ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(filters.isEmpty ? matchingL10n.filters : 'Filtreler (${filters.count})'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () => context.push(MatchingRoutes.profile),
                  child: ListTile(leading: const Icon(Icons.manage_accounts_outlined), title: Text(matchingL10n.myProfile)),
                ),
              ],
            ),
          ],
        ],
      ),
      body: GwReadingColumn(
        maxWidth: GwLayout.formMaxWidth,
        child: switch (profile) {
          AsyncData(value: null) => const _Intro(),
          AsyncData(:final value?) => _body(value),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myMatchProfileProvider)),
          _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 8)),
        },
      ),
    );
  }

  Widget _body(MatchProfile profile) {
    if (profile.suspendedAt(DateTime.now())) {
      return _Notice(
        icon: Icons.block_outlined,
        message: matchingL10n.suspended,
      );
    }
    if (!profile.hasEnoughPhotos) {
      return _Notice(
        icon: Icons.add_a_photo_outlined,
        message: matchingL10n.addPhotosToStart(matchMinPhotos),
        actionLabel: matchingL10n.addPhoto,
        onAction: () => context.push(MatchingRoutes.profile),
      );
    }
    if (profile.paused) {
      return _Notice(
        icon: Icons.pause_circle_outline,
        message: matchingL10n.paused,
        actionLabel: matchingL10n.continueAction,
        onAction: () async {
          final result = await ref.read(matchingRepositoryProvider).setPaused(false);
          if (!mounted) return;
          if (result case Err(:final failure)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
          }
          ref.invalidate(myMatchProfileProvider);
        },
      );
    }
    final modes = profile.modes;
    final mode = _mode != null && modes.contains(_mode) ? _mode! : modes.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, GwSpacing.sm),
      child: Column(
        children: [
          if (modes.length > 1) ...[
            SegmentedButton<MatchMode>(
              segments: [
                for (final m in MatchMode.values)
                  ButtonSegment(
                    value: m,
                    label: Text(m.label),
                    icon: Icon(m == MatchMode.friend ? Icons.people_outline : Icons.favorite_outline),
                  ),
              ],
              selected: {mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: GwSpacing.sm),
          ],
          Expanded(child: _Deck(key: ValueKey(mode), mode: mode, openChat: widget.openChat)),
        ],
      ),
    );
  }
}

class _Deck extends ConsumerStatefulWidget {
  const _Deck({super.key, required this.mode, required this.openChat});

  final MatchMode mode;
  final OpenChat openChat;

  @override
  ConsumerState<_Deck> createState() => _DeckState();
}

class _DeckState extends ConsumerState<_Deck> with SingleTickerProviderStateMixin {
  /// How far the top card is dragged; past [_threshold] it is swiped.
  Offset _drag = Offset.zero;
  static const _threshold = 110.0;

  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  Animation<Offset>? _flight;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _fly.addListener(() {
      if (_flight != null) setState(() => _drag = _flight!.value);
    });
  }

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  Future<void> _animateTo(Offset target, {Curve curve = Curves.easeOut}) async {
    _flight = Tween(begin: _drag, end: target).animate(CurvedAnimation(parent: _fly, curve: curve));
    await _fly.forward(from: 0);
    _flight = null;
  }

  SwipeKind? get _dragKind {
    if (_drag.dy < -_threshold / 2 && _drag.dy.abs() > _drag.dx.abs()) return SwipeKind.superLike;
    if (_drag.dx > 0) return SwipeKind.like;
    if (_drag.dx < 0) return SwipeKind.pass;
    return null;
  }

  double get _dragStrength => _dragKind == SwipeKind.superLike ? -_drag.dy / _threshold : _drag.dx.abs() / _threshold;

  /// Whether today's allowances let [kind] through; explains why not.
  bool _allowed(SwipeKind kind, MatchStatus? status) {
    if (status == null) return true;
    switch (kind) {
      case SwipeKind.like when status.likesLeft == 0:
        showPackageSheet(context, feature: MatchFeature.unlimited, reason: matchingL10n.likesOut);
        return false;
      case SwipeKind.superLike when status.superLikesLeft == 0:
        if (status.has(MatchFeature.superLike)) {
          _say(matchingL10n.supersOut);
        } else {
          showPackageSheet(context, feature: MatchFeature.superLike, reason: matchingL10n.superUsed);
        }
        return false;
      default:
        return true;
    }
  }

  Future<void> _swipe(MatchCard card, SwipeKind kind) async {
    if (_busy) return;
    if (!_allowed(kind, ref.read(matchStatusProvider).value)) {
      await _animateTo(Offset.zero, curve: Curves.elasticOut);
      return;
    }
    _busy = true;
    final width = MediaQuery.sizeOf(context).width;
    await _animateTo(switch (kind) {
      SwipeKind.like => Offset(width * 1.5, _drag.dy + GwSpacing.xl),
      SwipeKind.pass => Offset(-width * 1.5, _drag.dy + GwSpacing.xl),
      SwipeKind.superLike => Offset(_drag.dx, -MediaQuery.sizeOf(context).height),
    }, curve: Curves.easeIn);
    final pending = ref.read(deckProvider(widget.mode).notifier).swipe(card, kind);
    if (mounted) setState(() => _drag = Offset.zero);
    _busy = false;
    final result = await pending;
    if (!mounted) return;
    switch (result) {
      case Ok(value: SwipeOutcome(matched: true)):
        await showMatchDialog(context, card: card, onMessage: () => _openChat(card));
      case Ok():
        break;
      case Err(:final failure):
        _say(failure.userMessage);
    }
  }

  Future<void> _openChat(MatchCard card) async {
    final result = await ref.read(matchingRepositoryProvider).openChat(card.userId);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        widget.openChat(context, value);
      case Err(:final failure):
        _say(failure.userMessage);
    }
  }

  Future<void> _rewind(MatchStatus? status) async {
    if (!(status?.has(MatchFeature.unlimited) ?? false)) {
      await showPackageSheet(context, feature: MatchFeature.unlimited, reason: matchingL10n.rewindLocked);
      return;
    }
    final result = await ref.read(deckProvider(widget.mode).notifier).rewind();
    if (!mounted) return;
    switch (result) {
      case Ok(:final value) when value.mode != widget.mode:
        _say(matchingL10n.rewoundTo(value.mode.label));
      case Ok():
        break;
      case Err(:final failure):
        _say(failure.userMessage);
    }
  }

  Future<void> _boost(MatchStatus? status) async {
    final now = DateTime.now();
    if (status == null) return;
    if (!status.has(MatchFeature.boost)) {
      await showPackageSheet(context, feature: MatchFeature.boost, reason: matchingL10n.boostReason(status.boostMinutes));
      return;
    }
    if (status.boostingAt(now)) {
      _say(matchingL10n.boosting(status.boostEndsAt!.difference(now).inMinutes + 1));
      return;
    }
    if (status.boostUsedToday) {
      _say(matchingL10n.boostUsed);
      return;
    }
    final go = await confirmMatchAction(
      context,
      title: matchingL10n.boost,
      message: matchingL10n.boostBody(status.boostMinutes),
      confirmLabel: matchingL10n.boost,
    );
    if (!go || !mounted) return;
    final result = await ref.read(matchingRepositoryProvider).boost();
    if (!mounted) return;
    ref.invalidate(matchStatusProvider);
    _say(switch (result) {
      Ok(:final value) => matchingL10n.boosted(value.difference(DateTime.now()).inMinutes + 1),
      Err(:final failure) => failure.userMessage,
    });
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(deckProvider(widget.mode));
    final status = ref.watch(matchStatusProvider).value;
    final filters = ref.watch(deckFiltersProvider);
    final cards = deck.value ?? const <MatchCard>[];
    final top = cards.firstOrNull;

    final Widget stack = switch (deck) {
      AsyncData() when top == null => Center(
          child: SingleChildScrollView(
            child: GwEmptyState(
              icon: Icons.travel_explore_outlined,
              message: filters.isEmpty
                  ? matchingL10n.deckEmpty
                  : matchingL10n.deckEmptyFiltered,
              actionLabel: filters.isEmpty ? matchingL10n.refresh : matchingL10n.clearFilters,
              onAction: () => filters.isEmpty
                  ? ref.invalidate(deckProvider(widget.mode))
                  : ref.read(deckFiltersProvider.notifier).set(const MatchFilters()),
            ),
          ),
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(deckProvider(widget.mode))),
      AsyncData() => LayoutBuilder(builder: (context, size) => _cards(cards, size)),
      _ => const GwSkeleton(height: double.infinity),
    };

    return Column(
      children: [
        Expanded(child: stack),
        const SizedBox(height: GwSpacing.sm),
        _ActionBar(
          status: status,
          enabled: top != null && !_busy,
          onRewind: () => _rewind(status),
          onPass: () => _swipe(top!, SwipeKind.pass),
          onSuperLike: () => _swipe(top!, SwipeKind.superLike),
          onLike: () => _swipe(top!, SwipeKind.like),
          onBoost: () => _boost(status),
        ),
        if (status != null) ...[
          const SizedBox(height: GwSpacing.xs),
          Text(
            switch (status.likesLeft) {
              null => matchingL10n.allowanceUnlimited(status.superLikesLeft),
              0 => matchingL10n.allowanceOut,
              final n => matchingL10n.allowance(n, status.superLikesLeft),
            },
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _cards(List<MatchCard> cards, BoxConstraints size) {
    final top = cards.first;
    final progress = (_drag.distance / _threshold).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (cards.length > 1)
          Transform.scale(
            scale: 0.94 + 0.06 * progress,
            child: IgnorePointer(child: MatchCardView(key: ValueKey('next-${cards[1].userId}'), card: cards[1])),
          ),
        GestureDetector(
          onPanUpdate: _busy ? null : (d) => setState(() => _drag += d.delta),
          onPanEnd: _busy
              ? null
              : (d) {
                  final kind = _dragKind;
                  final fast = d.velocity.pixelsPerSecond.distance > 900;
                  if (kind != null && (_dragStrength >= 1 || fast && _dragStrength > 0.3)) {
                    _swipe(top, kind);
                  } else {
                    _animateTo(Offset.zero, curve: Curves.elasticOut);
                  }
                },
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              angle: _drag.dx / size.maxWidth * math.pi / 10,
              child: MatchCardView(
                key: ValueKey(top.userId),
                card: top,
                stamp: _dragKind,
                stampStrength: _dragStrength,
                onInfo: () => showMatchDetails(context, top),
                onMenu: (context, photo) => showCardMenu(context, ref, top, photoIndex: photo, afterBlock: () {
                  ref.invalidate(deckProvider(widget.mode));
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rewind · Pass · Super like · Like · Boost, as round buttons under the deck.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.status,
    required this.enabled,
    required this.onRewind,
    required this.onPass,
    required this.onSuperLike,
    required this.onLike,
    required this.onBoost,
  });

  final MatchStatus? status;
  final bool enabled;
  final VoidCallback onRewind;
  final VoidCallback onPass;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    final boosting = status?.boostingAt(DateTime.now()) ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RoundAction(icon: Icons.replay_rounded, color: GwColors.warning, tooltip: matchingL10n.undo, onPressed: onRewind),
        RoundAction(
          icon: Icons.close_rounded,
          color: swipeColor(SwipeKind.pass),
          tooltip: matchingL10n.pass,
          large: true,
          onPressed: enabled ? onPass : null,
        ),
        RoundAction(
          icon: Icons.star_rounded,
          color: swipeColor(SwipeKind.superLike),
          tooltip: matchingL10n.superLike,
          badge: status == null ? null : '${status!.superLikesLeft}',
          onPressed: enabled ? onSuperLike : null,
        ),
        RoundAction(
          icon: Icons.favorite_rounded,
          color: swipeColor(SwipeKind.like),
          tooltip: matchingL10n.like,
          large: true,
          onPressed: enabled ? onLike : null,
        ),
        RoundAction(
          icon: Icons.bolt_rounded,
          color: GwColors.primary,
          tooltip: matchingL10n.boost,
          filled: boosting,
          onPressed: onBoost,
        ),
      ],
    );
  }
}

/// A round, outlined action with a coloured icon; [filled] for an active state.
class RoundAction extends StatelessWidget {
  const RoundAction({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
    this.large = false,
    this.filled = false,
    this.badge,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool large;
  final bool filled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final size = large ? GwSpacing.xxl + GwSpacing.md : GwSpacing.xxl;
    final button = SizedBox.square(
      dimension: size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: large ? GwSpacing.xl : GwSpacing.lg,
        style: IconButton.styleFrom(
          backgroundColor: filled ? color : GwColors.background,
          foregroundColor: filled ? GwColors.onPrimary : color,
          disabledForegroundColor: color.withValues(alpha: 0.35),
          side: const BorderSide(color: GwColors.border),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon),
      ),
    );
    if (badge == null) return button;
    return Badge(label: Text(badge!), backgroundColor: color, child: button);
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: GwColors.primary),
              const SizedBox(width: GwSpacing.sm),
              Expanded(child: Text(text, style: textTheme.bodyMedium)),
            ],
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(GwSpacing.page),
      children: [
        GwCard(
          padding: const EdgeInsets.all(GwSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(matchingL10n.introTitle, style: textTheme.headlineSmall),
              const SizedBox(height: GwSpacing.md),
              point(Icons.groups_2_outlined, matchingL10n.intro1),
              point(Icons.swipe_rounded, matchingL10n.intro2),
              point(Icons.favorite_border_rounded, matchingL10n.intro3),
              point(Icons.people_outline, matchingL10n.intro4),
              point(Icons.lock_outline, matchingL10n.intro5),
              const SizedBox(height: GwSpacing.md),
              GwButton(label: matchingL10n.createMyProfile, expand: true, onPressed: () => context.push(MatchingRoutes.setup)),
              const SizedBox(height: GwSpacing.sm),
              Text(matchingL10n.adultsOnly, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(GwSpacing.page),
        child: GwCard(
          padding: const EdgeInsets.all(GwSpacing.lg),
          child: Column(
            children: [
              Icon(icon, size: GwSpacing.xxl, color: GwColors.primary),
              const SizedBox(height: GwSpacing.md),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              if (actionLabel != null) ...[
                const SizedBox(height: GwSpacing.md),
                GwButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      );
}
