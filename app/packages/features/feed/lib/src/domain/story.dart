import 'package:core/core.dart';

import 'post.dart';

class Story {
  const Story({
    required this.id,
    required this.author,
    required this.media,
    required this.createdAt,
    required this.expiresAt,
    this.seen = false,
  });

  final String id;
  final PostAuthor author;
  final PostMedia media;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool seen;

  bool isActive(DateTime now) => expiresAt.isAfter(now);

  /// Shown for this long; videos for their own length.
  Duration get displayDuration => media.duration ?? const Duration(seconds: 5);
}

/// One ring in the story bar.
class StoryRing {
  const StoryRing({required this.userId, required this.username, this.avatarUrl, required this.hasUnseen, required this.isMine});

  final String userId;
  final String username;
  final String? avatarUrl;
  final bool hasUnseen;
  final bool isMine;
}

class Highlight {
  const Highlight({required this.id, required this.ownerId, required this.title, this.cover, this.storyCount = 0});

  final String id;
  final String ownerId;
  final String title;

  /// The newest story's media.
  final PostMedia? cover;
  final int storyCount;
}

class StoryViewer {
  const StoryViewer({required this.person, required this.viewedAt});

  final PostAuthor person;
  final DateTime viewedAt;
}

abstract interface class StoryRepository {
  /// The user and the people they follow with active stories; the user first, then unseen.
  Future<Result<List<StoryRing>>> tray();

  /// A user's active stories, oldest first.
  Future<Result<List<Story>>> active(String userId);

  /// All of the signed-in user's stories, newest first (expired ones too).
  Future<Result<List<Story>>> archive();

  Future<Result<void>> create(NewMedia media);

  Future<Result<void>> delete(Story story);

  Future<Result<void>> markSeen(String storyId);

  Future<Result<List<StoryViewer>>> viewers(String storyId);

  Future<Result<List<Highlight>>> highlights(String userId);

  /// Stories of a highlight, oldest first.
  Future<Result<List<Story>>> highlightStories(String highlightId);

  Future<Result<String>> createHighlight(String title, List<String> storyIds);

  Future<Result<void>> renameHighlight(String id, String title);

  Future<Result<void>> deleteHighlight(String id);

  Future<Result<void>> addToHighlight(String id, List<String> storyIds);

  Future<Result<void>> removeFromHighlight(String id, String storyId);
}
