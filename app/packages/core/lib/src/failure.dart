import 'l10n.dart';

/// An expected failure, safe to show to the user via [userMessage].
///
/// Raw error text (exceptions, server messages) never reaches the UI;
/// the data layer maps it to one of these types.
sealed class Failure implements Exception {
  const Failure();

  /// User-facing message for this failure, in the current language.
  String get userMessage;
}

/// Safe message for any error caught in the UI layer.
String userMessageOf(Object? error) => error is Failure
    ? error.userMessage
    : const UnexpectedFailure().userMessage;

/// No connection or the server could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  String get userMessage => coreL10n.networkFailure;

  @override
  bool operator ==(Object other) => other is NetworkFailure;

  @override
  int get hashCode => (NetworkFailure).hashCode;
}

/// The session is missing or expired.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();

  @override
  String get userMessage => coreL10n.unauthorizedFailure;

  @override
  bool operator ==(Object other) => other is UnauthorizedFailure;

  @override
  int get hashCode => (UnauthorizedFailure).hashCode;
}

/// The user is signed in but lacks permission.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure();

  @override
  String get userMessage => coreL10n.forbiddenFailure;

  @override
  bool operator ==(Object other) => other is ForbiddenFailure;

  @override
  int get hashCode => (ForbiddenFailure).hashCode;
}

/// The requested resource does not exist or is not visible.
final class NotFoundFailure extends Failure {
  const NotFoundFailure();

  @override
  String get userMessage => coreL10n.notFoundFailure;

  @override
  bool operator ==(Object other) => other is NotFoundFailure;

  @override
  int get hashCode => (NotFoundFailure).hashCode;
}

/// Too many requests in a short time.
final class RateLimitedFailure extends Failure {
  const RateLimitedFailure();

  @override
  String get userMessage => coreL10n.rateLimitedFailure;

  @override
  bool operator ==(Object other) => other is RateLimitedFailure;

  @override
  int get hashCode => (RateLimitedFailure).hashCode;
}

/// A business rule rejected the request.
///
/// [userMessage] must already be a safe sentence in the current language chosen by the
/// data layer (or a curated server title, translated by the API), never a raw server string.
final class RuleFailure extends Failure {
  const RuleFailure(this.code, this.userMessage);

  /// Stable machine-readable code, e.g. `group.member_limit_reached`.
  final String code;

  @override
  final String userMessage;

  @override
  bool operator ==(Object other) =>
      other is RuleFailure &&
      other.code == code &&
      other.userMessage == userMessage;

  @override
  int get hashCode => Object.hash(code, userMessage);
}

/// Anything not covered above. The cause is kept for logging only.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([this.cause]);

  final Object? cause;

  @override
  String get userMessage => coreL10n.unexpectedFailure;

  @override
  bool operator ==(Object other) => other is UnexpectedFailure;

  @override
  int get hashCode => (UnexpectedFailure).hashCode;
}
