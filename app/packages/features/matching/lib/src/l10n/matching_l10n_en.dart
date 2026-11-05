// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MatchingL10nEn extends MatchingL10n {
  MatchingL10nEn([String locale = 'en']) : super(locale);

  @override
  String get unsupportedImage =>
      'Only JPEG, PNG or WebP photos can be uploaded.';

  @override
  String get modeFriend => 'Friends';

  @override
  String get modeDating => 'Dating';

  @override
  String get genderWoman => 'Woman';

  @override
  String get genderMan => 'Man';

  @override
  String get genderNonbinary => 'Non-binary';

  @override
  String get adultsOnly => 'Matching is for people over 18.';

  @override
  String get pickMode => 'Choose at least one mode: Friends or Dating.';

  @override
  String get pickInterest => 'Choose who you\'re looking for in Dating.';

  @override
  String get ageRangeInvalid => 'The age range is invalid.';

  @override
  String sharedGroup(String group) {
    return 'Shared group: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shared: $group and $count more groups',
      one: 'Shared: $group and 1 more group',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'My matches';

  @override
  String get pkgRevealText =>
      'See who you matched with: name, photos and profile.';

  @override
  String get pkgChat => 'Match Chat';

  @override
  String get pkgChatText =>
      'Write to your matches. Includes seeing your matches.';

  @override
  String get pkgAdmirers => 'Who Likes You';

  @override
  String get pkgAdmirersText =>
      'See who liked you and match instantly by liking back.';

  @override
  String get pkgUnlimited => 'Unlimited Likes';

  @override
  String get pkgUnlimitedText =>
      'No daily like limit; undo and filters are included.';

  @override
  String get pkgSuper => 'Super Like';

  @override
  String get pkgSuperText =>
      '5 Super Likes a day; the person you Super Like sees you first in their deck.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Once a day, appear at the top of decks in your shared groups for 30 minutes.';

  @override
  String get pkgTeammates => 'Teammate';

  @override
  String get pkgTeammatesText =>
      'Send teammate requests and chat with your teammates.';

  @override
  String get pkgAll => 'All in One';

  @override
  String get pkgAllText =>
      'Every plan in one, much cheaper than buying them separately.';

  @override
  String get superLikedYou => 'Super Liked you';

  @override
  String get options => 'Options';

  @override
  String get fullProfile => 'Full profile';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NOPE';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, photo $number';
  }

  @override
  String get about => 'About';

  @override
  String get interests => 'Interests';

  @override
  String get sharedGroupsTitle => 'Groups in common';

  @override
  String get createProfileTitle => 'Create a matching profile';

  @override
  String get myProfile => 'My matching profile';

  @override
  String get birthDateLabel => 'Your date of birth';

  @override
  String get pickBasics => 'Choose your date of birth, gender and province.';

  @override
  String get confirmAgeConsent =>
      'To continue, confirm you\'re over 18 and give your explicit consent.';

  @override
  String profileReady(int min) {
    return 'Your profile is ready. Now add at least $min photos.';
  }

  @override
  String get saved => 'Saved.';

  @override
  String get pickBirthDate => 'Choose date of birth';

  @override
  String ageNote(int age) {
    return '$age years old · your card shows only your age';
  }

  @override
  String get gender => 'Gender';

  @override
  String get province => 'Province';

  @override
  String get aboutHint => 'Tell us about yourself';

  @override
  String get jobOptional => 'Job (optional)';

  @override
  String get educationOptional => 'Education (optional)';

  @override
  String get interestsFromProfile =>
      'Your interests come from your social profile.';

  @override
  String get lookingFor => 'What are you looking for?';

  @override
  String get friendHint => 'People to go to events and chat with';

  @override
  String get datingHint => 'A romantic relationship';

  @override
  String get whoLookingFor => 'Who are you looking for?';

  @override
  String ageRange(int min, int max) {
    return 'Age range: $min–$max';
  }

  @override
  String get consentTitle => 'Consent';

  @override
  String get iam18 => 'I\'m over 18.';

  @override
  String get consentText =>
      'For matching, I give explicit consent to the processing of my gender, who I\'m looking for, my date of birth, my province and my photos, and to showing them to people in my shared groups who turned on matching. I can withdraw my consent at any time by deleting my matching data.';

  @override
  String get createProfile => 'Create my profile';

  @override
  String get save => 'Save';

  @override
  String get photos => 'Photos';

  @override
  String photosMin(int min) {
    return 'Add at least $min photos for your card to show. The first one is the cover.';
  }

  @override
  String photosMax(int max) {
    return 'Up to $max photos. The first one is the cover; tap a photo to change it.';
  }

  @override
  String get addPhoto => 'Add photo';

  @override
  String get cover => 'Cover';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get pauseProfile => 'Pause my profile';

  @override
  String get pauseHint =>
      'Nobody sees you and no new cards arrive; your matches and chats stay.';

  @override
  String get deleteData => 'Delete my matching data';

  @override
  String get deleteDataHint =>
      'Your profile, photos and likes are deleted and your matches end. Your explicit consent is withdrawn.';

  @override
  String get deleteDataTitle => 'Delete matching data';

  @override
  String get deleteDataBody =>
      'Your matching profile, photos and likes are permanently deleted and all your matches end. This can\'t be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get dataDeleted => 'Your matching data was deleted.';

  @override
  String get itsAMatch => 'It\'s a match!';

  @override
  String bothLiked(String name) {
    return 'You and $name liked each other.';
  }

  @override
  String get keepSwiping => 'Keep swiping';

  @override
  String get sendMessage => 'Send a message';

  @override
  String get reportProfile => 'Report profile';

  @override
  String get reportPhoto => 'Report this photo';

  @override
  String get block => 'Block';

  @override
  String get blockHint => 'You won\'t see each other anywhere.';

  @override
  String get cancel => 'Cancel';

  @override
  String get newMatch => 'You matched with someone!';

  @override
  String tapToSee(String date) {
    return 'Tap to see who it is · $date';
  }

  @override
  String get revealReason =>
      'You matched with someone! Get the My matches plan to see who it is.';

  @override
  String get keepFriend => 'Stay friends only';

  @override
  String get keepDating => 'Keep dating only';

  @override
  String keepFriendBody(String name) {
    return 'Your dating match with $name ends for both of you; your friends match and chat continue.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Your friends match with $name ends for both of you; your dating match and chat continue.';
  }

  @override
  String get keptFriend => 'You\'re now matched as friends only.';

  @override
  String get keptDating => 'You\'re now matched for dating only.';

  @override
  String get continueAction => 'Continue';

  @override
  String get endMatch => 'End match';

  @override
  String endMatchBody(String name) {
    return 'Your match with $name ends and your chat closes for both of you. This can\'t be undone.';
  }

  @override
  String get end => 'End';

  @override
  String get matchEnded => 'The match has ended.';

  @override
  String get noMatches => 'No matches yet. People you both like appear here.';

  @override
  String get backToDiscover => 'Back to discovering';

  @override
  String get report => 'Report';

  @override
  String get matching => 'Matching';

  @override
  String get admirers => 'Who likes you';

  @override
  String get packages => 'Plans';

  @override
  String get more => 'More';

  @override
  String get filtersLocked =>
      'Filtering by age, province and interest comes with the Unlimited Likes plan.';

  @override
  String get filters => 'Filters';

  @override
  String get suspended =>
      'Your matching profile was closed by the platform team. Write to Support for details.';

  @override
  String addPhotosToStart(int min) {
    return 'Add at least $min photos to show your card and start discovering.';
  }

  @override
  String get paused =>
      'Your profile is paused; nobody sees you. Your matches and chats are still there.';

  @override
  String get likesOut =>
      'You\'ve used today\'s free likes. Like as much as you want with Unlimited Likes.';

  @override
  String get supersOut =>
      'You\'ve used today\'s Super Likes. They renew tomorrow.';

  @override
  String get superUsed =>
      'You\'ve used today\'s Super Like. Get 5 a day with the Super Like plan.';

  @override
  String get rewindLocked =>
      'Bringing back someone you skipped by mistake comes with Unlimited Likes.';

  @override
  String rewoundTo(String mode) {
    return 'The last person you skipped is back in the $mode deck.';
  }

  @override
  String boostReason(int minutes) {
    return 'With a Boost you appear at the top of decks for $minutes minutes.';
  }

  @override
  String boosting(int minutes) {
    return 'You\'re boosted. $minutes minutes left.';
  }

  @override
  String get boostUsed => 'You\'ve used today\'s Boost. It renews tomorrow.';

  @override
  String get boost => 'Boost';

  @override
  String boostBody(int minutes) {
    return 'For $minutes minutes you appear first in the decks of people in your shared groups. Once a day.';
  }

  @override
  String boosted(int minutes) {
    return 'You\'re boosted! You\'re on top for $minutes minutes.';
  }

  @override
  String get deckEmpty =>
      'Nobody left to show for now. This fills up as you join groups and people turn on matching.';

  @override
  String get deckEmptyFiltered =>
      'Nobody left who fits your filters. Try widening them.';

  @override
  String get refresh => 'Refresh';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String allowanceUnlimited(int supers) {
    return 'Unlimited likes · $supers Super Likes left.';
  }

  @override
  String get allowanceOut => 'You\'re out of likes today; they renew tomorrow.';

  @override
  String allowance(int likes, int supers) {
    return 'Today you have $likes likes and $supers Super Likes left.';
  }

  @override
  String get undo => 'Undo';

  @override
  String get pass => 'Pass';

  @override
  String get superLike => 'Super Like';

  @override
  String get like => 'Like';

  @override
  String get introTitle => 'Meet new people from your shared groups';

  @override
  String get intro1 =>
      'You only see people who turned on matching in groups you belong to or follow.';

  @override
  String get intro2 => 'Swipe right to like, left to pass, up to Super Like.';

  @override
  String get intro3 =>
      'When you both like each other, you match. You write to your match with the Match Chat plan.';

  @override
  String get intro4 =>
      'Friends and Dating are separate modes; choose one or both.';

  @override
  String get intro5 =>
      'Your profile is only visible to people who turned on matching. Pause or delete it any time.';

  @override
  String get createMyProfile => 'Create my matching profile';

  @override
  String seePackageOf(String package) {
    return 'See the $package plan';
  }

  @override
  String get allPackages => 'All plans';

  @override
  String get packagesTitle => 'Matching plans';

  @override
  String get packagesIntro =>
      'Creating a profile and swiping are free. Each feature is its own plan; get only what you want.';

  @override
  String get adminAllOpen => 'All plans are on for you as an admin';

  @override
  String openUntil(String date) {
    return 'Active until $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Age: $min – $max';
  }

  @override
  String get allProvinces => 'All provinces';

  @override
  String get interest => 'Interest';

  @override
  String get all => 'All';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get noAdmirers =>
      'No pending likes for now. Keep swiping; people who like you appear here.';

  @override
  String get backToSwiping => 'Back to swiping';

  @override
  String get likeAndMatch => 'Like and match';

  @override
  String get noPendingLikes => 'No pending likes yet';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people liked you',
      one: '1 person liked you',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'See who they are with the Who Likes You plan and match instantly by liking back.';

  @override
  String get seePackage => 'See the plan';
}
