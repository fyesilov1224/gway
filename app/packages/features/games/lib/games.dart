library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'src/domain/arena.dart' show ArenaStatus;
export 'src/domain/chess.dart';
export 'src/domain/mind.dart' show MindMatch, mindLengths;
export 'src/domain/team.dart' show TeamGame, TeamMatchStatus;
export 'src/l10n.dart' show gamesL10n;
export 'src/presentation/arena_screens.dart' show ArenaScreen, ArenasScreen;
export 'src/presentation/chess_home_screen.dart';
export 'src/presentation/game_screen.dart';
export 'src/presentation/games_hub_screen.dart';
export 'src/presentation/leaderboard_screen.dart' show ChessLeaderboardScreen;
export 'src/presentation/mind_match_screen.dart' show MindMatchScreen;
export 'src/presentation/mind_providers.dart' show mindChallengesProvider;
export 'src/presentation/mind_screens.dart' show MindHomeScreen, MindLeaderboardScreen, MindPlayerScreen, MindSeekScreen;
export 'src/presentation/player_screen.dart' show ChessPlayerScreen;
export 'src/presentation/providers.dart' show challengesProvider;
export 'src/presentation/routes.dart';
export 'src/presentation/seek_screen.dart';
export 'src/presentation/team_screens.dart' show TeamMatchScreen;

/// Adds the piece sets' licenses to the app's licenses page (docs/ARCHITECTURE.md §3i, lisanslar).
void registerGamesLicenses() {
  LicenseRegistry.addLicense(() async* {
    Future<String> read(String file) => rootBundle.loadString('packages/games/assets/pieces/licenses/$file');
    yield LicenseEntryWithLineBreaks(['Cburnett chess pieces (Colin M.L. Burnett)'], await read('cburnett-bsd-3-clause.txt'));
    yield LicenseEntryWithLineBreaks(['GWAY Pro chess pieces (after Colin M.L. Burnett)'], await read('pro-bsd-3-clause.txt'));
    yield LicenseEntryWithLineBreaks(['Papercut chess pieces (Nikolay Anzarov)'], await read('papercut-cc-by-4.0.txt'));
    yield LicenseEntryWithLineBreaks(['Celtic, Fantasy and Spatial chess pieces (Maurizio Monge)'], await read('monge-mit.txt'));
    yield LicenseEntryWithLineBreaks(
        ['Chessnut chess pieces (Alexis Luengas)'], 'Copyright 2015 Alexis Luengas\n\n${await read('chessnut-apache-2.0.txt')}');
    yield LicenseEntryWithLineBreaks(['Vector Ranks chess pieces (RhosGFX)'], await read('rhosgfx-cc0.txt'));
  });
}
