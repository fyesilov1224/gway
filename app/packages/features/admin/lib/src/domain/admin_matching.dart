import 'package:core/core.dart';

/// The daily allowances (Turkey's day) and the boost length.
class AdminMatchingSettings {
  const AdminMatchingSettings({
    required this.dailyFreeLikes,
    required this.dailyFreeSuperLikes,
    required this.dailyPremiumSuperLikes,
    required this.boostMinutes,
  });

  factory AdminMatchingSettings.fromJson(Map<String, Object?> j) => AdminMatchingSettings(
        dailyFreeLikes: j['dailyFreeLikes']! as int,
        dailyFreeSuperLikes: j['dailyFreeSuperLikes']! as int,
        dailyPremiumSuperLikes: j['dailyPremiumSuperLikes']! as int,
        boostMinutes: j['boostMinutes']! as int,
      );

  final int dailyFreeLikes;
  final int dailyFreeSuperLikes;
  final int dailyPremiumSuperLikes;
  final int boostMinutes;

  Map<String, Object?> toJson() => {
        'dailyFreeLikes': dailyFreeLikes,
        'dailyFreeSuperLikes': dailyFreeSuperLikes,
        'dailyPremiumSuperLikes': dailyPremiumSuperLikes,
        'boostMinutes': boostMinutes,
      };
}

/// Matching at a glance (docs/ARCHITECTURE.md §3g, Admin). Counts only.
class AdminMatchingStats {
  const AdminMatchingStats({
    required this.profiles,
    required this.friendProfiles,
    required this.datingProfiles,
    required this.women,
    required this.men,
    required this.nonbinary,
    required this.paused,
    required this.suspended,
    required this.likes24h,
    required this.passes24h,
    required this.matches24h,
    required this.activeMatches,
    required this.openReports,
    required this.premiumProfiles,
    required this.superLikes24h,
    required this.activeBoosts,
    required this.settings,
  });

  factory AdminMatchingStats.fromJson(Map<String, Object?> j) => AdminMatchingStats(
        profiles: j['profiles']! as int,
        friendProfiles: j['friendProfiles']! as int,
        datingProfiles: j['datingProfiles']! as int,
        women: j['women']! as int,
        men: j['men']! as int,
        nonbinary: j['nonbinary']! as int,
        paused: j['paused']! as int,
        suspended: j['suspended']! as int,
        likes24h: j['likes24h']! as int,
        passes24h: j['passes24h']! as int,
        matches24h: j['matches24h']! as int,
        activeMatches: j['activeMatches']! as int,
        openReports: j['openReports']! as int,
        premiumProfiles: j['premiumProfiles']! as int,
        superLikes24h: j['superLikes24h']! as int,
        activeBoosts: j['activeBoosts']! as int,
        settings: AdminMatchingSettings.fromJson((j['settings']! as Map).cast()),
      );

  final int profiles;
  final int friendProfiles;
  final int datingProfiles;
  final int women;
  final int men;
  final int nonbinary;
  final int paused;
  final int suspended;
  final int likes24h;
  final int passes24h;
  final int matches24h;
  final int activeMatches;

  /// Open reports of matching profiles and photos.
  final int openReports;

  /// Matching profiles whose owner has Premium now.
  final int premiumProfiles;
  final int superLikes24h;
  final int activeBoosts;
  final AdminMatchingSettings settings;
}

typedef AdminPrice = ({String currency, String period, int amountMinor});

/// A matching package as billing sells it: catalog, people with time left, the last 30 days' revenue.
class AdminPremium {
  const AdminPremium({
    required this.slug,
    required this.name,
    required this.isActive,
    required this.prices,
    required this.activeMembers,
    required this.grantedMembers,
    required this.revenue30d,
  });

  factory AdminPremium.fromJson(Map<String, Object?> j) => AdminPremium(
        slug: j['slug']! as String,
        name: j['name']! as String,
        isActive: j['isActive']! as bool,
        prices: [
          for (final p in (j['prices']! as List).cast<Map<String, Object?>>())
            (currency: p['currency']! as String, period: p['period']! as String, amountMinor: p['amountMinor']! as int),
        ],
        activeMembers: j['activeMembers']! as int,
        grantedMembers: j['grantedMembers']! as int,
        revenue30d: [
          for (final r in (j['revenue30d']! as List).cast<Map<String, Object?>>())
            (currency: r['currency']! as String, amountMinor: r['amountMinor']! as int, orders: r['orders']! as int),
        ],
      );

  final String slug;
  final String name;
  final bool isActive;
  final List<AdminPrice> prices;
  final int activeMembers;

  /// Of [activeMembers], those whose time an admin gave.
  final int grantedMembers;
  final List<({String currency, int amountMinor, int orders})> revenue30d;

  int? price(String currency, String period) =>
      prices.where((p) => p.currency == currency && p.period == period).firstOrNull?.amountMinor;
}

/// One slice of a person's package: bought ([orderId]) or given by an admin ([grantReason]).
class AdminPersonalSubscription {
  const AdminPersonalSubscription({
    required this.id,
    required this.planSlug,
    required this.planName,
    required this.period,
    required this.startsAt,
    required this.endsAt,
    required this.canceledAt,
    required this.orderId,
    required this.orderStatus,
    required this.amountMinor,
    required this.currency,
    required this.grantReason,
    required this.grantedByUsername,
  });

  factory AdminPersonalSubscription.fromJson(Map<String, Object?> j) => AdminPersonalSubscription(
        id: j['id']! as String,
        planSlug: j['planSlug']! as String,
        planName: j['planName']! as String,
        period: j['period'] as String?,
        startsAt: DateTime.parse(j['startsAt']! as String),
        endsAt: DateTime.parse(j['endsAt']! as String),
        canceledAt: switch (j['canceledAt']) { final String at => DateTime.parse(at), _ => null },
        orderId: j['orderId'] as String?,
        orderStatus: j['orderStatus'] as String?,
        amountMinor: j['amountMinor'] as int?,
        currency: j['currency'] as String?,
        grantReason: j['grantReason'] as String?,
        grantedByUsername: j['grantedByUsername'] as String?,
      );

  final String id;
  final String planSlug;
  final String planName;
  final String? period;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;
  final String? orderId;
  final String? orderStatus;
  final int? amountMinor;
  final String? currency;
  final String? grantReason;
  final String? grantedByUsername;

  bool get isGrant => orderId == null;

  /// Running now or still to come (an empty, canceled slice never runs).
  bool isLive(DateTime now) => endsAt.isAfter(now) && endsAt.isAfter(startsAt);
}

abstract interface class AdminMatchingRepository {
  Future<Result<AdminMatchingStats>> stats();

  /// Hides the matching profile until [until] (null: for good) and ends its matches.
  Future<Result<void>> suspend(String userId, {required String reason, DateTime? until});

  Future<Result<void>> removePhoto(String photoId, {required String reason});

  Future<Result<void>> updateSettings(AdminMatchingSettings settings);

  /// The matching packages, as the shop lists them.
  Future<Result<List<AdminPremium>>> packages();

  Future<Result<void>> updatePackage(String slug, {required String name, required bool isActive, required List<AdminPrice> prices});

  /// Gives [username] the package for [days], after any time they already have.
  Future<Result<void>> grantPackage({required String username, required String slug, required int days, required String reason});

  /// Every slice of the person's packages, newest first.
  Future<Result<List<AdminPersonalSubscription>>> userPackages(String userId);

  /// Gives the person the package for [days], after any time they already have.
  Future<Result<void>> grantUserPackage(String userId, {required String slug, required int days, required String reason});

  /// Ends the person's running and upcoming time of the package now; [refunded] marks those orders refunded.
  Future<Result<void>> cancelUserPackage(String userId, String slug, {required String reason, required bool refunded});

  /// A short-lived address of a reported photo; the platform team may view matching photos.
  Future<Result<String>> photoUrl(String path);
}
