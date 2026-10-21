import 'package:core/core.dart';

enum LegalKind {
  terms('terms'),
  privacyNotice('privacy_notice'),
  explicitConsent('explicit_consent'),

  /// Accepted at checkout (billing), never at sign-up.
  distanceSales('distance_sales');

  const LegalKind(this.code);

  final String code;

  static LegalKind fromCode(String code) =>
      values.firstWhere((k) => k.code == code);
}

class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.version,
    required this.title,
    required this.body,
  });

  final LegalKind kind;
  final int version;
  final String title;
  final String body;
}

abstract interface class ConsentRepository {
  /// Latest published documents the user has not accepted yet.
  Future<Result<List<LegalDocument>>> pending();

  /// Latest published version of every document, for reading anytime.
  Future<Result<List<LegalDocument>>> latest();

  Future<Result<void>> accept(List<LegalDocument> documents);
}
