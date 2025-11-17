import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
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
  final List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];

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
    _initializeEvents();
    _filterEvents();
  }

  void _initializeEvents() {
    _allEvents.addAll([
      Event(
        id: '1',
        title: 'PCPS Dashain Fest 2025',
        category: 'Music',
        dateTime: DateTime(2025, 11, 15, 18, 0),
        location: 'Kupondole, Lalitpur',
        attendees: 2500,
        price: 'From Rs. 100',
        imageUrl: '',
        iconEmoji: '🎵',
      ),
      Event(
        id: '2',
        title: 'Tech Innovation Conference',
        category: 'Conference',
        dateTime: DateTime(2025, 11, 8, 9, 0),
        location: 'Hotel Soaltee, Kathmandu',
        attendees: 850,
        price: 'From Rs. 80',
        imageUrl: '',
      ),
      Event(
        id: '3',
        title: 'College Basketball Championship',
        category: 'Sports',
        dateTime: DateTime(2025, 11, 5, 19, 30),
        location: 'PCPS College, Kupondole',
        attendees: 5000,
        price: 'From Rs. 250',
        imageUrl: '',
        iconEmoji: '🏀',
      ),
      Event(
        id: '4',
        title: 'International Food Festival',
        category: 'Food & Drink',
        dateTime: DateTime(2025, 11, 14, 11, 0),
        location: 'Bhrikutimandap, KTM',
        attendees: 3200,
        price: 'Free Entry',
        imageUrl: '',
        iconEmoji: '🍜',
      ),
      Event(
        id: '5',
        title: 'Modern Art Exhibition',
        category: 'Art & Culture',
        dateTime: DateTime(2025, 11, 1, 10, 0),
        location: 'Naxal, KTM',
        attendees: 450,
        price: 'From Rs. 75',
        imageUrl: '',
        iconEmoji: '🎨',
      ),
      Event(
        id: '6',
        title: 'Digital Marketing Workshop',
        category: 'Workshop',
        dateTime: DateTime(2025, 11, 20, 14, 0),
        location: 'Learning Hub Room 301',
        attendees: 120,
        price: 'From Rs. 89',
        imageUrl: '',
      ),
      Event(
        id: '7',
        title: 'Jazz Night Under the Stars',
        category: 'Music',
        dateTime: DateTime(2025, 11, 18, 20, 0),
        location: 'Maitidevi',
        attendees: 600,
        price: 'From Rs. 300',
        imageUrl: '',
        iconEmoji: '✈️',
      ),
      Event(
        id: '8',
        title: 'Startup Pitch Competition',
        category: 'Conference',
        dateTime: DateTime(2025, 11, 10, 13, 0),
        location: 'Global College',
        attendees: 300,
        price: 'From Rs. 50',
        imageUrl: '',
        iconEmoji: '🚀',
      ),
    ]);
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
    setState(() {
      final index = _allEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _allEvents[index] = Event(
          id: _allEvents[index].id,
          title: _allEvents[index].title,
          category: _allEvents[index].category,
          dateTime: _allEvents[index].dateTime,
          location: _allEvents[index].location,
          attendees: _allEvents[index].attendees,
          price: _allEvents[index].price,
          imageUrl: _allEvents[index].imageUrl,
          iconEmoji: _allEvents[index].iconEmoji,
          isBookmarked: !_allEvents[index].isBookmarked,
        );
        _filterEvents();
      }
    });
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

