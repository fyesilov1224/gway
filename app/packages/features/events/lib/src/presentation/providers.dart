import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository_impl.dart';
import '../data/goals_repository_impl.dart';
import '../domain/events.dart';
import '../domain/exploration.dart';
import '../domain/goals.dart';
import '../domain/handshakes.dart';
import '../domain/tonight.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupEventsProvider = FutureProvider.autoDispose.family<GroupEvents, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).groupEvents(groupId)).getOrThrow();
  },
);

/// Events starting in the next 6 hours (Bugün).
final startingSoonProvider = FutureProvider.autoDispose<List<GroupEvent>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).startingSoon()).getOrThrow();
  },
);

/// The user's evening (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa).
final tonightProvider = FutureProvider.autoDispose<Tonight>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).tonight()).getOrThrow();
  },
);

/// People free tonight who share a group with the user.
final tonightPeopleProvider = FutureProvider.autoDispose<List<TonightPerson>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).tonightPeople()).getOrThrow();
  },
);

/// Reloads what Bugün shows from this feature (pull to refresh).
void refreshToday(WidgetRef ref) => ref.invalidate(startingSoonProvider);

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => GoalsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupGoalsProvider = FutureProvider.autoDispose.family<List<Goal>, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(goalsRepositoryProvider).groupGoals(groupId)).getOrThrow();
  },
);

final goalDetailProvider = FutureProvider.autoDispose.family<GoalDetail, String>(
  (ref, id) async {
    ref.cacheFor();
    return (await ref.watch(goalsRepositoryProvider).goal(id)).getOrThrow();
  },
);

/// One calendar page: [from, to) in local time, a group's or the user's own.
typedef CalendarQuery = ({DateTime from, DateTime to, String? groupId, bool includeGroups});

final calendarProvider = FutureProvider.autoDispose.family<List<GroupEvent>, CalendarQuery>(
  (ref, q) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).calendar(q.from, q.to, groupId: q.groupId, includeGroups: q.includeGroups)).getOrThrow();
  },
);

/// "Yaklaşanlar": the user's own and their groups' events in the next 60 days. Day precision keeps
/// the provider key stable, so the create sheet and the page share one load.
CalendarQuery upcomingQuery() {
  final today = DateTime.now();
  final from = DateTime(today.year, today.month, today.day);
  return (from: from, to: DateTime(from.year, from.month, from.day + 60), groupId: null, includeGroups: true);
}

/// Null when the person's content is private to the viewer.
final contributionsProvider = FutureProvider.autoDispose.family<Contributions?, String>(
  (ref, userId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).contributions(userId)).getOrThrow();
  },
);

final badgeCatalogProvider = FutureProvider<List<ContributionBadge>>(
  (ref) async => (await ref.watch(eventsRepositoryProvider).badgeCatalog()).getOrThrow(),
);

final groupContributionsProvider = FutureProvider.autoDispose.family<Map<String, ({int attended, int organized})>, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).groupContributions(groupId)).getOrThrow();
  },
);

/// Other groups' events that day nearby, for the event form; [day] is a local midnight.
final similarEventsProvider = FutureProvider.autoDispose.family<int?, ({String groupId, DateTime day})>(
  (ref, key) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).similarEventsCount(key.groupId, key.day)).getOrThrow();
  },
);

/// The welcome block; reloads with the event page, since going or leaving changes it.
final eventWelcomeProvider = FutureProvider.autoDispose.family<EventWelcome?, String>((ref, id) async {
  ref.cacheFor();
  await ref.watch(eventDetailProvider(id).future);
  return (await ref.watch(eventsRepositoryProvider).eventWelcome(id)).getOrThrow();
});

final groupWelcomeProvider = FutureProvider.autoDispose.family<GroupWelcome?, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).groupWelcome(groupId)).getOrThrow();
  },
);

final leagueTableProvider = FutureProvider.autoDispose.family<LeagueTable, LeagueKey>(
  (ref, key) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).leagueTable(key.category, key.province, key.month)).getOrThrow();
  },
);

final groupLeagueProvider = FutureProvider.autoDispose.family<GroupLeague?, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).groupLeague(groupId)).getOrThrow();
  },
);

final leagueCategoriesProvider = FutureProvider<List<LeagueCategory>>(
  (ref) async => (await ref.watch(eventsRepositoryProvider).leagueCategories()).getOrThrow(),
);

final eventDetailProvider = FutureProvider.autoDispose.family<EventDetail, String>(
  (ref, id) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).event(id)).getOrThrow();
  },
);

/// A group's polls, or (with an event id) only that event's.
typedef PollScope = ({String groupId, String? eventId});

final pollsProvider = FutureProvider.autoDispose.family<List<Poll>, PollScope>(
  (ref, scope) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).polls(scope.groupId, eventId: scope.eventId)).getOrThrow();
  },
);

final pollVotersProvider = FutureProvider.autoDispose.family<List<EventPerson>, int>(
  (ref, optionId) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).voters(optionId)).getOrThrow();
  },
);

/// eventsL10n.metPeople: the people the signed-in person met at events.
final metPeopleProvider = FutureProvider.autoDispose<List<MetPerson>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).metPeople()).getOrThrow();
  },
);

/// The signed-in person's exploration map.
final explorationProvider = FutureProvider.autoDispose<Exploration>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).exploration()).getOrThrow();
  },
);

/// Province outlines for the exploration map, read once from the package's asset.
final provinceShapesProvider = FutureProvider<ProvinceShapes>(
  (ref) async => parseProvinceShapes(await rootBundle.loadString('packages/events/assets/tr_provinces.json')),
);

/// The signed-in person's year in review.
final yearSummaryProvider = FutureProvider.autoDispose.family<YearSummary?, int>(
  (ref, year) async {
    ref.cacheFor();
    return (await ref.watch(eventsRepositoryProvider).yearSummary(year)).getOrThrow();
  },
);
