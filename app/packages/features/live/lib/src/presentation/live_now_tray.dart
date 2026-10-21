import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'routes.dart';

/// Live broadcasts of the user's groups, above the story tray; nothing when none is live.
class LiveNowTray extends ConsumerWidget {
  const LiveNowTray({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(myLiveProvider).value ?? const [];
    if (live.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    const avatar = GxAvatarSize.lg;

    return SizedBox(
      height: avatar.dimension + GxSpacing.xxl + GxSpacing.xs,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page, vertical: GxSpacing.xs),
        itemCount: live.length,
        separatorBuilder: (_, _) => const SizedBox(width: GxSpacing.md),
        itemBuilder: (context, i) {
          final b = live[i];
          return Semantics(
            button: true,
            label: '${b.group.name} canlı yayında: ${b.title}',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: GxRadius.mdAll,
              onTap: () => context.push(LiveRoutes.room(b.id)),
              child: SizedBox(
                width: avatar.dimension + GxSpacing.md,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        GxAvatar(name: b.group.name, imageUrl: b.group.logoUrl, shape: GxAvatarShape.group, size: avatar),
                        const Positioned(bottom: -GxSpacing.xs, child: GxLiveBadge()),
                      ],
                    ),
                    const SizedBox(height: GxSpacing.sm),
                    Text(b.group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
