abstract final class EventRoutes {
  static String event(String id) => '/e/$id';

  static String edit(String id) => '/e/$id/edit';

  static String create(String groupId) => '/events/new?group=$groupId';
}
