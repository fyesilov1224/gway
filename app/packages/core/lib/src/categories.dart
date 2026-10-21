import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  try {
    // Supabase sorts descending unless told otherwise.
    final rows = await ref
        .watch(supabaseClientProvider)
        .from('categories')
        .select('slug, name')
        .order('sort_order', ascending: true);
    return [for (final r in rows) Category(slug: r['slug'] as String, name: r['name'] as String)];
  } on Object catch (e) {
    throw failureFromSupabase(e);
  }
});
