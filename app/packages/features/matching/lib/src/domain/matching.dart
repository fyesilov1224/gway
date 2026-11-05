import 'package:core/core.dart';

import '../l10n.dart';

/// The version of the explicit consent text shown when the matching profile is opened (KVKK, docs/ARCHITECTURE.md §3g).
const matchConsentVersion = 'v1';

const matchMinAge = 18;
const matchMaxAge = 99;
const matchMinPhotos = 2;
const matchMaxPhotos = 6;

enum MatchMode {
  friend('friend'),
  dating('dating');

  const MatchMode(this.code);

  final String code;

  String get label => switch (this) {
        friend => matchingL10n.modeFriend,
        dating => matchingL10n.modeDating,
      };
}

enum MatchGender {
  woman('woman'),
  man('man'),
  nonbinary('nonbinary');

  const MatchGender(this.code);

  final String code;

  String get label => switch (this) {
        woman => matchingL10n.genderWoman,
        man => matchingL10n.genderMan,
        nonbinary => matchingL10n.genderNonbinary,
      };

  static MatchGender parse(Object? code) => values.firstWhere((g) => g.code == code, orElse: () => nonbinary);
}

/// Full years on [today]'s calendar.
int ageOn(DateTime birthDate, DateTime today) {
  var age = today.year - birthDate.year;
  if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
  return age;
}

String provinceName(int plate) => plate >= 1 && plate <= turkishProvinces.length ? turkishProvinces[plate - 1] : '';

class MatchPhoto {
  const MatchPhoto({required this.id, required this.path, required this.position, this.url});

  final String id;
  final String path;

  /// 0 is the cover.
  final int position;

  /// A signed address; null until loaded.
  final String? url;
}

/// What the user fills in; the same for opening and editing the profile.
class MatchProfileDraft {
  const MatchProfileDraft({
    required this.birthDate,
    required this.gender,
    required this.province,
    this.about = '',
    this.job = '',
    this.education = '',
    this.friend = true,
    this.dating = false,
    this.interestedIn = const {},
    this.ageMin = matchMinAge,
    this.ageMax = matchMaxAge,
  });

  final DateTime birthDate;
  final MatchGender gender;
  final int province;
  final String about;
  final String job;
  final String education;
  final bool friend;
  final bool dating;
  final Set<MatchGender> interestedIn;
  final int ageMin;
  final int ageMax;

  /// The rule the form shows before saving; null when the draft can be saved.
  String? problem(DateTime today) {
    if (ageOn(birthDate, today) < matchMinAge) return matchingL10n.adultsOnly;
    if (!friend && !dating) return matchingL10n.pickMode;
    if (dating && interestedIn.isEmpty) return matchingL10n.pickInterest;
    if (ageMin > ageMax) return matchingL10n.ageRangeInvalid;
    return null;
  }
}

/// The signed-in user's own matching profile.
class MatchProfile {
  const MatchProfile({
    required this.draft,
    required this.photos,
    this.paused = false,
    this.suspendedUntil,
  });

  final MatchProfileDraft draft;
  final List<MatchPhoto> photos;
  final bool paused;

  /// Set by the platform team; far in the future for good.
  final DateTime? suspendedUntil;

  bool suspendedAt(DateTime now) => suspendedUntil != null && suspendedUntil!.isAfter(now);

  /// Others see the profile only with enough photos (docs/ARCHITECTURE.md §3g).
  bool get hasEnoughPhotos => photos.length >= matchMinPhotos;

  Set<MatchMode> get modes => {if (draft.friend) MatchMode.friend, if (draft.dating) MatchMode.dating};
}

typedef SharedGroup = ({String name, String handle});

/// A person as their card shows them; the username appears only after a match.
class MatchCard {
  const MatchCard({
    required this.userId,
    required this.displayName,
    required this.age,
    required this.gender,
    required this.province,
    this.about = '',
    this.job = '',
    this.education = '',
    this.photoUrls = const [],
    this.photoIds = const [],
    this.interests = const [],
    this.sharedInterests = const {},
    this.sharedGroups = const [],
    this.superLikedMe = false,
  });

  final String userId;
  final String displayName;
  final int age;
  final MatchGender gender;
  final int province;
  final String about;
  final String job;
  final String education;
  final List<String> photoUrls;

  /// Not shown; for reporting a photo.
  final List<String> photoIds;

  /// Category slugs.
  final List<String> interests;
  final Set<String> sharedInterests;
  final List<SharedGroup> sharedGroups;

  /// They super liked the viewer; such cards come first in the deck.
  final bool superLikedMe;

  String get provinceLabel => provinceName(province);

  /// "Ortak: Doğa Yürüyüşçüleri ve 2 grup daha".
  String get sharedGroupsLine => switch (sharedGroups.length) {
        0 => '',
        1 => matchingL10n.sharedGroup(sharedGroups.first.name),
        final n => matchingL10n.sharedGroupsMore(sharedGroups.first.name, n - 1),
      };
}

/// One matched person with every mode they matched in (friend, dating or both); without the reveal
/// feature it is locked: [card] and [username] are null.
class MatchSummary {
  const MatchSummary({required this.modes, required this.matchedAt, this.username, this.card});

  /// Each running mode with its match, Arkadaş first.
  final Map<MatchMode, String> modes;
  final DateTime matchedAt;
  final String? username;
  final MatchCard? card;

  bool get locked => card == null;
}

/// What a package opens (docs/ARCHITECTURE.md §3g, Ücretli paketler).
enum MatchFeature {
  reveal('reveal'),
  chat('chat'),
  admirers('admirers'),
  unlimited('unlimited'),
  superLike('super'),
  boost('boost'),
  teammates('teammates');

  const MatchFeature(this.code);

  final String code;

  static MatchFeature? parse(Object? code) => values.where((f) => f.code == code).firstOrNull;

  /// The package that sells this feature on its own.
  MatchPackage get package => MatchPackage.values.firstWhere((p) => p.features.contains(this) && p != MatchPackage.all);
}

/// The matching packages, each sold on its own by billing; [all] is every feature.
enum MatchPackage {
  reveal('matching_reveal', {MatchFeature.reveal}),
  chat('matching_chat', {MatchFeature.chat, MatchFeature.reveal}),
  admirers('matching_admirers', {MatchFeature.admirers}),
  unlimited('matching_unlimited', {MatchFeature.unlimited}),
  superLike('matching_super', {MatchFeature.superLike}),
  boost('matching_boost', {MatchFeature.boost}),
  teammates('matching_teammates', {MatchFeature.teammates}),
  all('matching_premium', {...MatchFeature.values});

  const MatchPackage(this.slug, this.features);

  final String slug;

  String get title => switch (this) {
        reveal => matchingL10n.pkgReveal,
        chat => matchingL10n.pkgChat,
        admirers => matchingL10n.pkgAdmirers,
        unlimited => matchingL10n.pkgUnlimited,
        superLike => matchingL10n.pkgSuper,
        boost => matchingL10n.pkgBoost,
        teammates => matchingL10n.pkgTeammates,
        all => matchingL10n.pkgAll,
      };

  String get description => switch (this) {
        reveal => matchingL10n.pkgRevealText,
        chat => matchingL10n.pkgChatText,
        admirers => matchingL10n.pkgAdmirersText,
        unlimited => matchingL10n.pkgUnlimitedText,
        superLike => matchingL10n.pkgSuperText,
        boost => matchingL10n.pkgBoostText,
        teammates => matchingL10n.pkgTeammatesText,
        all => matchingL10n.pkgAllText,
      };
  final Set<MatchFeature> features;

  static MatchPackage? bySlug(String slug) => values.where((p) => p.slug == slug).firstOrNull;
}

/// The kinds of swipe: left, right, up.
enum SwipeKind { pass, like, superLike }

class SwipeOutcome {
  const SwipeOutcome({required this.matched, required this.likesLeft, required this.superLikesLeft, this.matchId});

  final bool matched;
  final String? matchId;

  /// Null with Sınırsız Beğeni.
  final int? likesLeft;
  final int superLikesLeft;
}

/// The user's packages and today's allowances (docs/ARCHITECTURE.md §3g, Ücretli paketler).
class MatchStatus {
  const MatchStatus({
    required this.likesLeft,
    required this.superLikesLeft,
    required this.boostUsedToday,
    required this.boostMinutes,
    this.features = const {},
    this.packages = const {},
    this.fullAccess = false,
    this.boostEndsAt,
    this.admirers = const {},
  });

  final Set<MatchFeature> features;

  /// A platform admin: every feature is open without a package.
  final bool fullAccess;

  /// Each package the user has, with the end of its time (also when a next slice is queued).
  final Map<MatchPackage, DateTime> packages;

  bool has(MatchFeature feature) => features.contains(feature);

  bool get hasAnyPackage => packages.isNotEmpty || fullAccess;

  /// Null with Sınırsız Beğeni.
  final int? likesLeft;
  final int superLikesLeft;
  final DateTime? boostEndsAt;
  final bool boostUsedToday;
  final int boostMinutes;

  /// How many people liked the user and wait for an answer, per mode.
  final Map<MatchMode, int> admirers;

  bool boostingAt(DateTime now) => boostEndsAt != null && boostEndsAt!.isAfter(now);

  int get admirerCount => admirers.values.fold(0, (a, b) => a + b);
}

/// Deck filters (Sınırsız Beğeni); empty means everyone in the pool.
class MatchFilters {
  const MatchFilters({this.minAge, this.maxAge, this.province, this.interest});

  final int? minAge;
  final int? maxAge;
  final int? province;

  /// A category slug.
  final String? interest;

  bool get isEmpty => minAge == null && maxAge == null && province == null && interest == null;

  int get count => [if (minAge != null || maxAge != null) 1, ?province, ?interest].length;

  @override
  bool operator ==(Object other) =>
      other is MatchFilters && other.minAge == minAge && other.maxAge == maxAge && other.province == province && other.interest == interest;

  @override
  int get hashCode => Object.hash(minAge, maxAge, province, interest);
}

/// A pass taken back (Sınırsız Beğeni).
typedef Rewound = ({String userId, MatchMode mode});

abstract interface class MatchingRepository {
  /// Null until the user opens a matching profile.
  Future<Result<MatchProfile?>> myProfile();

  /// Opens the profile with the current consent, or updates it.
  Future<Result<void>> saveProfile(MatchProfileDraft draft, {required bool create});

  Future<Result<void>> setPaused(bool paused);

  Future<Result<void>> addPhoto(ImageUpload image, int position);

  Future<Result<void>> removePhoto(MatchPhoto photo);

  /// Swaps [photo] with the cover.
  Future<Result<void>> makeCover(MatchPhoto photo, MatchPhoto cover);

  /// The next cards; filters need Sınırsız Beğeni.
  Future<Result<List<MatchCard>>> deck(MatchMode mode, {MatchFilters filters = const MatchFilters()});

  Future<Result<MatchStatus>> status();

  Future<Result<SwipeOutcome>> swipe(String userId, MatchMode mode, SwipeKind kind);

  /// Sınırsız Beğeni: takes the last pass back.
  Future<Result<Rewound>> rewind();

  /// Öne Çık: once a day; returns when the boost ends.
  Future<Result<DateTime>> boost();

  /// Seni Beğenenler: the people who liked the user and wait for an answer.
  Future<Result<List<MatchCard>>> admirers(MatchMode mode);

  Future<Result<List<MatchSummary>>> matches();

  Future<Result<void>> endMatch(String matchId);

  /// The chat with a match; it opens without a request.
  Future<Result<String>> openChat(String userId);

  Future<Result<void>> block(String userId);

  /// Profile, photos, swipes; matches end (docs/ARCHITECTURE.md §3g).
  Future<Result<void>> deleteAll();
}
