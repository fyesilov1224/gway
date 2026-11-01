/// Route paths owned by the messaging feature.
abstract final class MessagingRoutes {
  static const list = '/messages';

  static String chat(String id) => '/messages/$id';

  /// A voice call; the caller passes its [CallJoin] as the route's extra.
  static String call(String id) => '/calls/$id';

  static const callSettings = '/settings/calls';
}
