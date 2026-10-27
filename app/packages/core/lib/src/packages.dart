import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the screen of a paid package by its billing slug (e.g. `matching_teammates`), so a feature
/// package can offer it without importing the matching or billing packages (docs/ARCHITECTURE.md §3g).
typedef OpenPackage = void Function(BuildContext context, String slug);

/// Overridden by the app with its route.
final packageOpenerProvider = Provider<OpenPackage>(
  (ref) => throw UnimplementedError('packageOpenerProvider must be overridden'),
);
