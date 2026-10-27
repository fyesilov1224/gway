import 'package:core/core.dart';

import 'social.dart';

/// How experienced the person is in their activities.
enum TeammateLevel {
  beginner('beginner', 'Başlangıç', 'Yeni başlıyorum'),
  intermediate('intermediate', 'Orta', 'Düzenli yapıyorum'),
  advanced('advanced', 'İleri', 'Deneyimliyim');

  const TeammateLevel(this.key, this.label, this.hint);

  final String key;
  final String label;
  final String hint;

  static TeammateLevel? parse(Object? key) => values.where((l) => l.key == key).firstOrNull;
}

/// When the person is usually free: weekday or weekend, by part of the day.
enum TeammateSlot {
  weekdayMorning('weekday_morning', 'Hafta içi sabah', weekend: false, part: 'Sabah'),
  weekdayNoon('weekday_noon', 'Hafta içi öğle', weekend: false, part: 'Öğle'),
  weekdayEvening('weekday_evening', 'Hafta içi akşam', weekend: false, part: 'Akşam'),
  weekendMorning('weekend_morning', 'Hafta sonu sabah', weekend: true, part: 'Sabah'),
  weekendAfternoon('weekend_afternoon', 'Hafta sonu öğleden sonra', weekend: true, part: 'Öğle'),
  weekendEvening('weekend_evening', 'Hafta sonu akşam', weekend: true, part: 'Akşam');

  const TeammateSlot(this.key, this.label, {required this.weekend, required this.part});

  final String key;
  final String label;
  final bool weekend;

  /// Sabah, Öğle or Akşam, for the availability grid.
  final String part;

  static List<TeammateSlot> parseAll(Object? keys) => [
        for (final slot in values)
          if (keys is List && keys.contains(slot.key)) slot,
      ];
}

/// What the person wants out of it.
enum TeammateGoal {
  fun('fun', 'Eğlenmek'),
  fitness('fitness', 'Formda kalmak'),
  competition('competition', 'Yarışmaya hazırlanmak'),
  learning('learning', 'Yeni şeyler öğrenmek'),
  mentoring('mentoring', 'Deneyimimi paylaşmak'),
  social('social', 'Yeni insanlarla tanışmak');

  const TeammateGoal(this.key, this.label);

  final String key;
  final String label;

  static List<TeammateGoal> parseAll(Object? keys) => [
        for (final g in values)
          if (keys is List && keys.contains(g.key)) g,
      ];
}

/// How often the person wants to meet.
enum TeammateFrequency {
  monthly('monthly', 'Ayda birkaç kez'),
  weekly('weekly', 'Haftada bir'),
  fewWeekly('few_weekly', 'Haftada 2–3'),
  daily('daily', 'Neredeyse her gün');

  const TeammateFrequency(this.key, this.label);

  final String key;
  final String label;

  static TeammateFrequency? parse(Object? key) => values.where((f) => f.key == key).firstOrNull;
}

/// The team the person likes to go with.
enum TeammateGroupSize {
  pair('pair', 'Birebir'),
  small('small', 'Küçük grup (3–6)'),
  large('large', 'Kalabalık grup');

  const TeammateGroupSize(this.key, this.label);

  final String key;
  final String label;

  static List<TeammateGroupSize> parseAll(Object? keys) => [
        for (final s in values)
          if (keys is List && keys.contains(s.key)) s,
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
    this.activities = const {},
    this.goals = const {},
    this.frequency,
    this.groupSizes = const {},
    this.hasVehicle = false,
    this.hasEquipment = false,
  });

  static const noteMaxLength = 140;
  static const maxActivities = 8;

  final bool looking;
  final TeammateLevel? level;
  final Set<TeammateSlot> availability;

  /// Plate number, 1–81 (see [turkishProvinces]).
  final int? province;
  final String note;

  /// Category slugs the person wants teammates for.
  final Set<String> activities;
  final Set<TeammateGoal> goals;
  final TeammateFrequency? frequency;
  final Set<TeammateGroupSize> groupSizes;
  final bool hasVehicle;
  final bool hasEquipment;

  /// How many of the eight sections are answered, for the completeness bar.
  int get answered => [
        activities.isNotEmpty,
        level != null,
        goals.isNotEmpty,
        frequency != null,
        availability.isNotEmpty,
        groupSizes.isNotEmpty,
        province != null,
        note.trim().isNotEmpty,
      ].where((a) => a).length;

  static const sections = 8;
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
    this.activities = const [],
    this.goals = const [],
    this.sameFrequency = false,
    this.hasVehicle = false,
    this.hasEquipment = false,
  });

  final PersonSummary person;
  final TeammateLevel? level;
  final String note;
  final List<String> interests;
  final List<String> groups;
  final List<TeammateSlot> times;
  final bool sameLevel;
  final bool sameProvince;

  /// Shared activities (category names) and goals.
  final List<String> activities;
  final List<TeammateGoal> goals;
  final bool sameFrequency;
  final bool hasVehicle;
  final bool hasEquipment;

  List<String> get reasons => [
        if (activities.isNotEmpty) 'Aynı aktivite: ${activities.join(', ')}',
        if (interests.isNotEmpty) 'Ortak ilgi: ${interests.join(', ')}',
        if (sameProvince) 'Aynı ildesiniz',
        if (groups.isNotEmpty) groups.length == 1 ? 'Ortak grup: ${groups.first}' : '${groups.length} ortak grup',
        if (sameLevel && level != null) 'İkiniz de ${level!.label.toLowerCase()} seviye',
        if (times.isNotEmpty) 'Uygun zaman: ${times.map((t) => t.label.toLowerCase()).join(', ')}',
        if (goals.isNotEmpty) 'Ortak hedef: ${goals.map((g) => g.label.toLowerCase()).join(', ')}',
        if (sameFrequency) 'Aynı sıklıkta buluşmak istiyorsunuz',
        if (hasVehicle) 'Aracı var',
        if (hasEquipment) 'Kendi ekipmanı var',
      ];
}

class TeammateRequest {
  const TeammateRequest({required this.person, required this.createdAt, this.message = ''});

  final PersonSummary person;
  final String message;
  final DateTime createdAt;
}

class MyTeammates {
  const MyTeammates({
    this.teammates = const [],
    this.incoming = const [],
    this.outgoing = const [],
    this.locked = false,
    this.waiting = 0,
  });

  final List<PersonSummary> teammates;
  final List<TeammateRequest> incoming;
  final List<TeammateRequest> outgoing;

  /// The section needs the Ekip Arkadaşı package; until then the lists are empty (docs/ARCHITECTURE.md §3g).
  final bool locked;

  /// Requests waiting for the user while [locked].
  final int waiting;
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
