import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n.dart';
import 'language.dart';
import 'session.dart';
import 'supabase_errors.dart';

/// Shared reference data (`public.categories`, owned by core): profile
/// interests and group categories.
class Category {
  const Category({required this.slug, required this.name});

  final String slug;
  final String name;
}

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  ref.watch(appLanguageProvider); // names follow the language
  try {
    // Supabase sorts descending unless told otherwise.
    final rows = await ref
        .watch(supabaseClientProvider)
        .from('categories')
        .select('slug, name')
        .order('sort_order', ascending: true);
    return [for (final r in rows) Category(slug: r['slug'] as String, name: categoryLabel(r['slug'] as String, fallback: r['name'] as String))];
  } on Object catch (e) {
    throw failureFromSupabase(e);
  }
});
