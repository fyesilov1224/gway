/// Route paths owned by the support feature.
abstract final class SupportRoutes {
  static const list = '/support';

  /// New message; [groupId] preselects a group the user manages.
  static String create({String? groupId}) =>
      Uri(path: '/support/new', queryParameters: groupId == null ? null : {'group': groupId}).toString();

  static String ticket(String id) => '/support/t/$id';
}
