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
