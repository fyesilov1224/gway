import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/matching.dart';
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
        title: const Text('Eşleşme'),
        // Four actions at most, so the title never collides with them on a phone.
        actions: [
          if (hasProfile) ...[
            IconButton(
              tooltip: 'Seni beğenenler',
              icon: Badge(
                isLabelVisible: (status?.admirerCount ?? 0) > 0,
                label: Text('${status?.admirerCount ?? 0}'),
                child: const Icon(Icons.favorite_border_rounded),
              ),
              onPressed: () => context.push(MatchingRoutes.likes),
            ),
            IconButton(
              tooltip: 'Eşleşmelerim',
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => context.push(MatchingRoutes.matches),
            ),
            IconButton(
              tooltip: 'Paketler',
              color: GxColors.primary,
              icon: Icon(status?.hasAnyPackage ?? false ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined),
              onPressed: () => context.push(MatchingRoutes.packages),
            ),
            PopupMenuButton<void>(
              tooltip: 'Diğer',
              icon: Badge(isLabelVisible: !filters.isEmpty, smallSize: GxSpacing.xs, child: const Icon(Icons.more_vert)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => status?.has(MatchFeature.unlimited) ?? false
                      ? showDeckFilters(context)
                      : showPackageSheet(context,
                          feature: MatchFeature.unlimited, reason: 'Yaş, il ve ilgi alanına göre filtrelemek Sınırsız Beğeni paketiyle açılır.'),
                  child: ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(filters.isEmpty ? 'Filtreler' : 'Filtreler (${filters.count})'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () => context.push(MatchingRoutes.profile),
                  child: const ListTile(leading: Icon(Icons.manage_accounts_outlined), title: Text('Eşleşme profilim')),
                ),
              ],
            ),
          ],
        ],
      ),
      body: GxReadingColumn(
        maxWidth: GxLayout.formMaxWidth,
        child: switch (profile) {
          AsyncData(value: null) => const _Intro(),
          AsyncData(:final value?) => _body(value),
          AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myMatchProfileProvider)),
          _ => const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 8)),
        },
      ),
    );
  }

  Widget _body(MatchProfile profile) {
    if (profile.suspendedAt(DateTime.now())) {
      return const _Notice(
        icon: Icons.block_outlined,
        message: 'Eşleşme profilin platform ekibi tarafından kapatıldı. Ayrıntılar için Destek\'e yazabilirsin.',
      );
    }
    if (!profile.hasEnoughPhotos) {
      return _Notice(
        icon: Icons.add_a_photo_outlined,
        message: 'Kartının görünmesi ve keşfetmeye başlaman için en az $matchMinPhotos fotoğraf ekle.',
        actionLabel: 'Fotoğraf ekle',
        onAction: () => context.push(MatchingRoutes.profile),
      );
    }
    if (profile.paused) {
      return _Notice(
        icon: Icons.pause_circle_outline,
        message: 'Profilin duraklatıldı; kimse seni görmüyor. Eşleşmelerin ve sohbetlerin duruyor.',
        actionLabel: 'Devam et',
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
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.xs, GxSpacing.page, GxSpacing.sm),
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
            const SizedBox(height: GxSpacing.sm),
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
        showPackageSheet(context, feature: MatchFeature.unlimited, reason: 'Bugünkü ücretsiz beğenilerin bitti. Sınırsız Beğeni ile istediğin kadar beğen.');
        return false;
      case SwipeKind.superLike when status.superLikesLeft == 0:
        if (status.has(MatchFeature.superLike)) {
          _say('Bugünkü süper beğenilerin bitti. Yarın yenilenir.');
        } else {
          showPackageSheet(context, feature: MatchFeature.superLike, reason: 'Bugünkü süper beğenini kullandın. Süper Beğeni paketiyle her gün 5 tane.');
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
      SwipeKind.like => Offset(width * 1.5, _drag.dy + GxSpacing.xl),
      SwipeKind.pass => Offset(-width * 1.5, _drag.dy + GxSpacing.xl),
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
      await showPackageSheet(context, feature: MatchFeature.unlimited, reason: 'Yanlışlıkla geçtiğin kişiyi geri getirmek Sınırsız Beğeni paketiyle açılır.');
      return;
    }
    final result = await ref.read(deckProvider(widget.mode).notifier).rewind();
    if (!mounted) return;
    switch (result) {
      case Ok(:final value) when value.mode != widget.mode:
        _say('Son geçtiğin kişi ${value.mode.label} destesine geri döndü.');
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
      await showPackageSheet(context, feature: MatchFeature.boost, reason: 'Öne çıkınca ${status.boostMinutes} dakika boyunca destelerin en başında görünürsün.');
      return;
    }
    if (status.boostingAt(now)) {
      _say('Öne çıkıyorsun. ${status.boostEndsAt!.difference(now).inMinutes + 1} dakika kaldı.');
      return;
    }
    if (status.boostUsedToday) {
      _say('Bugünkü öne çıkma hakkını kullandın. Yarın yenilenir.');
      return;
    }
    final go = await confirmMatchAction(
      context,
      title: 'Öne çık',
      message: '${status.boostMinutes} dakika boyunca ortak gruplarındaki kişilerin destesinde en başta görünürsün. Günde bir kez kullanılır.',
      confirmLabel: 'Öne çık',
    );
    if (!go || !mounted) return;
    final result = await ref.read(matchingRepositoryProvider).boost();
    if (!mounted) return;
    ref.invalidate(matchStatusProvider);
    _say(switch (result) {
      Ok(:final value) => 'Öne çıktın! ${value.difference(DateTime.now()).inMinutes + 1} dakika boyunca en baştasın.',
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
            child: GxEmptyState(
              icon: Icons.travel_explore_outlined,
              message: filters.isEmpty
                  ? 'Şimdilik gösterecek kimse kalmadı. Yeni gruplara katıldıkça ve insanlar eşleşmeyi açtıkça burası dolar.'
                  : 'Filtrelerine uyan kimse kalmadı. Filtreleri genişletmeyi dene.',
              actionLabel: filters.isEmpty ? 'Yenile' : 'Filtreleri temizle',
              onAction: () => filters.isEmpty
                  ? ref.invalidate(deckProvider(widget.mode))
                  : ref.read(deckFiltersProvider.notifier).set(const MatchFilters()),
            ),
          ),
        ),
      AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(deckProvider(widget.mode))),
      AsyncData() => LayoutBuilder(builder: (context, size) => _cards(cards, size)),
      _ => const GxSkeleton(height: double.infinity),
    };

    return Column(
      children: [
        Expanded(child: stack),
        const SizedBox(height: GxSpacing.sm),
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
          const SizedBox(height: GxSpacing.xs),
          Text(
            switch (status.likesLeft) {
              null => 'Sınırsız beğeni · ${status.superLikesLeft} süper beğeni hakkın var.',
              0 => 'Bugünkü beğenilerin bitti; yarın yenilenir.',
              final n => 'Bugün $n beğeni ve ${status.superLikesLeft} süper beğeni hakkın var.',
            },
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
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
        RoundAction(icon: Icons.replay_rounded, color: GxColors.warning, tooltip: 'Geri al', onPressed: onRewind),
        RoundAction(
          icon: Icons.close_rounded,
          color: swipeColor(SwipeKind.pass),
          tooltip: 'Geç',
          large: true,
          onPressed: enabled ? onPass : null,
        ),
        RoundAction(
          icon: Icons.star_rounded,
          color: swipeColor(SwipeKind.superLike),
          tooltip: 'Süper beğen',
          badge: status == null ? null : '${status!.superLikesLeft}',
          onPressed: enabled ? onSuperLike : null,
        ),
        RoundAction(
          icon: Icons.favorite_rounded,
          color: swipeColor(SwipeKind.like),
          tooltip: 'Beğen',
          large: true,
          onPressed: enabled ? onLike : null,
        ),
        RoundAction(
          icon: Icons.bolt_rounded,
          color: GxColors.primary,
          tooltip: 'Öne çık',
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
    final size = large ? GxSpacing.xxl + GxSpacing.md : GxSpacing.xxl;
    final button = SizedBox.square(
      dimension: size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: large ? GxSpacing.xl : GxSpacing.lg,
        style: IconButton.styleFrom(
          backgroundColor: filled ? color : GxColors.background,
          foregroundColor: filled ? GxColors.onPrimary : color,
          disabledForegroundColor: color.withValues(alpha: 0.35),
          side: const BorderSide(color: GxColors.border),
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
          padding: const EdgeInsets.only(bottom: GxSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: GxColors.primary),
              const SizedBox(width: GxSpacing.sm),
              Expanded(child: Text(text, style: textTheme.bodyMedium)),
            ],
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(GxSpacing.page),
      children: [
        GxCard(
          padding: const EdgeInsets.all(GxSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ortak gruplarından yeni insanlarla tanış', style: textTheme.headlineSmall),
              const SizedBox(height: GxSpacing.md),
              point(Icons.groups_2_outlined, 'Yalnızca üye olduğun ya da takip ettiğin gruplardaki, eşleşmeyi açmış kişileri görürsün.'),
              point(Icons.swipe_rounded, 'Kartı sağa kaydır beğen, sola kaydır geç, yukarı kaydır süper beğen.'),
              point(Icons.favorite_border_rounded, 'İkiniz de birbirinizi beğenince eşleşirsiniz ve sohbet hemen açılır.'),
              point(Icons.people_outline, 'Arkadaş ve Sevgili ayrı modlardır; istediğini ya da ikisini seçersin.'),
              point(Icons.lock_outline, 'Profilin yalnızca eşleşmeyi açanlara görünür. İstediğin an duraklatır ya da tamamen silersin.'),
              const SizedBox(height: GxSpacing.md),
              GxButton(label: 'Eşleşme profilimi oluştur', expand: true, onPressed: () => context.push(MatchingRoutes.setup)),
              const SizedBox(height: GxSpacing.sm),
              Text('Eşleşme 18 yaşından büyükler içindir.', style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
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
        padding: const EdgeInsets.all(GxSpacing.page),
        child: GxCard(
          padding: const EdgeInsets.all(GxSpacing.lg),
          child: Column(
            children: [
              Icon(icon, size: GxSpacing.xxl, color: GxColors.primary),
              const SizedBox(height: GxSpacing.md),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              if (actionLabel != null) ...[
                const SizedBox(height: GxSpacing.md),
                GxButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      );
}
