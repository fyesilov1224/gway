import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:messaging/messaging.dart';

/// "Sesli görüşme talepleri" on the group page, for the owner and calls.manage holders (docs/ARCHITECTURE.md §8c).
Widget groupCallRequestsSection(BuildContext context, Group group, MyMembership me) {
  if (!me.can(GroupPermission.manageCalls) || group.isSuspended) return const SizedBox.shrink();
  return GroupCallRequestsEntry(groupId: group.id, onOpen: () => context.push('/g/${group.handle}/calls'));
}

/// `/g/<handle>/calls`: resolves the group, then its voice call requests.
class GroupCallRequestsPage extends ConsumerWidget {
  const GroupCallRequestsPage({super.key, required this.handle});

  final String handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(groupByHandleProvider(handle))) {
        AsyncData(:final value) => GroupCallRequestsScreen(groupId: value.id, groupName: value.name),
        AsyncError() => Scaffold(
            appBar: AppBar(),
            body: GwErrorState(message: 'Grup bulunamadı.', onRetry: () => ref.invalidate(groupByHandleProvider(handle))),
          ),
        _ => Scaffold(
            appBar: AppBar(),
            body: const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 3)),
          ),
      };
}
