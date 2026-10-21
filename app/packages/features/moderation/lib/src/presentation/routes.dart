abstract final class ModerationRoutes {
  static const mySanctions = '/me/sanctions';

  static String group(String handle) => '/g/$handle/moderation';
}
