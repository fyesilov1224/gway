import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/events_repository_impl.dart';
import '../domain/events.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupEventsProvider = FutureProvider.autoDispose.family<GroupEvents, String>(
  (ref, groupId) async => (await ref.watch(eventsRepositoryProvider).groupEvents(groupId)).getOrThrow(),
);

/// One calendar page: [from, to) in local time, a group's or the user's own.
typedef CalendarQuery = ({DateTime from, DateTime to, String? groupId, bool includeGroups});

final calendarProvider = FutureProvider.autoDispose.family<List<GroupEvent>, CalendarQuery>(
  (ref, q) async =>
      (await ref.watch(eventsRepositoryProvider).calendar(q.from, q.to, groupId: q.groupId, includeGroups: q.includeGroups)).getOrThrow(),
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
