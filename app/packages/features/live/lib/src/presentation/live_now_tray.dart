import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';

/// "Şimdi canlı" on the home page: broadcasts of the user's groups as cards; nothing when none is live.
class LiveNowTray extends ConsumerWidget {
  const LiveNowTray({super.key});

  static const double _cardWidth = GwSpacing.xxl * 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(myLiveProvider).value ?? const [];
    if (live.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GwSectionHeader(title: liveL10n.liveNow),
        SizedBox(
          height: GwAvatarSize.lg.dimension + GwSpacing.lg,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
            itemCount: live.length,
            separatorBuilder: (_, _) => const SizedBox(width: GwSpacing.sm),
            itemBuilder: (context, i) {
              final b = live[i];
              return Semantics(
                button: true,
                label: liveL10n.trayLabel(b.group.name, b.title),
                excludeSemantics: true,
                child: SizedBox(
                  width: _cardWidth,
                  child: GwCard(
                    radius: GwRadius.lgAll,
                    padding: const EdgeInsets.all(GwSpacing.sm),
                    onTap: () => context.push(LiveRoutes.room(b.id)),
                    child: Row(
                      children: [
                        GwAvatar(name: b.group.name, imageUrl: b.group.logoUrl, shape: GwAvatarShape.group, size: GwAvatarSize.lg),
                        const SizedBox(width: GwSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GwLiveBadge(),
                              const SizedBox(height: GwSpacing.xxs),
                              Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                              Text(b.group.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: GwColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
