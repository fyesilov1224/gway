abstract final class EventRoutes {
  static String event(String id) => '/e/$id';

  static String edit(String id) => '/e/$id/edit';

  static String create(String groupId) => '/events/new?group=$groupId';

  /// "Takvimim".
  static const calendar = '/calendar';

  static String groupCalendar(String groupId) => '/calendar?group=$groupId';

  static String goal(String id) => '/goals/$id';

  /// The group's past events.
  static String history(String groupId) => '/events/history?group=$groupId';
}
