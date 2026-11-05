import 'package:core/core.dart';
import 'package:country_flags/country_flags.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/chess.dart';
import '../domain/countries.dart';
import '../l10n.dart';

/// The country's name in the app language (CLDR), or the code when unknown.
String countryName(String code) {
  final i = countryCodes.indexOf(code);
  if (i < 0) return code;
  return (countryNames[currentAppLanguage.code] ?? countryNames['en']!)[i];
}

/// The country a new chess card suggests: the app language's main country.
String defaultCountry() => switch (currentAppLanguage.code) {
      'tr' => 'TR',
      'en' => 'GB',
      'de' => 'DE',
      'fr' => 'FR',
      'nl' => 'NL',
      'es' => 'ES',
      'pt' => 'BR',
      'it' => 'IT',
      'ru' => 'RU',
      'ar' => 'SA',
      'az' => 'AZ',
      'uk' => 'UA',
      _ => 'TR',
    };

/// A small rounded flag; nothing when the person chose none.
class ChessFlag extends StatelessWidget {
  const ChessFlag(this.code, {super.key, this.height = GwSpacing.sm});

  final String? code;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = code;
    if (c == null) return const SizedBox.shrink();
    return Semantics(
      label: countryName(c),
      child: CountryFlag.fromCountryCode(
        c,
        theme: ImageTheme(width: height * 4 / 3, height: height, shape: const RoundedRectangle(GwRadius.sm / 4)),
      ),
    );
  }
}

/// A gold, silver or bronze medal for the top three; a plain rank number below.
class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.rank, this.size = GwSpacing.xl});

  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final medal = GwMedal.forRank(rank);
    final textTheme = Theme.of(context).textTheme;
    if (medal == null) {
      return SizedBox(
        width: size,
        child: Text('$rank', textAlign: TextAlign.center, style: textTheme.titleSmall?.copyWith(color: GwColors.textSecondary)),
      );
    }
    return Semantics(
      excludeSemantics: true,
      label: switch (medal) {
        GwMedal.gold => gamesL10n.medalGold,
        GwMedal.silver => gamesL10n.medalSilver,
        GwMedal.bronze => gamesL10n.medalBronze,
      },
      child: GwMedalBadge(medal: medal, rank: rank, size: size),
    );
  }
}

/// An avatar wearing the crown of its place: gold, silver or bronze for the top three, nothing below.
class Crowned extends StatelessWidget {
  const Crowned({super.key, required this.rank, required this.avatarSize, required this.child});

  final int rank;

  /// The avatar's width; the crown is about half as wide and sits on its top edge.
  final double avatarSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final medal = GwMedal.forRank(rank);
    if (medal == null) return child;
    final crown = avatarSize * 0.55;
    return Padding(
      // Room above the avatar for the crown.
      padding: EdgeInsets.only(top: crown * GwCrown.aspect * 0.6),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          child,
          Positioned(
            top: -crown * GwCrown.aspect * 0.6,
            child: Transform.rotate(angle: rank == 1 ? 0 : (rank == 2 ? -0.18 : 0.18), child: GwCrown(medal: medal, size: crown)),
          ),
        ],
      ),
    );
  }
}

/// "+12" in green, "−8" in red, "±0" quiet.
class RatingDelta extends StatelessWidget {
  const RatingDelta(this.delta, {super.key, this.style});

  final int delta;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.labelLarge;
    final (text, color) = switch (delta) {
      > 0 => ('+$delta', GwColors.success),
      < 0 => ('−${-delta}', GwColors.error),
      _ => ('±0', GwColors.textSecondary),
    };
    return Text(text, style: base?.copyWith(color: color, fontWeight: FontWeight.w700));
  }
}

/// Avatar, name, flag and an optional line under it.
class ChessPlayerLine extends StatelessWidget {
  const ChessPlayerLine({super.key, required this.player, this.subtitle, this.trailing, this.size = GwAvatarSize.md, this.onTap});

  final ChessPlayer player;
  final String? subtitle;
  final Widget? trailing;
  final GwAvatarSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final line = Row(
      children: [
        GwAvatar(name: player.displayName, shape: GwAvatarShape.user, imageUrl: player.avatarUrl, size: size),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(child: Text(player.displayName, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
                  if (player.country != null) ...[const SizedBox(width: GwSpacing.xs), ChessFlag(player.country)],
                ],
              ),
              Text(
                subtitle ?? atName(player.username),
                style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
    if (onTap == null) return line;
    return InkWell(borderRadius: GwRadius.mdAll, onTap: onTap, child: line);
  }
}

/// mm:ss, and tenths under 10 seconds.
String formatClock(int ms) {
  final clamped = ms < 0 ? 0 : ms;
  final total = clamped ~/ 1000;
  final minutes = total ~/ 60;
  final seconds = total % 60;
  if (clamped < 10000) return '$minutes:${seconds.toString().padLeft(2, '0')}.${(clamped % 1000) ~/ 100}';
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

IconData chessCategoryIcon(ChessCategory c) => switch (c) {
      ChessCategory.bullet => Icons.bolt_rounded,
      ChessCategory.blitz => Icons.local_fire_department_outlined,
      ChessCategory.rapid => Icons.timer_outlined,
    };

/// The result of a game for one side, in words: "Kazandın", "Kaybettin", "Berabere".
String resultFor(ChessGame game, ChessColor color) => switch (game.scoreFor(color)) {
      1.0 => gamesL10n.youWon,
      0.0 => gamesL10n.youLost,
      0.5 => gamesL10n.draw,
      _ => game.status == GameStatus.aborted ? gamesL10n.endAborted : gamesL10n.inProgress,
    };
