import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:feed/feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';
import 'package:live/live.dart';
import 'package:moderation/moderation.dart';
import 'package:notifications/notifications.dart';
import 'package:profile/profile.dart';

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
        GxSectionHeader(title: 'Gönderiler', actionLabel: isOwn ? 'Yeni gönderi' : null, onAction: create),
        HighlightsRow(userId: profile.id, isOwn: isOwn),
        PostsSection(
          source: UserPosts(profile.id),
          emptyMessage: isOwn ? 'Henüz gönderi paylaşmadın. İlk fotoğrafını ya da videonu paylaş.' : 'Henüz gönderi yok.',
          emptyAction: isOwn ? (label: 'İlk gönderini paylaş', onPressed: create) : null,
        ),
      ],
    );
  }
}

/// The group's posts; publishers (owner, Yönetici) can share from here.
Widget groupPostsSection(BuildContext context, Group group, MyMembership me) {
  final canPublish = me.can(GroupPermission.publishPosts) && !group.isSuspended;
  void create() => context.push(FeedRoutes.createFor(group.id));
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GxSectionHeader(title: 'Gönderiler', actionLabel: canPublish ? 'Yeni gönderi' : null, onAction: create),
      PostsSection(
        source: GroupPosts(group.id),
        emptyMessage: canPublish ? 'Grup adına ilk gönderiyi sen paylaş.' : 'Bu grup henüz gönderi paylaşmadı.',
        emptyAction: canPublish ? (label: 'İlk gönderiyi paylaş', onPressed: create) : null,
      ),
    ],
  );
}
