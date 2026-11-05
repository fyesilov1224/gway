library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'src/domain/chess.dart';
export 'src/l10n.dart' show gamesL10n;
export 'src/presentation/chess_home_screen.dart';
export 'src/presentation/game_screen.dart';
export 'src/presentation/leaderboard_screen.dart';
export 'src/presentation/player_screen.dart' show ChessPlayerScreen;
export 'src/presentation/providers.dart' show challengesProvider;
export 'src/presentation/routes.dart';
export 'src/presentation/seek_screen.dart';

/// Adds the piece set's Apache 2.0 license to the app's licenses page (docs/ARCHITECTURE.md §3i, lisanslar).
void registerGamesLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('packages/games/assets/pieces/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['Chessnut chess pieces (Alexis Luengas)'], 'Copyright 2015 Alexis Luengas\n\n$text');
  });
}
