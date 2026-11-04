import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/call_keep_alive.dart';
import '../data/calls_repository_impl.dart';
import '../data/native_calls.dart';
import '../domain/calls.dart';
import 'call_session.dart';

final callsRepositoryProvider = Provider<CallsRepository>(
  (ref) => CallsRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

/// The phone's own incoming call screen (Android).
final nativeCallsProvider = Provider<NativeCalls>((_) => const CallkitNativeCalls());

/// Whether a chat may call now; asked fresh each time the chat opens (permissions change in the groups).
final callEligibilityProvider = FutureProvider.autoDispose.family<CallEligibility, String>(
  (ref, conversationId) async => (await ref.watch(callsRepositoryProvider).eligibility(conversationId)).getOrThrow(),
);

final myCallPermissionProvider = FutureProvider.autoDispose<CallPermission>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(callsRepositoryProvider).myPermission()).getOrThrow();
});

/// Groups the signed-in person may send a voice call request to.
final myCallGroupsProvider = FutureProvider.autoDispose<List<CallGroup>>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(callsRepositoryProvider).myGroups()).getOrThrow();
});

/// A group's voice call requests; null for those who may not decide them.
final groupCallDeskProvider = FutureProvider.autoDispose.family<GroupCallDesk?, String>(
  (ref, groupId) async => (await ref.watch(callsRepositoryProvider).groupDesk(groupId)).getOrThrow(),
);


/// Calls ringing for the signed-in person.
final incomingCallsProvider = StreamProvider.autoDispose<List<CallInfo>>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return Stream.value(const []);
  return ref.watch(callsRepositoryProvider).incoming();
});

final callPeerProvider = FutureProvider.autoDispose.family<CallPeer, String>(
  (ref, userId) async => (await ref.watch(callsRepositoryProvider).peer(userId)).getOrThrow(),
);

/// What rings: the callee's ring, or the tone the caller hears while it rings at the other end.
enum CallTone { incoming, outgoing }

/// Plays a tone in a loop until stopped; replaced in tests.
abstract interface class CallRinger {
  Future<void> start(CallTone tone);

  Future<void> stop();
}

final callRingerProvider = Provider<CallRinger>((ref) {
  final ringer = _AudioRinger();
  ref.onDispose(ringer.dispose);
  return ringer;
});

class _AudioRinger implements CallRinger {
  final _player = AudioPlayer()..audioCache = AudioCache(prefix: 'packages/messaging/assets/');

  /// The callee's ring sounds like the phone's ringer: at ring volume and not in silent mode (docs/ARCHITECTURE.md
  /// §3c, Arama zili). The caller's tone stays as it was, beside the call's own audio.
  static final _ringing = AudioContextConfig(respectSilence: true, focus: AudioContextConfigFocus.gain).build();
  static final _ringback = AudioContextConfig().build();

  @override
  Future<void> start(CallTone tone) async {
    await _player.setAudioContext(tone == CallTone.incoming ? _ringing : _ringback);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(tone == CallTone.incoming ? 'call_ring.wav' : 'call_ringback.wav'));
  }

  @override
  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

/// Keeps the call's audio going in the background (Android foreground service); replaced in tests.
final callKeepAliveProvider = Provider<CallKeepAlive>((_) => const PlatformCallKeepAlive());

/// A new audio session for a call screen; replaced in tests.
final callSessionFactoryProvider = Provider<CallSession Function()>((_) => CallSession.new);
