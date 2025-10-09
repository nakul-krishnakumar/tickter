import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart'; // We'll reuse the PostCard widget

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Called every time the text in the search bar changes.
  void _onSearchChanged(String query) {
    // Debouncing: Wait for the user to stop typing for 500ms before making a request.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _results = [];
        });
      }
    });
  }

  /// Performs the search by calling your backend API.
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use the correct local URL for your backend's search endpoint.
      final uri = Uri.parse('http://10.0.2.2:8081/api/v1/posts/search?q=$query');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // The results are nested inside the 'results' key in your backend's response.
          _results = List<Map<String, dynamic>>.from(data['results']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The search bar is in the AppBar.
        title: TextField(
          controller: _searchController,
          autofocus: true, // Automatically focus the search bar
          decoration: const InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _buildResultsBody(),
    );
  }

  Widget _buildResultsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_results.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('No results found.'));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Start typing to search for posts.'));
    }

    // Display the results in a ListView, reusing the PostCard widget.
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final post = _results[index];
        // We need to simulate the 'profiles' join for the PostCard.
        // In a more advanced setup, your search endpoint would also join the profiles table.
        post['profiles'] = {'first_name': 'Search', 'last_name': 'Result'};
        return PostCard(post: post);
      },
    );
  }
}
