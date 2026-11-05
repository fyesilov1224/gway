import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:moderation/moderation.dart';
import 'package:profile/profile.dart';

import 'l10n.dart';

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

/// "Disiplin dosyası aç" on the members screen; members.ban holders may ban there without a vote.
void openCase(BuildContext context, Group group, GroupPerson person, {required bool canMute, required bool canBan}) => showCaseSheet(
      context,
      groupId: group.id,
      subjectId: person.userId,
      subjectName: person.displayName,
      canMute: canMute,
      canBan: canBan,
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
            body: GwErrorState(
              message: socialAppL10n.groupNotFound,
              onRetry: () => ref.invalidate(groupByHandleProvider(handle)),
            ),
          ),
        _ => Scaffold(
            appBar: AppBar(),
            body: const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 3)),
          ),
      };
}
