import 'package:flutter/material.dart';
import 'dart:async';
import '../models/event.dart';
import '../services/event_api_service.dart';
import '../widgets/event_card.dart';
import 'event_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  final List<Map<String, dynamic>> _popularCategories = const [
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Conference', 'icon': Icons.business},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
    {'name': 'Food & Drink', 'icon': Icons.restaurant},
    {'name': 'Art & Culture', 'icon': Icons.palette},
    {'name': 'Workshop', 'icon': Icons.school},
  ];

  List<Event> _results = [];
  bool _loading = false;
  String _selectedCategory = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  _triggerSearch();
                  setState(() {});
                },
              ),
            ),
            // Search Results or Suggestions
            Expanded(
              child: _showingSuggestions
                  ? _buildSuggestions()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showingSuggestions => _searchController.text.isEmpty && _selectedCategory.isEmpty && !_loading && _results.isEmpty;

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._recentSearches.map((search) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _searchController.text = search;
                  _selectedCategory = '';
                  _triggerSearch();
                },
              )),
          const SizedBox(height: 24),
        ],
        const Text(
          'Popular Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._popularCategories.map((c) => _buildCategoryChip(c['name'], c['icon'])),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        _selectedCategory = selected ? label : '';
        _triggerSearch();
      },
    );
  }

  Widget _buildSearchResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final event = _results[index];
        return EventCard(
          event: event,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
        );
      },
    );
  }

  void _triggerSearch() {
    // Save recent
    final q = _searchController.text.trim();
    if (q.isNotEmpty && (_recentSearches.isEmpty || _recentSearches.first != q)) {
      _recentSearches.remove(q);
      _recentSearches.insert(0, q);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _loading = true);
      final results = await EventApiService.getEvents(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    });
  }
}

