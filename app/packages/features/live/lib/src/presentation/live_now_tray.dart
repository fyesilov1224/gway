import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'routes.dart';

/// "Şimdi canlı" on the home page: broadcasts of the user's groups as cards; nothing when none is live.
class LiveNowTray extends ConsumerWidget {
  const LiveNowTray({super.key});

  static const double _cardWidth = GxSpacing.xxl * 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(myLiveProvider).value ?? const [];
    if (live.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GxSectionHeader(title: 'Şimdi canlı'),
        SizedBox(
          height: GxAvatarSize.lg.dimension + GxSpacing.lg,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page),
            itemCount: live.length,
            separatorBuilder: (_, _) => const SizedBox(width: GxSpacing.sm),
            itemBuilder: (context, i) {
              final b = live[i];
              return Semantics(
                button: true,
                label: '${b.group.name} canlı yayında: ${b.title}',
                excludeSemantics: true,
                child: SizedBox(
                  width: _cardWidth,
                  child: GxCard(
                    radius: GxRadius.lgAll,
                    padding: const EdgeInsets.all(GxSpacing.sm),
                    onTap: () => context.push(LiveRoutes.room(b.id)),
                    child: Row(
                      children: [
                        GxAvatar(name: b.group.name, imageUrl: b.group.logoUrl, shape: GxAvatarShape.group, size: GxAvatarSize.lg),
                        const SizedBox(width: GxSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GxLiveBadge(),
                              const SizedBox(height: GxSpacing.xxs),
                              Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                              Text(b.group.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: GxColors.textSecondary),
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
