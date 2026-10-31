abstract final class AdminRoutes {
  static const overview = '/';

  static const users = '/users';
  static const notAuthorized = '/not-authorized';

  static const groups = '/groups';

  static const billing = '/billing';

  static const plans = '/plans';

  static const support = '/support';

  static const content = '/content';

  static const live = '/live';

  static const notifications = '/notifications';

  static const legal = '/legal';

  /// Not `/security`: that is the sign-in verification step (identity).
  static const securityReviews = '/security-reviews';

  static const matching = '/matching';

  static const events = '/events';

  static const reports = '/reports';

  static const goals = '/goals';

  static const leagues = '/leagues';

  static const messageLogs = '/message-logs';

  static String messageLog(String conversationId) => '/message-logs/$conversationId';

  static String messageLogsOf(String username) => '/message-logs?user=${Uri.encodeQueryComponent(username)}';

  static String post(String id) => '/content/$id';

  static String ticket(String id) => '/support/$id';

  static String user(String id) => '/users/$id';

  static String group(String id) => '/groups/$id';
}
