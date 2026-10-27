/// Route paths owned by the identity feature. Apps register the screens
/// under these paths.
abstract final class IdentityRoutes {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const checkEmail = '/check-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const consent = '/consent';
  static const deletionPending = '/deletion-pending';
  static const suspended = '/suspended';
  static const deleteAccount = '/settings/delete-account';
  static const legalDocuments = '/settings/legal';
  static const twoFactor = '/settings/two-factor';

  /// Location, phone and second factor (docs/ARCHITECTURE.md §3h).
  static const security = '/security';

  /// Screens reachable without a session.
  static const public = {signIn, signUp, checkEmail, forgotPassword};
}
