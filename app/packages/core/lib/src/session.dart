import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_client.dart';
import 'app_config.dart';

/// Set in each app's `main` via `ProviderScope(overrides: ...)`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Supabase auth events, starting with the current session.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = ref.watch(supabaseClientProvider).auth;
  return auth.onAuthStateChange;
});

/// Signed-in user id, or null. Rebuilds dependants on sign-in / sign-out.
final currentUserIdProvider = Provider<String?>((ref) {
  final state = ref.watch(authStateProvider);
  return state.value?.session?.user.id ??
      ref.watch(supabaseClientProvider).auth.currentUser?.id;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: Uri.parse(ref.watch(appConfigProvider).apiUrl),
    accessToken: () =>
        ref.read(supabaseClientProvider).auth.currentSession?.accessToken,
  );
  ref.onDispose(client.close);
  return client;
});
