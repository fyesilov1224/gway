import 'package:core/core.dart';

import 'admin_user.dart';

class AdminPostMedia {
  const AdminPostMedia({required this.kind, required this.path, this.posterPath});

  factory AdminPostMedia.fromJson(Map<String, Object?> j) => AdminPostMedia(
        kind: j['kind']! as String,
        path: j['path']! as String,
        posterPath: j['posterPath'] as String?,
      );

  /// `image` or `video`.
  final String kind;
  final String path;
  final String? posterPath;

  bool get isVideo => kind == 'video';
}

class AdminPostSummary {
  const AdminPostSummary({
    required this.id,
    required this.caption,
    required this.mediaCount,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.authorId,
    this.authorUsername,
    this.groupId,
    this.groupName,
    this.cover,
    this.removedAt,
    this.removedReason,
  });

  factory AdminPostSummary.fromJson(Map<String, Object?> j) => AdminPostSummary(
        id: j['id']! as String,
        caption: j['caption']! as String,
        mediaCount: j['mediaCount']! as int,
        likeCount: j['likeCount']! as int,
        commentCount: j['commentCount']! as int,
        createdAt: DateTime.parse(j['createdAt']! as String),
        authorId: j['authorId'] as String?,
        authorUsername: j['authorUsername'] as String?,
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        cover: j['cover'] == null ? null : AdminPostMedia.fromJson((j['cover']! as Map).cast()),
        removedAt: j['removedAt'] == null ? null : DateTime.parse(j['removedAt']! as String),
        removedReason: j['removedReason'] as String?,
      );

  final String id;
  final String caption;
  final int mediaCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final String? authorId;
  final String? authorUsername;
  final String? groupId;
  final String? groupName;
  final AdminPostMedia? cover;
  final DateTime? removedAt;
  final String? removedReason;

  bool get isRemoved => removedAt != null;

  /// "Grup adı · @yazar", "@yazar" or "Silinmiş hesap".
  String get owner => [
        ?groupName,
        if (authorUsername != null) '@$authorUsername',
      ].join(' · ').ifEmpty('Silinmiş hesap');
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class AdminComment {
  const AdminComment({
    required this.id,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.authorUsername,
    this.parentId,
    this.removedAt,
    this.removedReason,
  });

  factory AdminComment.fromJson(Map<String, Object?> j) => AdminComment(
        id: j['id']! as String,
        authorId: j['authorId']! as String,
        body: j['body']! as String,
        createdAt: DateTime.parse(j['createdAt']! as String),
        authorUsername: j['authorUsername'] as String?,
        parentId: j['parentId'] as String?,
        removedAt: j['removedAt'] == null ? null : DateTime.parse(j['removedAt']! as String),
        removedReason: j['removedReason'] as String?,
      );

  final String id;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final String? authorUsername;
  final String? parentId;
  final DateTime? removedAt;
  final String? removedReason;
}

class AdminPostDetail {
  const AdminPostDetail({required this.post, required this.media, required this.comments});

  factory AdminPostDetail.fromJson(Map<String, Object?> j) => AdminPostDetail(
        post: AdminPostSummary.fromJson((j['post']! as Map).cast()),
        media: [for (final m in (j['media']! as List).cast<Map<String, Object?>>()) AdminPostMedia.fromJson(m)],
        comments: [for (final c in (j['comments']! as List).cast<Map<String, Object?>>()) AdminComment.fromJson(c)],
      );

  final AdminPostSummary post;
  final List<AdminPostMedia> media;

  /// Replies follow their comment.
  final List<AdminComment> comments;
}

/// Filter of the content list.
enum AdminContentFilter {
  visible('Yayında', false),
  removed('Kaldırılanlar', true);

  const AdminContentFilter(this.label, this.isRemoved);

  final String label;
  final bool isRemoved;
}

typedef PostPage = PagedList<AdminPostSummary>;

abstract interface class AdminContentRepository {
  Future<Result<PostPage>> search({String? query, AdminContentFilter? filter, int page = 1});

  Future<Result<AdminPostDetail>> get(String id);

  Future<Result<void>> removePost(String id, {required String reason});

  Future<Result<void>> restorePost(String id);

  Future<Result<void>> removeComment(String id, {required String reason});
}
