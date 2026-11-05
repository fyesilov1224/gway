import 'package:core/core.dart';

/// The legal text kinds, in the order the screen lists them, with their Turkish names.
const legalKindLabels = {
  'privacy_notice': 'KVKK Aydınlatma Metni',
  'explicit_consent': 'Açık Rıza Metni',
  'terms': 'Kullanım Koşulları',
  'community_rules': 'Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi',
  'distance_sales': 'Mesafeli Satış Sözleşmesi',
};

String legalKindLabel(String kind) => legalKindLabels[kind] ?? kind;

/// The languages a legal text can be translated into, with their Turkish names (docs/ARCHITECTURE.md §11).
const legalTranslationLanguages = {
  'en': 'İngilizce',
  'de': 'Almanca',
  'fr': 'Fransızca',
  'nl': 'Felemenkçe',
  'es': 'İspanyolca',
  'pt': 'Portekizce',
  'it': 'İtalyanca',
  'ru': 'Rusça',
  'ar': 'Arapça',
  'az': 'Azerice',
  'uk': 'Ukraynaca',
};

/// An informational translation of a version; the Turkish text stays binding.
class LegalTranslation {
  const LegalTranslation({required this.language, required this.title, required this.body, required this.updatedAt});

  factory LegalTranslation.fromJson(Map<String, Object?> j) => LegalTranslation(
        language: j['language']! as String,
        title: j['title']! as String,
        body: j['body']! as String,
        updatedAt: DateTime.parse(j['updatedAt']! as String),
      );

  final String language;
  final String title;
  final String body;
  final DateTime updatedAt;
}

/// One version of a legal text (docs/ARCHITECTURE.md §8b).
class LegalVersion {
  const LegalVersion({
    required this.version,
    required this.title,
    required this.publishedAt,
    required this.isCurrent,
    required this.isDraft,
    required this.consentCount,
  });

  factory LegalVersion.fromJson(Map<String, Object?> j) => LegalVersion(
        version: j['version']! as int,
        title: j['title']! as String,
        publishedAt: DateTime.parse(j['publishedAt']! as String),
        isCurrent: j['isCurrent']! as bool,
        isDraft: j['isDraft']! as bool,
        consentCount: j['consentCount']! as int,
      );

  final int version;
  final String title;
  final DateTime publishedAt;

  /// The newest published version of its kind — the one new users accept.
  final bool isCurrent;

  /// Published in the future: not visible to anyone yet.
  final bool isDraft;

  /// How many people have accepted this exact version; above zero it is frozen.
  final int consentCount;

  bool get isFrozen => consentCount > 0;
}

/// A legal text kind with its versions (newest first).
class LegalKind {
  const LegalKind({required this.kind, required this.audience, required this.versions});

  factory LegalKind.fromJson(Map<String, Object?> j) => LegalKind(
        kind: j['kind']! as String,
        audience: j['audience']! as String,
        versions: [for (final v in (j['versions']! as List).cast<Map<String, Object?>>()) LegalVersion.fromJson(v)],
      );

  final String kind;

  /// 'signup' (accepted at onboarding) or 'purchase' (accepted at checkout).
  final String audience;
  final List<LegalVersion> versions;

  LegalVersion? get current => versions.where((v) => v.isCurrent).firstOrNull;
}

/// One version's full body, for editing.
class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.version,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.consentCount,
  });

  factory LegalDocument.fromJson(Map<String, Object?> j) => LegalDocument(
        kind: j['kind']! as String,
        version: j['version']! as int,
        title: j['title']! as String,
        body: j['body']! as String,
        publishedAt: DateTime.parse(j['publishedAt']! as String),
        consentCount: j['consentCount']! as int,
      );

  final String kind;
  final int version;
  final String title;
  final String body;
  final DateTime publishedAt;
  final int consentCount;

  bool get isFrozen => consentCount > 0;
}

abstract interface class AdminLegalRepository {
  Future<Result<List<LegalKind>>> list();

  Future<Result<LegalDocument>> get(String kind, int version);

  /// Publishes a new version of [kind]; [publishedAt] null means now.
  Future<Result<void>> publish(String kind, {required String title, required String body, DateTime? publishedAt});

  Future<Result<void>> update(String kind, int version, {required String title, required String body, required DateTime publishedAt});

  Future<Result<void>> remove(String kind, int version);

  Future<Result<List<LegalTranslation>>> translations(String kind, int version);

  /// Adds or corrects a translation; allowed even after people consented to the Turkish version.
  Future<Result<void>> saveTranslation(String kind, int version, String language, {required String title, required String body});

  Future<Result<void>> removeTranslation(String kind, int version, String language);
}
