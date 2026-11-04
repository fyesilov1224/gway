/// Route paths owned by the support feature.
abstract final class SupportRoutes {
  static const list = '/support';

  /// The user guide; a chapter opens with [topic] expanded.
  static const guide = '/support/guide';

  static String guideChapter(String id, {int? topic}) =>
      Uri(path: '$guide/$id', queryParameters: topic == null ? null : {'topic': '$topic'}).toString();

  /// New message; [groupId] preselects a group the user manages.
  static String create({String? groupId}) =>
      Uri(path: '/support/new', queryParameters: groupId == null ? null : {'group': groupId}).toString();

  static String ticket(String id) => '/support/t/$id';
}
