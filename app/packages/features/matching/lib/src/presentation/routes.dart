import '../domain/matching.dart';

abstract final class MatchingRoutes {
  static const home = '/matching';
  static const matches = '/matching/matches';
  static const likes = '/matching/likes';
  static const packages = '/matching/packages';

  static String package(MatchPackage p) => '/matching/packages/${p.slug}';
  static const profile = '/matching/profile';
  static const setup = '/matching/setup';
}
