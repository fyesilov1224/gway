/// Route paths owned by the messaging feature.
abstract final class MessagingRoutes {
  static const list = '/messages';

  static String chat(String id) => '/messages/$id';
}
