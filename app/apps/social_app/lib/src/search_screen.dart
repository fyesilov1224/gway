import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/profile.dart';

/// Account search with follow buttons; suggestions while the field is empty.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
        _controller.clear();
        _query = '';
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Kişi ara',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(tooltip: 'Aramayı temizle', icon: const Icon(Icons.close), onPressed: _clear),
          ),
        ),
      ),
      body: GxReadingColumn(child: PeopleSearchResults(query: _query, onClear: _clear)),
    );
  }
}
