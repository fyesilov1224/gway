import 'package:core/core.dart';

import '../l10n.dart';
import 'social.dart';

/// How experienced the person is in their activities.
enum TeammateLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  const TeammateLevel(this.key);

  final String key;

  String get label => switch (this) {
        beginner => profileL10n.levelBeginner,
        intermediate => profileL10n.levelIntermediate,
        advanced => profileL10n.levelAdvanced,
      };

  String get hint => switch (this) {
        beginner => profileL10n.levelBeginnerHint,
        intermediate => profileL10n.levelIntermediateHint,
        advanced => profileL10n.levelAdvancedHint,
      };

  static TeammateLevel? parse(Object? key) => values.where((l) => l.key == key).firstOrNull;
}

/// When the person is usually free: weekday or weekend, by part of the day.
enum TeammateSlot {
  weekdayMorning('weekday_morning', weekend: false),
  weekdayNoon('weekday_noon', weekend: false),
  weekdayEvening('weekday_evening', weekend: false),
  weekendMorning('weekend_morning', weekend: true),
  weekendAfternoon('weekend_afternoon', weekend: true),
  weekendEvening('weekend_evening', weekend: true);

  const TeammateSlot(this.key, {required this.weekend});

  final String key;
  final bool weekend;

  String get label => switch (this) {
        weekdayMorning => profileL10n.slotWeekdayMorning,
        weekdayNoon => profileL10n.slotWeekdayNoon,
        weekdayEvening => profileL10n.slotWeekdayEvening,
        weekendMorning => profileL10n.slotWeekendMorning,
        weekendAfternoon => profileL10n.slotWeekendAfternoon,
        weekendEvening => profileL10n.slotWeekendEvening,
      };

  /// Morning, midday or evening, for the availability grid.
  String get part => switch (this) {
        weekdayMorning || weekendMorning => profileL10n.partMorning,
        weekdayNoon || weekendAfternoon => profileL10n.partNoon,
        weekdayEvening || weekendEvening => profileL10n.partEvening,
      };

  static List<TeammateSlot> parseAll(Object? keys) => [
        for (final slot in values)
          if (keys is List && keys.contains(slot.key)) slot,
      ];
}

/// What the person wants out of it.
enum TeammateGoal {
  fun('fun'),
  fitness('fitness'),
  competition('competition'),
  learning('learning'),
  mentoring('mentoring'),
  social('social');

  const TeammateGoal(this.key);

  final String key;

  String get label => switch (this) {
        fun => profileL10n.goalFun,
        fitness => profileL10n.goalFitness,
        competition => profileL10n.goalCompetition,
        learning => profileL10n.goalLearning,
        mentoring => profileL10n.goalMentoring,
        social => profileL10n.goalSocial,
      };

  static List<TeammateGoal> parseAll(Object? keys) => [
        for (final g in values)
          if (keys is List && keys.contains(g.key)) g,
      ];
}

/// How often the person wants to meet.
enum TeammateFrequency {
  monthly('monthly'),
  weekly('weekly'),
  fewWeekly('few_weekly'),
  daily('daily');

  const TeammateFrequency(this.key);

  final String key;

  String get label => switch (this) {
        monthly => profileL10n.freqMonthly,
        weekly => profileL10n.freqWeekly,
        fewWeekly => profileL10n.freqFewWeekly,
        daily => profileL10n.freqDaily,
      };

  static TeammateFrequency? parse(Object? key) => values.where((f) => f.key == key).firstOrNull;
}

/// The team the person likes to go with.
enum TeammateGroupSize {
  pair('pair'),
  small('small'),
  large('large');

  const TeammateGroupSize(this.key);

  final String key;

  String get label => switch (this) {
        pair => profileL10n.sizePair,
        small => profileL10n.sizeSmall,
        large => profileL10n.sizeLarge,
      };

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

  String get label => level == null ? profileL10n.looking : profileL10n.lookingWithLevel(level!.label);
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
        if (activities.isNotEmpty) profileL10n.reasonActivities(formatList(activities)),
        if (interests.isNotEmpty) profileL10n.reasonInterests(formatList(interests)),
        if (sameProvince) profileL10n.reasonProvince,
        if (groups.isNotEmpty) groups.length == 1 ? profileL10n.reasonGroup(groups.first) : profileL10n.reasonGroups(groups.length),
        if (sameLevel && level != null) profileL10n.reasonLevel(level!.label),
        if (times.isNotEmpty) profileL10n.reasonTimes(formatList(times.map((t) => t.label))),
        if (goals.isNotEmpty) profileL10n.reasonGoals(formatList(goals.map((g) => g.label))),
        if (sameFrequency) profileL10n.reasonFrequency,
        if (hasVehicle) profileL10n.hasVehicle,
        if (hasEquipment) profileL10n.hasEquipment,
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
