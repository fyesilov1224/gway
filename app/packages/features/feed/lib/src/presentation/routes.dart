import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route paths owned by the feed feature.
abstract final class FeedRoutes {
  static const home = '/';
  static const explore = '/explore';
  static const create = '/new-post';
  static const saved = '/saved';
  static const newStory = '/new-story';
  static const archive = '/archive';

  static String createFor(String groupId) => '$create?group=$groupId';

  /// A memory of an event.
  static String createMemory(String eventId) => '$create?event=$eventId';

  static String post(String id) => '/p/$id';

  static String comments(String id) => '/p/$id/comments';

  static String edit(String id) => '/p/$id/edit';

  static String hashtag(String tag) => '/tags/${Uri.encodeComponent(tag)}';

  static String stories(String userId) => '/stories/$userId';

  static String highlight(String id) => '/highlights/$id';

  /// The address people share: the app is served with hash routing.
  static String shareLink(String postId) => '${Uri.base.origin}/#${post(postId)}';
}

/// Opens other features' pages; features do not import each other, so the app supplies it.
class FeedLinks {
  const FeedLinks({required this.openProfile, required this.openGroup, this.openEvent});

  final void Function(BuildContext context, String username) openProfile;
  final void Function(BuildContext context, String handle) openGroup;

  /// The event of a memory.
  final void Function(BuildContext context, String eventId)? openEvent;
}

final feedLinksProvider = Provider<FeedLinks>((ref) => throw UnimplementedError('feedLinksProvider must be overridden'));
