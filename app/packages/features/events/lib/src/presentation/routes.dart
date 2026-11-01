abstract final class EventRoutes {
  static String event(String id) => '/e/$id';

  static String edit(String id) => '/e/$id/edit';

  static String create(String groupId) => '/events/new?group=$groupId';

  /// "Takvimim".
  static const calendar = '/calendar';

  /// The year in review; [year] defaults to this one.
  static String year([int? year]) => year == null ? '/year' : '/year?y=$year';

  static const exploration = '/exploration';

  /// El sıkış for an event; the event title may come along as the route's `extra`.
  static String handshake(String eventId) => '/handshake/$eventId';

  static const met = '/met';

  static String groupCalendar(String groupId) => '/calendar?group=$groupId';

  static String goal(String id) => '/goals/$id';

  /// "Bu akşam": who is free and the small table.
  static const tonight = '/tonight';

  /// "Yaklaşanlar": the next 60 days of the user's groups, day by day.
  static const upcoming = '/upcoming';

  /// Groups and upcoming events on the map.
  static const map = '/map';

  /// A league table (docs/ARCHITECTURE.md §3d, Gruplar Ligi); without arguments the screen picks the first league.
  static String league({String? category, int? province, DateTime? month}) {
    final query = {
      'category': ?category,
      'province': ?province?.toString(),
      if (month != null) 'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
    };
    return query.isEmpty ? '/league' : Uri(path: '/league', queryParameters: query).toString();
  }

  /// The group's past events.
  static String history(String groupId) => '/events/history?group=$groupId';
}
