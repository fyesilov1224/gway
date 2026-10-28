import 'package:core/core.dart';

/// The viewer's side of a follow: Instagram's button states.
enum FollowState { none, requested, following }

/// Counts and relationship shown on a profile (`public.profile_social`).
class ProfileSocial {
  const ProfileSocial({
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isPrivate,
    required this.follow,
    required this.followsMe,
    required this.blockedByMe,
    required this.canView,
  });

  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isPrivate;
  final FollowState follow;
  final bool followsMe;
  final bool blockedByMe;

  /// Content (posts, stories, follow lists) is visible to the viewer.
  final bool canView;

  /// Mutual follow.
  bool get isFriend => follow == FollowState.following && followsMe;

  ProfileSocial copyWith({FollowState? follow, int? followerCount, bool? blockedByMe, bool? followsMe}) => ProfileSocial(
        postCount: postCount,
        followerCount: followerCount ?? this.followerCount,
        followingCount: followingCount,
        isPrivate: isPrivate,
        follow: follow ?? this.follow,
        followsMe: followsMe ?? this.followsMe,
        blockedByMe: blockedByMe ?? this.blockedByMe,
        canView: canView,
      );
}

/// A person in follower, following, request, search and suggestion lists.
class PersonSummary {
  const PersonSummary({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isPrivate = false,
    this.follow = FollowState.none,
    this.followsMe = false,
    this.mutualCount = 0,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isPrivate;
  final FollowState follow;
  final bool followsMe;

  /// People the viewer follows who follow this person (suggestions).
  final int mutualCount;
}

enum FollowList { followers, following }

abstract interface class SocialRepository {
  Future<Result<ProfileSocial>> social(String userId);

  /// Returns the new state: following for public accounts, requested for private ones.
  Future<Result<FollowState>> follow(String userId);

  /// Unfollows or withdraws a request.
  Future<Result<void>> unfollow(String userId);

  Future<Result<void>> acceptRequest(String userId);

  Future<Result<void>> rejectRequest(String userId);

  Future<Result<void>> removeFollower(String userId);

  Future<Result<void>> block(String userId);

  Future<Result<void>> unblock(String userId);

  Future<Result<List<PersonSummary>>> list(String userId, FollowList list);

  /// People waiting for the signed-in user's approval.
  Future<Result<List<PersonSummary>>> requests();

  Future<Result<List<PersonSummary>>> blocked();

  Future<Result<List<PersonSummary>>> search(String query);

  Future<Result<List<PersonSummary>>> suggestions();

  Future<Result<void>> setPrivate(bool isPrivate);

  /// Shows every group on the profile, not only to fellow members.
  Future<Result<void>> setGroupsPublic(bool value);
}
