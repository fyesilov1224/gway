import 'package:core/core.dart';

/// Where the app runs, as the live users list shows it (docs/ARCHITECTURE.md §8b, Canlı kullanıcılar).
enum PresencePlatform { android, ios, web }

/// "I have the app open" beats for the admin panel's live users list.
abstract interface class PresenceRepository {
  Future<Result<void>> touch(PresencePlatform platform);

  /// Off the list at once: the app went to the background or is signing out.
  Future<Result<void>> leave();
}
