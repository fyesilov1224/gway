import 'package:core/core.dart';

class Profile {
  const Profile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.createdAt,
    this.avatarUrl,
    this.coverUrl,
    this.usernameChangedAt,
    this.isPrivate = false,
    this.groupsPublic = false,
  });

  static const usernameChangeInterval = Duration(days: 30);

  final String id;
  final String username;
  final String displayName;
  final String bio;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? coverUrl;
  final DateTime? usernameChangedAt;

  /// Content is shown to approved followers only (docs/ARCHITECTURE.md §3c).
  final bool isPrivate;

  /// Every membership is shown on the profile; otherwise only to fellow members (docs/ARCHITECTURE.md §3b).
  final bool groupsPublic;

  /// When the username may change again; null if it can change now.
  DateTime? usernameLockedUntil(DateTime now) {
    final next = usernameChangedAt?.add(usernameChangeInterval);
    return next != null && next.isAfter(now) ? next : null;
  }
}

enum ProfileImage {
  avatar('avatars'),
  cover('covers');

  const ProfileImage(this.bucket);

  final String bucket;
}

class ProfileDraft {
  const ProfileDraft({
    required this.username,
    required this.displayName,
    this.bio = '',
    this.avatar,
    this.interests = const [],
  });

  final String username;
  final String displayName;
  final String bio;
  final ImageUpload? avatar;
  final List<String> interests;
}

abstract interface class ProfileRepository {
  /// The signed-in user's profile, or null before onboarding.
  Future<Result<Profile?>> mine();

  Future<Result<Profile>> byUsername(String username);

  Future<Result<bool>> isUsernameAvailable(String username);

  Future<Result<void>> create(ProfileDraft draft);

  Future<Result<void>> update({
    required String username,
    required String displayName,
    required String bio,
  });

  /// Uploads the image, points the profile at it and removes the old file.
  Future<Result<void>> setImage(ProfileImage kind, ImageUpload upload);

  Future<Result<void>> removeImage(ProfileImage kind);

  Future<Result<List<String>>> interests(String userId);

  Future<Result<void>> setInterests(List<String> slugs);

  /// The end of the user's suspension, or null when not suspended (docs/ARCHITECTURE.md §3a). The reason is not shown.
  Future<Result<DateTime?>> suspendedUntil(String userId);
}
