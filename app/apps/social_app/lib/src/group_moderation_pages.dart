import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:moderation/moderation.dart';
import 'package:profile/profile.dart';

/// Moderation pages open profiles, posts and events through the app (features stay independent).
final moderationLinks = ModerationLinks(
  openProfile: (context, username) => context.push(ProfileRoutes.user(username)),
  openPost: (context, postId) => context.push(FeedRoutes.post(postId)),
  openEvent: (context, eventId) => context.push(EventRoutes.event(eventId)),
);

/// The moderation entry on the group page, for reports.review holders (docs/ARCHITECTURE.md §3e).
Widget groupModerationSection(BuildContext context, Group group, MyMembership me) {
  if (!me.can(GroupPermission.reviewReports)) return const SizedBox.shrink();
  return GroupModerationEntry(groupId: group.id, onOpen: () => context.push(ModerationRoutes.group(group.handle)));
}

/// "Disiplin dosyası aç" on the members screen.
void openCase(BuildContext context, Group group, GroupPerson person, {required bool canMute}) => showCaseSheet(
      context,
      groupId: group.id,
      subjectId: person.userId,
      subjectName: person.displayName,
      canMute: canMute,
    );

/// `/g/<handle>/moderation`: resolves the group, then the moderation desk.
class GroupModerationPage extends ConsumerWidget {
  const GroupModerationPage({super.key, required this.handle});

  final String handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(groupByHandleProvider(handle))) {
        AsyncData(:final value) => GroupModerationScreen(groupId: value.id, groupName: value.name, links: moderationLinks),
        AsyncError() => Scaffold(
            appBar: AppBar(),
            body: GxErrorState(
              message: 'Grup bulunamadı.',
              onRetry: () => ref.invalidate(groupByHandleProvider(handle)),
            ),
          ),
        _ => Scaffold(
            appBar: AppBar(),
            body: const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 3)),
          ),
      };
}
