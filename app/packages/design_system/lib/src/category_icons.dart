import 'package:flutter/material.dart';

/// Icons of the shared `categories` (profile interests, group categories).
const _categoryIcons = <String, IconData>{
  'music': Icons.music_note_outlined,
  'hiking': Icons.hiking,
  'running': Icons.directions_run,
  'cycling': Icons.directions_bike,
  'nature': Icons.park_outlined,
  'sports': Icons.sports_soccer_outlined,
  'art': Icons.palette_outlined,
  'photography': Icons.photo_camera_outlined,
  'dance': Icons.nightlife_outlined,
  'books': Icons.menu_book_outlined,
  'games': Icons.sports_esports_outlined,
  'travel': Icons.flight_outlined,
  'food': Icons.restaurant_outlined,
  'technology': Icons.memory_outlined,
  'volunteering': Icons.volunteer_activism_outlined,
  'motorcycle': Icons.two_wheeler,
  'camping': Icons.forest_outlined,
  'chess': Icons.extension_outlined,
};

IconData categoryIcon(String slug) => _categoryIcons[slug] ?? Icons.tag;
