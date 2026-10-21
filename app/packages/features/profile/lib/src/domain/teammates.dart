import 'package:core/core.dart';

import 'social.dart';

/// How experienced the person is in their activities.
enum TeammateLevel {
  beginner('beginner', 'Başlangıç'),
  intermediate('intermediate', 'Orta'),
  advanced('advanced', 'İleri');

  const TeammateLevel(this.key, this.label);

  final String key;
  final String label;

  static TeammateLevel? parse(Object? key) => values.where((l) => l.key == key).firstOrNull;
}

/// When the person is usually free.
enum TeammateSlot {
  weekdayMorning('weekday_morning', 'Hafta içi sabah'),
  weekdayEvening('weekday_evening', 'Hafta içi akşam'),
  weekendMorning('weekend_morning', 'Hafta sonu sabah'),
  weekendAfternoon('weekend_afternoon', 'Hafta sonu öğleden sonra');

  const TeammateSlot(this.key, this.label);

  final String key;
  final String label;

  static List<TeammateSlot> parseAll(Object? keys) => [
        for (final slot in values)
          if (keys is List && keys.contains(slot.key)) slot,
      ];
}

/// The signed-in user's own settings; the province only matches people and is never shown.
class TeammatePreferences {
  const TeammatePreferences({
    this.looking = false,
    this.level,
    this.availability = const {},
    this.province,
    this.note = '',
  });

  static const noteMaxLength = 140;

  final bool looking;
  final TeammateLevel? level;
  final Set<TeammateSlot> availability;

  /// Plate number, 1–81 (see [turkishProvinces]).
  final int? province;
  final String note;
}

enum TeammateRelation { self, none, requested, incoming, teammates }

/// What a profile shows: "Ekip arıyor · Orta seviye" and the viewer's relation.
class TeammateStatus {
  const TeammateStatus({required this.looking, this.level, this.relation = TeammateRelation.none});

  final bool looking;
  final TeammateLevel? level;
  final TeammateRelation relation;

  String get label => level == null ? 'Ekip arıyor' : 'Ekip arıyor · ${level!.label} seviye';
}

/// A suggested person with the reasons they were suggested.
class TeammateSuggestion {
  const TeammateSuggestion({
    required this.person,
    this.level,
    this.note = '',
    this.interests = const [],
    this.groups = const [],
    this.times = const [],
    this.sameLevel = false,
    this.sameProvince = false,
  });

  final PersonSummary person;
  final TeammateLevel? level;
  final String note;
  final List<String> interests;
  final List<String> groups;
  final List<TeammateSlot> times;
  final bool sameLevel;
  final bool sameProvince;

  List<String> get reasons => [
        if (interests.isNotEmpty) 'Ortak ilgi: ${interests.join(', ')}',
        if (sameProvince) 'Aynı ildesiniz',
        if (groups.isNotEmpty) groups.length == 1 ? 'Ortak grup: ${groups.first}' : '${groups.length} ortak grup',
        if (sameLevel && level != null) 'İkiniz de ${level!.label.toLowerCase()} seviye',
        if (times.isNotEmpty) 'Uygun zaman: ${times.map((t) => t.label.toLowerCase()).join(', ')}',
      ];
}

class TeammateRequest {
  const TeammateRequest({required this.person, required this.createdAt, this.message = ''});

  final PersonSummary person;
  final String message;
  final DateTime createdAt;
}

class MyTeammates {
  const MyTeammates({this.teammates = const [], this.incoming = const [], this.outgoing = const []});

  final List<PersonSummary> teammates;
  final List<TeammateRequest> incoming;
  final List<TeammateRequest> outgoing;
}

/// Reads through Supabase; requests and the relation through the C# API (docs/ARCHITECTURE.md §3c, Ekip arkadaşı).
abstract interface class TeammatesRepository {
  Future<Result<TeammatePreferences>> preferences();

  Future<Result<void>> savePreferences(TeammatePreferences preferences);

  Future<Result<TeammateStatus?>> status(String userId);

  Future<Result<List<TeammateSuggestion>>> suggestions();

  Future<Result<MyTeammates>> mine();

  /// Sends a request; returns [TeammateRelation.teammates] when the other person had already asked.
  Future<Result<TeammateRelation>> request(String userId, {String message = ''});

  /// Withdraws a request or ends the pair.
  Future<Result<void>> remove(String userId);

  Future<Result<void>> accept(String userId);

  Future<Result<void>> decline(String userId);
}
