import 'package:core/core.dart';

/// GWAY is for adults only (docs/ARCHITECTURE.md §3a, Yaş sınırı).
const minimumAge = 18;

/// Full years between [birth] and [today] (dates only).
int ageOn(DateTime birth, DateTime today) {
  var age = today.year - birth.year;
  if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
  return age;
}

/// The user's own date of birth; added once, never shown to others.
abstract interface class BirthDateRepository {
  /// Null when it has not been given yet.
  Future<Result<DateTime?>> mine();

  Future<Result<void>> save(DateTime birthDate);
}
