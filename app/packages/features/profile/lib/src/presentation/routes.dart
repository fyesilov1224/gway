/// Route paths owned by the profile feature.
abstract final class ProfileRoutes {
  static const onboarding = '/onboarding';
  static const mine = '/me';
  static const edit = '/profile/edit';

  static const followRequests = '/follow-requests';
  static const blocked = '/settings/blocked';

  static const teammates = '/teammates';
  static const teammateSettings = '/settings/teammates';

  static String user(String username) => '/u/$username';

  static String followers(String username) => '/u/$username/followers';

  static String following(String username) => '/u/$username/following';
}
