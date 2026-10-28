import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository_impl.dart';
import '../data/goals_repository_impl.dart';
import '../domain/events.dart';
import '../domain/goals.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupEventsProvider = FutureProvider.autoDispose.family<GroupEvents, String>(
  (ref, groupId) async => (await ref.watch(eventsRepositoryProvider).groupEvents(groupId)).getOrThrow(),
);

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => GoalsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupGoalsProvider = FutureProvider.autoDispose.family<List<Goal>, String>(
  (ref, groupId) async => (await ref.watch(goalsRepositoryProvider).groupGoals(groupId)).getOrThrow(),
);

final goalDetailProvider = FutureProvider.autoDispose.family<GoalDetail, String>(
  (ref, id) async => (await ref.watch(goalsRepositoryProvider).goal(id)).getOrThrow(),
);

/// One calendar page: [from, to) in local time, a group's or the user's own.
typedef CalendarQuery = ({DateTime from, DateTime to, String? groupId, bool includeGroups});

final calendarProvider = FutureProvider.autoDispose.family<List<GroupEvent>, CalendarQuery>(
  (ref, q) async =>
      (await ref.watch(eventsRepositoryProvider).calendar(q.from, q.to, groupId: q.groupId, includeGroups: q.includeGroups)).getOrThrow(),
);

/// Null when the person's content is private to the viewer.
final contributionsProvider = FutureProvider.autoDispose.family<Contributions?, String>(
  (ref, userId) async => (await ref.watch(eventsRepositoryProvider).contributions(userId)).getOrThrow(),
);

final badgeCatalogProvider = FutureProvider<List<ContributionBadge>>(
  (ref) async => (await ref.watch(eventsRepositoryProvider).badgeCatalog()).getOrThrow(),
);

final groupContributionsProvider = FutureProvider.autoDispose.family<Map<String, ({int attended, int organized})>, String>(
  (ref, groupId) async => (await ref.watch(eventsRepositoryProvider).groupContributions(groupId)).getOrThrow(),
);

/// Other groups' events that day nearby, for the event form; [day] is a local midnight.
final similarEventsProvider = FutureProvider.autoDispose.family<int?, ({String groupId, DateTime day})>(
  (ref, key) async => (await ref.watch(eventsRepositoryProvider).similarEventsCount(key.groupId, key.day)).getOrThrow(),
);

final eventDetailProvider = FutureProvider.autoDispose.family<EventDetail, String>(
  (ref, id) async => (await ref.watch(eventsRepositoryProvider).event(id)).getOrThrow(),
);

/// A group's polls, or (with an event id) only that event's.
typedef PollScope = ({String groupId, String? eventId});

final pollsProvider = FutureProvider.autoDispose.family<List<Poll>, PollScope>(
  (ref, scope) async => (await ref.watch(eventsRepositoryProvider).polls(scope.groupId, eventId: scope.eventId)).getOrThrow(),
);

final pollVotersProvider = FutureProvider.autoDispose.family<List<EventPerson>, int>(
  (ref, optionId) async => (await ref.watch(eventsRepositoryProvider).voters(optionId)).getOrThrow(),
);
