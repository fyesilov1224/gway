import 'dart:typed_data';

import 'package:core/core.dart';

import 'media_crop.dart';

enum MediaKind {
  image,
  video;

  static MediaKind parse(Object? value) => value == 'video' ? video : image;
}

/// One photo or video of a post or story, with public URLs.
class PostMedia {
  const PostMedia({
    required this.kind,
    required this.url,
    required this.width,
    required this.height,
    this.duration,
    this.posterUrl,
    this.thumbUrl,
  });

  final MediaKind kind;
  final String url;
  final int width;
  final int height;
  final Duration? duration;
  final String? posterUrl;

  /// Small copy of a photo, for grids and previews.
  final String? thumbUrl;

  double get aspectRatio => width / height;

  /// A still picture for small previews; null for a video without a cover.
  String? get previewUrl => kind == MediaKind.image ? thumbUrl ?? url : posterUrl;
}

/// How tall the feed shows a post: the first media's ratio, kept between 4:5 and 1.91:1.
double feedAspectRatio(List<PostMedia> media) => media.isEmpty ? 1 : clampFeedRatio(media.first.aspectRatio);

/// A person shown next to content.
class PostAuthor {
  const PostAuthor({required this.id, required this.username, required this.displayName, this.avatarUrl});

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
}

class PostGroup {
  const PostGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

class Post {
  const Post({
    required this.id,
    required this.caption,
    required this.createdAt,
    required this.media,
    this.editedAt,
    this.author,
    this.group,
    this.commentsDisabled = false,
    this.hideLikeCount = false,
    this.likeCount,
    this.commentCount = 0,
    this.liked = false,
    this.saved = false,
    this.canManage = false,
  });

  final String id;
  final String caption;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// The user, or for group posts the publishing manager (null if their account is gone).
  final PostAuthor? author;

  /// Set for group posts, which are shown under the group's name.
  final PostGroup? group;
  final List<PostMedia> media;
  final bool commentsDisabled;
  final bool hideLikeCount;

  /// Null when the author hid it from others.
  final int? likeCount;
  final int commentCount;
  final bool liked;
  final bool saved;

  /// The viewer may edit and delete it (author, or the group's publishers).
  final bool canManage;

  Post copyWith({
    bool? liked,
    int? likeCount,
    bool? saved,
    int? commentCount,
    String? caption,
    bool? commentsDisabled,
    bool? hideLikeCount,
  }) =>
      Post(
        id: id,
        caption: caption ?? this.caption,
        createdAt: createdAt,
        editedAt: editedAt,
        author: author,
        group: group,
        media: media,
        commentsDisabled: commentsDisabled ?? this.commentsDisabled,
        hideLikeCount: hideLikeCount ?? this.hideLikeCount,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
        canManage: canManage,
      );
}

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
    this.parentId,
    this.likeCount = 0,
    this.liked = false,
    this.replies = const [],
  });

  final String id;
  final String postId;
  final PostAuthor author;
  final String? parentId;
  final String body;
  final DateTime createdAt;
  final int likeCount;
  final bool liked;

  /// Only top-level comments have replies (one level).
  final List<Comment> replies;

  Comment copyWith({bool? liked, int? likeCount, List<Comment>? replies}) => Comment(
        id: id,
        postId: postId,
        author: author,
        parentId: parentId,
        body: body,
        createdAt: createdAt,
        likeCount: likeCount ?? this.likeCount,
        liked: liked ?? this.liked,
        replies: replies ?? this.replies,
      );
}

/// Groups flat rows under their top-level comment, oldest first.
List<Comment> threadComments(List<Comment> flat) {
  final replies = <String, List<Comment>>{};
  for (final c in flat) {
    if (c.parentId case final parent?) (replies[parent] ??= []).add(c);
  }
  return [
    for (final c in flat)
      if (c.parentId == null) c.copyWith(replies: replies[c.id] ?? const []),
  ];
}

class HashtagCount {
  const HashtagCount({required this.tag, required this.postCount});

  final String tag;
  final int postCount;
}

/// Part of a caption or comment: plain text, `#tag` or `@username`.
sealed class TextPart {
  const TextPart(this.text);

  final String text;
}

final class PlainPart extends TextPart {
  const PlainPart(super.text);
}

final class HashtagPart extends TextPart {
  const HashtagPart(super.text, this.tag);

  /// Lower case, without '#', as the database stores it.
  final String tag;
}

final class MentionPart extends TextPart {
  const MentionPart(super.text, this.username);

  final String username;
}

final _tokens = RegExp(r'#([\p{L}\p{N}_]{1,50})|@([A-Za-z0-9_.]{3,30})', unicode: true);

/// Splits text into plain runs, hashtags and mentions (the same patterns the database indexes).
List<TextPart> parseRichText(String text) {
  final parts = <TextPart>[];
  var last = 0;
  for (final m in _tokens.allMatches(text)) {
    // A tag or mention starts a word.
    if (m.start > 0 && RegExp(r'[\p{L}\p{N}_]', unicode: true).hasMatch(text[m.start - 1])) continue;
    if (m.start > last) parts.add(PlainPart(text.substring(last, m.start)));
    final raw = m[0]!;
    parts.add(m[1] != null ? HashtagPart(raw, m[1]!.toLowerCase()) : MentionPart(raw, m[2]!.toLowerCase().replaceAll(RegExp(r'\.+$'), '')));
    last = m.end;
  }
  if (last < text.length) parts.add(PlainPart(text.substring(last)));
  return parts;
}

/// `şimdi`, `5 dk`, `3 sa`, `2 g`, `4 hf`, then the date.
String formatAgoTr(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return 'şimdi';
  if (diff.inHours < 1) return '${diff.inMinutes} dk';
  if (diff.inDays < 1) return '${diff.inHours} sa';
  if (diff.inDays < 7) return '${diff.inDays} g';
  if (diff.inDays < 28) return '${diff.inDays ~/ 7} hf';
  return formatDateTr(time);
}

/// A photo or video picked on the device, measured and ready to upload.
class NewMedia {
  const NewMedia({
    required this.kind,
    required this.bytes,
    required this.fileName,
    required this.width,
    required this.height,
    this.duration,
    this.previewPath,
    this.thumb,
  });

  final MediaKind kind;
  final Uint8List bytes;
  final String fileName;
  final int width;
  final int height;
  final Duration? duration;

  /// Where the picker left the file (a blob URL on web), for video previews.
  final String? previewPath;

  /// Small JPEG copy of a prepared photo.
  final Uint8List? thumb;

  static const imageTypes = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp'};
  static const videoTypes = {'mp4': 'video/mp4', 'mov': 'video/quicktime'};

  static const maxImageBytes = 10 * 1024 * 1024;
  static const maxVideoBytes = 50 * 1024 * 1024;
  static const maxVideo = Duration(seconds: 60);

  String get extension => fileName.split('.').last.toLowerCase();

  String? get contentType => (kind == MediaKind.image ? imageTypes : videoTypes)[extension];

  /// Null when the file can be shared; otherwise why not, in Turkish.
  String? get problem {
    if (contentType == null) return 'Yalnızca JPEG, PNG, WebP fotoğraf ve MP4, MOV video paylaşılabilir.';
    if (kind == MediaKind.image && bytes.length > maxImageBytes) return 'Fotoğraflar en fazla 10 MB olabilir.';
    if (kind == MediaKind.video && bytes.length > maxVideoBytes) return 'Videolar en fazla 50 MB olabilir.';
    if (kind == MediaKind.video && (duration ?? Duration.zero) > maxVideo) return 'Videolar en fazla 60 saniye olabilir.';
    return null;
  }
}

class NewPost {
  const NewPost({
    required this.media,
    this.caption = '',
    this.groupId,
    this.commentsDisabled = false,
    this.hideLikeCount = false,
  });

  final List<NewMedia> media;
  final String caption;
  final String? groupId;
  final bool commentsDisabled;
  final bool hideLikeCount;

  static const maxCaption = 2200;
  static const maxHashtags = 30;
  static const maxMedia = 10;

  static String? captionProblem(String caption) {
    if (caption.trim().length > maxCaption) return 'Açıklama en fazla 2.200 karakter olabilir.';
    if (parseRichText(caption).whereType<HashtagPart>().length > maxHashtags) {
      return 'Bir gönderide en fazla 30 etiket kullanılabilir.';
    }
    return null;
  }

  /// Same limits as the API, checked before uploading anything.
  String? get problem {
    if (media.isEmpty || media.length > maxMedia) return 'Bir gönderide 1–10 fotoğraf ya da video olabilir.';
    if (captionProblem(caption) case final p?) return p;
    for (final m in media) {
      if (m.problem case final p?) return p;
    }
    return null;
  }
}

/// Where a list of posts comes from.
sealed class PostSource {
  const PostSource();
}

final class HomeFeed extends PostSource {
  const HomeFeed();

  @override
  bool operator ==(Object other) => other is HomeFeed;

  @override
  int get hashCode => (HomeFeed).hashCode;
}

final class UserPosts extends PostSource {
  const UserPosts(this.userId);

  final String userId;

  @override
  bool operator ==(Object other) => other is UserPosts && other.userId == userId;

  @override
  int get hashCode => Object.hash(UserPosts, userId);
}

final class GroupPosts extends PostSource {
  const GroupPosts(this.groupId);

  final String groupId;

  @override
  bool operator ==(Object other) => other is GroupPosts && other.groupId == groupId;

  @override
  int get hashCode => Object.hash(GroupPosts, groupId);
}

final class HashtagPosts extends PostSource {
  const HashtagPosts(this.tag);

  final String tag;

  @override
  bool operator ==(Object other) => other is HashtagPosts && other.tag == tag;

  @override
  int get hashCode => Object.hash(HashtagPosts, tag);
}

final class ExplorePosts extends PostSource {
  const ExplorePosts();

  @override
  bool operator ==(Object other) => other is ExplorePosts;

  @override
  int get hashCode => (ExplorePosts).hashCode;
}

final class SavedPosts extends PostSource {
  const SavedPosts();

  @override
  bool operator ==(Object other) => other is SavedPosts;

  @override
  int get hashCode => (SavedPosts).hashCode;
}

abstract interface class FeedRepository {
  /// A page of posts after [after] (the last post of the previous page), newest first;
  /// explore pages by [offset].
  Future<Result<List<Post>>> posts(PostSource source, {Post? after, int offset = 0});

  Future<Result<Post>> post(String id);

  Future<Result<List<HashtagCount>>> searchHashtags(String query);

  /// Groups the user may post for.
  Future<Result<List<PostGroup>>> publishableGroups();

  /// Uploads the files, then creates the post through the API; returns its id.
  Future<Result<String>> create(NewPost post, {void Function(int done, int total)? onProgress});

  Future<Result<void>> update(String id, {required String caption, required bool commentsDisabled, required bool hideLikeCount});

  Future<Result<void>> delete(String id);

  Future<Result<void>> setLiked(String postId, bool liked);

  Future<Result<void>> setSaved(String postId, bool saved);

  /// Top-level comments with their replies, oldest first.
  Future<Result<List<Comment>>> comments(String postId);

  Future<Result<void>> addComment(String postId, String body, {String? replyTo});

  Future<Result<void>> deleteComment(String commentId);

  Future<Result<void>> setCommentLiked(String commentId, bool liked);
}
