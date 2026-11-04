import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:live/live.dart';
import 'package:matching/matching.dart';
import 'package:messaging/messaging.dart';
import 'package:moderation/moderation.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

import 'l10n.dart';

/// Feed pages open profiles and groups through the app (features stay independent).
final feedLinks = FeedLinks(
  openProfile: (context, username) => context.push(ProfileRoutes.user(username)),
  openGroup: (context, handle) => context.push(GroupRoutes.group(handle)),
  openEvent: (context, eventId) => context.push(EventRoutes.event(eventId)),
);

final notificationLinks = NotificationLinks(
  openProfile: (context, username) => context.push(ProfileRoutes.user(username)),
  openPost: (context, postId, {required comments}) =>
      context.push(comments ? FeedRoutes.comments(postId) : FeedRoutes.post(postId)),
  openFollowRequests: (context) => context.push(ProfileRoutes.followRequests),
  followButton: (context, actor) => FollowButton(
    userId: actor.id,
    username: actor.username,
    state: actor.iFollow
        ? FollowState.following
        : actor.requested
            ? FollowState.requested
            : FollowState.none,
    followsMe: true,
    compact: true,
  ),
  openLive: (context, liveId) => context.push(LiveRoutes.room(liveId)),
  openEvent: (context, eventId) => context.push(EventRoutes.event(eventId)),
  openGroupModeration: (context, handle) => context.push(ModerationRoutes.group(handle)),
  openSanctions: (context) => context.push(ModerationRoutes.mySanctions),
  openGoal: (context, goalId) => context.push(EventRoutes.goal(goalId)),
  openTeammates: (context) => context.push(ProfileRoutes.teammates),
  openMatches: (context) => context.push(MatchingRoutes.matches),
  openMatching: (context) => context.push(MatchingRoutes.home),
  openGroup: (context, handle) => context.push(GroupRoutes.group(handle)),
  openTonight: (context) => context.push(EventRoutes.tonight),
  openConversation: (context, id) => context.push(MessagingRoutes.chat(id)),
  openCallSettings: (context) => context.push(MessagingRoutes.callSettings),
);

Widget peopleResults(BuildContext context, String query, VoidCallback onClear) =>
    PeopleSearchResults(query: query, onClear: onClear);

/// Highlights and the post grid on a profile.
Widget profilePostsSection(BuildContext context, Profile profile, bool isOwn) => _ProfilePosts(profile: profile, isOwn: isOwn);

class _ProfilePosts extends ConsumerWidget {
  const _ProfilePosts({required this.profile, required this.isOwn});

  final Profile profile;
  final bool isOwn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The post count in the header comes from the profile feature.
    ref.listen(postsChangedProvider, (_, _) => ref.invalidate(profileSocialProvider(profile.id)));
    void create() => context.push(FeedRoutes.create);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GwSectionHeader(title: socialAppL10n.posts, actionLabel: isOwn ? socialAppL10n.newPost : null, onAction: create),
        HighlightsRow(userId: profile.id, isOwn: isOwn),
        PostsSection(
          source: UserPosts(profile.id),
          emptyMessage: isOwn ? socialAppL10n.noOwnPosts : socialAppL10n.noPosts,
          emptyAction: isOwn ? (label: socialAppL10n.shareFirstOwn, onPressed: create) : null,
        ),
      ],
    );
  }
}

/// The group's posts; every member shares from here (docs/ARCHITECTURE.md §3c; the server refuses a muted member).
Widget groupPostsSection(BuildContext context, Group group, MyMembership me) {
  final canPublish = me.isMember && !group.isSuspended;
  void create() => context.push(FeedRoutes.createFor(group.id));
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GwSectionHeader(title: socialAppL10n.posts, actionLabel: canPublish ? socialAppL10n.newPost : null, onAction: create),
      PostsSection(
        source: GroupPosts(group.id),
        emptyMessage: canPublish ? socialAppL10n.groupFirstPost : socialAppL10n.groupNoPosts,
        emptyAction: canPublish ? (label: socialAppL10n.shareFirstGroup, onPressed: create) : null,
      ),
    ],
  );
}
