// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SupportL10nEn extends SupportL10n {
  SupportL10nEn([String locale = 'en']) : super(locale);

  @override
  String get ruleTicketRate =>
      'You\'ve opened too many messages today. Try again tomorrow or reply in your open messages.';

  @override
  String get ruleReplyRate =>
      'You\'ve written too many replies in a short time. Wait a bit and try again.';

  @override
  String get ticketClosed =>
      'This message is closed. Open a new message to continue.';

  @override
  String get unsupportedImage =>
      'This file type is not supported. Choose JPEG, PNG or WebP.';

  @override
  String get kindProblem => 'Problem';

  @override
  String get kindProblemText => 'Something is broken or doesn\'t work.';

  @override
  String get kindRequest => 'Request';

  @override
  String get kindRequestText =>
      'Ask for something to be done for your account, group or payment.';

  @override
  String get kindSuggestion => 'Suggestion';

  @override
  String get kindSuggestionText => 'Share a new feature idea or suggestion.';

  @override
  String get statusOpen => 'New';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusClosed => 'Closed';

  @override
  String get guide => 'User guide';

  @override
  String get guideSearchHint => 'Search the guide: e.g. invite link, password';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get guideIntro =>
      'Explains every part of GWAY step by step. Pick a chapter or search above.';

  @override
  String get noHits =>
      'We couldn\'t find that. Try another word or write to the support team.';

  @override
  String get writeSupport => 'Write to support';

  @override
  String hitsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count topics found',
      one: '1 topic found',
    );
    return '$_temp0';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary $count topics.';
  }

  @override
  String topicCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count topics',
      one: '1 topic',
    );
    return '$_temp0';
  }

  @override
  String get chapterNotFound => 'This chapter was not found.';

  @override
  String get backToGuide => 'Back to the guide';

  @override
  String get notSolved => 'Didn\'t solve your problem?';

  @override
  String get notSolvedHint =>
      'Write to the platform team; you\'ll see the reply in Settings → Support and feedback.';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get sent => 'Your message was sent to the platform team.';

  @override
  String get newMessage => 'New message';

  @override
  String get aboutWhat => 'What are you writing about?';

  @override
  String get pickKind => 'Choose a type.';

  @override
  String get relatedGroup => 'Related group (optional)';

  @override
  String get noGroup => 'Not about a group';

  @override
  String get subject => 'Subject';

  @override
  String get subjectRequired => 'Write a short subject.';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'What happened, and what did you expect? More detail means faster help.';

  @override
  String get descriptionRequired => 'Briefly describe what happened.';

  @override
  String get send => 'Send';

  @override
  String get supportTitle => 'Support and feedback';

  @override
  String get emptyIntro =>
      'You can write to the platform team about a problem, request or suggestion.';

  @override
  String get listIntro =>
      'Your messages go to the platform team; follow the replies and status here.';

  @override
  String get newReply => 'New reply';

  @override
  String get message => 'Message';

  @override
  String get notFound => 'This message was not found.';

  @override
  String get goBack => 'Go back';

  @override
  String get team => 'GWAY Team';

  @override
  String get you => 'You';

  @override
  String get addScreenshot => 'Add a screenshot';

  @override
  String get writeReply => 'Write a reply';

  @override
  String get removeImage => 'Remove image';

  @override
  String screenshots(int count, int max) {
    return 'Screenshots ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Enlarge screenshot';
}
