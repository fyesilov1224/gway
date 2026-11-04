// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GroupsL10nEn extends GroupsL10n {
  GroupsL10nEn([String locale = 'en']) : super(locale);

  @override
  String get unsupportedImage =>
      'This file type is not supported. Choose JPEG, PNG or WebP.';

  @override
  String get joinOpen => 'Open to everyone';

  @override
  String get joinOpenHint => 'Anyone can join directly.';

  @override
  String get joinRequest => 'Request to join';

  @override
  String get joinRequestHint => 'Admins approve join requests.';

  @override
  String get joinInvite => 'Invite only';

  @override
  String get joinInviteHint => 'Only invited people can join.';

  @override
  String get roleOwner => 'Group owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleDiscipline => 'Disciplinary board';

  @override
  String get roleModerator => 'Moderator';

  @override
  String get roleMember => 'Member';

  @override
  String get handleMin => 'The group address must be at least 3 characters.';

  @override
  String get handleChars =>
      'Use only lowercase letters, numbers, underscores and periods.';

  @override
  String get handleDots =>
      'It can\'t start or end with a period or use two in a row.';

  @override
  String get nameMin => 'The group name must be at least 3 characters.';

  @override
  String nameMax(int max) {
    return 'The group name can be at most $max characters.';
  }

  @override
  String get httpsOnly => 'Enter an address that starts with https://.';

  @override
  String get createGroup => 'Create group';

  @override
  String get groupInfo => 'Group details';

  @override
  String get groupInfoHint =>
      'You can add a logo, cover, rules and links after creating the group.';

  @override
  String get groupName => 'Group name';

  @override
  String get about => 'About';

  @override
  String get aboutHint => 'What does your group do, and who can join?';

  @override
  String get joining => 'Joining';

  @override
  String get changeLater => 'You can change this later.';

  @override
  String get createTheGroup => 'Create the group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get noEditPermission =>
      'You don\'t have permission to edit this group.';

  @override
  String get backToGroup => 'Back to group';

  @override
  String get save => 'Save';

  @override
  String get logoAndCover => 'Logo and cover';

  @override
  String get imageHint => 'JPEG, PNG or WebP · up to 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Cover';

  @override
  String groupHandle(String handle) {
    return 'Group address: @$handle';
  }

  @override
  String get rules => 'Rules';

  @override
  String get rulesHint => 'What you expect from members, one rule per line.';

  @override
  String get links => 'Links';

  @override
  String linksHint(int max) {
    return 'Website and social media accounts. Up to $max.';
  }

  @override
  String get enterLabel => 'Enter a label.';

  @override
  String get label => 'Label';

  @override
  String get address => 'Address';

  @override
  String get removeLink => 'Remove link';

  @override
  String get addLink => 'Add link';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get deleteGroupBody =>
      'The group, memberships, roles, requests and invitations are deleted permanently. The remaining plan time is not refunded.';

  @override
  String deleteGroupNamed(String name) {
    return 'Delete $name';
  }

  @override
  String changeImage(String label) {
    return 'Change $label';
  }

  @override
  String addImage(String label) {
    return 'Add $label';
  }

  @override
  String get remove => 'Remove';

  @override
  String get deleteForever => 'Delete group permanently';

  @override
  String deleteConfirm(String handle) {
    return 'This can\'t be undone. To confirm, type the group address: $handle';
  }

  @override
  String get delete => 'Delete';

  @override
  String get group => 'Group';

  @override
  String get share => 'Share';

  @override
  String shareText(String name) {
    return 'Check out $name on GWAY:';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get groupNotFound =>
      'This group was not found or is no longer visible.';

  @override
  String get backToGroups => 'Back to groups';

  @override
  String leaveConfirm(String name) {
    return 'Leave $name? If you have a role in the group, it is removed too.';
  }

  @override
  String get leave => 'Leave';

  @override
  String leftGroup(String name) {
    return 'You left $name.';
  }

  @override
  String get suspendedNotice =>
      'The platform team has suspended this group. While suspended, only members can see it.';

  @override
  String founded(String date) {
    return 'Founded $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count join requests are waiting for approval.',
      one: '1 join request is waiting for approval.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Review';

  @override
  String get requestSent => 'Your join request has been sent.';

  @override
  String get youAreMember => 'You\'re a member';

  @override
  String get join => 'Join';

  @override
  String joined(String name) {
    return 'You joined $name.';
  }

  @override
  String get sendJoinRequest => 'Request to join';

  @override
  String get requestSentShort => 'Requested';

  @override
  String get withdrawRequest => 'Withdraw request';

  @override
  String get withdrawConfirm => 'Withdraw your join request?';

  @override
  String get undo => 'Withdraw';

  @override
  String get requestWithdrawn => 'Your join request was withdrawn.';

  @override
  String get decline => 'Decline';

  @override
  String get inviteDeclined => 'Invitation declined.';

  @override
  String get acceptInvite => 'Accept invitation';

  @override
  String followOn(String name) {
    return '$name\'s posts will appear in your feed.';
  }

  @override
  String get followOff => 'You stopped following the group.';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get managementTeam => 'Management team';

  @override
  String allMembers(int count) {
    return 'All members ($count)';
  }

  @override
  String get groups => 'Groups';

  @override
  String get discover => 'Discover';

  @override
  String get myGroups => 'My groups';

  @override
  String get plans => 'Plans';

  @override
  String get searchHint => 'Search by group name or address';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get all => 'All';

  @override
  String get noMatch => 'No groups match your search.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noGroupsYet => 'There are no groups yet. Start the first one.';

  @override
  String get showMore => 'Show more';

  @override
  String get notJoinedYet => 'You haven\'t joined a group yet.';

  @override
  String get discoverGroups => 'Discover groups';

  @override
  String get plansHint =>
      'Group owners buy plans. Start your group and choose a plan.';

  @override
  String get yourInvitations => 'Your invitations';

  @override
  String get invitationsHint => 'These groups invited you to join.';

  @override
  String invitedBy(String name) {
    return 'Invited by $name';
  }

  @override
  String get linkCopied => 'Link copied.';

  @override
  String inviteShareText(String name) {
    return 'Join $name on GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Revoke link?';

  @override
  String get revokeLinkBody =>
      'No one can join with this link anymore. People who already joined stay members.';

  @override
  String get revoke => 'Revoke';

  @override
  String get inviteLink => 'Invite link';

  @override
  String get inviteLinkHint =>
      'Share it on WhatsApp or Instagram. Anyone who opens the link joins directly, whatever the joining type.';

  @override
  String get createLink => 'Create link';

  @override
  String validUntil(String date) {
    return 'Until $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people joined',
      one: '1 person joined',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max joined';
  }

  @override
  String get newInviteLink => 'New invite link';

  @override
  String get validity => 'Valid for';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'How many people can join?';

  @override
  String get unlimited => 'Unlimited';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Create and share';

  @override
  String get invitation => 'Invitation';

  @override
  String get linkInvalid =>
      'This invite link is no longer valid. You can ask the group\'s admin for a new one.';

  @override
  String get seeGroup => 'See group';

  @override
  String get invitedToGroup => 'You\'ve been invited to this group.';

  @override
  String get joinGroup => 'Join group';

  @override
  String get members => 'Members';

  @override
  String get requests => 'Requests';

  @override
  String get invitations => 'Invitations';

  @override
  String get roles => 'Roles';

  @override
  String get openCase => 'Open a disciplinary case';

  @override
  String get report => 'Report';

  @override
  String membersVisibility(int shown, int total) {
    return 'Only group members see the full member list. Shown here: the management team and $shown people who made their groups public; the group has $total members in total.';
  }

  @override
  String optionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String get transferOwnership => 'Transfer ownership';

  @override
  String transferBody(String group, String person) {
    return 'Ownership of $group will pass to $person. You\'ll stay on as a regular member, and you can\'t undo this.';
  }

  @override
  String get transfer => 'Transfer';

  @override
  String transferred(String name) {
    return 'Ownership transferred to $name.';
  }

  @override
  String get hintAdmin =>
      'Edits the group and manages join requests and invitations.';

  @override
  String get hintDiscipline =>
      'Reviews complaint cases and decides on sanctions.';

  @override
  String get hintModerator => 'Reviews posts and comments.';

  @override
  String personJoined(String name) {
    return '$name joined the group.';
  }

  @override
  String get requestDeclined => 'Request declined.';

  @override
  String get noPendingRequests => 'No pending join requests.';

  @override
  String get refresh => 'Refresh';

  @override
  String get approve => 'Approve';

  @override
  String get inviteSent => 'Invitation sent.';

  @override
  String get inviteByUsername => 'Invite by username';

  @override
  String get invite => 'Invite';

  @override
  String get noPendingInvites => 'No pending invitations.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'Suspended';

  @override
  String get groupsSection => 'Groups';

  @override
  String get groupsOwnHint =>
      'Only members of the same group see your groups. You can make them public in Settings.';

  @override
  String get groupsOtherHint =>
      'Only your shared groups and groups they help run are shown.';

  @override
  String get noGroupsToShow => 'No groups to show.';

  @override
  String get handleTaken => 'This group address is taken. Try another one.';

  @override
  String get groupAddress => 'Group address';

  @override
  String get groupAddressHint =>
      'Your group page\'s address. It can\'t be changed later.';

  @override
  String get available => 'Available';

  @override
  String get taken => 'Taken';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get provinceOptional => 'Province (optional)';

  @override
  String get provinceHint => 'The group appears in this province on the map.';

  @override
  String get chooseCategory => 'Choose a category.';

  @override
  String get category => 'Category';
}
