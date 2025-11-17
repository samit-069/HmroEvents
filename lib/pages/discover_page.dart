import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../models/event_store.dart';
import 'profile_page.dart';
import 'event_details_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String selectedCategory = 'All Events';
  String currentLocation = 'Kupondole, Lalitpur';
  late final EventStore _eventStore;
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  late VoidCallback _eventListener;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All Events', 'icon': Icons.local_fire_department, 'emoji': '🔥'},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Conference', 'icon': Icons.business},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
    {'name': 'Food & Drink', 'icon': Icons.restaurant},
    {'name': 'Art & Culture', 'icon': Icons.palette},
    {'name': 'Workshop', 'icon': Icons.school},
  ];

  @override
  void initState() {
    super.initState();
    _eventStore = EventStore.instance;
    _allEvents = _eventStore.events;
    _filterEvents();
    _eventListener = () {
      setState(() {
        _allEvents = _eventStore.events;
        _filterEvents();
      });
    };
    _eventStore.eventsNotifier.addListener(_eventListener);
  }

  @override
  void dispose() {
    _eventStore.eventsNotifier.removeListener(_eventListener);
    super.dispose();
  }

  void _filterEvents() {
    if (selectedCategory == 'All Events') {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents
          .where((event) => event.category == selectedCategory)
          .toList();
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      _filterEvents();
    });
  }

  void _onBookmark(Event event) {
    _eventStore.toggleBookmark(event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Top Row: Title and Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discover Events',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Location Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Location Search Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Change your location...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                currentLocation = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Get current location
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Category Filters
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = selectedCategory == category['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: () => _onCategorySelected(category['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category['emoji'] != null)
                          Text(
                            category['emoji'],
                            style: const TextStyle(fontSize: 16),
                          )
                        else
                          Icon(
                            category['icon'],
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Events List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCategory,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${_filteredEvents.length} events',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return EventCard(
                          event: event,
                          onBookmark: () => _onBookmark(event),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

