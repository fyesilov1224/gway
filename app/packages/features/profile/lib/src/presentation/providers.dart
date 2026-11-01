import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_profile_repository.dart';
import '../domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

/// The signed-in user's profile; null before onboarding or when signed out.
final myProfileProvider = FutureProvider<Profile?>((ref) async {
  if (ref.watch(currentUserIdProvider) == null) return null;
  return (await ref.watch(profileRepositoryProvider).mine()).getOrThrow();
});

final profileByUsernameProvider = FutureProvider.family<Profile, String>(
  (ref, username) async =>
      (await ref.watch(profileRepositoryProvider).byUsername(username)).getOrThrow(),
);

/// The end of a visited user's suspension (a notice on the profile); null when not suspended.
final profileSuspensionProvider = FutureProvider.autoDispose.family<DateTime?, String>(
  (ref, userId) async {
    ref.cacheFor();
    return (await ref.watch(profileRepositoryProvider).suspendedUntil(userId)).getOrThrow();
  },
);

final interestsProvider = FutureProvider.family<List<String>, String>(
  (ref, userId) async =>
      (await ref.watch(profileRepositoryProvider).interests(userId)).getOrThrow(),
);
