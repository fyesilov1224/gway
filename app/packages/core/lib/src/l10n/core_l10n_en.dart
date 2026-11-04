// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoreL10nEn extends CoreL10n {
  CoreL10nEn([String locale = 'en']) : super(locale);

  @override
  String get networkFailure =>
      'Couldn\'t connect. Check your internet connection and try again.';

  @override
  String get unauthorizedFailure =>
      'Your session has expired. Please sign in again.';

  @override
  String get forbiddenFailure => 'You don\'t have permission to do this.';

  @override
  String get notFoundFailure => 'We couldn\'t find what you\'re looking for.';

  @override
  String get rateLimitedFailure =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get unexpectedFailure => 'Something went wrong. Please try again.';

  @override
  String get storageTooLarge =>
      'The file is too large. You can upload up to 5 MB.';

  @override
  String get storageUnsupportedType =>
      'This file type is not supported. Choose JPEG, PNG or WebP.';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryHiking => 'Hiking';

  @override
  String get categoryRunning => 'Running';

  @override
  String get categoryCycling => 'Cycling';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryArt => 'Art';

  @override
  String get categoryPhotography => 'Photography';

  @override
  String get categoryDance => 'Dance';

  @override
  String get categoryBooks => 'Books';

  @override
  String get categoryGames => 'Games';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryVolunteering => 'Volunteering';

  @override
  String get categoryMotorcycle => 'Motorcycling';

  @override
  String get categoryCamping => 'Camping';

  @override
  String get categoryChess => 'Chess';
}
