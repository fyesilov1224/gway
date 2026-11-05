import 'package:core/core.dart';

enum LegalKind {
  terms('terms'),
  privacyNotice('privacy_notice'),
  explicitConsent('explicit_consent'),
  communityRules('community_rules'),

  /// Accepted at checkout (billing), never at sign-up.
  distanceSales('distance_sales');

  const LegalKind(this.code);

  final String code;

  static LegalKind fromCode(String code) =>
      values.firstWhere((k) => k.code == code);
}

/// An informational translation of a document (docs/ARCHITECTURE.md §11, Hukuki metin çevirileri).
class LegalTranslation {
  const LegalTranslation({required this.title, required this.body});

  final String title;
  final String body;
}

class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.version,
    required this.title,
    required this.body,
    this.translation,
  });

  final LegalKind kind;
  final int version;

  /// The Turkish text: the binding one, and the one consent is given to.
  final String title;
  final String body;

  /// In the app language, when there is one; shown with a note that the Turkish text is binding.
  final LegalTranslation? translation;

  String get displayTitle => translation?.title ?? title;

  LegalDocument withTranslation(LegalTranslation? translation) =>
      LegalDocument(kind: kind, version: version, title: title, body: body, translation: translation);
}

abstract interface class ConsentRepository {
  /// Latest published documents the user has not accepted yet.
  Future<Result<List<LegalDocument>>> pending();

  /// Latest published version of every document, for reading anytime.
  Future<Result<List<LegalDocument>>> latest();

  Future<Result<void>> accept(List<LegalDocument> documents);
}
