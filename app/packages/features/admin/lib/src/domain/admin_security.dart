import 'package:core/core.dart';

/// Turkish names of the signals a location check or phone step can raise (docs/ARCHITECTURE.md §3h).
const securitySignalLabels = {
  'mock_location': 'Sahte konum',
  'foreign_phone': 'Başka ülkenin numarası',
  'banned_phone': 'Yasaklı numara',
  'ip_mismatch': 'GPS ve IP ülkesi farklı',
  'vpn': 'VPN açık',
  'sim_mismatch': 'SIM ülkesi farklı',
  'phone_mismatch': 'Numaranın ülkesi farklı',
};

String securitySignalLabel(String code) => securitySignalLabels[code] ?? code;

/// Certain signals ban automatically; the others restrict until a review.
bool isCertainSignal(String code) => const {'mock_location', 'foreign_phone', 'banned_phone'}.contains(code);

class AdminLocationCheck {
  const AdminLocationCheck({
    required this.checkedAt,
    required this.platform,
    required this.gpsCountry,
    required this.ipCountry,
    required this.simCountry,
    required this.phoneCountry,
    required this.isMocked,
    required this.vpn,
    required this.signals,
    required this.verdict,
  });

  factory AdminLocationCheck.fromJson(Map<String, Object?> j) => AdminLocationCheck(
        checkedAt: DateTime.parse(j['checkedAt']! as String),
        platform: j['platform']! as String,
        gpsCountry: j['gpsCountry'] as String?,
        ipCountry: j['ipCountry'] as String?,
        simCountry: j['simCountry'] as String?,
        phoneCountry: j['phoneCountry'] as String?,
        isMocked: j['isMocked']! as bool,
        vpn: j['vpn']! as bool,
        signals: (j['signals']! as List).cast<String>(),
        verdict: j['verdict']! as String,
      );

  final DateTime checkedAt;
  final String platform;
  final String? gpsCountry;
  final String? ipCountry;
  final String? simCountry;
  final String? phoneCountry;
  final bool isMocked;
  final bool vpn;
  final List<String> signals;

  /// `ok`, `restricted` or `banned`.
  final String verdict;

  /// One line for lists: `GPS TR · IP DE · SIM — · Numara TR · android`.
  String get summary => [
        'GPS ${gpsCountry ?? '—'}',
        'IP ${ipCountry ?? '—'}',
        'SIM ${simCountry ?? '—'}',
        'Numara ${phoneCountry ?? '—'}',
        platform,
      ].join(' · ');
}

enum AdminReviewStatus {
  open('open', 'Açık'),
  approved('approved', 'Onaylandı'),
  banned('banned', 'Banlandı');

  const AdminReviewStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminReviewStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => open);
}

class AdminSecurityReview {
  const AdminSecurityReview({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.signals,
    required this.status,
    required this.openedAt,
    required this.resolvedAt,
    required this.note,
    required this.check,
  });

  factory AdminSecurityReview.fromJson(Map<String, Object?> j) => AdminSecurityReview(
        id: j['id']! as String,
        userId: j['userId']! as String,
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
        signals: (j['signals']! as List).cast<String>(),
        status: AdminReviewStatus.parse(j['status']),
        openedAt: DateTime.parse(j['openedAt']! as String),
        resolvedAt: switch (j['resolvedAt']) { final String s => DateTime.parse(s), _ => null },
        note: j['note'] as String?,
        check: switch (j['check']) { final Map<String, Object?> c => AdminLocationCheck.fromJson(c), _ => null },
      );

  final String id;
  final String userId;
  final String? username;
  final String? displayName;
  final List<String> signals;
  final AdminReviewStatus status;
  final DateTime openedAt;
  final DateTime? resolvedAt;
  final String? note;
  final AdminLocationCheck? check;

  String get title => displayName ?? (username == null ? 'Onboarding tamamlanmadı' : '@$username');
}

class AdminSecuritySettings {
  const AdminSecuritySettings({
    required this.enforce,
    required this.smsConfigured,
    required this.lookupEnabled,
    required this.updatedAt,
  });

  factory AdminSecuritySettings.fromJson(Map<String, Object?> j) => AdminSecuritySettings(
        enforce: j['enforce']! as bool,
        smsConfigured: j['smsConfigured']! as bool,
        lookupEnabled: j['lookupEnabled']! as bool,
        updatedAt: DateTime.parse(j['updatedAt']! as String),
      );

  final bool enforce;
  final bool smsConfigured;
  final bool lookupEnabled;
  final DateTime updatedAt;
}

class AdminUserSecurity {
  const AdminUserSecurity({
    required this.state,
    required this.phoneMasked,
    required this.phoneCountry,
    required this.phoneVerifiedAt,
    required this.totpEnabled,
    required this.allowedCountry,
    required this.locationCheckedAt,
    required this.exemptUntil,
    required this.checks,
  });

  factory AdminUserSecurity.fromJson(Map<String, Object?> j) {
    DateTime? date(Object? v) => v is String ? DateTime.parse(v) : null;
    return AdminUserSecurity(
      state: j['state']! as String,
      phoneMasked: j['phoneMasked'] as String?,
      phoneCountry: j['phoneCountry'] as String?,
      phoneVerifiedAt: date(j['phoneVerifiedAt']),
      totpEnabled: j['totpEnabled']! as bool,
      allowedCountry: j['allowedCountry'] as String?,
      locationCheckedAt: date(j['locationCheckedAt']),
      exemptUntil: date(j['exemptUntil']),
      checks: [for (final c in (j['checks']! as List).cast<Map<String, Object?>>()) AdminLocationCheck.fromJson(c)],
    );
  }

  /// `ok` or `restricted`.
  final String state;
  final String? phoneMasked;
  final String? phoneCountry;
  final DateTime? phoneVerifiedAt;
  final bool totpEnabled;
  final String? allowedCountry;
  final DateTime? locationCheckedAt;
  final DateTime? exemptUntil;
  final List<AdminLocationCheck> checks;
}

abstract interface class AdminSecurityRepository {
  Future<Result<AdminSecuritySettings>> settings();

  Future<Result<AdminSecuritySettings>> setEnforce(bool enforce);

  Future<Result<List<AdminSecurityReview>>> reviews(AdminReviewStatus? status, {int page = 1});

  /// [exemptDays] 0–90: uncertain signals do not restrict for that long.
  Future<Result<void>> approve(String reviewId, {required int exemptDays, String? note});

  Future<Result<void>> ban(String reviewId, {required String note});

  Future<Result<AdminUserSecurity>> user(String userId);
}
