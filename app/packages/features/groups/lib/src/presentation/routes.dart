/// Route paths owned by the groups feature.
abstract final class GroupRoutes {
  static const discover = '/groups';
  static const create = '/groups/new';

  static String group(String handle) => '/g/$handle';

  static String members(String handle) => '/g/$handle/members';

  static String edit(String handle) => '/g/$handle/edit';
}
